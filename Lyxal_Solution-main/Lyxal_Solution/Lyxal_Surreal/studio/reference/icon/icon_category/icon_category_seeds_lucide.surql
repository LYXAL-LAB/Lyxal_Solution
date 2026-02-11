-- =============================================================================
-- SEEDS: icon_category (Lucide)
-- =============================================================================
-- Catégories d'icônes extraites de Lucide (43 catégories)
-- Ordre de déploiement : Après icon_category_i18n_key_seeds.surql
-- =============================================================================

-- 1. Accessibility
CREATE icon_category:accessibility CONTENT {
  identity: {
    value: 'accessibility',
    slug: 'accessibility'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_accessibility_name,
    description_i18n: i18n_key:icon_category_accessibility_description
  },
  context: {
    examples: ["accessibility", "baby", "badge-info", "badge-question-mark", "circle-question-mark"],
    keywords: ["accessibility", "accessibility"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 14
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 2. Accounts & access
CREATE icon_category:account CONTENT {
  identity: {
    value: 'account',
    slug: 'account'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_account_name,
    description_i18n: i18n_key:icon_category_account_description
  },
  context: {
    examples: ["activity", "at-sign", "award", "badge", "badge-alert"],
    keywords: ["account", "accounts & access"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 15
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 3. Animals
CREATE icon_category:animals CONTENT {
  identity: {
    value: 'animals',
    slug: 'animals'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_animals_name,
    description_i18n: i18n_key:icon_category_animals_description
  },
  context: {
    examples: ["bird", "birdhouse", "bone", "bug", "bug-off"],
    keywords: ["animals", "animals"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 16
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 4. Arrows
CREATE icon_category:arrows CONTENT {
  identity: {
    value: 'arrows',
    slug: 'arrows'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_arrows_name,
    description_i18n: i18n_key:icon_category_arrows_description
  },
  context: {
    examples: ["arrow-big-down", "arrow-big-down-dash", "arrow-big-left", "arrow-big-left-dash", "arrow-big-right"],
    keywords: ["arrows", "arrows"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 17
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 5. Brands
CREATE icon_category:brands CONTENT {
  identity: {
    value: 'brands',
    slug: 'brands'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_brands_name,
    description_i18n: i18n_key:icon_category_brands_description
  },
  context: {
    examples: ["airplay", "bitcoin", "chromium", "codepen", "codesandbox"],
    keywords: ["brands", "brands"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 18
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 6. Buildings
CREATE icon_category:buildings CONTENT {
  identity: {
    value: 'buildings',
    slug: 'buildings'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_buildings_name,
    description_i18n: i18n_key:icon_category_buildings_description
  },
  context: {
    examples: ["anvil", "brick-wall", "building", "building-2", "castle"],
    keywords: ["buildings", "buildings"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 19
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 7. Charts
CREATE icon_category:charts CONTENT {
  identity: {
    value: 'charts',
    slug: 'charts'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_charts_name,
    description_i18n: i18n_key:icon_category_charts_description
  },
  context: {
    examples: ["chart-area", "chart-bar", "chart-bar-big", "chart-bar-decreasing", "chart-bar-increasing"],
    keywords: ["charts", "charts"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 20
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 8. Communication
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
    examples: ["antenna", "audio-lines", "audio-waveform", "book-user", "camera"],
    keywords: ["communication", "communication"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 21
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 9. Connectivity
CREATE icon_category:connectivity CONTENT {
  identity: {
    value: 'connectivity',
    slug: 'connectivity'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_connectivity_name,
    description_i18n: i18n_key:icon_category_connectivity_description
  },
  context: {
    examples: ["airplay", "battery", "battery-charging", "battery-full", "battery-low"],
    keywords: ["connectivity", "connectivity"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 22
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 10. Cursors
CREATE icon_category:cursors CONTENT {
  identity: {
    value: 'cursors',
    slug: 'cursors'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_cursors_name,
    description_i18n: i18n_key:icon_category_cursors_description
  },
  context: {
    examples: ["circle-plus", "hand", "hand-grab", "lasso", "lasso-select"],
    keywords: ["cursors", "cursors"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 23
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 11. Design
CREATE icon_category:design CONTENT {
  identity: {
    value: 'design',
    slug: 'design'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_design_name,
    description_i18n: i18n_key:icon_category_design_description
  },
  context: {
    examples: ["a-arrow-down", "a-arrow-up", "a-large-small", "app-window", "app-window-mac"],
    keywords: ["design", "design"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 24
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 12. Coding & development
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
    examples: ["ampersand", "ampersands", "app-window", "app-window-mac", "arrow-big-up"],
    keywords: ["development", "coding & development"]
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 25
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 13. Devices
CREATE icon_category:devices CONTENT {
  identity: {
    value: 'devices',
    slug: 'devices'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_devices_name,
    description_i18n: i18n_key:icon_category_devices_description
  },
  context: {
    examples: ["airplay", "alarm-clock", "alarm-clock-check", "alarm-clock-minus", "alarm-clock-off"],
    keywords: ["devices", "devices"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 26
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 14. Emoji
CREATE icon_category:emoji CONTENT {
  identity: {
    value: 'emoji',
    slug: 'emoji'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_emoji_name,
    description_i18n: i18n_key:icon_category_emoji_description
  },
  context: {
    examples: ["angry", "annoyed", "biceps-flexed", "frown", "hand-fist"],
    keywords: ["emoji", "emoji"]
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 27
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 15. File icons
CREATE icon_category:files CONTENT {
  identity: {
    value: 'files',
    slug: 'files'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_files_name,
    description_i18n: i18n_key:icon_category_files_description
  },
  context: {
    examples: ["app-window", "app-window-mac", "archive", "archive-restore", "archive-x"],
    keywords: ["files", "file icons"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 28
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 16. Finance
CREATE icon_category:finance CONTENT {
  identity: {
    value: 'finance',
    slug: 'finance'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_finance_name,
    description_i18n: i18n_key:icon_category_finance_description
  },
  context: {
    examples: ["badge-cent", "badge-dollar-sign", "badge-euro", "badge-indian-rupee", "badge-japanese-yen"],
    keywords: ["finance", "finance"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 29
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 17. Food & beverage
CREATE icon_category:food_beverage CONTENT {
  identity: {
    value: 'food_beverage',
    slug: 'food-beverage'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_food_beverage_name,
    description_i18n: i18n_key:icon_category_food_beverage_description
  },
  context: {
    examples: ["amphora", "apple", "banana", "barrel", "bean"],
    keywords: ["food_beverage", "food & beverage", "food", "beverage"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 30
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 18. Gaming
CREATE icon_category:gaming CONTENT {
  identity: {
    value: 'gaming',
    slug: 'gaming'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_gaming_name,
    description_i18n: i18n_key:icon_category_gaming_description
  },
  context: {
    examples: ["amphora", "anvil", "arrow-big-down", "arrow-big-down-dash", "arrow-big-left"],
    keywords: ["gaming", "gaming"]
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 31
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 19. Home
CREATE icon_category:home CONTENT {
  identity: {
    value: 'home',
    slug: 'home'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_home_name,
    description_i18n: i18n_key:icon_category_home_description
  },
  context: {
    examples: ["air-vent", "alarm-smoke", "armchair", "bed", "bed-double"],
    keywords: ["home", "home"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 32
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 20. Layout
CREATE icon_category:layout CONTENT {
  identity: {
    value: 'layout',
    slug: 'layout'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_layout_name,
    description_i18n: i18n_key:icon_category_layout_description
  },
  context: {
    examples: ["align-center-horizontal", "align-center-vertical", "align-end-horizontal", "align-end-vertical", "align-horizontal-distribute-center"],
    keywords: ["layout", "layout"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 33
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 21. Mail
CREATE icon_category:mail CONTENT {
  identity: {
    value: 'mail',
    slug: 'mail'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_mail_name,
    description_i18n: i18n_key:icon_category_mail_description
  },
  context: {
    examples: ["archive", "archive-restore", "archive-x", "arrows-up-from-line", "container"],
    keywords: ["mail", "mail"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 34
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 22. Mathematics
CREATE icon_category:math CONTENT {
  identity: {
    value: 'math',
    slug: 'math'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_math_name,
    description_i18n: i18n_key:icon_category_math_description
  },
  context: {
    examples: ["asterisk", "badge-percent", "box", "calculator", "chevron-right"],
    keywords: ["math", "mathematics"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 35
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 23. Medical
CREATE icon_category:medical CONTENT {
  identity: {
    value: 'medical',
    slug: 'medical'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_medical_name,
    description_i18n: i18n_key:icon_category_medical_description
  },
  context: {
    examples: ["accessibility", "activity", "ambulance", "bandage", "bone"],
    keywords: ["medical", "medical"]
  },
  metadata: {
    color_type: theme_color_type:error,
    representative_icon: NONE,
    display_order: 36
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 24. Multimedia
CREATE icon_category:multimedia CONTENT {
  identity: {
    value: 'multimedia',
    slug: 'multimedia'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_multimedia_name,
    description_i18n: i18n_key:icon_category_multimedia_description
  },
  context: {
    examples: ["activity", "airplay", "album", "antenna", "audio-lines"],
    keywords: ["multimedia", "multimedia"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 37
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 25. Nature
CREATE icon_category:nature CONTENT {
  identity: {
    value: 'nature',
    slug: 'nature'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_nature_name,
    description_i18n: i18n_key:icon_category_nature_description
  },
  context: {
    examples: ["binoculars", "birdhouse", "cannabis", "caravan", "flame-kindling"],
    keywords: ["nature", "nature"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 38
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 26. Navigation
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
    examples: ["arrow-big-down", "arrow-big-down-dash", "arrow-big-left", "arrow-big-left-dash", "arrow-big-right"],
    keywords: ["navigation", "navigation"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 39
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 27. Notification
CREATE icon_category:notifications CONTENT {
  identity: {
    value: 'notifications',
    slug: 'notifications'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_notifications_name,
    description_i18n: i18n_key:icon_category_notifications_description
  },
  context: {
    examples: ["alarm-clock", "alarm-clock-check", "alarm-clock-minus", "alarm-clock-off", "alarm-clock-plus"],
    keywords: ["notifications", "notification"]
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 40
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 28. People
CREATE icon_category:people CONTENT {
  identity: {
    value: 'people',
    slug: 'people'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_people_name,
    description_i18n: i18n_key:icon_category_people_description
  },
  context: {
    examples: ["baby", "hand-platter", "person-standing"],
    keywords: ["people", "people"]
  },
  metadata: {
    color_type: theme_color_type:primary,
    representative_icon: NONE,
    display_order: 41
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 29. Photography
CREATE icon_category:photography CONTENT {
  identity: {
    value: 'photography',
    slug: 'photography'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_photography_name,
    description_i18n: i18n_key:icon_category_photography_description
  },
  context: {
    examples: ["album", "aperture", "backpack", "binoculars", "blend"],
    keywords: ["photography", "photography"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 42
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 30. Science
CREATE icon_category:science CONTENT {
  identity: {
    value: 'science',
    slug: 'science'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_science_name,
    description_i18n: i18n_key:icon_category_science_description
  },
  context: {
    examples: ["activity", "atom", "beaker", "binoculars", "biohazard"],
    keywords: ["science", "science"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 43
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 31. Seasons
CREATE icon_category:seasons CONTENT {
  identity: {
    value: 'seasons',
    slug: 'seasons'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_seasons_name,
    description_i18n: i18n_key:icon_category_seasons_description
  },
  context: {
    examples: ["flower-2", "leaf", "rose", "snowflake", "sun"],
    keywords: ["seasons", "seasons"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 44
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 32. Security
CREATE icon_category:security CONTENT {
  identity: {
    value: 'security',
    slug: 'security'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_security_name,
    description_i18n: i18n_key:icon_category_security_description
  },
  context: {
    examples: ["bomb", "book-key", "book-lock", "brick-wall-fire", "brick-wall-shield"],
    keywords: ["security", "security"]
  },
  metadata: {
    color_type: theme_color_type:error,
    representative_icon: NONE,
    display_order: 45
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 33. Shapes
CREATE icon_category:shapes CONTENT {
  identity: {
    value: 'shapes',
    slug: 'shapes'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_shapes_name,
    description_i18n: i18n_key:icon_category_shapes_description
  },
  context: {
    examples: ["badge", "badge-question-mark", "blocks", "box", "boxes"],
    keywords: ["shapes", "shapes"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 46
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 34. Shopping
CREATE icon_category:shopping CONTENT {
  identity: {
    value: 'shopping',
    slug: 'shopping'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_shopping_name,
    description_i18n: i18n_key:icon_category_shopping_description
  },
  context: {
    examples: ["badge-cent", "badge-dollar-sign", "badge-euro", "badge-indian-rupee", "badge-japanese-yen"],
    keywords: ["shopping", "shopping"]
  },
  metadata: {
    color_type: theme_color_type:warning,
    representative_icon: NONE,
    display_order: 47
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 35. Social
CREATE icon_category:social CONTENT {
  identity: {
    value: 'social',
    slug: 'social'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_social_name,
    description_i18n: i18n_key:icon_category_social_description
  },
  context: {
    examples: ["activity", "badge", "badge-alert", "badge-check", "badge-info"],
    keywords: ["social", "social"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 48
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 36. Sports
CREATE icon_category:sports CONTENT {
  identity: {
    value: 'sports',
    slug: 'sports'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_sports_name,
    description_i18n: i18n_key:icon_category_sports_description
  },
  context: {
    examples: ["award", "circle-gauge", "circle-star", "dumbbell", "gauge"],
    keywords: ["sports", "sports"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 49
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 37. Sustainability
CREATE icon_category:sustainability CONTENT {
  identity: {
    value: 'sustainability',
    slug: 'sustainability'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_sustainability_name,
    description_i18n: i18n_key:icon_category_sustainability_description
  },
  context: {
    examples: ["dam", "flower", "flower-2", "house-plug", "leaf"],
    keywords: ["sustainability", "sustainability"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 50
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 38. Text formatting
CREATE icon_category:text CONTENT {
  identity: {
    value: 'text',
    slug: 'text'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_text_name,
    description_i18n: i18n_key:icon_category_text_description
  },
  context: {
    examples: ["a-arrow-down", "a-arrow-up", "a-large-small", "ampersand", "ampersands"],
    keywords: ["text", "text formatting"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 51
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 39. Time & calendar
CREATE icon_category:time CONTENT {
  identity: {
    value: 'time',
    slug: 'time'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_time_name,
    description_i18n: i18n_key:icon_category_time_description
  },
  context: {
    examples: ["alarm-clock", "alarm-clock-check", "alarm-clock-minus", "alarm-clock-off", "alarm-clock-plus"],
    keywords: ["time", "time & calendar"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 52
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 40. Tools
CREATE icon_category:tools CONTENT {
  identity: {
    value: 'tools',
    slug: 'tools'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_tools_name,
    description_i18n: i18n_key:icon_category_tools_description
  },
  context: {
    examples: ["anvil", "axe", "between-horizontal-end", "between-horizontal-start", "between-vertical-end"],
    keywords: ["tools", "tools"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 53
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 41. Transportation
CREATE icon_category:transportation CONTENT {
  identity: {
    value: 'transportation',
    slug: 'transportation'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_transportation_name,
    description_i18n: i18n_key:icon_category_transportation_description
  },
  context: {
    examples: ["ambulance", "anchor", "arrows-up-from-line", "baggage-claim", "bike"],
    keywords: ["transportation", "transportation"]
  },
  metadata: {
    color_type: theme_color_type:neutral,
    representative_icon: NONE,
    display_order: 54
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 42. Travel
CREATE icon_category:travel CONTENT {
  identity: {
    value: 'travel',
    slug: 'travel'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_travel_name,
    description_i18n: i18n_key:icon_category_travel_description
  },
  context: {
    examples: ["alarm-smoke", "backpack", "baggage-claim", "bath", "binoculars"],
    keywords: ["travel", "travel"]
  },
  metadata: {
    color_type: theme_color_type:success,
    representative_icon: NONE,
    display_order: 55
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};

-- 43. Weather
CREATE icon_category:weather CONTENT {
  identity: {
    value: 'weather',
    slug: 'weather'
  },
  presentation: {
    name_i18n: i18n_key:icon_category_weather_name,
    description_i18n: i18n_key:icon_category_weather_description
  },
  context: {
    examples: ["bubbles", "cloud", "cloud-drizzle", "cloud-fog", "cloud-hail"],
    keywords: ["weather", "weather"]
  },
  metadata: {
    color_type: theme_color_type:info,
    representative_icon: NONE,
    display_order: 56
  },
  status: {
    is_active: true,
    is_system: true,
    source: 'system'
  },
  timestamp: {}
};
