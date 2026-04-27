import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { PaymentRecordDto } from '../dto/payment-record.dto';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectDataSource()
    private readonly dataSource: DataSource,
  ) {}

  async getMyPayments(userId: number): Promise<PaymentRecordDto[]> {
    const rows = await this.dataSource.query<
      {
        transaction_id: string | number;
        amount: string | number | null;
        currency: string | null;
        transaction_status: string | null;
        paid_at: string | Date | null;
        course_code: string | null;
        course_name: string | null;
      }[]
    >(
      `
      SELECT
        pt.transaction_id,
        pt.amount,
        pt.currency,
        pt.transaction_status,
        pt.paid_at,
        c.course_code,
        c.course_name
      FROM payment_transactions pt
      LEFT JOIN courses c ON c.course_id = pt.course_id
      WHERE pt.user_id = ?
      ORDER BY pt.paid_at DESC, pt.transaction_id DESC
      `,
      [userId],
    );

    return (rows || []).map((row) => {
      const amount = Number(row.amount || 0);
      const currency = row.currency || 'USD';
      const date = row.paid_at ? new Date(row.paid_at).toISOString().slice(0, 10) : '';
      const baseCategory = Number.isFinite(amount) ? `${currency} ${amount.toFixed(2)}` : currency;
      const category =
        row.course_code && row.course_name
          ? `${baseCategory} - ${row.course_code} ${row.course_name}`
          : `${baseCategory} - Tuition Payment`;

      return {
        id: String(row.transaction_id),
        category,
        date,
        status: this.mapStatus(row.transaction_status),
      };
    });
  }

  private mapStatus(status: string | null | undefined): PaymentRecordDto['status'] {
    switch ((status || '').toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return 'On-Verification';
    }
  }
}

