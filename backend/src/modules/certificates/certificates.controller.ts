import { Controller, Get, Post, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CertificatesService } from './certificates.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@ApiTags('Certificates')
@Controller('certificates')
export class CertificatesController {
  constructor(private readonly certificatesService: CertificatesService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user certificates' })
  async getUserCertificates(@Request() req) {
    return this.certificatesService.getUserCertificates(req.user.id);
  }

  @Post('generate/:level')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Generate certificate for level' })
  async generateCertificate(
    @Request() req,
    @Param('level') level: string,
  ) {
    return this.certificatesService.generateCertificate(req.user.id, level);
  }

  @Get('verify/:code')
  @ApiOperation({ summary: 'Verify certificate' })
  async verifyCertificate(@Param('code') code: string) {
    return this.certificatesService.verifyCertificate(code);
  }
}
