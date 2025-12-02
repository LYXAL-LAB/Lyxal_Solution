import React from 'react';
import { useToastStore } from '../../store/toast.store';
import { X } from 'lucide-react';

export const ToastContainer: React.FC = () => {
    const { toasts, removeToast } = useToastStore();

    return (
        <div className="toast-container">
            {toasts.map((toast) => (
                <div key={toast.id} className={`toast toast-${toast.type}`}>
                    <span className="toast-message">{toast.message}</span>
                    <button onClick={() => removeToast(toast.id)} className="toast-close">
                        <X size={16} />
                    </button>
                </div>
            ))}
        </div>
    );
};
