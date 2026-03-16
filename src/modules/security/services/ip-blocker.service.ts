import { Injectable, Logger, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { BlockedIp } from '../entities/blocked-ip.entity';
import { BlockIpDto } from '../dto/block-ip.dto';

@Injectable()
export class IpBlockerService {
  private readonly logger = new Logger(IpBlockerService.name);

  constructor(
    @InjectRepository(BlockedIp)
    private blockedIpRepo: Repository<BlockedIp>,
  ) {}

  async blockIp(dto: BlockIpDto) {
    const existing = await this.blockedIpRepo.findOne({
      where: { ipAddress: dto.ipAddress },
    });

    if (existing && existing.isActive) {
      throw new ConflictException(`IP ${dto.ipAddress} is already blocked`);
    }

    if (existing) {
      existing.isActive = true;
      existing.reason = dto.reason;
      existing.expiresAt = dto.expiresAt ? new Date(dto.expiresAt) : null;
      return this.blockedIpRepo.save(existing);
    }

    const blockedIp = this.blockedIpRepo.create({
      ipAddress: dto.ipAddress,
      reason: dto.reason,
      expiresAt: dto.expiresAt ? new Date(dto.expiresAt) : null,
    });

    return this.blockedIpRepo.save(blockedIp);
  }

  async unblockIp(id: number) {
    const blockedIp = await this.blockedIpRepo.findOne({
      where: { ipId: id },
    });

    if (!blockedIp) {
      throw new NotFoundException(`Blocked IP record ${id} not found`);
    }

    blockedIp.isActive = false;
    await this.blockedIpRepo.save(blockedIp);

    return { message: `IP ${blockedIp.ipAddress} unblocked successfully` };
  }

  async getBlockedIps() {
    const data = await this.blockedIpRepo.find({
      order: { blockedAt: 'DESC' },
    });
    return { data };
  }

  async isIpBlocked(ip: string): Promise<boolean> {
    const blocked = await this.blockedIpRepo.findOne({
      where: { ipAddress: ip, isActive: true },
    });

    if (blocked && blocked.expiresAt && new Date(blocked.expiresAt) < new Date()) {
      blocked.isActive = false;
      await this.blockedIpRepo.save(blocked);
      return false;
    }

    return !!blocked;
  }
}
