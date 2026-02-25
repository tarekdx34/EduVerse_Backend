import {
  Controller,
  Post,
  Get,
  Query,
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
}
