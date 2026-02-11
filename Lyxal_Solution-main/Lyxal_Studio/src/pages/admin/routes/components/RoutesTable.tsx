import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Badge } from '@/components/ui/badge';
import { RouteService } from '@/services/RouteService';
import { StudioRoute } from '@/lib/studio/types/route';
import { StatusBadge } from './StatusBadge';
import { Edit, Trash2, Eye, Copy, GitBranch } from 'lucide-react';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';

interface RoutesTableProps {
  routes: StudioRoute[];
  loading: boolean;
  selectedRoutes: string[];
  onSelectionChange: (selected: string[]) => void;
  onRouteUpdate: () => void;
}

export const RoutesTable = ({
  routes,
  loading,
  selectedRoutes,
  onSelectionChange,
  onRouteUpdate
}: RoutesTableProps) => {
  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      onSelectionChange(routes.map(route => route.id!));
    } else {
      onSelectionChange([]);
    }
  };

  const handleSelectRoute = (routeId: string, checked: boolean) => {
    if (checked) {
      onSelectionChange([...selectedRoutes, routeId]);
    } else {
      onSelectionChange(selectedRoutes.filter(id => id !== routeId));
    }
  };

  const handleDeleteRoute = async (routeId: string) => {
    try {
      await RouteService.deleteRoute(routeId);
      onRouteUpdate();
    } catch (error) {
      console.error('Failed to delete route:', error);
    }
  };

  const handleCopyPath = async (path: string) => {
    try {
      await navigator.clipboard.writeText(path);
      // TODO: Add toast notification
    } catch (error) {
      console.error('Failed to copy path:', error);
    }
  };

  const handleDuplicateRoute = async (route: StudioRoute) => {
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
        status: 'draft' as const
      };

      // Remove id to create new route
      const { id, ...routeData } = duplicatedRoute;
      await RouteService.createRoute(routeData);
      onRouteUpdate();
      // TODO: Add success notification
    } catch (error) {
      console.error('Failed to duplicate route:', error);
      // TODO: Add error notification
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center p-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
        <span className="ml-2">Loading routes...</span>
      </div>
    );
  }

  if (routes.length === 0) {
    return (
      <div className="text-center py-12">
        <div className="text-gray-500 mb-4">
          <svg className="mx-auto h-12 w-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
        </div>
        <h3 className="text-lg font-medium text-gray-900 mb-2">No routes found</h3>
        <p className="text-gray-500 mb-4">
          Get started by creating your first route.
        </p>
        <Button asChild>
          <Link to="/admin/routes/new">Create Route</Link>
        </Button>
      </div>
    );
  }

  return (
    <div className="bg-white shadow-sm border border-gray-200 rounded-lg overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th scope="col" className="relative w-12 px-6 sm:w-16 sm:px-8">
                <Checkbox
                  checked={selectedRoutes.length === routes.length && routes.length > 0}
                  onCheckedChange={handleSelectAll}
                  aria-label="Select all routes"
                />
              </th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Route
              </th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Permissions
              </th>
              <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Guards
              </th>
              <th scope="col" className="relative px-6 py-3">
                <span className="sr-only">Actions</span>
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {routes.map((route) => (
              <tr key={route.id} className="hover:bg-gray-50">
                <td className="relative w-12 px-6 sm:w-16 sm:px-8">
                  <Checkbox
                    checked={selectedRoutes.includes(route.id!)}
                    onCheckedChange={(checked: boolean) => handleSelectRoute(route.id!, checked)}
                    aria-label={`Select route ${route.identity.value}`}
                  />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex items-center">
                    <div>
                      <div className="text-sm font-medium text-gray-900 font-mono">
                        {route.identity.value}
                      </div>
                      <div className="text-sm text-gray-500">
                        {route.metadata?.title_i18n || route.identity.slug}
                      </div>
                    </div>
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <StatusBadge status={route.status} />
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="flex flex-wrap gap-1">
                    {route.permissions.slice(0, 2).map((permission) => (
                      <Badge key={permission} variant="secondary" className="text-xs">
                        {permission}
                      </Badge>
                    ))}
                    {route.permissions.length > 2 && (
                      <Badge variant="outline" className="text-xs">
                        +{route.permissions.length - 2}
                      </Badge>
                    )}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <div className="text-sm text-gray-900">
                    {route.guards && route.guards.length > 0 ? (
                      <span className="text-green-600 font-medium">
                        {route.guards.length} guard{route.guards.length > 1 ? 's' : ''}
                      </span>
                    ) : (
                      <span className="text-gray-400">None</span>
                    )}
                  </div>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <div className="flex items-center justify-end space-x-1">
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleCopyPath(route.identity.value)}
                      title="Copy path"
                    >
                      <Copy className="w-4 h-4" />
                      <span className="sr-only">Copy path</span>
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => handleDuplicateRoute(route)}
                      title="Duplicate route"
                    >
                      <GitBranch className="w-4 h-4" />
                      <span className="sr-only">Duplicate</span>
                    </Button>
                    <Button asChild variant="ghost" size="sm">
                      <Link to={`/admin/routes/${route.id}`}>
                        <Eye className="w-4 h-4" />
                        <span className="sr-only">View</span>
                      </Link>
                    </Button>
                    <Button asChild variant="ghost" size="sm">
                      <Link to={`/admin/routes/${route.id}/edit`}>
                        <Edit className="w-4 h-4" />
                        <span className="sr-only">Edit</span>
                      </Link>
                    </Button>
                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button variant="ghost" size="sm" className="text-red-600 hover:text-red-900">
                          <Trash2 className="w-4 h-4" />
                          <span className="sr-only">Delete</span>
                        </Button>
                      </AlertDialogTrigger>
                      <AlertDialogContent>
                        <AlertDialogHeader>
                          <AlertDialogTitle>Delete Route</AlertDialogTitle>
                          <AlertDialogDescription>
                            Are you sure you want to delete the route "{route.identity.value}"?
                            This action cannot be undone.
                          </AlertDialogDescription>
                        </AlertDialogHeader>
                        <AlertDialogFooter>
                          <AlertDialogCancel>Cancel</AlertDialogCancel>
                          <AlertDialogAction
                            onClick={() => handleDeleteRoute(route.id!)}
                            className="bg-red-600 hover:bg-red-700"
                          >
                            Delete
                          </AlertDialogAction>
                        </AlertDialogFooter>
                      </AlertDialogContent>
                    </AlertDialog>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};
