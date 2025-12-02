import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo, useCallback, useState } from 'react';
import { useSystemConfig } from '../../../hooks/useSystemConfig';
import { SystemConfigService } from '../../../services/SystemConfigService';
import { isProprietaireLevel, canViewSensitiveCredentials } from '@/types/systemConfig';
/**
 * Composant modal de configuration système
 * Fermeture uniquement via le bouton "Fermer" - pas de fermeture au clic sur l'écran
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
const ConfigModal = memo(({ isOpen, onClose }) => {
    // Hook pour récupérer la configuration système
    const { config } = useSystemConfig();
    // Service de configuration
    const configService = new SystemConfigService();
    // State pour gérer quel champ est en cours d'édition
    const [editingField, setEditingField] = useState(null);
    // State pour gérer le loading et les notifications
    const [isLoading, setIsLoading] = useState(null);
    const [notification, setNotification] = useState(null);
    // Récupérer le niveau architectural depuis la configuration système
    const architecturalLevel = Number(config?.identity?.niveauArchitectural?.value ?? 0);
    const isOwnerLevel = isProprietaireLevel(architecturalLevel);
    const canViewCredentials = canViewSensitiveCredentials(architecturalLevel, config);
    // Callback pour gérer la fermeture UNIQUEMENT via bouton
    const handleClose = useCallback(() => {
        setEditingField(null);
        setNotification(null);
        setIsLoading(null);
        onClose();
    }, [onClose]);
    // Callback pour empêcher la fermeture au clic sur l'overlay
    const handleOverlayClick = useCallback((e) => {
        // Ne pas fermer au clic sur l'écran - désactivé complètement
        e.stopPropagation();
    }, []);
    // Callback pour gérer les touches clavier (désactiver Escape aussi)
    const handleKeyDown = useCallback((e) => {
        // Désactiver la fermeture par Escape pour forcer l'utilisation du bouton
        if (e.key === 'Escape') {
            e.preventDefault();
            e.stopPropagation();
        }
    }, []);
    // Callback pour activer l'édition d'un champ
    const handleEditField = useCallback((fieldName) => {
        setEditingField(fieldName);
    }, []);
    // Callback pour annuler l'édition
    const handleCancelEdit = useCallback(() => {
        setEditingField(null);
    }, []);
    // Callback pour valider l'édition
    const handleValidateEdit = useCallback(async (fieldName) => {
        const inputElement = document.getElementById(`config-input-${fieldName}`);
        if (!inputElement)
            return;
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
            const configKeyMap = {
                'username': 'surrealUsername',
                'password': 'surrealPassword'
            };
            const configKey = configKeyMap[fieldName];
            if (!configKey) {
                throw new Error(`Clé de configuration non trouvée pour ${fieldName}`);
            }
            // Sauvegarder via le service
            await configService.updateConfig('infrastructure', configKey, newValue, `Modification de ${fieldName} via modal de configuration`);
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
        }
        catch (error) {
            console.error(`❌ Erreur lors de la mise à jour de ${fieldName}:`, error);
            setNotification({
                type: 'error',
                message: `Erreur lors de la sauvegarde: ${error instanceof Error ? error.message : 'Erreur inconnue'}`
            });
            // Auto-fermeture des erreurs après 5 secondes
            setTimeout(() => {
                setNotification(null);
            }, 5000);
        }
        finally {
            setIsLoading(null);
        }
    }, [configService]);
    if (!isOpen)
        return null;
    return (_jsx("div", { id: "config-modal-backdrop", className: "fixed inset-0 bg-black/80 flex items-center justify-center z-[1000] p-4", onClick: handleOverlayClick, onKeyDown: handleKeyDown, role: "dialog", "aria-modal": "true", "aria-labelledby": "config-modal-title", tabIndex: -1, children: _jsx("div", { id: "config-modal-container", className: "bg-base-100 rounded-lg shadow-xl w-full max-w-[90%] sm:max-w-2xl max-h-[90vh] overflow-hidden !p-5", onClick: (e) => e.stopPropagation(), children: _jsxs("div", { id: "config-modal-inner-container", className: "p-6 overflow-y-auto max-h-[90vh]", children: [_jsxs("div", { id: "config-modal-header", className: "flex justify-between items-center mb-6", children: [_jsx("h2", { id: "config-modal-title", className: "text-2xl font-bold text-base-content", children: "Configuration Syst\u00E8me" }), _jsx("button", { id: "config-modal-close-button", className: "btn btn-ghost btn-circle", onClick: handleClose, "aria-label": "Fermer la configuration", children: _jsx("svg", { id: "config-modal-close-icon", className: "w-6 h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M6 18L18 6M6 6l12 12" }) }) })] }), notification && (_jsxs("div", { className: `alert ${notification.type === 'success' ? 'alert-success' : 'alert-error'} mb-4`, children: [_jsx("svg", { className: "w-6 h-6 shrink-0", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: notification.type === 'success' ? (_jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" })) : (_jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" })) }), _jsx("span", { children: notification.message })] })), _jsxs("div", { id: "config-modal-content", className: "space-y-6", children: [_jsx("div", { id: "config-section-general", className: "card bg-base-200", children: _jsxs("div", { id: "config-section-general-body", className: "card-body", children: [_jsx("h3", { id: "config-section-general-title", className: "card-title text-lg", children: "Param\u00E8tres G\u00E9n\u00E9raux" }), _jsxs("div", { id: "config-field-platform-name", className: "form-control", children: [_jsx("label", { id: "config-label-platform-name", className: "label !pb-2", children: _jsx("span", { id: "config-label-platform-name-text", className: "label-text", children: "Nom de la plateforme" }) }), _jsx("input", { id: "config-input-platform-name", type: "text", placeholder: "LYXAL", className: "input input-bordered w-full !pl-4" })] }), _jsxs("div", { id: "config-field-description", className: "form-control", children: [_jsx("label", { id: "config-label-description", className: "label !pb-2", children: _jsx("span", { id: "config-label-description-text", className: "label-text", children: "Description" }) }), _jsx("textarea", { id: "config-textarea-description", className: "textarea textarea-bordered !pl-4", placeholder: "Console de gestion LYXAL" })] })] }) }), _jsx("div", { id: "config-section-database", className: "card bg-base-200 !p-2", children: _jsxs("div", { id: "config-section-database-container", className: "container flex flex-col gap-4", children: [_jsxs("div", { id: "config-section-database-body", className: "card-body", children: [_jsx("h3", { id: "config-section-database-title", className: "card-title text-lg", children: "Base de donn\u00E9es" }), _jsx("div", { id: "config-field-surreal-url", className: "form-control", children: _jsx("label", { id: "config-label-surreal-url", className: "label !pb-2", children: _jsxs("span", { id: "config-label-surreal-url-text", className: "label-text", children: ["URL SurrealDB : ", String(config?.infrastructure?.surrealDbUrl?.value || 'wss://accurate-horse-06bnu0f1k1tv1215mv54m347tc.aws-euw1.surreal.cloud/rpc')] }) }) }), _jsxs("div", { id: "config-grid-database-params", className: "grid grid-cols-2 gap-4", children: [_jsx("div", { id: "config-field-namespace", className: "form-control", children: _jsx("label", { id: "config-label-namespace", className: "label !pb-2", children: _jsxs("span", { id: "config-label-namespace-text", className: "label-text", children: ["Namespace : ", String(config?.infrastructure?.surrealNamespace?.value || 'lyxal_master')] }) }) }), _jsx("div", { id: "config-field-database", className: "form-control", children: _jsx("label", { id: "config-label-database", className: "label !pb-2", children: _jsxs("span", { id: "config-label-database-text", className: "label-text", children: ["Database : ", String(config?.infrastructure?.surrealDatabase?.value || 'platform_control')] }) }) })] }), canViewCredentials && (_jsxs("div", { id: "config-grid-credentials", className: "grid grid-cols-2 gap-4 mt-4", children: [_jsxs("div", { id: "config-field-username", className: "form-control", children: [_jsx("label", { id: "config-label-username", className: "label !pb-2", children: _jsxs("span", { id: "config-label-username-text", className: "label-text flex items-center gap-2", children: ["Utilisateur : ", String(config?.infrastructure?.surrealUsername?.value || 'lyxal_app_user'), _jsx("button", { className: "btn btn-xs btn-ghost", onClick: () => handleEditField('username'), "aria-label": "Modifier l'utilisateur", children: _jsx("svg", { className: "w-3 h-3", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" }) }) })] }) }), editingField === 'username' && (_jsxs("div", { className: "flex items-center gap-3 mt-2", children: [_jsx("input", { id: "config-input-username", type: "text", placeholder: "lyxal_app_user", defaultValue: String(config?.infrastructure?.surrealUsername?.value || ''), className: "input input-bordered w-full !pl-4", autoFocus: true }), _jsx("button", { className: "btn btn-sm btn-neutral !h-10 !w-10", onClick: () => handleValidateEdit('username'), disabled: isLoading === 'username', title: "Valider", children: isLoading === 'username' ? (_jsx("span", { className: "loading loading-spinner loading-xs" })) : (_jsx("svg", { className: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M5 13l4 4L19 7" }) })) }), _jsx("button", { className: "btn btn-sm btn-primary !h-10 !w-10", onClick: handleCancelEdit, title: "Annuler", children: _jsx("svg", { className: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M6 18L18 6M6 6l12 12" }) }) })] }))] }), _jsxs("div", { id: "config-field-password", className: "form-control", children: [_jsx("label", { id: "config-label-password", className: "label !pb-2", children: _jsxs("span", { id: "config-label-password-text", className: "label-text flex items-center gap-2", children: ["Mot de passe : \u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022", _jsx("button", { className: "btn btn-xs btn-ghost", onClick: () => handleEditField('password'), "aria-label": "Modifier le mot de passe", children: _jsx("svg", { className: "w-3 h-3", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" }) }) })] }) }), editingField === 'password' && (_jsxs("div", { className: "flex items-center gap-3 mt-2", children: [_jsx("input", { id: "config-input-password", type: "password", placeholder: "\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022", defaultValue: String(config?.infrastructure?.surrealPassword?.value || ''), className: "input input-bordered w-full !pl-4", autoFocus: true }), _jsx("button", { className: "btn btn-sm btn-neutral !h-10 !w-10", onClick: () => handleValidateEdit('password'), disabled: isLoading === 'password', title: "Valider", children: isLoading === 'password' ? (_jsx("span", { className: "loading loading-spinner loading-xs" })) : (_jsx("svg", { className: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M5 13l4 4L19 7" }) })) }), _jsx("button", { className: "btn btn-sm btn-primary !h-10 !w-10", onClick: handleCancelEdit, title: "Annuler", children: _jsx("svg", { className: "w-4 h-4", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M6 18L18 6M6 6l12 12" }) }) })] }))] })] }))] }), isOwnerLevel && (_jsx("div", { id: "config-section-database-button-container", children: _jsx("button", { id: "config-section-database-migration-button", className: "btn btn-neutral w-full", children: "Migration" }) }))] }) }), _jsx("div", { id: "config-section-security", className: "card bg-base-200", children: _jsxs("div", { id: "config-section-security-body", className: "card-body", children: [_jsx("h3", { id: "config-section-security-title", className: "card-title text-lg", children: "S\u00E9curit\u00E9" }), _jsx("div", { id: "config-field-2fa", className: "form-control", children: _jsxs("label", { id: "config-label-2fa", className: "label cursor-pointer !pb-2", children: [_jsx("span", { id: "config-label-2fa-text", className: "label-text", children: "Authentification \u00E0 deux facteurs" }), _jsx("input", { id: "config-toggle-2fa", type: "checkbox", className: "toggle toggle-primary" })] }) }), _jsx("div", { id: "config-field-logging", className: "form-control", children: _jsxs("label", { id: "config-label-logging", className: "label cursor-pointer !pb-2", children: [_jsx("span", { id: "config-label-logging-text", className: "label-text", children: "Logging des actions" }), _jsx("input", { id: "config-toggle-logging", type: "checkbox", className: "toggle toggle-primary", defaultChecked: true })] }) }), _jsxs("div", { id: "config-field-session-duration", className: "form-control", children: [_jsx("label", { id: "config-label-session-duration", className: "label !pb-2", children: _jsx("span", { id: "config-label-session-duration-text", className: "label-text", children: "Dur\u00E9e de session (minutes)" }) }), _jsx("input", { id: "config-input-session-duration", type: "number", placeholder: "60", className: "input input-bordered w-full !pl-4", min: "5", max: "1440" })] })] }) })] }), _jsxs("div", { id: "config-modal-actions", className: "flex justify-end gap-3 mt-8", children: [_jsx("button", { id: "config-button-cancel", className: "btn btn-ghost", onClick: handleClose, children: "Fermer" }), _jsx("button", { id: "config-button-save", className: "btn btn-primary", children: "Sauvegarder" })] })] }) }) }));
});
// Nom d'affichage pour le débogage
ConfigModal.displayName = 'ConfigModal';
export default ConfigModal;
