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
 * Classe pour gérer les annonces aux lecteurs d'écran
 */
class ScreenReaderAnnouncer {
  private liveRegion: HTMLElement | null = null;

  constructor() {
    this.createLiveRegion();
  }

  /**
   * Crée une région live pour les annonces
   */
  private createLiveRegion(): void {
    if (this.liveRegion) return;

    this.liveRegion = document.createElement('div');
    this.liveRegion.setAttribute('aria-live', 'polite');
    this.liveRegion.setAttribute('aria-atomic', 'true');
    this.liveRegion.setAttribute('aria-relevant', 'additions text');
    this.liveRegion.style.position = 'absolute';
    this.liveRegion.style.left = '-10000px';
    this.liveRegion.style.width = '1px';
    this.liveRegion.style.height = '1px';
    this.liveRegion.style.overflow = 'hidden';
    
    document.body.appendChild(this.liveRegion);
  }

  /**
   * Annonce un message aux lecteurs d'écran
   */
  announce(message: string, options: AnnounceOptions = {}): void {
    const { priority = 'polite', delay = 0 } = options;

    if (!this.liveRegion) {
      this.createLiveRegion();
    }

    const announceMessage = () => {
      if (this.liveRegion) {
        this.liveRegion.setAttribute('aria-live', priority);
        this.liveRegion.textContent = message;
        
        // Nettoyer après annonce
        setTimeout(() => {
          if (this.liveRegion) {
            this.liveRegion.textContent = '';
          }
        }, 1000);
      }
    };

    if (delay > 0) {
      setTimeout(announceMessage, delay);
    } else {
      announceMessage();
    }
  }

  /**
   * Nettoie les ressources
   */
  destroy(): void {
    if (this.liveRegion && this.liveRegion.parentNode) {
      this.liveRegion.parentNode.removeChild(this.liveRegion);
      this.liveRegion = null;
    }
  }
}

// Instance globale de l'annonceur
const announcer = new ScreenReaderAnnouncer();

/**
 * Annonce un message aux lecteurs d'écran
 * @param message - Message à annoncer
 * @param options - Options d'annonce
 */
export const announceToScreenReader = (message: string, options?: AnnounceOptions): void => {
  announcer.announce(message, options);
};

/**
 * Gère le focus de manière accessible
 * @param element - Élément à focuser
 * @param options - Options de focus
 */
export const focusElement = (element: HTMLElement | null, options: FocusOptions = {}): void => {
  if (!element) return;

  const { delay = 0, preventScroll = false, selectText = false } = options;

  const performFocus = () => {
    element.focus({ preventScroll });
    
    if (selectText && (element instanceof HTMLInputElement || element instanceof HTMLTextAreaElement)) {
      element.select();
    }
  };

  if (delay > 0) {
    setTimeout(performFocus, delay);
  } else {
    performFocus();
  }
};

/**
 * Trouve le premier élément focusable dans un conteneur
 * @param container - Conteneur à rechercher
 * @returns Premier élément focusable ou null
 */
export const findFirstFocusableElement = (container: HTMLElement): HTMLElement | null => {
  const focusableSelectors = [
    'button:not([disabled])',
    'input:not([disabled])',
    'select:not([disabled])',
    'textarea:not([disabled])',
    'a[href]',
    '[tabindex]:not([tabindex="-1"])',
    '[contenteditable="true"]'
  ].join(', ');

  const focusableElements = container.querySelectorAll<HTMLElement>(focusableSelectors);
  return focusableElements.length > 0 ? focusableElements[0] : null;
};

/**
 * Trouve tous les éléments focusables dans un conteneur
 * @param container - Conteneur à rechercher
 * @returns Liste des éléments focusables
 */
export const findAllFocusableElements = (container: HTMLElement): HTMLElement[] => {
  const focusableSelectors = [
    'button:not([disabled])',
    'input:not([disabled])',
    'select:not([disabled])',
    'textarea:not([disabled])',
    'a[href]',
    '[tabindex]:not([tabindex="-1"])',
    '[contenteditable="true"]'
  ].join(', ');

  return Array.from(container.querySelectorAll<HTMLElement>(focusableSelectors));
};

/**
 * Piège le focus dans un conteneur (utile pour les modales)
 * @param container - Conteneur pour piéger le focus
 * @returns Fonction de nettoyage
 */
export const trapFocus = (container: HTMLElement): (() => void) => {
  const focusableElements = findAllFocusableElements(container);
  
  if (focusableElements.length === 0) return () => {};

  const firstElement = focusableElements[0];
  const lastElement = focusableElements[focusableElements.length - 1];

  const handleKeyDown = (event: KeyboardEvent) => {
    if (event.key !== 'Tab') return;

    if (event.shiftKey) {
      // Shift + Tab
      if (document.activeElement === firstElement) {
        event.preventDefault();
        lastElement.focus();
      }
    } else {
      // Tab
      if (document.activeElement === lastElement) {
        event.preventDefault();
        firstElement.focus();
      }
    }
  };

  container.addEventListener('keydown', handleKeyDown);
  
  // Focus initial
  firstElement.focus();

  // Fonction de nettoyage
  return () => {
    container.removeEventListener('keydown', handleKeyDown);
  };
};

/**
 * Vérifie si un élément est visible pour les lecteurs d'écran
 * @param element - Élément à vérifier
 * @returns true si visible pour les lecteurs d'écran
 */
export const isAccessible = (element: HTMLElement): boolean => {
  // Vérifier si l'élément est caché
  if (element.hidden || element.style.display === 'none' || element.style.visibility === 'hidden') {
    return false;
  }

  // Vérifier aria-hidden
  if (element.getAttribute('aria-hidden') === 'true') {
    return false;
  }

  // Vérifier si l'élément a une taille
  const rect = element.getBoundingClientRect();
  if (rect.width === 0 && rect.height === 0) {
    return false;
  }

  return true;
};

/**
 * Génère un ID unique pour les éléments
 * @param prefix - Préfixe pour l'ID
 * @returns ID unique
 */
export const generateUniqueId = (prefix: string = 'accessible'): string => {
  return `${prefix}-${Math.random().toString(36).substr(2, 9)}`;
};

/**
 * Associe un label à un contrôle de formulaire
 * @param control - Élément de contrôle
 * @param label - Élément label ou texte
 */
export const associateLabel = (control: HTMLElement, label: HTMLElement | string): void => {
  if (typeof label === 'string') {
    control.setAttribute('aria-label', label);
  } else {
    const labelId = label.id || generateUniqueId('label');
    if (!label.id) {
      label.id = labelId;
    }
    control.setAttribute('aria-labelledby', labelId);
  }
};

/**
 * Configure les attributs ARIA pour un dropdown
 * @param trigger - Élément déclencheur
 * @param menu - Menu dropdown
 * @param isOpen - État d'ouverture
 */
export const configureDropdownAria = (
  trigger: HTMLElement, 
  menu: HTMLElement, 
  isOpen: boolean
): void => {
  const menuId = menu.id || generateUniqueId('dropdown-menu');
  if (!menu.id) {
    menu.id = menuId;
  }

  trigger.setAttribute('aria-haspopup', 'menu');
  trigger.setAttribute('aria-expanded', isOpen.toString());
  trigger.setAttribute('aria-controls', menuId);
  
  menu.setAttribute('role', 'menu');
  menu.setAttribute('aria-hidden', (!isOpen).toString());

  // Configurer les éléments du menu
  const menuItems = menu.querySelectorAll<HTMLElement>('[role="menuitem"], button, a');
  menuItems.forEach(item => {
    if (!item.getAttribute('role')) {
      item.setAttribute('role', 'menuitem');
    }
  });
};

/**
 * Gère la navigation au clavier dans un menu
 * @param menu - Élément menu
 * @param onClose - Callback de fermeture
 * @returns Fonction de nettoyage
 */
export const enableMenuKeyboardNavigation = (
  menu: HTMLElement, 
  onClose?: () => void
): (() => void) => {
  const menuItems = findAllFocusableElements(menu);
  let currentIndex = 0;

  const handleKeyDown = (event: KeyboardEvent) => {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        currentIndex = (currentIndex + 1) % menuItems.length;
        menuItems[currentIndex].focus();
        break;
        
      case 'ArrowUp':
        event.preventDefault();
        currentIndex = currentIndex === 0 ? menuItems.length - 1 : currentIndex - 1;
        menuItems[currentIndex].focus();
        break;
        
      case 'Home':
        event.preventDefault();
        currentIndex = 0;
        menuItems[currentIndex].focus();
        break;
        
      case 'End':
        event.preventDefault();
        currentIndex = menuItems.length - 1;
        menuItems[currentIndex].focus();
        break;
        
      case 'Escape':
        event.preventDefault();
        onClose?.();
        break;
    }
  };

  menu.addEventListener('keydown', handleKeyDown);

  return () => {
    menu.removeEventListener('keydown', handleKeyDown);
  };
};

/**
 * Nettoie les ressources d'accessibilité
 */
export const cleanupAccessibility = (): void => {
  announcer.destroy();
}; 