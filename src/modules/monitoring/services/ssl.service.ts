import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SslCertificate } from '../entities/ssl-certificate.entity';

@Injectable()
export class SslService {
  private readonly logger = new Logger(SslService.name);

  constructor(
    @InjectRepository(SslCertificate)
    private sslRepo: Repository<SslCertificate>,
  ) {}

  async getCertificates() {
    const data = await this.sslRepo.find({
      order: { validUntil: 'ASC' },
    });
    return { data };
  }

  async getCertificateDetails(id: number) {
    const cert = await this.sslRepo.findOne({ where: { certId: id } });
    if (!cert) {
      return { message: `SSL certificate #${id} not found` };
    }
    return { data: cert };
  }

  async getExpiringCertificates() {
    const data = await this.sslRepo
      .createQueryBuilder('ssl')
      .where("ssl.status IN ('expiring_soon', 'expired')")
      .orderBy('ssl.valid_until', 'ASC')
      .getMany();

    return { data };
  }
}
