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
import { Plus, RefreshCw, BarChart3, CheckCircle, AlertCircle, Clock, XCircle, Zap, Menu, X, Home, Settings, Users, Database, ChevronLeft, ChevronRight } from 'lucide-react';

export const RoutesDashboard = () => {
  const { routes, loading, error, refetch } = useStudioRoutes();
  const [selectedRoutes, setSelectedRoutes] = useState<string[]>([]);
  const [filters, setFilters] = useState({
    search: '',
    status: 'all',
    permission: 'all'
  });
  const [notification, setNotification] = useState<{
    type: 'success' | 'error' | 'warning' | 'info';
    message: string;
    show: boolean;
  } | null>(null);

  const [refreshMode, setRefreshMode] = useState<'manual' | '30s' | '1min' | '5min'>('manual');
  const [autoRefreshInterval, setAutoRefreshInterval] = useState<NodeJS.Timeout | null>(null);
  const [sidebarOpen, setSidebarOpen] = useState(window.innerWidth >= 768); // Ouvert par défaut sur desktop

  // Fonction pour afficher les notifications
  const showNotification = (type: 'success' | 'error' | 'warning' | 'info', message: string) => {
    setNotification({ type, message, show: true });
    setTimeout(() => setNotification(null), 5000);
  };

  // Gestion de l'auto-refresh
  const getRefreshInterval = (mode: string): number => {
    switch (mode) {
      case '30s': return 30 * 1000;
      case '1min': return 60 * 1000;
      case '5min': return 5 * 60 * 1000;
      default: return 0;
    }
  };

  const handleRefreshModeChange = (newMode: 'manual' | '30s' | '1min' | '5min') => {
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
    } else {
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
                             (route.permissions as string[]).includes(filters.permission);

    return matchesSearch && matchesStatus && matchesPermission;
  });

  // Gestion des actions groupées
  const handleBulkStatusChange = async (routeIds: string[], status: any) => {
    try {
      await Promise.all(routeIds.map(id => RouteService.setRouteStatus(id, status)));
      await refetch();
      setSelectedRoutes([]);
      showNotification('success', `${routeIds.length} route${routeIds.length > 1 ? 's' : ''} ${status === 'active' ? 'activated' : status === 'inactive' ? 'deactivated' : status}`);
    } catch (error) {
      console.error('Failed to update route status:', error);
      showNotification('error', 'Failed to update route status. Please try again.');
    }
  };

  const handleBulkDelete = async (routeIds: string[]) => {
    try {
      await Promise.all(routeIds.map(id => RouteService.deleteRoute(id)));
      await refetch();
      setSelectedRoutes([]);
      showNotification('success', `${routeIds.length} route${routeIds.length > 1 ? 's' : ''} deleted successfully`);
    } catch (error) {
      console.error('Failed to delete routes:', error);
      showNotification('error', 'Failed to delete routes. Please try again.');
    }
  };

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          Error loading routes: {error}
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 relative">
      {/* Sidebar */}
      <aside className={`fixed left-0 top-0 z-40 h-screen transition-all duration-300 ease-in-out ${
        sidebarOpen ? 'w-64' : 'w-16'
      } bg-white border-r border-gray-200 shadow-lg ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
      } md:relative md:translate-x-0`}>
        {/* Sidebar Header */}
        <div className="flex items-center justify-between p-4 border-b border-gray-200">
          <div className={`flex items-center space-x-2 transition-opacity duration-200 ${
            sidebarOpen ? 'opacity-100' : 'opacity-0'
          }`}>
            <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
              <Database className="w-5 h-5 text-white" />
            </div>
            <span className="font-semibold text-gray-900">LYXAL Studio</span>
          </div>
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-1.5 rounded-lg hover:bg-gray-100 transition-colors"
          >
            {sidebarOpen ? (
              <ChevronLeft className="w-5 h-5 text-gray-600" />
            ) : (
              <ChevronRight className="w-5 h-5 text-gray-600" />
            )}
          </button>
        </div>

        {/* Navigation */}
        <nav className="p-4 space-y-2">
          <Link
            to="/"
            className={`flex items-center space-x-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-all duration-200 ${
              sidebarOpen ? 'justify-start' : 'justify-center'
            }`}
          >
            <Home className="w-5 h-5 text-gray-600" />
            <span className={`transition-opacity duration-200 ${
              sidebarOpen ? 'opacity-100' : 'opacity-0'
            }`}>
              Dashboard
            </span>
          </Link>

          <Link
            to="/admin/routes"
            className={`flex items-center space-x-3 px-3 py-2 rounded-lg bg-blue-50 border border-blue-200 transition-all duration-200 ${
              sidebarOpen ? 'justify-start' : 'justify-center'
            }`}
          >
            <BarChart3 className="w-5 h-5 text-blue-600" />
            <span className={`transition-opacity duration-200 ${
              sidebarOpen ? 'opacity-100' : 'opacity-0'
            }`}>
              Routes
            </span>
          </Link>

          <Link
            to="#"
            className={`flex items-center space-x-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-all duration-200 ${
              sidebarOpen ? 'justify-start' : 'justify-center'
            }`}
          >
            <Users className="w-5 h-5 text-gray-600" />
            <span className={`transition-opacity duration-200 ${
              sidebarOpen ? 'opacity-100' : 'opacity-0'
            }`}>
              Users
            </span>
          </Link>

          <Link
            to="#"
            className={`flex items-center space-x-3 px-3 py-2 rounded-lg hover:bg-gray-100 transition-all duration-200 ${
              sidebarOpen ? 'justify-start' : 'justify-center'
            }`}
          >
            <Settings className="w-5 h-5 text-gray-600" />
            <span className={`transition-opacity duration-200 ${
              sidebarOpen ? 'opacity-100' : 'opacity-0'
            }`}>
              Settings
            </span>
          </Link>
        </nav>
      </aside>

      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-30 bg-black bg-opacity-50 md:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Fixed Header */}
      <header className={`fixed top-0 z-50 bg-white border-b border-gray-200 shadow-sm h-16 transition-all duration-300 md:${
        sidebarOpen ? 'left-64 right-0' : 'left-16 right-0'
      } left-0 right-0`}>
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            {/* Mobile menu button */}
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="md:hidden p-2 rounded-lg hover:bg-gray-100 transition-colors"
            >
              <Menu className="w-5 h-5 text-gray-600" />
            </button>

            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2">
                <div className="w-8 h-8 bg-blue-600 rounded-lg flex items-center justify-center">
                  <BarChart3 className="w-5 h-5 text-white" />
                </div>
                <div>
                  <h1 className="text-xl font-bold text-gray-900">Routes Management</h1>
                  <p className="text-sm text-gray-600">Studio Route Administration</p>
                </div>
              </div>
            </div>

            {/* Header Actions */}
            <div className="flex items-center space-x-4">
              <div className="flex items-center gap-2">
                <Zap className={`w-4 h-4 ${refreshMode !== 'manual' ? 'text-green-500 animate-pulse' : 'text-gray-400'}`} />
                <Select value={refreshMode} onValueChange={(value: 'manual' | '30s' | '1min' | '5min') => handleRefreshModeChange(value)}>
                  <SelectTrigger className="w-40">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="manual">
                      <div className="flex items-center gap-2">
                        Manual
                      </div>
                    </SelectItem>
                    <SelectItem value="30s">
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                        Live (30s)
                      </div>
                    </SelectItem>
                    <SelectItem value="1min">
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                        Live (1min)
                      </div>
                    </SelectItem>
                    <SelectItem value="5min">
                      <div className="flex items-center gap-2">
                        <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
                        Live (5min)
                      </div>
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <Button asChild>
                <Link to="/admin/routes/new">
                  <Plus className="w-4 h-4 mr-2" />
                  New Route
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content - takes full height between header and footer */}
      <main className={`absolute top-16 bottom-12 transition-all duration-300 md:${
        sidebarOpen ? 'left-64' : 'left-16'
      } left-0 right-0 px-6 py-6 flex flex-col`}>
        {/* Notifications - fixed at top */}
        {notification?.show && (
          <div className={`p-4 rounded-lg border-2 transition-all duration-300 mb-6 ${
            notification.type === 'success' ? 'bg-green-50 border-green-200 text-green-800' :
            notification.type === 'error' ? 'bg-red-50 border-red-200 text-red-800' :
            notification.type === 'warning' ? 'bg-yellow-50 border-yellow-200 text-yellow-800' :
            'bg-blue-50 border-blue-200 text-blue-800'
          }`}>
            <div className="flex items-center">
              {notification.type === 'success' && <CheckCircle className="w-5 h-5 mr-3" />}
              {notification.type === 'error' && <XCircle className="w-5 h-5 mr-3" />}
              {notification.type === 'warning' && <AlertCircle className="w-5 h-5 mr-3" />}
              {notification.type === 'info' && <AlertCircle className="w-5 h-5 mr-3" />}
              <span className="font-medium">{notification.message}</span>
              <button
                onClick={() => setNotification(null)}
                className="ml-auto text-gray-400 hover:text-gray-600"
              >
                <XCircle className="w-4 h-4" />
              </button>
            </div>
          </div>
        )}

        {/* Statistics Cards Section */}
        <div className="mb-8">
          <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
        <Card className="border-2 border-gray-200 hover:border-gray-300 transition-colors">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center text-gray-700">
              <BarChart3 className="w-4 h-4 mr-2" />
              Total Routes
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-900">{stats.total}</div>
            <p className="text-xs text-gray-500 mt-1">All registered routes</p>
          </CardContent>
        </Card>

        <Card className="border-2 border-green-200 hover:border-green-300 transition-colors">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center text-green-700">
              <CheckCircle className="w-4 h-4 mr-2" />
              Active
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-green-700">{stats.active}</div>
            <p className="text-xs text-green-600 mt-1">Live and accessible</p>
          </CardContent>
        </Card>

        <Card className="border-2 border-yellow-200 hover:border-yellow-300 transition-colors">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center text-yellow-700">
              <Clock className="w-4 h-4 mr-2" />
              Draft
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-yellow-700">{stats.draft}</div>
            <p className="text-xs text-yellow-600 mt-1">Work in progress</p>
          </CardContent>
        </Card>

        <Card className="border-2 border-red-200 hover:border-red-300 transition-colors">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center text-red-700">
              <XCircle className="w-4 h-4 mr-2" />
              Inactive
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-red-700">{stats.inactive}</div>
            <p className="text-xs text-red-600 mt-1">Temporarily disabled</p>
          </CardContent>
        </Card>

        <Card className="border-2 border-gray-200 hover:border-gray-300 transition-colors">
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium flex items-center text-gray-700">
              <AlertCircle className="w-4 h-4 mr-2" />
              Deprecated
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-3xl font-bold text-gray-700">{stats.deprecated}</div>
            <p className="text-xs text-gray-600 mt-1">Legacy routes</p>
          </CardContent>
        </Card>
          </div>
        </div>

        {/* Filters and Table Section - takes remaining space */}
        <div className="flex-1 flex flex-col min-h-0 space-y-6 overflow-hidden">
          {/* Filters */}
          <Card>
        <CardHeader>
          <CardTitle>Filters</CardTitle>
        </CardHeader>
            <CardContent>
              <SearchFilters
                filters={filters}
                onFiltersChange={setFilters}
                totalResults={filteredRoutes.length}
              />
            </CardContent>
          </Card>

          {/* Bulk Actions */}
          {selectedRoutes.length > 0 && (
            <BulkActions
              selectedRoutes={selectedRoutes}
              onStatusChange={handleBulkStatusChange}
              onDelete={handleBulkDelete}
              onClearSelection={() => setSelectedRoutes([])}
            />
          )}

          {/* Routes Table - takes remaining space */}
          <div className="flex-1 min-h-0 overflow-hidden">
            <RoutesTable
              routes={filteredRoutes}
              loading={loading}
              selectedRoutes={selectedRoutes}
              onSelectionChange={setSelectedRoutes}
              onRouteUpdate={refetch}
            />
          </div>
        </div>

      </main>

      {/* Fixed Footer */}
      <footer className={`fixed bottom-0 z-50 bg-white border-t border-gray-200 shadow-sm h-12 transition-all duration-300 md:${
        sidebarOpen ? 'left-64 right-0' : 'left-16 right-0'
      } left-0 right-0`}>
        <div className="px-6 py-3">
          <div className="flex items-center justify-between text-sm text-gray-600">
            <div className="flex items-center space-x-4">
              <span>Routes Management System</span>
              <span>•</span>
              <span>{routes.length} routes loaded</span>
              {refreshMode !== 'manual' && (
                <>
                  <span>•</span>
                  <span className="text-green-600 font-medium">Live mode active</span>
                </>
              )}
            </div>
            <div className="flex items-center space-x-4">
              <span>LYXAL Studio v1.0</span>
              <span>•</span>
              <span>© 2024 LYXAL LAB</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
};
