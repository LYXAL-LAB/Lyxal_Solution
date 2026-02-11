import { jsxs as _jsxs, jsx as _jsx, Fragment as _Fragment } from "react/jsx-runtime";
import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { useStudioRoutes } from '@/lib/studio/hooks/useStudioRoutes';
import { RouteService } from '@/services/RouteService';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { RoutesTable } from './components/RoutesTable';
import { SearchFilters } from './components/SearchFilters';
import { BulkActions } from './components/BulkActions';
import { Plus, BarChart3, CheckCircle, AlertCircle, Clock, XCircle, Zap, Menu, Home, Settings, Users, Database, ChevronLeft, ChevronRight } from 'lucide-react';
export const RoutesDashboard = () => {
    const { routes, loading, error, refetch } = useStudioRoutes();
    const [selectedRoutes, setSelectedRoutes] = useState([]);
    const [filters, setFilters] = useState({
        search: '',
        status: 'all',
        permission: 'all'
    });
    const [notification, setNotification] = useState(null);
    const [refreshMode, setRefreshMode] = useState('manual');
    const [autoRefreshInterval, setAutoRefreshInterval] = useState(null);
    const [sidebarOpen, setSidebarOpen] = useState(window.innerWidth >= 768); // Ouvert par défaut sur desktop
    // Fonction pour afficher les notifications
    const showNotification = (type, message) => {
        setNotification({ type, message, show: true });
        setTimeout(() => setNotification(null), 5000);
    };
    // Gestion de l'auto-refresh
    const getRefreshInterval = (mode) => {
        switch (mode) {
            case '30s': return 30 * 1000;
            case '1min': return 60 * 1000;
            case '5min': return 5 * 60 * 1000;
            default: return 0;
        }
    };
    const handleRefreshModeChange = (newMode) => {
        setRefreshMode(newMode);
        // Nettoyer l'ancien interval
        if (autoRefreshInterval) {
            clearInterval(autoRefreshInterval);
            setAutoRefreshInterval(null);
        }
        // Démarrer le nouvel interval si nécessaire
        if (newMode !== 'manual') {
            const interval = getRefreshInterval(newMode);
            const newInterval = setInterval(() => {
                refetch();
            }, interval);
            setAutoRefreshInterval(newInterval);
            // Notification pour informer l'utilisateur
            const intervalText = newMode === '30s' ? '30 seconds' :
                newMode === '1min' ? '1 minute' :
                    '5 minutes';
            showNotification('info', `Live refresh enabled - auto-refreshing every ${intervalText}`);
        }
        else {
            showNotification('info', 'Switched to manual refresh mode');
        }
    };
    // Nettoyer l'interval au démontage du composant
    React.useEffect(() => {
        return () => {
            if (autoRefreshInterval) {
                clearInterval(autoRefreshInterval);
            }
        };
    }, [autoRefreshInterval]);
    // Statistiques
    const stats = {
        total: routes.length,
        active: routes.filter(r => r.status === 'active').length,
        draft: routes.filter(r => r.status === 'draft').length,
        inactive: routes.filter(r => r.status === 'inactive').length,
        deprecated: routes.filter(r => r.status === 'deprecated').length,
    };
    // Filtrage des routes
    const filteredRoutes = routes.filter(route => {
        const matchesSearch = route.identity.value.toLowerCase().includes(filters.search.toLowerCase()) ||
            route.identity.slug.toLowerCase().includes(filters.search.toLowerCase());
        const matchesStatus = filters.status === 'all' || route.status === filters.status;
        const matchesPermission = filters.permission === 'all' ||
            route.permissions.includes(filters.permission);
        return matchesSearch && matchesStatus && matchesPermission;
    });
    // Gestion des actions groupées
    const handleBulkStatusChange = async (routeIds, status) => {
        try {
            await Promise.all(routeIds.map(id => RouteService.setRouteStatus(id, status)));
            await refetch();
            setSelectedRoutes([]);
            showNotification('success', `${routeIds.length} route${routeIds.length > 1 ? 's' : ''} ${status === 'active' ? 'activated' : status === 'inactive' ? 'deactivated' : status}`);
        }
        catch (error) {
            console.error('Failed to update route status:', error);
            showNotification('error', 'Failed to update route status. Please try again.');
        }
    };
    const handleBulkDelete = async (routeIds) => {
        try {
            await Promise.all(routeIds.map(id => RouteService.deleteRoute(id)));
            await refetch();
            setSelectedRoutes([]);
            showNotification('success', `${routeIds.length} route${routeIds.length > 1 ? 's' : ''} deleted successfully`);
        }
        catch (error) {
            console.error('Failed to delete routes:', error);
            showNotification('error', 'Failed to delete routes. Please try again.');
        }
    };
    if (error) {
        return (_jsx("div", { className: "p-6", children: _jsxs("div", { className: "bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded", children: ["Error loading routes: ", error] }) }));
    }
    return (_jsxs("div", { className: "min-h-screen bg-gray-50", children: [_jsxs("aside", { className: `fixed left-0 top-0 z-40 h-screen transition-all duration-300 ease-in-out ${sidebarOpen ? 'w-64' : 'w-16'} bg-white border-r border-gray-200 shadow-lg ${sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'} md:relative md:translate-x-0`, children: [_jsxs("div", { className: "flex items-center justify-between p-4 border-b border-gray-200", children: [_jsxs("div", { className: `flex items-center space-x-2 transition-opacity duration-200 ${sidebarOpen ? 'opacity-100' : 'opacity-0'}`, children: [_jsx("div", { className: "w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center", children: _jsx(Database, { className: "w-5 h-5 text-white" }) }), _jsx("span", { className: "font-semibold text-gray-900", children: "LYXAL Studio" })] }), _jsx("button", { onClick: () => setSidebarOpen(!sidebarOpen), className: "p-1.5 rounded-lg hover:bg-gray-100 transition-colors", children: sidebarOpen ? (_jsx(ChevronLeft, { className: "w-5 h-5 text-gray-600" })) : (_jsx(ChevronRight, { className: "w-5 h-5 text-gray-600" })) })] }), _jsxs("nav", { className: "p-4 space-y-2", children: [_jsxs(Link, { to: "/", className: `flex items-center space-x-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-all duration-200 ${sidebarOpen ? 'justify-start' : 'justify-center'}`, children: [_jsx(Home, { className: "w-5 h-5 text-gray-600" }), _jsx("span", { className: `transition-opacity duration-200 ${sidebarOpen ? 'opacity-100' : 'opacity-0'}`, children: "Dashboard" })] }), _jsxs(Link, { to: "/admin/routes", className: `flex items-center space-x-3 px-3 py-2 rounded-lg bg-blue-50 border border-blue-200 transition-all duration-200 ${sidebarOpen ? 'justify-start' : 'justify-center'}`, children: [_jsx(BarChart3, { className: "w-5 h-5 text-blue-600" }), _jsx("span", { className: `transition-opacity duration-200 ${sidebarOpen ? 'opacity-100' : 'opacity-0'}`, children: "Routes" })] }), _jsxs(Link, { to: "#", className: `flex items-center space-x-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-all duration-200 ${sidebarOpen ? 'justify-start' : 'justify-center'}`, children: [_jsx(Users, { className: "w-5 h-5 text-gray-600" }), _jsx("span", { className: `transition-opacity duration-200 ${sidebarOpen ? 'opacity-100' : 'opacity-0'}`, children: "Users" })] }), _jsxs(Link, { to: "#", className: `flex items-center space-x-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-all duration-200 ${sidebarOpen ? 'justify-start' : 'justify-center'}`, children: [_jsx(Settings, { className: "w-5 h-5 text-gray-600" }), _jsx("span", { className: `transition-opacity duration-200 ${sidebarOpen ? 'opacity-100' : 'opacity-0'}`, children: "Settings" })] })] })] }), sidebarOpen && (_jsx("div", { className: "fixed inset-0 z-30 bg-black bg-opacity-50 md:hidden", onClick: () => setSidebarOpen(false) })), _jsx("header", { className: `fixed top-0 z-50 bg-white border-b border-gray-200 shadow-sm transition-all duration-300 md:${sidebarOpen ? 'left-64 right-0' : 'left-16 right-0'} left-0 right-0`, children: _jsx("div", { className: "px-6 py-4", children: _jsxs("div", { className: "flex items-center justify-between", children: [_jsx("button", { onClick: () => setSidebarOpen(!sidebarOpen), className: "md:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors", children: _jsx(Menu, { className: "w-5 h-5 text-gray-600" }) }), _jsx("div", { className: "flex items-center space-x-4", children: _jsxs("div", { className: "flex items-center space-x-2", children: [_jsx("div", { className: "w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center", children: _jsx(BarChart3, { className: "w-5 h-5 text-white" }) }), _jsxs("div", { children: [_jsx("h1", { className: "text-xl font-bold text-gray-900", children: "Routes Management" }), _jsx("p", { className: "text-sm text-gray-600", children: "Studio Route Administration" })] })] }) }), _jsxs("div", { className: "flex items-center space-x-4", children: [_jsxs("div", { className: "flex items-center gap-2", children: [_jsx(Zap, { className: `w-4 h-4 ${refreshMode !== 'manual' ? 'text-green-500 animate-pulse' : 'text-gray-400'}` }), _jsxs(Select, { value: refreshMode, onValueChange: (value) => handleRefreshModeChange(value), children: [_jsx(SelectTrigger, { className: "w-40", children: _jsx(SelectValue, {}) }), _jsxs(SelectContent, { children: [_jsx(SelectItem, { value: "manual", children: _jsx("div", { className: "flex items-center gap-2", children: "Manual" }) }), _jsx(SelectItem, { value: "30s", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx("span", { className: "w-2 h-2 bg-green-500 rounded-full animate-pulse" }), "Live (30s)"] }) }), _jsx(SelectItem, { value: "1min", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx("span", { className: "w-2 h-2 bg-green-500 rounded-full animate-pulse" }), "Live (1min)"] }) }), _jsx(SelectItem, { value: "5min", children: _jsxs("div", { className: "flex items-center gap-2", children: [_jsx("span", { className: "w-2 h-2 bg-green-500 rounded-full animate-pulse" }), "Live (5min)"] }) })] })] })] }), _jsx(Button, { asChild: true, children: _jsxs(Link, { to: "/admin/routes/new", children: [_jsx(Plus, { className: "w-4 h-4 mr-2" }), "New Route"] }) })] })] }) }) }), _jsxs("main", { className: `pt-20 pb-16 px-6 transition-all duration-300 md:${sidebarOpen ? 'ml-64' : 'ml-16'} ml-0`, children: [notification?.show && (_jsx("div", { className: `p-4 rounded-lg border-2 transition-all duration-300 ${notification.type === 'success' ? 'bg-green-50 border-green-200 text-green-800' :
                            notification.type === 'error' ? 'bg-red-50 border-red-200 text-red-800' :
                                notification.type === 'warning' ? 'bg-yellow-50 border-yellow-200 text-yellow-800' :
                                    'bg-blue-50 border-blue-200 text-blue-800'}`, children: _jsxs("div", { className: "flex items-center", children: [notification.type === 'success' && _jsx(CheckCircle, { className: "w-5 h-5 mr-3" }), notification.type === 'error' && _jsx(XCircle, { className: "w-5 h-5 mr-3" }), notification.type === 'warning' && _jsx(AlertCircle, { className: "w-5 h-5 mr-3" }), notification.type === 'info' && _jsx(AlertCircle, { className: "w-5 h-5 mr-3" }), _jsx("span", { className: "font-medium", children: notification.message }), _jsx("button", { onClick: () => setNotification(null), className: "ml-auto text-gray-400 hover:text-gray-600", children: _jsx(XCircle, { className: "w-4 h-4" }) })] }) })), _jsxs("div", { className: "grid grid-cols-1 md:grid-cols-5 gap-4", children: [_jsxs(Card, { className: "border-2 border-gray-200 hover:border-gray-300 transition-colors", children: [_jsx(CardHeader, { className: "pb-2", children: _jsxs(CardTitle, { className: "text-sm font-medium flex items-center text-gray-700", children: [_jsx(BarChart3, { className: "w-4 h-4 mr-2" }), "Total Routes"] }) }), _jsxs(CardContent, { children: [_jsx("div", { className: "text-3xl font-bold text-gray-900", children: stats.total }), _jsx("p", { className: "text-xs text-gray-500 mt-1", children: "All registered routes" })] })] }), _jsxs(Card, { className: "border-2 border-green-200 hover:border-green-300 transition-colors", children: [_jsx(CardHeader, { className: "pb-2", children: _jsxs(CardTitle, { className: "text-sm font-medium flex items-center text-green-700", children: [_jsx(CheckCircle, { className: "w-4 h-4 mr-2" }), "Active"] }) }), _jsxs(CardContent, { children: [_jsx("div", { className: "text-3xl font-bold text-green-700", children: stats.active }), _jsx("p", { className: "text-xs text-green-600 mt-1", children: "Live and accessible" })] })] }), _jsxs(Card, { className: "border-2 border-yellow-200 hover:border-yellow-300 transition-colors", children: [_jsx(CardHeader, { className: "pb-2", children: _jsxs(CardTitle, { className: "text-sm font-medium flex items-center text-yellow-700", children: [_jsx(Clock, { className: "w-4 h-4 mr-2" }), "Draft"] }) }), _jsxs(CardContent, { children: [_jsx("div", { className: "text-3xl font-bold text-yellow-700", children: stats.draft }), _jsx("p", { className: "text-xs text-yellow-600 mt-1", children: "Work in progress" })] })] }), _jsxs(Card, { className: "border-2 border-red-200 hover:border-red-300 transition-colors", children: [_jsx(CardHeader, { className: "pb-2", children: _jsxs(CardTitle, { className: "text-sm font-medium flex items-center text-red-700", children: [_jsx(XCircle, { className: "w-4 h-4 mr-2" }), "Inactive"] }) }), _jsxs(CardContent, { children: [_jsx("div", { className: "text-3xl font-bold text-red-700", children: stats.inactive }), _jsx("p", { className: "text-xs text-red-600 mt-1", children: "Temporarily disabled" })] })] }), _jsxs(Card, { className: "border-2 border-gray-200 hover:border-gray-300 transition-colors", children: [_jsx(CardHeader, { className: "pb-2", children: _jsxs(CardTitle, { className: "text-sm font-medium flex items-center text-gray-700", children: [_jsx(AlertCircle, { className: "w-4 h-4 mr-2" }), "Deprecated"] }) }), _jsxs(CardContent, { children: [_jsx("div", { className: "text-3xl font-bold text-gray-700", children: stats.deprecated }), _jsx("p", { className: "text-xs text-gray-600 mt-1", children: "Legacy routes" })] })] })] }), _jsxs(Card, { children: [_jsx(CardHeader, { children: _jsx(CardTitle, { children: "Filters" }) }), _jsx(CardContent, { children: _jsx(SearchFilters, { filters: filters, onFiltersChange: setFilters, totalResults: filteredRoutes.length }) })] }), selectedRoutes.length > 0 && (_jsx(BulkActions, { selectedRoutes: selectedRoutes, onStatusChange: handleBulkStatusChange, onDelete: handleBulkDelete, onClearSelection: () => setSelectedRoutes([]) })), _jsx(RoutesTable, { routes: filteredRoutes, loading: loading, selectedRoutes: selectedRoutes, onSelectionChange: setSelectedRoutes, onRouteUpdate: refetch })] }), _jsx("footer", { className: `fixed bottom-0 z-50 bg-white border-t border-gray-200 shadow-sm transition-all duration-300 md:${sidebarOpen ? 'left-64 right-0' : 'left-16 right-0'} left-0 right-0`, children: _jsx("div", { className: "px-6 py-3", children: _jsxs("div", { className: "flex items-center justify-between text-sm text-gray-600", children: [_jsxs("div", { className: "flex items-center space-x-4", children: [_jsx("span", { children: "Routes Management System" }), _jsx("span", { children: "\u2022" }), _jsxs("span", { children: [routes.length, " routes loaded"] }), refreshMode !== 'manual' && (_jsxs(_Fragment, { children: [_jsx("span", { children: "\u2022" }), _jsx("span", { className: "text-green-600 font-medium", children: "Live mode active" })] }))] }), _jsxs("div", { className: "flex items-center space-x-4", children: [_jsx("span", { children: "LYXAL Studio v1.0" }), _jsx("span", { children: "\u2022" }), _jsx("span", { children: "\u00A9 2024 LYXAL LAB" })] })] }) }) })] }));
};
