import React, { useState } from 'react';
import { LyxalConfigNamespace, SystemConfigItem, SystemConfigValue } from '../../../types/systemConfig';

interface ConfigFieldProps {
  namespace: LyxalConfigNamespace;
  configKey: string;
  configItem: SystemConfigItem;
  onUpdate: (namespace: LyxalConfigNamespace, key: string, value: SystemConfigValue, reason?: string) => Promise<void>;
}

export function ConfigField({ namespace, configKey, configItem, onUpdate }: ConfigFieldProps) {
  const [isEditing, setIsEditing] = useState(false);
  const [editValue, setEditValue] = useState(String(configItem.value || ''));
  const [reason, setReason] = useState('');
  const [isUpdating, setIsUpdating] = useState(false);

  const handleSave = async () => {
    if (!editValue.trim()) return;

    try {
      setIsUpdating(true);
      await onUpdate(namespace, configKey, editValue, reason || undefined);
      setIsEditing(false);
      setReason('');
    } catch (error) {
      console.error('Erreur lors de la sauvegarde:', error);
    } finally {
      setIsUpdating(false);
    }
  };

  const handleCancel = () => {
    setEditValue(String(configItem.value || ''));
    setReason('');
    setIsEditing(false);
  };

  const getFieldIcon = () => {
    switch (configItem.type) {
      case 'url': return '🔗';
      case 'email': return '📧';
      case 'boolean': return '🔘';
      case 'number': return '🔢';
      default: return '📝';
    }
  };

  return (
    <div className="border border-base-300 rounded-lg p-4 hover:border-primary transition-colors">
      <div className="flex items-start justify-between gap-4">
        <div className="flex-1">
          {/* En-tête du champ */}
          <div className="flex items-center gap-2 mb-2">
            <span className="text-lg">{getFieldIcon()}</span>
            <h3 className="font-semibold text-base-content">{configKey}</h3>
            {!configItem.editable && (
              <div className="badge badge-warning badge-sm">
                🔒 Protégé
              </div>
            )}
          </div>

          {/* Description */}
          <p className="text-sm text-base-content/70 mb-3">{configItem.description}</p>

          {/* Valeur actuelle ou champ d'édition */}
          {isEditing ? (
            <div className="space-y-3">
              <div className="form-control">
                <input
                  type={configItem.type === 'url' ? 'url' : 'text'}
                  value={editValue}
                  onChange={(e) => setEditValue(e.target.value)}
                  className="input input-bordered input-sm w-full"
                  placeholder={`Nouvelle valeur pour ${configKey}`}
                />
              </div>
              
              <div className="form-control">
                <input
                  type="text"
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  className="input input-bordered input-sm w-full"
                  placeholder="Raison du changement (optionnel)"
                />
              </div>

              <div className="flex gap-2">
                <button
                  onClick={handleSave}
                  disabled={!editValue.trim() || isUpdating}
                  className="btn btn-primary btn-sm"
                >
                  {isUpdating ? (
                    <>
                      <span className="loading loading-spinner loading-xs"></span>
                      Sauvegarde...
                    </>
                  ) : (
                    '✅ Sauvegarder'
                  )}
                </button>
                <button
                  onClick={handleCancel}
                  disabled={isUpdating}
                  className="btn btn-ghost btn-sm"
                >
                  ❌ Annuler
                </button>
              </div>
            </div>
          ) : (
            <div className="flex items-center justify-between">
              <div className="font-mono text-sm bg-base-200 px-3 py-2 rounded border">
                {String(configItem.value)}
              </div>
              
              {configItem.editable && (
                <button
                  onClick={() => setIsEditing(true)}
                  className="btn btn-ghost btn-sm"
                  title="Modifier cette valeur"
                >
                  ✏️ Modifier
                </button>
              )}
            </div>
          )}

          {/* Métadonnées */}
          {configItem.metadata && (
            <div className="mt-3 text-xs text-base-content/50">
              Dernière modification : {new Date(configItem.metadata.updatedAt).toLocaleString('fr-FR')}
              {configItem.metadata.updatedBy && ` par ${configItem.metadata.updatedBy}`}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}