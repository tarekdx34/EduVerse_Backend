import { PartialType } from '@nestjs/swagger';
import { CreateSlotDto } from './create-slot.dto';
import { IsOptional, IsIn } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UpdateSlotDto extends PartialType(CreateSlotDto) {
  @ApiPropertyOptional({
    description: 'Slot status',
    enum: ['active', 'cancelled', 'suspended'],
    example: 'active',
  })
  @IsOptional()
  @IsIn(['active', 'cancelled', 'suspended'])
  status?: string;
}
