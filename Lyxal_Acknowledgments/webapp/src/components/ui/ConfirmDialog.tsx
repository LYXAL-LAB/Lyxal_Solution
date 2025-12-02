import React from 'react';
import { X } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardContent } from './Card';
import { Button } from './Button';
import { Alert, AlertDescription } from './Alert';
import { cn } from '../../lib/utils';

export interface ConfirmDialogProps {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    title: string;
    message: string;
    confirmText?: string;
    cancelText?: string;
    variant?: 'default' | 'destructive' | 'warning';
    loading?: boolean;
    onConfirm: () => void;
    onCancel?: () => void;
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
    open,
    onOpenChange,
    title,
    message,
    confirmText = 'Confirmer',
    cancelText = 'Annuler',
    variant = 'default',
    loading = false,
    onConfirm,
    onCancel
}) => {
    if (!open) return null;

    const handleCancel = () => {
        if (onCancel) onCancel();
        onOpenChange(false);
    };

    const handleConfirm = () => {
        onConfirm();
    };

    return (
        <div
            className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4"
            onClick={(e) => {
                if (e.target === e.currentTarget) handleCancel();
            }}
        >
            <Card className={cn(
                'max-w-md w-full',
                variant === 'destructive' ? 'border-destructive' : variant === 'warning' ? 'border-orange-500' : 'border-primary'
            )}>
                <CardHeader>
                    <div className="flex items-center justify-between">
                        <CardTitle className={cn(
                            variant === 'destructive' && 'text-destructive',
                            variant === 'warning' && 'text-orange-600'
                        )}>
                            {title}
                        </CardTitle>
                        <Button variant="ghost" size="icon" onClick={handleCancel} disabled={loading}>
                            <X size={20} />
                        </Button>
                    </div>
                </CardHeader>
                <CardContent>
                    <div className="space-y-4">
                        <Alert
                            variant={variant === 'destructive' ? 'destructive' : 'default'}
                            className={cn(
                                variant === 'warning' ? 'border-orange-500 bg-orange-50 dark:bg-orange-900/20' : variant === 'destructive' ? 'border-destructive' : ''
                            )}
                        >
                            <AlertDescription className={cn(variant === 'warning' && 'text-orange-800 dark:text-orange-200')}>
                                {message}
                            </AlertDescription>
                        </Alert>

                        <div className="flex justify-end space-x-3 pt-2">
                            <Button type="button" variant="outline" onClick={handleCancel} disabled={loading}>
                                {cancelText}
                            </Button>
                            <Button
                                onClick={handleConfirm}
                                variant={variant === 'default' ? 'default' : 'destructive'}
                                disabled={loading}
                            >
                                {loading ? 'Chargement...' : confirmText}
                            </Button>
                        </div>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
};
