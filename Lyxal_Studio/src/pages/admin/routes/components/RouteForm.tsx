import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { RouteService } from '@/services/RouteService';
import { CreateStudioRouteInput, StudioRoute } from '@/lib/studio/types/route';
import { GuardsEditor } from './GuardsEditor';
import { PermissionsSelect } from './PermissionsSelect';
import { ArrowLeft, Loader2 } from 'lucide-react';

interface RouteFormProps {
  route?: StudioRoute;
}

export const RouteForm = ({ route }: RouteFormProps) => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState<{
    path: string;
    slug: string;
    code: string;
    pageCode: string;
    permissions: string[];
    status: string;
    title: string;
    description: string;
  }>({
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const routeData: CreateStudioRouteInput = {
        identity: {
          value: formData.path,
          slug: formData.slug,
          code: formData.code,
        },
        page: { identity: { code: formData.pageCode } },
        permissions: formData.permissions as any,
        guards: guards,
        metadata: {
          title_i18n: formData.title,
          description_i18n: formData.description,
        },
        status: formData.status as any,
      };

      if (route) {
        // Update existing route
        await RouteService.updateRoute(route.id!, { ...routeData, id: route.id! });
      } else {
        // Create new route
        await RouteService.createRoute(routeData);
      }

      navigate('/admin/routes');
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  const updatePermissions = (permission: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      permissions: checked
        ? [...prev.permissions, permission]
        : prev.permissions.filter(p => p !== permission)
    }));
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-4xl mx-auto p-6">
        <div className="mb-6">
          <Button
            variant="ghost"
            onClick={() => navigate('/admin/routes')}
            className="mb-4"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Back to Routes
          </Button>

          <h1 className="text-3xl font-bold">
            {route ? 'Edit Route' : 'Create New Route'}
          </h1>
          <p className="text-gray-600 mt-1">
            {route ? 'Update the route configuration' : 'Define a new route for your application'}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Basic Information */}
          <Card>
            <CardHeader>
              <CardTitle>Basic Information</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                  <Label htmlFor="path">Path *</Label>
                  <Input
                    id="path"
                    value={formData.path}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, path: e.target.value }))}
                    placeholder="/dashboard"
                    required
                  />
                  <p className="text-sm text-gray-500 mt-1">The URL path for this route</p>
                </div>

                <div>
                  <Label htmlFor="slug">Slug *</Label>
                  <Input
                    id="slug"
                    value={formData.slug}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, slug: e.target.value }))}
                    placeholder="dashboard"
                    required
                  />
                  <p className="text-sm text-gray-500 mt-1">URL-friendly identifier</p>
                </div>

                <div>
                  <Label htmlFor="code">Code *</Label>
                  <Input
                    id="code"
                    value={formData.code}
                    onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, code: e.target.value }))}
                    placeholder="dashboard"
                    required
                  />
                  <p className="text-sm text-gray-500 mt-1">Unique code identifier</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Page Reference */}
          <Card>
            <CardHeader>
              <CardTitle>Page Reference</CardTitle>
            </CardHeader>
            <CardContent>
              <div>
                <Label htmlFor="pageCode">Page Code *</Label>
                <Input
                  id="pageCode"
                  value={formData.pageCode}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, pageCode: e.target.value }))}
                  placeholder="dashboard_page"
                  required
                />
                <p className="text-sm text-gray-500 mt-1">Reference to the studio page that will be rendered</p>
              </div>
            </CardContent>
          </Card>

          {/* Permissions */}
          <Card>
            <CardHeader>
              <CardTitle>Permissions</CardTitle>
            </CardHeader>
            <CardContent>
              <PermissionsSelect
                selected={formData.permissions}
                onChange={(permissions) => setFormData(prev => ({ ...prev, permissions }))}
              />
            </CardContent>
          </Card>

          {/* Security Guards */}
          <Card>
            <CardHeader>
              <CardTitle>Security Guards</CardTitle>
            </CardHeader>
            <CardContent>
              <GuardsEditor
                guards={guards}
                onChange={setGuards}
              />
            </CardContent>
          </Card>

          {/* Status */}
          <Card>
            <CardHeader>
              <CardTitle>Status</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="max-w-xs">
                <Label htmlFor="status">Route Status</Label>
                <Select value={formData.status} onValueChange={(value: string) => setFormData(prev => ({ ...prev, status: value }))}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="draft">Draft</SelectItem>
                    <SelectItem value="active">Active</SelectItem>
                    <SelectItem value="inactive">Inactive</SelectItem>
                    <SelectItem value="deprecated">Deprecated</SelectItem>
                  </SelectContent>
                </Select>
                <p className="text-sm text-gray-500 mt-1">Current status of the route</p>
              </div>
            </CardContent>
          </Card>

          {/* Metadata */}
          <Card>
            <CardHeader>
              <CardTitle>Metadata (Optional)</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <Label htmlFor="title">Title</Label>
                <Input
                  id="title"
                  value={formData.title}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setFormData(prev => ({ ...prev, title: e.target.value }))}
                  placeholder="Dashboard"
                />
                <p className="text-sm text-gray-500 mt-1">Display name for the route</p>
              </div>

              <div>
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  value={formData.description}
                  onChange={(e: React.ChangeEvent<HTMLTextAreaElement>) => setFormData(prev => ({ ...prev, description: e.target.value }))}
                  placeholder="Main dashboard page for administrators"
                  rows={3}
                />
                <p className="text-sm text-gray-500 mt-1">Brief description of what this route does</p>
              </div>
            </CardContent>
          </Card>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
              {error}
            </div>
          )}

          {/* Actions */}
          <div className="flex justify-end gap-2 pt-6 border-t">
            <Button type="button" variant="outline" onClick={() => navigate('/admin/routes')}>
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
              {loading ? 'Saving...' : (route ? 'Update Route' : 'Create Route')}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};
