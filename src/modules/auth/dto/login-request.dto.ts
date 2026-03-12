import {
  IsEmail,
  IsNotEmpty,
  IsString,
  IsBoolean,
  IsOptional,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class LoginRequestDto {
  @ApiProperty({
    description: 'User email address',
    example: 'john.doe@example.com',
    format: 'email',
  })
  @IsEmail({}, { message: 'Invalid email format' })
  @IsNotEmpty({ message: 'Email is required' })
  email: string;

  @ApiProperty({
    description: 'User password',
    example: 'SecureP@ss123',
  })
  @IsString()
  @IsNotEmpty({ message: 'Password is required' })
  password: string;

  @ApiPropertyOptional({
    description: 'Remember me option for extended session',
    example: false,
    default: false,
  })
  @IsOptional()
  @IsBoolean({ message: 'Remember me must be a boolean' })
  rememberMe?: boolean;
}
