import React from 'react';
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
declare const ConfigModal: React.FC<ConfigModalProps>;
export default ConfigModal;
