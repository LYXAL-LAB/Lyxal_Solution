import { apiClient } from './config';
import { PaginationOptions, PaginatedResponse } from './types';

interface Log {
  id: string;
  type: string;
  payload: Record<string, any>;
  createdAt: string;
}

/**
 * Récupère les logs
 */
export const getLogs = async (
  options?: PaginationOptions & {
    userId?: string;
    applicationId?: string;
    logType?: string;
    from?: string;
    to?: string;
  }
): Promise<PaginatedResponse<Log>> => {
  const queryParams = new URLSearchParams();
  
  if (options) {
    if (options.page) queryParams.append('page', options.page.toString());
    if (options.pageSize) queryParams.append('page_size', options.pageSize.toString());
    if (options.userId) queryParams.append('userId', options.userId);
    if (options.applicationId) queryParams.append('applicationId', options.applicationId);
    if (options.logType) queryParams.append('logType', options.logType);
    if (options.from) queryParams.append('from', options.from);
    if (options.to) queryParams.append('to', options.to);
  }
  
  const query = queryParams.toString() ? `?${queryParams.toString()}` : '';
  return apiClient<PaginatedResponse<Log>>(`/logs${query}`);
};

/**
 * Récupère un log par son ID
 */
export const getLog = async (logId: string): Promise<Log> => {
  return apiClient<Log>(`/logs/${logId}`);
}; 