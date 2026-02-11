-- =============================================================================
-- SEEDS: icon_category
-- =============================================================================
-- Catégories fonctionnelles pour classifier les icônes
-- Ordre de déploiement : Après i18n_key, theme_color_type
-- =============================================================================

-- 1. Interface
-- Éléments d'interface utilisateur (boutons, inputs, modales, etc.)
CREATE icon_category:ui CONTENT {
  identity: {
    value: 'ui',
    slug: 'ui'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_interface_name,
    description_i18n: i18n_key:icon_category_interface_description
  },
  context: {
    examples: ['button', 'input', 'checkbox', 'radio', 'toggle', 'slider', 'select', 'modal', 'dialog'],
    keywords: ['ui', 'interface', 'component', 'element', 'control', 'form', 'widget', 'bouton', 'entrée', 'interface utilisateur']
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 1
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 2. Navigation
-- Icônes de navigation et déplacement
CREATE icon_category:navigation CONTENT {
  identity: {
    value: 'navigation',
    slug: 'navigation'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_navigation_name,
    description_i18n: i18n_key:icon_category_navigation_description
  },
  context: {
    examples: ['home', 'menu', 'arrow-left', 'arrow-right', 'chevron-up', 'chevron-down', 'link', 'external-link'],
    keywords: ['nav', 'navigation', 'menu', 'direction', 'goto', 'move', 'arrow', 'chevron', 'accueil', 'flèche']
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 2
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 3. Action
-- Icônes d'actions utilisateur (CRUD, interactions)
CREATE icon_category:action CONTENT {
  identity: {
    value: 'action',
    slug: 'action'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_action_name,
    description_i18n: i18n_key:icon_category_action_description
  },
  context: {
    examples: ['edit', 'delete', 'save', 'plus', 'minus', 'trash', 'copy', 'paste', 'cut', 'undo', 'redo'],
    keywords: ['action', 'crud', 'edit', 'create', 'delete', 'update', 'interaction', 'modify', 'modifier', 'supprimer', 'créer']
  },
  metadata: {
    color_type: theme_color_type:error,
    representative_icon: NONE,
    display_order: 3
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 4. Data
-- Icônes liées aux données et stockage
CREATE icon_category:data CONTENT {
  identity: {
    value: 'data',
    slug: 'data'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_data_name,
    description_i18n: i18n_key:icon_category_data_description
  },
  context: {
    examples: ['database', 'file', 'folder', 'document', 'archive', 'cloud', 'download', 'upload'],
    keywords: ['data', 'storage', 'file', 'database', 'document', 'folder', 'cloud', 'store', 'données', 'fichier', 'stockage']
  },
  metadata: {
    color_type: theme_color_type:secondary,
    representative_icon: NONE,
    display_order: 4
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 5. Communication
-- Icônes de communication (email, chat, notifications)
CREATE icon_category:communication CONTENT {
  identity: {
    value: 'communication',
    slug: 'communication'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_communication_name,
    description_i18n: i18n_key:icon_category_communication_description
  },
  context: {
    examples: ['mail', 'message', 'chat', 'bell', 'phone', 'video', 'mic', 'send'],
    keywords: ['communication', 'message', 'email', 'notification', 'chat', 'call', 'contact', 'téléphone', 'appel']
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 5
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 6. User
-- Icônes relatives aux utilisateurs et profils
CREATE icon_category:user CONTENT {
  identity: {
    value: 'user',
    slug: 'user'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_user_name,
    description_i18n: i18n_key:icon_category_user_description
  },
  context: {
    examples: ['user', 'users', 'user-plus', 'user-minus', 'user-check', 'profile', 'avatar', 'team'],
    keywords: ['user', 'profile', 'person', 'account', 'team', 'group', 'people', 'identity', 'utilisateur', 'profil', 'équipe']
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 6
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 7. System
-- Icônes système et configuration
CREATE icon_category:system CONTENT {
  identity: {
    value: 'system',
    slug: 'system'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_system_name,
    description_i18n: i18n_key:icon_category_system_description
  },
  context: {
    examples: ['settings', 'tool', 'wrench', 'cog', 'shield', 'lock', 'unlock', 'key', 'power'],
    keywords: ['system', 'settings', 'config', 'admin', 'security', 'tool', 'utility', 'système', 'paramètres', 'configuration']
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 7
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 8. Status
-- Icônes de statut et indicateurs
CREATE icon_category:status CONTENT {
  identity: {
    value: 'status',
    slug: 'status'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_status_name,
    description_i18n: i18n_key:icon_category_status_description
  },
  context: {
    examples: ['check', 'check-circle', 'x', 'x-circle', 'alert-circle', 'alert-triangle', 'info', 'help-circle', 'loader'],
    keywords: ['status', 'state', 'indicator', 'success', 'error', 'warning', 'info', 'alert', 'statut', 'état', 'indicateur']
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 8
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 9. Media
-- Icônes multimédia (images, vidéos, audio)
CREATE icon_category:media CONTENT {
  identity: {
    value: 'media',
    slug: 'media'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_media_name,
    description_i18n: i18n_key:icon_category_media_description
  },
  context: {
    examples: ['image', 'video', 'music', 'volume', 'camera', 'film', 'play', 'pause', 'stop'],
    keywords: ['media', 'image', 'video', 'audio', 'music', 'photo', 'gallery', 'player', 'multimédia', 'vidéo', 'musique']
  },
  metadata: {
    color_type: theme_color_type:accent,
    representative_icon: NONE,
    display_order: 9
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 10. Business
-- Icônes métier et business
CREATE icon_category:business CONTENT {
  identity: {
    value: 'business',
    slug: 'business'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_business_name,
    description_i18n: i18n_key:icon_category_business_description
  },
  context: {
    examples: ['briefcase', 'dollar-sign', 'euro', 'chart', 'bar-chart', 'pie-chart', 'trending-up', 'shopping-cart'],
    keywords: ['business', 'finance', 'money', 'chart', 'graph', 'analytics', 'report', 'commerce', 'finances', 'graphique']
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 10
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 11. Development
-- Icônes développement et technique
CREATE icon_category:development CONTENT {
  identity: {
    value: 'development',
    slug: 'development'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_development_name,
    description_i18n: i18n_key:icon_category_development_description
  },
  context: {
    examples: ['code', 'terminal', 'git-branch', 'git-commit', 'bug', 'cpu', 'server', 'api'],
    keywords: ['dev', 'development', 'code', 'programming', 'git', 'api', 'debug', 'tech', 'développement', 'programmation']
  },
  metadata: {
    color_type: theme_color_type:secondary,
    representative_icon: NONE,
    display_order: 11
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 12. Brand
-- Icônes de marques et identité
CREATE icon_category:brand CONTENT {
  identity: {
    value: 'brand',
    slug: 'brand'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_brand_name,
    description_i18n: i18n_key:icon_category_brand_description
  },
  context: {
    examples: ['logo', 'brand', 'facebook', 'twitter', 'linkedin', 'github', 'google'],
    keywords: ['brand', 'logo', 'identity', 'social', 'company', 'corporate', 'marque', 'identité', 'entreprise']
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 12
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 13. Other
-- Autres icônes non classifiées
CREATE icon_category:other CONTENT {
  identity: {
    value: 'other',
    slug: 'other'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_other_name,
    description_i18n: i18n_key:icon_category_other_description
  },
  context: {
    examples: [],
    keywords: ['other', 'misc', 'various', 'autre', 'divers']
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 999
  },
  status: {
    is_active: true,
    is_system: false,
    source: 'system'
  },
  timestamp: {}
};
