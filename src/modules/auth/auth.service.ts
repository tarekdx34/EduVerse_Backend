// src/modules/auth/auth.service.ts
// Updated version with email integration

import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { User, UserStatus } from './entities/user.entity';
import { Role, RoleName } from './entities/role.entity';
import { Session } from './entities/session.entity';
import { PasswordReset } from './entities/password-reset.entity';
import { RegisterRequestDto } from './dto/register-request.dto';
import { LoginRequestDto } from './dto/login-request.dto';
import { LoginResponseDto } from './dto/auth-response.dto';
import { UserDto } from './dto/user.dto';
import { plainToClass } from 'class-transformer';
import { EmailService } from '../email/email.service';
import { NotificationsService } from '../notifications/services/notifications.service';
import { NotificationPriority, NotificationType } from '../notifications/enums';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
    @InjectRepository(Session)
    private sessionRepository: Repository<Session>,
    @InjectRepository(PasswordReset)
    private passwordResetRepository: Repository<PasswordReset>,
    private jwtService: JwtService,
    private configService: ConfigService,
    private emailService: EmailService,
    private notificationsService: NotificationsService,
  ) {}

  async register(
    registerDto: RegisterRequestDto,
    request: any,
  ): Promise<{ message: string; user: UserDto }> {
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
      withDeleted: true,
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    const roleName = registerDto.role || RoleName.STUDENT;
    const role = await this.roleRepository.findOne({
      where: { roleName },
    });

    if (!role) {
      throw new BadRequestException('Invalid role');
    }

    const user = this.userRepository.create({
      email: registerDto.email,
      passwordHash: registerDto.password,
      firstName: registerDto.firstName,
      lastName: registerDto.lastName,
      phone: registerDto.phone,
      status: UserStatus.ACTIVE,
      emailVerified: true,
      roles: [role],
    });

    await this.userRepository.save(user);

    return {
      message: 'Registration successful! Your account is now active.',
      user: this.transformUserToDto(user),
    };
  }

  async login(
    loginDto: LoginRequestDto,
    request: any,
  ): Promise<LoginResponseDto> {
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
      relations: ['roles'],
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await user.validatePassword(loginDto.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (user.status !== UserStatus.ACTIVE) {
      throw new UnauthorizedException('Account is not active');
    }

    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    return this.generateAuthResponse(user, request, loginDto.rememberMe);
  }

  async refreshToken(
    refreshToken: string,
    request: any,
  ): Promise<LoginResponseDto> {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const user = await this.userRepository.findOne({
        where: { userId: payload.sub },
        relations: ['roles'],
      });

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      const session = await this.sessionRepository.findOne({
        where: {
          userId: user.userId,
          sessionToken: refreshToken,
        },
      });

      if (!session) {
        throw new UnauthorizedException('Invalid session');
      }

      if (new Date() > session.expiresAt) {
        await this.sessionRepository.remove(session);
        throw new UnauthorizedException('Session expired');
      }

      await this.sessionRepository.remove(session);

      return this.generateAuthResponse(user, request, session.rememberMe);
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async logout(userId: number, sessionToken: string): Promise<void> {
    await this.sessionRepository.delete({
      userId,
      sessionToken,
    });
  }

  async forgotPassword(email: string): Promise<void> {
    const user = await this.userRepository.findOne({ where: { email } });

    if (!user) {
      // Don't reveal if email exists (security best practice)
      return;
    }

    // Invalidate any existing unused reset tokens for this user
    await this.passwordResetRepository.update(
      { userId: user.userId, used: false },
      { used: true, usedAt: new Date() },
    );

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const hashedToken = crypto
      .createHash('sha256')
      .update(resetToken)
      .digest('hex');

    // Save reset token
    const passwordReset = this.passwordResetRepository.create({
      userId: user.userId,
      resetToken: hashedToken,
      expiresAt: new Date(Date.now() + 3600000), // 1 hour
      used: false,
    });

    await this.passwordResetRepository.save(passwordReset);

    // Send reset email with the plain token
    try {
      await this.emailService.sendPasswordResetEmail(
        user.email,
        resetToken,
        user.firstName,
      );
    } catch (error) {
      console.error('Failed to send password reset email:', error);
      throw new BadRequestException('Failed to send password reset email');
    }
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

    const passwordReset = await this.passwordResetRepository.findOne({
      where: { resetToken: hashedToken, used: false },
      relations: ['user'],
    });

    if (!passwordReset) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    if (new Date() > passwordReset.expiresAt) {
      throw new BadRequestException('Reset token has expired');
    }

    // Update password
    passwordReset.user.passwordHash = newPassword;
    await this.userRepository.save(passwordReset.user);

    // Mark token as used
    passwordReset.used = true;
    passwordReset.usedAt = new Date();
    await this.passwordResetRepository.save(passwordReset);

    // Invalidate all user sessions
    await this.sessionRepository.delete({ userId: passwordReset.user.userId });

    // Send confirmation email
    try {
      await this.emailService.sendPasswordChangedNotification(
        passwordReset.user.email,
        passwordReset.user.firstName,
      );
    } catch (error) {
      console.error('Failed to send password changed notification:', error);
      // Don't throw error, password was already changed successfully
    }

    await this.notificationsService.createNotification({
      userId: passwordReset.user.userId,
      notificationType: NotificationType.SYSTEM,
      title: 'Password Changed',
      body: 'Your password was changed successfully. If this was not you, contact support immediately.',
      relatedEntityType: 'user',
      relatedEntityId: passwordReset.user.userId,
      priority: NotificationPriority.HIGH,
      actionUrl: '/profile/security',
    });
  }

  async getCurrentUser(userId: number): Promise<UserDto> {
    const user = await this.userRepository.findOne({
      where: { userId },
      relations: ['roles'],
    });

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    return this.transformUserToDto(user);
  }

  private async generateAuthResponse(
    user: User,
    request: any,
    rememberMe: boolean = false,
  ): Promise<LoginResponseDto> {
    const payload = {
      sub: user.userId,
      email: user.email,
      roles: user.roles.map((role) => role.roleName),
    };

    const accessTokenExpiration = rememberMe ? '24h' : '1h';
    const refreshTokenExpiration = rememberMe ? '30d' : '7d';

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET'),
      expiresIn: accessTokenExpiration,
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: refreshTokenExpiration,
    });

    const sessionExpirationMs = rememberMe
      ? 30 * 24 * 60 * 60 * 1000
      : 7 * 24 * 60 * 60 * 1000;

    const session = this.sessionRepository.create({
      userId: user.userId,
      sessionToken: refreshToken,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
      deviceType: this.detectDeviceType(request.headers['user-agent']),
      expiresAt: new Date(Date.now() + sessionExpirationMs),
      rememberMe: rememberMe,
    });

    await this.sessionRepository.save(session);

    return {
      accessToken,
      refreshToken,
      user: this.transformUserToDto(user),
    };
  }

  private transformUserToDto(user: User): UserDto {
    const userDto = plainToClass(UserDto, user, {
      excludeExtraneousValues: false,
    });
    userDto.roles = user.roles.map((role) => role.roleName);
    userDto.fullName = user.fullName;
    return userDto;
  }

  private detectDeviceType(userAgent?: string): string {
    if (!userAgent) return 'web';

    // Keep values aligned with DB enum used in production (ios/android/web).
    if (/(iphone|ipad|ipod|ios)/i.test(userAgent)) return 'ios';
    if (/(android)/i.test(userAgent)) return 'android';
    return 'web';
  }
}
