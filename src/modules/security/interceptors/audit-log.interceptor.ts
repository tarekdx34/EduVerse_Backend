import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { AuditService } from '../services/audit.service';

@Injectable()
export class AuditLogInterceptor implements NestInterceptor {
  private readonly logger = new Logger(AuditLogInterceptor.name);

  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;

    // Only log write operations
    if (!['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
      return next.handle();
    }

    const user = request.user;
    const url = request.url;
    const routePath = request.route?.path || url;

    // Derive entity type from URL path
    const pathParts = url.replace('/api/', '').split('/').filter(Boolean);
    const entityType = pathParts[0] || 'unknown';

    // Derive action type from HTTP method
    const actionMap: Record<string, string> = {
      POST: 'CREATE',
      PUT: 'UPDATE',
      PATCH: 'UPDATE',
      DELETE: 'DELETE',
    };
    const actionType = actionMap[method] || method;

    // Try to extract entity ID from URL params
    const paramId = request.params?.id || request.params?.courseId || request.params?.userId || null;

    return next.handle().pipe(
      tap({
        next: () => {
          // Fire and forget — don't block the response
          this.auditService
            .createAuditLog({
              userId: user?.userId || user?.id || null,
              actionType,
              entityType,
              entityId: paramId ? Number(paramId) : undefined,
              newValues: method !== 'DELETE' ? JSON.stringify(request.body) : undefined,
              ipAddress: request.ip || request.connection?.remoteAddress,
              userAgent: request.headers?.['user-agent'],
              description: `${actionType} ${entityType} via ${method} ${url}`,
            })
            .catch((err) => {
              this.logger.warn(`Failed to create audit log: ${err.message}`);
            });
        },
      }),
    );
  }
}
