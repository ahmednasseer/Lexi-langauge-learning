import { Controller, Post, Body, Get, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { RegisterDto, LoginDto, GoogleLoginDto } from './dto/auth.dto';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('register')
  @ApiOperation({ summary: 'Register new user' })
  async register(@Body() body: RegisterDto) {
    return this.authService.register(body.name, body.email, body.password);
  }

  @Post('login')
  @ApiOperation({ summary: 'Login with email' })
  async login(@Body() body: LoginDto) {
    return this.authService.login(body.email, body.password);
  }

  @Post('google')
  @ApiOperation({ summary: 'Login with Google' })
  async googleLogin(@Body() body: GoogleLoginDto) {
    return this.authService.loginWithGoogle(body);
  }

  @Post('guest')
  @ApiOperation({ summary: 'Login as guest' })
  async guestLogin() {
    return this.authService.loginAsGuest();
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user' })
  async getMe(@Request() req) {
    return this.authService.validateUser(req.user.sub);
  }
}
