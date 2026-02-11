import { useState, useEffect, useCallback, useMemo } from 'react';
import WorkspaceDataTableService, { DataTableConfig } from '@lyxalsuite/lyxal-base/services/WorkspaceDataTableService';
import { message } from 'antd';

export interface UseWorkspaceDataTableOptions {
  workspaceId: string;
  moduleName: string;
  tableName: string;
  autoLoad?: boolean;
  initialPageSize?: number;
  onError?: (error: Error) => void;
}

export interface UseWorkspaceDataTableReturn {
  // État des données
  data: any[];
  total: number;
  loading: boolean;
  config: DataTableConfig | null;
  
  // Pagination
  currentPage: number;
  pageSize: number;
  
  // Tri et filtres
  sortField?: string;
  sortOrder?: 'asc' | 'desc';
  filters: Record<string, any>;
  searchValue: string;
  
  // Actions de données
  loadData: () => Promise<void>;
  createRecord: (data: Record<string, any>) => Promise<any>;
  updateRecord: (id: string, data: Record<string, any>) => Promise<any>;
  deleteRecord: (id: string) => Promise<void>;
  
  // Actions d'interface
  setCurrentPage: (page: number) => void;
  setPageSize: (size: number) => void;
  setSorting: (field?: string, order?: 'asc' | 'desc') => void;
  setFilters: (filters: Record<string, any>) => void;
  setSearchValue: (value: string) => void;
  resetFilters: () => void;
  
  // Utilitaires
  refresh: () => Promise<void>;
  hasPermission: (permission: string[]) => boolean;
}

export const useWorkspaceDataTable = (
  options: UseWorkspaceDataTableOptions
): UseWorkspaceDataTableReturn => {
  const {
    workspaceId,
    moduleName,
    tableName,
    autoLoad = true,
    initialPageSize = 20,
    onError
  } = options;

  // Service
  const dataTableService = useMemo(() => new WorkspaceDataTableService(), []);

  // État des données
  const [data, setData] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(false);
  const [config, setConfig] = useState<DataTableConfig | null>(null);

  // État de la pagination
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(initialPageSize);

  // État du tri et des filtres
  const [sortField, setSortField] = useState<string>();
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>();
  const [filters, setFilters] = useState<Record<string, any>>({});
  const [searchValue, setSearchValue] = useState('');

  // Fonction de chargement des données
  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      
      const result = await dataTableService.getTableData(workspaceId, moduleName, tableName, {
        page: currentPage,
        pageSize,
        sortField,
        sortOrder,
        filters,
        search: searchValue
      });

      setData(result.data);
      setTotal(result.total);
      setConfig(result.config);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors du chargement des données';
      console.error('Erreur lors du chargement:', error);
      
      if (onError) {
        onError(error instanceof Error ? error : new Error(errorMessage));
      } else {
        message.error(errorMessage);
      }
    } finally {
      setLoading(false);
    }
  }, [
    dataTableService,
    workspaceId,
    moduleName,
    tableName,
    currentPage,
    pageSize,
    sortField,
    sortOrder,
    filters,
    searchValue,
    onError
  ]);

  // Chargement automatique
  useEffect(() => {
    if (autoLoad) {
      loadData();
    }
  }, [loadData, autoLoad]);

  // Actions CRUD
  const createRecord = useCallback(async (recordData: Record<string, any>) => {
    try {
      setLoading(true);
      const result = await dataTableService.createRecord(workspaceId, moduleName, tableName, recordData);
      message.success('Enregistrement créé avec succès');
      await loadData(); // Recharger les données
      return result;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors de la création';
      console.error('Erreur lors de la création:', error);
      message.error(errorMessage);
      throw error;
    } finally {
      setLoading(false);
    }
  }, [dataTableService, workspaceId, moduleName, tableName, loadData]);

  const updateRecord = useCallback(async (id: string, recordData: Record<string, any>) => {
    try {
      setLoading(true);
      const result = await dataTableService.updateRecord(workspaceId, moduleName, tableName, id, recordData);
      message.success('Enregistrement mis à jour avec succès');
      await loadData(); // Recharger les données
      return result;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors de la mise à jour';
      console.error('Erreur lors de la mise à jour:', error);
      message.error(errorMessage);
      throw error;
    } finally {
      setLoading(false);
    }
  }, [dataTableService, workspaceId, moduleName, tableName, loadData]);

  const deleteRecord = useCallback(async (id: string) => {
    try {
      setLoading(true);
      await dataTableService.deleteRecord(workspaceId, moduleName, tableName, id);
      message.success('Enregistrement supprimé avec succès');
      await loadData(); // Recharger les données
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors de la suppression';
      console.error('Erreur lors de la suppression:', error);
      message.error(errorMessage);
      throw error;
    } finally {
      setLoading(false);
    }
  }, [dataTableService, workspaceId, moduleName, tableName, loadData]);

  // Actions d'interface
  const handleSetCurrentPage = useCallback((page: number) => {
    setCurrentPage(page);
  }, []);

  const handleSetPageSize = useCallback((size: number) => {
    setPageSize(size);
    setCurrentPage(1); // Retour à la première page
  }, []);

  const setSorting = useCallback((field?: string, order?: 'asc' | 'desc') => {
    setSortField(field);
    setSortOrder(order);
    setCurrentPage(1); // Retour à la première page
  }, []);

  const handleSetFilters = useCallback((newFilters: Record<string, any>) => {
    setFilters(newFilters);
    setCurrentPage(1); // Retour à la première page
  }, []);

  const handleSetSearchValue = useCallback((value: string) => {
    setSearchValue(value);
    setCurrentPage(1); // Retour à la première page
  }, []);

  const resetFilters = useCallback(() => {
    setFilters({});
    setSearchValue('');
    setSortField(undefined);
    setSortOrder(undefined);
    setCurrentPage(1);
  }, []);

  // Utilitaires
  const refresh = useCallback(async () => {
    await loadData();
  }, [loadData]);

  const hasPermission = useCallback((permission: string[]) => {
    if (!config) return false;
    
    // Logique de vérification des permissions
    // Ceci devrait être adapté selon votre système de permissions
    return true; // Placeholder
  }, [config]);

  return {
    // État des données
    data,
    total,
    loading,
    config,
    
    // Pagination
    currentPage,
    pageSize,
    
    // Tri et filtres
    sortField,
    sortOrder,
    filters,
    searchValue,
    
    // Actions de données
    loadData,
    createRecord,
    updateRecord,
    deleteRecord,
    
    // Actions d'interface
    setCurrentPage: handleSetCurrentPage,
    setPageSize: handleSetPageSize,
    setSorting,
    setFilters: handleSetFilters,
    setSearchValue: handleSetSearchValue,
    resetFilters,
    
    // Utilitaires
    refresh,
    hasPermission,
  };
};

export default useWorkspaceDataTable; 