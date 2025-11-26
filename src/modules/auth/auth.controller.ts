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
import { AuthService } from './auth.service';
import { RegisterRequestDto } from './dto/register-request.dto';
import { LoginRequestDto } from './dto/login-request.dto';
import {
  ForgotPasswordRequestDto,
  ResetPasswordRequestDto,
  TokenRefreshRequestDto,
  ResendVerificationEmailDto,
} from './dto/other-dtos';
import { Public } from '../../common/decorators/public.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { User } from './entities/user.entity';

@Controller('api/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() registerDto: RegisterRequestDto, @Req() request: any) {
    return this.authService.register(registerDto, request);
  }

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginRequestDto, @Req() request: any) {
    return this.authService.login(loginDto, request);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @UseGuards(JwtAuthGuard)
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
  async refreshToken(
    @Body() tokenRefreshDto: TokenRefreshRequestDto,
    @Req() request: any,
  ) {
    return this.authService.refreshToken(tokenRefreshDto.refreshToken, request);
  }

  @Public()
  @Post('forgot-password')
  @HttpCode(HttpStatus.OK)
  async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordRequestDto) {
    await this.authService.forgotPassword(forgotPasswordDto.email);
    return {
      message: 'If the email exists, a password reset link has been sent',
    };
  }

  @Public()
  @Post('reset-password')
  @HttpCode(HttpStatus.OK)
  async resetPassword(@Body() resetPasswordDto: ResetPasswordRequestDto) {
    await this.authService.resetPassword(
      resetPasswordDto.token,
      resetPasswordDto.newPassword,
    );
    return { message: 'Password reset successfully' };
  }

  @Public()
  @Post('verify-email')
  @HttpCode(HttpStatus.OK)
  async verifyEmail(@Body('token') token: string) {
    return this.authService.verifyEmail(token);
  }

  @Public()
  @Post('resend-verification-email')
  @HttpCode(HttpStatus.OK)
  async resendVerificationEmail(@Body() resendDto: ResendVerificationEmailDto) {
    return this.authService.resendVerificationEmail(resendDto.email);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  async getCurrentUser(@CurrentUser() user: User) {
    return this.authService.getCurrentUser(user.userId);
  }
}
