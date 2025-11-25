import { UserDto } from './user.dto';

export class LoginResponseDto {
  accessToken: string;
  refreshToken: string;
  user: UserDto;
}

export class TokenRefreshResponseDto {
  accessToken: string;
  refreshToken: string;
}
