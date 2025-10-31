import React, { memo, useCallback, useState } from 'react';
import { useSystemConfig } from '../../../../hooks/useSystemConfig';
import { SystemConfigService } from '../../../../services/SystemConfigService';
import { isProprietaireLevel, canViewSensitiveCredentials } from '@/types/systemConfig';

/**
 * Props pour le composant ConfigModal
 * @interface ConfigModalProps
 */
interface ConfigModalProps {
  /** État d'ouverture du modal */
  isOpen: boolean;
  /** Callback pour fermer le modal */
  onClose: () => void;
}

/**
 * Composant modal de configuration système
 * Fermeture uniquement via le bouton "Fermer" - pas de fermeture au clic sur l'écran
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const ConfigModal: React.FC<ConfigModalProps> = memo(({ isOpen, onClose }) => {
  // Hook pour récupérer la configuration système
  const { config } = useSystemConfig();
  
  // Service de configuration
  const configService = new SystemConfigService();
  
  // State pour gérer quel champ est en cours d'édition
  const [editingField, setEditingField] = useState<string | null>(null);
  
  // State pour gérer le loading et les notifications
  const [isLoading, setIsLoading] = useState<string | null>(null);
  const [notification, setNotification] = useState<{
    type: 'success' | 'error';
    message: string;
  } | null>(null);
  
  // Récupérer le niveau architectural depuis la configuration système
  const architecturalLevel = Number(config?.identity?.niveauArchitectural?.value ?? 0);
  const isOwnerLevel = isProprietaireLevel(architecturalLevel);
  const canViewCredentials = canViewSensitiveCredentials(architecturalLevel, config as any);
  
  // Callback pour gérer la fermeture UNIQUEMENT via bouton
  const handleClose = useCallback(() => {
    setEditingField(null);
    setNotification(null);
    setIsLoading(null);
    onClose();
  }, [onClose]);

  // Callback pour empêcher la fermeture au clic sur l'overlay
  const handleOverlayClick = useCallback((e: React.MouseEvent) => {
    // Ne pas fermer au clic sur l'écran - désactivé complètement
    e.stopPropagation();
  }, []);

  // Callback pour gérer les touches clavier (désactiver Escape aussi)
  const handleKeyDown = useCallback((e: React.KeyboardEvent) => {
    // Désactiver la fermeture par Escape pour forcer l'utilisation du bouton
    if (e.key === 'Escape') {
      e.preventDefault();
      e.stopPropagation();
    }
  }, []);

  // Callback pour activer l'édition d'un champ
  const handleEditField = useCallback((fieldName: string) => {
    setEditingField(fieldName);
  }, []);

  // Callback pour annuler l'édition
  const handleCancelEdit = useCallback(() => {
    setEditingField(null);
  }, []);

  // Callback pour valider l'édition
  const handleValidateEdit = useCallback(async (fieldName: string) => {
    const inputElement = document.getElementById(`config-input-${fieldName}`) as HTMLInputElement;
    if (!inputElement) return;

    const newValue = inputElement.value.trim();
    
    // Validation avancée
    if (!newValue) {
      setNotification({
        type: 'error',
        message: 'La valeur ne peut pas être vide'
      });
      setTimeout(() => setNotification(null), 3000);
      return;
    }

    // Validation spécifique par champ
    if (fieldName === 'username' && newValue.length < 3) {
      setNotification({
        type: 'error',
        message: 'Le nom d\'utilisateur doit contenir au moins 3 caractères'
      });
      setTimeout(() => setNotification(null), 3000);
      return;
    }

    if (fieldName === 'password' && newValue.length < 8) {
      setNotification({
        type: 'error',
        message: 'Le mot de passe doit contenir au moins 8 caractères'
      });
      setTimeout(() => setNotification(null), 3000);
      return;
    }

    // Démarrer le loading
    setIsLoading(fieldName);
    setNotification(null);

    try {
      // Mapping des noms de champs vers les clés de configuration
      const configKeyMap: Record<string, string> = {
        'username': 'surrealUsername',
        'password': 'surrealPassword'
      };

      const configKey = configKeyMap[fieldName];
      if (!configKey) {
        throw new Error(`Clé de configuration non trouvée pour ${fieldName}`);
      }

      // Sauvegarder via le service
      await configService.updateConfig(
        'infrastructure', 
        configKey, 
        newValue,
        `Modification de ${fieldName} via modal de configuration`
      );
      
      // Notification de succès
      setNotification({
        type: 'success',
        message: `${fieldName === 'username' ? 'Utilisateur' : 'Mot de passe'} mis à jour avec succès`
      });
      
      // Fermer l'édition après un délai
      setTimeout(() => {
        setEditingField(null);
        setNotification(null);
      }, 2000);
      
    } catch (error) {
      console.error(`❌ Erreur lors de la mise à jour de ${fieldName}:`, error);
      setNotification({
        type: 'error',
        message: `Erreur lors de la sauvegarde: ${error instanceof Error ? error.message : 'Erreur inconnue'}`
      });
      
      // Auto-fermeture des erreurs après 5 secondes
      setTimeout(() => {
        setNotification(null);
      }, 5000);
    } finally {
      setIsLoading(null);
    }
  }, [configService]);

  if (!isOpen) return null;

  return (
    <div 
      id="config-modal-backdrop"
      className="fixed inset-0 bg-black/80 flex items-center justify-center z-[1000] p-4"
      onClick={handleOverlayClick}
      onKeyDown={handleKeyDown}
      role="dialog"
      aria-modal="true"
      aria-labelledby="config-modal-title"
      tabIndex={-1}
    >
      <div 
        id="config-modal-container"
        className="bg-base-100 rounded-lg shadow-xl w-full max-w-[90%] sm:max-w-2xl max-h-[90vh] overflow-hidden !p-5"
        onClick={(e) => e.stopPropagation()} // Empêcher la propagation des clics
      >
        <div 
          id="config-modal-inner-container"
          className="p-6 overflow-y-auto max-h-[90vh]"
        >
          <div id="config-modal-header" className="flex justify-between items-center mb-6">
            <h2 id="config-modal-title" className="text-2xl font-bold text-base-content">
              Configuration Système
            </h2>
            <button 
              id="config-modal-close-button"
              className="btn btn-ghost btn-circle"
              onClick={handleClose}
              aria-label="Fermer la configuration"
            >
              <svg id="config-modal-close-icon" className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Notification */}
          {notification && (
            <div className={`alert ${notification.type === 'success' ? 'alert-success' : 'alert-error'} mb-4`}>
              <svg className="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                {notification.type === 'success' ? (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                ) : (
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                )}
              </svg>
              <span>{notification.message}</span>
            </div>
          )}

          <div id="config-modal-content" className="space-y-6">
            {/* Section Général */}
            <div id="config-section-general" className="card bg-base-200">
              <div id="config-section-general-body" className="card-body">
                <h3 id="config-section-general-title" className="card-title text-lg">Paramètres Généraux</h3>
                <div id="config-field-platform-name" className="form-control">
                  <label id="config-label-platform-name" className="label !pb-2">
                    <span id="config-label-platform-name-text" className="label-text">Nom de la plateforme</span>
                  </label>
                  <input 
                    id="config-input-platform-name"
                    type="text" 
                    placeholder="LYXAL" 
                    className="input input-bordered w-full !pl-4" 
                  />
                </div>
                <div id="config-field-description" className="form-control">
                  <label id="config-label-description" className="label !pb-2">
                    <span id="config-label-description-text" className="label-text">Description</span>
                  </label>
                  <textarea 
                    id="config-textarea-description"
                    className="textarea textarea-bordered !pl-4" 
                    placeholder="Console de gestion LYXAL"
                  ></textarea>
                </div>
              </div>
            </div>

            {/* Section Base de données */}
            <div id="config-section-database" className="card bg-base-200 !p-2">
              <div id="config-section-database-container" className="container flex flex-col gap-4">
                <div id="config-section-database-body" className="card-body">
                <h3 id="config-section-database-title" className="card-title text-lg">Base de données</h3>
                <div id="config-field-surreal-url" className="form-control">
                  <label id="config-label-surreal-url" className="label !pb-2">
                    <span id="config-label-surreal-url-text" className="label-text">URL SurrealDB : {String(config?.infrastructure?.surrealDbUrl?.value || 'wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc')}</span>
                  </label>
                </div>
                <div id="config-grid-database-params" className="grid grid-cols-2 gap-4">
                  <div id="config-field-namespace" className="form-control">
                    <label id="config-label-namespace" className="label !pb-2">
                      <span id="config-label-namespace-text" className="label-text">Namespace : {String(config?.infrastructure?.surrealNamespace?.value || 'lyxal_master')}</span>
                    </label>
                  </div>
                  <div id="config-field-database" className="form-control">
                    <label id="config-label-database" className="label !pb-2">
                      <span id="config-label-database-text" className="label-text">Database : {String(config?.infrastructure?.surrealDatabase?.value || 'platform_control')}</span>
                    </label>
                  </div>
                </div>
                
                {/* Identifiants instance - Visibles seulement pour PROPRIÉTAIRE + ADMIN */}
                {canViewCredentials && (
                  <div id="config-grid-credentials" className="grid grid-cols-2 gap-4 mt-4">
                    <div id="config-field-username" className="form-control">
                      <label id="config-label-username" className="label !pb-2">
                        <span id="config-label-username-text" className="label-text flex items-center gap-2">
                          Utilisateur : {String(config?.infrastructure?.surrealUsername?.value || 'lyxal_app_user')}
                          <button 
                            className="btn btn-xs btn-ghost"
                            onClick={() => handleEditField('username')}
                            aria-label="Modifier l'utilisateur"
                          >
                            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                          </button>
                        </span>
                      </label>
                      {editingField === 'username' && (
                        <div className="flex items-center gap-3 mt-2">
                          <input 
                            id="config-input-username"
                            type="text"
                            placeholder="lyxal_app_user"
                            defaultValue={String(config?.infrastructure?.surrealUsername?.value || '')}
                            className="input input-bordered w-full !pl-4"
                            autoFocus
                          />
                          <button 
                            className="btn btn-sm btn-neutral !h-10 !w-10"
                            onClick={() => handleValidateEdit('username')}
                            disabled={isLoading === 'username'}
                            title="Valider"
                          >
                            {isLoading === 'username' ? (
                              <span className="loading loading-spinner loading-xs"></span>
                            ) : (
                              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                              </svg>
                            )}
                          </button>
                          <button 
                            className="btn btn-sm btn-primary !h-10 !w-10"
                            onClick={handleCancelEdit}
                            title="Annuler"
                          >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          </button>
                        </div>
                      )}
                    </div>
                    <div id="config-field-password" className="form-control">
                      <label id="config-label-password" className="label !pb-2">
                        <span id="config-label-password-text" className="label-text flex items-center gap-2">
                          Mot de passe : ••••••••••••
                          <button 
                            className="btn btn-xs btn-ghost"
                            onClick={() => handleEditField('password')}
                            aria-label="Modifier le mot de passe"
                          >
                            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                            </svg>
                          </button>
                        </span>
                      </label>
                      {editingField === 'password' && (
                        <div className="flex items-center gap-3 mt-2">
                          <input 
                            id="config-input-password"
                            type="password"
                            placeholder="••••••••••••"
                            defaultValue={String(config?.infrastructure?.surrealPassword?.value || '')}
                            className="input input-bordered w-full !pl-4"
                            autoFocus
                          />
                          <button 
                            className="btn btn-sm btn-neutral !h-10 !w-10"
                            onClick={() => handleValidateEdit('password')}
                            disabled={isLoading === 'password'}
                            title="Valider"
                          >
                            {isLoading === 'password' ? (
                              <span className="loading loading-spinner loading-xs"></span>
                            ) : (
                              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M5 13l4 4L19 7" />
                              </svg>
                            )}
                          </button>
                          <button 
                            className="btn btn-sm btn-primary !h-10 !w-10"
                            onClick={handleCancelEdit}
                            title="Annuler"
                          >
                            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                )}
                </div>
                {/* Bouton Migration - Visible seulement pour le niveau PROPRIÉTAIRE */}
                {isOwnerLevel && (
                  <div id="config-section-database-button-container">
                    <button id="config-section-database-migration-button" className="btn btn-neutral w-full">
                      Migration
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Section Sécurité */}
            <div id="config-section-security" className="card bg-base-200">
              <div id="config-section-security-body" className="card-body">
                <h3 id="config-section-security-title" className="card-title text-lg">Sécurité</h3>
                <div id="config-field-2fa" className="form-control">
                  <label id="config-label-2fa" className="label cursor-pointer !pb-2">
                    <span id="config-label-2fa-text" className="label-text">Authentification à deux facteurs</span>
                    <input id="config-toggle-2fa" type="checkbox" className="toggle toggle-primary" />
                  </label>
                </div>
                <div id="config-field-logging" className="form-control">
                  <label id="config-label-logging" className="label cursor-pointer !pb-2">
                    <span id="config-label-logging-text" className="label-text">Logging des actions</span>
                    <input id="config-toggle-logging" type="checkbox" className="toggle toggle-primary" defaultChecked />
                  </label>
                </div>
                <div id="config-field-session-duration" className="form-control">
                  <label id="config-label-session-duration" className="label !pb-2">
                    <span id="config-label-session-duration-text" className="label-text">Durée de session (minutes)</span>
                  </label>
                  <input 
                    id="config-input-session-duration"
                    type="number" 
                    placeholder="60" 
                    className="input input-bordered w-full !pl-4" 
                    min="5"
                    max="1440"
                  />
                </div>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div id="config-modal-actions" className="flex justify-end gap-3 mt-8">
            <button 
              id="config-button-cancel"
              className="btn btn-ghost"
              onClick={handleClose}
            >
              Fermer
            </button>
            <button id="config-button-save" className="btn btn-primary">
              Sauvegarder
            </button>
          </div>
        </div>
      </div>
    </div>
  );
});

// Nom d'affichage pour le débogage
ConfigModal.displayName = 'ConfigModal';

export default ConfigModal; 