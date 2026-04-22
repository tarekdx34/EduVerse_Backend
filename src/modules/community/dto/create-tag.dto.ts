import { IsString, MaxLength, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTagDto {
  @ApiProperty({ description: 'Tag name', example: 'study-group', maxLength: 50 })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  name: string;
}
