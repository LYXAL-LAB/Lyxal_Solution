import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
const AVAILABLE_PERMISSIONS = [
    { id: 'guest', label: 'Guest', description: 'Accès public' },
    { id: 'authenticated', label: 'Authenticated', description: 'Utilisateurs connectés' },
    { id: 'admin', label: 'Admin', description: 'Administrateurs' },
    { id: 'manager', label: 'Manager', description: 'Gestionnaires' }
];
export const PermissionsSelect = ({ selected, onChange, className = '' }) => {
    const handlePermissionChange = (permissionId, checked) => {
        if (checked) {
            onChange([...selected, permissionId]);
        }
        else {
            onChange(selected.filter(p => p !== permissionId));
        }
    };
    return (_jsxs("div", { className: `space-y-3 ${className}`, children: [_jsx("div", { className: "flex flex-wrap gap-1 mb-3", children: selected.map(permission => {
                    const permConfig = AVAILABLE_PERMISSIONS.find(p => p.id === permission);
                    return (_jsx(Badge, { variant: "secondary", className: "text-xs", children: permConfig?.label || permission }, permission));
                }) }), _jsx("div", { className: "space-y-2", children: AVAILABLE_PERMISSIONS.map(permission => (_jsxs("div", { className: "flex items-center space-x-2", children: [_jsx(Checkbox, { id: permission.id, checked: selected.includes(permission.id), onCheckedChange: (checked) => handlePermissionChange(permission.id, checked) }), _jsxs("div", { className: "grid gap-1.5 leading-none", children: [_jsx(Label, { htmlFor: permission.id, className: "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70", children: permission.label }), _jsx("p", { className: "text-xs text-muted-foreground", children: permission.description })] })] }, permission.id))) })] }));
};
