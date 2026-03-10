import {
  Controller,
  Post,
  Get,
  Query,
  Param,
  Body,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiBody,
  ApiConsumes,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { YoutubeService } from './youtube.service';

@ApiTags('🎬 YouTube')
@Controller('youtube')
export class YoutubeController {
  constructor(private readonly youtubeService: YoutubeService) {}

  @Get('auth')
  @ApiOperation({
    summary: 'Get YouTube authentication URL',
    description: `
## Get YouTube OAuth URL

Returns the OAuth2 authentication URL for YouTube API access.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Process
1. Call this endpoint to get the auth URL
2. Redirect user to the URL
3. User grants permission on Google
4. Google redirects to callback with code
    `,
  })
  @ApiResponse({
    status: 200,
    description: 'Authentication URL',
    schema: {
      example: {
        authUrl: 'https://accounts.google.com/o/oauth2/v2/auth?...',
      },
    },
  })
  getAuthUrl() {
    const url = this.youtubeService.getAuthUrl();
    return { authUrl: url };
  }

  @Get('callback')
  @ApiOperation({
    summary: 'Handle YouTube OAuth callback',
    description: `
## Handle OAuth Callback

Exchanges the authorization code for access tokens.

### Access Control
- **Authentication Required**: No (Callback from Google)
- **Roles Required**: None

### Process
Called automatically by Google after user authorization.
Returns refresh token for future API calls.
    `,
  })
  @ApiQuery({ name: 'code', description: 'Authorization code from Google', type: String })
  @ApiResponse({
    status: 200,
    description: 'Authentication tokens',
    schema: {
      example: {
        message: 'Authentication successful',
        refreshToken: 'ya29.a0AfB_byC...',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid or expired code' })
  async handleCallback(@Query('code') code: string) {
    const tokens = await this.youtubeService.getTokens(code);
    return {
      message: 'Authentication successful',
      refreshToken: tokens.refresh_token,
    };
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('video'))
  @ApiOperation({
    summary: 'Upload video to YouTube',
    description: `
## Upload Video to YouTube

Uploads a video file directly to YouTube.

### Access Control
- **Authentication Required**: ✅ Requires YouTube OAuth
- **Roles Required**: User with YouTube credentials configured

### Supported Formats
MP4, AVI, MOV, WMV, FLV, WebM, and other common video formats.

### Notes
- Maximum file size depends on YouTube account verification
- Video will be uploaded as "unlisted" by default
- Processing time varies based on video length/quality
    `,
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        video: { type: 'string', format: 'binary', description: 'Video file' },
        title: { type: 'string', description: 'Video title', example: 'My Course Lecture' },
        description: { type: 'string', description: 'Video description', example: 'Lecture about...' },
        tags: { type: 'string', description: 'Comma-separated tags', example: 'education,course,lecture' },
      },
      required: ['video', 'title', 'description'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Video uploaded successfully',
    schema: {
      example: {
        videoId: 'dQw4w9WgXcQ',
        title: 'My Course Lecture',
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'No video file or invalid format' })
  @ApiResponse({ status: 401, description: 'YouTube authentication required' })
  @ApiResponse({ status: 413, description: 'Video file too large' })
  async uploadVideo(
    @UploadedFile() file: Express.Multer.File,
    @Body('title') title: string,
    @Body('description') description: string,
    @Body('tags') tags?: string,
  ) {
    const videoTags = tags ? tags.split(',').map((tag) => tag.trim()) : [];

    const result = await this.youtubeService.uploadVideoFromBuffer(
      file.buffer,
      title,
      description,
      videoTags,
    );

    return result;
  }

  @Get('search')
  @ApiOperation({
    summary: 'Search videos on YouTube',
    description: `
## Search YouTube Videos

Searches for videos on YouTube using a query string.

### Access Control
- **Authentication Required**: No (uses service account OAuth2)
- **Roles Required**: None

### Query Parameters
- \`query\`: Search terms
- \`maxResults\`: Number of results to return (default: 10, max: 50)

### Returns
Array of video objects with title, description, thumbnail, and URLs.
    `,
  })
  @ApiQuery({
    name: 'query',
    description: 'Search query',
    example: 'NestJS tutorial',
    required: true,
  })
  @ApiQuery({
    name: 'maxResults',
    description: 'Maximum number of results',
    example: 10,
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'Search results',
    schema: {
      example: {
        success: true,
        items: [
          {
            videoId: 'dQw4w9WgXcQ',
            title: 'Example Video Title',
            description: 'Video description...',
            thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
            channelTitle: 'Channel Name',
            publishedAt: '2023-01-15T10:30:00Z',
            videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
          },
        ],
        totalResults: 1000000,
        resultsPerPage: 10,
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid query parameters' })
  async searchVideos(
    @Query('query') query: string,
    @Query('maxResults') maxResults?: number,
  ) {
    const max = Math.min(Number(maxResults) || 10, 50);
    return await this.youtubeService.searchVideos(query, max);
  }

  @Get('videos/:videoId')
  @ApiOperation({
    summary: 'Get video details by ID',
    description: `
## Get YouTube Video Details

Retrieves detailed information about a specific YouTube video.

### Access Control
- **Authentication Required**: No (uses service account OAuth2)
- **Roles Required**: None

### Returns
Complete video information including statistics, duration, and metadata.
    `,
  })
  @ApiResponse({
    status: 200,
    description: 'Video details',
    schema: {
      example: {
        success: true,
        video: {
          videoId: 'dQw4w9WgXcQ',
          title: 'Example Video',
          description: 'Full video description...',
          thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
          channelId: 'UC1234567890',
          channelTitle: 'Channel Name',
          publishedAt: '2023-01-15T10:30:00Z',
          duration: 'PT4M33S',
          viewCount: '1000000',
          likeCount: '50000',
          commentCount: '2000',
          privacyStatus: 'public',
          videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
        },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Video not found' })
  async getVideoDetails(@Param('videoId') videoId: string) {
    return await this.youtubeService.getVideoDetails(videoId);
  }

  @Get('channel/:channelId/videos')
  @ApiOperation({
    summary: 'Get videos from a YouTube channel',
    description: `
## Get Channel Videos

Retrieves a list of videos from a specific YouTube channel.

### Access Control
- **Authentication Required**: No (uses service account OAuth2)
- **Roles Required**: None

### Query Parameters
- \`maxResults\`: Number of results to return (default: 10, max: 50)

### Returns
Array of videos from the channel, ordered by date (newest first).
    `,
  })
  @ApiQuery({
    name: 'maxResults',
    description: 'Maximum number of results',
    example: 10,
    required: false,
  })
  @ApiResponse({
    status: 200,
    description: 'Channel videos',
    schema: {
      example: {
        success: true,
        items: [
          {
            videoId: 'dQw4w9WgXcQ',
            title: 'Latest Video',
            description: 'Video description...',
            thumbnail: 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
            publishedAt: '2023-01-15T10:30:00Z',
            videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
            embedUrl: 'https://www.youtube.com/embed/dQw4w9WgXcQ',
          },
        ],
        totalResults: 150,
        resultsPerPage: 10,
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Channel not found' })
  async getChannelVideos(
    @Param('channelId') channelId: string,
    @Query('maxResults') maxResults?: number,
  ) {
    const max = Math.min(Number(maxResults) || 10, 50);
    return await this.youtubeService.getChannelVideos(channelId, max);
  }
}
