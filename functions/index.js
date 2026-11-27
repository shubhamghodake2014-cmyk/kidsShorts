require("dotenv").config();

const express = require("express");
const cors = require("cors");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;
const PORT = 3000;

// Search.list costs 100 YouTube quota units per request. Cache results on disk
// so restarting Node or reopening the app does not repeat the same searches.
const CACHE_FILE = path.join(__dirname, ".kidzshorts-youtube-cache.json");
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;
const cache = new Map();
const inFlight = new Map();
let quotaBlockedUntil = 0;

try {
    if (fs.existsSync(CACHE_FILE)) {
        const saved = JSON.parse(fs.readFileSync(CACHE_FILE, "utf8"));
        for (const [key, value] of Object.entries(saved.cache || {})) {
            cache.set(key, value);
        }
        quotaBlockedUntil = Number(saved.quotaBlockedUntil || 0);
    }
} catch (error) {
    console.warn("KidzShorts cache could not be loaded:", error.message);
}

let saveQueue = Promise.resolve();
function persistCache() {
    const snapshot = {
        quotaBlockedUntil,
        cache: Object.fromEntries(cache.entries())
    };
    saveQueue = saveQueue
        .then(async () => {
            const tempFile = `${CACHE_FILE}.tmp`;
            await fs.promises.writeFile(tempFile, JSON.stringify(snapshot), "utf8");
            await fs.promises.rename(tempFile, CACHE_FILE);
        })
        .catch(error => console.warn("KidzShorts cache save failed:", error.message));
    return saveQueue;
}

function makeCacheKey({ category, language, pageToken, duration, shorts }) {
    return [category, language, pageToken || "first-page", duration, shorts ? "shorts" : "home"].join("|");
}

function nextPacificMidnight() {
    const timeZone = "America/Los_Angeles";
    const formatter = new Intl.DateTimeFormat("en-US", {
        timeZone,
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
        hourCycle: "h23"
    });
    const parts = Object.fromEntries(formatter.formatToParts(new Date()).map(p => [p.type, p.value]));
    const nextDayUtc = Date.UTC(Number(parts.year), Number(parts.month) - 1, Number(parts.day) + 1, 0, 0, 0);
    const targetParts = Object.fromEntries(formatter.formatToParts(new Date(nextDayUtc)).map(p => [p.type, p.value]));
    const targetAsUtc = Date.UTC(Number(targetParts.year), Number(targetParts.month) - 1, Number(targetParts.day), Number(targetParts.hour), Number(targetParts.minute), Number(targetParts.second));
    const offset = targetAsUtc - nextDayUtc;
    return nextDayUtc - offset;
}

function isQuotaError(status, message) {
    const text = String(message || "").toLowerCase();
    return status === 429 || text.includes("quota") || text.includes("dailylimitexceeded") || text.includes("quotaexceeded");
}

app.get("/", (req, res) => {
    res.send("KidzShorts YouTube API Backend is running!");
});

const searchKeywords = {
    mr: {
        Rhymes: "मराठी बालगीते बडबडगीते",
        Education: "मराठी मुलांचे शैक्षणिक व्हिडिओ",
        Learning: "मराठी मुलांचे शैक्षणिक व्हिडिओ",
        Stories: "मराठी मुलांच्या गोष्टी",
        Cartoons: "मराठी मुलांचे कार्टून",
        Animals: "मुलांसाठी प्राण्यांची माहिती मराठी",
        All: "मराठी मुलांचे मनोरंजक शैक्षणिक व्हिडिओ"
    },
    hi: {
        Rhymes: "हिंदी बालगीत",
        Education: "हिंदी बच्चों की शैक्षिक वीडियो",
        Learning: "हिंदी बच्चों की शैक्षिक वीडियो",
        Stories: "हिंदी बच्चों की कहानियां",
        Cartoons: "हिंदी बच्चों के कार्टून",
        Animals: "बच्चों के लिए जानवरों की जानकारी हिंदी",
        All: "बच्चों के लिए हिंदी मनोरंजक शैक्षिक वीडियो"
    },
    en: {
        Rhymes: "English nursery rhymes",
        Education: "English educational videos for kids",
        Learning: "English learning videos for children",
        Stories: "English bedtime stories for kids",
        Cartoons: "English cartoons for kids",
        Animals: "animal facts and learning videos for kids",
        All: "fun educational videos for children"
    }
};

async function youtubeSearch({ category, language, pageToken, duration, shorts }) {
    const validCategories = Object.keys(searchKeywords[language] || {});
    if (!validCategories.includes(category)) {
        const error = new Error("Invalid category");
        error.status = 400;
        throw error;
    }

    const request = { category, language, pageToken, duration, shorts };
    const cacheKey = makeCacheKey(request);
    const cached = cache.get(cacheKey);
    const now = Date.now();

    // Fresh disk/memory cache: no YouTube API quota is consumed.
    if (cached && now - cached.savedAt < CACHE_TTL_MS) {
        return { ...cached.result, cached: true };
    }

    // If another request for the same category is already running, share it.
    if (inFlight.has(cacheKey)) return inFlight.get(cacheKey);

    // After Google reports daily quota exhausted, don't repeatedly hit the API.
    if (now < quotaBlockedUntil) {
        if (cached) return { ...cached.result, cached: true, stale: true };
        const error = new Error("YouTube daily quota is exhausted. Try again after the quota reset, or use a category that has cached videos.");
        error.status = 429;
        throw error;
    }

    const task = (async () => {
        if (!YOUTUBE_API_KEY) {
            const error = new Error("YouTube API key not configured");
            error.status = 500;
            throw error;
        }

        const keyword = searchKeywords[language][category];
        const query = shorts ? `${keyword} #shorts` : keyword;
        const params = {
            part: "snippet",
            q: query,
            type: "video",
            videoDuration: duration,
            videoEmbeddable: "true",
            safeSearch: "strict",
            relevanceLanguage: language,
            regionCode: "IN",
            order: "relevance",
            maxResults: "50",
            key: YOUTUBE_API_KEY
        };
        if (pageToken) params.pageToken = pageToken;

        const url = new URL("https://www.googleapis.com/youtube/v3/search");
        url.search = new URLSearchParams(params).toString();
        const response = await fetch(url);
        const data = await response.json();

        if (!response.ok) {
            const message = data.error?.message || "YouTube API request failed";
            if (isQuotaError(response.status, message)) {
                quotaBlockedUntil = nextPacificMidnight();
                await persistCache();
            }
            const error = new Error(message);
            error.status = response.status;
            throw error;
        }

        const uniqueVideos = [];
        const seenIds = new Set();
        for (const item of data.items || []) {
            const videoId = item.id?.videoId;
            if (!videoId || seenIds.has(videoId)) continue;
            seenIds.add(videoId);
            uniqueVideos.push({
                videoId,
                title: item.snippet.title,
                description: item.snippet.description,
                thumbnail: item.snippet.thumbnails.high?.url || item.snippet.thumbnails.medium?.url || item.snippet.thumbnails.default?.url,
                channelTitle: item.snippet.channelTitle
            });
        }

        const result = {
            category,
            language,
            searchType: shorts ? "Shorts-focused" : "Home landscape video discovery",
            count: uniqueVideos.length,
            nextPageToken: data.nextPageToken || null,
            videos: uniqueVideos
        };

        cache.set(cacheKey, { savedAt: Date.now(), result });
        await persistCache();
        return { ...result, cached: false };
    })();

    inFlight.set(cacheKey, task);
    try {
        return await task;
    } catch (error) {
        // If a stale result exists, keep the app usable when YouTube is down/quota-limited.
        if (cached && isQuotaError(error.status, error.message)) {
            return { ...cached.result, cached: true, stale: true };
        }
        throw error;
    } finally {
        inFlight.delete(cacheKey);
    }
}

app.get("/videos", async (req, res) => {
    try {
        const result = await youtubeSearch({
            category: req.query.category || "Rhymes",
            language: req.query.language || "mr",
            pageToken: req.query.pageToken,
            duration: "short",
            shorts: true
        });
        res.json(result);
    } catch (error) {
        console.error("YouTube Shorts API Error:", error.message);
        res.status(error.status || 500).json({ error: error.message || "Internal server error" });
    }
});

app.get("/home-videos", async (req, res) => {
    try {
        const result = await youtubeSearch({
            category: req.query.category || "All",
            language: req.query.language || "mr",
            pageToken: req.query.pageToken,
            duration: "medium",
            shorts: false
        });
        res.json(result);
    } catch (error) {
        console.error("YouTube Home API Error:", error.message);
        res.status(error.status || 500).json({ error: error.message || "Internal server error" });
    }
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`KidzShorts Backend running on port ${PORT}`);
    console.log("YouTube search cache: enabled (24-hour TTL)");
});
