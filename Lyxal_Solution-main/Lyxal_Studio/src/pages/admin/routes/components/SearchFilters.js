import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Card, CardContent } from '@/components/ui/card';
import { Search, X } from 'lucide-react';
export const SearchFilters = ({ filters, onFiltersChange, totalResults, className = '' }) => {
    const hasActiveFilters = filters.search || filters.status !== 'all' || filters.permission !== 'all';
    const handleSearchChange = (search) => {
        onFiltersChange({ ...filters, search });
    };
    const handleStatusChange = (status) => {
        onFiltersChange({ ...filters, status });
    };
    const handlePermissionChange = (permission) => {
        onFiltersChange({ ...filters, permission });
    };
    const handleClearFilters = () => {
        onFiltersChange({ search: '', status: 'all', permission: 'all' });
    };
    return (_jsx(Card, { className: className, children: _jsxs(CardContent, { className: "pt-6", children: [_jsxs("div", { className: "grid grid-cols-1 md:grid-cols-4 gap-4", children: [_jsxs("div", { className: "md:col-span-2", children: [_jsx(Label, { htmlFor: "search", className: "sr-only", children: "Search routes" }), _jsxs("div", { className: "relative", children: [_jsx(Search, { className: "absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" }), _jsx(Input, { id: "search", placeholder: "Search by path, slug, or page code...", value: filters.search, onChange: (e) => handleSearchChange(e.target.value), className: "pl-10" })] })] }), _jsxs("div", { children: [_jsx(Label, { htmlFor: "status-filter", className: "sr-only", children: "Filter by status" }), _jsxs(Select, { value: filters.status, onValueChange: handleStatusChange, children: [_jsx(SelectTrigger, { id: "status-filter", children: _jsx(SelectValue, { placeholder: "All statuses" }) }), _jsxs(SelectContent, { children: [_jsx(SelectItem, { value: "all", children: "All Statuses" }), _jsx(SelectItem, { value: "active", children: "Active" }), _jsx(SelectItem, { value: "inactive", children: "Inactive" }), _jsx(SelectItem, { value: "draft", children: "Draft" }), _jsx(SelectItem, { value: "deprecated", children: "Deprecated" })] })] })] }), _jsxs("div", { children: [_jsx(Label, { htmlFor: "permission-filter", className: "sr-only", children: "Filter by permission" }), _jsxs(Select, { value: filters.permission, onValueChange: handlePermissionChange, children: [_jsx(SelectTrigger, { id: "permission-filter", children: _jsx(SelectValue, { placeholder: "All permissions" }) }), _jsxs(SelectContent, { children: [_jsx(SelectItem, { value: "all", children: "All Permissions" }), _jsx(SelectItem, { value: "guest", children: "Guest" }), _jsx(SelectItem, { value: "authenticated", children: "Authenticated" }), _jsx(SelectItem, { value: "admin", children: "Admin" }), _jsx(SelectItem, { value: "manager", children: "Manager" })] })] })] })] }), _jsxs("div", { className: "flex justify-between items-center mt-4 pt-4 border-t", children: [_jsxs("div", { className: "text-sm text-muted-foreground", children: [totalResults, " route", totalResults !== 1 ? 's' : '', " found"] }), hasActiveFilters && (_jsxs("div", { className: "flex gap-2", children: [_jsx("div", { className: "text-xs text-muted-foreground", children: "Filters active" }), _jsxs(Button, { variant: "outline", size: "sm", onClick: handleClearFilters, children: [_jsx(X, { className: "w-4 h-4 mr-1" }), "Clear"] })] }))] })] }) }));
};
