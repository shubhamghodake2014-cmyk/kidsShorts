require("dotenv").config();

const express = require("express");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY;

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
    if (!YOUTUBE_API_KEY) {
        const error = new Error("YouTube API key not configured");
        error.status = 500;
        throw error;
    }

    const validCategories = Object.keys(searchKeywords[language] || {});
    if (!validCategories.includes(category)) {
        const error = new Error("Invalid category");
        error.status = 400;
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
        const error = new Error(data.error?.message || "YouTube API request failed");
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

    return {
        category,
        language,
        searchType: shorts ? "Shorts-focused" : "Home landscape video discovery",
        count: uniqueVideos.length,
        nextPageToken: data.nextPageToken || null,
        videos: uniqueVideos
    };
}

// Vertical Shorts endpoint. Existing app behavior is preserved.
app.get("/videos", async (req, res) => {
    try {
        const category = req.query.category || "Rhymes";
        const language = req.query.language || "mr";
        if (!["mr", "hi", "en"].includes(language)) {
            return res.status(400).json({ error: "Invalid language" });
        }
        const result = await youtubeSearch({
            category,
            language,
            pageToken: req.query.pageToken,
            duration: "short",
            shorts: true
        });
        res.json(result);
    } catch (error) {
        console.error("YouTube Shorts API Error:", error);
        res.status(error.status || 500).json({ error: error.message || "Internal server error" });
    }
});

// Home endpoint. Uses medium-length videos and landscape thumbnail cards.
// YouTube Search API does not expose a reliable portrait/landscape filter;
// cards are presented in 16:9 layout and videos play in a 16:9 player.
app.get("/home-videos", async (req, res) => {
    try {
        const category = req.query.category || "All";
        const language = req.query.language || "mr";
        if (!["mr", "hi", "en"].includes(language)) {
            return res.status(400).json({ error: "Invalid language" });
        }
        const result = await youtubeSearch({
            category,
            language,
            pageToken: req.query.pageToken,
            duration: "medium",
            shorts: false
        });
        res.json(result);
    } catch (error) {
        console.error("YouTube Home API Error:", error);
        res.status(error.status || 500).json({ error: error.message || "Internal server error" });
    }
});

const PORT = 3000;
app.listen(PORT, "0.0.0.0", () => {
    console.log(`KidzShorts Backend running on port ${PORT}`);
});
