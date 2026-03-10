# YouTube Module - Quick Reference

## 🚀 Quick Start

### 1. OAuth Setup (One-time)
```bash
# Get auth URL
curl http://localhost:8081/youtube/auth

# Visit the returned URL in browser → Grant permissions
# Copy refresh token from callback response
# Add to .env: YOUTUBE_REFRESH_TOKEN=your_token_here
# Restart server
```

### 2. Test Endpoints
```bash
# Search videos
curl "http://localhost:8081/youtube/search?query=nodejs&maxResults=5"

# Get video details
curl "http://localhost:8081/youtube/videos/VIDEO_ID"

# Get channel videos
curl "http://localhost:8081/youtube/channel/CHANNEL_ID/videos"
```

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/youtube/auth` | Get OAuth2 authorization URL |
| GET | `/youtube/callback` | OAuth2 callback (automatic) |
| GET | `/youtube/search` | Search YouTube videos |
| GET | `/youtube/videos/:videoId` | Get video details |
| GET | `/youtube/channel/:channelId/videos` | Get channel videos |
| POST | `/youtube/upload` | Upload video to YouTube |

## 🔑 Environment Variables

```env
YOUTUBE_CLIENT_ID=
YOUTUBE_CLIENT_SECRET=
YOUTUBE_REDIRECT_URI=http://localhost:8081/youtube/callback
YOUTUBE_REFRESH_TOKEN=  # Obtain via OAuth flow
```

## 📚 Documentation Files

- **`YOUTUBE_OAUTH_SETUP.md`** - Complete setup guide & API docs
- **`YOUTUBE_POSTMAN_SECTION.json`** - Postman collection
- **`YOUTUBE_INTEGRATION_SUMMARY.md`** - Implementation details

## ⚡ Common Tasks

### Search for videos
```javascript
// GET /youtube/search?query=nestjs&maxResults=10
{
  "success": true,
  "items": [
    {
      "videoId": "abc123",
      "title": "Video Title",
      "thumbnail": "https://...",
      "videoUrl": "https://youtube.com/watch?v=abc123",
      "embedUrl": "https://youtube.com/embed/abc123"
    }
  ]
}
```

### Get video details
```javascript
// GET /youtube/videos/VIDEO_ID
{
  "success": true,
  "video": {
    "videoId": "abc123",
    "title": "Video Title",
    "viewCount": "1000000",
    "likeCount": "50000",
    "duration": "PT4M33S"
  }
}
```

### Upload video
```bash
curl -X POST http://localhost:8081/youtube/upload \
  -F "video=@video.mp4" \
  -F "title=My Video" \
  -F "description=Description here"
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| 500 Internal Server Error | Refresh token not configured - complete OAuth setup |
| Invalid credentials | Run OAuth flow again to get new refresh token |
| Quota exceeded | Wait for quota reset (midnight PT) or request increase |
| Redirect URI mismatch | Verify in Google Cloud Console |

## 📊 Rate Limits

- **Daily Quota:** 10,000 units (default)
- **Search:** 100 units/request
- **Video details:** 1 unit/request
- **Upload:** 1,600 units/request

## 🔐 Security Notes

- ✅ Never commit `.env` or refresh tokens
- ✅ Videos uploaded as "unlisted" by default
- ✅ Use environment variable management in production
- ✅ Restrict API keys in Google Cloud Console

## 🎯 Next Steps

1. ☐ Complete OAuth2 setup (get refresh token)
2. ☐ Test search endpoint
3. ☐ Test video upload
4. ☐ Import Postman collection
5. ☐ Review rate limits for your use case

---

**Server Status Check:**
```bash
curl http://localhost:8081/youtube/auth
# Should return: {"authUrl": "https://accounts.google.com/..."}
```

**Swagger UI:** http://localhost:8081/api → Look for 🎬 YouTube section
