import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';
import { AuditService } from '../security/services/audit.service';

export type AdminDashboardRecentActivity = {
  type: 'course' | 'user';
  title: string;
  description: string;
  time: string;
};

export type AdminDashboardSummary = {
  analytics: {
    userGrowth: { month: string; students: number; instructors: number }[];
    courseEngagement: {
      course: string;
      activeStudents: number;
      avgAttendance: number | null;
      avgGrade: number | null;
    }[];
    aiUsage: { label: string; value: number }[];
    systemMetrics: {
      cpuUsage: number;
      memoryUsage: number;
      storageUsage: number;
      networkLoad: number;
    } | null;
  };
  recentActivity: AdminDashboardRecentActivity[];
};

@Injectable()
export class AdminDashboardService {
  constructor(
    @InjectDataSource()
    private readonly dataSource: DataSource,
    private readonly auditService: AuditService,
  ) {}

  async getDashboardSummary(): Promise<AdminDashboardSummary> {
    const userGrowthRows = await this.dataSource.query<
      { month: string; students: string | number; instructors: string | number }[]
    >(
      `
      SELECT DATE_FORMAT(u.created_at, '%Y-%m') AS month,
        COUNT(DISTINCT CASE WHEN r.role_name = 'student' THEN u.user_id END) AS students,
        COUNT(DISTINCT CASE WHEN r.role_name = 'instructor' THEN u.user_id END) AS instructors
      FROM users u
      LEFT JOIN user_roles ur ON ur.user_id = u.user_id
      LEFT JOIN roles r ON r.role_id = ur.role_id
      WHERE u.created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
        AND u.deleted_at IS NULL
      GROUP BY DATE_FORMAT(u.created_at, '%Y-%m')
      ORDER BY month ASC
      `,
    );

    const userGrowth = (userGrowthRows || []).map((row) => ({
      month: String(row.month),
      students: Number(row.students) || 0,
      instructors: Number(row.instructors) || 0,
    }));

    const engagementRows = await this.dataSource.query<
      { course: string; activeStudents: string | number }[]
    >(
      `
      SELECT CONCAT(c.course_code, ' — ', c.course_name) AS course,
        COUNT(DISTINCT e.user_id) AS activeStudents
      FROM course_enrollments e
      INNER JOIN course_sections sec ON sec.section_id = e.section_id
      INNER JOIN courses c ON c.course_id = sec.course_id
      WHERE e.enrollment_status IN ('enrolled', 'completed')
        AND c.deleted_at IS NULL
      GROUP BY c.course_id, c.course_code, c.course_name
      ORDER BY activeStudents DESC
      LIMIT 8
      `,
    );

    const courseEngagement = (engagementRows || []).map((row) => ({
      course: String(row.course).length > 48 ? `${String(row.course).slice(0, 46)}…` : String(row.course),
      activeStudents: Number(row.activeStudents) || 0,
      avgAttendance: null,
      avgGrade: null,
    }));

    const auditPage = await this.auditService.getAuditLogs({ page: 1, limit: 15 });
    const recentActivity: AdminDashboardRecentActivity[] = (auditPage.data || []).map((log: any) => {
      const created = log.createdAt ? new Date(log.createdAt) : new Date();
      const time = Number.isNaN(created.getTime())
        ? '—'
        : created.toLocaleString(undefined, {
            month: 'short',
            day: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
          });
      const et = (log.entityType || '').toLowerCase();
      const type: 'course' | 'user' = et === 'course' ? 'course' : 'user';
      const actor =
        log.user?.firstName || log.user?.lastName
          ? `${log.user?.firstName || ''} ${log.user?.lastName || ''}`.trim()
          : log.userId
            ? `User #${log.userId}`
            : 'System';
      const title = `${log.actionType || 'ACTION'}${log.entityType ? ` · ${log.entityType}` : ''}`;
      const description = log.description || `${actor}`;
      return { type, title, description, time };
    });

    return {
      analytics: {
        userGrowth,
        courseEngagement,
        aiUsage: [],
        systemMetrics: null,
      },
      recentActivity,
    };
  }
}
