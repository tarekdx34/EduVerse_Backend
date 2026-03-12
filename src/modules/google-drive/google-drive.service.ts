// src/modules/google-drive/google-drive.service.ts
import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { google, drive_v3 } from 'googleapis';
import { OAuth2Client } from 'google-auth-library';
import { Readable } from 'stream';

export interface DriveFile {
  id: string;
  name: string;
  mimeType: string;
  size?: string;
  webViewLink?: string;
  webContentLink?: string;
  thumbnailLink?: string;
  createdTime?: string;
  modifiedTime?: string;
  parents?: string[];
}

export interface DriveFolder {
  id: string;
  name: string;
  webViewLink?: string;
  createdTime?: string;
}

@Injectable()
export class GoogleDriveService {
  private readonly logger = new Logger(GoogleDriveService.name);
  private oauth2Client: OAuth2Client;
  private drive: drive_v3.Drive;

  constructor(private configService: ConfigService) {
    this.oauth2Client = new google.auth.OAuth2(
      this.configService.get<string>('YOUTUBE_CLIENT_ID'),
      this.configService.get<string>('YOUTUBE_CLIENT_SECRET'),
      this.configService.get<string>('YOUTUBE_REDIRECT_URI'),
    );

    // Set credentials if refresh token exists
    const refreshToken = this.configService.get<string>('YOUTUBE_REFRESH_TOKEN');
    if (refreshToken) {
      this.oauth2Client.setCredentials({
        refresh_token: refreshToken,
      });
    }

    this.drive = google.drive({
      version: 'v3',
      auth: this.oauth2Client,
    });
  }

  /**
   * Generate OAuth URL for authentication with both YouTube and Drive scopes
   */
  getAuthUrl(): string {
    const scopes = [
      'https://www.googleapis.com/auth/youtube.upload',
      'https://www.googleapis.com/auth/drive.file',
    ];

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
   * Create a folder in Google Drive
   */
  async createFolder(name: string, parentId?: string): Promise<DriveFolder> {
    try {
      const fileMetadata: drive_v3.Schema$File = {
        name,
        mimeType: 'application/vnd.google-apps.folder',
      };

      if (parentId) {
        fileMetadata.parents = [parentId];
      }

      const response = await this.drive.files.create({
        requestBody: fileMetadata,
        fields: 'id, name, webViewLink, createdTime',
      });

      this.logger.log(`Created folder: ${name} (ID: ${response.data.id})`);

      return {
        id: response.data.id!,
        name: response.data.name!,
        webViewLink: response.data.webViewLink || undefined,
        createdTime: response.data.createdTime || undefined,
      };
    } catch (error) {
      this.logger.error(`Error creating folder: ${error.message}`);
      throw error;
    }
  }

  /**
   * Upload a file to Google Drive
   */
  async uploadFile(
    buffer: Buffer,
    fileName: string,
    mimeType: string,
    folderId?: string,
  ): Promise<DriveFile> {
    try {
      const stream = new Readable();
      stream.push(buffer);
      stream.push(null);

      const fileMetadata: drive_v3.Schema$File = {
        name: fileName,
      };

      if (folderId) {
        fileMetadata.parents = [folderId];
      }

      const response = await this.drive.files.create({
        requestBody: fileMetadata,
        media: {
          mimeType,
          body: stream,
        },
        fields: 'id, name, mimeType, size, webViewLink, webContentLink, thumbnailLink, createdTime, modifiedTime, parents',
      });

      this.logger.log(`Uploaded file: ${fileName} (ID: ${response.data.id})`);

      return {
        id: response.data.id!,
        name: response.data.name!,
        mimeType: response.data.mimeType!,
        size: response.data.size || undefined,
        webViewLink: response.data.webViewLink || undefined,
        webContentLink: response.data.webContentLink || undefined,
        thumbnailLink: response.data.thumbnailLink || undefined,
        createdTime: response.data.createdTime || undefined,
        modifiedTime: response.data.modifiedTime || undefined,
        parents: response.data.parents || undefined,
      };
    } catch (error) {
      this.logger.error(`Error uploading file: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get file metadata
   */
  async getFile(fileId: string): Promise<DriveFile> {
    try {
      const response = await this.drive.files.get({
        fileId,
        fields: 'id, name, mimeType, size, webViewLink, webContentLink, thumbnailLink, createdTime, modifiedTime, parents',
      });

      return {
        id: response.data.id!,
        name: response.data.name!,
        mimeType: response.data.mimeType!,
        size: response.data.size || undefined,
        webViewLink: response.data.webViewLink || undefined,
        webContentLink: response.data.webContentLink || undefined,
        thumbnailLink: response.data.thumbnailLink || undefined,
        createdTime: response.data.createdTime || undefined,
        modifiedTime: response.data.modifiedTime || undefined,
        parents: response.data.parents || undefined,
      };
    } catch (error) {
      this.logger.error(`Error getting file: ${error.message}`);
      throw error;
    }
  }

  /**
   * Download file content
   */
  async downloadFile(fileId: string): Promise<Buffer> {
    try {
      const response = await this.drive.files.get(
        { fileId, alt: 'media' },
        { responseType: 'arraybuffer' },
      );

      return Buffer.from(response.data as ArrayBuffer);
    } catch (error) {
      this.logger.error(`Error downloading file: ${error.message}`);
      throw error;
    }
  }

  /**
   * List files in a folder
   */
  async listFolder(folderId: string): Promise<DriveFile[]> {
    try {
      const response = await this.drive.files.list({
        q: `'${folderId}' in parents and trashed = false`,
        fields: 'files(id, name, mimeType, size, webViewLink, webContentLink, thumbnailLink, createdTime, modifiedTime, parents)',
        orderBy: 'name',
      });

      return (response.data.files || []).map((file) => ({
        id: file.id!,
        name: file.name!,
        mimeType: file.mimeType!,
        size: file.size || undefined,
        webViewLink: file.webViewLink || undefined,
        webContentLink: file.webContentLink || undefined,
        thumbnailLink: file.thumbnailLink || undefined,
        createdTime: file.createdTime || undefined,
        modifiedTime: file.modifiedTime || undefined,
        parents: file.parents || undefined,
      }));
    } catch (error) {
      this.logger.error(`Error listing folder: ${error.message}`);
      throw error;
    }
  }

  /**
   * Delete a file or folder
   */
  async deleteFile(fileId: string): Promise<void> {
    try {
      await this.drive.files.delete({ fileId });
      this.logger.log(`Deleted file/folder: ${fileId}`);
    } catch (error) {
      this.logger.error(`Error deleting file: ${error.message}`);
      throw error;
    }
  }

  /**
   * Move a file to a different folder
   */
  async moveFile(fileId: string, newParentId: string): Promise<DriveFile> {
    try {
      // Get current parents
      const file = await this.drive.files.get({
        fileId,
        fields: 'parents',
      });

      const previousParents = file.data.parents?.join(',') || '';

      const response = await this.drive.files.update({
        fileId,
        addParents: newParentId,
        removeParents: previousParents,
        fields: 'id, name, mimeType, size, webViewLink, webContentLink, thumbnailLink, createdTime, modifiedTime, parents',
      });

      this.logger.log(`Moved file ${fileId} to folder ${newParentId}`);

      return {
        id: response.data.id!,
        name: response.data.name!,
        mimeType: response.data.mimeType!,
        size: response.data.size || undefined,
        webViewLink: response.data.webViewLink || undefined,
        webContentLink: response.data.webContentLink || undefined,
        thumbnailLink: response.data.thumbnailLink || undefined,
        createdTime: response.data.createdTime || undefined,
        modifiedTime: response.data.modifiedTime || undefined,
        parents: response.data.parents || undefined,
      };
    } catch (error) {
      this.logger.error(`Error moving file: ${error.message}`);
      throw error;
    }
  }

  /**
   * Rename a file or folder
   */
  async renameFile(fileId: string, newName: string): Promise<DriveFile> {
    try {
      const response = await this.drive.files.update({
        fileId,
        requestBody: { name: newName },
        fields: 'id, name, mimeType, size, webViewLink, webContentLink, thumbnailLink, createdTime, modifiedTime, parents',
      });

      this.logger.log(`Renamed file ${fileId} to ${newName}`);

      return {
        id: response.data.id!,
        name: response.data.name!,
        mimeType: response.data.mimeType!,
        size: response.data.size || undefined,
        webViewLink: response.data.webViewLink || undefined,
        webContentLink: response.data.webContentLink || undefined,
        thumbnailLink: response.data.thumbnailLink || undefined,
        createdTime: response.data.createdTime || undefined,
        modifiedTime: response.data.modifiedTime || undefined,
        parents: response.data.parents || undefined,
      };
    } catch (error) {
      this.logger.error(`Error renaming file: ${error.message}`);
      throw error;
    }
  }

  /**
   * Check if a folder exists by name in parent
   */
  async findFolderByName(name: string, parentId?: string): Promise<DriveFolder | null> {
    try {
      let query = `name = '${name}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false`;
      if (parentId) {
        query += ` and '${parentId}' in parents`;
      }

      const response = await this.drive.files.list({
        q: query,
        fields: 'files(id, name, webViewLink, createdTime)',
      });

      if (response.data.files && response.data.files.length > 0) {
        const folder = response.data.files[0];
        return {
          id: folder.id!,
          name: folder.name!,
          webViewLink: folder.webViewLink || undefined,
          createdTime: folder.createdTime || undefined,
        };
      }

      return null;
    } catch (error) {
      this.logger.error(`Error finding folder: ${error.message}`);
      throw error;
    }
  }

  /**
   * Get or create a folder (idempotent operation)
   */
  async getOrCreateFolder(name: string, parentId?: string): Promise<DriveFolder> {
    const existing = await this.findFolderByName(name, parentId);
    if (existing) {
      return existing;
    }
    return this.createFolder(name, parentId);
  }

  /**
   * Get storage quota information
   */
  async getStorageQuota(): Promise<{ limit: string; usage: string; usageInDrive: string }> {
    try {
      const response = await this.drive.about.get({
        fields: 'storageQuota',
      });

      return {
        limit: response.data.storageQuota?.limit || 'unlimited',
        usage: response.data.storageQuota?.usage || '0',
        usageInDrive: response.data.storageQuota?.usageInDrive || '0',
      };
    } catch (error) {
      this.logger.error(`Error getting storage quota: ${error.message}`);
      throw error;
    }
  }
}
