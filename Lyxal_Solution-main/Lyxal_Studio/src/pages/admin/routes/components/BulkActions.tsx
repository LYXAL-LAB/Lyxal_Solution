import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from '@/components/ui/alert-dialog';
import { Trash2, Play, Pause, Archive } from 'lucide-react';

interface BulkActionsProps {
  selectedRoutes: string[];
  onStatusChange: (routeIds: string[], status: 'active' | 'inactive' | 'draft' | 'deprecated') => void;
  onDelete: (routeIds: string[]) => void;
  onClearSelection: () => void;
  isLoading?: boolean;
  className?: string;
}

export const BulkActions = ({
  selectedRoutes,
  onStatusChange,
  onDelete,
  onClearSelection,
  isLoading = false,
  className = ''
}: BulkActionsProps) => {
  const [pendingAction, setPendingAction] = useState<{
    type: 'status' | 'delete';
    value?: string;
  } | null>(null);

  if (selectedRoutes.length === 0) {
    return null;
  }

  const handleStatusChange = (status: 'active' | 'inactive' | 'draft' | 'deprecated') => {
    setPendingAction({ type: 'status', value: status });
  };

  const handleDelete = () => {
    setPendingAction({ type: 'delete' });
  };

  const executeAction = () => {
    if (!pendingAction) return;

    if (pendingAction.type === 'status' && pendingAction.value) {
      onStatusChange(selectedRoutes, pendingAction.value as any);
    } else if (pendingAction.type === 'delete') {
      onDelete(selectedRoutes);
    }

    setPendingAction(null);
  };

  const cancelAction = () => {
    setPendingAction(null);
  };

  return (
    <>
      <div className={`flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg ${className}`}>
        <Badge variant="secondary" className="bg-blue-100 text-blue-800">
          {selectedRoutes.length} selected
        </Badge>

        <div className="flex gap-2">
          <Select onValueChange={handleStatusChange} disabled={isLoading}>
            <SelectTrigger className="w-32">
              <SelectValue placeholder="Change status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="active">
                <div className="flex items-center gap-2">
                  <Play className="w-4 h-4" />
                  Activate
                </div>
              </SelectItem>
              <SelectItem value="inactive">
                <div className="flex items-center gap-2">
                  <Pause className="w-4 h-4" />
                  Deactivate
                </div>
              </SelectItem>
              <SelectItem value="draft">
                <div className="flex items-center gap-2">
                  <Archive className="w-4 h-4" />
                  Set as Draft
                </div>
              </SelectItem>
              <SelectItem value="deprecated">
                <div className="flex items-center gap-2">
                  <Archive className="w-4 h-4" />
                  Deprecate
                </div>
              </SelectItem>
            </SelectContent>
          </Select>

          <AlertDialog>
            <AlertDialogTrigger asChild>
              <Button variant="destructive" size="sm" disabled={isLoading}>
                <Trash2 className="w-4 h-4 mr-2" />
                Delete
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Delete Routes</AlertDialogTitle>
                <AlertDialogDescription>
                  Are you sure you want to delete {selectedRoutes.length} route{selectedRoutes.length !== 1 ? 's' : ''}?
                  This action cannot be undone.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction onClick={handleDelete} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
                  Delete
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>

        <div className="ml-auto">
          <Button variant="outline" size="sm" onClick={onClearSelection}>
            Clear Selection
          </Button>
        </div>
      </div>

      {/* Confirmation Dialog for Status Changes */}
      <AlertDialog open={!!pendingAction} onOpenChange={(open: boolean) => !open && cancelAction()}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>
              {pendingAction?.type === 'status'
                ? `Change Status to ${pendingAction?.value}`
                : 'Delete Routes'
              }
            </AlertDialogTitle>
            <AlertDialogDescription>
              {pendingAction?.type === 'status'
                ? `Are you sure you want to change the status of ${selectedRoutes.length} route${selectedRoutes.length !== 1 ? 's' : ''} to "${pendingAction?.value}"?`
                : `Are you sure you want to delete ${selectedRoutes.length} route${selectedRoutes.length !== 1 ? 's' : ''}? This action cannot be undone.`
              }
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel onClick={cancelAction}>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={executeAction}>
              {pendingAction?.type === 'status' ? 'Change Status' : 'Delete'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
};
