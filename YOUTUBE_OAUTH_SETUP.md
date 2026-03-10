# YouTube OAuth2 Setup Guide

## Overview
The YouTube module now uses OAuth2 authentication with your Google Cloud project credentials. This guide explains how to complete the initial setup and obtain the refresh token needed for automated video operations.

## Credentials Configured
- **Project ID**: eduverse-489820
- **Client ID**: ``
- **Client Secret**: ``
- **Redirect URI**: `http://localhost:8081/youtube/callback`

## Initial Setup Steps

### 1. Ensure Google Cloud Console Configuration
Before proceeding, verify in Google Cloud Console (project: eduverse-489820):

1. **YouTube Data API v3** is enabled
2. **OAuth consent screen** is configured
3. **Authorized redirect URIs** includes: `http://localhost:8081/youtube/callback`
4. **Scopes** include: `https://www.googleapis.com/auth/youtube.upload`

### 2. Obtain Refresh Token

The refresh token allows the application to automatically upload, update, and manage YouTube videos without manual authentication each time.

**Steps:**

1. **Start the backend server** (if not already running):
   ```bash
   npm run start:dev
   ```

2. **Get the authorization URL**:
   - Visit: `http://localhost:8081/youtube/auth`
   - Or use curl: `curl http://localhost:8081/youtube/auth`
   - You'll receive a response like:
     ```json
     {
       "authUrl": "https://accounts.google.com/o/oauth2/v2/auth?..."
     }
     ```

3. **Visit the authorization URL**:
   - Copy the `authUrl` from the response
   - Open it in a web browser
   - Sign in with the Google account that manages your YouTube channel
   - Grant the requested permissions (YouTube upload access)

4. **Capture the refresh token**:
   - After granting permissions, Google will redirect to: `http://localhost:8081/youtube/callback?code=...`
   - The response will include:
     ```json
     {
       "message": "Authentication successful",
       "refreshToken": "1//0gXXXXXXXXXXXXXX..."
     }
     ```

5. **Update .env file**:
   - Copy the `refreshToken` value
   - Open `.env` file
   - Update the line:
     ```env
     YOUTUBE_REFRESH_TOKEN=1//0gXXXXXXXXXXXXXX...
     ```
   - Save the file
   - Restart the server if needed

### 3. Verify Setup

Test that video operations work:

```bash
# Test video search (requires refresh token)
curl "http://localhost:8081/youtube/search?query=nestjs&maxResults=5"

# Test video details
curl "http://localhost:8081/youtube/videos/VIDEO_ID"

# Test video upload
curl -X POST http://localhost:8081/youtube/upload \
  -F "video=@path/to/video.mp4" \
  -F "title=Test Video" \
  -F "description=Test upload"
```

## API Endpoints

### OAuth Flow Endpoints

#### GET /youtube/auth
Get the OAuth2 authorization URL.

**Response:**
```json
{
  "authUrl": "https://accounts.google.com/o/oauth2/v2/auth?..."
}
```

#### GET /youtube/callback?code=...
Handle OAuth2 callback (called automatically by Google after user grants permissions).

**Response:**
```json
{
  "message": "Authentication successful",
  "refreshToken": "1//0g..."
}
```

### Video Upload Endpoints

#### POST /youtube/upload
Upload a video file to YouTube.

**Form Data:**
- `video`: Video file (binary)
- `title`: Video title (string)
- `description`: Video description (string)
- `tags`: Comma-separated tags (optional string)

**Response:**
```json
{
  "success": true,
  "videoId": "dQw4w9WgXcQ",
  "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

### Search & Read Endpoints

#### GET /youtube/search?query=...&maxResults=10
Search for videos on YouTube.

**Query Parameters:**
- `query`: Search terms (required)
- `maxResults`: Number of results (optional, default: 10, max: 50)

**Response:**
```json
{
  "success": true,
  "items": [
    {
      "videoId": "dQw4w9WgXcQ",
      "title": "Video Title",
      "description": "Video description...",
      "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
      "channelTitle": "Channel Name",
      "publishedAt": "2023-01-15T10:30:00Z",
      "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "embedUrl": "https://www.youtube.com/embed/dQw4w9WgXcQ"
    }
  ],
  "totalResults": 1000000,
  "resultsPerPage": 10
}
```

#### GET /youtube/videos/:videoId
Get detailed information about a specific video.

**Response:**
```json
{
  "success": true,
  "video": {
    "videoId": "dQw4w9WgXcQ",
    "title": "Video Title",
    "description": "Full description...",
    "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    "channelId": "UC1234567890",
    "channelTitle": "Channel Name",
    "publishedAt": "2023-01-15T10:30:00Z",
    "duration": "PT4M33S",
    "viewCount": "1000000",
    "likeCount": "50000",
    "commentCount": "2000",
    "privacyStatus": "public",
    "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    "embedUrl": "https://www.youtube.com/embed/dQw4w9WgXcQ"
  }
}
```

#### GET /youtube/channel/:channelId/videos?maxResults=10
Get videos from a specific YouTube channel.

**Query Parameters:**
- `maxResults`: Number of results (optional, default: 10, max: 50)

**Response:**
```json
{
  "success": true,
  "items": [
    {
      "videoId": "dQw4w9WgXcQ",
      "title": "Latest Video",
      "description": "Description...",
      "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
      "publishedAt": "2023-01-15T10:30:00Z",
      "videoUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "embedUrl": "https://www.youtube.com/embed/dQw4w9WgXcQ"
    }
  ],
  "totalResults": 150,
  "resultsPerPage": 10
}
```

## Rate Limits & Quotas

YouTube Data API v3 has a daily quota limit (default: 10,000 units per day).

**Operation Costs:**
- Search: 100 units per request
- Videos.list: 1 unit per request
- Videos.insert (upload): 1600 units per request
- Videos.update: 50 units per request
- Videos.delete: 50 units per request

**Best Practices:**
- Cache search results when possible
- Avoid unnecessary API calls
- Monitor quota usage in Google Cloud Console
- Request quota increase if needed for production

## Troubleshooting

### "Invalid credentials" or "Access token expired"
- **Solution**: Re-run the OAuth flow to obtain a new refresh token

### "The request cannot be completed because you have exceeded your quota"
- **Solution**: Wait for quota reset (midnight Pacific Time) or request quota increase

### "Redirect URI mismatch"
- **Solution**: Verify the redirect URI in Google Cloud Console matches `http://localhost:8081/youtube/callback`

### "Access blocked: This app's request is invalid"
- **Solution**: Ensure OAuth consent screen is properly configured in Google Cloud Console

## Integration with Course Materials

The YouTube service is automatically integrated with the course materials module. When uploading video materials through `/api/course-materials/upload-video`, the video is:

1. Uploaded to YouTube (as unlisted)
2. Stored in the course_materials table with the YouTube video ID
3. Available for embedding in course content

See `FRONTEND_DASHBOARD_GUIDE.md` for course materials API documentation.

## Security Notes

- **Never commit** the `.env` file or refresh token to version control
- Store refresh tokens securely in production environments
- Use environment variable management services (e.g., AWS Secrets Manager, Azure Key Vault)
- Restrict API keys in Google Cloud Console to specific IPs/domains when possible
- Regularly rotate credentials if compromised

## Support

For issues with:
- **Google Cloud Configuration**: Check Google Cloud Console documentation
- **OAuth2 Flow**: Review [Google OAuth2 documentation](https://developers.google.com/identity/protocols/oauth2)
- **YouTube API**: Review [YouTube Data API v3 documentation](https://developers.google.com/youtube/v3)
- **Application Integration**: Check the service and controller source code in `src/modules/youtube/`
