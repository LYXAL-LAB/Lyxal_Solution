import React from 'react';
import { clsx } from 'clsx';
import { Button } from '../components/Button/Button';
import { Badge } from '../components/Badge/Badge';
import { Table } from '../components/Table/Table';
import { Loader } from '../components/Loader/Loader';
import { useTheme } from '../theme/hooks/useTheme';
import { getAllThemes, setActiveTheme, ThemeDefinition } from '../theme/core/registry';
import './Dashboard.css';

export interface DashboardStats {
  /** Titre de la statistique */
  title: string;
  /** Valeur de la statistique */
  value: string | number;
  /** Changement par rapport à la période précédente */
  change?: {
    value: number;
    type: 'increase' | 'decrease' | 'neutral';
  };
  /** Icône de la statistique */
  icon?: React.ReactNode;
  /** Couleur de la carte */
  color?: 'primary' | 'secondary' | 'success' | 'warning' | 'error';
}

export interface DashboardAction {
  /** Libellé de l'action */
  label: string;
  /** Fonction appelée au clic */
  onClick: () => void;
  /** Variante du bouton */
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
  /** Icône de l'action */
  icon?: React.ReactNode;
  /** Action désactivée */
  disabled?: boolean;
}

export interface DashboardProps {
  /** Titre du dashboard */
  title?: string;
  /** Sous-titre ou description */
  subtitle?: string;
  /** Statistiques à afficher */
  stats?: DashboardStats[];
  /** Actions rapides */
  actions?: DashboardAction[];
  /** Données du tableau principal */
  tableData?: {
    columns: Array<{
      key: string;
      title: string;
      sortable?: boolean;
      render?: (value: any, record: any) => React.ReactNode;
    }>;
    data: any[];
    loading?: boolean;
    emptyText?: string;
  };
  /** Contenu personnalisé */
  children?: React.ReactNode;
  /** État de chargement global */
  loading?: boolean;
  /** Classe CSS personnalisée */
  className?: string;
  /** Fonction de rafraîchissement */
  onRefresh?: () => void;
  /** Informations utilisateur */
  user?: {
    name: string;
    avatar?: string;
    role?: string;
  };
}

/**
 * Page de tableau de bord prête à l'emploi
 */
export function Dashboard({
  title = 'Tableau de bord',
  subtitle,
  stats = [],
  actions = [],
  tableData,
  children,
  loading = false,
  className,
  onRefresh,
  user,
}: DashboardProps) {
  const { currentTheme: theme } = useTheme();
  const [refreshing, setRefreshing] = React.useState(false);
  const [themes, setThemes] = React.useState<ThemeDefinition[]>([]);
  const [activeTheme, setActiveThemeState] = React.useState<ThemeDefinition | null>(null);

  // Charger les thèmes disponibles
  React.useEffect(() => {
    const allThemes = getAllThemes();
    setThemes(allThemes);
    
    // Identifier le thème actif
    const currentTheme = allThemes.find((t: ThemeDefinition) => t.id === theme?.id) || null;
    setActiveThemeState(currentTheme);
    
    // Écouter les changements de thème
    const handleThemeChange = () => {
      const newThemes = getAllThemes();
      setThemes(newThemes);
      const updatedCurrentTheme = newThemes.find((t: ThemeDefinition) => t.id === theme?.id) || null;
      setActiveThemeState(updatedCurrentTheme);
    };
    
    window.addEventListener('themeChanged', handleThemeChange);
    return () => {
      window.removeEventListener('themeChanged', handleThemeChange);
    };
  }, [theme]);

  // Gestion du changement de thème
  const handleThemeChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const selectedThemeId = event.target.value;
    if (selectedThemeId) {
      // Définir le thème actif
      setActiveTheme(selectedThemeId);
      
      // Émettre un événement pour notifier les autres composants
      const themeChangedEvent = new CustomEvent('themeChanged', { 
        detail: { themeId: selectedThemeId }
      });
      window.dispatchEvent(themeChangedEvent);
    }
  };

  // Gestion du rafraîchissement
  const handleRefresh = React.useCallback(async () => {
    if (refreshing || !onRefresh) return;
    
    setRefreshing(true);
    try {
      await onRefresh();
    } finally {
      setRefreshing(false);
    }
  }, [refreshing, onRefresh]);

  // Formatage des changements de statistiques
  const formatChange = React.useCallback((change: DashboardStats['change']) => {
    if (!change) return null;
    
    const { value, type } = change;
    const sign = value > 0 ? '+' : '';
    const color = type === 'increase' ? 'success' : type === 'decrease' ? 'error' : 'primary';
    
    return (
      <Badge
        variant={color}
        size="sm"
        icon={
          type === 'increase' ? (
            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 17l9.2-9.2M17 17V7H7" />
            </svg>
          ) : type === 'decrease' ? (
            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 7l-9.2 9.2M7 7v10h10" />
            </svg>
          ) : null
        }
      >
        {sign}{value}%
      </Badge>
    );
  }, []);

  if (loading) {
    return (
      <div className="dashboard-loading" style={{ backgroundColor: 'var(--color-base-100)' }}>
        <Loader
          variant="spinner"
          size="lg"
          color="primary"
          label="Chargement du tableau de bord..."
        />
      </div>
    );
  }

  return (
    <div className={clsx('dashboard', className)} style={{ backgroundColor: 'var(--color-base-100)' }}>
      {/* Header */}
      <div className="dashboard-header" style={{ borderColor: 'var(--color-base-300)' }}>
        <div className="dashboard-header-content">
          <div>
            <h1 className="dashboard-title" style={{ color: 'var(--color-base-content)' }}>{title}</h1>
            {subtitle && <p className="dashboard-subtitle" style={{ color: 'var(--color-base-content-secondary)' }}>{subtitle}</p>}
          </div>
          
          <div className="dashboard-header-actions">
            {/* Sélecteur de thème */}
            <div className="dashboard-theme-selector">
              <select
                value={activeTheme?.id || ''}
                onChange={handleThemeChange}
                style={{
                  padding: '0.5rem 2rem 0.5rem 0.75rem',
                  border: '1px solid var(--color-base-300)',
                  borderRadius: 'var(--radius-field, 0.25rem)',
                  backgroundColor: 'var(--color-base-200)',
                  color: 'var(--color-base-content)',
                  appearance: 'none',
                  backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%23666'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E")`,
                  backgroundRepeat: 'no-repeat',
                  backgroundPosition: 'right 0.5rem center',
                  backgroundSize: '1rem',
                  fontSize: '0.875rem',
                  cursor: 'pointer',
                  minWidth: '120px',
                  maxWidth: '180px',
                  textOverflow: 'ellipsis',
                  whiteSpace: 'nowrap',
                  overflow: 'hidden',
                }}
              >
                <option value="" disabled>Thème</option>
                {themes.map(t => (
                  <option key={t.id} value={t.id}>
                    {t.label} {t.isDark ? '(sombre)' : ''}
                  </option>
                ))}
              </select>
            </div>
            
            {user && (
              <div className="dashboard-user" style={{ backgroundColor: 'var(--color-base-200)', borderColor: 'var(--color-base-300)' }}>
                {user.avatar && (
                  <img
                    src={user.avatar}
                    alt={user.name}
                    className="dashboard-user-avatar"
                  />
                )}
                <div className="dashboard-user-info">
                  <span className="dashboard-user-name" style={{ color: 'var(--color-base-content)' }}>{user.name}</span>
                  {user.role && (
                    <span className="dashboard-user-role" style={{ color: 'var(--color-base-content-secondary)' }}>{user.role}</span>
                  )}
                </div>
              </div>
            )}
            
            {onRefresh && (
              <Button
                variant="outline"
                size="md"
                onClick={handleRefresh}
                loading={refreshing}
                icon={
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                  </svg>
                }
              >
                Actualiser
              </Button>
            )}
          </div>
        </div>
      </div>

      {/* Statistiques */}
      {stats.length > 0 && (
        <div className="dashboard-stats">
          {stats.map((stat, index) => (
            <div
              key={index}
              className={clsx(
                'dashboard-stat-card',
                stat.color && `dashboard-stat-card--${stat.color}`
              )}
              style={{ 
                backgroundColor: 'var(--color-base-200)', 
                borderColor: stat.color ? `var(--color-${stat.color})` : 'var(--color-base-300)' 
              }}
            >
              <div className="dashboard-stat-header">
                {stat.icon && (
                  <div 
                    className="dashboard-stat-icon"
                    style={{ 
                      backgroundColor: stat.color ? `var(--color-${stat.color}-light)` : 'var(--color-primary-light)',
                      color: stat.color ? `var(--color-${stat.color})` : 'var(--color-primary)'
                    }}
                  >
                    {stat.icon}
                  </div>
                )}
                <div className="dashboard-stat-content">
                  <div className="dashboard-stat-title" style={{ color: 'var(--color-base-content-secondary)' }}>{stat.title}</div>
                  <div className="dashboard-stat-value" style={{ color: 'var(--color-base-content)' }}>{stat.value}</div>
                </div>
              </div>
              {stat.change && (
                <div className="dashboard-stat-change">
                  {formatChange(stat.change)}
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Actions rapides */}
      {actions.length > 0 && (
        <div className="dashboard-actions">
          <h2 className="dashboard-section-title" style={{ color: 'var(--color-base-content)' }}>Actions rapides</h2>
          <div className="dashboard-actions-grid">
            {actions.map((action, index) => (
              <Button
                key={index}
                variant={action.variant || 'outline'}
                size="lg"
                icon={action.icon}
                onClick={action.onClick}
                disabled={action.disabled}
                className="dashboard-action-button"
              >
                {action.label}
              </Button>
            ))}
          </div>
        </div>
      )}

      {/* Tableau principal */}
      {tableData && (
        <div className="dashboard-table">
          <h2 className="dashboard-section-title" style={{ color: 'var(--color-base-content)' }}>Données récentes</h2>
          <div className="dashboard-table-wrapper">
            {tableData.loading ? (
              <Loader variant="spinner" size="md" color="primary" label="Chargement des données..." />
            ) : tableData.data.length === 0 ? (
              <div className="dashboard-table-empty">{tableData.emptyText || 'Aucune donnée disponible'}</div>
            ) : (
              <table className="dashboard-table-content">
                <thead>
                  <tr>
                    {tableData.columns.map((column, index) => (
                      <th key={index}>{column.title}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {tableData.data.map((row, rowIndex) => (
                    <tr key={rowIndex}>
                      {tableData.columns.map((column, colIndex) => (
                        <td key={colIndex}>
                          {column.render ? column.render(row[column.key], row) : row[column.key]}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      )}

      {/* Contenu personnalisé */}
      {children && (
        <div className="dashboard-custom">
          {children}
        </div>
      )}
    </div>
  );
}