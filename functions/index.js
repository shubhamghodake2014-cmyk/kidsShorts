
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

app.get("/videos", async (req, res) => {
    try {
        const category = req.query.category || "Rhymes";
        const language = req.query.language || "mr";
        const pageToken = req.query.pageToken;

        if (!["Rhymes", "Education", "Stories", "Cartoons"].includes(category)) {
            return res.status(400).json({ error: "Invalid category" });
        }

        if (!["mr", "hi", "en"].includes(language)) {
            return res.status(400).json({ error: "Invalid language" });
        }

        if (!YOUTUBE_API_KEY) {
            return res.status(500).json({
                error: "YouTube API key not configured"
            });
        }

        const searchKeywords = {
            mr: {
                Rhymes: "मराठी बालगीते बडबडगीते",
                Education: "मराठी मुलांचे शैक्षणिक व्हिडिओ",
                Stories: "मराठी मुलांच्या गोष्टी",
                Cartoons: "मराठी मुलांचे कार्टून"
            },
            hi: {
                Rhymes: "हिंदी बालगीत",
                Education: "हिंदी बच्चों की शैक्षिक वीडियो",
                Stories: "हिंदी बच्चों की कहानियां",
                Cartoons: "हिंदी बच्चों के कार्टून"
            },
            en: {
                Rhymes: "English nursery rhymes",
                Education: "English educational videos for kids",
                Stories: "English bedtime stories for kids",
                Cartoons: "English cartoons for kids"
            }
        };

        const query = `${searchKeywords[language][category]} #shorts`;

        const params = {
            part: "snippet",
            q: query,
            type: "video",
            videoDuration: "short",
            videoEmbeddable: "true",
            safeSearch: "strict",
            relevanceLanguage: language,
            regionCode: "IN",
            order: "relevance",
            maxResults: "50",
            key: YOUTUBE_API_KEY
        };

        // Request next page when a page token is supplied.
        if (pageToken) {
            params.pageToken = pageToken;
        }

        const url = new URL(
            "https://www.googleapis.com/youtube/v3/search"
        );

        url.search = new URLSearchParams(params).toString();

        const response = await fetch(url);
        const data = await response.json();

        if (!response.ok) {
            return res.status(response.status).json({
                error: data.error?.message || "YouTube API request failed"
            });
        }

        const uniqueVideos = [];
        const seenIds = new Set();

        for (const item of data.items || []) {
            const videoId = item.id?.videoId;

            if (!videoId || seenIds.has(videoId)) {
                continue;
            }

            seenIds.add(videoId);

            uniqueVideos.push({
                videoId,
                title: item.snippet.title,
                description: item.snippet.description,
                thumbnail:
                    item.snippet.thumbnails.high?.url ||
                    item.snippet.thumbnails.medium?.url,
                channelTitle: item.snippet.channelTitle
            });
        }

        res.json({
            category,
            language,
            searchType: "Shorts-focused",
            count: uniqueVideos.length,
            nextPageToken: data.nextPageToken || null,
            videos: uniqueVideos
        });

    } catch (error) {
        console.error("YouTube API Error:", error);

        res.status(500).json({
            error: "Internal server error"
        });
    }
});

const PORT = 3000;

app.listen(PORT, "0.0.0.0", () => {
    console.log(`KidzShorts Backend running on port ${PORT}`);
});
