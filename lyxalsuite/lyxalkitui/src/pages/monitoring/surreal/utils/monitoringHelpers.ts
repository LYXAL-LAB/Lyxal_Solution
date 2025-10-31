export const formatResponseTime = (timeMs: number): string => {
  if (timeMs < 1000) {
    return `${timeMs}ms`;
  }
  return `${(timeMs / 1000).toFixed(2)}s`;
};

export const getPerformanceStatus = (
  value: number, 
  thresholds: { excellent: number; good: number; warning: number }
): 'excellent' | 'good' | 'warning' | 'critical' => {
  if (value <= thresholds.excellent) return 'excellent';
  if (value <= thresholds.good) return 'good';
  if (value <= thresholds.warning) return 'warning';
  return 'critical';
};

export const getStatusColor = (status: string): string => {
  switch (status) {
    case 'excellent':
      return 'text-success';
    case 'good':
      return 'text-info';
    case 'warning':
      return 'text-warning';
    case 'critical':
      return 'text-error';
    default:
      return 'text-base-content';
  }
};

export const calculateCacheEfficiency = (hits: number, misses: number): number => {
  const total = hits + misses;
  return total > 0 ? (hits / total) * 100 : 0;
};

export const formatBytes = (bytes: number): string => {
  const sizes = ['B', 'KB', 'MB', 'GB'];
  if (bytes === 0) return '0 B';
  
  const i = Math.floor(Math.log(bytes) / Math.log(1024));
  return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
};

export const formatUptime = (startTime: Date): string => {
  const now = new Date();
  const diffMs = now.getTime() - startTime.getTime();
  
  const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
  const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
  
  if (days > 0) {
    return `${days}j ${hours}h ${minutes}m`;
  } else if (hours > 0) {
    return `${hours}h ${minutes}m`;
  } else {
    return `${minutes}m`;
  }
};

// Nouvelles fonctions utilitaires pour SurrealDB
export const formatSurrealQuery = (query: string): string => {
  return query.replace(/\s+/g, ' ').trim();
};

export const getSurrealDBStatus = (connectionState: string): {
  color: string;
  label: string;
  badge: string;
} => {
  switch (connectionState) {
    case 'connected':
      return {
        color: 'text-success',
        label: 'Connecté',
        badge: 'badge-success'
      };
    case 'connecting':
      return {
        color: 'text-warning',
        label: 'Connexion...',
        badge: 'badge-warning'
      };
    case 'disconnected':
      return {
        color: 'text-error',
        label: 'Déconnecté',
        badge: 'badge-error'
      };
    default:
      return {
        color: 'text-base-content',
        label: 'Inconnu',
        badge: 'badge-ghost'
      };
  }
}; 