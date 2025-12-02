import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { RouteService } from '@/services/RouteService';
import { StatusBadge } from './StatusBadge';
import { Edit, Trash2, Eye, Copy, GitBranch } from 'lucide-react';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger, } from '@/components/ui/alert-dialog';
export const RoutesTable = ({ routes, loading, selectedRoutes, onSelectionChange, onRouteUpdate }) => {
    const handleSelectAll = (checked) => {
        if (checked) {
            onSelectionChange(routes.map(route => route.id));
        }
        else {
            onSelectionChange([]);
        }
    };
    const handleSelectRoute = (routeId, checked) => {
        if (checked) {
            onSelectionChange([...selectedRoutes, routeId]);
        }
        else {
            onSelectionChange(selectedRoutes.filter(id => id !== routeId));
        }
    };
    const handleDeleteRoute = async (routeId) => {
        try {
            await RouteService.deleteRoute(routeId);
            onRouteUpdate();
        }
        catch (error) {
            console.error('Failed to delete route:', error);
        }
    };
    const handleCopyPath = async (path) => {
        try {
            await navigator.clipboard.writeText(path);
            // TODO: Add toast notification
        }
        catch (error) {
            console.error('Failed to copy path:', error);
        }
    };
    const handleDuplicateRoute = async (route) => {
        try {
            // Create a copy with modified identity
            const duplicatedRoute = {
                ...route,
                identity: {
                    ...route.identity,
                    value: `${route.identity.value}-copy`,
                    slug: `${route.identity.slug}-copy`,
                    code: `${route.identity.code}_copy`
                },
                status: 'draft'
            };
            // Remove id to create new route
            const { id, ...routeData } = duplicatedRoute;
            await RouteService.createRoute(routeData);
            onRouteUpdate();
            // TODO: Add success notification
        }
        catch (error) {
            console.error('Failed to duplicate route:', error);
            // TODO: Add error notification
        }
    };
    if (loading) {
        return (_jsxs("div", { className: "flex items-center justify-center p-8", children: [_jsx("div", { className: "animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900" }), _jsx("span", { className: "ml-2", children: "Loading routes..." })] }));
    }
    if (routes.length === 0) {
        return (_jsxs("div", { className: "text-center py-12", children: [_jsx("div", { className: "text-gray-500 mb-4", children: _jsx("svg", { className: "mx-auto h-12 w-12", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 2, d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" }) }) }), _jsx("h3", { className: "text-lg font-medium text-gray-900 mb-2", children: "No routes found" }), _jsx("p", { className: "text-gray-500 mb-4", children: "Get started by creating your first route." }), _jsx(Button, { asChild: true, children: _jsx(Link, { to: "/admin/routes/new", children: "Create Route" }) })] }));
    }
    return (_jsx("div", { className: "bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden", children: _jsx("div", { className: "overflow-x-auto", children: _jsxs("table", { className: "min-w-full divide-y divide-gray-200", children: [_jsx("thead", { className: "bg-gray-50", children: _jsxs("tr", { children: [_jsx("th", { scope: "col", className: "relative w-12 px-6 sm:w-16 sm:px-8", children: _jsx(Checkbox, { checked: selectedRoutes.length === routes.length && routes.length > 0, onCheckedChange: handleSelectAll, "aria-label": "Select all routes" }) }), _jsx("th", { scope: "col", className: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider", children: "Route" }), _jsx("th", { scope: "col", className: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider", children: "Status" }), _jsx("th", { scope: "col", className: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider", children: "Permissions" }), _jsx("th", { scope: "col", className: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider", children: "Guards" }), _jsx("th", { scope: "col", className: "relative px-6 py-3", children: _jsx("span", { className: "sr-only", children: "Actions" }) })] }) }), _jsx("tbody", { className: "bg-white divide-y divide-gray-200", children: routes.map((route) => (_jsxs("tr", { className: "hover:bg-gray-50", children: [_jsx("td", { className: "relative w-12 px-6 sm:w-16 sm:px-8", children: _jsx(Checkbox, { checked: selectedRoutes.includes(route.id), onCheckedChange: (checked) => handleSelectRoute(route.id, checked), "aria-label": `Select route ${route.identity.value}` }) }), _jsx("td", { className: "px-6 py-4 whitespace-nowrap", children: _jsx("div", { className: "flex items-center", children: _jsxs("div", { children: [_jsx("div", { className: "text-sm font-medium text-gray-900 font-mono", children: route.identity.value }), _jsx("div", { className: "text-sm text-gray-500", children: route.metadata?.title_i18n || route.identity.slug })] }) }) }), _jsx("td", { className: "px-6 py-4 whitespace-nowrap", children: _jsx(StatusBadge, { status: route.status }) }), _jsx("td", { className: "px-6 py-4 whitespace-nowrap", children: _jsxs("div", { className: "flex flex-wrap gap-1", children: [route.permissions.slice(0, 2).map((permission) => (_jsx(Badge, { variant: "secondary", className: "text-xs", children: permission }, permission))), route.permissions.length > 2 && (_jsxs(Badge, { variant: "outline", className: "text-xs", children: ["+", route.permissions.length - 2] }))] }) }), _jsx("td", { className: "px-6 py-4 whitespace-nowrap", children: _jsx("div", { className: "text-sm text-gray-900", children: route.guards && route.guards.length > 0 ? (_jsxs("span", { className: "text-green-600 font-medium", children: [route.guards.length, " guard", route.guards.length > 1 ? 's' : ''] })) : (_jsx("span", { className: "text-gray-400", children: "None" })) }) }), _jsx("td", { className: "px-6 py-4 whitespace-nowrap text-right text-sm font-medium", children: _jsxs("div", { className: "flex items-center justify-end space-x-1", children: [_jsxs(Button, { variant: "ghost", size: "sm", onClick: () => handleCopyPath(route.identity.value), title: "Copy path", children: [_jsx(Copy, { className: "w-4 h-4" }), _jsx("span", { className: "sr-only", children: "Copy path" })] }), _jsxs(Button, { variant: "ghost", size: "sm", onClick: () => handleDuplicateRoute(route), title: "Duplicate route", children: [_jsx(GitBranch, { className: "w-4 h-4" }), _jsx("span", { className: "sr-only", children: "Duplicate" })] }), _jsx(Button, { asChild: true, variant: "ghost", size: "sm", children: _jsxs(Link, { to: `/admin/routes/${route.id}`, children: [_jsx(Eye, { className: "w-4 h-4" }), _jsx("span", { className: "sr-only", children: "View" })] }) }), _jsx(Button, { asChild: true, variant: "ghost", size: "sm", children: _jsxs(Link, { to: `/admin/routes/${route.id}/edit`, children: [_jsx(Edit, { className: "w-4 h-4" }), _jsx("span", { className: "sr-only", children: "Edit" })] }) }), _jsxs(AlertDialog, { children: [_jsx(AlertDialogTrigger, { asChild: true, children: _jsxs(Button, { variant: "ghost", size: "sm", className: "text-red-600 hover:text-red-900", children: [_jsx(Trash2, { className: "w-4 h-4" }), _jsx("span", { className: "sr-only", children: "Delete" })] }) }), _jsxs(AlertDialogContent, { children: [_jsxs(AlertDialogHeader, { children: [_jsx(AlertDialogTitle, { children: "Delete Route" }), _jsxs(AlertDialogDescription, { children: ["Are you sure you want to delete the route \"", route.identity.value, "\"? This action cannot be undone."] })] }), _jsxs(AlertDialogFooter, { children: [_jsx(AlertDialogCancel, { children: "Cancel" }), _jsx(AlertDialogAction, { onClick: () => handleDeleteRoute(route.id), className: "bg-red-600 hover:bg-red-700", children: "Delete" })] })] })] })] }) })] }, route.id))) })] }) }) }));
};
