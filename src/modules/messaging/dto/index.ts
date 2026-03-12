import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsArray, IsNumber, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

// ============ Start Conversation ============
export class StartConversationDto {
  @ApiProperty({ description: 'Participant user IDs', example: [58], type: [Number] })
  @IsArray()
  @IsNumber({}, { each: true })
  participantIds: number[];

  @ApiProperty({ description: 'Message type', example: 'direct', enum: ['direct', 'group'] })
  @IsEnum(['direct', 'group'])
  type: string;

  @ApiPropertyOptional({ description: 'Group name (required for group chats)', example: 'CS101 Study Group' })
  @IsOptional()
  @IsString()
  groupName?: string;

  @ApiProperty({ description: 'First message text', example: 'Hey! How are you?' })
  @IsString()
  text: string;

  @ApiPropertyOptional({ description: 'File ID attachment from Files module', example: 1 })
  @IsOptional()
  @IsNumber()
  fileId?: number;
}

// ============ Send Message ============
export class SendMessageDto {
  @ApiProperty({ description: 'Message text', example: 'Sure, let me check that for you!' })
  @IsString()
  text: string;

  @ApiPropertyOptional({ description: 'File ID attachment', example: 1 })
  @IsOptional()
  @IsNumber()
  fileId?: number;

  @ApiPropertyOptional({ description: 'Reply to specific message ID (within the conversation)', example: 5 })
  @IsOptional()
  @IsNumber()
  replyToId?: number;
}

// ============ Message Query ============
export class MessageQueryDto {
  @ApiPropertyOptional({ description: 'Page number', example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Messages per page', example: 50, default: 50 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 50;
}

// ============ Search Messages ============
export class SearchMessagesDto {
  @ApiProperty({ description: 'Search query', example: 'assignment deadline' })
  @IsString()
  query: string;

  @ApiPropertyOptional({ description: 'Page number', example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Results per page', example: 20, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}

// ============ WebSocket DTOs ============
export class WsSendMessageDto {
  conversationId: number;
  text: string;
  fileId?: number;
  replyToId?: number;
}

export class WsTypingDto {
  conversationId: number;
  isTyping: boolean;
}

export class WsMarkReadDto {
  conversationId: number;
}

export class WsDeleteMessageDto {
  messageId: number;
  forEveryone: boolean;
}

export class WsEditMessageDto {
  messageId: number;
  text: string;
}

// ============ Edit Message ============
export class EditMessageDto {
  @ApiProperty({ description: 'New message text', example: 'Updated message content' })
  @IsString()
  text: string;
}

// ============ Search Users ============
export class SearchUsersDto {
  @ApiProperty({ description: 'Search query (name or email)', example: 'tarek' })
  @IsString()
  query: string;

  @ApiPropertyOptional({ description: 'Max results', example: 20, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}
