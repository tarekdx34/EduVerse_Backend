import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('branding_settings')
export class BrandingSetting {
  @PrimaryGeneratedColumn({ name: 'branding_id', type: 'bigint', unsigned: true })
  brandingId: number;

  @Column({ name: 'campus_id', type: 'bigint', unsigned: true })
  campusId: number;

  @Column({ name: 'logo_url', type: 'varchar', length: 500, nullable: true })
  logoUrl: string;

  @Column({ name: 'favicon_url', type: 'varchar', length: 500, nullable: true })
  faviconUrl: string;

  @Column({ name: 'primary_color', type: 'varchar', length: 7, default: '#007bff' })
  primaryColor: string;

  @Column({ name: 'secondary_color', type: 'varchar', length: 7, default: '#6c757d' })
  secondaryColor: string;

  @Column({ name: 'custom_css', type: 'text', nullable: true })
  customCss: string;

  @Column({ name: 'email_header_html', type: 'text', nullable: true })
  emailHeaderHtml: string;

  @Column({ name: 'email_footer_html', type: 'text', nullable: true })
  emailFooterHtml: string;

  @Column({ name: 'updated_by', type: 'bigint', unsigned: true, nullable: true })
  updatedBy: number;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'updated_by' })
  updatedByUser: User;
}
