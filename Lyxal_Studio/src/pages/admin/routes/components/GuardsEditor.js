import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Trash2, Plus } from 'lucide-react';
const GUARD_TYPES = [
    { value: 'auth', label: 'Authentication', description: 'Vérifie si l\'utilisateur est connecté' },
    { value: 'role', label: 'Role', description: 'Vérifie le rôle de l\'utilisateur' },
    { value: 'subscription', label: 'Subscription', description: 'Vérifie le plan d\'abonnement' },
    { value: 'feature', label: 'Feature', description: 'Vérifie l\'accès à une fonctionnalité' }
];
export const GuardsEditor = ({ guards, onChange, className = '' }) => {
    const addGuard = () => {
        const newGuards = [...guards, { type: 'auth' }];
        onChange(newGuards);
    };
    const removeGuard = (index) => {
        const newGuards = guards.filter((_, i) => i !== index);
        onChange(newGuards);
    };
    const updateGuard = (index, updates) => {
        const newGuards = [...guards];
        newGuards[index] = { ...newGuards[index], ...updates };
        // Reset condition when type changes
        if (updates.type && updates.type !== guards[index].type) {
            newGuards[index].condition = {};
        }
        onChange(newGuards);
    };
    const updateGuardCondition = (index, key, value) => {
        const newGuards = [...guards];
        newGuards[index].condition = { ...newGuards[index].condition, [key]: value };
        onChange(newGuards);
    };
    return (_jsxs("div", { className: `space-y-4 ${className}`, children: [_jsxs("div", { className: "flex justify-between items-center", children: [_jsxs("div", { children: [_jsx("h3", { className: "text-lg font-semibold", children: "Security Guards" }), _jsx("p", { className: "text-sm text-muted-foreground", children: "Configure security checks for this route" })] }), _jsxs(Button, { onClick: addGuard, size: "sm", variant: "outline", children: [_jsx(Plus, { className: "w-4 h-4 mr-2" }), "Add Guard"] })] }), guards.length === 0 ? (_jsx(Card, { children: _jsx(CardContent, { className: "flex items-center justify-center py-8", children: _jsxs("div", { className: "text-center text-muted-foreground", children: [_jsx("p", { className: "text-sm", children: "No security guards configured" }), _jsx("p", { className: "text-xs mt-1", children: "Add guards to secure this route" })] }) }) })) : (_jsx("div", { className: "space-y-3", children: guards.map((guard, index) => (_jsxs(Card, { children: [_jsx(CardHeader, { className: "pb-3", children: _jsxs("div", { className: "flex items-center justify-between", children: [_jsxs(CardTitle, { className: "text-base", children: ["Guard #", index + 1] }), _jsx(Button, { onClick: () => removeGuard(index), size: "sm", variant: "outline", className: "text-destructive hover:text-destructive", children: _jsx(Trash2, { className: "w-4 h-4" }) })] }) }), _jsxs(CardContent, { className: "space-y-4", children: [_jsxs("div", { children: [_jsx(Label, { htmlFor: `guard-type-${index}`, children: "Guard Type" }), _jsxs(Select, { value: guard.type, onValueChange: (value) => updateGuard(index, { type: value }), children: [_jsx(SelectTrigger, { id: `guard-type-${index}`, children: _jsx(SelectValue, {}) }), _jsx(SelectContent, { children: GUARD_TYPES.map(type => (_jsx(SelectItem, { value: type.value, children: _jsxs("div", { children: [_jsx("div", { className: "font-medium", children: type.label }), _jsx("div", { className: "text-xs text-muted-foreground", children: type.description })] }) }, type.value))) })] })] }), guard.type === 'role' && (_jsxs("div", { children: [_jsx(Label, { htmlFor: `role-${index}`, children: "Required Role" }), _jsx(Input, { id: `role-${index}`, value: guard.condition?.role || '', onChange: (e) => updateGuardCondition(index, 'role', e.target.value), placeholder: "admin" })] })), guard.type === 'subscription' && (_jsxs("div", { children: [_jsx(Label, { htmlFor: `plan-${index}`, children: "Required Plan" }), _jsx(Input, { id: `plan-${index}`, value: guard.condition?.plan || '', onChange: (e) => updateGuardCondition(index, 'plan', e.target.value), placeholder: "premium" })] })), guard.type === 'feature' && (_jsxs("div", { children: [_jsx(Label, { htmlFor: `feature-${index}`, children: "Required Feature" }), _jsx(Input, { id: `feature-${index}`, value: guard.condition?.feature || '', onChange: (e) => updateGuardCondition(index, 'feature', e.target.value), placeholder: "advanced_analytics" })] }))] })] }, index))) }))] }));
};
