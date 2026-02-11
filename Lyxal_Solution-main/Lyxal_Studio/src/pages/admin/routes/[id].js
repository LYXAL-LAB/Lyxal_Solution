import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useParams, useNavigate } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { RouteService } from '@/services/RouteService';
import { RouteForm } from './components/RouteForm';
import { Button } from '@/components/ui/button';
import { ArrowLeft, Loader2 } from 'lucide-react';
export const RouteDetails = () => {
    const { id } = useParams();
    const navigate = useNavigate();
    const [route, setRoute] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    useEffect(() => {
        const loadRoute = async () => {
            if (!id)
                return;
            try {
                setLoading(true);
                const routeData = await RouteService.getRouteById(id);
                setRoute(routeData);
            }
            catch (err) {
                setError(err instanceof Error ? err.message : 'Failed to load route');
            }
            finally {
                setLoading(false);
            }
        };
        loadRoute();
    }, [id]);
    if (loading) {
        return (_jsx("div", { className: "min-h-screen bg-gray-50 flex items-center justify-center", children: _jsxs("div", { className: "flex items-center space-x-2", children: [_jsx(Loader2, { className: "w-6 h-6 animate-spin" }), _jsx("span", { children: "Loading route..." })] }) }));
    }
    if (error || !route) {
        return (_jsx("div", { className: "min-h-screen bg-gray-50 p-6", children: _jsxs("div", { className: "max-w-2xl mx-auto", children: [_jsxs(Button, { variant: "ghost", onClick: () => navigate('/admin/routes'), className: "mb-4", children: [_jsx(ArrowLeft, { className: "w-4 h-4 mr-2" }), "Back to Routes"] }), _jsx("div", { className: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded", children: error || 'Route not found' })] }) }));
    }
    return (_jsx("div", { className: "min-h-screen bg-gray-50", children: _jsx(RouteForm, { route: route }) }));
};
