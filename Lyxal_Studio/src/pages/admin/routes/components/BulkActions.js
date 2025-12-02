import { jsxs as _jsxs, jsx as _jsx, Fragment as _Fragment } from "react/jsx-runtime";
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from '@/components/ui/alert-dialog';
import { Trash2, Play, Pause, Archive } from 'lucide-react';
export const BulkActions = ({ selectedRoutes, onStatusChange, onDelete, onClearSelection, isLoading = false, className = '' }) => {
    const [pendingAction, setPendingAction] = useState(null);
    if (selectedRoutes.length === 0) {
        return null;
    }
    const handleStatusChange = (status) => {
        setPendingAction({ type: 'status', value: status });
    };
    const handleDelete = () => {
        setPendingAction({ type: 'delete' });
    };
    const executeAction = () => {
        if (!pendingAction)
            return;
        if (pendingAction.type === 'status' && pendingAction.value) {
            onStatusChange(selectedRoutes, pendingAction.value);
        }
        else if (pendingAction.type === 'delete') {
            onDelete(selectedRoutes);
        }
        setPendingAction(null);
    };
    const cancelAction = () => {
        setPendingAction(null);
    };
    return (_jsxs(_Fragment, { children: [_jsxs("div", { className: `flex items-center gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg ${className}`, children: [_jsxs(Badge, { variant: "secondary", className: "bg-blue-100 text-blue-800", children: [selectedRoutes.length, " selected"] }), _jsxs("div", { className: "flex gap-2", children: [_jsxs(Select, { onValueChange: handleStatusChange, disabled: isLoading, children: [_jsx(SelectTrigger, { className: "w-32", children: _jsx(SelectValue, { placeholder: "Change status" }) }), _jsxs(SelectContent, { children: [_jsx(SelectItem, { value: "active", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx(Play, { className: "w-4 h-4" }), "Activate"] }) }), _jsx(SelectItem, { value: "inactive", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx(Pause, { className: "w-4 h-4" }), "Deactivate"] }) }), _jsx(SelectItem, { value: "draft", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx(Archive, { className: "w-4 h-4" }), "Set as Draft"] }) }), _jsx(SelectItem, { value: "deprecated", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx(Archive, { className: "w-4 h-4" }), "Deprecate"] }) })] })] }), _jsxs(AlertDialog, { children: [_jsx(AlertDialogTrigger, { asChild: true, children: _jsxs(Button, { variant: "destructive", size: "sm", disabled: isLoading, children: [_jsx(Trash2, { className: "w-4 h-4 mr-2" }), "Delete"] }) }), _jsxs(AlertDialogContent, { children: [_jsxs(AlertDialogHeader, { children: [_jsx(AlertDialogTitle, { children: "Delete Routes" }), _jsxs(AlertDialogDescription, { children: ["Are you sure you want to delete ", selectedRoutes.length, " route", selectedRoutes.length !== 1 ? 's' : '', "? This action cannot be undone."] })] }), _jsxs(AlertDialogFooter, { children: [_jsx(AlertDialogCancel, { children: "Cancel" }), _jsx(AlertDialogAction, { onClick: handleDelete, className: "bg-destructive text-destructive-foreground hover:bg-destructive/90", children: "Delete" })] })] })] })] }), _jsx("div", { className: "ml-auto", children: _jsx(Button, { variant: "outline", size: "sm", onClick: onClearSelection, children: "Clear Selection" }) })] }), _jsx(AlertDialog, { open: !!pendingAction, onOpenChange: (open) => !open && cancelAction(), children: _jsxs(AlertDialogContent, { children: [_jsxs(AlertDialogHeader, { children: [_jsx(AlertDialogTitle, { children: pendingAction?.type === 'status'
                                        ? `Change Status to ${pendingAction?.value}`
                                        : 'Delete Routes' }), _jsx(AlertDialogDescription, { children: pendingAction?.type === 'status'
                                        ? `Are you sure you want to change the status of ${selectedRoutes.length} route${selectedRoutes.length !== 1 ? 's' : ''} to "${pendingAction?.value}"?`
                                        : `Are you sure you want to delete ${selectedRoutes.length} route${selectedRoutes.length !== 1 ? 's' : ''}? This action cannot be undone.` })] }), _jsxs(AlertDialogFooter, { children: [_jsx(AlertDialogCancel, { onClick: cancelAction, children: "Cancel" }), _jsx(AlertDialogAction, { onClick: executeAction, children: pendingAction?.type === 'status' ? 'Change Status' : 'Delete' })] })] }) })] }));
};
