// src/modules/youtube/youtube.service.ts
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { google, youtube_v3 } from 'googleapis';
import { OAuth2Client } from 'google-auth-library';
import * as fs from 'fs';
import { Readable } from 'stream';

@Injectable()
export class YoutubeService {
  private oauth2Client: OAuth2Client;
  private youtube: youtube_v3.Youtube;

  constructor(private configService: ConfigService) {
    this.oauth2Client = new google.auth.OAuth2(
      this.configService.get<string>('YOUTUBE_CLIENT_ID'),
      this.configService.get<string>('YOUTUBE_CLIENT_SECRET'),
      this.configService.get<string>('YOUTUBE_REDIRECT_URI'),
    );

    // Set credentials if you have a refresh token
    const refreshToken = this.configService.get<string>(
      'YOUTUBE_REFRESH_TOKEN',
    );
    if (refreshToken) {
      this.oauth2Client.setCredentials({
        refresh_token: refreshToken,
      });
    }

    this.youtube = google.youtube({
      version: 'v3',
      auth: this.oauth2Client,
    });
  }

  /**
   * Generate OAuth URL for initial authentication
   */
  getAuthUrl(): string {
    const scopes = ['https://www.googleapis.com/auth/youtube.upload'];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline',
      scope: scopes,
      prompt: 'consent',
    });
  }

  /**
   * Exchange authorization code for tokens
   */
  async getTokens(code: string) {
    const { tokens } = await this.oauth2Client.getToken(code);
    this.oauth2Client.setCredentials(tokens);
    return tokens;
  }

  /**
   * Upload video to YouTube as unlisted
   */
  async uploadVideo(
    filePath: string,
    title: string,
    description: string,
    tags?: string[],
  ) {
    try {
      const response = await this.youtube.videos.insert({
        part: ['snippet', 'status'],
        requestBody: {
          snippet: {
            title,
            description,
            tags: tags || [],
            categoryId: '22', // People & Blogs category, change as needed
          },
          status: {
            privacyStatus: 'unlisted', // Can be: public, private, or unlisted
          },
        },
        media: {
          body: fs.createReadStream(filePath),
        },
      });

      return {
        success: true,
        videoId: response.data.id,
        videoUrl: `https://www.youtube.com/watch?v=${response.data.id}`,
        data: response.data,
      };
    } catch (error) {
      console.error('Error uploading video:', error);
      throw error;
    }
  }

  /**
   * Upload video from buffer
   */
  async uploadVideoFromBuffer(
    buffer: Buffer,
    title: string,
    description: string,
    tags?: string[],
  ) {
    try {
      const stream = new Readable();
      stream.push(buffer);
      stream.push(null);

      const response = await this.youtube.videos.insert({
        part: ['snippet', 'status'],
        requestBody: {
          snippet: {
            title,
            description,
            tags: tags || [],
            categoryId: '22',
          },
          status: {
            privacyStatus: 'unlisted',
          },
        },
        media: {
          body: stream,
        },
      });

      return {
        success: true,
        videoId: response.data.id,
        videoUrl: `https://www.youtube.com/watch?v=${response.data.id}`,
        data: response.data,
      };
    } catch (error) {
      console.error('Error uploading video:', error);
      throw error;
    }
  }

  /**
   * Update video details
   */
  async updateVideo(
    videoId: string,
    title?: string,
    description?: string,
    privacyStatus?: 'public' | 'private' | 'unlisted',
  ) {
    try {
      const response = await this.youtube.videos.update({
        part: ['snippet', 'status'],
        requestBody: {
          id: videoId,
          snippet: {
            title,
            description,
          },
          status: {
            privacyStatus,
          },
        },
      });

      return response.data;
    } catch (error) {
      console.error('Error updating video:', error);
      throw error;
    }
  }

  /**
   * Delete video
   */
  async deleteVideo(videoId: string) {
    try {
      await this.youtube.videos.delete({
        id: videoId,
      });
      return { success: true, message: 'Video deleted successfully' };
    } catch (error) {
      console.error('Error deleting video:', error);
      throw error;
    }
  }
}
