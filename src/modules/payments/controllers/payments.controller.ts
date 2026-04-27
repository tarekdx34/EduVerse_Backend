import { Controller, Get, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { PaymentRecordDto } from '../dto/payment-record.dto';
import { PaymentsService } from '../services/payments.service';

@ApiTags('💳 Payments')
@ApiBearerAuth('JWT-auth')
@Controller('api/payments')
@UseGuards(JwtAuthGuard, RolesGuard)
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Get('my')
  @Roles(RoleName.STUDENT)
  @ApiOperation({ summary: "Get authenticated student's payment records" })
  @ApiResponse({ status: 200, description: 'Payment records', type: [PaymentRecordDto] })
  async getMyPayments(@Request() req): Promise<PaymentRecordDto[]> {
    const userId = req.user.userId || req.user.id;
    return this.paymentsService.getMyPayments(userId);
  }
}

