import React from 'react';
import { LyxalConfigNamespace } from '../../../types/systemConfig';
import { useSystemConfig } from '../../../hooks/useSystemConfig';
import { ConfigField } from './ConfigField';

interface ConfigSectionProps {
  namespace: LyxalConfigNamespace;
  title: string;
  icon: string;
  description: string;
  priority?: 'high' | 'medium' | 'low';
}

export function ConfigSection({ 
  namespace, 
  title, 
  icon, 
  description, 
  priority = 'medium' 
}: ConfigSectionProps) {
  const { config, loading, updateConfig } = useSystemConfig(namespace);

  const priorityColors = {
    high: 'border-error',
    medium: 'border-warning', 
    low: 'border-info'
  };

  const namespaceConfig = config?.[namespace] || {};
  const configEntries = Object.entries(namespaceConfig);

  return (
    <div className={`card bg-base-100 shadow-lg border-2 ${priorityColors[priority]}`}>
      <div className="card-body">
        {/* Header de la section */}
        <div className="flex items-start gap-4 mb-6">
          <div className="flex-shrink-0">
            <span className="text-3xl">{icon}</span>
          </div>
          <div className="flex-1">
            <h2 className="card-title text-xl text-base-content">{title}</h2>
            <p className="text-sm text-base-content/70 mt-1">{description}</p>
            <div className="flex items-center gap-2 mt-2">
              <div className="badge badge-outline badge-sm">
                {namespace}
              </div>
              <div className={`badge badge-sm ${
                priority === 'high' ? 'badge-error' : 
                priority === 'medium' ? 'badge-warning' : 
                'badge-info'
              }`}>
                {priority === 'high' ? 'Critique' : 
                 priority === 'medium' ? 'Important' : 
                 'Standard'}
              </div>
            </div>
          </div>
        </div>

        {/* État de chargement */}
        {loading && (
          <div className="flex justify-center py-8">
            <span className="loading loading-spinner loading-md text-primary"></span>
          </div>
        )}

        {/* Liste des variables de configuration */}
        {!loading && (
          <div className="space-y-4">
            {configEntries.length === 0 ? (
              <div className="text-center py-8 text-base-content/50">
                <span className="text-2xl mb-2 block">📭</span>
                Aucune configuration trouvée pour ce namespace
              </div>
            ) : (
              configEntries.map(([key, configItem]) => (
                <ConfigField
                  key={key}
                  namespace={namespace}
                  configKey={key}
                  configItem={configItem}
                  onUpdate={updateConfig}
                />
              ))
            )}
          </div>
        )}

        {/* Footer avec compteur */}
        {!loading && configEntries.length > 0 && (
          <div className="card-actions justify-between items-center mt-6 pt-4 border-t border-base-300">
            <span className="text-sm text-base-content/70">
              {configEntries.length} variable{configEntries.length > 1 ? 's' : ''} configurée{configEntries.length > 1 ? 's' : ''}
            </span>
            <span className="text-sm text-base-content/70">
              {configEntries.filter(([, item]) => item.editable).length} modifiable{configEntries.filter(([, item]) => item.editable).length > 1 ? 's' : ''}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}