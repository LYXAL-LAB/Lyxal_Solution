import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Trash2, Plus } from 'lucide-react';

interface Guard {
  type: 'auth' | 'role' | 'subscription' | 'feature';
  condition?: Record<string, any>;
}

interface GuardsEditorProps {
  guards: Guard[];
  onChange: (guards: Guard[]) => void;
  className?: string;
}

const GUARD_TYPES = [
  { value: 'auth', label: 'Authentication', description: 'Vérifie si l\'utilisateur est connecté' },
  { value: 'role', label: 'Role', description: 'Vérifie le rôle de l\'utilisateur' },
  { value: 'subscription', label: 'Subscription', description: 'Vérifie le plan d\'abonnement' },
  { value: 'feature', label: 'Feature', description: 'Vérifie l\'accès à une fonctionnalité' }
];

export const GuardsEditor = ({ guards, onChange, className = '' }: GuardsEditorProps) => {
  const addGuard = () => {
    const newGuards = [...guards, { type: 'auth' as const }];
    onChange(newGuards);
  };

  const removeGuard = (index: number) => {
    const newGuards = guards.filter((_, i) => i !== index);
    onChange(newGuards);
  };

  const updateGuard = (index: number, updates: Partial<Guard>) => {
    const newGuards = [...guards];
    newGuards[index] = { ...newGuards[index], ...updates };

    // Reset condition when type changes
    if (updates.type && updates.type !== guards[index].type) {
      newGuards[index].condition = {};
    }

    onChange(newGuards);
  };

  const updateGuardCondition = (index: number, key: string, value: any) => {
    const newGuards = [...guards];
    newGuards[index].condition = { ...newGuards[index].condition, [key]: value };
    onChange(newGuards);
  };

  return (
    <div className={`space-y-4 ${className}`}>
      <div className="flex justify-between items-center">
        <div>
          <h3 className="text-lg font-semibold">Security Guards</h3>
          <p className="text-sm text-muted-foreground">
            Configure security checks for this route
          </p>
        </div>
        <Button onClick={addGuard} size="sm" variant="outline">
          <Plus className="w-4 h-4 mr-2" />
          Add Guard
        </Button>
      </div>

      {guards.length === 0 ? (
        <Card>
          <CardContent className="flex items-center justify-center py-8">
            <div className="text-center text-muted-foreground">
              <p className="text-sm">No security guards configured</p>
              <p className="text-xs mt-1">Add guards to secure this route</p>
            </div>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-3">
          {guards.map((guard, index) => (
            <Card key={index}>
              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-base">Guard #{index + 1}</CardTitle>
                  <Button
                    onClick={() => removeGuard(index)}
                    size="sm"
                    variant="outline"
                    className="text-destructive hover:text-destructive"
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <Label htmlFor={`guard-type-${index}`}>Guard Type</Label>
                  <Select
                    value={guard.type}
                    onValueChange={(value: Guard['type']) => updateGuard(index, { type: value })}
                  >
                    <SelectTrigger id={`guard-type-${index}`}>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {GUARD_TYPES.map(type => (
                        <SelectItem key={type.value} value={type.value}>
                          <div>
                            <div className="font-medium">{type.label}</div>
                            <div className="text-xs text-muted-foreground">{type.description}</div>
                          </div>
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {guard.type === 'role' && (
                  <div>
                    <Label htmlFor={`role-${index}`}>Required Role</Label>
                    <Input
                      id={`role-${index}`}
                      value={guard.condition?.role || ''}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => updateGuardCondition(index, 'role', e.target.value)}
                      placeholder="admin"
                    />
                  </div>
                )}

                {guard.type === 'subscription' && (
                  <div>
                    <Label htmlFor={`plan-${index}`}>Required Plan</Label>
                    <Input
                      id={`plan-${index}`}
                      value={guard.condition?.plan || ''}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => updateGuardCondition(index, 'plan', e.target.value)}
                      placeholder="premium"
                    />
                  </div>
                )}

                {guard.type === 'feature' && (
                  <div>
                    <Label htmlFor={`feature-${index}`}>Required Feature</Label>
                    <Input
                      id={`feature-${index}`}
                      value={guard.condition?.feature || ''}
                      onChange={(e: React.ChangeEvent<HTMLInputElement>) => updateGuardCondition(index, 'feature', e.target.value)}
                      placeholder="advanced_analytics"
                    />
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};
