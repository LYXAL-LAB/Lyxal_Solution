-- ============================================================================
-- SEED : Dictionnaire Standard Lyxal
-- Pré-remplit le dictionnaire sémantique avec les concepts de base
-- Mappe par défaut sur le pack 'lucide'
-- ============================================================================

-- Fonction helper pour créer un concept et le lier
-- (Usage théorique, ici on fait du script direct)

-- 1. ACTIONS
INSERT INTO icon_dictionary (identity, presentation) VALUES 
    ({ slug: 'action_add' }, { label: 'Ajouter', tags: ['ui', 'action'] }),
    ({ slug: 'action_edit' }, { label: 'Modifier', tags: ['ui', 'action'] }),
    ({ slug: 'action_delete' }, { label: 'Supprimer', tags: ['ui', 'action'] }),
    ({ slug: 'action_save' }, { label: 'Sauvegarder', tags: ['ui', 'action'] }),
    ({ slug: 'action_cancel' }, { label: 'Annuler', tags: ['ui', 'action'] }),
    ({ slug: 'action_search' }, { label: 'Rechercher', tags: ['ui', 'action'] });

-- Liaisons Lucide
RELATE icon_dictionary:action_add->icon_usage->icon:lucide-plus;
RELATE icon_dictionary:action_edit->icon_usage->icon:lucide-pencil;
RELATE icon_dictionary:action_delete->icon_usage->icon:lucide-trash-2;
RELATE icon_dictionary:action_save->icon_usage->icon:lucide-save;
RELATE icon_dictionary:action_cancel->icon_usage->icon:lucide-x;
RELATE icon_dictionary:action_search->icon_usage->icon:lucide-search;

-- 2. NAVIGATION
INSERT INTO icon_dictionary (identity, presentation) VALUES 
    ({ slug: 'nav_home' }, { label: 'Accueil', tags: ['nav'] }),
    ({ slug: 'nav_settings' }, { label: 'Paramètres', tags: ['nav'] }),
    ({ slug: 'nav_profile' }, { label: 'Profil', tags: ['nav'] }),
    ({ slug: 'nav_menu' }, { label: 'Menu', tags: ['nav'] });

-- Liaisons Lucide
RELATE icon_dictionary:nav_home->icon_usage->icon:lucide-home;
RELATE icon_dictionary:nav_settings->icon_usage->icon:lucide-settings;
RELATE icon_dictionary:nav_profile->icon_usage->icon:lucide-user-circle;
RELATE icon_dictionary:nav_menu->icon_usage->icon:lucide-menu;

-- 3. STATUS
INSERT INTO icon_dictionary (identity, presentation) VALUES 
    ({ slug: 'status_success' }, { label: 'Succès', tags: ['status'] }),
    ({ slug: 'status_error' }, { label: 'Erreur', tags: ['status'] }),
    ({ slug: 'status_warning' }, { label: 'Attention', tags: ['status'] }),
    ({ slug: 'status_info' }, { label: 'Information', tags: ['status'] });

-- Liaisons Lucide
RELATE icon_dictionary:status_success->icon_usage->icon:lucide-check-circle;
RELATE icon_dictionary:status_error->icon_usage->icon:lucide-x-circle;
RELATE icon_dictionary:status_warning->icon_usage->icon:lucide-alert-triangle;
RELATE icon_dictionary:status_info->icon_usage->icon:lucide-info;

-- 4. UI / CHEVRONS
INSERT INTO icon_dictionary (identity, presentation) VALUES 
    ({ slug: 'ui_chevron_down' }, { label: 'Bas', tags: ['ui'] }),
    ({ slug: 'ui_chevron_up' }, { label: 'Haut', tags: ['ui'] }),
    ({ slug: 'ui_chevron_left' }, { label: 'Gauche', tags: ['ui'] }),
    ({ slug: 'ui_chevron_right' }, { label: 'Droite', tags: ['ui'] });

-- Liaisons Lucide
RELATE icon_dictionary:ui_chevron_down->icon_usage->icon:lucide-chevron-down;
RELATE icon_dictionary:ui_chevron_up->icon_usage->icon:lucide-chevron-up;
RELATE icon_dictionary:ui_chevron_left->icon_usage->icon:lucide-chevron-left;
RELATE icon_dictionary:ui_chevron_right->icon_usage->icon:lucide-chevron-right;

