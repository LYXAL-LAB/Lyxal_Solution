import React, { useEffect } from 'react';
import { useToastStore } from '../store/toast.store';
import { CheckCircle2, XCircle, AlertTriangle, Info, X } from 'lucide-react';

export const NotificationToast: React.FC = () => {
    const { toasts, removeToast } = useToastStore();

    useEffect(() => {
        // Auto-remove toasts after 5 seconds
        toasts.forEach(toast => {
            if (toast.id) {
                const timer = setTimeout(() => {
                    removeToast(toast.id!);
                }, 5000);
                return () => clearTimeout(timer);
            }
        });
    }, [toasts, removeToast]);

    const getIcon = (type: string) => {
        switch (type) {
            case 'success':
                return <CheckCircle2 className="h-6 w-6 text-green-500 dark:text-green-400" />;
            case 'error':
                return <XCircle className="h-6 w-6 text-destructive" />;
            case 'warning':
                return <AlertTriangle className="h-6 w-6 text-yellow-500 dark:text-yellow-400" />;
            default:
                return <Info className="h-6 w-6 text-primary" />;
        }
    };

    return (
        <div className="fixed top-4 right-4 z-50 space-y-4">
            {toasts.map((notification) => (
                <div
                    key={notification.id}
                    className="max-w-sm w-full bg-card text-card-foreground shadow-lg rounded-lg pointer-events-auto ring-1 ring-border overflow-hidden animate-in slide-in-from-right fade-in duration-300"
                >
                    <div className="p-4">
                        <div className="flex items-start">
                            <div className="flex-shrink-0">
                                {getIcon(notification.type)}
                            </div>

                            <div className="ml-3 w-0 flex-1 pt-0.5">
                                <p className="text-sm font-medium text-foreground">
                                    {notification.title || notification.message}
                                </p>
                                {notification.title && notification.message && (
                                    <p className="mt-1 text-sm text-muted-foreground">
                                        {notification.message}
                                    </p>
                                )}
                            </div>

                            <div className="ml-4 flex-shrink-0 flex">
                                <button
                                    onClick={() => removeToast(notification.id!)}
                                    className="bg-transparent rounded-md inline-flex text-muted-foreground hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 focus-visible:ring-offset-background transition-colors"
                                    aria-label="Close notification"
                                >
                                    <span className="sr-only">Close</span>
                                    <X className="h-5 w-5" />
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            ))}
        </div>
    );
};
