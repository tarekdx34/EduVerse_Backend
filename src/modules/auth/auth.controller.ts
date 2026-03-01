import {
  Controller,
  Post,
  Get,
  Body,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RegisterRequestDto } from './dto/register-request.dto';
import { LoginRequestDto } from './dto/login-request.dto';
import {
  ForgotPasswordRequestDto,
  ResetPasswordRequestDto,
  TokenRefreshRequestDto,
} from './dto/other-dtos';
import { Public } from '../../common/decorators/public.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { User } from './entities/user.entity';

@ApiTags('🔐 Authentication')
@Controller('api/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register a new user',
    description: `
## Register New User Account

Creates a new user account in the EduVerse system.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Process Flow
1. Validates email format and password strength
2. Checks for existing user with same email
3. Creates user with default STUDENT role (unless specified)
4. Returns user data

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character (@$!%*?&)

### Notes
- Default role is STUDENT if not specified
    `,
  })
  @ApiBody({ type: RegisterRequestDto })
  @ApiResponse({
    status: 201,
    description: 'User successfully registered.',
    schema: {
      example: {
        user: {
          userId: 1,
          email: 'user@example.com',
          firstName: 'John',
          lastName: 'Doe',
          isEmailVerified: true,
          roles: [{ roleName: 'student' }],
        },
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid input data or password requirements not met' })
  @ApiResponse({ status: 409, description: 'User with this email already exists' })
  async register(@Body() registerDto: RegisterRequestDto, @Req() request: any) {
    return this.authService.register(registerDto, request);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'User login',
    description: `
## User Authentication

Authenticates a user and returns JWT tokens for API access.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Process Flow
1. Validates email and password credentials
2. Checks if user account is active
3. Creates a new session for the user
4. Returns access token (short-lived) and refresh token (long-lived)

### Token Usage
- **Access Token**: Include in Authorization header as \`Bearer <token>\`
- **Refresh Token**: Use with \`/api/auth/refresh-token\` to get new access token
- Access token expires in 15 minutes (default)
- Refresh token expires in 7 days (or 30 days with rememberMe)

### Remember Me Option
When \`rememberMe: true\`, the refresh token will have extended validity.
    `,
  })
  @ApiBody({ type: LoginRequestDto })
  @ApiResponse({
    status: 200,
    description: 'Login successful. Returns JWT tokens.',
    schema: {
      example: {
        user: {
          userId: 1,
          email: 'user@example.com',
          firstName: 'John',
          lastName: 'Doe',
          roles: [{ roleName: 'student' }],
        },
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        expiresIn: 900,
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid credentials' })
  @ApiResponse({ status: 401, description: 'Account disabled' })
  async login(@Body() loginDto: LoginRequestDto, @Req() request: any) {
    return this.authService.login(loginDto, request);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'User logout',
    description: `
## Logout Current Session

Invalidates the current user session and refresh token.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user

### Process Flow
1. Validates the JWT access token
2. Invalidates the provided refresh token
3. Ends the current session

### Notes
- The access token will remain valid until expiration
- Client should discard both tokens after logout
- For immediate token invalidation, implement token blacklisting
    `,
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        refreshToken: {
          type: 'string',
          description: 'The refresh token to invalidate',
          example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        },
      },
      required: ['refreshToken'],
    },
  })
  @ApiResponse({ status: 200, description: 'Successfully logged out' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or expired token' })
  async logout(
    @CurrentUser() user: User,
    @Body('refreshToken') refreshToken: string,
  ) {
    await this.authService.logout(user.userId, refreshToken);
    return { message: 'Logged out successfully' };
  }

  @Public()
  @Post('refresh-token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Refresh access token',
    description: `
## Refresh JWT Access Token

Generates a new access token using a valid refresh token.

### Access Control
- **Authentication Required**: No (Uses refresh token instead)
- **Roles Required**: None

### Process Flow
1. Validates the refresh token
2. Checks if the session is still valid
3. Generates a new access token
4. Optionally rotates the refresh token

### Usage
Call this endpoint when the access token expires (typically after 15 minutes).
The refresh token has a longer validity period (7-30 days).

### Security Notes
- Refresh tokens should be stored securely (httpOnly cookies recommended)
- Each refresh token can only be used once (token rotation)
    `,
  })
  @ApiBody({ type: TokenRefreshRequestDto })
  @ApiResponse({
    status: 200,
    description: 'New access token generated',
    schema: {
      example: {
        accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        refreshToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        expiresIn: 900,
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Invalid or expired refresh token' })
  async refreshToken(
    @Body() tokenRefreshDto: TokenRefreshRequestDto,
    @Req() request: any,
  ) {
    return this.authService.refreshToken(tokenRefreshDto.refreshToken, request);
  }

  @Public()
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Request password reset',
    description: `
## Request Password Reset Email

Sends a password reset link to the user's email address.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Process Flow
1. Validates the email format
2. Checks if user exists (silently fails if not for security)
3. Generates a secure password reset token
4. Sends reset link via email

### Security Notes
- Always returns success message regardless of email existence
- Reset token expires after 1 hour
- Previous reset tokens are invalidated
    `,
  })
  @ApiBody({ type: ForgotPasswordRequestDto })
  @ApiResponse({
    status: 200,
    description: 'Password reset email sent (if user exists)',
    schema: {
      example: {
        message: 'If the email exists, a password reset link has been sent',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid email format' })
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordRequestDto) {
    await this.authService.forgotPassword(forgotPasswordDto.email);
    return {
      message: 'If the email exists, a password reset link has been sent',
    };
  }

  @Public()
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Reset password with token',
    description: `
## Reset User Password

Resets the user's password using a valid reset token from email.

### Access Control
- **Authentication Required**: No (Uses reset token)
- **Roles Required**: None

### Process Flow
1. Validates the reset token
2. Verifies token hasn't expired
3. Validates new password meets requirements
4. Updates user password (hashed)
5. Invalidates all existing sessions

### Password Requirements
- Minimum 8 characters
- At least one uppercase letter
- At least one lowercase letter
- At least one number
- At least one special character (@$!%*?&)
    `,
  })
  @ApiBody({ type: ResetPasswordRequestDto })
  @ApiResponse({
    status: 200,
    description: 'Password reset successful',
    schema: {
      example: { message: 'Password reset successfully' },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid or expired reset token' })
  async resetPassword(@Body() resetPasswordDto: ResetPasswordRequestDto) {
    await this.authService.resetPassword(
      resetPasswordDto.token,
      resetPasswordDto.newPassword,
    );
    return { message: 'Password reset successfully' };
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get current user profile',
    description: `
## Get Authenticated User Profile

Returns the complete profile of the currently authenticated user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)

### Response Includes
- User basic information (name, email, phone)
- Assigned roles and permissions
- Account status and verification state
- Campus association (if applicable)

### Usage
Use this endpoint to:
- Display user profile information
- Check user permissions
- Verify authentication status
    `,
  })
  @ApiResponse({
    status: 200,
    description: 'Current user profile',
    schema: {
      example: {
        userId: 1,
        email: 'user@example.com',
        firstName: 'John',
        lastName: 'Doe',
        phone: '+1234567890',
        isEmailVerified: true,
        status: 'active',
        roles: [
          { roleId: 1, roleName: 'student', roleDescription: 'Regular student user' },
        ],
        createdAt: '2024-01-15T10:30:00Z',
      },
    },
  })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or expired token' })
  async getCurrentUser(@CurrentUser() user: User) {
    return this.authService.getCurrentUser(user.userId);
  }
}
