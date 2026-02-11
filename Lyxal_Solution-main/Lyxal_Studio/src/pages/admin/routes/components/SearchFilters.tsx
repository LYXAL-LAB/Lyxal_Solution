import { useState } from 'react';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import { Card, CardContent } from '@/components/ui/card';
import { Search, X } from 'lucide-react';

interface SearchFiltersProps {
  filters: {
    search: string;
    status: string;
    permission: string;
  };
  onFiltersChange: (filters: { search: string; status: string; permission: string }) => void;
  totalResults: number;
  className?: string;
}

export const SearchFilters = ({
  filters,
  onFiltersChange,
  totalResults,
  className = ''
}: SearchFiltersProps) => {
  const hasActiveFilters = filters.search || filters.status !== 'all' || filters.permission !== 'all';

  const handleSearchChange = (search: string) => {
    onFiltersChange({ ...filters, search });
  };

  const handleStatusChange = (status: string) => {
    onFiltersChange({ ...filters, status });
  };

  const handlePermissionChange = (permission: string) => {
    onFiltersChange({ ...filters, permission });
  };

  const handleClearFilters = () => {
    onFiltersChange({ search: '', status: 'all', permission: 'all' });
  };

  return (
    <Card className={className}>
      <CardContent className="pt-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="md:col-span-2">
            <Label htmlFor="search" className="sr-only">Search routes</Label>
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground w-4 h-4" />
              <Input
                id="search"
                placeholder="Search by path, slug, or page code..."
                value={filters.search}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => handleSearchChange(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <div>
            <Label htmlFor="status-filter" className="sr-only">Filter by status</Label>
            <Select value={filters.status} onValueChange={handleStatusChange}>
              <SelectTrigger id="status-filter">
                <SelectValue placeholder="All statuses" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Statuses</SelectItem>
                <SelectItem value="active">Active</SelectItem>
                <SelectItem value="inactive">Inactive</SelectItem>
                <SelectItem value="draft">Draft</SelectItem>
                <SelectItem value="deprecated">Deprecated</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div>
            <Label htmlFor="permission-filter" className="sr-only">Filter by permission</Label>
            <Select value={filters.permission} onValueChange={handlePermissionChange}>
              <SelectTrigger id="permission-filter">
                <SelectValue placeholder="All permissions" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Permissions</SelectItem>
                <SelectItem value="guest">Guest</SelectItem>
                <SelectItem value="authenticated">Authenticated</SelectItem>
                <SelectItem value="admin">Admin</SelectItem>
                <SelectItem value="manager">Manager</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>

        <div className="flex justify-between items-center mt-4 pt-4 border-t">
          <div className="text-sm text-muted-foreground">
            {totalResults} route{totalResults !== 1 ? 's' : ''} found
          </div>

          {hasActiveFilters && (
            <div className="flex gap-2">
              <div className="text-xs text-muted-foreground">
                Filters active
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={handleClearFilters}
              >
                <X className="w-4 h-4 mr-1" />
                Clear
              </Button>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
};
