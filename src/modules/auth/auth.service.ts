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
  ) {}

  async register(
    registerDto: RegisterRequestDto,
    request: any,
  ): Promise<LoginResponseDto> {
    // Check if user already exists
    const existingUser = await this.userRepository.findOne({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException('Email already registered');
    }

    // Get default role (student) or requested role
    const roleName = registerDto.role || RoleName.STUDENT;
    const role = await this.roleRepository.findOne({
      where: { roleName },
    });

    if (!role) {
      throw new BadRequestException('Invalid role');
    }

    // Create user
    const user = this.userRepository.create({
      email: registerDto.email,
      passwordHash: registerDto.password, // Will be hashed by entity hook
      firstName: registerDto.firstName,
      lastName: registerDto.lastName,
      phone: registerDto.phone,
      status: UserStatus.PENDING,
      emailVerified: false,
      roles: [role],
    });

    await this.userRepository.save(user);

    // TODO: Send verification email

    // Auto-activate for now (in production, require email verification)
    user.status = UserStatus.ACTIVE;
    user.emailVerified = true;
    await this.userRepository.save(user);

    // Generate tokens and create session
    return this.generateAuthResponse(user, request);
  }

  async login(
    loginDto: LoginRequestDto,
    request: any,
  ): Promise<LoginResponseDto> {
    // Find user with roles
    const user = await this.userRepository.findOne({
      where: { email: loginDto.email },
      relations: ['roles'],
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isPasswordValid = await user.validatePassword(loginDto.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if email is verified
    if (!user.emailVerified) {
      throw new UnauthorizedException('Please verify your email first');
    }

    // Check account status
    if (user.status !== UserStatus.ACTIVE) {
      throw new UnauthorizedException('Account is not active');
    }

    // Update last login
    user.lastLoginAt = new Date();
    await this.userRepository.save(user);

    // Generate tokens and create session
    return this.generateAuthResponse(user, request);
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

      // Verify session exists
      const session = await this.sessionRepository.findOne({
        where: {
          userId: user.userId,
          sessionToken: refreshToken,
        },
      });

      if (!session) {
        throw new UnauthorizedException('Invalid session');
      }

      // Check if session expired
      if (new Date() > session.expiresAt) {
        await this.sessionRepository.remove(session);
        throw new UnauthorizedException('Session expired');
      }

      // Generate new tokens
      return this.generateAuthResponse(user, request);
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
      // Don't reveal if email exists
      return;
    }

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

    // TODO: Send reset email with resetToken (not hashedToken)
    console.log('Reset token:', resetToken); // For testing
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
    passwordReset.user.passwordHash = newPassword; // Will be hashed by entity hook
    await this.userRepository.save(passwordReset.user);

    // Mark token as used
    passwordReset.used = true;
    passwordReset.usedAt = new Date();
    await this.passwordResetRepository.save(passwordReset);

    // Invalidate all user sessions
    await this.sessionRepository.delete({ userId: passwordReset.user.userId });
  }

  async verifyEmail(token: string): Promise<void> {
    // TODO: Implement email verification logic
    throw new BadRequestException('Email verification not implemented yet');
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
  ): Promise<LoginResponseDto> {
    const payload = {
      sub: user.userId,
      email: user.email,
      roles: user.roles.map((role) => role.roleName),
    };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET'),
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn: '7d',
    });

    // Create session
    const session = this.sessionRepository.create({
      userId: user.userId,
      sessionToken: refreshToken,
      ipAddress: request.ip,
      userAgent: request.headers['user-agent'],
      deviceType: this.detectDeviceType(request.headers['user-agent']),
      expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
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

  private detectDeviceType(userAgent: string): string {
    if (!userAgent) return 'unknown';
    if (/mobile/i.test(userAgent)) return 'mobile';
    if (/tablet/i.test(userAgent)) return 'tablet';
    return 'desktop';
  }
}
