import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

import { SslStatus } from '../enums/ssl-status.enum';

@Entity('ssl_certificates')
export class SslCertificate {
  @PrimaryGeneratedColumn({ name: 'cert_id', type: 'bigint', unsigned: true })
  certId: number;

  @Column({ name: 'campus_id', type: 'bigint', unsigned: true })
  campusId: number;

  @Column({ name: 'domain_name', type: 'varchar', length: 255 })
  domainName: string;

  @Column({ name: 'certificate_path', type: 'varchar', length: 500, nullable: true })
  certificatePath: string;

  @Column({ name: 'private_key_path', type: 'varchar', length: 500, nullable: true })
  privateKeyPath: string;

  @Column({ name: 'issuer', type: 'varchar', length: 255, nullable: true })
  issuer: string;

  @Column({ name: 'valid_from', type: 'date' })
  validFrom: Date;

  @Column({ name: 'valid_until', type: 'date' })
  validUntil: Date;

  @Column({
    name: 'status',
    type: 'enum',
    enum: ['active', 'expiring_soon', 'expired', 'revoked'],
    default: SslStatus.ACTIVE,
  })
  status: SslStatus;

  @Column({ name: 'auto_renew', type: 'tinyint', default: 1 })
  autoRenew: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
