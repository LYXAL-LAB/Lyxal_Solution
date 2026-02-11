# 🚀 **PHASE 5 : UI COMPONENTS** (2-3 jours)

## 🎯 **Objectif**
Créer l'interface utilisateur complète pour gérer les routes dynamiques avec deux approches possibles :

### **Approche A : Interface Classique** (2 jours)
Interface web standard utilisant React classique avec formulaires HTML, sans dépendre du système Studio pour l'interface elle-même.

### **Approche B : Interface Avancée Studio** (3 jours)
Interface utilisant les composants DB-driven du système Studio pour une expérience ultra-dynamique.

---

---

## 🔄 **CHOIX D'APPROCHE - DÉCISION IMPORTANTE**

### **🎯 Approche A : Interface Classique** (2 jours - RECOMMANDÉE)
Interface web standard avec React/HTML classique. Plus rapide à implémenter, plus maintenable.

### **🚀 Approche B : Interface Studio Avancée** (3 jours - POUR EXPERIENCE ULTIME)
Interface utilisant le système Studio DB-driven pour une expérience complètement dynamique.

---

## 📋 **APPROCHE A : INTERFACE CLASSIQUE** (2 jours)

### **Jour 1 : Interface de Base**
- ✅ **RoutesTable** : Table des routes avec actions CRUD
- ✅ **RouteForm** : Formulaire de création/édition simple
- ✅ **PermissionsSelect** : Sélecteur de permissions
- ✅ **StatusBadge** : Indicateurs de statut visuels

### **Jour 2 : Fonctionnalités Avancées**
- ✅ **RoutesDashboard** : Dashboard avec métriques
- ✅ **GuardsEditor** : Éditeur visuel des guards
- ✅ **BulkOperations** : Actions groupées (statut, suppression)
- ✅ **SearchFilters** : Recherche et filtrage avancé

---

## 📋 **APPROCHE B : INTERFACE STUDIO AVANCÉE** (3 jours)

### **Jour 1 : Composants de Base**
- ✅ **RouteCard** : Affichage d'une route avec métadonnées
- ✅ **RouteForm** : Création/édition avec validation temps réel
- ✅ **GuardConfig** : Configuration visuelle des guards
- ✅ **PermissionSelector** : Sélection des permissions

### **Jour 2 : Pages d'Administration**
- ✅ **RoutesManager** : Dashboard des routes avec métriques
- ✅ **RouteEditor** : Éditeur avancé avec aperçu
- ✅ **GuardBuilder** : Constructeur visuel de guards
- ✅ **PermissionManager** : Gestion centralisée des permissions

### **Jour 3 : Intégration & Testing**
- ✅ **RouteWizard** : Assistant pas-à-pas de création
- ✅ **BulkOperations** : Actions groupées avec confirmation
- ✅ **Import/Export** : Migration de données
- ✅ **Real-time Updates** : Synchronisation temps réel

---

## 🏗️ **ARCHITECTURE APPROCHE A** (Classique)

### **Structure Simplifiée**
```
src/pages/admin/
├── routes/
│   ├── index.tsx                    # Dashboard principal
│   ├── [id].tsx                     # Édition d'une route
│   ├── new.tsx                      # Création de route
│   └── components/
│       ├── RoutesTable.tsx          # Table des routes
│       ├── RouteForm.tsx            # Formulaire simple
│       ├── GuardsEditor.tsx         # Éditeur guards
│       └── PermissionsSelect.tsx    # Sélecteur permissions
```

---

## 🏗️ **ARCHITECTURE APPROCHE B** (Studio Avancée)

### **Structure des Composants**
```
src/components/routes/
├── common/                    # Composants partagés
│   ├── RouteCard.tsx         # Carte d'affichage route
│   ├── RouteStatus.tsx       # Indicateur de statut
│   ├── PermissionBadge.tsx   # Badge de permission
│   └── GuardIndicator.tsx    # Indicateur de guard
├── forms/                     # Formulaires
│   ├── RouteForm.tsx         # Formulaire principal
│   ├── GuardConfigForm.tsx   # Config guards
│   ├── PermissionForm.tsx    # Gestion permissions
│   └── BulkActionsForm.tsx   # Actions groupées
├── pages/                     # Pages complètes
│   ├── RoutesDashboard.tsx   # Dashboard principal
│   ├── RouteEditor.tsx       # Éditeur détaillé
│   ├── RouteWizard.tsx       # Assistant création
│   └── PermissionManager.tsx # Gestion permissions
├── hooks/                     # Hooks UI spécifiques
│   ├── useRouteForm.ts       # Gestion formulaires
│   ├── useRouteValidation.ts # Validation temps réel
│   ├── useBulkOperations.ts  # Opérations groupées
│   └── useRouteTemplates.ts  # Templates de routes
└── utils/                     # Utilitaires UI
    ├── routeFormatters.ts    # Formatage affichage
    ├── dragDropHelpers.ts    # Drag & drop
    └── exportHelpers.ts      # Import/export
```

---

## 🎨 **DESIGN SYSTEM APPROCHE B**

### **Thème et Couleurs**
```typescript
// Couleurs par statut
const ROUTE_STATUS_COLORS = {
  active: 'bg-green-500',
  inactive: 'bg-gray-500',
  draft: 'bg-yellow-500',
  deprecated: 'bg-red-500'
};

// Couleurs par type de guard
const GUARD_TYPE_COLORS = {
  auth: 'bg-blue-500',
  role: 'bg-purple-500',
  subscription: 'bg-orange-500',
  feature: 'bg-pink-500'
};
```

### **Icônes et Indicateurs**
```typescript
// Icônes par type de guard
const GUARD_ICONS = {
  auth: 'Shield',
  role: 'Users',
  subscription: 'CreditCard',
  feature: 'Zap'
};
```

---

## 🎨 **DESIGN SYSTEM**

### **Stack Technologique**
- ✅ **React + TypeScript** : Composants typés
- ✅ **Tailwind CSS** : Framework CSS utilitaire
- ✅ **shadcn/ui** : Composants UI accessibles
- ✅ **React Hook Form** : Gestion des formulaires
- ✅ **Lucide React** : Icônes cohérentes

### **Thème et Couleurs**
```typescript
// Statuts des routes
const ROUTE_STATUS_STYLES = {
  active: 'bg-green-100 text-green-800 border-green-200',
  inactive: 'bg-gray-100 text-gray-800 border-gray-200',
  draft: 'bg-yellow-100 text-yellow-800 border-yellow-200',
  deprecated: 'bg-red-100 text-red-800 border-red-200'
};

// Types de guards
const GUARD_TYPE_COLORS = {
  auth: 'text-blue-600',
  role: 'text-purple-600',
  subscription: 'text-orange-600',
  feature: 'text-pink-600'
};
```

---

## 🧩 **COMPOSANTS PRINCIPAUX**

### **1. RoutesTable - Table des Routes**
```tsx
import { useState } from 'react';
import { useStudioRoutes } from '@/lib/studio/hooks/useStudioRoutes';
import { RouteService } from '@/services/RouteService';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Checkbox } from '@/components/ui/checkbox';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from '@/components/ui/alert-dialog';
import { Link } from 'react-router-dom';
import { StatusBadge } from './StatusBadge';
import { BulkActions } from './BulkActions';
import { SearchFilters } from './SearchFilters';

export const RoutesTable = () => {
  const { routes, loading, error, refetch } = useStudioRoutes();
  const [selectedRoutes, setSelectedRoutes] = useState<Set<string>>(new Set());
  const [filters, setFilters] = useState({ search: '', status: 'all' });

  const handleDelete = async (routeId: string) => {
    try {
      await RouteService.deleteRoute(routeId);
      refetch();
    } catch (error) {
      console.error('Failed to delete route:', error);
    }
  };

  const handleBulkDelete = async () => {
    try {
      await Promise.all(Array.from(selectedRoutes).map(id => RouteService.deleteRoute(id)));
      setSelectedRoutes(new Set());
      refetch();
    } catch (error) {
      console.error('Failed to delete routes:', error);
    }
  };

  const toggleSelection = (routeId: string) => {
    setSelectedRoutes(prev => {
      const next = new Set(prev);
      if (next.has(routeId)) {
        next.delete(routeId);
      } else {
        next.add(routeId);
      }
      return next;
    });
  };

  const selectAll = () => {
    setSelectedRoutes(new Set(filteredRoutes.map(r => r.id!)));
  };

  const clearSelection = () => {
    setSelectedRoutes(new Set());
  };

  const filteredRoutes = routes.filter(route => {
    const matchesSearch = route.identity.value.toLowerCase().includes(filters.search.toLowerCase()) ||
                         route.identity.slug.toLowerCase().includes(filters.search.toLowerCase());
    const matchesStatus = filters.status === 'all' || route.status === filters.status;
    return matchesSearch && matchesStatus;
  });

  if (loading) return <div className="flex justify-center p-8"><div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div></div>;
  if (error) return <div className="text-red-600 p-4">Error: {error}</div>;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold">Routes Management</h2>
          <p className="text-gray-600">{routes.length} routes total</p>
        </div>
        <div className="flex gap-2">
          <Button onClick={refetch} variant="outline" size="sm">
            Refresh
          </Button>
          <Button asChild size="sm">
            <Link to="/admin/routes/new">New Route</Link>
          </Button>
        </div>
      </div>

      {/* Filters */}
      <SearchFilters filters={filters} onFiltersChange={setFilters} />

      {/* Bulk Actions */}
      {selectedRoutes.size > 0 && (
        <BulkActions
          selectedRoutes={selectedRoutes}
          onClearSelection={clearSelection}
          onBulkDelete={handleBulkDelete}
          onRefresh={refetch}
        />
      )}

      {/* Table */}
      <div className="border rounded-lg overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left">
                <Checkbox
                  checked={selectedRoutes.size === filteredRoutes.length && filteredRoutes.length > 0}
                  onCheckedChange={selectAll}
                />
              </th>
              <th className="px-4 py-3 text-left font-semibold">Path</th>
              <th className="px-4 py-3 text-left font-semibold">Status</th>
              <th className="px-4 py-3 text-left font-semibold">Permissions</th>
              <th className="px-4 py-3 text-left font-semibold">Guards</th>
              <th className="px-4 py-3 text-left font-semibold">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {filteredRoutes.map(route => (
              <tr key={route.id} className={`hover:bg-gray-50 ${selectedRoutes.has(route.id!) ? 'bg-blue-50' : ''}`}>
                <td className="px-4 py-3">
                  <Checkbox
                    checked={selectedRoutes.has(route.id!)}
                    onCheckedChange={() => toggleSelection(route.id!)}
                  />
                </td>
                <td className="px-4 py-3">
                  <div>
                    <div className="font-mono text-sm font-medium">{route.identity.value}</div>
                    <div className="text-xs text-gray-500">{route.identity.slug}</div>
                  </div>
                </td>
                <td className="px-4 py-3">
                  <StatusBadge status={route.status} />
                </td>
                <td className="px-4 py-3">
                  <div className="flex flex-wrap gap-1">
                    {route.permissions.slice(0, 2).map(perm => (
                      <Badge key={perm} variant="outline" className="text-xs">
                        {perm}
                      </Badge>
                    ))}
                    {route.permissions.length > 2 && (
                      <Badge variant="outline" className="text-xs">
                        +{route.permissions.length - 2}
                      </Badge>
                    )}
                  </div>
                </td>
                <td className="px-4 py-3">
                  <div className="text-sm text-gray-600">
                    {route.guards?.length || 0} guard(s)
                  </div>
                </td>
                <td className="px-4 py-3">
                  <div className="flex gap-2">
                    <Button asChild size="sm" variant="outline">
                      <Link to={`/admin/routes/${route.id}`}>Edit</Link>
                    </Button>
                    <AlertDialog>
                      <AlertDialogTrigger asChild>
                        <Button size="sm" variant="outline" className="text-red-600 hover:text-red-700">
                          Delete
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
                            onClick={() => handleDelete(route.id!)}
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

        {filteredRoutes.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            No routes found matching your criteria.
          </div>
        )}
      </div>
    </div>
  );
};
```

### **2. RouteForm - Formulaire Simple**
```tsx
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { RouteService } from '@/services/RouteService';
import { CreateStudioRouteInput, StudioRoute } from '@/lib/studio/types/route';

interface RouteFormProps {
  route?: StudioRoute;
}

export const RouteForm = ({ route }: RouteFormProps) => {
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
        permissions: formData.permissions,
        guards: [], // Sera ajouté plus tard
        metadata: {
          title_i18n: formData.title,
          description_i18n: formData.description,
        },
        status: formData.status as any,
      };

      if (route) {
        // Update existing route
        await RouteService.updateRoute(route.id!, routeData);
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
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">
        {route ? 'Edit Route' : 'Create New Route'}
      </h1>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Basic Information */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold">Basic Information</h2>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <Label htmlFor="path">Path</Label>
              <Input
                id="path"
                value={formData.path}
                onChange={(e) => setFormData(prev => ({ ...prev, path: e.target.value }))}
                placeholder="/dashboard"
                required
              />
            </div>

            <div>
              <Label htmlFor="slug">Slug</Label>
              <Input
                id="slug"
                value={formData.slug}
                onChange={(e) => setFormData(prev => ({ ...prev, slug: e.target.value }))}
                placeholder="dashboard"
                required
              />
            </div>

            <div>
              <Label htmlFor="code">Code</Label>
              <Input
                id="code"
                value={formData.code}
                onChange={(e) => setFormData(prev => ({ ...prev, code: e.target.value }))}
                placeholder="dashboard"
                required
              />
            </div>
          </div>
        </div>

        {/* Page Reference */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold">Page Reference</h2>
          <div>
            <Label htmlFor="pageCode">Page Code</Label>
            <Input
              id="pageCode"
              value={formData.pageCode}
              onChange={(e) => setFormData(prev => ({ ...prev, pageCode: e.target.value }))}
              placeholder="dashboard_page"
              required
            />
          </div>
        </div>

        {/* Permissions */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold">Permissions</h2>
          <div className="space-y-2">
            {['guest', 'authenticated', 'admin', 'manager'].map(permission => (
              <div key={permission} className="flex items-center space-x-2">
                <Checkbox
                  id={permission}
                  checked={formData.permissions.includes(permission)}
                  onCheckedChange={(checked) => updatePermissions(permission, checked as boolean)}
                />
                <Label htmlFor={permission} className="capitalize">
                  {permission}
                </Label>
              </div>
            ))}
          </div>
        </div>

        {/* Status */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold">Status</h2>
          <Select value={formData.status} onValueChange={(value) => setFormData(prev => ({ ...prev, status: value }))}>
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
        </div>

        {/* Metadata */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold">Metadata (Optional)</h2>

          <div>
            <Label htmlFor="title">Title</Label>
            <Input
              id="title"
              value={formData.title}
              onChange={(e) => setFormData(prev => ({ ...prev, title: e.target.value }))}
              placeholder="Dashboard"
            />
          </div>

          <div>
            <Label htmlFor="description">Description</Label>
            <Input
              id="description"
              value={formData.description}
              onChange={(e) => setFormData(prev => ({ ...prev, description: e.target.value }))}
              placeholder="Main dashboard page"
            />
          </div>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
            {error}
          </div>
        )}

        {/* Actions */}
        <div className="flex justify-end gap-2">
          <Button type="button" variant="outline" onClick={() => navigate('/admin/routes')}>
            Cancel
          </Button>
          <Button type="submit" disabled={loading}>
            {loading ? 'Saving...' : (route ? 'Update Route' : 'Create Route')}
          </Button>
        </div>
      </form>
    </div>
  );
};
```

### **3. GuardsEditor - Éditeur Simple**
```tsx
import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

export const GuardsEditor = () => {
  const [guards, setGuards] = useState([]);

  const addGuard = () => {
    setGuards([...guards, { type: 'auth', condition: {} }]);
  };

  const removeGuard = (index: number) => {
    setGuards(guards.filter((_, i) => i !== index));
  };

  const updateGuard = (index: number, field: string, value: any) => {
    const newGuards = [...guards];
    if (field === 'type') {
      newGuards[index] = { type: value, condition: {} };
    } else {
      newGuards[index].condition = { ...newGuards[index].condition, [field]: value };
    }
    setGuards(newGuards);
  };

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h3 className="text-lg font-semibold">Security Guards</h3>
        <Button onClick={addGuard} size="sm">Add Guard</Button>
      </div>

      {guards.map((guard, index) => (
        <div key={index} className="border rounded-lg p-4 space-y-3">
          <div className="flex justify-between items-center">
            <span className="font-medium">Guard #{index + 1}</span>
            <Button onClick={() => removeGuard(index)} size="sm" variant="outline">
              Remove
            </Button>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label>Type</Label>
              <Select
                value={guard.type}
                onValueChange={(value) => updateGuard(index, 'type', value)}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="auth">Authentication</SelectItem>
                  <SelectItem value="role">Role</SelectItem>
                  <SelectItem value="subscription">Subscription</SelectItem>
                  <SelectItem value="feature">Feature</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {guard.type === 'role' && (
              <div>
                <Label>Required Role</Label>
                <Input
                  value={guard.condition.role || ''}
                  onChange={(e) => updateGuard(index, 'role', e.target.value)}
                  placeholder="admin"
                />
              </div>
            )}

            {guard.type === 'subscription' && (
              <div>
                <Label>Plan</Label>
                <Input
                  value={guard.condition.plan || ''}
                  onChange={(e) => updateGuard(index, 'plan', e.target.value)}
                  placeholder="premium"
                />
              </div>
            )}

            {guard.type === 'feature' && (
              <div>
                <Label>Feature</Label>
                <Input
                  value={guard.condition.feature || ''}
                  onChange={(e) => updateGuard(index, 'feature', e.target.value)}
                  placeholder="advanced_analytics"
                />
              </div>
            )}
          </div>
        </div>
      ))}

      {guards.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          No guards configured. Add one to secure this route.
        </div>
      )}
    </div>
  );
};
```

---

## 📊 **HOOKS SPÉCIALISÉS**

### **useRouteForm - Gestion de Formulaire**
```typescript
import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { CreateStudioRouteInput, UpdateStudioRouteInput, StudioRoute } from '@/lib/studio/types/route';
import { createRouteSchema, updateRouteSchema } from '@/lib/studio/routes/schemas/routeSchema';

export const useRouteForm = (route?: StudioRoute) => {
  const isEditing = !!route;
  const schema = isEditing ? updateRouteSchema : createRouteSchema;

  const form = useForm({
    resolver: zodResolver(schema),
    defaultValues: {
      identity: {
        value: route?.identity.value || '',
        slug: route?.identity.slug || '',
        code: route?.identity.code || '',
      },
      page: {
        identity: {
          code: route?.page.identity.code || '',
        },
      },
      permissions: route?.permissions || ['guest'],
      guards: route?.guards || [],
      metadata: {
        title_i18n: route?.metadata?.title_i18n || '',
        description_i18n: route?.metadata?.description_i18n || '',
      },
      status: route?.status || 'draft',
    },
  });

  const [isSubmitting, setIsSubmitting] = useState(false);

  // Auto-generate slug and code from path
  useEffect(() => {
    const path = form.watch('identity.value');
    if (path && !isEditing) {
      const slug = path.replace(/^\/+/, '').replace(/\/+/g, '-');
      const code = slug.replace(/-/g, '_');

      form.setValue('identity.slug', slug);
      form.setValue('identity.code', code);
    }
  }, [form.watch('identity.value'), isEditing]);

  const onSubmit = async (data: CreateStudioRouteInput | UpdateStudioRouteInput) => {
    setIsSubmitting(true);
    try {
      if (isEditing) {
        await RouteService.updateRoute(route!.id!, data as UpdateStudioRouteInput);
      } else {
        await RouteService.createRoute(data as CreateStudioRouteInput);
      }
      return true;
    } catch (error) {
      console.error('Form submission failed:', error);
      return false;
    } finally {
      setIsSubmitting(false);
    }
  };

  return {
    form,
    isSubmitting,
    isEditing,
    onSubmit: form.handleSubmit(onSubmit),
  };
};
```

### **useBulkOperations - Actions Groupées**
```typescript
import { useState } from 'react';
import { RouteService } from '@/services/RouteService';

export const useBulkOperations = () => {
  const [isLoading, setIsLoading] = useState(false);

  const bulkDelete = async (routeIds: string[]) => {
    setIsLoading(true);
    try {
      await Promise.all(routeIds.map(id => RouteService.deleteRoute(id)));
      return true;
    } catch (error) {
      console.error('Bulk delete failed:', error);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  const bulkUpdateStatus = async (routeIds: string[], status: StudioRoute['status']) => {
    setIsLoading(true);
    try {
      await Promise.all(routeIds.map(id => RouteService.setRouteStatus(id, status)));
      return true;
    } catch (error) {
      console.error('Bulk status update failed:', error);
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  return {
    isLoading,
    bulkDelete,
    bulkUpdateStatus,
  };
};
```

---

## 🎯 **FONCTIONNALITÉS AVANCÉES**

### **Dashboard Simple**
```tsx
import { useStudioRoutes } from '@/lib/studio/hooks/useStudioRoutes';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

export const RoutesDashboard = () => {
  const { routes, loading } = useStudioRoutes();

  if (loading) return <div>Loading...</div>;

  const stats = {
    total: routes.length,
    active: routes.filter(r => r.status === 'active').length,
    draft: routes.filter(r => r.status === 'draft').length,
    inactive: routes.filter(r => r.status === 'inactive').length,
  };

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Routes Dashboard</h1>

      {/* Statistics */}
      <div className="grid grid-cols-4 gap-4">
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Total Routes</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Active</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-green-600">{stats.active}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Draft</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-yellow-600">{stats.draft}</div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-medium">Inactive</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-gray-600">{stats.inactive}</div>
          </CardContent>
        </Card>
      </div>

      {/* Quick Actions */}
      <Card>
        <CardHeader>
          <CardTitle>Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex gap-2">
            <Button asChild>
              <Link to="/admin/routes/new">New Route</Link>
            </Button>
            <Button variant="outline">
              Export Routes
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
```

### **Search & Filter Basique**
```tsx
import { useState, useMemo } from 'react';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

export const useRouteFilters = (routes) => {
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const filteredRoutes = useMemo(() => {
    return routes.filter(route => {
      const matchesSearch = route.identity.value.toLowerCase().includes(search.toLowerCase()) ||
                          route.identity.slug.toLowerCase().includes(search.toLowerCase());

      const matchesStatus = statusFilter === 'all' || route.status === statusFilter;

      return matchesSearch && matchesStatus;
    });
  }, [routes, search, statusFilter]);

  return {
    search,
    setSearch,
    statusFilter,
    setStatusFilter,
    filteredRoutes
  };
};
```

---

## 🧪 **TESTS ET VALIDATION**

### **Tests Composants**
```typescript
describe('RouteCard', () => {
  it('displays route information correctly', () => {
    const route = createMockRoute();
    render(<RouteCard route={route} onEdit={mockFn} onDelete={mockFn} onToggleStatus={mockFn} />);

    expect(screen.getByText(route.identity.value)).toBeInTheDocument();
    expect(screen.getByText(route.metadata!.description_i18n!)).toBeInTheDocument();
  });

  it('calls onEdit when edit button is clicked', () => {
    const mockOnEdit = jest.fn();
    const route = createMockRoute();

    render(<RouteCard route={route} onEdit={mockOnEdit} onDelete={mockFn} onToggleStatus={mockFn} />);
    fireEvent.click(screen.getByRole('button', { name: /edit/i }));

    expect(mockOnEdit).toHaveBeenCalledWith(route);
  });
});
```

### **Tests d'Intégration**
```typescript
describe('Routes Management Flow', () => {
  it('creates a new route successfully', async () => {
    const newRoute = {
      identity: { value: '/test', slug: 'test', code: 'test' },
      page: { identity: { code: 'test_page' } },
      permissions: ['authenticated'],
      status: 'active' as const
    };

    // Mock API
    mockRouteService.createRoute.mockResolvedValue({ ...newRoute, id: '123' });

    render(<RouteWizard />);

    // Remplir le formulaire
    await userEvent.type(screen.getByLabelText('Path'), '/test');
    await userEvent.type(screen.getByLabelText('Slug'), 'test');
    await userEvent.type(screen.getByLabelText('Code'), 'test');

    // Soumettre
    await userEvent.click(screen.getByRole('button', { name: /create route/i }));

    // Vérifier que l'API a été appelée
    expect(mockRouteService.createRoute).toHaveBeenCalledWith(newRoute);

    // Vérifier la redirection
    expect(mockRouter.push).toHaveBeenCalledWith('/routes');
  });
});
```

---

## 📈 **MÉTRIQUES DE SUCCÈS**

- ✅ **15+ composants** créés et testés
- ✅ **4 pages principales** d'administration
- ✅ **3 hooks spécialisés** pour l'UX
- ✅ **Import/Export** fonctionnel
- ✅ **Real-time updates** implémentés
- ✅ **Responsive design** pour tous les écrans
- ✅ **Accessibilité** WCAG 2.1 AA
- ✅ **Performance** < 100ms de chargement

---

## 🎯 **LIVRABLES PHASE 5**

### **Composants UI**
- ✅ Bibliothèque complète de composants routes
- ✅ Formulaires intelligents avec validation
- ✅ Interface drag & drop pour l'organisation
- ✅ Templates et presets pour création rapide

### **Pages d'Administration**
- ✅ Dashboard routes avec métriques
- ✅ Éditeur avancé avec aperçu temps réel
- ✅ Gestion permissions centralisée
- ✅ Outils d'import/export massifs

### **UX/Performance**
- ✅ Loading states et skeletons
- ✅ Gestion d'erreur user-friendly
- ✅ Cache client optimisé
- ✅ PWA prête pour offline

---

## 🚀 **INTÉGRATION FINALE**

```tsx
// Dans App.tsx
import { RoutesManager } from '@/components/routes/pages/RoutesDashboard';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        {/* Routes dynamiques */}
        <Route path="/admin/routes" element={<RoutesManager />} />
        <Route path="/admin/routes/new" element={<RouteWizard />} />
        <Route path="/admin/routes/:id/edit" element={<RouteEditor />} />

        {/* Routes générées dynamiquement */}
        {/* ... autres routes ... */}
      </Routes>
    </BrowserRouter>
  );
}
```

---

**Phase 5 : UI Components complète l'architecture !** 🎉

**Prêt pour la démonstration finale ?** 🤝
