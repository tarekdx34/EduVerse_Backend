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

  /**
   * Search videos on YouTube
   */
  async searchVideos(query: string, maxResults: number = 10) {
    try {
      const response = await this.youtube.search.list({
        part: ['snippet'],
        q: query,
        type: ['video'],
        maxResults,
      });

      return {
        success: true,
        items: response.data.items?.map((item) => ({
          videoId: item.id?.videoId,
          title: item.snippet?.title,
          description: item.snippet?.description,
          thumbnail: item.snippet?.thumbnails?.high?.url,
          channelTitle: item.snippet?.channelTitle,
          publishedAt: item.snippet?.publishedAt,
          videoUrl: `https://www.youtube.com/watch?v=${item.id?.videoId}`,
          embedUrl: `https://www.youtube.com/embed/${item.id?.videoId}`,
        })),
        totalResults: response.data.pageInfo?.totalResults,
        resultsPerPage: response.data.pageInfo?.resultsPerPage,
      };
    } catch (error) {
      console.error('Error searching videos:', error);
      throw error;
    }
  }

  /**
   * Get video details by ID
   */
  async getVideoDetails(videoId: string) {
    try {
      const response = await this.youtube.videos.list({
        part: ['snippet', 'contentDetails', 'statistics', 'status'],
        id: [videoId],
      });

      if (!response.data.items || response.data.items.length === 0) {
        return {
          success: false,
          message: 'Video not found',
        };
      }

      const video = response.data.items[0];
      return {
        success: true,
        video: {
          videoId: video.id,
          title: video.snippet?.title,
          description: video.snippet?.description,
          thumbnail: video.snippet?.thumbnails?.high?.url,
          channelId: video.snippet?.channelId,
          channelTitle: video.snippet?.channelTitle,
          publishedAt: video.snippet?.publishedAt,
          duration: video.contentDetails?.duration,
          viewCount: video.statistics?.viewCount,
          likeCount: video.statistics?.likeCount,
          commentCount: video.statistics?.commentCount,
          privacyStatus: video.status?.privacyStatus,
          videoUrl: `https://www.youtube.com/watch?v=${video.id}`,
          embedUrl: `https://www.youtube.com/embed/${video.id}`,
        },
      };
    } catch (error) {
      console.error('Error getting video details:', error);
      throw error;
    }
  }

  /**
   * Get videos from a channel
   */
  async getChannelVideos(channelId: string, maxResults: number = 10) {
    try {
      const response = await this.youtube.search.list({
        part: ['snippet'],
        channelId,
        type: ['video'],
        maxResults,
        order: 'date',
      });

      return {
        success: true,
        items: response.data.items?.map((item) => ({
          videoId: item.id?.videoId,
          title: item.snippet?.title,
          description: item.snippet?.description,
          thumbnail: item.snippet?.thumbnails?.high?.url,
          publishedAt: item.snippet?.publishedAt,
          videoUrl: `https://www.youtube.com/watch?v=${item.id?.videoId}`,
          embedUrl: `https://www.youtube.com/embed/${item.id?.videoId}`,
        })),
        totalResults: response.data.pageInfo?.totalResults,
        resultsPerPage: response.data.pageInfo?.resultsPerPage,
      };
    } catch (error) {
      console.error('Error getting channel videos:', error);
      throw error;
    }
  }
}
