import { useState } from 'react';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';

interface PermissionsSelectProps {
  selected: string[];
  onChange: (permissions: string[]) => void;
  className?: string;
}

const AVAILABLE_PERMISSIONS = [
  { id: 'guest', label: 'Guest', description: 'Accès public' },
  { id: 'authenticated', label: 'Authenticated', description: 'Utilisateurs connectés' },
  { id: 'admin', label: 'Admin', description: 'Administrateurs' },
  { id: 'manager', label: 'Manager', description: 'Gestionnaires' }
];

export const PermissionsSelect = ({ selected, onChange, className = '' }: PermissionsSelectProps) => {
  const handlePermissionChange = (permissionId: string, checked: boolean) => {
    if (checked) {
      onChange([...selected, permissionId]);
    } else {
      onChange(selected.filter(p => p !== permissionId));
    }
  };

  return (
    <div className={`space-y-3 ${className}`}>
      <div className="flex flex-wrap gap-1 mb-3">
        {selected.map(permission => {
          const permConfig = AVAILABLE_PERMISSIONS.find(p => p.id === permission);
          return (
            <Badge key={permission} variant="secondary" className="text-xs">
              {permConfig?.label || permission}
            </Badge>
          );
        })}
      </div>

      <div className="space-y-2">
        {AVAILABLE_PERMISSIONS.map(permission => (
          <div key={permission.id} className="flex items-center space-x-2">
            <Checkbox
              id={permission.id}
              checked={selected.includes(permission.id)}
              onCheckedChange={(checked: boolean) => handlePermissionChange(permission.id, checked)}
            />
            <div className="grid gap-1.5 leading-none">
              <Label
                htmlFor={permission.id}
                className="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              >
                {permission.label}
              </Label>
              <p className="text-xs text-muted-foreground">
                {permission.description}
              </p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
