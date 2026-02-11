import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { RouteService } from '@/services/RouteService';
import { GuardsEditor } from './GuardsEditor';
import { PermissionsSelect } from './PermissionsSelect';
import { ArrowLeft, Loader2 } from 'lucide-react';
export const RouteForm = ({ route }) => {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [formData, setFormData] = useState({
        path: route?.identity.value || '',
        slug: route?.identity.slug || '',
        code: route?.identity.code || '',
        pageCode: route?.page.identity.code || '',
        permissions: route?.permissions || ['guest'],
        status: route?.status || 'draft',
        title: route?.metadata?.title_i18n || '',
        description: route?.metadata?.description_i18n || '',
    });
    const [guards, setGuards] = useState(route?.guards || []);
    const handleSubmit = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            const routeData = {
                identity: {
                    value: formData.path,
                    slug: formData.slug,
                    code: formData.code,
                },
                page: { identity: { code: formData.pageCode } },
                permissions: formData.permissions,
                guards: guards,
                metadata: {
                    title_i18n: formData.title,
                    description_i18n: formData.description,
                },
                status: formData.status,
            };
            if (route) {
                // Update existing route
                await RouteService.updateRoute(route.id, { ...routeData, id: route.id });
            }
            else {
                // Create new route
                await RouteService.createRoute(routeData);
            }
            navigate('/admin/routes');
        }
        catch (err) {
            setError(err instanceof Error ? err.message : 'An error occurred');
        }
        finally {
            setLoading(false);
        }
    };
    const updatePermissions = (permission, checked) => {
        setFormData(prev => ({
            ...prev,
            permissions: checked
                ? [...prev.permissions, permission]
                : prev.permissions.filter(p => p !== permission)
        }));
    };
    return (_jsx("div", { className: "min-h-screen bg-gray-50", children: _jsxs("div", { className: "max-w-4xl mx-auto p-6", children: [_jsxs("div", { className: "mb-6", children: [_jsxs(Button, { variant: "ghost", onClick: () => navigate('/admin/routes'), className: "mb-4", children: [_jsx(ArrowLeft, { className: "w-4 h-4 mr-2" }), "Back to Routes"] }), _jsx("h1", { className: "text-3xl font-bold", children: route ? 'Edit Route' : 'Create New Route' }), _jsx("p", { className: "text-gray-600 mt-1", children: route ? 'Update the route configuration' : 'Define a new route for your application' })] }), _jsxs("form", { onSubmit: handleSubmit, className: "space-y-6", children: [_jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Basic Information" }) }), _jsx(CardContent, { className: "space-y-4", children: _jsxs("div", { className: "grid grid-cols-1 md:grid-cols-3 gap-4", children: [_jsxs("div", { children: [_jsx(Label, { htmlFor: "path", children: "Path *" }), _jsx(Input, { id: "path", value: formData.path, onChange: (e) => setFormData(prev => ({ ...prev, path: e.target.value })), placeholder: "/dashboard", required: true }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "The URL path for this route" })] }), _jsxs("div", { children: [_jsx(Label, { htmlFor: "slug", children: "Slug *" }), _jsx(Input, { id: "slug", value: formData.slug, onChange: (e) => setFormData(prev => ({ ...prev, slug: e.target.value })), placeholder: "dashboard", required: true }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "URL-friendly identifier" })] }), _jsxs("div", { children: [_jsx(Label, { htmlFor: "code", children: "Code *" }), _jsx(Input, { id: "code", value: formData.code, onChange: (e) => setFormData(prev => ({ ...prev, code: e.target.value })), placeholder: "dashboard", required: true }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "Unique code identifier" })] })] }) })] }), _jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Page Reference" }) }), _jsx(CardContent, { children: _jsxs("div", { children: [_jsx(Label, { htmlFor: "pageCode", children: "Page Code *" }), _jsx(Input, { id: "pageCode", value: formData.pageCode, onChange: (e) => setFormData(prev => ({ ...prev, pageCode: e.target.value })), placeholder: "dashboard_page", required: true }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "Reference to the studio page that will be rendered" })] }) })] }), _jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Permissions" }) }), _jsx(CardContent, { children: _jsx(PermissionsSelect, { selected: formData.permissions, onChange: (permissions) => setFormData(prev => ({ ...prev, permissions })) }) })] }), _jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Security Guards" }) }), _jsx(CardContent, { children: _jsx(GuardsEditor, { guards: guards, onChange: setGuards }) })] }), _jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Status" }) }), _jsx(CardContent, { children: _jsxs("div", { className: "max-w-xs", children: [_jsx(Label, { htmlFor: "status", children: "Route Status" }), _jsxs(Select, { value: formData.status, onValueChange: (value) => setFormData(prev => ({ ...prev, status: value })), children: [_jsx(SelectTrigger, { children: _jsx(SelectValue, {}) }), _jsxs(SelectContent, { children: [_jsx(SelectItem, { value: "draft", children: "Draft" }), _jsx(SelectItem, { value: "active", children: "Active" }), _jsx(SelectItem, { value: "inactive", children: "Inactive" }), _jsx(SelectItem, { value: "deprecated", children: "Deprecated" })] })] }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "Current status of the route" })] }) })] }), _jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Metadata (Optional)" }) }), _jsxs(CardContent, { className: "space-y-4", children: [_jsxs("div", { children: [_jsx(Label, { htmlFor: "title", children: "Title" }), _jsx(Input, { id: "title", value: formData.title, onChange: (e) => setFormData(prev => ({ ...prev, title: e.target.value })), placeholder: "Dashboard" }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "Display name for the route" })] }), _jsxs("div", { children: [_jsx(Label, { htmlFor: "description", children: "Description" }), _jsx(Textarea, { id: "description", value: formData.description, onChange: (e) => setFormData(prev => ({ ...prev, description: e.target.value })), placeholder: "Main dashboard page for administrators", rows: 3 }), _jsx("p", { className: "text-sm text-gray-500 mt-1", children: "Brief description of what this route does" })] })] })] }), error && (_jsx("div", { className: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded", children: error })), _jsxs("div", { className: "flex justify-end gap-2 pt-6 border-t", children: [_jsx(Button, { type: "button", variant: "outline", onClick: () => navigate('/admin/routes'), children: "Cancel" }), _jsxs(Button, { type: "submit", disabled: loading, children: [loading && _jsx(Loader2, { className: "w-4 h-4 mr-2 animate-spin" }), loading ? 'Saving...' : (route ? 'Update Route' : 'Create Route')] })] })] })] }) }));
};
