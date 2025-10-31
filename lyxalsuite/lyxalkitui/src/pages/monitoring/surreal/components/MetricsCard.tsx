import React from 'react';

interface MetricsCardProps {
  title: string;
  value: string | number;
  description: string;
  icon: React.ReactNode;
  valueColor?: string;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  className?: string;
}

export function MetricsCard({ 
  title, 
  value, 
  description, 
  icon, 
  valueColor = 'text-primary',
  trend,
  className = ''
}: MetricsCardProps) {
  return (
    <div className={`bg-base-200 shadow-xl rounded-2xl border border-base-300 hover:shadow-2xl transition-all duration-300 p-6 ${className}`}>
      <div className="text-primary flex justify-end">
        {icon}
      </div>
      <div className="text-base-content/70 text-sm font-medium">{title}</div>
      <div className={`text-2xl font-bold ${valueColor}`}>{value}</div>
      <div className="text-base-content/60 text-xs flex items-center gap-2">
        {trend && (
          <div className={`flex items-center ${trend.isPositive ? 'text-success' : 'text-error'}`}>
            {trend.isPositive ? '↗️' : '↘️'}
            <span className="text-xs">{Math.abs(trend.value)}%</span>
          </div>
        )}
        <span>{description}</span>
      </div>
    </div>
  );
} 