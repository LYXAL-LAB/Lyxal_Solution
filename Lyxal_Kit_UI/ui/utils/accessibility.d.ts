/**
 * Utilitaires pour l'accessibilité avancée
 * Fournit des fonctions pour améliorer l'expérience utilisateur avec les technologies d'assistance
 */
/**
 * Interface pour les options d'annonce
 */
interface AnnounceOptions {
    /** Priorité de l'annonce (défaut: 'polite') */
    priority?: 'off' | 'polite' | 'assertive';
    /** Délai avant l'annonce (ms, défaut: 0) */
    delay?: number;
}
/**
 * Interface pour les options de focus
 */
interface FocusOptions {
    /** Délai avant le focus (ms, défaut: 0) */
    delay?: number;
    /** Prévenir le scroll lors du focus (défaut: false) */
    preventScroll?: boolean;
    /** Sélectionner le texte si applicable (défaut: false) */
    selectText?: boolean;
}
/**
 * Annonce un message aux lecteurs d'écran
 * @param message - Message à annoncer
 * @param options - Options d'annonce
 */
export declare const announceToScreenReader: (message: string, options?: AnnounceOptions) => void;
/**
 * Gère le focus de manière accessible
 * @param element - Élément à focuser
 * @param options - Options de focus
 */
export declare const focusElement: (element: HTMLElement | null, options?: FocusOptions) => void;
/**
 * Trouve le premier élément focusable dans un conteneur
 * @param container - Conteneur à rechercher
 * @returns Premier élément focusable ou null
 */
export declare const findFirstFocusableElement: (container: HTMLElement) => HTMLElement | null;
/**
 * Trouve tous les éléments focusables dans un conteneur
 * @param container - Conteneur à rechercher
 * @returns Liste des éléments focusables
 */
export declare const findAllFocusableElements: (container: HTMLElement) => HTMLElement[];
/**
 * Piège le focus dans un conteneur (utile pour les modales)
 * @param container - Conteneur pour piéger le focus
 * @returns Fonction de nettoyage
 */
export declare const trapFocus: (container: HTMLElement) => (() => void);
/**
 * Vérifie si un élément est visible pour les lecteurs d'écran
 * @param element - Élément à vérifier
 * @returns true si visible pour les lecteurs d'écran
 */
export declare const isAccessible: (element: HTMLElement) => boolean;
/**
 * Génère un ID unique pour les éléments
 * @param prefix - Préfixe pour l'ID
 * @returns ID unique
 */
export declare const generateUniqueId: (prefix?: string) => string;
/**
 * Associe un label à un contrôle de formulaire
 * @param control - Élément de contrôle
 * @param label - Élément label ou texte
 */
export declare const associateLabel: (control: HTMLElement, label: HTMLElement | string) => void;
/**
 * Configure les attributs ARIA pour un dropdown
 * @param trigger - Élément déclencheur
 * @param menu - Menu dropdown
 * @param isOpen - État d'ouverture
 */
export declare const configureDropdownAria: (trigger: HTMLElement, menu: HTMLElement, isOpen: boolean) => void;
/**
 * Gère la navigation au clavier dans un menu
 * @param menu - Élément menu
 * @param onClose - Callback de fermeture
 * @returns Fonction de nettoyage
 */
export declare const enableMenuKeyboardNavigation: (menu: HTMLElement, onClose?: () => void) => (() => void);
/**
 * Nettoie les ressources d'accessibilité
 */
export declare const cleanupAccessibility: () => void;
export {};
