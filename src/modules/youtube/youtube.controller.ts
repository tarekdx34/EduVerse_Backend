import {
  Controller,
  Post,
  Get,
  Query,
  Body,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { YoutubeService } from './youtube.service';

@Controller('youtube')
export class YoutubeController {
  constructor(private readonly youtubeService: YoutubeService) {}

  @Get('auth')
  getAuthUrl() {
    const url = this.youtubeService.getAuthUrl();
    return { authUrl: url };
  }

  @Get('callback')
  async handleCallback(@Query('code') code: string) {
    const tokens = await this.youtubeService.getTokens(code);
    return {
      message: 'Authentication successful',
      refreshToken: tokens.refresh_token,
    };
  }

  @Post('upload')
  @UseInterceptors(FileInterceptor('video'))
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
