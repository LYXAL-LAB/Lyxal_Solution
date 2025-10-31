-- =============================================================================
-- SEEDS: icon (Lucide - sélection)
-- =============================================================================
-- Dictionnaire d'icônes enrichi depuis Lucide
-- Ordre de déploiement : Après icon_seeds_lucide_i18n_key_seeds.surql
-- =============================================================================

-- 1. a-arrow-down
CREATE icon:a_arrow_down CONTENT {
  identity: {
    value: 'a_arrow_down',
    slug: 'a-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_a_arrow_down_name,
    label_i18n: i18n_key:icon_a_arrow_down_label,
    keywords: ["a-arrow-down", "letter", "font size", "text", "formatting", "smaller"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 2. a-arrow-up
CREATE icon:a_arrow_up CONTENT {
  identity: {
    value: 'a_arrow_up',
    slug: 'a-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_a_arrow_up_name,
    label_i18n: i18n_key:icon_a_arrow_up_label,
    keywords: ["a-arrow-up", "letter", "font size", "text", "formatting", "larger", "bigger"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 3. a-large-small
CREATE icon:a_large_small CONTENT {
  identity: {
    value: 'a_large_small',
    slug: 'a-large-small'
  },
  presentation: {
    name_i18n: i18n_key:icon_a_large_small_name,
    label_i18n: i18n_key:icon_a_large_small_label,
    keywords: ["a-large-small", "letter", "font size", "text", "formatting"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 4. accessibility
CREATE icon:accessibility CONTENT {
  identity: {
    value: 'accessibility',
    slug: 'accessibility'
  },
  presentation: {
    name_i18n: i18n_key:icon_accessibility_name,
    label_i18n: i18n_key:icon_accessibility_label,
    keywords: ["accessibility", "disability", "disabled", "dda", "wheelchair"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 5. activity
CREATE icon:activity CONTENT {
  identity: {
    value: 'activity',
    slug: 'activity'
  },
  presentation: {
    name_i18n: i18n_key:icon_activity_name,
    label_i18n: i18n_key:icon_activity_label,
    keywords: ["activity", "pulse", "action", "motion", "movement", "exercise", "fitness", "healthcare", "heart rate monitor", "vital signs", "vitals", "emergency room", "er", "intensive care", "hospital", "defibrillator", "earthquake", "siesmic", "magnitude", "richter scale", "aftershock", "tremor", "shockwave", "audio", "waveform", "synthesizer", "synthesiser", "music"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 6. air-vent
CREATE icon:air_vent CONTENT {
  identity: {
    value: 'air_vent',
    slug: 'air-vent'
  },
  presentation: {
    name_i18n: i18n_key:icon_air_vent_name,
    label_i18n: i18n_key:icon_air_vent_label,
    keywords: ["air-vent", "air conditioner", "ac", "central air", "cooling", "climate-control"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 7. airplay
CREATE icon:airplay CONTENT {
  identity: {
    value: 'airplay',
    slug: 'airplay'
  },
  presentation: {
    name_i18n: i18n_key:icon_airplay_name,
    label_i18n: i18n_key:icon_airplay_label,
    keywords: ["airplay", "stream", "cast", "mirroring", "screen", "monitor", "macos", "osx"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 8. alarm-clock-check
CREATE icon:alarm_clock_check CONTENT {
  identity: {
    value: 'alarm_clock_check',
    slug: 'alarm-clock-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_alarm_clock_check_name,
    label_i18n: i18n_key:icon_alarm_clock_check_label,
    keywords: ["alarm-clock-check", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 9. alarm-clock-minus
CREATE icon:alarm_clock_minus CONTENT {
  identity: {
    value: 'alarm_clock_minus',
    slug: 'alarm-clock-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_alarm_clock_minus_name,
    label_i18n: i18n_key:icon_alarm_clock_minus_label,
    keywords: ["alarm-clock-minus", "remove"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 10. alarm-clock-off
CREATE icon:alarm_clock_off CONTENT {
  identity: {
    value: 'alarm_clock_off',
    slug: 'alarm-clock-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_alarm_clock_off_name,
    label_i18n: i18n_key:icon_alarm_clock_off_label,
    keywords: ["alarm-clock-off", "morning", "turn-off"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 11. alarm-clock-plus
CREATE icon:alarm_clock_plus CONTENT {
  identity: {
    value: 'alarm_clock_plus',
    slug: 'alarm-clock-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_alarm_clock_plus_name,
    label_i18n: i18n_key:icon_alarm_clock_plus_label,
    keywords: ["alarm-clock-plus", "add"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 12. alarm-clock
CREATE icon:alarm_clock CONTENT {
  identity: {
    value: 'alarm_clock',
    slug: 'alarm-clock'
  },
  presentation: {
    name_i18n: i18n_key:icon_alarm_clock_name,
    label_i18n: i18n_key:icon_alarm_clock_label,
    keywords: ["alarm-clock", "morning"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 13. alarm-smoke
CREATE icon:alarm_smoke CONTENT {
  identity: {
    value: 'alarm_smoke',
    slug: 'alarm-smoke'
  },
  presentation: {
    name_i18n: i18n_key:icon_alarm_smoke_name,
    label_i18n: i18n_key:icon_alarm_smoke_label,
    keywords: ["alarm-smoke", "fire", "alert", "warning", "detector", "carbon monoxide", "safety", "equipment", "amenities"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 14. album
CREATE icon:album CONTENT {
  identity: {
    value: 'album',
    slug: 'album'
  },
  presentation: {
    name_i18n: i18n_key:icon_album_name,
    label_i18n: i18n_key:icon_album_label,
    keywords: ["album", "photo", "book"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 15. align-center-horizontal
CREATE icon:align_center_horizontal CONTENT {
  identity: {
    value: 'align_center_horizontal',
    slug: 'align-center-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_center_horizontal_name,
    label_i18n: i18n_key:icon_align_center_horizontal_label,
    keywords: ["align-center-horizontal", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 16. align-center-vertical
CREATE icon:align_center_vertical CONTENT {
  identity: {
    value: 'align_center_vertical',
    slug: 'align-center-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_center_vertical_name,
    label_i18n: i18n_key:icon_align_center_vertical_label,
    keywords: ["align-center-vertical", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 17. align-end-horizontal
CREATE icon:align_end_horizontal CONTENT {
  identity: {
    value: 'align_end_horizontal',
    slug: 'align-end-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_end_horizontal_name,
    label_i18n: i18n_key:icon_align_end_horizontal_label,
    keywords: ["align-end-horizontal", "items", "bottom", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 18. align-end-vertical
CREATE icon:align_end_vertical CONTENT {
  identity: {
    value: 'align_end_vertical',
    slug: 'align-end-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_end_vertical_name,
    label_i18n: i18n_key:icon_align_end_vertical_label,
    keywords: ["align-end-vertical", "items", "right", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 19. align-horizontal-distribute-center
CREATE icon:align_horizontal_distribute_center CONTENT {
  identity: {
    value: 'align_horizontal_distribute_center',
    slug: 'align-horizontal-distribute-center'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_distribute_center_name,
    label_i18n: i18n_key:icon_align_horizontal_distribute_center_label,
    keywords: ["align-horizontal-distribute-center", "items", "flex", "justify", "space", "evenly", "around"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 20. align-horizontal-distribute-end
CREATE icon:align_horizontal_distribute_end CONTENT {
  identity: {
    value: 'align_horizontal_distribute_end',
    slug: 'align-horizontal-distribute-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_distribute_end_name,
    label_i18n: i18n_key:icon_align_horizontal_distribute_end_label,
    keywords: ["align-horizontal-distribute-end", "right", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 21. align-horizontal-distribute-start
CREATE icon:align_horizontal_distribute_start CONTENT {
  identity: {
    value: 'align_horizontal_distribute_start',
    slug: 'align-horizontal-distribute-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_distribute_start_name,
    label_i18n: i18n_key:icon_align_horizontal_distribute_start_label,
    keywords: ["align-horizontal-distribute-start", "left", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 22. align-horizontal-justify-center
CREATE icon:align_horizontal_justify_center CONTENT {
  identity: {
    value: 'align_horizontal_justify_center',
    slug: 'align-horizontal-justify-center'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_justify_center_name,
    label_i18n: i18n_key:icon_align_horizontal_justify_center_label,
    keywords: ["align-horizontal-justify-center", "center", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 23. align-horizontal-justify-end
CREATE icon:align_horizontal_justify_end CONTENT {
  identity: {
    value: 'align_horizontal_justify_end',
    slug: 'align-horizontal-justify-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_justify_end_name,
    label_i18n: i18n_key:icon_align_horizontal_justify_end_label,
    keywords: ["align-horizontal-justify-end", "right", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 24. align-horizontal-justify-start
CREATE icon:align_horizontal_justify_start CONTENT {
  identity: {
    value: 'align_horizontal_justify_start',
    slug: 'align-horizontal-justify-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_justify_start_name,
    label_i18n: i18n_key:icon_align_horizontal_justify_start_label,
    keywords: ["align-horizontal-justify-start", "left", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 25. align-horizontal-space-around
CREATE icon:align_horizontal_space_around CONTENT {
  identity: {
    value: 'align_horizontal_space_around',
    slug: 'align-horizontal-space-around'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_space_around_name,
    label_i18n: i18n_key:icon_align_horizontal_space_around_label,
    keywords: ["align-horizontal-space-around", "center", "items", "flex", "justify", "distribute", "between"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 26. align-horizontal-space-between
CREATE icon:align_horizontal_space_between CONTENT {
  identity: {
    value: 'align_horizontal_space_between',
    slug: 'align-horizontal-space-between'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_horizontal_space_between_name,
    label_i18n: i18n_key:icon_align_horizontal_space_between_label,
    keywords: ["align-horizontal-space-between", "around", "items", "bottom", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 27. align-start-horizontal
CREATE icon:align_start_horizontal CONTENT {
  identity: {
    value: 'align_start_horizontal',
    slug: 'align-start-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_start_horizontal_name,
    label_i18n: i18n_key:icon_align_start_horizontal_label,
    keywords: ["align-start-horizontal", "top", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 28. align-start-vertical
CREATE icon:align_start_vertical CONTENT {
  identity: {
    value: 'align_start_vertical',
    slug: 'align-start-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_start_vertical_name,
    label_i18n: i18n_key:icon_align_start_vertical_label,
    keywords: ["align-start-vertical", "left", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 29. align-vertical-distribute-center
CREATE icon:align_vertical_distribute_center CONTENT {
  identity: {
    value: 'align_vertical_distribute_center',
    slug: 'align-vertical-distribute-center'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_distribute_center_name,
    label_i18n: i18n_key:icon_align_vertical_distribute_center_label,
    keywords: ["align-vertical-distribute-center", "items", "flex", "justify", "space", "evenly", "around"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 30. align-vertical-distribute-end
CREATE icon:align_vertical_distribute_end CONTENT {
  identity: {
    value: 'align_vertical_distribute_end',
    slug: 'align-vertical-distribute-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_distribute_end_name,
    label_i18n: i18n_key:icon_align_vertical_distribute_end_label,
    keywords: ["align-vertical-distribute-end", "bottom", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 31. align-vertical-distribute-start
CREATE icon:align_vertical_distribute_start CONTENT {
  identity: {
    value: 'align_vertical_distribute_start',
    slug: 'align-vertical-distribute-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_distribute_start_name,
    label_i18n: i18n_key:icon_align_vertical_distribute_start_label,
    keywords: ["align-vertical-distribute-start", "top", "items", "flex", "justify"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 32. align-vertical-justify-center
CREATE icon:align_vertical_justify_center CONTENT {
  identity: {
    value: 'align_vertical_justify_center',
    slug: 'align-vertical-justify-center'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_justify_center_name,
    label_i18n: i18n_key:icon_align_vertical_justify_center_label,
    keywords: ["align-vertical-justify-center", "center", "items", "flex", "justify", "distribute", "between"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 33. align-vertical-justify-end
CREATE icon:align_vertical_justify_end CONTENT {
  identity: {
    value: 'align_vertical_justify_end',
    slug: 'align-vertical-justify-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_justify_end_name,
    label_i18n: i18n_key:icon_align_vertical_justify_end_label,
    keywords: ["align-vertical-justify-end", "bottom", "items", "flex", "justify", "distribute", "between"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 34. align-vertical-justify-start
CREATE icon:align_vertical_justify_start CONTENT {
  identity: {
    value: 'align_vertical_justify_start',
    slug: 'align-vertical-justify-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_justify_start_name,
    label_i18n: i18n_key:icon_align_vertical_justify_start_label,
    keywords: ["align-vertical-justify-start", "top", "items", "flex", "justify", "distribute", "between"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 35. align-vertical-space-around
CREATE icon:align_vertical_space_around CONTENT {
  identity: {
    value: 'align_vertical_space_around',
    slug: 'align-vertical-space-around'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_space_around_name,
    label_i18n: i18n_key:icon_align_vertical_space_around_label,
    keywords: ["align-vertical-space-around", "center", "items", "flex", "justify", "distribute", "between"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 36. align-vertical-space-between
CREATE icon:align_vertical_space_between CONTENT {
  identity: {
    value: 'align_vertical_space_between',
    slug: 'align-vertical-space-between'
  },
  presentation: {
    name_i18n: i18n_key:icon_align_vertical_space_between_name,
    label_i18n: i18n_key:icon_align_vertical_space_between_label,
    keywords: ["align-vertical-space-between", "center", "items", "flex", "justify", "distribute", "between"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 37. ambulance
CREATE icon:ambulance CONTENT {
  identity: {
    value: 'ambulance',
    slug: 'ambulance'
  },
  presentation: {
    name_i18n: i18n_key:icon_ambulance_name,
    label_i18n: i18n_key:icon_ambulance_label,
    keywords: ["ambulance", "ambulance", "emergency", "medical", "vehicle", "siren", "healthcare", "transportation", "rescue", "urgent", "first aid"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 38. ampersand
CREATE icon:ampersand CONTENT {
  identity: {
    value: 'ampersand',
    slug: 'ampersand'
  },
  presentation: {
    name_i18n: i18n_key:icon_ampersand_name,
    label_i18n: i18n_key:icon_ampersand_label,
    keywords: ["ampersand", "and", "typography", "operator", "join", "concatenate", "code", "&"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 39. ampersands
CREATE icon:ampersands CONTENT {
  identity: {
    value: 'ampersands',
    slug: 'ampersands'
  },
  presentation: {
    name_i18n: i18n_key:icon_ampersands_name,
    label_i18n: i18n_key:icon_ampersands_label,
    keywords: ["ampersands", "and", "operator", "then", "code", "&&"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 40. amphora
CREATE icon:amphora CONTENT {
  identity: {
    value: 'amphora',
    slug: 'amphora'
  },
  presentation: {
    name_i18n: i18n_key:icon_amphora_name,
    label_i18n: i18n_key:icon_amphora_label,
    keywords: ["amphora", "pottery", "artifact", "artefact", "vase", "ceramics", "clay", "archaeology", "museum", "wine", "oil"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 41. anchor
CREATE icon:anchor CONTENT {
  identity: {
    value: 'anchor',
    slug: 'anchor'
  },
  presentation: {
    name_i18n: i18n_key:icon_anchor_name,
    label_i18n: i18n_key:icon_anchor_label,
    keywords: ["anchor", "ship"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 42. angry
CREATE icon:angry CONTENT {
  identity: {
    value: 'angry',
    slug: 'angry'
  },
  presentation: {
    name_i18n: i18n_key:icon_angry_name,
    label_i18n: i18n_key:icon_angry_label,
    keywords: ["angry", "emoji", "anger", "face", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 43. annoyed
CREATE icon:annoyed CONTENT {
  identity: {
    value: 'annoyed',
    slug: 'annoyed'
  },
  presentation: {
    name_i18n: i18n_key:icon_annoyed_name,
    label_i18n: i18n_key:icon_annoyed_label,
    keywords: ["annoyed", "emoji", "nuisance", "face", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 44. antenna
CREATE icon:antenna CONTENT {
  identity: {
    value: 'antenna',
    slug: 'antenna'
  },
  presentation: {
    name_i18n: i18n_key:icon_antenna_name,
    label_i18n: i18n_key:icon_antenna_label,
    keywords: ["antenna", "signal", "connection", "connectivity", "tv", "television", "broadcast", "live", "frequency", "tune", "scan", "channels", "aerial", "receiver", "transmission", "transducer", "terrestrial", "satellite", "cable"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 45. anvil
CREATE icon:anvil CONTENT {
  identity: {
    value: 'anvil',
    slug: 'anvil'
  },
  presentation: {
    name_i18n: i18n_key:icon_anvil_name,
    label_i18n: i18n_key:icon_anvil_label,
    keywords: ["anvil", "metal", "iron", "alloy", "materials", "heavy", "weight", "blacksmith", "forge", "acme"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 46. aperture
CREATE icon:aperture CONTENT {
  identity: {
    value: 'aperture',
    slug: 'aperture'
  },
  presentation: {
    name_i18n: i18n_key:icon_aperture_name,
    label_i18n: i18n_key:icon_aperture_label,
    keywords: ["aperture", "camera", "photo", "pictures", "shutter", "exposure"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 47. app-window-mac
CREATE icon:app_window_mac CONTENT {
  identity: {
    value: 'app_window_mac',
    slug: 'app-window-mac'
  },
  presentation: {
    name_i18n: i18n_key:icon_app_window_mac_name,
    label_i18n: i18n_key:icon_app_window_mac_label,
    keywords: ["app-window-mac", "application", "menu bar", "pane", "preferences", "macos", "osx", "executable"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 48. app-window
CREATE icon:app_window CONTENT {
  identity: {
    value: 'app_window',
    slug: 'app-window'
  },
  presentation: {
    name_i18n: i18n_key:icon_app_window_name,
    label_i18n: i18n_key:icon_app_window_label,
    keywords: ["app-window", "application", "menu bar", "pane", "executable"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 49. apple
CREATE icon:apple CONTENT {
  identity: {
    value: 'apple',
    slug: 'apple'
  },
  presentation: {
    name_i18n: i18n_key:icon_apple_name,
    label_i18n: i18n_key:icon_apple_label,
    keywords: ["apple", "fruit", "food", "healthy", "snack", "nutrition", "fresh", "produce", "grocery", "organic", "harvest", "vitamin", "red", "green", "juicy", "sweet", "tart", "bite", "orchard", "plant", "core", "raw", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 50. archive-restore
CREATE icon:archive_restore CONTENT {
  identity: {
    value: 'archive_restore',
    slug: 'archive-restore'
  },
  presentation: {
    name_i18n: i18n_key:icon_archive_restore_name,
    label_i18n: i18n_key:icon_archive_restore_label,
    keywords: ["archive-restore", "unarchive", "index", "backup", "box", "storage", "records"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 51. archive-x
CREATE icon:archive_x CONTENT {
  identity: {
    value: 'archive_x',
    slug: 'archive-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_archive_x_name,
    label_i18n: i18n_key:icon_archive_x_label,
    keywords: ["archive-x", "index", "backup", "box", "storage", "records", "junk"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 52. archive
CREATE icon:archive CONTENT {
  identity: {
    value: 'archive',
    slug: 'archive'
  },
  presentation: {
    name_i18n: i18n_key:icon_archive_name,
    label_i18n: i18n_key:icon_archive_label,
    keywords: ["archive", "index", "backup", "box", "storage", "records"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 53. armchair
CREATE icon:armchair CONTENT {
  identity: {
    value: 'armchair',
    slug: 'armchair'
  },
  presentation: {
    name_i18n: i18n_key:icon_armchair_name,
    label_i18n: i18n_key:icon_armchair_label,
    keywords: ["armchair", "sofa", "furniture", "leisure", "lounge", "loveseat", "couch"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 54. arrow-big-down-dash
CREATE icon:arrow_big_down_dash CONTENT {
  identity: {
    value: 'arrow_big_down_dash',
    slug: 'arrow-big-down-dash'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_down_dash_name,
    label_i18n: i18n_key:icon_arrow_big_down_dash_label,
    keywords: ["arrow-big-down-dash", "backwards", "reverse", "slow", "direction", "south", "download"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 55. arrow-big-down
CREATE icon:arrow_big_down CONTENT {
  identity: {
    value: 'arrow_big_down',
    slug: 'arrow-big-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_down_name,
    label_i18n: i18n_key:icon_arrow_big_down_label,
    keywords: ["arrow-big-down", "backwards", "reverse", "direction", "south"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 56. arrow-big-left-dash
CREATE icon:arrow_big_left_dash CONTENT {
  identity: {
    value: 'arrow_big_left_dash',
    slug: 'arrow-big-left-dash'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_left_dash_name,
    label_i18n: i18n_key:icon_arrow_big_left_dash_label,
    keywords: ["arrow-big-left-dash", "previous", "back", "direction", "west", "turn", "corner"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 57. arrow-big-left
CREATE icon:arrow_big_left CONTENT {
  identity: {
    value: 'arrow_big_left',
    slug: 'arrow-big-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_left_name,
    label_i18n: i18n_key:icon_arrow_big_left_label,
    keywords: ["arrow-big-left", "previous", "back", "direction", "west", "indicate turn"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 58. arrow-big-right-dash
CREATE icon:arrow_big_right_dash CONTENT {
  identity: {
    value: 'arrow_big_right_dash',
    slug: 'arrow-big-right-dash'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_right_dash_name,
    label_i18n: i18n_key:icon_arrow_big_right_dash_label,
    keywords: ["arrow-big-right-dash", "next", "forward", "direction", "east", "turn", "corner"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 59. arrow-big-right
CREATE icon:arrow_big_right CONTENT {
  identity: {
    value: 'arrow_big_right',
    slug: 'arrow-big-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_right_name,
    label_i18n: i18n_key:icon_arrow_big_right_label,
    keywords: ["arrow-big-right", "next", "forward", "direction", "east", "indicate turn"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 60. arrow-big-up-dash
CREATE icon:arrow_big_up_dash CONTENT {
  identity: {
    value: 'arrow_big_up_dash',
    slug: 'arrow-big-up-dash'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_up_dash_name,
    label_i18n: i18n_key:icon_arrow_big_up_dash_label,
    keywords: ["arrow-big-up-dash", "caps lock", "capitals", "keyboard", "button", "mac", "forward", "direction", "north", "faster", "speed", "boost"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 61. arrow-big-up
CREATE icon:arrow_big_up CONTENT {
  identity: {
    value: 'arrow_big_up',
    slug: 'arrow-big-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_big_up_name,
    label_i18n: i18n_key:icon_arrow_big_up_label,
    keywords: ["arrow-big-up", "shift", "keyboard", "button", "mac", "capitalize", "capitalise", "forward", "direction", "north"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 62. arrow-down-0-1
CREATE icon:arrow_down_0_1 CONTENT {
  identity: {
    value: 'arrow_down_0_1',
    slug: 'arrow-down-0-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_0_1_name,
    label_i18n: i18n_key:icon_arrow_down_0_1_label,
    keywords: ["arrow-down-0-1", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "numerical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 63. arrow-down-1-0
CREATE icon:arrow_down_1_0 CONTENT {
  identity: {
    value: 'arrow_down_1_0',
    slug: 'arrow-down-1-0'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_1_0_name,
    label_i18n: i18n_key:icon_arrow_down_1_0_label,
    keywords: ["arrow-down-1-0", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "numerical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 64. arrow-down-a-z
CREATE icon:arrow_down_a_z CONTENT {
  identity: {
    value: 'arrow_down_a_z',
    slug: 'arrow-down-a-z'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_a_z_name,
    label_i18n: i18n_key:icon_arrow_down_a_z_label,
    keywords: ["arrow-down-a-z", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "alphabetical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 65. arrow-down-from-line
CREATE icon:arrow_down_from_line CONTENT {
  identity: {
    value: 'arrow_down_from_line',
    slug: 'arrow-down-from-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_from_line_name,
    label_i18n: i18n_key:icon_arrow_down_from_line_label,
    keywords: ["arrow-down-from-line", "backwards", "reverse", "direction", "south", "download", "expand", "fold", "vertical"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 66. arrow-down-left
CREATE icon:arrow_down_left CONTENT {
  identity: {
    value: 'arrow_down_left',
    slug: 'arrow-down-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_left_name,
    label_i18n: i18n_key:icon_arrow_down_left_label,
    keywords: ["arrow-down-left", "direction", "south-west", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 67. arrow-down-narrow-wide
CREATE icon:arrow_down_narrow_wide CONTENT {
  identity: {
    value: 'arrow_down_narrow_wide',
    slug: 'arrow-down-narrow-wide'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_narrow_wide_name,
    label_i18n: i18n_key:icon_arrow_down_narrow_wide_label,
    keywords: ["arrow-down-narrow-wide", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 68. arrow-down-right
CREATE icon:arrow_down_right CONTENT {
  identity: {
    value: 'arrow_down_right',
    slug: 'arrow-down-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_right_name,
    label_i18n: i18n_key:icon_arrow_down_right_label,
    keywords: ["arrow-down-right", "direction", "south-east", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 69. arrow-down-to-dot
CREATE icon:arrow_down_to_dot CONTENT {
  identity: {
    value: 'arrow_down_to_dot',
    slug: 'arrow-down-to-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_to_dot_name,
    label_i18n: i18n_key:icon_arrow_down_to_dot_label,
    keywords: ["arrow-down-to-dot", "direction", "south", "waypoint", "location", "step", "into"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 70. arrow-down-to-line
CREATE icon:arrow_down_to_line CONTENT {
  identity: {
    value: 'arrow_down_to_line',
    slug: 'arrow-down-to-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_to_line_name,
    label_i18n: i18n_key:icon_arrow_down_to_line_label,
    keywords: ["arrow-down-to-line", "behind", "direction", "south", "download", "save", "git", "version control", "pull", "collapse", "fold", "vertical"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 71. arrow-down-up
CREATE icon:arrow_down_up CONTENT {
  identity: {
    value: 'arrow_down_up',
    slug: 'arrow-down-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_up_name,
    label_i18n: i18n_key:icon_arrow_down_up_label,
    keywords: ["arrow-down-up", "bidirectional", "two-way", "2-way", "swap", "switch", "network", "traffic", "flow", "mobile data", "internet", "sort", "reorder", "move"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 72. arrow-down-wide-narrow
CREATE icon:arrow_down_wide_narrow CONTENT {
  identity: {
    value: 'arrow_down_wide_narrow',
    slug: 'arrow-down-wide-narrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_wide_narrow_name,
    label_i18n: i18n_key:icon_arrow_down_wide_narrow_label,
    keywords: ["arrow-down-wide-narrow", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 73. arrow-down-z-a
CREATE icon:arrow_down_z_a CONTENT {
  identity: {
    value: 'arrow_down_z_a',
    slug: 'arrow-down-z-a'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_z_a_name,
    label_i18n: i18n_key:icon_arrow_down_z_a_label,
    keywords: ["arrow-down-z-a", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "alphabetical", "reverse"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 74. arrow-down
CREATE icon:arrow_down CONTENT {
  identity: {
    value: 'arrow_down',
    slug: 'arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_down_name,
    label_i18n: i18n_key:icon_arrow_down_label,
    keywords: ["arrow-down", "backwards", "reverse", "direction", "south"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 75. arrow-left-from-line
CREATE icon:arrow_left_from_line CONTENT {
  identity: {
    value: 'arrow_left_from_line',
    slug: 'arrow-left-from-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_left_from_line_name,
    label_i18n: i18n_key:icon_arrow_left_from_line_label,
    keywords: ["arrow-left-from-line", "previous", "back", "direction", "west", "expand", "fold", "horizontal", "<-|"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 76. arrow-left-right
CREATE icon:arrow_left_right CONTENT {
  identity: {
    value: 'arrow_left_right',
    slug: 'arrow-left-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_left_right_name,
    label_i18n: i18n_key:icon_arrow_left_right_label,
    keywords: ["arrow-left-right", "bidirectional", "two-way", "2-way", "swap", "switch", "transaction", "reorder", "move", "<-", "->"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 77. arrow-left-to-line
CREATE icon:arrow_left_to_line CONTENT {
  identity: {
    value: 'arrow_left_to_line',
    slug: 'arrow-left-to-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_left_to_line_name,
    label_i18n: i18n_key:icon_arrow_left_to_line_label,
    keywords: ["arrow-left-to-line", "previous", "back", "direction", "west", "collapse", "fold", "horizontal", "|<-"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 78. arrow-left
CREATE icon:arrow_left CONTENT {
  identity: {
    value: 'arrow_left',
    slug: 'arrow-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_left_name,
    label_i18n: i18n_key:icon_arrow_left_label,
    keywords: ["arrow-left", "previous", "back", "direction", "west", "<-"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 79. arrow-right-from-line
CREATE icon:arrow_right_from_line CONTENT {
  identity: {
    value: 'arrow_right_from_line',
    slug: 'arrow-right-from-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_right_from_line_name,
    label_i18n: i18n_key:icon_arrow_right_from_line_label,
    keywords: ["arrow-right-from-line", "next", "forward", "direction", "east", "export", "expand", "fold", "horizontal", "|->"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 80. arrow-right-left
CREATE icon:arrow_right_left CONTENT {
  identity: {
    value: 'arrow_right_left',
    slug: 'arrow-right-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_right_left_name,
    label_i18n: i18n_key:icon_arrow_right_left_label,
    keywords: ["arrow-right-left", "bidirectional", "two-way", "2-way", "swap", "switch", "transaction", "reorder", "move", "<-", "->"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 81. arrow-right-to-line
CREATE icon:arrow_right_to_line CONTENT {
  identity: {
    value: 'arrow_right_to_line',
    slug: 'arrow-right-to-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_right_to_line_name,
    label_i18n: i18n_key:icon_arrow_right_to_line_label,
    keywords: ["arrow-right-to-line", "next", "forward", "direction", "east", "tab", "keyboard", "mac", "indent", "collapse", "fold", "horizontal", "->|"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 82. arrow-right
CREATE icon:arrow_right CONTENT {
  identity: {
    value: 'arrow_right',
    slug: 'arrow-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_right_name,
    label_i18n: i18n_key:icon_arrow_right_label,
    keywords: ["arrow-right", "forward", "next", "direction", "east", "->"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 83. arrow-up-0-1
CREATE icon:arrow_up_0_1 CONTENT {
  identity: {
    value: 'arrow_up_0_1',
    slug: 'arrow-up-0-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_0_1_name,
    label_i18n: i18n_key:icon_arrow_up_0_1_label,
    keywords: ["arrow-up-0-1", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "numerical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 84. arrow-up-1-0
CREATE icon:arrow_up_1_0 CONTENT {
  identity: {
    value: 'arrow_up_1_0',
    slug: 'arrow-up-1-0'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_1_0_name,
    label_i18n: i18n_key:icon_arrow_up_1_0_label,
    keywords: ["arrow-up-1-0", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "numerical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 85. arrow-up-a-z
CREATE icon:arrow_up_a_z CONTENT {
  identity: {
    value: 'arrow_up_a_z',
    slug: 'arrow-up-a-z'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_a_z_name,
    label_i18n: i18n_key:icon_arrow_up_a_z_label,
    keywords: ["arrow-up-a-z", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "alphabetical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 86. arrow-up-down
CREATE icon:arrow_up_down CONTENT {
  identity: {
    value: 'arrow_up_down',
    slug: 'arrow-up-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_down_name,
    label_i18n: i18n_key:icon_arrow_up_down_label,
    keywords: ["arrow-up-down", "bidirectional", "two-way", "2-way", "swap", "switch", "network", "mobile data", "internet", "sort", "reorder", "move"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 87. arrow-up-from-dot
CREATE icon:arrow_up_from_dot CONTENT {
  identity: {
    value: 'arrow_up_from_dot',
    slug: 'arrow-up-from-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_from_dot_name,
    label_i18n: i18n_key:icon_arrow_up_from_dot_label,
    keywords: ["arrow-up-from-dot", "direction", "north", "step", "out"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 88. arrow-up-from-line
CREATE icon:arrow_up_from_line CONTENT {
  identity: {
    value: 'arrow_up_from_line',
    slug: 'arrow-up-from-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_from_line_name,
    label_i18n: i18n_key:icon_arrow_up_from_line_label,
    keywords: ["arrow-up-from-line", "forward", "direction", "north", "upload", "git", "version control", "push", "expand", "fold", "vertical"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 89. arrow-up-left
CREATE icon:arrow_up_left CONTENT {
  identity: {
    value: 'arrow_up_left',
    slug: 'arrow-up-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_left_name,
    label_i18n: i18n_key:icon_arrow_up_left_label,
    keywords: ["arrow-up-left", "direction", "north-west", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 90. arrow-up-narrow-wide
CREATE icon:arrow_up_narrow_wide CONTENT {
  identity: {
    value: 'arrow_up_narrow_wide',
    slug: 'arrow-up-narrow-wide'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_narrow_wide_name,
    label_i18n: i18n_key:icon_arrow_up_narrow_wide_label,
    keywords: ["arrow-up-narrow-wide", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 91. arrow-up-right
CREATE icon:arrow_up_right CONTENT {
  identity: {
    value: 'arrow_up_right',
    slug: 'arrow-up-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_right_name,
    label_i18n: i18n_key:icon_arrow_up_right_label,
    keywords: ["arrow-up-right", "direction", "north-east", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 92. arrow-up-to-line
CREATE icon:arrow_up_to_line CONTENT {
  identity: {
    value: 'arrow_up_to_line',
    slug: 'arrow-up-to-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_to_line_name,
    label_i18n: i18n_key:icon_arrow_up_to_line_label,
    keywords: ["arrow-up-to-line", "forward", "direction", "north", "upload", "collapse", "fold", "vertical"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 93. arrow-up-wide-narrow
CREATE icon:arrow_up_wide_narrow CONTENT {
  identity: {
    value: 'arrow_up_wide_narrow',
    slug: 'arrow-up-wide-narrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_wide_narrow_name,
    label_i18n: i18n_key:icon_arrow_up_wide_narrow_label,
    keywords: ["arrow-up-wide-narrow", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 94. arrow-up-z-a
CREATE icon:arrow_up_z_a CONTENT {
  identity: {
    value: 'arrow_up_z_a',
    slug: 'arrow-up-z-a'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_z_a_name,
    label_i18n: i18n_key:icon_arrow_up_z_a_label,
    keywords: ["arrow-up-z-a", "filter", "sort", "ascending", "descending", "increasing", "decreasing", "rising", "falling", "alphabetical", "reverse"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 95. arrow-up
CREATE icon:arrow_up CONTENT {
  identity: {
    value: 'arrow_up',
    slug: 'arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrow_up_name,
    label_i18n: i18n_key:icon_arrow_up_label,
    keywords: ["arrow-up", "forward", "direction", "north"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 96. arrows-up-from-line
CREATE icon:arrows_up_from_line CONTENT {
  identity: {
    value: 'arrows_up_from_line',
    slug: 'arrows-up-from-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_arrows_up_from_line_name,
    label_i18n: i18n_key:icon_arrows_up_from_line_label,
    keywords: ["arrows-up-from-line", "direction", "orientation", "this way up", "vertical", "package", "box", "fragile", "postage", "shipping"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 97. asterisk
CREATE icon:asterisk CONTENT {
  identity: {
    value: 'asterisk',
    slug: 'asterisk'
  },
  presentation: {
    name_i18n: i18n_key:icon_asterisk_name,
    label_i18n: i18n_key:icon_asterisk_label,
    keywords: ["asterisk", "reference", "times", "multiply", "multiplication", "operator", "code", "glob pattern", "wildcard", "*"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 98. at-sign
CREATE icon:at_sign CONTENT {
  identity: {
    value: 'at_sign',
    slug: 'at-sign'
  },
  presentation: {
    name_i18n: i18n_key:icon_at_sign_name,
    label_i18n: i18n_key:icon_at_sign_label,
    keywords: ["at-sign", "mention", "at", "email", "message", "@"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 99. atom
CREATE icon:atom CONTENT {
  identity: {
    value: 'atom',
    slug: 'atom'
  },
  presentation: {
    name_i18n: i18n_key:icon_atom_name,
    label_i18n: i18n_key:icon_atom_label,
    keywords: ["atom", "atomic", "nuclear", "physics", "particle", "element", "molecule", "electricity", "energy", "chemistry"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 100. audio-lines
CREATE icon:audio_lines CONTENT {
  identity: {
    value: 'audio_lines',
    slug: 'audio-lines'
  },
  presentation: {
    name_i18n: i18n_key:icon_audio_lines_name,
    label_i18n: i18n_key:icon_audio_lines_label,
    keywords: ["audio-lines", "graphic equaliser", "sound", "noise", "listen", "hearing", "hertz", "frequency", "wavelength", "vibrate", "sine", "synthesizer", "synthesiser", "levels", "track", "music", "playback", "radio", "broadcast", "airwaves", "voice", "vocals", "singer", "song"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 101. audio-waveform
CREATE icon:audio_waveform CONTENT {
  identity: {
    value: 'audio_waveform',
    slug: 'audio-waveform'
  },
  presentation: {
    name_i18n: i18n_key:icon_audio_waveform_name,
    label_i18n: i18n_key:icon_audio_waveform_label,
    keywords: ["audio-waveform", "sound", "noise", "listen", "hearing", "hertz", "frequency", "wavelength", "vibrate", "sine", "synthesizer", "synthesiser", "levels", "track", "music", "playback", "radio", "broadcast", "airwaves", "voice", "vocals", "singer", "song"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 102. award
CREATE icon:award CONTENT {
  identity: {
    value: 'award',
    slug: 'award'
  },
  presentation: {
    name_i18n: i18n_key:icon_award_name,
    label_i18n: i18n_key:icon_award_label,
    keywords: ["award", "achievement", "badge", "rosette", "prize", "winner"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 103. axe
CREATE icon:axe CONTENT {
  identity: {
    value: 'axe',
    slug: 'axe'
  },
  presentation: {
    name_i18n: i18n_key:icon_axe_name,
    label_i18n: i18n_key:icon_axe_label,
    keywords: ["axe", "hatchet", "weapon", "chop", "sharp", "equipment", "fireman", "firefighter", "brigade", "lumberjack", "woodcutter", "logger", "forestry"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 104. axis-3d
CREATE icon:axis_3d CONTENT {
  identity: {
    value: 'axis_3d',
    slug: 'axis-3d'
  },
  presentation: {
    name_i18n: i18n_key:icon_axis_3d_name,
    label_i18n: i18n_key:icon_axis_3d_label,
    keywords: ["axis-3d", "gizmo", "coordinates"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 105. baby
CREATE icon:baby CONTENT {
  identity: {
    value: 'baby',
    slug: 'baby'
  },
  presentation: {
    name_i18n: i18n_key:icon_baby_name,
    label_i18n: i18n_key:icon_baby_label,
    keywords: ["baby", "child", "childproof", "children"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 106. backpack
CREATE icon:backpack CONTENT {
  identity: {
    value: 'backpack',
    slug: 'backpack'
  },
  presentation: {
    name_i18n: i18n_key:icon_backpack_name,
    label_i18n: i18n_key:icon_backpack_label,
    keywords: ["backpack", "bag", "hiking", "travel", "camping", "school", "childhood"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 107. badge-alert
CREATE icon:badge_alert CONTENT {
  identity: {
    value: 'badge_alert',
    slug: 'badge-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_alert_name,
    label_i18n: i18n_key:icon_badge_alert_label,
    keywords: ["badge-alert", "check", "verified", "unverified", "security", "safety", "issue"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 108. badge-cent
CREATE icon:badge_cent CONTENT {
  identity: {
    value: 'badge_cent',
    slug: 'badge-cent'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_cent_name,
    label_i18n: i18n_key:icon_badge_cent_label,
    keywords: ["badge-cent", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "cents", "dollar", "usd", "$", "\u00a2"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 109. badge-check
CREATE icon:badge_check CONTENT {
  identity: {
    value: 'badge_check',
    slug: 'badge-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_check_name,
    label_i18n: i18n_key:icon_badge_check_label,
    keywords: ["badge-check", "verified", "check"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 110. badge-dollar-sign
CREATE icon:badge_dollar_sign CONTENT {
  identity: {
    value: 'badge_dollar_sign',
    slug: 'badge-dollar-sign'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_dollar_sign_name,
    label_i18n: i18n_key:icon_badge_dollar_sign_label,
    keywords: ["badge-dollar-sign", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "usd", "$"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 111. badge-euro
CREATE icon:badge_euro CONTENT {
  identity: {
    value: 'badge_euro',
    slug: 'badge-euro'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_euro_name,
    label_i18n: i18n_key:icon_badge_euro_label,
    keywords: ["badge-euro", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "\u20ac"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 112. badge-indian-rupee
CREATE icon:badge_indian_rupee CONTENT {
  identity: {
    value: 'badge_indian_rupee',
    slug: 'badge-indian-rupee'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_indian_rupee_name,
    label_i18n: i18n_key:icon_badge_indian_rupee_label,
    keywords: ["badge-indian-rupee", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "inr", "\u20b9"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 113. badge-info
CREATE icon:badge_info CONTENT {
  identity: {
    value: 'badge_info',
    slug: 'badge-info'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_info_name,
    label_i18n: i18n_key:icon_badge_info_label,
    keywords: ["badge-info", "verified", "unverified", "help"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 114. badge-japanese-yen
CREATE icon:badge_japanese_yen CONTENT {
  identity: {
    value: 'badge_japanese_yen',
    slug: 'badge-japanese-yen'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_japanese_yen_name,
    label_i18n: i18n_key:icon_badge_japanese_yen_label,
    keywords: ["badge-japanese-yen", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "jpy", "\u00a5"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 115. badge-minus
CREATE icon:badge_minus CONTENT {
  identity: {
    value: 'badge_minus',
    slug: 'badge-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_minus_name,
    label_i18n: i18n_key:icon_badge_minus_label,
    keywords: ["badge-minus", "verified", "unverified", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 116. badge-percent
CREATE icon:badge_percent CONTENT {
  identity: {
    value: 'badge_percent',
    slug: 'badge-percent'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_percent_name,
    label_i18n: i18n_key:icon_badge_percent_label,
    keywords: ["badge-percent", "verified", "unverified", "sale", "discount", "offer", "marketing", "sticker", "price tag"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 117. badge-plus
CREATE icon:badge_plus CONTENT {
  identity: {
    value: 'badge_plus',
    slug: 'badge-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_plus_name,
    label_i18n: i18n_key:icon_badge_plus_label,
    keywords: ["badge-plus", "verified", "unverified", "add", "create", "new"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 118. badge-pound-sterling
CREATE icon:badge_pound_sterling CONTENT {
  identity: {
    value: 'badge_pound_sterling',
    slug: 'badge-pound-sterling'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_pound_sterling_name,
    label_i18n: i18n_key:icon_badge_pound_sterling_label,
    keywords: ["badge-pound-sterling", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "british", "gbp", "\u00a3"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 119. badge-question-mark
CREATE icon:badge_question_mark CONTENT {
  identity: {
    value: 'badge_question_mark',
    slug: 'badge-question-mark'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_question_mark_name,
    label_i18n: i18n_key:icon_badge_question_mark_label,
    keywords: ["badge-question-mark", "verified", "unverified", "help"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 120. badge-russian-ruble
CREATE icon:badge_russian_ruble CONTENT {
  identity: {
    value: 'badge_russian_ruble',
    slug: 'badge-russian-ruble'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_russian_ruble_name,
    label_i18n: i18n_key:icon_badge_russian_ruble_label,
    keywords: ["badge-russian-ruble", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "rub", "\u20bd"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 121. badge-swiss-franc
CREATE icon:badge_swiss_franc CONTENT {
  identity: {
    value: 'badge_swiss_franc',
    slug: 'badge-swiss-franc'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_swiss_franc_name,
    label_i18n: i18n_key:icon_badge_swiss_franc_label,
    keywords: ["badge-swiss-franc", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "chf", "\u20a3"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 122. badge-turkish-lira
CREATE icon:badge_turkish_lira CONTENT {
  identity: {
    value: 'badge_turkish_lira',
    slug: 'badge-turkish-lira'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_turkish_lira_name,
    label_i18n: i18n_key:icon_badge_turkish_lira_label,
    keywords: ["badge-turkish-lira", "discount", "offer", "sale", "voucher", "tag", "monetization", "marketing", "finance", "financial", "exchange", "transaction", "payment", "try", "\u20ba"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 123. badge-x
CREATE icon:badge_x CONTENT {
  identity: {
    value: 'badge_x',
    slug: 'badge-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_x_name,
    label_i18n: i18n_key:icon_badge_x_label,
    keywords: ["badge-x", "verified", "unverified", "lost", "delete", "remove"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 124. badge
CREATE icon:badge CONTENT {
  identity: {
    value: 'badge',
    slug: 'badge'
  },
  presentation: {
    name_i18n: i18n_key:icon_badge_name,
    label_i18n: i18n_key:icon_badge_label,
    keywords: ["badge", "check", "verified", "unverified"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 125. baggage-claim
CREATE icon:baggage_claim CONTENT {
  identity: {
    value: 'baggage_claim',
    slug: 'baggage-claim'
  },
  presentation: {
    name_i18n: i18n_key:icon_baggage_claim_name,
    label_i18n: i18n_key:icon_baggage_claim_label,
    keywords: ["baggage-claim", "baggage", "luggage", "travel", "cart", "trolley", "suitcase"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 126. ban
CREATE icon:ban CONTENT {
  identity: {
    value: 'ban',
    slug: 'ban'
  },
  presentation: {
    name_i18n: i18n_key:icon_ban_name,
    label_i18n: i18n_key:icon_ban_label,
    keywords: ["ban", "cancel", "no", "stop", "forbidden", "prohibited", "error", "incorrect", "mistake", "wrong", "failure", "circle", "slash", "null", "void"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 127. banana
CREATE icon:banana CONTENT {
  identity: {
    value: 'banana',
    slug: 'banana'
  },
  presentation: {
    name_i18n: i18n_key:icon_banana_name,
    label_i18n: i18n_key:icon_banana_label,
    keywords: ["banana", "fruit", "food"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 128. bandage
CREATE icon:bandage CONTENT {
  identity: {
    value: 'bandage',
    slug: 'bandage'
  },
  presentation: {
    name_i18n: i18n_key:icon_bandage_name,
    label_i18n: i18n_key:icon_bandage_label,
    keywords: ["bandage", "plaster", "band-aid", "first aid", "medical", "health", "wound", "injury", "care", "treatment", "healing", "protection", "emergency", "aid", "safety", "patch"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 129. banknote-arrow-down
CREATE icon:banknote_arrow_down CONTENT {
  identity: {
    value: 'banknote_arrow_down',
    slug: 'banknote-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_banknote_arrow_down_name,
    label_i18n: i18n_key:icon_banknote_arrow_down_label,
    keywords: ["banknote-arrow-down", "bill", "currency", "money", "payment", "funds", "transaction", "cash", "finance", "withdraw", "expense", "out", "payout", "refund", "debit", "spending", "decrease"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 130. banknote-arrow-up
CREATE icon:banknote_arrow_up CONTENT {
  identity: {
    value: 'banknote_arrow_up',
    slug: 'banknote-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_banknote_arrow_up_name,
    label_i18n: i18n_key:icon_banknote_arrow_up_label,
    keywords: ["banknote-arrow-up", "bill", "currency", "money", "payment", "funds", "transaction", "cash", "finance", "deposit", "earnings", "income", "in", "credit", "prepaid", "growth", "increase"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 131. banknote-x
CREATE icon:banknote_x CONTENT {
  identity: {
    value: 'banknote_x',
    slug: 'banknote-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_banknote_x_name,
    label_i18n: i18n_key:icon_banknote_x_label,
    keywords: ["banknote-x", "bill", "currency", "money", "payment", "funds", "transaction", "cash", "finance", "error", "failed", "rejected", "canceled", "declined", "lost", "delete", "remove"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 132. banknote
CREATE icon:banknote CONTENT {
  identity: {
    value: 'banknote',
    slug: 'banknote'
  },
  presentation: {
    name_i18n: i18n_key:icon_banknote_name,
    label_i18n: i18n_key:icon_banknote_label,
    keywords: ["banknote", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 133. barcode
CREATE icon:barcode CONTENT {
  identity: {
    value: 'barcode',
    slug: 'barcode'
  },
  presentation: {
    name_i18n: i18n_key:icon_barcode_name,
    label_i18n: i18n_key:icon_barcode_label,
    keywords: ["barcode", "scan", "checkout", "till", "cart", "transaction", "purchase", "buy", "product", "packaging", "retail", "consumer"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 134. barrel
CREATE icon:barrel CONTENT {
  identity: {
    value: 'barrel',
    slug: 'barrel'
  },
  presentation: {
    name_i18n: i18n_key:icon_barrel_name,
    label_i18n: i18n_key:icon_barrel_label,
    keywords: ["barrel", "keg", "drum", "tank", "wine", "beer", "oak", "wood", "firkin", "hogshead", "kilderkin", "barrique", "solera", "aging", "whiskey", "brewery", "distillery", "winery", "vineyard"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 135. baseline
CREATE icon:baseline CONTENT {
  identity: {
    value: 'baseline',
    slug: 'baseline'
  },
  presentation: {
    name_i18n: i18n_key:icon_baseline_name,
    label_i18n: i18n_key:icon_baseline_label,
    keywords: ["baseline", "text", "format", "color"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 136. bath
CREATE icon:bath CONTENT {
  identity: {
    value: 'bath',
    slug: 'bath'
  },
  presentation: {
    name_i18n: i18n_key:icon_bath_name,
    label_i18n: i18n_key:icon_bath_label,
    keywords: ["bath", "amenities", "services", "bathroom", "shower"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 137. battery-charging
CREATE icon:battery_charging CONTENT {
  identity: {
    value: 'battery_charging',
    slug: 'battery-charging'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_charging_name,
    label_i18n: i18n_key:icon_battery_charging_label,
    keywords: ["battery-charging", "power", "electricity", "energy", "accumulator", "charge"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 138. battery-full
CREATE icon:battery_full CONTENT {
  identity: {
    value: 'battery_full',
    slug: 'battery-full'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_full_name,
    label_i18n: i18n_key:icon_battery_full_label,
    keywords: ["battery-full", "power", "electricity", "energy", "accumulator", "charge"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 139. battery-low
CREATE icon:battery_low CONTENT {
  identity: {
    value: 'battery_low',
    slug: 'battery-low'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_low_name,
    label_i18n: i18n_key:icon_battery_low_label,
    keywords: ["battery-low", "power", "electricity", "energy", "accumulator", "charge"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 140. battery-medium
CREATE icon:battery_medium CONTENT {
  identity: {
    value: 'battery_medium',
    slug: 'battery-medium'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_medium_name,
    label_i18n: i18n_key:icon_battery_medium_label,
    keywords: ["battery-medium", "power", "electricity", "energy", "accumulator", "charge"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 141. battery-plus
CREATE icon:battery_plus CONTENT {
  identity: {
    value: 'battery_plus',
    slug: 'battery-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_plus_name,
    label_i18n: i18n_key:icon_battery_plus_label,
    keywords: ["battery-plus", "power", "electricity", "energy", "accumulator", "charge", "plus", "economy", "health", "add", "new", "maximum", "upgrade", "extra", "+"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 142. battery-warning
CREATE icon:battery_warning CONTENT {
  identity: {
    value: 'battery_warning',
    slug: 'battery-warning'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_warning_name,
    label_i18n: i18n_key:icon_battery_warning_label,
    keywords: ["battery-warning", "power", "electricity", "energy", "accumulator", "charge", "exclamation mark"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 143. battery
CREATE icon:battery CONTENT {
  identity: {
    value: 'battery',
    slug: 'battery'
  },
  presentation: {
    name_i18n: i18n_key:icon_battery_name,
    label_i18n: i18n_key:icon_battery_label,
    keywords: ["battery", "power", "electricity", "energy", "accumulator", "charge"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 144. beaker
CREATE icon:beaker CONTENT {
  identity: {
    value: 'beaker',
    slug: 'beaker'
  },
  presentation: {
    name_i18n: i18n_key:icon_beaker_name,
    label_i18n: i18n_key:icon_beaker_label,
    keywords: ["beaker", "cup", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 145. bean-off
CREATE icon:bean_off CONTENT {
  identity: {
    value: 'bean_off',
    slug: 'bean-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_bean_off_name,
    label_i18n: i18n_key:icon_bean_off_label,
    keywords: ["bean-off", "soy free", "legume", "soy", "food", "seed", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 146. bean
CREATE icon:bean CONTENT {
  identity: {
    value: 'bean',
    slug: 'bean'
  },
  presentation: {
    name_i18n: i18n_key:icon_bean_name,
    label_i18n: i18n_key:icon_bean_label,
    keywords: ["bean", "legume", "soy", "food", "seed"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 147. bed-double
CREATE icon:bed_double CONTENT {
  identity: {
    value: 'bed_double',
    slug: 'bed-double'
  },
  presentation: {
    name_i18n: i18n_key:icon_bed_double_name,
    label_i18n: i18n_key:icon_bed_double_label,
    keywords: ["bed-double", "sleep", "hotel", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 148. bed-single
CREATE icon:bed_single CONTENT {
  identity: {
    value: 'bed_single',
    slug: 'bed-single'
  },
  presentation: {
    name_i18n: i18n_key:icon_bed_single_name,
    label_i18n: i18n_key:icon_bed_single_label,
    keywords: ["bed-single", "sleep", "hotel", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 149. bed
CREATE icon:bed CONTENT {
  identity: {
    value: 'bed',
    slug: 'bed'
  },
  presentation: {
    name_i18n: i18n_key:icon_bed_name,
    label_i18n: i18n_key:icon_bed_label,
    keywords: ["bed", "sleep", "hotel", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 150. beef
CREATE icon:beef CONTENT {
  identity: {
    value: 'beef',
    slug: 'beef'
  },
  presentation: {
    name_i18n: i18n_key:icon_beef_name,
    label_i18n: i18n_key:icon_beef_label,
    keywords: ["beef", "food", "dish", "restaurant", "course", "meal", "meat", "bbq", "steak"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 151. beer-off
CREATE icon:beer_off CONTENT {
  identity: {
    value: 'beer_off',
    slug: 'beer-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_beer_off_name,
    label_i18n: i18n_key:icon_beer_off_label,
    keywords: ["beer-off", "alcohol", "bar", "beverage", "brewery", "drink"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 152. beer
CREATE icon:beer CONTENT {
  identity: {
    value: 'beer',
    slug: 'beer'
  },
  presentation: {
    name_i18n: i18n_key:icon_beer_name,
    label_i18n: i18n_key:icon_beer_label,
    keywords: ["beer", "alcohol", "bar", "beverage", "brewery", "drink"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 153. bell-dot
CREATE icon:bell_dot CONTENT {
  identity: {
    value: 'bell_dot',
    slug: 'bell-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_dot_name,
    label_i18n: i18n_key:icon_bell_dot_label,
    keywords: ["bell-dot", "alarm", "notification", "sound", "reminder", "unread"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 154. bell-electric
CREATE icon:bell_electric CONTENT {
  identity: {
    value: 'bell_electric',
    slug: 'bell-electric'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_electric_name,
    label_i18n: i18n_key:icon_bell_electric_label,
    keywords: ["bell-electric", "fire alarm", "flames", "smoke", "firefighter", "fireman", "department", "brigade", "station", "emergency", "alert", "safety", "school bell", "period break", "recess", "doorbell", "entrance", "entry", "ring", "reception"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 155. bell-minus
CREATE icon:bell_minus CONTENT {
  identity: {
    value: 'bell_minus',
    slug: 'bell-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_minus_name,
    label_i18n: i18n_key:icon_bell_minus_label,
    keywords: ["bell-minus", "alarm", "notification", "silent", "reminder", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 156. bell-off
CREATE icon:bell_off CONTENT {
  identity: {
    value: 'bell_off',
    slug: 'bell-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_off_name,
    label_i18n: i18n_key:icon_bell_off_label,
    keywords: ["bell-off", "alarm", "notification", "silent", "reminder"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 157. bell-plus
CREATE icon:bell_plus CONTENT {
  identity: {
    value: 'bell_plus',
    slug: 'bell-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_plus_name,
    label_i18n: i18n_key:icon_bell_plus_label,
    keywords: ["bell-plus", "notification", "silent", "reminder", "add", "create", "new"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 158. bell-ring
CREATE icon:bell_ring CONTENT {
  identity: {
    value: 'bell_ring',
    slug: 'bell-ring'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_ring_name,
    label_i18n: i18n_key:icon_bell_ring_label,
    keywords: ["bell-ring", "alarm", "notification", "sound", "reminder"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 159. bell
CREATE icon:bell CONTENT {
  identity: {
    value: 'bell',
    slug: 'bell'
  },
  presentation: {
    name_i18n: i18n_key:icon_bell_name,
    label_i18n: i18n_key:icon_bell_label,
    keywords: ["bell", "alarm", "notification", "sound", "reminder"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 160. between-horizontal-end
CREATE icon:between_horizontal_end CONTENT {
  identity: {
    value: 'between_horizontal_end',
    slug: 'between-horizontal-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_between_horizontal_end_name,
    label_i18n: i18n_key:icon_between_horizontal_end_label,
    keywords: ["between-horizontal-end", "insert", "add", "left", "slot", "squeeze", "space", "vertical", "grid", "table", "rows", "cells", "excel", "spreadsheet", "accountancy", "data", "enter", "entry", "entries", "blocks", "rectangles", "chevron"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 161. between-horizontal-start
CREATE icon:between_horizontal_start CONTENT {
  identity: {
    value: 'between_horizontal_start',
    slug: 'between-horizontal-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_between_horizontal_start_name,
    label_i18n: i18n_key:icon_between_horizontal_start_label,
    keywords: ["between-horizontal-start", "insert", "add", "right", "slot", "squeeze", "space", "vertical", "grid", "table", "rows", "cells", "excel", "spreadsheet", "accountancy", "data", "enter", "entry", "entries", "blocks", "rectangles", "chevron"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 162. between-vertical-end
CREATE icon:between_vertical_end CONTENT {
  identity: {
    value: 'between_vertical_end',
    slug: 'between-vertical-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_between_vertical_end_name,
    label_i18n: i18n_key:icon_between_vertical_end_label,
    keywords: ["between-vertical-end", "insert", "add", "top", "slot", "squeeze", "space", "vertical", "grid", "table", "columns", "cells", "data", "enter", "entry", "entries", "blocks", "rectangles", "chevron"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 163. between-vertical-start
CREATE icon:between_vertical_start CONTENT {
  identity: {
    value: 'between_vertical_start',
    slug: 'between-vertical-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_between_vertical_start_name,
    label_i18n: i18n_key:icon_between_vertical_start_label,
    keywords: ["between-vertical-start", "insert", "add", "bottom", "slot", "squeeze", "space", "vertical", "grid", "table", "columns", "cells", "data", "enter", "entry", "entries", "blocks", "rectangles", "chevron"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 164. biceps-flexed
CREATE icon:biceps_flexed CONTENT {
  identity: {
    value: 'biceps_flexed',
    slug: 'biceps-flexed'
  },
  presentation: {
    name_i18n: i18n_key:icon_biceps_flexed_name,
    label_i18n: i18n_key:icon_biceps_flexed_label,
    keywords: ["biceps-flexed", "arm", "muscle", "strong", "working out", "athletic", "toned", "muscular", "forelimb", "curled"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 165. bike
CREATE icon:bike CONTENT {
  identity: {
    value: 'bike',
    slug: 'bike'
  },
  presentation: {
    name_i18n: i18n_key:icon_bike_name,
    label_i18n: i18n_key:icon_bike_label,
    keywords: ["bike", "bicycle", "transport", "trip"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 166. binary
CREATE icon:binary CONTENT {
  identity: {
    value: 'binary',
    slug: 'binary'
  },
  presentation: {
    name_i18n: i18n_key:icon_binary_name,
    label_i18n: i18n_key:icon_binary_label,
    keywords: ["binary", "code", "digits", "computer", "zero", "one", "boolean"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 167. binoculars
CREATE icon:binoculars CONTENT {
  identity: {
    value: 'binoculars',
    slug: 'binoculars'
  },
  presentation: {
    name_i18n: i18n_key:icon_binoculars_name,
    label_i18n: i18n_key:icon_binoculars_label,
    keywords: ["binoculars", "field glasses", "lorgnette", "pince-nez", "observation", "sightseeing", "nature", "wildlife", "birdwatching", "scouting", "surveillance", "search", "discovery", "monitoring", "lookout", "viewpoint", "travel", "tourism", "research"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 168. biohazard
CREATE icon:biohazard CONTENT {
  identity: {
    value: 'biohazard',
    slug: 'biohazard'
  },
  presentation: {
    name_i18n: i18n_key:icon_biohazard_name,
    label_i18n: i18n_key:icon_biohazard_label,
    keywords: ["biohazard", "fallout", "waste", "biology", "chemistry", "chemical", "element"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 169. bird
CREATE icon:bird CONTENT {
  identity: {
    value: 'bird',
    slug: 'bird'
  },
  presentation: {
    name_i18n: i18n_key:icon_bird_name,
    label_i18n: i18n_key:icon_bird_label,
    keywords: ["bird", "peace", "freedom", "wing", "avian", "tweet"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 170. birdhouse
CREATE icon:birdhouse CONTENT {
  identity: {
    value: 'birdhouse',
    slug: 'birdhouse'
  },
  presentation: {
    name_i18n: i18n_key:icon_birdhouse_name,
    label_i18n: i18n_key:icon_birdhouse_label,
    keywords: ["birdhouse", "birdhouse", "bird", "garden", "home", "house", "woodwork"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 171. bitcoin
CREATE icon:bitcoin CONTENT {
  identity: {
    value: 'bitcoin',
    slug: 'bitcoin'
  },
  presentation: {
    name_i18n: i18n_key:icon_bitcoin_name,
    label_i18n: i18n_key:icon_bitcoin_label,
    keywords: ["bitcoin", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 172. blend
CREATE icon:blend CONTENT {
  identity: {
    value: 'blend',
    slug: 'blend'
  },
  presentation: {
    name_i18n: i18n_key:icon_blend_name,
    label_i18n: i18n_key:icon_blend_label,
    keywords: ["blend", "mode", "overlay", "multiply", "screen", "opacity", "transparency", "alpha", "filters", "lenses", "mixed", "shades", "tints", "hues", "saturation", "brightness", "overlap", "colors", "colours"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 173. blinds
CREATE icon:blinds CONTENT {
  identity: {
    value: 'blinds',
    slug: 'blinds'
  },
  presentation: {
    name_i18n: i18n_key:icon_blinds_name,
    label_i18n: i18n_key:icon_blinds_label,
    keywords: ["blinds", "shades", "screen", "curtain", "shutter", "roller blind", "window", "lighting", "household", "home"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 174. blocks
CREATE icon:blocks CONTENT {
  identity: {
    value: 'blocks',
    slug: 'blocks'
  },
  presentation: {
    name_i18n: i18n_key:icon_blocks_name,
    label_i18n: i18n_key:icon_blocks_label,
    keywords: ["blocks", "addon", "plugin", "integration", "extension", "package", "build", "stack", "toys", "kids", "children", "learning", "squares", "corner"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 175. bluetooth-connected
CREATE icon:bluetooth_connected CONTENT {
  identity: {
    value: 'bluetooth_connected',
    slug: 'bluetooth-connected'
  },
  presentation: {
    name_i18n: i18n_key:icon_bluetooth_connected_name,
    label_i18n: i18n_key:icon_bluetooth_connected_label,
    keywords: ["bluetooth-connected", "paired"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 176. bluetooth-off
CREATE icon:bluetooth_off CONTENT {
  identity: {
    value: 'bluetooth_off',
    slug: 'bluetooth-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_bluetooth_off_name,
    label_i18n: i18n_key:icon_bluetooth_off_label,
    keywords: ["bluetooth-off", "lost"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 177. bluetooth-searching
CREATE icon:bluetooth_searching CONTENT {
  identity: {
    value: 'bluetooth_searching',
    slug: 'bluetooth-searching'
  },
  presentation: {
    name_i18n: i18n_key:icon_bluetooth_searching_name,
    label_i18n: i18n_key:icon_bluetooth_searching_label,
    keywords: ["bluetooth-searching", "pairing"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 178. bluetooth
CREATE icon:bluetooth CONTENT {
  identity: {
    value: 'bluetooth',
    slug: 'bluetooth'
  },
  presentation: {
    name_i18n: i18n_key:icon_bluetooth_name,
    label_i18n: i18n_key:icon_bluetooth_label,
    keywords: ["bluetooth", "wireless"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 179. bold
CREATE icon:bold CONTENT {
  identity: {
    value: 'bold',
    slug: 'bold'
  },
  presentation: {
    name_i18n: i18n_key:icon_bold_name,
    label_i18n: i18n_key:icon_bold_label,
    keywords: ["bold", "text", "strong", "format"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 180. bolt
CREATE icon:bolt CONTENT {
  identity: {
    value: 'bolt',
    slug: 'bolt'
  },
  presentation: {
    name_i18n: i18n_key:icon_bolt_name,
    label_i18n: i18n_key:icon_bolt_label,
    keywords: ["bolt", "nut", "screw", "settings", "preferences", "configuration", "controls", "edit", "diy", "fixed", "build", "construction", "parts"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 181. bomb
CREATE icon:bomb CONTENT {
  identity: {
    value: 'bomb',
    slug: 'bomb'
  },
  presentation: {
    name_i18n: i18n_key:icon_bomb_name,
    label_i18n: i18n_key:icon_bomb_label,
    keywords: ["bomb", "fatal", "error", "crash", "blockbuster", "mine", "explosion", "explode", "explosive"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 182. bone
CREATE icon:bone CONTENT {
  identity: {
    value: 'bone',
    slug: 'bone'
  },
  presentation: {
    name_i18n: i18n_key:icon_bone_name,
    label_i18n: i18n_key:icon_bone_label,
    keywords: ["bone", "health", "skeleton", "skull", "death", "pets", "dog"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 183. book-a
CREATE icon:book_a CONTENT {
  identity: {
    value: 'book_a',
    slug: 'book-a'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_a_name,
    label_i18n: i18n_key:icon_book_a_label,
    keywords: ["book-a", "dictionary", "define", "definition", "thesaurus", "encyclopedia", "encyclopaedia", "reading", "booklet", "magazine", "leaflet", "pamphlet", "tome", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "language", "translate", "alphabetical", "a-z", "ordered"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 184. book-alert
CREATE icon:book_alert CONTENT {
  identity: {
    value: 'book_alert',
    slug: 'book-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_alert_name,
    label_i18n: i18n_key:icon_book_alert_label,
    keywords: ["book-alert", "reading", "paperback", "booklet", "magazine", "leaflet", "pamphlet", "tome", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "documentation", "warning", "alert", "danger", "exclamation mark"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 185. book-audio
CREATE icon:book_audio CONTENT {
  identity: {
    value: 'book_audio',
    slug: 'book-audio'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_audio_name,
    label_i18n: i18n_key:icon_book_audio_label,
    keywords: ["book-audio", "audiobook", "reading", "listening", "sound", "story", "fiction", "novel", "information", "knowledge", "education", "student", "study", "learning", "research"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 186. book-check
CREATE icon:book_check CONTENT {
  identity: {
    value: 'book_check',
    slug: 'book-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_check_name,
    label_i18n: i18n_key:icon_book_check_label,
    keywords: ["book-check", "read", "booklet", "magazine", "leaflet", "pamphlet", "library", "written", "authored", "published", "informed", "knowledgeable", "educated", "schooled", "homework", "examined", "tested", "marked", "passed", "graduated", "studied", "learned", "lesson", "researched", "documented", "revealed", "blank", "plain language", "true", "truth", "verified", "corrected", "task", "todo", "done", "completed", "finished", "ticked"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 187. book-copy
CREATE icon:book_copy CONTENT {
  identity: {
    value: 'book_copy',
    slug: 'book-copy'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_copy_name,
    label_i18n: i18n_key:icon_book_copy_label,
    keywords: ["book-copy", "code", "coding", "version control", "git", "repository", "clone", "fork", "duplicate", "multiple", "books", "library", "copies", "copied", "plagiarism", "plagiarised", "plagiarized", "reading list", "information", "informed", "knowledge", "knowledgeable", "knowledgable", "education", "high school", "university", "college", "academy", "student", "study", "learning", "research", "smart", "intelligent", "intellectual"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 188. book-dashed
CREATE icon:book_dashed CONTENT {
  identity: {
    value: 'book_dashed',
    slug: 'book-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_dashed_name,
    label_i18n: i18n_key:icon_book_dashed_label,
    keywords: ["book-dashed", "code", "coding", "version control", "git", "repository", "template", "draft", "script", "screenplay", "writing", "writer", "author", "unwritten", "unpublished", "untold"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 189. book-down
CREATE icon:book_down CONTENT {
  identity: {
    value: 'book_down',
    slug: 'book-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_down_name,
    label_i18n: i18n_key:icon_book_down_label,
    keywords: ["book-down", "code", "coding", "version control", "git", "repository", "pull"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 190. book-headphones
CREATE icon:book_headphones CONTENT {
  identity: {
    value: 'book_headphones',
    slug: 'book-headphones'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_headphones_name,
    label_i18n: i18n_key:icon_book_headphones_label,
    keywords: ["book-headphones", "audiobook", "reading", "listening", "sound", "story", "fiction", "novel", "information", "knowledge", "education", "student", "study", "learning", "research"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 191. book-heart
CREATE icon:book_heart CONTENT {
  identity: {
    value: 'book_heart',
    slug: 'book-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_heart_name,
    label_i18n: i18n_key:icon_book_heart_label,
    keywords: ["book-heart", "diary", "romance", "novel", "journal", "entry", "entries", "personal", "private", "secret", "crush", "like", "love", "emotion", "feminine", "girls", "teens", "teenager", "therapy", "theraputic", "therapist", "planner", "organizer", "organiser", "notes", "notepad", "stationery", "sketchbook", "writing", "written", "reading", "favorite", "favourite", "high school"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 192. book-image
CREATE icon:book_image CONTENT {
  identity: {
    value: 'book_image',
    slug: 'book-image'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_image_name,
    label_i18n: i18n_key:icon_book_image_label,
    keywords: ["book-image", "images", "pictures", "photos", "album", "collection", "event", "magazine", "catalog", "catalogue", "brochure", "browse", "gallery"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 193. book-key
CREATE icon:book_key CONTENT {
  identity: {
    value: 'book_key',
    slug: 'book-key'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_key_name,
    label_i18n: i18n_key:icon_book_key_label,
    keywords: ["book-key", "code", "coding", "version control", "git", "repository", "private", "public", "secret", "unlocked", "hidden", "revealed", "knowledge", "learning"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 194. book-lock
CREATE icon:book_lock CONTENT {
  identity: {
    value: 'book_lock',
    slug: 'book-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_lock_name,
    label_i18n: i18n_key:icon_book_lock_label,
    keywords: ["book-lock", "code", "coding", "version control", "git", "repository", "private", "secret", "hidden", "knowledge"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 195. book-marked
CREATE icon:book_marked CONTENT {
  identity: {
    value: 'book_marked',
    slug: 'book-marked'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_marked_name,
    label_i18n: i18n_key:icon_book_marked_label,
    keywords: ["book-marked", "dictionary", "reading", "booklet", "magazine", "leaflet", "pamphlet", "tome", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "documentation", "saved", "later", "future", "reference", "index", "code", "coding", "version control", "git", "repository"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 196. book-minus
CREATE icon:book_minus CONTENT {
  identity: {
    value: 'book_minus',
    slug: 'book-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_minus_name,
    label_i18n: i18n_key:icon_book_minus_label,
    keywords: ["book-minus", "code", "coding", "version control", "git", "repository", "remove", "delete", "censor", "cancel", "forbid", "prohibit", "ban", "uneducated", "re-educate", "unlearn", "downgrade"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 197. book-open-check
CREATE icon:book_open_check CONTENT {
  identity: {
    value: 'book_open_check',
    slug: 'book-open-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_open_check_name,
    label_i18n: i18n_key:icon_book_open_check_label,
    keywords: ["book-open-check", "read", "pages", "booklet", "magazine", "leaflet", "pamphlet", "library", "written", "authored", "published", "informed", "knowledgeable", "educated", "schooled", "homework", "examined", "tested", "marked", "passed", "graduated", "studied", "learned", "lesson", "researched", "documented", "revealed", "blank", "plain language", "true", "truth", "verified", "corrected", "task", "todo", "done", "completed", "finished", "ticked"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 198. book-open-text
CREATE icon:book_open_text CONTENT {
  identity: {
    value: 'book_open_text',
    slug: 'book-open-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_open_text_name,
    label_i18n: i18n_key:icon_book_open_text_label,
    keywords: ["book-open-text", "reading", "pages", "booklet", "magazine", "leaflet", "pamphlet", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "documentation", "revealed"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 199. book-open
CREATE icon:book_open CONTENT {
  identity: {
    value: 'book_open',
    slug: 'book-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_open_name,
    label_i18n: i18n_key:icon_book_open_label,
    keywords: ["book-open", "reading", "pages", "booklet", "magazine", "leaflet", "pamphlet", "library", "writing", "written", "writer", "author", "story", "script", "screenplay", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "documentation", "revealed", "blank", "plain"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 200. book-plus
CREATE icon:book_plus CONTENT {
  identity: {
    value: 'book_plus',
    slug: 'book-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_plus_name,
    label_i18n: i18n_key:icon_book_plus_label,
    keywords: ["book-plus", "code", "coding", "version control", "git", "repository", "remove", "delete", "read", "write", "author", "publish", "inform", "graduate", "re-educate", "study", "learn", "research", "knowledge", "improve", "upgrade", "level up"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 201. book-text
CREATE icon:book_text CONTENT {
  identity: {
    value: 'book_text',
    slug: 'book-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_text_name,
    label_i18n: i18n_key:icon_book_text_label,
    keywords: ["book-text", "reading", "booklet", "magazine", "leaflet", "pamphlet", "tome", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "documentation"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 202. book-type
CREATE icon:book_type CONTENT {
  identity: {
    value: 'book_type',
    slug: 'book-type'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_type_name,
    label_i18n: i18n_key:icon_book_type_label,
    keywords: ["book-type", "thesaurus", "synonym", "reading", "booklet", "magazine", "leaflet", "pamphlet", "tome", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "language", "translate", "typography", "fonts", "collection"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 203. book-up-2
CREATE icon:book_up_2 CONTENT {
  identity: {
    value: 'book_up_2',
    slug: 'book-up-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_up_2_name,
    label_i18n: i18n_key:icon_book_up_2_label,
    keywords: ["book-up-2", "code", "coding", "version control", "git", "repository", "push", "force"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 204. book-up
CREATE icon:book_up CONTENT {
  identity: {
    value: 'book_up',
    slug: 'book-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_up_name,
    label_i18n: i18n_key:icon_book_up_label,
    keywords: ["book-up", "code", "coding", "version control", "git", "repository", "push"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 205. book-user
CREATE icon:book_user CONTENT {
  identity: {
    value: 'book_user',
    slug: 'book-user'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_user_name,
    label_i18n: i18n_key:icon_book_user_label,
    keywords: ["book-user", "person", "people", "family", "friends", "acquaintances", "contacts", "details", "addresses", "phone numbers", "directory", "listing", "networking"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 206. book-x
CREATE icon:book_x CONTENT {
  identity: {
    value: 'book_x',
    slug: 'book-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_x_name,
    label_i18n: i18n_key:icon_book_x_label,
    keywords: ["book-x", "code", "coding", "version control", "git", "repository", "remove", "delete", "reading", "misinformation", "disinformation", "misinformed", "charlatan", "sophistry", "false", "lies", "untruth", "propaganda", "censored", "cancelled", "forbidden", "prohibited", "banned", "uneducated", "re-education", "unlearn"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 207. book
CREATE icon:book CONTENT {
  identity: {
    value: 'book',
    slug: 'book'
  },
  presentation: {
    name_i18n: i18n_key:icon_book_name,
    label_i18n: i18n_key:icon_book_label,
    keywords: ["book", "reading", "paperback", "booklet", "magazine", "leaflet", "pamphlet", "tome", "library", "writing", "written", "writer", "author", "story", "script", "fiction", "novel", "information", "knowledge", "education", "high school", "university", "college", "academy", "student", "study", "learning", "homework", "research", "documentation"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 208. bookmark-check
CREATE icon:bookmark_check CONTENT {
  identity: {
    value: 'bookmark_check',
    slug: 'bookmark-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_bookmark_check_name,
    label_i18n: i18n_key:icon_bookmark_check_label,
    keywords: ["bookmark-check", "read", "finished", "complete", "clip", "marker", "tag", "task", "todo"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 209. bookmark-minus
CREATE icon:bookmark_minus CONTENT {
  identity: {
    value: 'bookmark_minus',
    slug: 'bookmark-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_bookmark_minus_name,
    label_i18n: i18n_key:icon_bookmark_minus_label,
    keywords: ["bookmark-minus", "delete", "remove"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 210. bookmark-plus
CREATE icon:bookmark_plus CONTENT {
  identity: {
    value: 'bookmark_plus',
    slug: 'bookmark-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_bookmark_plus_name,
    label_i18n: i18n_key:icon_bookmark_plus_label,
    keywords: ["bookmark-plus", "add"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 211. bookmark-x
CREATE icon:bookmark_x CONTENT {
  identity: {
    value: 'bookmark_x',
    slug: 'bookmark-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_bookmark_x_name,
    label_i18n: i18n_key:icon_bookmark_x_label,
    keywords: ["bookmark-x", "read", "clip", "marker", "tag", "cancel", "close", "delete", "remove", "clear"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 212. bookmark
CREATE icon:bookmark CONTENT {
  identity: {
    value: 'bookmark',
    slug: 'bookmark'
  },
  presentation: {
    name_i18n: i18n_key:icon_bookmark_name,
    label_i18n: i18n_key:icon_bookmark_label,
    keywords: ["bookmark", "read", "clip", "marker", "tag"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 213. boom-box
CREATE icon:boom_box CONTENT {
  identity: {
    value: 'boom_box',
    slug: 'boom-box'
  },
  presentation: {
    name_i18n: i18n_key:icon_boom_box_name,
    label_i18n: i18n_key:icon_boom_box_label,
    keywords: ["boom-box", "radio", "speakers", "audio", "music", "sound", "broadcast", "live", "frequency"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 214. bot-message-square
CREATE icon:bot_message_square CONTENT {
  identity: {
    value: 'bot_message_square',
    slug: 'bot-message-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_bot_message_square_name,
    label_i18n: i18n_key:icon_bot_message_square_label,
    keywords: ["bot-message-square", "robot", "ai", "chat", "assistant"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 215. bot-off
CREATE icon:bot_off CONTENT {
  identity: {
    value: 'bot_off',
    slug: 'bot-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_bot_off_name,
    label_i18n: i18n_key:icon_bot_off_label,
    keywords: ["bot-off", "robot", "ai", "chat", "assistant"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 216. bot
CREATE icon:bot CONTENT {
  identity: {
    value: 'bot',
    slug: 'bot'
  },
  presentation: {
    name_i18n: i18n_key:icon_bot_name,
    label_i18n: i18n_key:icon_bot_label,
    keywords: ["bot", "robot", "ai", "chat", "assistant"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 217. bottle-wine
CREATE icon:bottle_wine CONTENT {
  identity: {
    value: 'bottle_wine',
    slug: 'bottle-wine'
  },
  presentation: {
    name_i18n: i18n_key:icon_bottle_wine_name,
    label_i18n: i18n_key:icon_bottle_wine_label,
    keywords: ["bottle-wine", "alcohol", "drink", "glass", "goblet", "chalice", "vineyard", "winery", "red", "white", "rose", "dry", "sparkling", "bar", "party", "nightclub", "nightlife", "sommelier", "restaurant", "dinner", "meal"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 218. bow-arrow
CREATE icon:bow_arrow CONTENT {
  identity: {
    value: 'bow_arrow',
    slug: 'bow-arrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_bow_arrow_name,
    label_i18n: i18n_key:icon_bow_arrow_label,
    keywords: ["bow-arrow", "archer", "archery", "game", "war", "weapon"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 219. box
CREATE icon:box CONTENT {
  identity: {
    value: 'box',
    slug: 'box'
  },
  presentation: {
    name_i18n: i18n_key:icon_box_name,
    label_i18n: i18n_key:icon_box_label,
    keywords: ["box", "cube", "package", "container", "storage", "geometry", "3d", "isometric"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 220. boxes
CREATE icon:boxes CONTENT {
  identity: {
    value: 'boxes',
    slug: 'boxes'
  },
  presentation: {
    name_i18n: i18n_key:icon_boxes_name,
    label_i18n: i18n_key:icon_boxes_label,
    keywords: ["boxes", "cubes", "packages", "parts", "group", "units", "collection", "cluster", "geometry"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 221. braces
CREATE icon:braces CONTENT {
  identity: {
    value: 'braces',
    slug: 'braces'
  },
  presentation: {
    name_i18n: i18n_key:icon_braces_name,
    label_i18n: i18n_key:icon_braces_label,
    keywords: ["braces", "json", "code", "token", "curly brackets", "data", "{", "}"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 222. brackets
CREATE icon:brackets CONTENT {
  identity: {
    value: 'brackets',
    slug: 'brackets'
  },
  presentation: {
    name_i18n: i18n_key:icon_brackets_name,
    label_i18n: i18n_key:icon_brackets_label,
    keywords: ["brackets", "code", "token", "array", "list", "square", "[", "]"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 223. brain-circuit
CREATE icon:brain_circuit CONTENT {
  identity: {
    value: 'brain_circuit',
    slug: 'brain-circuit'
  },
  presentation: {
    name_i18n: i18n_key:icon_brain_circuit_name,
    label_i18n: i18n_key:icon_brain_circuit_label,
    keywords: ["brain-circuit", "mind", "intellect", "artificial intelligence", "ai", "deep learning", "machine learning", "computing"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 224. brain-cog
CREATE icon:brain_cog CONTENT {
  identity: {
    value: 'brain_cog',
    slug: 'brain-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_brain_cog_name,
    label_i18n: i18n_key:icon_brain_cog_label,
    keywords: ["brain-cog", "mind", "intellect", "artificial intelligence", "ai", "deep learning", "machine learning", "computing"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 225. brain
CREATE icon:brain CONTENT {
  identity: {
    value: 'brain',
    slug: 'brain'
  },
  presentation: {
    name_i18n: i18n_key:icon_brain_name,
    label_i18n: i18n_key:icon_brain_label,
    keywords: ["brain", "medical", "mind", "mental", "intellect", "cerebral", "consciousness", "genius", "artificial intelligence", "ai", "think", "thought", "insight", "intelligent", "smart"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 226. brick-wall-fire
CREATE icon:brick_wall_fire CONTENT {
  identity: {
    value: 'brick_wall_fire',
    slug: 'brick-wall-fire'
  },
  presentation: {
    name_i18n: i18n_key:icon_brick_wall_fire_name,
    label_i18n: i18n_key:icon_brick_wall_fire_label,
    keywords: ["brick-wall-fire", "firewall", "security", "bricks", "mortar", "cement", "materials", "construction", "builder", "labourer", "quantity surveyor", "blocks", "stone", "campfire", "camping", "wilderness", "outdoors", "lit", "warmth", "wood", "twigs", "sticks"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 227. brick-wall-shield
CREATE icon:brick_wall_shield CONTENT {
  identity: {
    value: 'brick_wall_shield',
    slug: 'brick-wall-shield'
  },
  presentation: {
    name_i18n: i18n_key:icon_brick_wall_shield_name,
    label_i18n: i18n_key:icon_brick_wall_shield_label,
    keywords: ["brick-wall-shield", "firewall", "security", "bricks", "mortar", "cement", "materials", "construction", "builder", "labourer", "quantity surveyor", "blocks", "stone", "cybersecurity", "secure", "safety", "protection", "guardian", "armored", "armoured", "defense", "defence", "defender", "block", "threat", "prevention", "antivirus", "vigilance", "vigilant", "detection", "scan", "find", "strength", "strong", "tough", "invincible", "invincibility", "invulnerable", "undamaged", "audit", "admin", "verification", "crest", "bravery", "knight", "foot soldier", "infantry", "trooper", "pawn", "battle", "war", "military", "army", "cadet", "scout"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 228. brick-wall
CREATE icon:brick_wall CONTENT {
  identity: {
    value: 'brick_wall',
    slug: 'brick-wall'
  },
  presentation: {
    name_i18n: i18n_key:icon_brick_wall_name,
    label_i18n: i18n_key:icon_brick_wall_label,
    keywords: ["brick-wall", "bricks", "mortar", "cement", "materials", "construction", "builder", "labourer", "quantity surveyor", "blocks", "stone"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 229. briefcase-business
CREATE icon:briefcase_business CONTENT {
  identity: {
    value: 'briefcase_business',
    slug: 'briefcase-business'
  },
  presentation: {
    name_i18n: i18n_key:icon_briefcase_business_name,
    label_i18n: i18n_key:icon_briefcase_business_label,
    keywords: ["briefcase-business", "work", "bag", "baggage", "folder", "portfolio"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 230. briefcase-conveyor-belt
CREATE icon:briefcase_conveyor_belt CONTENT {
  identity: {
    value: 'briefcase_conveyor_belt',
    slug: 'briefcase-conveyor-belt'
  },
  presentation: {
    name_i18n: i18n_key:icon_briefcase_conveyor_belt_name,
    label_i18n: i18n_key:icon_briefcase_conveyor_belt_label,
    keywords: ["briefcase-conveyor-belt", "baggage", "luggage", "travel", "suitcase", "conveyor", "carousel"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 231. briefcase-medical
CREATE icon:briefcase_medical CONTENT {
  identity: {
    value: 'briefcase_medical',
    slug: 'briefcase-medical'
  },
  presentation: {
    name_i18n: i18n_key:icon_briefcase_medical_name,
    label_i18n: i18n_key:icon_briefcase_medical_label,
    keywords: ["briefcase-medical", "doctor", "medicine", "first aid"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 232. briefcase
CREATE icon:briefcase CONTENT {
  identity: {
    value: 'briefcase',
    slug: 'briefcase'
  },
  presentation: {
    name_i18n: i18n_key:icon_briefcase_name,
    label_i18n: i18n_key:icon_briefcase_label,
    keywords: ["briefcase", "work", "bag", "baggage", "folder"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 233. bring-to-front
CREATE icon:bring_to_front CONTENT {
  identity: {
    value: 'bring_to_front',
    slug: 'bring-to-front'
  },
  presentation: {
    name_i18n: i18n_key:icon_bring_to_front_name,
    label_i18n: i18n_key:icon_bring_to_front_label,
    keywords: ["bring-to-front", "bring", "send", "move", "over", "forward", "front", "overlap", "layer", "order"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 234. brush-cleaning
CREATE icon:brush_cleaning CONTENT {
  identity: {
    value: 'brush_cleaning',
    slug: 'brush-cleaning'
  },
  presentation: {
    name_i18n: i18n_key:icon_brush_cleaning_name,
    label_i18n: i18n_key:icon_brush_cleaning_label,
    keywords: ["brush-cleaning", "cleaning", "utensil", "housekeeping", "tool", "sweeping", "scrubbing", "hygiene", "maintenance", "household", "cleaner", "chores", "equipment", "sanitation", "bristles", "handle", "home care", "sanitize", "purify", "wash", "disinfect", "sterilize", "scrub", "polish", "decontaminate", "wipe", "spotless", "remove", "empty", "erase", "purge", "eliminate"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 235. brush
CREATE icon:brush CONTENT {
  identity: {
    value: 'brush',
    slug: 'brush'
  },
  presentation: {
    name_i18n: i18n_key:icon_brush_name,
    label_i18n: i18n_key:icon_brush_label,
    keywords: ["brush", "clean", "sweep", "refactor", "remove", "draw", "paint", "color", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 236. bubbles
CREATE icon:bubbles CONTENT {
  identity: {
    value: 'bubbles',
    slug: 'bubbles'
  },
  presentation: {
    name_i18n: i18n_key:icon_bubbles_name,
    label_i18n: i18n_key:icon_bubbles_label,
    keywords: ["bubbles", "water", "cleaning", "soap", "bath", "hygiene", "freshness", "wash", "foam", "cleanliness", "shampoo", "purity", "splash", "lightness", "airy", "relaxation", "spa", "bubbly", "fluid", "floating", "drop"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 237. bug-off
CREATE icon:bug_off CONTENT {
  identity: {
    value: 'bug_off',
    slug: 'bug-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_bug_off_name,
    label_i18n: i18n_key:icon_bug_off_label,
    keywords: ["bug-off", "issue", "fixed", "resolved", "testing", "debug", "code", "insect", "kill", "exterminate", "pest control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 238. bug-play
CREATE icon:bug_play CONTENT {
  identity: {
    value: 'bug_play',
    slug: 'bug-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_bug_play_name,
    label_i18n: i18n_key:icon_bug_play_label,
    keywords: ["bug-play", "issue", "testing", "debug", "reproduce", "code", "insect"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 239. bug
CREATE icon:bug CONTENT {
  identity: {
    value: 'bug',
    slug: 'bug'
  },
  presentation: {
    name_i18n: i18n_key:icon_bug_name,
    label_i18n: i18n_key:icon_bug_label,
    keywords: ["bug", "issue", "error", "defect", "testing", "troubleshoot", "problem", "report", "debug", "code", "insect", "beetle"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 240. building-2
CREATE icon:building_2 CONTENT {
  identity: {
    value: 'building_2',
    slug: 'building-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_building_2_name,
    label_i18n: i18n_key:icon_building_2_label,
    keywords: ["building-2", "business", "company", "enterprise", "skyscraper", "organisation", "organization", "city"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 241. building
CREATE icon:building CONTENT {
  identity: {
    value: 'building',
    slug: 'building'
  },
  presentation: {
    name_i18n: i18n_key:icon_building_name,
    label_i18n: i18n_key:icon_building_label,
    keywords: ["building", "organisation", "organization"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 242. bus-front
CREATE icon:bus_front CONTENT {
  identity: {
    value: 'bus_front',
    slug: 'bus-front'
  },
  presentation: {
    name_i18n: i18n_key:icon_bus_front_name,
    label_i18n: i18n_key:icon_bus_front_label,
    keywords: ["bus-front", "coach", "vehicle", "trip", "road"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 243. bus
CREATE icon:bus CONTENT {
  identity: {
    value: 'bus',
    slug: 'bus'
  },
  presentation: {
    name_i18n: i18n_key:icon_bus_name,
    label_i18n: i18n_key:icon_bus_label,
    keywords: ["bus", "bus", "vehicle", "transport", "trip"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 244. cable-car
CREATE icon:cable_car CONTENT {
  identity: {
    value: 'cable_car',
    slug: 'cable-car'
  },
  presentation: {
    name_i18n: i18n_key:icon_cable_car_name,
    label_i18n: i18n_key:icon_cable_car_label,
    keywords: ["cable-car", "ski lift", "winter holiday", "alpine", "resort", "mountains"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 245. cable
CREATE icon:cable CONTENT {
  identity: {
    value: 'cable',
    slug: 'cable'
  },
  presentation: {
    name_i18n: i18n_key:icon_cable_name,
    label_i18n: i18n_key:icon_cable_label,
    keywords: ["cable", "cord", "wire", "connector", "connection", "link", "signal", "console", "computer", "equipment", "electricity", "energy", "electronics", "recharging", "charger", "power", "supply", "disconnected", "unplugged", "plugs", "interface", "input", "output", "audio video", "av", "rca", "scart", "tv", "television", "optical"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 246. cake-slice
CREATE icon:cake_slice CONTENT {
  identity: {
    value: 'cake_slice',
    slug: 'cake-slice'
  },
  presentation: {
    name_i18n: i18n_key:icon_cake_slice_name,
    label_i18n: i18n_key:icon_cake_slice_label,
    keywords: ["cake-slice", "birthday", "birthdate", "celebration", "party", "surprise", "gateaux", "dessert", "candles", "wish", "fondant", "icing sugar", "sweet", "baking"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 247. cake
CREATE icon:cake CONTENT {
  identity: {
    value: 'cake',
    slug: 'cake'
  },
  presentation: {
    name_i18n: i18n_key:icon_cake_name,
    label_i18n: i18n_key:icon_cake_label,
    keywords: ["cake", "birthday", "birthdate", "celebration", "party", "surprise", "gateaux", "dessert", "fondant", "icing sugar", "sweet", "baking"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 248. calculator
CREATE icon:calculator CONTENT {
  identity: {
    value: 'calculator',
    slug: 'calculator'
  },
  presentation: {
    name_i18n: i18n_key:icon_calculator_name,
    label_i18n: i18n_key:icon_calculator_label,
    keywords: ["calculator", "count", "calculating machine"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 249. calendar-1
CREATE icon:calendar_1 CONTENT {
  identity: {
    value: 'calendar_1',
    slug: 'calendar-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_1_name,
    label_i18n: i18n_key:icon_calendar_1_label,
    keywords: ["calendar-1", "date", "month", "year", "event", "single", "singular", "once", "1", "first"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 250. calendar-arrow-down
CREATE icon:calendar_arrow_down CONTENT {
  identity: {
    value: 'calendar_arrow_down',
    slug: 'calendar-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_arrow_down_name,
    label_i18n: i18n_key:icon_calendar_arrow_down_label,
    keywords: ["calendar-arrow-down", "date", "month", "year", "event", "sort", "order", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 251. calendar-arrow-up
CREATE icon:calendar_arrow_up CONTENT {
  identity: {
    value: 'calendar_arrow_up',
    slug: 'calendar-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_arrow_up_name,
    label_i18n: i18n_key:icon_calendar_arrow_up_label,
    keywords: ["calendar-arrow-up", "date", "month", "year", "event", "sort", "order", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 252. calendar-check-2
CREATE icon:calendar_check_2 CONTENT {
  identity: {
    value: 'calendar_check_2',
    slug: 'calendar-check-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_check_2_name,
    label_i18n: i18n_key:icon_calendar_check_2_label,
    keywords: ["calendar-check-2", "date", "day", "month", "year", "event", "confirm", "subscribe", "schedule", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 253. calendar-check
CREATE icon:calendar_check CONTENT {
  identity: {
    value: 'calendar_check',
    slug: 'calendar-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_check_name,
    label_i18n: i18n_key:icon_calendar_check_label,
    keywords: ["calendar-check", "date", "day", "month", "year", "event", "confirm", "subscribe", "schedule", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 254. calendar-clock
CREATE icon:calendar_clock CONTENT {
  identity: {
    value: 'calendar_clock',
    slug: 'calendar-clock'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_clock_name,
    label_i18n: i18n_key:icon_calendar_clock_label,
    keywords: ["calendar-clock", "date", "day", "month", "year", "event", "clock", "hour"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 255. calendar-cog
CREATE icon:calendar_cog CONTENT {
  identity: {
    value: 'calendar_cog',
    slug: 'calendar-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_cog_name,
    label_i18n: i18n_key:icon_calendar_cog_label,
    keywords: ["calendar-cog", "date", "day", "month", "year", "events", "settings", "gear", "cog"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 256. calendar-days
CREATE icon:calendar_days CONTENT {
  identity: {
    value: 'calendar_days',
    slug: 'calendar-days'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_days_name,
    label_i18n: i18n_key:icon_calendar_days_label,
    keywords: ["calendar-days", "date", "month", "year", "event"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 257. calendar-fold
CREATE icon:calendar_fold CONTENT {
  identity: {
    value: 'calendar_fold',
    slug: 'calendar-fold'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_fold_name,
    label_i18n: i18n_key:icon_calendar_fold_label,
    keywords: ["calendar-fold", "date", "month", "year", "event", "birthday", "birthdate", "ics"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 258. calendar-heart
CREATE icon:calendar_heart CONTENT {
  identity: {
    value: 'calendar_heart',
    slug: 'calendar-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_heart_name,
    label_i18n: i18n_key:icon_calendar_heart_label,
    keywords: ["calendar-heart", "date", "month", "year", "event", "heart", "favourite", "subscribe", "valentines day"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 259. calendar-minus-2
CREATE icon:calendar_minus_2 CONTENT {
  identity: {
    value: 'calendar_minus_2',
    slug: 'calendar-minus-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_minus_2_name,
    label_i18n: i18n_key:icon_calendar_minus_2_label,
    keywords: ["calendar-minus-2", "date", "day", "month", "year", "event", "delete", "remove"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 260. calendar-minus
CREATE icon:calendar_minus CONTENT {
  identity: {
    value: 'calendar_minus',
    slug: 'calendar-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_minus_name,
    label_i18n: i18n_key:icon_calendar_minus_label,
    keywords: ["calendar-minus", "date", "day", "month", "year", "event", "delete", "remove"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 261. calendar-off
CREATE icon:calendar_off CONTENT {
  identity: {
    value: 'calendar_off',
    slug: 'calendar-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_off_name,
    label_i18n: i18n_key:icon_calendar_off_label,
    keywords: ["calendar-off", "date", "day", "month", "year", "event", "delete", "remove"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 262. calendar-plus-2
CREATE icon:calendar_plus_2 CONTENT {
  identity: {
    value: 'calendar_plus_2',
    slug: 'calendar-plus-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_plus_2_name,
    label_i18n: i18n_key:icon_calendar_plus_2_label,
    keywords: ["calendar-plus-2", "date", "day", "month", "year", "event", "add", "subscribe", "create", "new"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 263. calendar-plus
CREATE icon:calendar_plus CONTENT {
  identity: {
    value: 'calendar_plus',
    slug: 'calendar-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_plus_name,
    label_i18n: i18n_key:icon_calendar_plus_label,
    keywords: ["calendar-plus", "date", "day", "month", "year", "event", "add", "subscribe", "create", "new"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 264. calendar-range
CREATE icon:calendar_range CONTENT {
  identity: {
    value: 'calendar_range',
    slug: 'calendar-range'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_range_name,
    label_i18n: i18n_key:icon_calendar_range_label,
    keywords: ["calendar-range", "date", "day", "month", "year", "event", "range", "period"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 265. calendar-search
CREATE icon:calendar_search CONTENT {
  identity: {
    value: 'calendar_search',
    slug: 'calendar-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_search_name,
    label_i18n: i18n_key:icon_calendar_search_label,
    keywords: ["calendar-search", "date", "day", "month", "year", "events", "search", "lens"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 266. calendar-sync
CREATE icon:calendar_sync CONTENT {
  identity: {
    value: 'calendar_sync',
    slug: 'calendar-sync'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_sync_name,
    label_i18n: i18n_key:icon_calendar_sync_label,
    keywords: ["calendar-sync", "repeat", "refresh", "reconnect", "transfer", "backup", "date", "month", "year", "event", "subscribe", "recurring", "schedule", "reminder", "automatic", "auto"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 267. calendar-x-2
CREATE icon:calendar_x_2 CONTENT {
  identity: {
    value: 'calendar_x_2',
    slug: 'calendar-x-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_x_2_name,
    label_i18n: i18n_key:icon_calendar_x_2_label,
    keywords: ["calendar-x-2", "date", "day", "month", "year", "event", "remove"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 268. calendar-x
CREATE icon:calendar_x CONTENT {
  identity: {
    value: 'calendar_x',
    slug: 'calendar-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_x_name,
    label_i18n: i18n_key:icon_calendar_x_label,
    keywords: ["calendar-x", "date", "day", "month", "year", "event", "remove", "busy"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 269. calendar
CREATE icon:calendar CONTENT {
  identity: {
    value: 'calendar',
    slug: 'calendar'
  },
  presentation: {
    name_i18n: i18n_key:icon_calendar_name,
    label_i18n: i18n_key:icon_calendar_label,
    keywords: ["calendar", "date", "month", "year", "event", "birthday", "birthdate"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 270. camera-off
CREATE icon:camera_off CONTENT {
  identity: {
    value: 'camera_off',
    slug: 'camera-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_camera_off_name,
    label_i18n: i18n_key:icon_camera_off_label,
    keywords: ["camera-off", "photo", "webcam", "video"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 271. camera
CREATE icon:camera CONTENT {
  identity: {
    value: 'camera',
    slug: 'camera'
  },
  presentation: {
    name_i18n: i18n_key:icon_camera_name,
    label_i18n: i18n_key:icon_camera_label,
    keywords: ["camera", "photography", "lens", "focus", "capture", "shot", "visual", "image", "device", "equipment", "photo", "webcam", "video"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 272. candy-cane
CREATE icon:candy_cane CONTENT {
  identity: {
    value: 'candy_cane',
    slug: 'candy-cane'
  },
  presentation: {
    name_i18n: i18n_key:icon_candy_cane_name,
    label_i18n: i18n_key:icon_candy_cane_label,
    keywords: ["candy-cane", "sugar", "food", "sweet", "christmas", "xmas"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 273. candy-off
CREATE icon:candy_off CONTENT {
  identity: {
    value: 'candy_off',
    slug: 'candy-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_candy_off_name,
    label_i18n: i18n_key:icon_candy_off_label,
    keywords: ["candy-off", "sugar free", "food", "sweet", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 274. candy
CREATE icon:candy CONTENT {
  identity: {
    value: 'candy',
    slug: 'candy'
  },
  presentation: {
    name_i18n: i18n_key:icon_candy_name,
    label_i18n: i18n_key:icon_candy_label,
    keywords: ["candy", "sugar", "food", "sweet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 275. cannabis
CREATE icon:cannabis CONTENT {
  identity: {
    value: 'cannabis',
    slug: 'cannabis'
  },
  presentation: {
    name_i18n: i18n_key:icon_cannabis_name,
    label_i18n: i18n_key:icon_cannabis_label,
    keywords: ["cannabis", "cannabis", "weed", "leaf"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 276. captions-off
CREATE icon:captions_off CONTENT {
  identity: {
    value: 'captions_off',
    slug: 'captions-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_captions_off_name,
    label_i18n: i18n_key:icon_captions_off_label,
    keywords: ["captions-off", "closed captions", "subtitles", "subhead", "transcription", "transcribe", "dialogue", "accessibility"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 277. captions
CREATE icon:captions CONTENT {
  identity: {
    value: 'captions',
    slug: 'captions'
  },
  presentation: {
    name_i18n: i18n_key:icon_captions_name,
    label_i18n: i18n_key:icon_captions_label,
    keywords: ["captions", "closed captions", "subtitles", "subhead", "transcription", "transcribe", "dialogue", "accessibility"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 278. car-front
CREATE icon:car_front CONTENT {
  identity: {
    value: 'car_front',
    slug: 'car-front'
  },
  presentation: {
    name_i18n: i18n_key:icon_car_front_name,
    label_i18n: i18n_key:icon_car_front_label,
    keywords: ["car-front", "vehicle", "drive", "trip", "journey"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 279. car-taxi-front
CREATE icon:car_taxi_front CONTENT {
  identity: {
    value: 'car_taxi_front',
    slug: 'car-taxi-front'
  },
  presentation: {
    name_i18n: i18n_key:icon_car_taxi_front_name,
    label_i18n: i18n_key:icon_car_taxi_front_label,
    keywords: ["car-taxi-front", "cab", "vehicle", "drive", "trip", "journey"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 280. car
CREATE icon:car CONTENT {
  identity: {
    value: 'car',
    slug: 'car'
  },
  presentation: {
    name_i18n: i18n_key:icon_car_name,
    label_i18n: i18n_key:icon_car_label,
    keywords: ["car", "vehicle", "drive", "trip", "journey"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 281. caravan
CREATE icon:caravan CONTENT {
  identity: {
    value: 'caravan',
    slug: 'caravan'
  },
  presentation: {
    name_i18n: i18n_key:icon_caravan_name,
    label_i18n: i18n_key:icon_caravan_label,
    keywords: ["caravan", "trailer", "tow", "camping", "campsite", "mobile home", "holiday", "nomadic", "wilderness", "outdoors"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 282. card-sim
CREATE icon:card_sim CONTENT {
  identity: {
    value: 'card_sim',
    slug: 'card-sim'
  },
  presentation: {
    name_i18n: i18n_key:icon_card_sim_name,
    label_i18n: i18n_key:icon_card_sim_label,
    keywords: ["card-sim", "cellphone", "smartphone", "mobile", "network", "cellular", "service", "provider", "signal", "coverage", "disk", "data", "format", "storage", "flash", "digital", "contacts", "phone book", "contractual", "circuit board", "chip"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 283. carrot
CREATE icon:carrot CONTENT {
  identity: {
    value: 'carrot',
    slug: 'carrot'
  },
  presentation: {
    name_i18n: i18n_key:icon_carrot_name,
    label_i18n: i18n_key:icon_carrot_label,
    keywords: ["carrot", "vegetable", "food", "eat"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 284. case-lower
CREATE icon:case_lower CONTENT {
  identity: {
    value: 'case_lower',
    slug: 'case-lower'
  },
  presentation: {
    name_i18n: i18n_key:icon_case_lower_name,
    label_i18n: i18n_key:icon_case_lower_label,
    keywords: ["case-lower", "text", "letters", "characters", "font", "typography"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 285. case-sensitive
CREATE icon:case_sensitive CONTENT {
  identity: {
    value: 'case_sensitive',
    slug: 'case-sensitive'
  },
  presentation: {
    name_i18n: i18n_key:icon_case_sensitive_name,
    label_i18n: i18n_key:icon_case_sensitive_label,
    keywords: ["case-sensitive", "text", "letters", "characters", "font", "typography"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 286. case-upper
CREATE icon:case_upper CONTENT {
  identity: {
    value: 'case_upper',
    slug: 'case-upper'
  },
  presentation: {
    name_i18n: i18n_key:icon_case_upper_name,
    label_i18n: i18n_key:icon_case_upper_label,
    keywords: ["case-upper", "text", "letters", "characters", "font", "typography"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 287. cassette-tape
CREATE icon:cassette_tape CONTENT {
  identity: {
    value: 'cassette_tape',
    slug: 'cassette-tape'
  },
  presentation: {
    name_i18n: i18n_key:icon_cassette_tape_name,
    label_i18n: i18n_key:icon_cassette_tape_label,
    keywords: ["cassette-tape", "audio", "music", "recording", "play"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 288. cast
CREATE icon:cast CONTENT {
  identity: {
    value: 'cast',
    slug: 'cast'
  },
  presentation: {
    name_i18n: i18n_key:icon_cast_name,
    label_i18n: i18n_key:icon_cast_label,
    keywords: ["cast", "chromecast", "airplay", "screen"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 289. castle
CREATE icon:castle CONTENT {
  identity: {
    value: 'castle',
    slug: 'castle'
  },
  presentation: {
    name_i18n: i18n_key:icon_castle_name,
    label_i18n: i18n_key:icon_castle_label,
    keywords: ["castle", "fortress", "stronghold", "palace", "chateau", "building"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 290. cat
CREATE icon:cat CONTENT {
  identity: {
    value: 'cat',
    slug: 'cat'
  },
  presentation: {
    name_i18n: i18n_key:icon_cat_name,
    label_i18n: i18n_key:icon_cat_label,
    keywords: ["cat", "animal", "pet", "kitten", "feline"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 291. cctv
CREATE icon:cctv CONTENT {
  identity: {
    value: 'cctv',
    slug: 'cctv'
  },
  presentation: {
    name_i18n: i18n_key:icon_cctv_name,
    label_i18n: i18n_key:icon_cctv_label,
    keywords: ["cctv", "camera", "surveillance", "recording", "film", "videotape", "crime", "watching"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 292. chart-area
CREATE icon:chart_area CONTENT {
  identity: {
    value: 'chart_area',
    slug: 'chart-area'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_area_name,
    label_i18n: i18n_key:icon_chart_area_label,
    keywords: ["chart-area", "statistics", "analytics", "diagram", "graph", "area"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 293. chart-bar-big
CREATE icon:chart_bar_big CONTENT {
  identity: {
    value: 'chart_bar_big',
    slug: 'chart-bar-big'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_bar_big_name,
    label_i18n: i18n_key:icon_chart_bar_big_label,
    keywords: ["chart-bar-big", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 294. chart-bar-decreasing
CREATE icon:chart_bar_decreasing CONTENT {
  identity: {
    value: 'chart_bar_decreasing',
    slug: 'chart-bar-decreasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_bar_decreasing_name,
    label_i18n: i18n_key:icon_chart_bar_decreasing_label,
    keywords: ["chart-bar-decreasing", "statistics", "analytics", "diagram", "graph", "trending down"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 295. chart-bar-increasing
CREATE icon:chart_bar_increasing CONTENT {
  identity: {
    value: 'chart_bar_increasing',
    slug: 'chart-bar-increasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_bar_increasing_name,
    label_i18n: i18n_key:icon_chart_bar_increasing_label,
    keywords: ["chart-bar-increasing", "statistics", "analytics", "diagram", "graph", "trending up"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 296. chart-bar-stacked
CREATE icon:chart_bar_stacked CONTENT {
  identity: {
    value: 'chart_bar_stacked',
    slug: 'chart-bar-stacked'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_bar_stacked_name,
    label_i18n: i18n_key:icon_chart_bar_stacked_label,
    keywords: ["chart-bar-stacked", "statistics", "analytics", "diagram", "graph", "multivariate", "categorical", "comparison"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 297. chart-bar
CREATE icon:chart_bar CONTENT {
  identity: {
    value: 'chart_bar',
    slug: 'chart-bar'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_bar_name,
    label_i18n: i18n_key:icon_chart_bar_label,
    keywords: ["chart-bar", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 298. chart-candlestick
CREATE icon:chart_candlestick CONTENT {
  identity: {
    value: 'chart_candlestick',
    slug: 'chart-candlestick'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_candlestick_name,
    label_i18n: i18n_key:icon_chart_candlestick_label,
    keywords: ["chart-candlestick", "trading", "trader", "financial", "markets", "portfolio", "assets", "prices", "value", "valuation", "commodities", "currencies", "currency", "stocks", "exchange", "hedge fund", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 299. chart-column-big
CREATE icon:chart_column_big CONTENT {
  identity: {
    value: 'chart_column_big',
    slug: 'chart-column-big'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_column_big_name,
    label_i18n: i18n_key:icon_chart_column_big_label,
    keywords: ["chart-column-big", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 300. chart-column-decreasing
CREATE icon:chart_column_decreasing CONTENT {
  identity: {
    value: 'chart_column_decreasing',
    slug: 'chart-column-decreasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_column_decreasing_name,
    label_i18n: i18n_key:icon_chart_column_decreasing_label,
    keywords: ["chart-column-decreasing", "statistics", "analytics", "diagram", "graph", "trending down"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 301. chart-column-increasing
CREATE icon:chart_column_increasing CONTENT {
  identity: {
    value: 'chart_column_increasing',
    slug: 'chart-column-increasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_column_increasing_name,
    label_i18n: i18n_key:icon_chart_column_increasing_label,
    keywords: ["chart-column-increasing", "statistics", "analytics", "diagram", "graph", "trending up"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 302. chart-column-stacked
CREATE icon:chart_column_stacked CONTENT {
  identity: {
    value: 'chart_column_stacked',
    slug: 'chart-column-stacked'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_column_stacked_name,
    label_i18n: i18n_key:icon_chart_column_stacked_label,
    keywords: ["chart-column-stacked", "statistics", "analytics", "diagram", "graph", "multivariate", "categorical", "comparison"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 303. chart-column
CREATE icon:chart_column CONTENT {
  identity: {
    value: 'chart_column',
    slug: 'chart-column'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_column_name,
    label_i18n: i18n_key:icon_chart_column_label,
    keywords: ["chart-column", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 304. chart-gantt
CREATE icon:chart_gantt CONTENT {
  identity: {
    value: 'chart_gantt',
    slug: 'chart-gantt'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_gantt_name,
    label_i18n: i18n_key:icon_chart_gantt_label,
    keywords: ["chart-gantt", "diagram", "graph", "timeline", "planning"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 305. chart-line
CREATE icon:chart_line CONTENT {
  identity: {
    value: 'chart_line',
    slug: 'chart-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_line_name,
    label_i18n: i18n_key:icon_chart_line_label,
    keywords: ["chart-line", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 306. chart-network
CREATE icon:chart_network CONTENT {
  identity: {
    value: 'chart_network',
    slug: 'chart-network'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_network_name,
    label_i18n: i18n_key:icon_chart_network_label,
    keywords: ["chart-network", "statistics", "analytics", "diagram", "graph", "topology", "cluster", "web", "nodes", "connections", "edges"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 307. chart-no-axes-column-decreasing
CREATE icon:chart_no_axes_column_decreasing CONTENT {
  identity: {
    value: 'chart_no_axes_column_decreasing',
    slug: 'chart-no-axes-column-decreasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_no_axes_column_decreasing_name,
    label_i18n: i18n_key:icon_chart_no_axes_column_decreasing_label,
    keywords: ["chart-no-axes-column-decreasing", "statistics", "analytics", "diagram", "graph", "trending down"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 308. chart-no-axes-column-increasing
CREATE icon:chart_no_axes_column_increasing CONTENT {
  identity: {
    value: 'chart_no_axes_column_increasing',
    slug: 'chart-no-axes-column-increasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_no_axes_column_increasing_name,
    label_i18n: i18n_key:icon_chart_no_axes_column_increasing_label,
    keywords: ["chart-no-axes-column-increasing", "statistics", "analytics", "diagram", "graph", "trending up"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 309. chart-no-axes-column
CREATE icon:chart_no_axes_column CONTENT {
  identity: {
    value: 'chart_no_axes_column',
    slug: 'chart-no-axes-column'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_no_axes_column_name,
    label_i18n: i18n_key:icon_chart_no_axes_column_label,
    keywords: ["chart-no-axes-column", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 310. chart-no-axes-combined
CREATE icon:chart_no_axes_combined CONTENT {
  identity: {
    value: 'chart_no_axes_combined',
    slug: 'chart-no-axes-combined'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_no_axes_combined_name,
    label_i18n: i18n_key:icon_chart_no_axes_combined_label,
    keywords: ["chart-no-axes-combined", "statistics", "analytics", "diagram", "graph", "trending up"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 311. chart-no-axes-gantt
CREATE icon:chart_no_axes_gantt CONTENT {
  identity: {
    value: 'chart_no_axes_gantt',
    slug: 'chart-no-axes-gantt'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_no_axes_gantt_name,
    label_i18n: i18n_key:icon_chart_no_axes_gantt_label,
    keywords: ["chart-no-axes-gantt", "projects", "manage", "overview", "roadmap", "plan", "intentions", "timeline", "deadline", "date", "event", "range", "period", "productivity", "work", "agile", "code", "coding"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 312. chart-pie
CREATE icon:chart_pie CONTENT {
  identity: {
    value: 'chart_pie',
    slug: 'chart-pie'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_pie_name,
    label_i18n: i18n_key:icon_chart_pie_label,
    keywords: ["chart-pie", "statistics", "analytics", "diagram", "presentation"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 313. chart-scatter
CREATE icon:chart_scatter CONTENT {
  identity: {
    value: 'chart_scatter',
    slug: 'chart-scatter'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_scatter_name,
    label_i18n: i18n_key:icon_chart_scatter_label,
    keywords: ["chart-scatter", "statistics", "analytics", "diagram", "graph"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 314. chart-spline
CREATE icon:chart_spline CONTENT {
  identity: {
    value: 'chart_spline',
    slug: 'chart-spline'
  },
  presentation: {
    name_i18n: i18n_key:icon_chart_spline_name,
    label_i18n: i18n_key:icon_chart_spline_label,
    keywords: ["chart-spline", "statistics", "analytics", "diagram", "graph", "curve", "continuous", "smooth", "polynomial", "quadratic", "function", "interpolation"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 315. check-check
CREATE icon:check_check CONTENT {
  identity: {
    value: 'check_check',
    slug: 'check-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_check_check_name,
    label_i18n: i18n_key:icon_check_check_label,
    keywords: ["check-check", "done", "received", "double", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 316. check-line
CREATE icon:check_line CONTENT {
  identity: {
    value: 'check_line',
    slug: 'check-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_check_line_name,
    label_i18n: i18n_key:icon_check_line_label,
    keywords: ["check-line", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 317. check
CREATE icon:check CONTENT {
  identity: {
    value: 'check',
    slug: 'check'
  },
  presentation: {
    name_i18n: i18n_key:icon_check_name,
    label_i18n: i18n_key:icon_check_label,
    keywords: ["check", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 318. chef-hat
CREATE icon:chef_hat CONTENT {
  identity: {
    value: 'chef_hat',
    slug: 'chef-hat'
  },
  presentation: {
    name_i18n: i18n_key:icon_chef_hat_name,
    label_i18n: i18n_key:icon_chef_hat_label,
    keywords: ["chef-hat", "cooking", "food", "kitchen", "restaurant"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 319. cherry
CREATE icon:cherry CONTENT {
  identity: {
    value: 'cherry',
    slug: 'cherry'
  },
  presentation: {
    name_i18n: i18n_key:icon_cherry_name,
    label_i18n: i18n_key:icon_cherry_label,
    keywords: ["cherry", "fruit", "food"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 320. chevron-down
CREATE icon:chevron_down CONTENT {
  identity: {
    value: 'chevron_down',
    slug: 'chevron-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevron_down_name,
    label_i18n: i18n_key:icon_chevron_down_label,
    keywords: ["chevron-down", "backwards", "reverse", "slow", "dropdown"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 321. chevron-first
CREATE icon:chevron_first CONTENT {
  identity: {
    value: 'chevron_first',
    slug: 'chevron-first'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevron_first_name,
    label_i18n: i18n_key:icon_chevron_first_label,
    keywords: ["chevron-first", "previous", "music"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 322. chevron-last
CREATE icon:chevron_last CONTENT {
  identity: {
    value: 'chevron_last',
    slug: 'chevron-last'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevron_last_name,
    label_i18n: i18n_key:icon_chevron_last_label,
    keywords: ["chevron-last", "skip", "next", "music"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 323. chevron-left
CREATE icon:chevron_left CONTENT {
  identity: {
    value: 'chevron_left',
    slug: 'chevron-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevron_left_name,
    label_i18n: i18n_key:icon_chevron_left_label,
    keywords: ["chevron-left", "back", "previous", "less than", "fewer", "menu", "<"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 324. chevron-right
CREATE icon:chevron_right CONTENT {
  identity: {
    value: 'chevron_right',
    slug: 'chevron-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevron_right_name,
    label_i18n: i18n_key:icon_chevron_right_label,
    keywords: ["chevron-right", "forward", "next", "more than", "greater", "menu", "code", "coding", "command line", "terminal", "prompt", "shell", ">"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 325. chevron-up
CREATE icon:chevron_up CONTENT {
  identity: {
    value: 'chevron_up',
    slug: 'chevron-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevron_up_name,
    label_i18n: i18n_key:icon_chevron_up_label,
    keywords: ["chevron-up", "caret", "keyboard", "mac", "control", "ctrl", "superscript", "exponential", "power", "ahead", "fast", "^", "dropdown"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 326. chevrons-down-up
CREATE icon:chevrons_down_up CONTENT {
  identity: {
    value: 'chevrons_down_up',
    slug: 'chevrons-down-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_down_up_name,
    label_i18n: i18n_key:icon_chevrons_down_up_label,
    keywords: ["chevrons-down-up", "collapse", "fold", "vertical"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 327. chevrons-down
CREATE icon:chevrons_down CONTENT {
  identity: {
    value: 'chevrons_down',
    slug: 'chevrons-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_down_name,
    label_i18n: i18n_key:icon_chevrons_down_label,
    keywords: ["chevrons-down", "backwards", "reverse", "slower"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 328. chevrons-left-right-ellipsis
CREATE icon:chevrons_left_right_ellipsis CONTENT {
  identity: {
    value: 'chevrons_left_right_ellipsis',
    slug: 'chevrons-left-right-ellipsis'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_left_right_ellipsis_name,
    label_i18n: i18n_key:icon_chevrons_left_right_ellipsis_label,
    keywords: ["chevrons-left-right-ellipsis", "internet", "network", "connection", "cable", "lan", "port", "router", "switch", "hub", "modem", "web", "online", "networking", "communication", "socket", "plug", "slot", "controller", "connector", "interface", "console", "signal", "data", "input", "output"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 329. chevrons-left-right
CREATE icon:chevrons_left_right CONTENT {
  identity: {
    value: 'chevrons_left_right',
    slug: 'chevrons-left-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_left_right_name,
    label_i18n: i18n_key:icon_chevrons_left_right_label,
    keywords: ["chevrons-left-right", "expand", "horizontal", "unfold"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 330. chevrons-left
CREATE icon:chevrons_left CONTENT {
  identity: {
    value: 'chevrons_left',
    slug: 'chevrons-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_left_name,
    label_i18n: i18n_key:icon_chevrons_left_label,
    keywords: ["chevrons-left", "turn", "corner"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 331. chevrons-right-left
CREATE icon:chevrons_right_left CONTENT {
  identity: {
    value: 'chevrons_right_left',
    slug: 'chevrons-right-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_right_left_name,
    label_i18n: i18n_key:icon_chevrons_right_left_label,
    keywords: ["chevrons-right-left", "collapse", "fold", "horizontal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 332. chevrons-right
CREATE icon:chevrons_right CONTENT {
  identity: {
    value: 'chevrons_right',
    slug: 'chevrons-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_right_name,
    label_i18n: i18n_key:icon_chevrons_right_label,
    keywords: ["chevrons-right", "turn", "corner"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 333. chevrons-up-down
CREATE icon:chevrons_up_down CONTENT {
  identity: {
    value: 'chevrons_up_down',
    slug: 'chevrons-up-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_up_down_name,
    label_i18n: i18n_key:icon_chevrons_up_down_label,
    keywords: ["chevrons-up-down", "expand", "unfold", "vertical"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 334. chevrons-up
CREATE icon:chevrons_up CONTENT {
  identity: {
    value: 'chevrons_up',
    slug: 'chevrons-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_chevrons_up_name,
    label_i18n: i18n_key:icon_chevrons_up_label,
    keywords: ["chevrons-up", "forward", "ahead", "faster", "speed", "boost"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 335. chromium
CREATE icon:chromium CONTENT {
  identity: {
    value: 'chromium',
    slug: 'chromium'
  },
  presentation: {
    name_i18n: i18n_key:icon_chromium_name,
    label_i18n: i18n_key:icon_chromium_label,
    keywords: ["chromium", "browser", "logo"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 336. church
CREATE icon:church CONTENT {
  identity: {
    value: 'church',
    slug: 'church'
  },
  presentation: {
    name_i18n: i18n_key:icon_church_name,
    label_i18n: i18n_key:icon_church_label,
    keywords: ["church", "temple", "building"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 337. cigarette-off
CREATE icon:cigarette_off CONTENT {
  identity: {
    value: 'cigarette_off',
    slug: 'cigarette-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_cigarette_off_name,
    label_i18n: i18n_key:icon_cigarette_off_label,
    keywords: ["cigarette-off", "smoking", "no-smoking"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 338. cigarette
CREATE icon:cigarette CONTENT {
  identity: {
    value: 'cigarette',
    slug: 'cigarette'
  },
  presentation: {
    name_i18n: i18n_key:icon_cigarette_name,
    label_i18n: i18n_key:icon_cigarette_label,
    keywords: ["cigarette", "smoking"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 339. circle-alert
CREATE icon:circle_alert CONTENT {
  identity: {
    value: 'circle_alert',
    slug: 'circle-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_alert_name,
    label_i18n: i18n_key:icon_circle_alert_label,
    keywords: ["circle-alert", "warning", "alert", "danger", "exclamation mark"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 340. circle-arrow-down
CREATE icon:circle_arrow_down CONTENT {
  identity: {
    value: 'circle_arrow_down',
    slug: 'circle-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_down_name,
    label_i18n: i18n_key:icon_circle_arrow_down_label,
    keywords: ["circle-arrow-down", "backwards", "reverse", "direction", "south", "sign", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 341. circle-arrow-left
CREATE icon:circle_arrow_left CONTENT {
  identity: {
    value: 'circle_arrow_left',
    slug: 'circle-arrow-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_left_name,
    label_i18n: i18n_key:icon_circle_arrow_left_label,
    keywords: ["circle-arrow-left", "previous", "back", "direction", "west", "sign", "turn", "button", "<-"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 342. circle-arrow-out-down-left
CREATE icon:circle_arrow_out_down_left CONTENT {
  identity: {
    value: 'circle_arrow_out_down_left',
    slug: 'circle-arrow-out-down-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_out_down_left_name,
    label_i18n: i18n_key:icon_circle_arrow_out_down_left_label,
    keywords: ["circle-arrow-out-down-left", "outwards", "direction", "south-west", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 343. circle-arrow-out-down-right
CREATE icon:circle_arrow_out_down_right CONTENT {
  identity: {
    value: 'circle_arrow_out_down_right',
    slug: 'circle-arrow-out-down-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_out_down_right_name,
    label_i18n: i18n_key:icon_circle_arrow_out_down_right_label,
    keywords: ["circle-arrow-out-down-right", "outwards", "direction", "south-east", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 344. circle-arrow-out-up-left
CREATE icon:circle_arrow_out_up_left CONTENT {
  identity: {
    value: 'circle_arrow_out_up_left',
    slug: 'circle-arrow-out-up-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_out_up_left_name,
    label_i18n: i18n_key:icon_circle_arrow_out_up_left_label,
    keywords: ["circle-arrow-out-up-left", "outwards", "direction", "north-west", "diagonal", "keyboard", "button", "escape"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 345. circle-arrow-out-up-right
CREATE icon:circle_arrow_out_up_right CONTENT {
  identity: {
    value: 'circle_arrow_out_up_right',
    slug: 'circle-arrow-out-up-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_out_up_right_name,
    label_i18n: i18n_key:icon_circle_arrow_out_up_right_label,
    keywords: ["circle-arrow-out-up-right", "outwards", "direction", "north-east", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 346. circle-arrow-right
CREATE icon:circle_arrow_right CONTENT {
  identity: {
    value: 'circle_arrow_right',
    slug: 'circle-arrow-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_right_name,
    label_i18n: i18n_key:icon_circle_arrow_right_label,
    keywords: ["circle-arrow-right", "next", "forward", "direction", "east", "sign", "turn", "button", "->"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 347. circle-arrow-up
CREATE icon:circle_arrow_up CONTENT {
  identity: {
    value: 'circle_arrow_up',
    slug: 'circle-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_arrow_up_name,
    label_i18n: i18n_key:icon_circle_arrow_up_label,
    keywords: ["circle-arrow-up", "forward", "direction", "north", "sign", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 348. circle-check-big
CREATE icon:circle_check_big CONTENT {
  identity: {
    value: 'circle_check_big',
    slug: 'circle-check-big'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_check_big_name,
    label_i18n: i18n_key:icon_circle_check_big_label,
    keywords: ["circle-check-big", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 349. circle-check
CREATE icon:circle_check CONTENT {
  identity: {
    value: 'circle_check',
    slug: 'circle-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_check_name,
    label_i18n: i18n_key:icon_circle_check_label,
    keywords: ["circle-check", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 350. circle-chevron-down
CREATE icon:circle_chevron_down CONTENT {
  identity: {
    value: 'circle_chevron_down',
    slug: 'circle-chevron-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_chevron_down_name,
    label_i18n: i18n_key:icon_circle_chevron_down_label,
    keywords: ["circle-chevron-down", "back", "menu"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 351. circle-chevron-left
CREATE icon:circle_chevron_left CONTENT {
  identity: {
    value: 'circle_chevron_left',
    slug: 'circle-chevron-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_chevron_left_name,
    label_i18n: i18n_key:icon_circle_chevron_left_label,
    keywords: ["circle-chevron-left", "back", "previous", "less than", "fewer", "menu", "<"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 352. circle-chevron-right
CREATE icon:circle_chevron_right CONTENT {
  identity: {
    value: 'circle_chevron_right',
    slug: 'circle-chevron-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_chevron_right_name,
    label_i18n: i18n_key:icon_circle_chevron_right_label,
    keywords: ["circle-chevron-right", "back", "more than", "greater", "menu", ">"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 353. circle-chevron-up
CREATE icon:circle_chevron_up CONTENT {
  identity: {
    value: 'circle_chevron_up',
    slug: 'circle-chevron-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_chevron_up_name,
    label_i18n: i18n_key:icon_circle_chevron_up_label,
    keywords: ["circle-chevron-up", "caret", "ahead", "menu", "^"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 354. circle-dashed
CREATE icon:circle_dashed CONTENT {
  identity: {
    value: 'circle_dashed',
    slug: 'circle-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_dashed_name,
    label_i18n: i18n_key:icon_circle_dashed_label,
    keywords: ["circle-dashed", "pending", "dot", "progress", "issue", "draft", "code", "coding", "version control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 355. circle-divide
CREATE icon:circle_divide CONTENT {
  identity: {
    value: 'circle_divide',
    slug: 'circle-divide'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_divide_name,
    label_i18n: i18n_key:icon_circle_divide_label,
    keywords: ["circle-divide", "calculate", "math", "\u00f7", "/"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 356. circle-dollar-sign
CREATE icon:circle_dollar_sign CONTENT {
  identity: {
    value: 'circle_dollar_sign',
    slug: 'circle-dollar-sign'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_dollar_sign_name,
    label_i18n: i18n_key:icon_circle_dollar_sign_label,
    keywords: ["circle-dollar-sign", "monetization", "marketing", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 357. circle-dot-dashed
CREATE icon:circle_dot_dashed CONTENT {
  identity: {
    value: 'circle_dot_dashed',
    slug: 'circle-dot-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_dot_dashed_name,
    label_i18n: i18n_key:icon_circle_dot_dashed_label,
    keywords: ["circle-dot-dashed", "pending", "dot", "progress", "issue", "draft", "code", "coding", "version control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 358. circle-dot
CREATE icon:circle_dot CONTENT {
  identity: {
    value: 'circle_dot',
    slug: 'circle-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_dot_name,
    label_i18n: i18n_key:icon_circle_dot_label,
    keywords: ["circle-dot", "pending", "dot", "progress", "issue", "code", "coding", "version control", "choices", "multiple choice", "choose"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 359. circle-ellipsis
CREATE icon:circle_ellipsis CONTENT {
  identity: {
    value: 'circle_ellipsis',
    slug: 'circle-ellipsis'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_ellipsis_name,
    label_i18n: i18n_key:icon_circle_ellipsis_label,
    keywords: ["circle-ellipsis", "ellipsis", "et cetera", "etc", "loader", "loading", "progress", "pending", "throbber", "menu", "options", "operator", "code", "spread", "rest", "more", "further", "extra", "overflow", "dots", "\u2026", "..."]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 360. circle-equal
CREATE icon:circle_equal CONTENT {
  identity: {
    value: 'circle_equal',
    slug: 'circle-equal'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_equal_name,
    label_i18n: i18n_key:icon_circle_equal_label,
    keywords: ["circle-equal", "calculate", "shape", "="]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 361. circle-fading-arrow-up
CREATE icon:circle_fading_arrow_up CONTENT {
  identity: {
    value: 'circle_fading_arrow_up',
    slug: 'circle-fading-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_fading_arrow_up_name,
    label_i18n: i18n_key:icon_circle_fading_arrow_up_label,
    keywords: ["circle-fading-arrow-up", "north", "up", "upgrade", "improve", "circle", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 362. circle-fading-plus
CREATE icon:circle_fading_plus CONTENT {
  identity: {
    value: 'circle_fading_plus',
    slug: 'circle-fading-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_fading_plus_name,
    label_i18n: i18n_key:icon_circle_fading_plus_label,
    keywords: ["circle-fading-plus", "stories", "social media", "instagram", "facebook", "meta", "snapchat", "sharing", "content"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 363. circle-gauge
CREATE icon:circle_gauge CONTENT {
  identity: {
    value: 'circle_gauge',
    slug: 'circle-gauge'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_gauge_name,
    label_i18n: i18n_key:icon_circle_gauge_label,
    keywords: ["circle-gauge", "dashboard", "dial", "meter", "speed", "pressure", "measure", "level"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 364. circle-minus
CREATE icon:circle_minus CONTENT {
  identity: {
    value: 'circle_minus',
    slug: 'circle-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_minus_name,
    label_i18n: i18n_key:icon_circle_minus_label,
    keywords: ["circle-minus", "subtract", "remove", "decrease", "reduce", "calculate", "line", "operator", "code", "coding", "minimum", "downgrade", "-"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 365. circle-off
CREATE icon:circle_off CONTENT {
  identity: {
    value: 'circle_off',
    slug: 'circle-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_off_name,
    label_i18n: i18n_key:icon_circle_off_label,
    keywords: ["circle-off", "diameter", "zero", "\u00d8", "nothing", "null", "void", "cancel", "ban", "no", "stop", "forbidden", "prohibited", "error", "incorrect", "mistake", "wrong", "failure"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 366. circle-parking-off
CREATE icon:circle_parking_off CONTENT {
  identity: {
    value: 'circle_parking_off',
    slug: 'circle-parking-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_parking_off_name,
    label_i18n: i18n_key:icon_circle_parking_off_label,
    keywords: ["circle-parking-off", "parking lot", "car park", "no parking"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 367. circle-parking
CREATE icon:circle_parking CONTENT {
  identity: {
    value: 'circle_parking',
    slug: 'circle-parking'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_parking_name,
    label_i18n: i18n_key:icon_circle_parking_label,
    keywords: ["circle-parking", "parking lot", "car park"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 368. circle-pause
CREATE icon:circle_pause CONTENT {
  identity: {
    value: 'circle_pause',
    slug: 'circle-pause'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_pause_name,
    label_i18n: i18n_key:icon_circle_pause_label,
    keywords: ["circle-pause", "music", "audio", "stop"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 369. circle-percent
CREATE icon:circle_percent CONTENT {
  identity: {
    value: 'circle_percent',
    slug: 'circle-percent'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_percent_name,
    label_i18n: i18n_key:icon_circle_percent_label,
    keywords: ["circle-percent", "verified", "unverified", "sale", "discount", "offer", "marketing", "sticker", "price tag"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 370. circle-play
CREATE icon:circle_play CONTENT {
  identity: {
    value: 'circle_play',
    slug: 'circle-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_play_name,
    label_i18n: i18n_key:icon_circle_play_label,
    keywords: ["circle-play", "music", "start", "run"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 371. circle-plus
CREATE icon:circle_plus CONTENT {
  identity: {
    value: 'circle_plus',
    slug: 'circle-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_plus_name,
    label_i18n: i18n_key:icon_circle_plus_label,
    keywords: ["circle-plus", "add", "new", "increase", "increment", "positive", "calculate", "crosshair", "aim", "target", "scope", "sight", "reticule", "maximum", "upgrade", "extra", "operator", "join", "concatenate", "code", "coding", "+"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 372. circle-pound-sterling
CREATE icon:circle_pound_sterling CONTENT {
  identity: {
    value: 'circle_pound_sterling',
    slug: 'circle-pound-sterling'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_pound_sterling_name,
    label_i18n: i18n_key:icon_circle_pound_sterling_label,
    keywords: ["circle-pound-sterling", "monetization", "coin", "penny", "marketing", "currency", "money", "payment", "british", "gbp", "\u00a3"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 373. circle-power
CREATE icon:circle_power CONTENT {
  identity: {
    value: 'circle_power',
    slug: 'circle-power'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_power_name,
    label_i18n: i18n_key:icon_circle_power_label,
    keywords: ["circle-power", "on", "off", "device", "switch", "toggle", "binary", "boolean", "reboot", "restart", "button", "keyboard", "troubleshoot"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 374. circle-question-mark
CREATE icon:circle_question_mark CONTENT {
  identity: {
    value: 'circle_question_mark',
    slug: 'circle-question-mark'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_question_mark_name,
    label_i18n: i18n_key:icon_circle_question_mark_label,
    keywords: ["circle-question-mark", "question mark"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 375. circle-slash-2
CREATE icon:circle_slash_2 CONTENT {
  identity: {
    value: 'circle_slash_2',
    slug: 'circle-slash-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_slash_2_name,
    label_i18n: i18n_key:icon_circle_slash_2_label,
    keywords: ["circle-slash-2", "diameter", "zero", "\u00f8", "nothing", "null", "void", "ban", "math", "divide", "division", "half", "split", "/", "average", "avg", "mean", "median", "normal"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 376. circle-slash
CREATE icon:circle_slash CONTENT {
  identity: {
    value: 'circle_slash',
    slug: 'circle-slash'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_slash_name,
    label_i18n: i18n_key:icon_circle_slash_label,
    keywords: ["circle-slash", "diameter", "zero", "\u00d8", "nothing", "null", "void", "cancel", "ban", "no", "stop", "forbidden", "prohibited", "error", "incorrect", "mistake", "wrong", "failure", "divide", "division", "or", "/"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 377. circle-small
CREATE icon:circle_small CONTENT {
  identity: {
    value: 'circle_small',
    slug: 'circle-small'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_small_name,
    label_i18n: i18n_key:icon_circle_small_label,
    keywords: ["circle-small", "shape", "bullet", "gender", "genderless"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 378. circle-star
CREATE icon:circle_star CONTENT {
  identity: {
    value: 'circle_star',
    slug: 'circle-star'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_star_name,
    label_i18n: i18n_key:icon_circle_star_label,
    keywords: ["circle-star", "badge", "medal", "honour", "decoration", "order", "pin", "laurel", "trophy", "medallion", "insignia", "bronze", "silver", "gold"]
  },
  context: {
    category: icon_category:sports,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 379. circle-stop
CREATE icon:circle_stop CONTENT {
  identity: {
    value: 'circle_stop',
    slug: 'circle-stop'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_stop_name,
    label_i18n: i18n_key:icon_circle_stop_label,
    keywords: ["circle-stop", "media", "music"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 380. circle-user-round
CREATE icon:circle_user_round CONTENT {
  identity: {
    value: 'circle_user_round',
    slug: 'circle-user-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_user_round_name,
    label_i18n: i18n_key:icon_circle_user_round_label,
    keywords: ["circle-user-round", "person", "account", "contact"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 381. circle-user
CREATE icon:circle_user CONTENT {
  identity: {
    value: 'circle_user',
    slug: 'circle-user'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_user_name,
    label_i18n: i18n_key:icon_circle_user_label,
    keywords: ["circle-user", "person", "account", "contact"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 382. circle-x
CREATE icon:circle_x CONTENT {
  identity: {
    value: 'circle_x',
    slug: 'circle-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_x_name,
    label_i18n: i18n_key:icon_circle_x_label,
    keywords: ["circle-x", "cancel", "close", "delete", "remove", "times", "clear", "error", "incorrect", "wrong", "mistake", "failure", "linter", "multiply", "multiplication"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 383. circle
CREATE icon:circle CONTENT {
  identity: {
    value: 'circle',
    slug: 'circle'
  },
  presentation: {
    name_i18n: i18n_key:icon_circle_name,
    label_i18n: i18n_key:icon_circle_label,
    keywords: ["circle", "off", "zero", "record", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 384. circuit-board
CREATE icon:circuit_board CONTENT {
  identity: {
    value: 'circuit_board',
    slug: 'circuit-board'
  },
  presentation: {
    name_i18n: i18n_key:icon_circuit_board_name,
    label_i18n: i18n_key:icon_circuit_board_label,
    keywords: ["circuit-board", "computing", "electricity", "electronics"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 385. citrus
CREATE icon:citrus CONTENT {
  identity: {
    value: 'citrus',
    slug: 'citrus'
  },
  presentation: {
    name_i18n: i18n_key:icon_citrus_name,
    label_i18n: i18n_key:icon_citrus_label,
    keywords: ["citrus", "lemon", "orange", "grapefruit", "fruit"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 386. clapperboard
CREATE icon:clapperboard CONTENT {
  identity: {
    value: 'clapperboard',
    slug: 'clapperboard'
  },
  presentation: {
    name_i18n: i18n_key:icon_clapperboard_name,
    label_i18n: i18n_key:icon_clapperboard_label,
    keywords: ["clapperboard", "movie", "film", "video", "camera", "cinema", "cut", "action", "television", "tv", "show", "entertainment"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 387. clipboard-check
CREATE icon:clipboard_check CONTENT {
  identity: {
    value: 'clipboard_check',
    slug: 'clipboard-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_check_name,
    label_i18n: i18n_key:icon_clipboard_check_label,
    keywords: ["clipboard-check", "copied", "pasted", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 388. clipboard-clock
CREATE icon:clipboard_clock CONTENT {
  identity: {
    value: 'clipboard_clock',
    slug: 'clipboard-clock'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_clock_name,
    label_i18n: i18n_key:icon_clipboard_clock_label,
    keywords: ["clipboard-clock", "copy", "paste", "history", "log", "clock", "time", "watch", "alarm", "hour", "minute", "reminder", "scheduled", "deadline", "pending", "time tracking", "timesheets", "appointment", "logbook"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 389. clipboard-copy
CREATE icon:clipboard_copy CONTENT {
  identity: {
    value: 'clipboard_copy',
    slug: 'clipboard-copy'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_copy_name,
    label_i18n: i18n_key:icon_clipboard_copy_label,
    keywords: ["clipboard-copy", "copy", "paste"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 390. clipboard-list
CREATE icon:clipboard_list CONTENT {
  identity: {
    value: 'clipboard_list',
    slug: 'clipboard-list'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_list_name,
    label_i18n: i18n_key:icon_clipboard_list_label,
    keywords: ["clipboard-list", "copy", "paste", "tasks"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 391. clipboard-minus
CREATE icon:clipboard_minus CONTENT {
  identity: {
    value: 'clipboard_minus',
    slug: 'clipboard-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_minus_name,
    label_i18n: i18n_key:icon_clipboard_minus_label,
    keywords: ["clipboard-minus", "copy", "delete", "remove", "erase", "document", "medical", "report", "doctor"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 392. clipboard-paste
CREATE icon:clipboard_paste CONTENT {
  identity: {
    value: 'clipboard_paste',
    slug: 'clipboard-paste'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_paste_name,
    label_i18n: i18n_key:icon_clipboard_paste_label,
    keywords: ["clipboard-paste", "copy", "paste"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 393. clipboard-pen-line
CREATE icon:clipboard_pen_line CONTENT {
  identity: {
    value: 'clipboard_pen_line',
    slug: 'clipboard-pen-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_pen_line_name,
    label_i18n: i18n_key:icon_clipboard_pen_line_label,
    keywords: ["clipboard-pen-line", "paste"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 394. clipboard-pen
CREATE icon:clipboard_pen CONTENT {
  identity: {
    value: 'clipboard_pen',
    slug: 'clipboard-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_pen_name,
    label_i18n: i18n_key:icon_clipboard_pen_label,
    keywords: ["clipboard-pen", "paste", "signature"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 395. clipboard-plus
CREATE icon:clipboard_plus CONTENT {
  identity: {
    value: 'clipboard_plus',
    slug: 'clipboard-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_plus_name,
    label_i18n: i18n_key:icon_clipboard_plus_label,
    keywords: ["clipboard-plus", "copy", "paste", "add", "create", "new", "document", "medical", "report", "doctor"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 396. clipboard-type
CREATE icon:clipboard_type CONTENT {
  identity: {
    value: 'clipboard_type',
    slug: 'clipboard-type'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_type_name,
    label_i18n: i18n_key:icon_clipboard_type_label,
    keywords: ["clipboard-type", "paste", "format", "text"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 397. clipboard-x
CREATE icon:clipboard_x CONTENT {
  identity: {
    value: 'clipboard_x',
    slug: 'clipboard-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_x_name,
    label_i18n: i18n_key:icon_clipboard_x_label,
    keywords: ["clipboard-x", "copy", "paste", "discard", "remove"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 398. clipboard
CREATE icon:clipboard CONTENT {
  identity: {
    value: 'clipboard',
    slug: 'clipboard'
  },
  presentation: {
    name_i18n: i18n_key:icon_clipboard_name,
    label_i18n: i18n_key:icon_clipboard_label,
    keywords: ["clipboard", "copy", "paste"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 399. clock-1
CREATE icon:clock_1 CONTENT {
  identity: {
    value: 'clock_1',
    slug: 'clock-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_1_name,
    label_i18n: i18n_key:icon_clock_1_label,
    keywords: ["clock-1", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 400. clock-10
CREATE icon:clock_10 CONTENT {
  identity: {
    value: 'clock_10',
    slug: 'clock-10'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_10_name,
    label_i18n: i18n_key:icon_clock_10_label,
    keywords: ["clock-10", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 401. clock-11
CREATE icon:clock_11 CONTENT {
  identity: {
    value: 'clock_11',
    slug: 'clock-11'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_11_name,
    label_i18n: i18n_key:icon_clock_11_label,
    keywords: ["clock-11", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 402. clock-12
CREATE icon:clock_12 CONTENT {
  identity: {
    value: 'clock_12',
    slug: 'clock-12'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_12_name,
    label_i18n: i18n_key:icon_clock_12_label,
    keywords: ["clock-12", "time", "watch", "alarm", "noon", "midnight"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 403. clock-2
CREATE icon:clock_2 CONTENT {
  identity: {
    value: 'clock_2',
    slug: 'clock-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_2_name,
    label_i18n: i18n_key:icon_clock_2_label,
    keywords: ["clock-2", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 404. clock-3
CREATE icon:clock_3 CONTENT {
  identity: {
    value: 'clock_3',
    slug: 'clock-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_3_name,
    label_i18n: i18n_key:icon_clock_3_label,
    keywords: ["clock-3", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 405. clock-4
CREATE icon:clock_4 CONTENT {
  identity: {
    value: 'clock_4',
    slug: 'clock-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_4_name,
    label_i18n: i18n_key:icon_clock_4_label,
    keywords: ["clock-4", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 406. clock-5
CREATE icon:clock_5 CONTENT {
  identity: {
    value: 'clock_5',
    slug: 'clock-5'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_5_name,
    label_i18n: i18n_key:icon_clock_5_label,
    keywords: ["clock-5", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 407. clock-6
CREATE icon:clock_6 CONTENT {
  identity: {
    value: 'clock_6',
    slug: 'clock-6'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_6_name,
    label_i18n: i18n_key:icon_clock_6_label,
    keywords: ["clock-6", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 408. clock-7
CREATE icon:clock_7 CONTENT {
  identity: {
    value: 'clock_7',
    slug: 'clock-7'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_7_name,
    label_i18n: i18n_key:icon_clock_7_label,
    keywords: ["clock-7", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 409. clock-8
CREATE icon:clock_8 CONTENT {
  identity: {
    value: 'clock_8',
    slug: 'clock-8'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_8_name,
    label_i18n: i18n_key:icon_clock_8_label,
    keywords: ["clock-8", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 410. clock-9
CREATE icon:clock_9 CONTENT {
  identity: {
    value: 'clock_9',
    slug: 'clock-9'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_9_name,
    label_i18n: i18n_key:icon_clock_9_label,
    keywords: ["clock-9", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 411. clock-alert
CREATE icon:clock_alert CONTENT {
  identity: {
    value: 'clock_alert',
    slug: 'clock-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_alert_name,
    label_i18n: i18n_key:icon_clock_alert_label,
    keywords: ["clock-alert", "time", "watch", "alarm", "warning", "wrong"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 412. clock-arrow-down
CREATE icon:clock_arrow_down CONTENT {
  identity: {
    value: 'clock_arrow_down',
    slug: 'clock-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_arrow_down_name,
    label_i18n: i18n_key:icon_clock_arrow_down_label,
    keywords: ["clock-arrow-down", "time", "watch", "alarm", "sort", "order", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 413. clock-arrow-up
CREATE icon:clock_arrow_up CONTENT {
  identity: {
    value: 'clock_arrow_up',
    slug: 'clock-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_arrow_up_name,
    label_i18n: i18n_key:icon_clock_arrow_up_label,
    keywords: ["clock-arrow-up", "time", "watch", "alarm", "sort", "order", "ascending", "descending", "increasing", "decreasing", "rising", "falling"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 414. clock-fading
CREATE icon:clock_fading CONTENT {
  identity: {
    value: 'clock_fading',
    slug: 'clock-fading'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_fading_name,
    label_i18n: i18n_key:icon_clock_fading_label,
    keywords: ["clock-fading", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 415. clock-plus
CREATE icon:clock_plus CONTENT {
  identity: {
    value: 'clock_plus',
    slug: 'clock-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_plus_name,
    label_i18n: i18n_key:icon_clock_plus_label,
    keywords: ["clock-plus", "time", "watch", "alarm", "add", "create", "new"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 416. clock
CREATE icon:clock CONTENT {
  identity: {
    value: 'clock',
    slug: 'clock'
  },
  presentation: {
    name_i18n: i18n_key:icon_clock_name,
    label_i18n: i18n_key:icon_clock_label,
    keywords: ["clock", "time", "watch", "alarm"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 417. closed-caption
CREATE icon:closed_caption CONTENT {
  identity: {
    value: 'closed_caption',
    slug: 'closed-caption'
  },
  presentation: {
    name_i18n: i18n_key:icon_closed_caption_name,
    label_i18n: i18n_key:icon_closed_caption_label,
    keywords: ["closed-caption", "tv", "movie", "video", "closed captions", "subtitles", "subhead", "transcription", "transcribe", "dialogue", "accessibility"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 418. cloud-alert
CREATE icon:cloud_alert CONTENT {
  identity: {
    value: 'cloud_alert',
    slug: 'cloud-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_alert_name,
    label_i18n: i18n_key:icon_cloud_alert_label,
    keywords: ["cloud-alert", "weather", "danger", "warning", "alert", "error", "sync", "network", "exclamation"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 419. cloud-check
CREATE icon:cloud_check CONTENT {
  identity: {
    value: 'cloud_check',
    slug: 'cloud-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_check_name,
    label_i18n: i18n_key:icon_cloud_check_label,
    keywords: ["cloud-check", "sync", "network", "success", "done", "completed", "saved", "persisted"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 420. cloud-cog
CREATE icon:cloud_cog CONTENT {
  identity: {
    value: 'cloud_cog',
    slug: 'cloud-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_cog_name,
    label_i18n: i18n_key:icon_cloud_cog_label,
    keywords: ["cloud-cog", "computing", "ai", "cluster", "network"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 421. cloud-download
CREATE icon:cloud_download CONTENT {
  identity: {
    value: 'cloud_download',
    slug: 'cloud-download'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_download_name,
    label_i18n: i18n_key:icon_cloud_download_label,
    keywords: ["cloud-download", "import"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 422. cloud-drizzle
CREATE icon:cloud_drizzle CONTENT {
  identity: {
    value: 'cloud_drizzle',
    slug: 'cloud-drizzle'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_drizzle_name,
    label_i18n: i18n_key:icon_cloud_drizzle_label,
    keywords: ["cloud-drizzle", "weather", "shower"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 423. cloud-fog
CREATE icon:cloud_fog CONTENT {
  identity: {
    value: 'cloud_fog',
    slug: 'cloud-fog'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_fog_name,
    label_i18n: i18n_key:icon_cloud_fog_label,
    keywords: ["cloud-fog", "weather", "mist"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 424. cloud-hail
CREATE icon:cloud_hail CONTENT {
  identity: {
    value: 'cloud_hail',
    slug: 'cloud-hail'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_hail_name,
    label_i18n: i18n_key:icon_cloud_hail_label,
    keywords: ["cloud-hail", "weather", "rainfall"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 425. cloud-lightning
CREATE icon:cloud_lightning CONTENT {
  identity: {
    value: 'cloud_lightning',
    slug: 'cloud-lightning'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_lightning_name,
    label_i18n: i18n_key:icon_cloud_lightning_label,
    keywords: ["cloud-lightning", "weather", "bolt"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 426. cloud-moon-rain
CREATE icon:cloud_moon_rain CONTENT {
  identity: {
    value: 'cloud_moon_rain',
    slug: 'cloud-moon-rain'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_moon_rain_name,
    label_i18n: i18n_key:icon_cloud_moon_rain_label,
    keywords: ["cloud-moon-rain", "weather", "partly", "night", "rainfall"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 427. cloud-moon
CREATE icon:cloud_moon CONTENT {
  identity: {
    value: 'cloud_moon',
    slug: 'cloud-moon'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_moon_name,
    label_i18n: i18n_key:icon_cloud_moon_label,
    keywords: ["cloud-moon", "weather", "night"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 428. cloud-off
CREATE icon:cloud_off CONTENT {
  identity: {
    value: 'cloud_off',
    slug: 'cloud-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_off_name,
    label_i18n: i18n_key:icon_cloud_off_label,
    keywords: ["cloud-off", "disconnect"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 429. cloud-rain-wind
CREATE icon:cloud_rain_wind CONTENT {
  identity: {
    value: 'cloud_rain_wind',
    slug: 'cloud-rain-wind'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_rain_wind_name,
    label_i18n: i18n_key:icon_cloud_rain_wind_label,
    keywords: ["cloud-rain-wind", "weather", "rainfall"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 430. cloud-rain
CREATE icon:cloud_rain CONTENT {
  identity: {
    value: 'cloud_rain',
    slug: 'cloud-rain'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_rain_name,
    label_i18n: i18n_key:icon_cloud_rain_label,
    keywords: ["cloud-rain", "weather", "rainfall"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 431. cloud-snow
CREATE icon:cloud_snow CONTENT {
  identity: {
    value: 'cloud_snow',
    slug: 'cloud-snow'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_snow_name,
    label_i18n: i18n_key:icon_cloud_snow_label,
    keywords: ["cloud-snow", "weather", "blizzard"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 432. cloud-sun-rain
CREATE icon:cloud_sun_rain CONTENT {
  identity: {
    value: 'cloud_sun_rain',
    slug: 'cloud-sun-rain'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_sun_rain_name,
    label_i18n: i18n_key:icon_cloud_sun_rain_label,
    keywords: ["cloud-sun-rain", "weather", "partly", "rainfall"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 433. cloud-sun
CREATE icon:cloud_sun CONTENT {
  identity: {
    value: 'cloud_sun',
    slug: 'cloud-sun'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_sun_name,
    label_i18n: i18n_key:icon_cloud_sun_label,
    keywords: ["cloud-sun", "weather", "partly"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 434. cloud-upload
CREATE icon:cloud_upload CONTENT {
  identity: {
    value: 'cloud_upload',
    slug: 'cloud-upload'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_upload_name,
    label_i18n: i18n_key:icon_cloud_upload_label,
    keywords: ["cloud-upload", "file"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 435. cloud
CREATE icon:cloud CONTENT {
  identity: {
    value: 'cloud',
    slug: 'cloud'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloud_name,
    label_i18n: i18n_key:icon_cloud_label,
    keywords: ["cloud", "weather"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 436. cloudy
CREATE icon:cloudy CONTENT {
  identity: {
    value: 'cloudy',
    slug: 'cloudy'
  },
  presentation: {
    name_i18n: i18n_key:icon_cloudy_name,
    label_i18n: i18n_key:icon_cloudy_label,
    keywords: ["cloudy", "weather", "clouds"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 437. clover
CREATE icon:clover CONTENT {
  identity: {
    value: 'clover',
    slug: 'clover'
  },
  presentation: {
    name_i18n: i18n_key:icon_clover_name,
    label_i18n: i18n_key:icon_clover_label,
    keywords: ["clover", "leaf", "luck", "plant"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 438. club
CREATE icon:club CONTENT {
  identity: {
    value: 'club',
    slug: 'club'
  },
  presentation: {
    name_i18n: i18n_key:icon_club_name,
    label_i18n: i18n_key:icon_club_label,
    keywords: ["club", "shape", "suit", "playing", "cards"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 439. code-xml
CREATE icon:code_xml CONTENT {
  identity: {
    value: 'code_xml',
    slug: 'code-xml'
  },
  presentation: {
    name_i18n: i18n_key:icon_code_xml_name,
    label_i18n: i18n_key:icon_code_xml_label,
    keywords: ["code-xml", "source", "programming", "html", "xml"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 440. code
CREATE icon:code CONTENT {
  identity: {
    value: 'code',
    slug: 'code'
  },
  presentation: {
    name_i18n: i18n_key:icon_code_name,
    label_i18n: i18n_key:icon_code_label,
    keywords: ["code", "source", "programming", "html", "xml"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 441. codepen
CREATE icon:codepen CONTENT {
  identity: {
    value: 'codepen',
    slug: 'codepen'
  },
  presentation: {
    name_i18n: i18n_key:icon_codepen_name,
    label_i18n: i18n_key:icon_codepen_label,
    keywords: ["codepen", "logo"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 442. codesandbox
CREATE icon:codesandbox CONTENT {
  identity: {
    value: 'codesandbox',
    slug: 'codesandbox'
  },
  presentation: {
    name_i18n: i18n_key:icon_codesandbox_name,
    label_i18n: i18n_key:icon_codesandbox_label,
    keywords: ["codesandbox", "logo"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 443. coffee
CREATE icon:coffee CONTENT {
  identity: {
    value: 'coffee',
    slug: 'coffee'
  },
  presentation: {
    name_i18n: i18n_key:icon_coffee_name,
    label_i18n: i18n_key:icon_coffee_label,
    keywords: ["coffee", "drink", "cup", "mug", "tea", "cafe", "hot", "beverage"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 444. cog
CREATE icon:cog CONTENT {
  identity: {
    value: 'cog',
    slug: 'cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_cog_name,
    label_i18n: i18n_key:icon_cog_label,
    keywords: ["cog", "computing", "settings", "cog", "edit", "gear", "preferences", "controls", "configuration", "fixed", "build", "construction", "parts"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 445. coins
CREATE icon:coins CONTENT {
  identity: {
    value: 'coins',
    slug: 'coins'
  },
  presentation: {
    name_i18n: i18n_key:icon_coins_name,
    label_i18n: i18n_key:icon_coins_label,
    keywords: ["coins", "money", "cash", "finance", "gamble"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 446. columns-2
CREATE icon:columns_2 CONTENT {
  identity: {
    value: 'columns_2',
    slug: 'columns-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_columns_2_name,
    label_i18n: i18n_key:icon_columns_2_label,
    keywords: ["columns-2", "lines", "list", "queue", "preview", "panel", "parallel", "series", "split", "vertical", "horizontal", "half", "center", "middle", "even", "sidebar", "drawer", "gutter", "fold", "reflow", "typography", "pagination", "pages"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 447. columns-3-cog
CREATE icon:columns_3_cog CONTENT {
  identity: {
    value: 'columns_3_cog',
    slug: 'columns-3-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_columns_3_cog_name,
    label_i18n: i18n_key:icon_columns_3_cog_label,
    keywords: ["columns-3-cog", "columns", "settings", "customize", "table", "grid", "adjust", "configuration", "panel", "layout"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 448. columns-3
CREATE icon:columns_3 CONTENT {
  identity: {
    value: 'columns_3',
    slug: 'columns-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_columns_3_name,
    label_i18n: i18n_key:icon_columns_3_label,
    keywords: ["columns-3", "lines", "list", "queue", "preview", "parallel", "series", "split", "vertical", "horizontal", "thirds", "triple", "center", "middle", "alignment", "even", "sidebars", "drawers", "gutters", "fold", "reflow", "typography", "pagination", "pages"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 449. columns-4
CREATE icon:columns_4 CONTENT {
  identity: {
    value: 'columns_4',
    slug: 'columns-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_columns_4_name,
    label_i18n: i18n_key:icon_columns_4_label,
    keywords: ["columns-4", "lines", "list", "queue", "preview", "parallel", "series", "split", "vertical", "horizontal", "thirds", "triple", "center", "middle", "alignment", "even", "sidebars", "drawers", "gutters", "fold", "reflow", "typography", "pagination", "pages", "prison", "jail", "bars", "sentence", "police", "cops", "cell", "crime", "criminal", "justice", "law", "enforcement", "grill"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 450. combine
CREATE icon:combine CONTENT {
  identity: {
    value: 'combine',
    slug: 'combine'
  },
  presentation: {
    name_i18n: i18n_key:icon_combine_name,
    label_i18n: i18n_key:icon_combine_label,
    keywords: ["combine", "cubes", "packages", "parts", "units", "collection", "cluster", "combine", "gather", "merge"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 451. command
CREATE icon:command CONTENT {
  identity: {
    value: 'command',
    slug: 'command'
  },
  presentation: {
    name_i18n: i18n_key:icon_command_name,
    label_i18n: i18n_key:icon_command_label,
    keywords: ["command", "keyboard", "key", "mac", "cmd", "button"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 452. compass
CREATE icon:compass CONTENT {
  identity: {
    value: 'compass',
    slug: 'compass'
  },
  presentation: {
    name_i18n: i18n_key:icon_compass_name,
    label_i18n: i18n_key:icon_compass_label,
    keywords: ["compass", "direction", "north", "east", "south", "west", "safari", "browser"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 453. component
CREATE icon:component CONTENT {
  identity: {
    value: 'component',
    slug: 'component'
  },
  presentation: {
    name_i18n: i18n_key:icon_component_name,
    label_i18n: i18n_key:icon_component_label,
    keywords: ["component", "design", "element", "group", "module", "part", "symbol"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 454. computer
CREATE icon:computer CONTENT {
  identity: {
    value: 'computer',
    slug: 'computer'
  },
  presentation: {
    name_i18n: i18n_key:icon_computer_name,
    label_i18n: i18n_key:icon_computer_label,
    keywords: ["computer", "pc", "chassis", "codespaces", "github"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 455. concierge-bell
CREATE icon:concierge_bell CONTENT {
  identity: {
    value: 'concierge_bell',
    slug: 'concierge-bell'
  },
  presentation: {
    name_i18n: i18n_key:icon_concierge_bell_name,
    label_i18n: i18n_key:icon_concierge_bell_label,
    keywords: ["concierge-bell", "reception", "bell", "porter"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 456. cone
CREATE icon:cone CONTENT {
  identity: {
    value: 'cone',
    slug: 'cone'
  },
  presentation: {
    name_i18n: i18n_key:icon_cone_name,
    label_i18n: i18n_key:icon_cone_label,
    keywords: ["cone", "conical", "triangle", "triangular", "geometry", "filter", "funnel", "hopper", "spotlight", "searchlight"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 457. construction
CREATE icon:construction CONTENT {
  identity: {
    value: 'construction',
    slug: 'construction'
  },
  presentation: {
    name_i18n: i18n_key:icon_construction_name,
    label_i18n: i18n_key:icon_construction_label,
    keywords: ["construction", "roadwork", "maintenance", "blockade", "barricade"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 458. contact-round
CREATE icon:contact_round CONTENT {
  identity: {
    value: 'contact_round',
    slug: 'contact-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_contact_round_name,
    label_i18n: i18n_key:icon_contact_round_label,
    keywords: ["contact-round", "user", "person", "family", "friend", "acquaintance", "listing", "networking"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 459. contact
CREATE icon:contact CONTENT {
  identity: {
    value: 'contact',
    slug: 'contact'
  },
  presentation: {
    name_i18n: i18n_key:icon_contact_name,
    label_i18n: i18n_key:icon_contact_label,
    keywords: ["contact", "user", "person", "family", "friend", "acquaintance", "listing", "networking"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 460. container
CREATE icon:container CONTENT {
  identity: {
    value: 'container',
    slug: 'container'
  },
  presentation: {
    name_i18n: i18n_key:icon_container_name,
    label_i18n: i18n_key:icon_container_label,
    keywords: ["container", "storage", "shipping", "freight", "supply chain", "docker", "environment", "devops", "code", "coding"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 461. contrast
CREATE icon:contrast CONTENT {
  identity: {
    value: 'contrast',
    slug: 'contrast'
  },
  presentation: {
    name_i18n: i18n_key:icon_contrast_name,
    label_i18n: i18n_key:icon_contrast_label,
    keywords: ["contrast", "display", "accessibility"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 462. cookie
CREATE icon:cookie CONTENT {
  identity: {
    value: 'cookie',
    slug: 'cookie'
  },
  presentation: {
    name_i18n: i18n_key:icon_cookie_name,
    label_i18n: i18n_key:icon_cookie_label,
    keywords: ["cookie", "biscuit", "privacy", "legal", "food"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 463. cooking-pot
CREATE icon:cooking_pot CONTENT {
  identity: {
    value: 'cooking_pot',
    slug: 'cooking-pot'
  },
  presentation: {
    name_i18n: i18n_key:icon_cooking_pot_name,
    label_i18n: i18n_key:icon_cooking_pot_label,
    keywords: ["cooking-pot", "pod", "cooking", "recipe", "food", "kitchen", "chef", "restaurant", "dinner", "lunch", "breakfast", "meal", "eat"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 464. copy-check
CREATE icon:copy_check CONTENT {
  identity: {
    value: 'copy_check',
    slug: 'copy-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_copy_check_name,
    label_i18n: i18n_key:icon_copy_check_label,
    keywords: ["copy-check", "clone", "duplicate", "done", "multiple"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 465. copy-minus
CREATE icon:copy_minus CONTENT {
  identity: {
    value: 'copy_minus',
    slug: 'copy-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_copy_minus_name,
    label_i18n: i18n_key:icon_copy_minus_label,
    keywords: ["copy-minus", "clone", "duplicate", "remove", "delete", "collapse", "subtract", "multiple", "-"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 466. copy-plus
CREATE icon:copy_plus CONTENT {
  identity: {
    value: 'copy_plus',
    slug: 'copy-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_copy_plus_name,
    label_i18n: i18n_key:icon_copy_plus_label,
    keywords: ["copy-plus", "clone", "duplicate", "add", "multiple", "expand", "+"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 467. copy-slash
CREATE icon:copy_slash CONTENT {
  identity: {
    value: 'copy_slash',
    slug: 'copy-slash'
  },
  presentation: {
    name_i18n: i18n_key:icon_copy_slash_name,
    label_i18n: i18n_key:icon_copy_slash_label,
    keywords: ["copy-slash", "clone", "duplicate", "cancel", "ban", "no", "stop", "forbidden", "prohibited", "error", "multiple", "divide", "division", "split", "or", "/"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 468. copy-x
CREATE icon:copy_x CONTENT {
  identity: {
    value: 'copy_x',
    slug: 'copy-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_copy_x_name,
    label_i18n: i18n_key:icon_copy_x_label,
    keywords: ["copy-x", "cancel", "close", "delete", "remove", "clear", "multiple", "multiply", "multiplication", "times"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 469. copy
CREATE icon:copy CONTENT {
  identity: {
    value: 'copy',
    slug: 'copy'
  },
  presentation: {
    name_i18n: i18n_key:icon_copy_name,
    label_i18n: i18n_key:icon_copy_label,
    keywords: ["copy", "clone", "duplicate", "multiple"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 470. copyleft
CREATE icon:copyleft CONTENT {
  identity: {
    value: 'copyleft',
    slug: 'copyleft'
  },
  presentation: {
    name_i18n: i18n_key:icon_copyleft_name,
    label_i18n: i18n_key:icon_copyleft_label,
    keywords: ["copyleft", "licence"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 471. copyright
CREATE icon:copyright CONTENT {
  identity: {
    value: 'copyright',
    slug: 'copyright'
  },
  presentation: {
    name_i18n: i18n_key:icon_copyright_name,
    label_i18n: i18n_key:icon_copyright_label,
    keywords: ["copyright", "licence", "license"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 472. corner-down-left
CREATE icon:corner_down_left CONTENT {
  identity: {
    value: 'corner_down_left',
    slug: 'corner-down-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_down_left_name,
    label_i18n: i18n_key:icon_corner_down_left_label,
    keywords: ["corner-down-left", "arrow", "return"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 473. corner-down-right
CREATE icon:corner_down_right CONTENT {
  identity: {
    value: 'corner_down_right',
    slug: 'corner-down-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_down_right_name,
    label_i18n: i18n_key:icon_corner_down_right_label,
    keywords: ["corner-down-right", "arrow", "indent", "tab"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 474. corner-left-down
CREATE icon:corner_left_down CONTENT {
  identity: {
    value: 'corner_left_down',
    slug: 'corner-left-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_left_down_name,
    label_i18n: i18n_key:icon_corner_left_down_label,
    keywords: ["corner-left-down", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 475. corner-left-up
CREATE icon:corner_left_up CONTENT {
  identity: {
    value: 'corner_left_up',
    slug: 'corner-left-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_left_up_name,
    label_i18n: i18n_key:icon_corner_left_up_label,
    keywords: ["corner-left-up", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 476. corner-right-down
CREATE icon:corner_right_down CONTENT {
  identity: {
    value: 'corner_right_down',
    slug: 'corner-right-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_right_down_name,
    label_i18n: i18n_key:icon_corner_right_down_label,
    keywords: ["corner-right-down", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 477. corner-right-up
CREATE icon:corner_right_up CONTENT {
  identity: {
    value: 'corner_right_up',
    slug: 'corner-right-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_right_up_name,
    label_i18n: i18n_key:icon_corner_right_up_label,
    keywords: ["corner-right-up", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 478. corner-up-left
CREATE icon:corner_up_left CONTENT {
  identity: {
    value: 'corner_up_left',
    slug: 'corner-up-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_up_left_name,
    label_i18n: i18n_key:icon_corner_up_left_label,
    keywords: ["corner-up-left", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 479. corner-up-right
CREATE icon:corner_up_right CONTENT {
  identity: {
    value: 'corner_up_right',
    slug: 'corner-up-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_corner_up_right_name,
    label_i18n: i18n_key:icon_corner_up_right_label,
    keywords: ["corner-up-right", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 480. cpu
CREATE icon:cpu CONTENT {
  identity: {
    value: 'cpu',
    slug: 'cpu'
  },
  presentation: {
    name_i18n: i18n_key:icon_cpu_name,
    label_i18n: i18n_key:icon_cpu_label,
    keywords: ["cpu", "processor", "cores", "technology", "computer", "chip", "circuit", "memory", "ram", "specs", "gigahertz", "ghz"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 481. creative-commons
CREATE icon:creative_commons CONTENT {
  identity: {
    value: 'creative_commons',
    slug: 'creative-commons'
  },
  presentation: {
    name_i18n: i18n_key:icon_creative_commons_name,
    label_i18n: i18n_key:icon_creative_commons_label,
    keywords: ["creative-commons", "licence", "license"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 482. credit-card
CREATE icon:credit_card CONTENT {
  identity: {
    value: 'credit_card',
    slug: 'credit-card'
  },
  presentation: {
    name_i18n: i18n_key:icon_credit_card_name,
    label_i18n: i18n_key:icon_credit_card_label,
    keywords: ["credit-card", "bank", "purchase", "payment", "cc"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 483. croissant
CREATE icon:croissant CONTENT {
  identity: {
    value: 'croissant',
    slug: 'croissant'
  },
  presentation: {
    name_i18n: i18n_key:icon_croissant_name,
    label_i18n: i18n_key:icon_croissant_label,
    keywords: ["croissant", "bakery", "cooking", "food", "pastry"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 484. crop
CREATE icon:crop CONTENT {
  identity: {
    value: 'crop',
    slug: 'crop'
  },
  presentation: {
    name_i18n: i18n_key:icon_crop_name,
    label_i18n: i18n_key:icon_crop_label,
    keywords: ["crop", "photo", "image"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 485. cross
CREATE icon:cross CONTENT {
  identity: {
    value: 'cross',
    slug: 'cross'
  },
  presentation: {
    name_i18n: i18n_key:icon_cross_name,
    label_i18n: i18n_key:icon_cross_label,
    keywords: ["cross", "healthcare", "first aid"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 486. crosshair
CREATE icon:crosshair CONTENT {
  identity: {
    value: 'crosshair',
    slug: 'crosshair'
  },
  presentation: {
    name_i18n: i18n_key:icon_crosshair_name,
    label_i18n: i18n_key:icon_crosshair_label,
    keywords: ["crosshair", "aim", "target"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 487. crown
CREATE icon:crown CONTENT {
  identity: {
    value: 'crown',
    slug: 'crown'
  },
  presentation: {
    name_i18n: i18n_key:icon_crown_name,
    label_i18n: i18n_key:icon_crown_label,
    keywords: ["crown", "diadem", "tiara", "circlet", "corona", "king", "ruler", "winner", "favourite"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 488. cuboid
CREATE icon:cuboid CONTENT {
  identity: {
    value: 'cuboid',
    slug: 'cuboid'
  },
  presentation: {
    name_i18n: i18n_key:icon_cuboid_name,
    label_i18n: i18n_key:icon_cuboid_label,
    keywords: ["cuboid", "brick", "block", "container", "storage", "geometry", "rectangular", "hexahedron"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 489. cup-soda
CREATE icon:cup_soda CONTENT {
  identity: {
    value: 'cup_soda',
    slug: 'cup-soda'
  },
  presentation: {
    name_i18n: i18n_key:icon_cup_soda_name,
    label_i18n: i18n_key:icon_cup_soda_label,
    keywords: ["cup-soda", "beverage", "cup", "drink", "soda", "straw", "water"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 490. currency
CREATE icon:currency CONTENT {
  identity: {
    value: 'currency',
    slug: 'currency'
  },
  presentation: {
    name_i18n: i18n_key:icon_currency_name,
    label_i18n: i18n_key:icon_currency_label,
    keywords: ["currency", "finance", "money"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 491. cylinder
CREATE icon:cylinder CONTENT {
  identity: {
    value: 'cylinder',
    slug: 'cylinder'
  },
  presentation: {
    name_i18n: i18n_key:icon_cylinder_name,
    label_i18n: i18n_key:icon_cylinder_label,
    keywords: ["cylinder", "shape", "elliptical", "geometry", "container", "storage", "tin", "pot"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 492. dam
CREATE icon:dam CONTENT {
  identity: {
    value: 'dam',
    slug: 'dam'
  },
  presentation: {
    name_i18n: i18n_key:icon_dam_name,
    label_i18n: i18n_key:icon_dam_label,
    keywords: ["dam", "electricity", "energy", "water"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 493. database-backup
CREATE icon:database_backup CONTENT {
  identity: {
    value: 'database_backup',
    slug: 'database-backup'
  },
  presentation: {
    name_i18n: i18n_key:icon_database_backup_name,
    label_i18n: i18n_key:icon_database_backup_label,
    keywords: ["database-backup", "storage", "memory", "bytes", "servers", "backup", "timemachine", "rotate", "arrow", "left"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 494. database-zap
CREATE icon:database_zap CONTENT {
  identity: {
    value: 'database_zap',
    slug: 'database-zap'
  },
  presentation: {
    name_i18n: i18n_key:icon_database_zap_name,
    label_i18n: i18n_key:icon_database_zap_label,
    keywords: ["database-zap", "cache busting", "storage", "memory", "bytes", "servers", "power", "crash"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 495. database
CREATE icon:database CONTENT {
  identity: {
    value: 'database',
    slug: 'database'
  },
  presentation: {
    name_i18n: i18n_key:icon_database_name,
    label_i18n: i18n_key:icon_database_label,
    keywords: ["database", "storage", "memory", "container", "tin", "pot", "bytes", "servers"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 496. decimals-arrow-left
CREATE icon:decimals_arrow_left CONTENT {
  identity: {
    value: 'decimals_arrow_left',
    slug: 'decimals-arrow-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_decimals_arrow_left_name,
    label_i18n: i18n_key:icon_decimals_arrow_left_label,
    keywords: ["decimals-arrow-left", "numerical", "decimal", "decrease", "less", "fewer", "precision", "rounding", "digits", "fraction", "float", "number"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 497. decimals-arrow-right
CREATE icon:decimals_arrow_right CONTENT {
  identity: {
    value: 'decimals_arrow_right',
    slug: 'decimals-arrow-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_decimals_arrow_right_name,
    label_i18n: i18n_key:icon_decimals_arrow_right_label,
    keywords: ["decimals-arrow-right", "numerical", "decimal", "increase", "more", "precision", "rounding", "digits", "fraction", "float", "number"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 498. delete
CREATE icon:delete CONTENT {
  identity: {
    value: 'delete',
    slug: 'delete'
  },
  presentation: {
    name_i18n: i18n_key:icon_delete_name,
    label_i18n: i18n_key:icon_delete_label,
    keywords: ["delete", "backspace", "remove"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 499. dessert
CREATE icon:dessert CONTENT {
  identity: {
    value: 'dessert',
    slug: 'dessert'
  },
  presentation: {
    name_i18n: i18n_key:icon_dessert_name,
    label_i18n: i18n_key:icon_dessert_label,
    keywords: ["dessert", "pudding", "christmas", "xmas", "custard", "iced bun", "icing", "fondant", "cake", "ice cream", "gelato", "sundae", "scoop", "dollop", "sugar", "food", "sweet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 500. diameter
CREATE icon:diameter CONTENT {
  identity: {
    value: 'diameter',
    slug: 'diameter'
  },
  presentation: {
    name_i18n: i18n_key:icon_diameter_name,
    label_i18n: i18n_key:icon_diameter_label,
    keywords: ["diameter", "shape", "circle", "geometry", "trigonometry", "width", "height", "size", "calculate", "measure"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 501. diamond-minus
CREATE icon:diamond_minus CONTENT {
  identity: {
    value: 'diamond_minus',
    slug: 'diamond-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_diamond_minus_name,
    label_i18n: i18n_key:icon_diamond_minus_label,
    keywords: ["diamond-minus", "keyframe", "subtract", "remove", "decrease", "reduce", "calculator", "button", "keyboard", "line", "divider", "separator", "horizontal rule", "hr", "html", "markup", "markdown", "---", "toolbar", "operator", "code", "coding", "minimum", "downgrade"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 502. diamond-percent
CREATE icon:diamond_percent CONTENT {
  identity: {
    value: 'diamond_percent',
    slug: 'diamond-percent'
  },
  presentation: {
    name_i18n: i18n_key:icon_diamond_percent_name,
    label_i18n: i18n_key:icon_diamond_percent_label,
    keywords: ["diamond-percent", "verified", "unverified", "sale", "discount", "offer", "marketing", "sticker", "price tag"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 503. diamond-plus
CREATE icon:diamond_plus CONTENT {
  identity: {
    value: 'diamond_plus',
    slug: 'diamond-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_diamond_plus_name,
    label_i18n: i18n_key:icon_diamond_plus_label,
    keywords: ["diamond-plus", "keyframe", "add", "new", "increase", "increment", "positive", "calculate", "toolbar", "crosshair", "aim", "target", "scope", "sight", "reticule", "maximum", "upgrade", "extra", "+"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 504. diamond
CREATE icon:diamond CONTENT {
  identity: {
    value: 'diamond',
    slug: 'diamond'
  },
  presentation: {
    name_i18n: i18n_key:icon_diamond_name,
    label_i18n: i18n_key:icon_diamond_label,
    keywords: ["diamond", "square", "rectangle", "oblique", "rhombus", "shape", "suit", "playing", "cards"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 505. dice-1
CREATE icon:dice_1 CONTENT {
  identity: {
    value: 'dice_1',
    slug: 'dice-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_dice_1_name,
    label_i18n: i18n_key:icon_dice_1_label,
    keywords: ["dice-1", "dice", "random", "tabletop", "1", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 506. dice-2
CREATE icon:dice_2 CONTENT {
  identity: {
    value: 'dice_2',
    slug: 'dice-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_dice_2_name,
    label_i18n: i18n_key:icon_dice_2_label,
    keywords: ["dice-2", "dice", "random", "tabletop", "2", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 507. dice-3
CREATE icon:dice_3 CONTENT {
  identity: {
    value: 'dice_3',
    slug: 'dice-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_dice_3_name,
    label_i18n: i18n_key:icon_dice_3_label,
    keywords: ["dice-3", "dice", "random", "tabletop", "3", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 508. dice-4
CREATE icon:dice_4 CONTENT {
  identity: {
    value: 'dice_4',
    slug: 'dice-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_dice_4_name,
    label_i18n: i18n_key:icon_dice_4_label,
    keywords: ["dice-4", "dice", "random", "tabletop", "4", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 509. dice-5
CREATE icon:dice_5 CONTENT {
  identity: {
    value: 'dice_5',
    slug: 'dice-5'
  },
  presentation: {
    name_i18n: i18n_key:icon_dice_5_name,
    label_i18n: i18n_key:icon_dice_5_label,
    keywords: ["dice-5", "dice", "random", "tabletop", "5", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 510. dice-6
CREATE icon:dice_6 CONTENT {
  identity: {
    value: 'dice_6',
    slug: 'dice-6'
  },
  presentation: {
    name_i18n: i18n_key:icon_dice_6_name,
    label_i18n: i18n_key:icon_dice_6_label,
    keywords: ["dice-6", "dice", "random", "tabletop", "6", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 511. dices
CREATE icon:dices CONTENT {
  identity: {
    value: 'dices',
    slug: 'dices'
  },
  presentation: {
    name_i18n: i18n_key:icon_dices_name,
    label_i18n: i18n_key:icon_dices_label,
    keywords: ["dices", "dice", "random", "tabletop", "board", "game"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 512. diff
CREATE icon:diff CONTENT {
  identity: {
    value: 'diff',
    slug: 'diff'
  },
  presentation: {
    name_i18n: i18n_key:icon_diff_name,
    label_i18n: i18n_key:icon_diff_label,
    keywords: ["diff", "patch", "difference", "compare", "plus", "minus", "plus-minus", "math"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 513. disc-2
CREATE icon:disc_2 CONTENT {
  identity: {
    value: 'disc_2',
    slug: 'disc-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_disc_2_name,
    label_i18n: i18n_key:icon_disc_2_label,
    keywords: ["disc-2", "album", "music", "vinyl", "record", "cd", "dvd", "format", "dj", "spin", "rotate", "rpm"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 514. disc-3
CREATE icon:disc_3 CONTENT {
  identity: {
    value: 'disc_3',
    slug: 'disc-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_disc_3_name,
    label_i18n: i18n_key:icon_disc_3_label,
    keywords: ["disc-3", "album", "music", "vinyl", "record", "cd", "dvd", "format", "dj", "spin", "rotate", "rpm"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 515. disc-album
CREATE icon:disc_album CONTENT {
  identity: {
    value: 'disc_album',
    slug: 'disc-album'
  },
  presentation: {
    name_i18n: i18n_key:icon_disc_album_name,
    label_i18n: i18n_key:icon_disc_album_label,
    keywords: ["disc-album", "album", "music", "songs", "format", "cd", "dvd", "vinyl", "sleeve", "cover", "platinum", "compilation", "ep", "recording", "playback", "spin", "rotate", "rpm", "dj"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 516. disc
CREATE icon:disc CONTENT {
  identity: {
    value: 'disc',
    slug: 'disc'
  },
  presentation: {
    name_i18n: i18n_key:icon_disc_name,
    label_i18n: i18n_key:icon_disc_label,
    keywords: ["disc", "album", "music", "songs", "format", "cd", "dvd", "vinyl", "sleeve", "cover", "platinum", "compilation", "ep", "recording", "playback", "spin", "rotate", "rpm", "dj"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 517. divide
CREATE icon:divide CONTENT {
  identity: {
    value: 'divide',
    slug: 'divide'
  },
  presentation: {
    name_i18n: i18n_key:icon_divide_name,
    label_i18n: i18n_key:icon_divide_label,
    keywords: ["divide", "calculate", "math", "division", "operator", "code", "\u00f7", "/"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 518. dna-off
CREATE icon:dna_off CONTENT {
  identity: {
    value: 'dna_off',
    slug: 'dna-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_dna_off_name,
    label_i18n: i18n_key:icon_dna_off_label,
    keywords: ["dna-off", "gene", "gmo free", "helix", "heredity", "chromosome", "nucleic acid"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 519. dna
CREATE icon:dna CONTENT {
  identity: {
    value: 'dna',
    slug: 'dna'
  },
  presentation: {
    name_i18n: i18n_key:icon_dna_name,
    label_i18n: i18n_key:icon_dna_label,
    keywords: ["dna", "gene", "gmo", "helix", "heredity", "chromosome", "nucleic acid"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 520. dock
CREATE icon:dock CONTENT {
  identity: {
    value: 'dock',
    slug: 'dock'
  },
  presentation: {
    name_i18n: i18n_key:icon_dock_name,
    label_i18n: i18n_key:icon_dock_label,
    keywords: ["dock", "desktop", "applications", "launch", "home", "menu bar", "bottom", "line", "macos", "osx"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 521. dog
CREATE icon:dog CONTENT {
  identity: {
    value: 'dog',
    slug: 'dog'
  },
  presentation: {
    name_i18n: i18n_key:icon_dog_name,
    label_i18n: i18n_key:icon_dog_label,
    keywords: ["dog", "animal", "pet", "puppy", "hound", "canine"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 522. dollar-sign
CREATE icon:dollar_sign CONTENT {
  identity: {
    value: 'dollar_sign',
    slug: 'dollar-sign'
  },
  presentation: {
    name_i18n: i18n_key:icon_dollar_sign_name,
    label_i18n: i18n_key:icon_dollar_sign_label,
    keywords: ["dollar-sign", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 523. donut
CREATE icon:donut CONTENT {
  identity: {
    value: 'donut',
    slug: 'donut'
  },
  presentation: {
    name_i18n: i18n_key:icon_donut_name,
    label_i18n: i18n_key:icon_donut_label,
    keywords: ["donut", "doughnut", "sprinkles", "topping", "fast food", "junk food", "snack", "treat", "sweet", "sugar", "dessert", "hollow", "ring"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 524. door-closed-locked
CREATE icon:door_closed_locked CONTENT {
  identity: {
    value: 'door_closed_locked',
    slug: 'door-closed-locked'
  },
  presentation: {
    name_i18n: i18n_key:icon_door_closed_locked_name,
    label_i18n: i18n_key:icon_door_closed_locked_label,
    keywords: ["door-closed-locked", "entrance", "entry", "exit", "ingress", "egress", "gate", "gateway", "emergency exit", "lock"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 525. door-closed
CREATE icon:door_closed CONTENT {
  identity: {
    value: 'door_closed',
    slug: 'door-closed'
  },
  presentation: {
    name_i18n: i18n_key:icon_door_closed_name,
    label_i18n: i18n_key:icon_door_closed_label,
    keywords: ["door-closed", "entrance", "entry", "exit", "ingress", "egress", "gate", "gateway", "emergency exit"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 526. door-open
CREATE icon:door_open CONTENT {
  identity: {
    value: 'door_open',
    slug: 'door-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_door_open_name,
    label_i18n: i18n_key:icon_door_open_label,
    keywords: ["door-open", "entrance", "entry", "exit", "ingress", "egress", "gate", "gateway", "emergency exit"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 527. dot
CREATE icon:dot CONTENT {
  identity: {
    value: 'dot',
    slug: 'dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_dot_name,
    label_i18n: i18n_key:icon_dot_label,
    keywords: ["dot", "interpunct", "interpoint", "middot", "step", "punctuation", "period", "full stop", "end", "finish", "final", "characters", "font", "typography", "type", "center", "."]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 528. download
CREATE icon:download CONTENT {
  identity: {
    value: 'download',
    slug: 'download'
  },
  presentation: {
    name_i18n: i18n_key:icon_download_name,
    label_i18n: i18n_key:icon_download_label,
    keywords: ["download", "import", "export", "save"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 529. drafting-compass
CREATE icon:drafting_compass CONTENT {
  identity: {
    value: 'drafting_compass',
    slug: 'drafting-compass'
  },
  presentation: {
    name_i18n: i18n_key:icon_drafting_compass_name,
    label_i18n: i18n_key:icon_drafting_compass_label,
    keywords: ["drafting-compass", "geometry", "trigonometry", "radius", "diameter", "circumference", "calculate", "measure", "arc", "curve", "draw", "sketch"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 530. drama
CREATE icon:drama CONTENT {
  identity: {
    value: 'drama',
    slug: 'drama'
  },
  presentation: {
    name_i18n: i18n_key:icon_drama_name,
    label_i18n: i18n_key:icon_drama_label,
    keywords: ["drama", "drama", "masks", "theater", "theatre", "entertainment", "show"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 531. dribbble
CREATE icon:dribbble CONTENT {
  identity: {
    value: 'dribbble',
    slug: 'dribbble'
  },
  presentation: {
    name_i18n: i18n_key:icon_dribbble_name,
    label_i18n: i18n_key:icon_dribbble_label,
    keywords: ["dribbble", "design", "social"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 532. drill
CREATE icon:drill CONTENT {
  identity: {
    value: 'drill',
    slug: 'drill'
  },
  presentation: {
    name_i18n: i18n_key:icon_drill_name,
    label_i18n: i18n_key:icon_drill_label,
    keywords: ["drill", "power", "bit", "head", "hole", "diy", "toolbox", "build", "construction"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 533. drone
CREATE icon:drone CONTENT {
  identity: {
    value: 'drone',
    slug: 'drone'
  },
  presentation: {
    name_i18n: i18n_key:icon_drone_name,
    label_i18n: i18n_key:icon_drone_label,
    keywords: ["drone", "quadcopter", "uav", "aerial", "flight", "flying", "technology", "airborne", "robotics"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 534. droplet-off
CREATE icon:droplet_off CONTENT {
  identity: {
    value: 'droplet_off',
    slug: 'droplet-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_droplet_off_name,
    label_i18n: i18n_key:icon_droplet_off_label,
    keywords: ["droplet-off", "water", "weather", "liquid", "fluid", "wet", "moisture", "damp", "bead", "globule"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 535. droplet
CREATE icon:droplet CONTENT {
  identity: {
    value: 'droplet',
    slug: 'droplet'
  },
  presentation: {
    name_i18n: i18n_key:icon_droplet_name,
    label_i18n: i18n_key:icon_droplet_label,
    keywords: ["droplet", "water", "weather", "liquid", "fluid", "wet", "moisture", "damp", "bead", "globule"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 536. droplets
CREATE icon:droplets CONTENT {
  identity: {
    value: 'droplets',
    slug: 'droplets'
  },
  presentation: {
    name_i18n: i18n_key:icon_droplets_name,
    label_i18n: i18n_key:icon_droplets_label,
    keywords: ["droplets", "water", "weather", "liquid", "fluid", "wet", "moisture", "damp", "bead", "globule"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 537. drum
CREATE icon:drum CONTENT {
  identity: {
    value: 'drum',
    slug: 'drum'
  },
  presentation: {
    name_i18n: i18n_key:icon_drum_name,
    label_i18n: i18n_key:icon_drum_label,
    keywords: ["drum", "drummer", "kit", "sticks", "instrument", "beat", "bang", "bass", "backing track", "band", "play", "performance", "concert", "march", "music", "audio", "sound", "noise", "loud"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 538. drumstick
CREATE icon:drumstick CONTENT {
  identity: {
    value: 'drumstick',
    slug: 'drumstick'
  },
  presentation: {
    name_i18n: i18n_key:icon_drumstick_name,
    label_i18n: i18n_key:icon_drumstick_label,
    keywords: ["drumstick", "food", "chicken", "meat"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 539. dumbbell
CREATE icon:dumbbell CONTENT {
  identity: {
    value: 'dumbbell',
    slug: 'dumbbell'
  },
  presentation: {
    name_i18n: i18n_key:icon_dumbbell_name,
    label_i18n: i18n_key:icon_dumbbell_label,
    keywords: ["dumbbell", "barbell", "weight", "workout", "gym"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 540. ear-off
CREATE icon:ear_off CONTENT {
  identity: {
    value: 'ear_off',
    slug: 'ear-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_ear_off_name,
    label_i18n: i18n_key:icon_ear_off_label,
    keywords: ["ear-off", "hearing", "hard of hearing", "hearing loss", "deafness", "noise", "silence", "audio", "accessibility"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 541. ear
CREATE icon:ear CONTENT {
  identity: {
    value: 'ear',
    slug: 'ear'
  },
  presentation: {
    name_i18n: i18n_key:icon_ear_name,
    label_i18n: i18n_key:icon_ear_label,
    keywords: ["ear", "hearing", "noise", "audio", "accessibility"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 542. earth-lock
CREATE icon:earth_lock CONTENT {
  identity: {
    value: 'earth_lock',
    slug: 'earth-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_earth_lock_name,
    label_i18n: i18n_key:icon_earth_lock_label,
    keywords: ["earth-lock", "vpn", "private", "privacy", "network", "world", "browser", "security", "encryption", "protection", "connection"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 543. earth
CREATE icon:earth CONTENT {
  identity: {
    value: 'earth',
    slug: 'earth'
  },
  presentation: {
    name_i18n: i18n_key:icon_earth_name,
    label_i18n: i18n_key:icon_earth_label,
    keywords: ["earth", "world", "browser", "language", "translate", "globe"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 544. eclipse
CREATE icon:eclipse CONTENT {
  identity: {
    value: 'eclipse',
    slug: 'eclipse'
  },
  presentation: {
    name_i18n: i18n_key:icon_eclipse_name,
    label_i18n: i18n_key:icon_eclipse_label,
    keywords: ["eclipse", "lunar", "solar", "crescent moon", "sun", "earth", "day", "night", "planet", "space", "mode", "dark", "light", "toggle", "switch", "color", "css", "styles", "display", "accessibility", "contrast", "brightness", "blend", "shade"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 545. egg-fried
CREATE icon:egg_fried CONTENT {
  identity: {
    value: 'egg_fried',
    slug: 'egg-fried'
  },
  presentation: {
    name_i18n: i18n_key:icon_egg_fried_name,
    label_i18n: i18n_key:icon_egg_fried_label,
    keywords: ["egg-fried", "food", "breakfast"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 546. egg-off
CREATE icon:egg_off CONTENT {
  identity: {
    value: 'egg_off',
    slug: 'egg-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_egg_off_name,
    label_i18n: i18n_key:icon_egg_off_label,
    keywords: ["egg-off", "egg free", "vegan", "hatched", "bad egg"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 547. egg
CREATE icon:egg CONTENT {
  identity: {
    value: 'egg',
    slug: 'egg'
  },
  presentation: {
    name_i18n: i18n_key:icon_egg_name,
    label_i18n: i18n_key:icon_egg_label,
    keywords: ["egg", "bird", "chicken", "nest", "hatch", "shell", "incubate", "soft boiled", "hard", "breakfast", "brunch", "morning", "easter"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 548. ellipsis-vertical
CREATE icon:ellipsis_vertical CONTENT {
  identity: {
    value: 'ellipsis_vertical',
    slug: 'ellipsis-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_ellipsis_vertical_name,
    label_i18n: i18n_key:icon_ellipsis_vertical_label,
    keywords: ["ellipsis-vertical", "menu", "options", "spread", "more", "further", "extra", "overflow", "dots", "\u2026", "..."]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 549. ellipsis
CREATE icon:ellipsis CONTENT {
  identity: {
    value: 'ellipsis',
    slug: 'ellipsis'
  },
  presentation: {
    name_i18n: i18n_key:icon_ellipsis_name,
    label_i18n: i18n_key:icon_ellipsis_label,
    keywords: ["ellipsis", "et cetera", "etc", "loader", "loading", "progress", "pending", "throbber", "menu", "options", "operator", "code", "coding", "spread", "rest", "more", "further", "extra", "overflow", "dots", "\u2026", "..."]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 550. equal-approximately
CREATE icon:equal_approximately CONTENT {
  identity: {
    value: 'equal_approximately',
    slug: 'equal-approximately'
  },
  presentation: {
    name_i18n: i18n_key:icon_equal_approximately_name,
    label_i18n: i18n_key:icon_equal_approximately_label,
    keywords: ["equal-approximately", "about", "calculate", "math", "operater"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 551. equal-not
CREATE icon:equal_not CONTENT {
  identity: {
    value: 'equal_not',
    slug: 'equal-not'
  },
  presentation: {
    name_i18n: i18n_key:icon_equal_not_name,
    label_i18n: i18n_key:icon_equal_not_label,
    keywords: ["equal-not", "calculate", "off", "math", "operator", "code", "\u2260"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 552. equal
CREATE icon:equal CONTENT {
  identity: {
    value: 'equal',
    slug: 'equal'
  },
  presentation: {
    name_i18n: i18n_key:icon_equal_name,
    label_i18n: i18n_key:icon_equal_label,
    keywords: ["equal", "calculate", "math", "operator", "assignment", "code", "="]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 553. eraser
CREATE icon:eraser CONTENT {
  identity: {
    value: 'eraser',
    slug: 'eraser'
  },
  presentation: {
    name_i18n: i18n_key:icon_eraser_name,
    label_i18n: i18n_key:icon_eraser_label,
    keywords: ["eraser", "pencil", "drawing", "undo", "delete", "clear", "trash", "remove"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 554. ethernet-port
CREATE icon:ethernet_port CONTENT {
  identity: {
    value: 'ethernet_port',
    slug: 'ethernet-port'
  },
  presentation: {
    name_i18n: i18n_key:icon_ethernet_port_name,
    label_i18n: i18n_key:icon_ethernet_port_label,
    keywords: ["ethernet-port", "internet", "network", "connection", "cable", "lan", "port", "router", "switch", "hub", "modem", "web", "online", "networking", "communication", "socket", "plug", "slot", "controller", "connector", "interface", "console", "signal", "data", "input", "output"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 555. euro
CREATE icon:euro CONTENT {
  identity: {
    value: 'euro',
    slug: 'euro'
  },
  presentation: {
    name_i18n: i18n_key:icon_euro_name,
    label_i18n: i18n_key:icon_euro_label,
    keywords: ["euro", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 556. ev-charger
CREATE icon:ev_charger CONTENT {
  identity: {
    value: 'ev_charger',
    slug: 'ev-charger'
  },
  presentation: {
    name_i18n: i18n_key:icon_ev_charger_name,
    label_i18n: i18n_key:icon_ev_charger_label,
    keywords: ["ev-charger", "electric", "charger", "station", "vehicle", "fast", "plug", "ev", "power", "electricity", "energy", "accumulator", "charge"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 557. expand
CREATE icon:expand CONTENT {
  identity: {
    value: 'expand',
    slug: 'expand'
  },
  presentation: {
    name_i18n: i18n_key:icon_expand_name,
    label_i18n: i18n_key:icon_expand_label,
    keywords: ["expand", "scale", "fullscreen", "maximize", "minimize", "contract"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 558. external-link
CREATE icon:external_link CONTENT {
  identity: {
    value: 'external_link',
    slug: 'external-link'
  },
  presentation: {
    name_i18n: i18n_key:icon_external_link_name,
    label_i18n: i18n_key:icon_external_link_label,
    keywords: ["external-link", "outbound", "open", "share"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 559. eye-closed
CREATE icon:eye_closed CONTENT {
  identity: {
    value: 'eye_closed',
    slug: 'eye-closed'
  },
  presentation: {
    name_i18n: i18n_key:icon_eye_closed_name,
    label_i18n: i18n_key:icon_eye_closed_label,
    keywords: ["eye-closed", "view", "watch", "see", "hide", "conceal", "mask", "hidden", "visibility", "vision"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 560. eye-off
CREATE icon:eye_off CONTENT {
  identity: {
    value: 'eye_off',
    slug: 'eye-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_eye_off_name,
    label_i18n: i18n_key:icon_eye_off_label,
    keywords: ["eye-off", "view", "watch", "see", "hide", "conceal", "mask", "hidden", "visibility", "vision"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 561. eye
CREATE icon:eye CONTENT {
  identity: {
    value: 'eye',
    slug: 'eye'
  },
  presentation: {
    name_i18n: i18n_key:icon_eye_name,
    label_i18n: i18n_key:icon_eye_label,
    keywords: ["eye", "view", "watch", "see", "show", "expose", "reveal", "display", "visible", "visibility", "vision", "preview", "read"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 562. facebook
CREATE icon:facebook CONTENT {
  identity: {
    value: 'facebook',
    slug: 'facebook'
  },
  presentation: {
    name_i18n: i18n_key:icon_facebook_name,
    label_i18n: i18n_key:icon_facebook_label,
    keywords: ["facebook", "logo", "social"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 563. factory
CREATE icon:factory CONTENT {
  identity: {
    value: 'factory',
    slug: 'factory'
  },
  presentation: {
    name_i18n: i18n_key:icon_factory_name,
    label_i18n: i18n_key:icon_factory_label,
    keywords: ["factory", "building", "business", "energy", "industry", "manufacture", "sector"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 564. fan
CREATE icon:fan CONTENT {
  identity: {
    value: 'fan',
    slug: 'fan'
  },
  presentation: {
    name_i18n: i18n_key:icon_fan_name,
    label_i18n: i18n_key:icon_fan_label,
    keywords: ["fan", "air", "cooler", "ventilation", "ventilator", "blower"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 565. fast-forward
CREATE icon:fast_forward CONTENT {
  identity: {
    value: 'fast_forward',
    slug: 'fast-forward'
  },
  presentation: {
    name_i18n: i18n_key:icon_fast_forward_name,
    label_i18n: i18n_key:icon_fast_forward_label,
    keywords: ["fast-forward", "music"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 566. feather
CREATE icon:feather CONTENT {
  identity: {
    value: 'feather',
    slug: 'feather'
  },
  presentation: {
    name_i18n: i18n_key:icon_feather_name,
    label_i18n: i18n_key:icon_feather_label,
    keywords: ["feather", "logo"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 567. fence
CREATE icon:fence CONTENT {
  identity: {
    value: 'fence',
    slug: 'fence'
  },
  presentation: {
    name_i18n: i18n_key:icon_fence_name,
    label_i18n: i18n_key:icon_fence_label,
    keywords: ["fence", "picket", "panels", "woodwork", "diy", "materials", "suburban", "garden", "property", "territory"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 568. ferris-wheel
CREATE icon:ferris_wheel CONTENT {
  identity: {
    value: 'ferris_wheel',
    slug: 'ferris-wheel'
  },
  presentation: {
    name_i18n: i18n_key:icon_ferris_wheel_name,
    label_i18n: i18n_key:icon_ferris_wheel_label,
    keywords: ["ferris-wheel", "big wheel", "daisy wheel", "observation", "attraction", "entertainment", "amusement park", "theme park", "funfair"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 569. figma
CREATE icon:figma CONTENT {
  identity: {
    value: 'figma',
    slug: 'figma'
  },
  presentation: {
    name_i18n: i18n_key:icon_figma_name,
    label_i18n: i18n_key:icon_figma_label,
    keywords: ["figma", "logo", "design", "tool"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 570. file-archive
CREATE icon:file_archive CONTENT {
  identity: {
    value: 'file_archive',
    slug: 'file-archive'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_archive_name,
    label_i18n: i18n_key:icon_file_archive_label,
    keywords: ["file-archive", "zip", "package", "archive"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 571. file-audio-2
CREATE icon:file_audio_2 CONTENT {
  identity: {
    value: 'file_audio_2',
    slug: 'file-audio-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_audio_2_name,
    label_i18n: i18n_key:icon_file_audio_2_label,
    keywords: ["file-audio-2", "music", "audio", "sound", "headphones"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 572. file-audio
CREATE icon:file_audio CONTENT {
  identity: {
    value: 'file_audio',
    slug: 'file-audio'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_audio_name,
    label_i18n: i18n_key:icon_file_audio_label,
    keywords: ["file-audio", "music", "audio", "sound", "headphones"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 573. file-axis-3d
CREATE icon:file_axis_3d CONTENT {
  identity: {
    value: 'file_axis_3d',
    slug: 'file-axis-3d'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_axis_3d_name,
    label_i18n: i18n_key:icon_file_axis_3d_label,
    keywords: ["file-axis-3d", "model", "3d", "axis", "coordinates"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 574. file-badge-2
CREATE icon:file_badge_2 CONTENT {
  identity: {
    value: 'file_badge_2',
    slug: 'file-badge-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_badge_2_name,
    label_i18n: i18n_key:icon_file_badge_2_label,
    keywords: ["file-badge-2", "award", "achievement", "badge", "rosette", "prize", "winner"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 575. file-badge
CREATE icon:file_badge CONTENT {
  identity: {
    value: 'file_badge',
    slug: 'file-badge'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_badge_name,
    label_i18n: i18n_key:icon_file_badge_label,
    keywords: ["file-badge", "award", "achievement", "badge", "rosette", "prize", "winner"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 576. file-box
CREATE icon:file_box CONTENT {
  identity: {
    value: 'file_box',
    slug: 'file-box'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_box_name,
    label_i18n: i18n_key:icon_file_box_label,
    keywords: ["file-box", "box", "package", "model"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 577. file-chart-column-increasing
CREATE icon:file_chart_column_increasing CONTENT {
  identity: {
    value: 'file_chart_column_increasing',
    slug: 'file-chart-column-increasing'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_chart_column_increasing_name,
    label_i18n: i18n_key:icon_file_chart_column_increasing_label,
    keywords: ["file-chart-column-increasing", "statistics", "analytics", "diagram", "graph", "presentation", "trending up"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 578. file-chart-column
CREATE icon:file_chart_column CONTENT {
  identity: {
    value: 'file_chart_column',
    slug: 'file-chart-column'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_chart_column_name,
    label_i18n: i18n_key:icon_file_chart_column_label,
    keywords: ["file-chart-column", "statistics", "analytics", "diagram", "graph", "presentation"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 579. file-chart-line
CREATE icon:file_chart_line CONTENT {
  identity: {
    value: 'file_chart_line',
    slug: 'file-chart-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_chart_line_name,
    label_i18n: i18n_key:icon_file_chart_line_label,
    keywords: ["file-chart-line", "statistics", "analytics", "diagram", "graph", "presentation"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 580. file-chart-pie
CREATE icon:file_chart_pie CONTENT {
  identity: {
    value: 'file_chart_pie',
    slug: 'file-chart-pie'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_chart_pie_name,
    label_i18n: i18n_key:icon_file_chart_pie_label,
    keywords: ["file-chart-pie", "statistics", "analytics", "diagram", "graph", "presentation"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 581. file-check-2
CREATE icon:file_check_2 CONTENT {
  identity: {
    value: 'file_check_2',
    slug: 'file-check-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_check_2_name,
    label_i18n: i18n_key:icon_file_check_2_label,
    keywords: ["file-check-2", "done", "document", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 582. file-check
CREATE icon:file_check CONTENT {
  identity: {
    value: 'file_check',
    slug: 'file-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_check_name,
    label_i18n: i18n_key:icon_file_check_label,
    keywords: ["file-check", "done", "document", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 583. file-clock
CREATE icon:file_clock CONTENT {
  identity: {
    value: 'file_clock',
    slug: 'file-clock'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_clock_name,
    label_i18n: i18n_key:icon_file_clock_label,
    keywords: ["file-clock", "history", "log", "clock"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 584. file-code-2
CREATE icon:file_code_2 CONTENT {
  identity: {
    value: 'file_code_2',
    slug: 'file-code-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_code_2_name,
    label_i18n: i18n_key:icon_file_code_2_label,
    keywords: ["file-code-2", "script", "document", "html", "xml", "property list", "plist"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 585. file-code
CREATE icon:file_code CONTENT {
  identity: {
    value: 'file_code',
    slug: 'file-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_code_name,
    label_i18n: i18n_key:icon_file_code_label,
    keywords: ["file-code", "script", "document", "gist", "html", "xml", "property list", "plist"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 586. file-cog
CREATE icon:file_cog CONTENT {
  identity: {
    value: 'file_cog',
    slug: 'file-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_cog_name,
    label_i18n: i18n_key:icon_file_cog_label,
    keywords: ["file-cog", "executable", "settings", "cog", "edit", "gear"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 587. file-diff
CREATE icon:file_diff CONTENT {
  identity: {
    value: 'file_diff',
    slug: 'file-diff'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_diff_name,
    label_i18n: i18n_key:icon_file_diff_label,
    keywords: ["file-diff", "diff", "patch"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 588. file-digit
CREATE icon:file_digit CONTENT {
  identity: {
    value: 'file_digit',
    slug: 'file-digit'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_digit_name,
    label_i18n: i18n_key:icon_file_digit_label,
    keywords: ["file-digit", "number", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 589. file-down
CREATE icon:file_down CONTENT {
  identity: {
    value: 'file_down',
    slug: 'file-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_down_name,
    label_i18n: i18n_key:icon_file_down_label,
    keywords: ["file-down", "download", "import", "export"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 590. file-heart
CREATE icon:file_heart CONTENT {
  identity: {
    value: 'file_heart',
    slug: 'file-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_heart_name,
    label_i18n: i18n_key:icon_file_heart_label,
    keywords: ["file-heart", "heart", "favourite", "bookmark", "quick link"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 591. file-image
CREATE icon:file_image CONTENT {
  identity: {
    value: 'file_image',
    slug: 'file-image'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_image_name,
    label_i18n: i18n_key:icon_file_image_label,
    keywords: ["file-image", "image", "graphics", "photo", "picture"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 592. file-input
CREATE icon:file_input CONTENT {
  identity: {
    value: 'file_input',
    slug: 'file-input'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_input_name,
    label_i18n: i18n_key:icon_file_input_label,
    keywords: ["file-input", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 593. file-json-2
CREATE icon:file_json_2 CONTENT {
  identity: {
    value: 'file_json_2',
    slug: 'file-json-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_json_2_name,
    label_i18n: i18n_key:icon_file_json_2_label,
    keywords: ["file-json-2", "code", "json", "curly braces", "curly brackets"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 594. file-json
CREATE icon:file_json CONTENT {
  identity: {
    value: 'file_json',
    slug: 'file-json'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_json_name,
    label_i18n: i18n_key:icon_file_json_label,
    keywords: ["file-json", "code", "json", "curly braces", "curly brackets"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 595. file-key-2
CREATE icon:file_key_2 CONTENT {
  identity: {
    value: 'file_key_2',
    slug: 'file-key-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_key_2_name,
    label_i18n: i18n_key:icon_file_key_2_label,
    keywords: ["file-key-2", "key", "private", "public", "security"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 596. file-key
CREATE icon:file_key CONTENT {
  identity: {
    value: 'file_key',
    slug: 'file-key'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_key_name,
    label_i18n: i18n_key:icon_file_key_label,
    keywords: ["file-key", "key", "private", "public", "security"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 597. file-lock-2
CREATE icon:file_lock_2 CONTENT {
  identity: {
    value: 'file_lock_2',
    slug: 'file-lock-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_lock_2_name,
    label_i18n: i18n_key:icon_file_lock_2_label,
    keywords: ["file-lock-2", "lock", "password", "security"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 598. file-lock
CREATE icon:file_lock CONTENT {
  identity: {
    value: 'file_lock',
    slug: 'file-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_lock_name,
    label_i18n: i18n_key:icon_file_lock_label,
    keywords: ["file-lock", "lock", "password", "security"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 599. file-minus-2
CREATE icon:file_minus_2 CONTENT {
  identity: {
    value: 'file_minus_2',
    slug: 'file-minus-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_minus_2_name,
    label_i18n: i18n_key:icon_file_minus_2_label,
    keywords: ["file-minus-2", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 600. file-minus
CREATE icon:file_minus CONTENT {
  identity: {
    value: 'file_minus',
    slug: 'file-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_minus_name,
    label_i18n: i18n_key:icon_file_minus_label,
    keywords: ["file-minus", "delete", "remove", "erase", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 601. file-music
CREATE icon:file_music CONTENT {
  identity: {
    value: 'file_music',
    slug: 'file-music'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_music_name,
    label_i18n: i18n_key:icon_file_music_label,
    keywords: ["file-music", "audio", "sound", "noise", "track", "digital", "recording", "playback", "piano", "keyboard", "keys", "notes", "chord", "midi", "octave"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 602. file-output
CREATE icon:file_output CONTENT {
  identity: {
    value: 'file_output',
    slug: 'file-output'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_output_name,
    label_i18n: i18n_key:icon_file_output_label,
    keywords: ["file-output", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 603. file-pen-line
CREATE icon:file_pen_line CONTENT {
  identity: {
    value: 'file_pen_line',
    slug: 'file-pen-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_pen_line_name,
    label_i18n: i18n_key:icon_file_pen_line_label,
    keywords: ["file-pen-line", "edit"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 604. file-pen
CREATE icon:file_pen CONTENT {
  identity: {
    value: 'file_pen',
    slug: 'file-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_pen_name,
    label_i18n: i18n_key:icon_file_pen_label,
    keywords: ["file-pen", "signature"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 605. file-play
CREATE icon:file_play CONTENT {
  identity: {
    value: 'file_play',
    slug: 'file-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_play_name,
    label_i18n: i18n_key:icon_file_play_label,
    keywords: ["file-play", "movie", "video", "film"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 606. file-plus-2
CREATE icon:file_plus_2 CONTENT {
  identity: {
    value: 'file_plus_2',
    slug: 'file-plus-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_plus_2_name,
    label_i18n: i18n_key:icon_file_plus_2_label,
    keywords: ["file-plus-2", "add", "create", "new", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 607. file-plus
CREATE icon:file_plus CONTENT {
  identity: {
    value: 'file_plus',
    slug: 'file-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_plus_name,
    label_i18n: i18n_key:icon_file_plus_label,
    keywords: ["file-plus", "add", "create", "new", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 608. file-question-mark
CREATE icon:file_question_mark CONTENT {
  identity: {
    value: 'file_question_mark',
    slug: 'file-question-mark'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_question_mark_name,
    label_i18n: i18n_key:icon_file_question_mark_label,
    keywords: ["file-question-mark", "readme", "help", "question"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 609. file-scan
CREATE icon:file_scan CONTENT {
  identity: {
    value: 'file_scan',
    slug: 'file-scan'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_scan_name,
    label_i18n: i18n_key:icon_file_scan_label,
    keywords: ["file-scan", "scan", "code", "qr-code"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 610. file-search-2
CREATE icon:file_search_2 CONTENT {
  identity: {
    value: 'file_search_2',
    slug: 'file-search-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_search_2_name,
    label_i18n: i18n_key:icon_file_search_2_label,
    keywords: ["file-search-2", "lost", "document", "find", "browser", "lens"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 611. file-search
CREATE icon:file_search CONTENT {
  identity: {
    value: 'file_search',
    slug: 'file-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_search_name,
    label_i18n: i18n_key:icon_file_search_label,
    keywords: ["file-search", "lost", "document", "find", "browser", "lens"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 612. file-sliders
CREATE icon:file_sliders CONTENT {
  identity: {
    value: 'file_sliders',
    slug: 'file-sliders'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_sliders_name,
    label_i18n: i18n_key:icon_file_sliders_label,
    keywords: ["file-sliders", "cogged", "gear", "mechanical", "machinery", "configuration", "controls", "preferences", "settings", "system", "admin", "edit", "executable"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 613. file-spreadsheet
CREATE icon:file_spreadsheet CONTENT {
  identity: {
    value: 'file_spreadsheet',
    slug: 'file-spreadsheet'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_spreadsheet_name,
    label_i18n: i18n_key:icon_file_spreadsheet_label,
    keywords: ["file-spreadsheet", "spreadsheet", "sheet", "table"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 614. file-stack
CREATE icon:file_stack CONTENT {
  identity: {
    value: 'file_stack',
    slug: 'file-stack'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_stack_name,
    label_i18n: i18n_key:icon_file_stack_label,
    keywords: ["file-stack", "versions", "multiple", "copy", "documents", "revisions", "version control", "history"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 615. file-symlink
CREATE icon:file_symlink CONTENT {
  identity: {
    value: 'file_symlink',
    slug: 'file-symlink'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_symlink_name,
    label_i18n: i18n_key:icon_file_symlink_label,
    keywords: ["file-symlink", "symlink", "symbolic", "link"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 616. file-terminal
CREATE icon:file_terminal CONTENT {
  identity: {
    value: 'file_terminal',
    slug: 'file-terminal'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_terminal_name,
    label_i18n: i18n_key:icon_file_terminal_label,
    keywords: ["file-terminal", "terminal", "bash", "script", "executable"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 617. file-text
CREATE icon:file_text CONTENT {
  identity: {
    value: 'file_text',
    slug: 'file-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_text_name,
    label_i18n: i18n_key:icon_file_text_label,
    keywords: ["file-text", "data", "txt", "pdf", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 618. file-type-2
CREATE icon:file_type_2 CONTENT {
  identity: {
    value: 'file_type_2',
    slug: 'file-type-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_type_2_name,
    label_i18n: i18n_key:icon_file_type_2_label,
    keywords: ["file-type-2", "font", "text", "typography", "type"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 619. file-type
CREATE icon:file_type CONTENT {
  identity: {
    value: 'file_type',
    slug: 'file-type'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_type_name,
    label_i18n: i18n_key:icon_file_type_label,
    keywords: ["file-type", "font", "text", "typography", "type"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 620. file-up
CREATE icon:file_up CONTENT {
  identity: {
    value: 'file_up',
    slug: 'file-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_up_name,
    label_i18n: i18n_key:icon_file_up_label,
    keywords: ["file-up", "upload", "import", "export"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 621. file-user
CREATE icon:file_user CONTENT {
  identity: {
    value: 'file_user',
    slug: 'file-user'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_user_name,
    label_i18n: i18n_key:icon_file_user_label,
    keywords: ["file-user", "person", "personal information", "people", "listing", "networking", "document", "contact", "cover letter", "resume", "cv", "curriculum vitae", "application form"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 622. file-video-camera
CREATE icon:file_video_camera CONTENT {
  identity: {
    value: 'file_video_camera',
    slug: 'file-video-camera'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_video_camera_name,
    label_i18n: i18n_key:icon_file_video_camera_label,
    keywords: ["file-video-camera", "movie", "video", "film"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 623. file-volume-2
CREATE icon:file_volume_2 CONTENT {
  identity: {
    value: 'file_volume_2',
    slug: 'file-volume-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_volume_2_name,
    label_i18n: i18n_key:icon_file_volume_2_label,
    keywords: ["file-volume-2", "audio", "music", "volume"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 624. file-volume
CREATE icon:file_volume CONTENT {
  identity: {
    value: 'file_volume',
    slug: 'file-volume'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_volume_name,
    label_i18n: i18n_key:icon_file_volume_label,
    keywords: ["file-volume", "audio", "music", "volume"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 625. file-warning
CREATE icon:file_warning CONTENT {
  identity: {
    value: 'file_warning',
    slug: 'file-warning'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_warning_name,
    label_i18n: i18n_key:icon_file_warning_label,
    keywords: ["file-warning", "hidden", "warning", "alert", "danger", "protected", "exclamation mark"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 626. file-x-2
CREATE icon:file_x_2 CONTENT {
  identity: {
    value: 'file_x_2',
    slug: 'file-x-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_x_2_name,
    label_i18n: i18n_key:icon_file_x_2_label,
    keywords: ["file-x-2", "lost", "delete", "remove", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 627. file-x
CREATE icon:file_x CONTENT {
  identity: {
    value: 'file_x',
    slug: 'file-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_x_name,
    label_i18n: i18n_key:icon_file_x_label,
    keywords: ["file-x", "lost", "delete", "remove", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 628. file
CREATE icon:file CONTENT {
  identity: {
    value: 'file',
    slug: 'file'
  },
  presentation: {
    name_i18n: i18n_key:icon_file_name,
    label_i18n: i18n_key:icon_file_label,
    keywords: ["file", "document"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 629. files
CREATE icon:files CONTENT {
  identity: {
    value: 'files',
    slug: 'files'
  },
  presentation: {
    name_i18n: i18n_key:icon_files_name,
    label_i18n: i18n_key:icon_files_label,
    keywords: ["files", "multiple", "copy", "documents"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 630. film
CREATE icon:film CONTENT {
  identity: {
    value: 'film',
    slug: 'film'
  },
  presentation: {
    name_i18n: i18n_key:icon_film_name,
    label_i18n: i18n_key:icon_film_label,
    keywords: ["film", "movie", "video", "reel", "camera", "cinema", "entertainment"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 631. fingerprint
CREATE icon:fingerprint CONTENT {
  identity: {
    value: 'fingerprint',
    slug: 'fingerprint'
  },
  presentation: {
    name_i18n: i18n_key:icon_fingerprint_name,
    label_i18n: i18n_key:icon_fingerprint_label,
    keywords: ["fingerprint", "2fa", "authentication", "biometric", "identity", "security"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 632. fire-extinguisher
CREATE icon:fire_extinguisher CONTENT {
  identity: {
    value: 'fire_extinguisher',
    slug: 'fire-extinguisher'
  },
  presentation: {
    name_i18n: i18n_key:icon_fire_extinguisher_name,
    label_i18n: i18n_key:icon_fire_extinguisher_label,
    keywords: ["fire-extinguisher", "flames", "smoke", "foam", "water", "spray", "hose", "firefighter", "fireman", "department", "brigade", "station", "emergency", "suppress", "compressed", "tank", "cylinder", "safety", "equipment", "amenities"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 633. fish-off
CREATE icon:fish_off CONTENT {
  identity: {
    value: 'fish_off',
    slug: 'fish-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_fish_off_name,
    label_i18n: i18n_key:icon_fish_off_label,
    keywords: ["fish-off", "food", "dish", "restaurant", "course", "meal", "seafood", "animal", "pet", "sea", "marine", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 634. fish-symbol
CREATE icon:fish_symbol CONTENT {
  identity: {
    value: 'fish_symbol',
    slug: 'fish-symbol'
  },
  presentation: {
    name_i18n: i18n_key:icon_fish_symbol_name,
    label_i18n: i18n_key:icon_fish_symbol_label,
    keywords: ["fish-symbol", "dish", "restaurant", "course", "meal", "seafood", "pet", "sea", "marine"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 635. fish
CREATE icon:fish CONTENT {
  identity: {
    value: 'fish',
    slug: 'fish'
  },
  presentation: {
    name_i18n: i18n_key:icon_fish_name,
    label_i18n: i18n_key:icon_fish_label,
    keywords: ["fish", "dish", "restaurant", "course", "meal", "seafood", "pet", "sea", "marine"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 636. flag-off
CREATE icon:flag_off CONTENT {
  identity: {
    value: 'flag_off',
    slug: 'flag-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_flag_off_name,
    label_i18n: i18n_key:icon_flag_off_label,
    keywords: ["flag-off", "unflag", "unmark", "report", "marker", "notification", "warning", "milestone", "goal", "notice", "signal", "attention", "banner"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 637. flag-triangle-left
CREATE icon:flag_triangle_left CONTENT {
  identity: {
    value: 'flag_triangle_left',
    slug: 'flag-triangle-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_flag_triangle_left_name,
    label_i18n: i18n_key:icon_flag_triangle_left_label,
    keywords: ["flag-triangle-left", "report", "timeline", "marker", "pin"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 638. flag-triangle-right
CREATE icon:flag_triangle_right CONTENT {
  identity: {
    value: 'flag_triangle_right',
    slug: 'flag-triangle-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_flag_triangle_right_name,
    label_i18n: i18n_key:icon_flag_triangle_right_label,
    keywords: ["flag-triangle-right", "report", "timeline", "marker", "pin"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 639. flag
CREATE icon:flag CONTENT {
  identity: {
    value: 'flag',
    slug: 'flag'
  },
  presentation: {
    name_i18n: i18n_key:icon_flag_name,
    label_i18n: i18n_key:icon_flag_label,
    keywords: ["flag", "report", "marker", "notification", "warning", "milestone", "goal", "notice", "signal", "attention", "banner"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 640. flame-kindling
CREATE icon:flame_kindling CONTENT {
  identity: {
    value: 'flame_kindling',
    slug: 'flame-kindling'
  },
  presentation: {
    name_i18n: i18n_key:icon_flame_kindling_name,
    label_i18n: i18n_key:icon_flame_kindling_label,
    keywords: ["flame-kindling", "campfire", "camping", "wilderness", "outdoors", "lit", "warmth", "wood", "twigs", "sticks"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 641. flame
CREATE icon:flame CONTENT {
  identity: {
    value: 'flame',
    slug: 'flame'
  },
  presentation: {
    name_i18n: i18n_key:icon_flame_name,
    label_i18n: i18n_key:icon_flame_label,
    keywords: ["flame", "heat", "burn", "light", "glow", "ignite", "passion", "ember", "fire", "lit", "burning", "spark", "embers", "smoke", "firefighter", "fireman", "department", "brigade", "station", "emergency"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 642. flashlight-off
CREATE icon:flashlight_off CONTENT {
  identity: {
    value: 'flashlight_off',
    slug: 'flashlight-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_flashlight_off_name,
    label_i18n: i18n_key:icon_flashlight_off_label,
    keywords: ["flashlight-off", "torch"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 643. flashlight
CREATE icon:flashlight CONTENT {
  identity: {
    value: 'flashlight',
    slug: 'flashlight'
  },
  presentation: {
    name_i18n: i18n_key:icon_flashlight_name,
    label_i18n: i18n_key:icon_flashlight_label,
    keywords: ["flashlight", "torch"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 644. flask-conical-off
CREATE icon:flask_conical_off CONTENT {
  identity: {
    value: 'flask_conical_off',
    slug: 'flask-conical-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_flask_conical_off_name,
    label_i18n: i18n_key:icon_flask_conical_off_label,
    keywords: ["flask-conical-off", "beaker", "erlenmeyer", "non toxic", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 645. flask-conical
CREATE icon:flask_conical CONTENT {
  identity: {
    value: 'flask_conical',
    slug: 'flask-conical'
  },
  presentation: {
    name_i18n: i18n_key:icon_flask_conical_name,
    label_i18n: i18n_key:icon_flask_conical_label,
    keywords: ["flask-conical", "beaker", "erlenmeyer", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 646. flask-round
CREATE icon:flask_round CONTENT {
  identity: {
    value: 'flask_round',
    slug: 'flask-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_flask_round_name,
    label_i18n: i18n_key:icon_flask_round_label,
    keywords: ["flask-round", "beaker", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 647. flip-horizontal-2
CREATE icon:flip_horizontal_2 CONTENT {
  identity: {
    value: 'flip_horizontal_2',
    slug: 'flip-horizontal-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_flip_horizontal_2_name,
    label_i18n: i18n_key:icon_flip_horizontal_2_label,
    keywords: ["flip-horizontal-2", "reflect", "mirror", "alignment", "dashed"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 648. flip-horizontal
CREATE icon:flip_horizontal CONTENT {
  identity: {
    value: 'flip_horizontal',
    slug: 'flip-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_flip_horizontal_name,
    label_i18n: i18n_key:icon_flip_horizontal_label,
    keywords: ["flip-horizontal", "reflect", "mirror", "alignment", "dashed"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 649. flip-vertical-2
CREATE icon:flip_vertical_2 CONTENT {
  identity: {
    value: 'flip_vertical_2',
    slug: 'flip-vertical-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_flip_vertical_2_name,
    label_i18n: i18n_key:icon_flip_vertical_2_label,
    keywords: ["flip-vertical-2", "reflect", "mirror", "alignment", "dashed"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 650. flip-vertical
CREATE icon:flip_vertical CONTENT {
  identity: {
    value: 'flip_vertical',
    slug: 'flip-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_flip_vertical_name,
    label_i18n: i18n_key:icon_flip_vertical_label,
    keywords: ["flip-vertical", "reflect", "mirror", "alignment", "dashed"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 651. flower-2
CREATE icon:flower_2 CONTENT {
  identity: {
    value: 'flower_2',
    slug: 'flower-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_flower_2_name,
    label_i18n: i18n_key:icon_flower_2_label,
    keywords: ["flower-2", "sustainability", "nature", "plant"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 652. flower
CREATE icon:flower CONTENT {
  identity: {
    value: 'flower',
    slug: 'flower'
  },
  presentation: {
    name_i18n: i18n_key:icon_flower_name,
    label_i18n: i18n_key:icon_flower_label,
    keywords: ["flower", "sustainability", "nature", "plant", "spring"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 653. focus
CREATE icon:focus CONTENT {
  identity: {
    value: 'focus',
    slug: 'focus'
  },
  presentation: {
    name_i18n: i18n_key:icon_focus_name,
    label_i18n: i18n_key:icon_focus_label,
    keywords: ["focus", "camera", "lens", "photo", "dashed"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 654. fold-horizontal
CREATE icon:fold_horizontal CONTENT {
  identity: {
    value: 'fold_horizontal',
    slug: 'fold-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_fold_horizontal_name,
    label_i18n: i18n_key:icon_fold_horizontal_label,
    keywords: ["fold-horizontal", "arrow", "collapse", "fold", "vertical", "dashed"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 655. fold-vertical
CREATE icon:fold_vertical CONTENT {
  identity: {
    value: 'fold_vertical',
    slug: 'fold-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_fold_vertical_name,
    label_i18n: i18n_key:icon_fold_vertical_label,
    keywords: ["fold-vertical", "arrow", "collapse", "fold", "vertical", "dashed"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 656. folder-archive
CREATE icon:folder_archive CONTENT {
  identity: {
    value: 'folder_archive',
    slug: 'folder-archive'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_archive_name,
    label_i18n: i18n_key:icon_folder_archive_label,
    keywords: ["folder-archive", "archive", "zip", "package"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 657. folder-check
CREATE icon:folder_check CONTENT {
  identity: {
    value: 'folder_check',
    slug: 'folder-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_check_name,
    label_i18n: i18n_key:icon_folder_check_label,
    keywords: ["folder-check", "done", "directory", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 658. folder-clock
CREATE icon:folder_clock CONTENT {
  identity: {
    value: 'folder_clock',
    slug: 'folder-clock'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_clock_name,
    label_i18n: i18n_key:icon_folder_clock_label,
    keywords: ["folder-clock", "history", "directory", "clock"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 659. folder-closed
CREATE icon:folder_closed CONTENT {
  identity: {
    value: 'folder_closed',
    slug: 'folder-closed'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_closed_name,
    label_i18n: i18n_key:icon_folder_closed_label,
    keywords: ["folder-closed", "directory", "closed"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 660. folder-code
CREATE icon:folder_code CONTENT {
  identity: {
    value: 'folder_code',
    slug: 'folder-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_code_name,
    label_i18n: i18n_key:icon_folder_code_label,
    keywords: ["folder-code", "directory", "coding", "develop", "software"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 661. folder-cog
CREATE icon:folder_cog CONTENT {
  identity: {
    value: 'folder_cog',
    slug: 'folder-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_cog_name,
    label_i18n: i18n_key:icon_folder_cog_label,
    keywords: ["folder-cog", "directory", "settings", "control", "preferences", "cog", "edit", "gear"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 662. folder-dot
CREATE icon:folder_dot CONTENT {
  identity: {
    value: 'folder_dot',
    slug: 'folder-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_dot_name,
    label_i18n: i18n_key:icon_folder_dot_label,
    keywords: ["folder-dot", "directory", "root", "project", "pinned", "active", "current", "cogged", "gear", "mechanical", "machinery", "configuration", "controls", "preferences", "settings", "system", "admin", "edit"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 663. folder-down
CREATE icon:folder_down CONTENT {
  identity: {
    value: 'folder_down',
    slug: 'folder-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_down_name,
    label_i18n: i18n_key:icon_folder_down_label,
    keywords: ["folder-down", "directory", "download", "import", "export"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 664. folder-git-2
CREATE icon:folder_git_2 CONTENT {
  identity: {
    value: 'folder_git_2',
    slug: 'folder-git-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_git_2_name,
    label_i18n: i18n_key:icon_folder_git_2_label,
    keywords: ["folder-git-2", "directory", "root", "project", "git", "repo"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 665. folder-git
CREATE icon:folder_git CONTENT {
  identity: {
    value: 'folder_git',
    slug: 'folder-git'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_git_name,
    label_i18n: i18n_key:icon_folder_git_label,
    keywords: ["folder-git", "directory", "root", "project", "git", "repo"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 666. folder-heart
CREATE icon:folder_heart CONTENT {
  identity: {
    value: 'folder_heart',
    slug: 'folder-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_heart_name,
    label_i18n: i18n_key:icon_folder_heart_label,
    keywords: ["folder-heart", "directory", "heart", "favourite", "bookmark", "quick link"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 667. folder-input
CREATE icon:folder_input CONTENT {
  identity: {
    value: 'folder_input',
    slug: 'folder-input'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_input_name,
    label_i18n: i18n_key:icon_folder_input_label,
    keywords: ["folder-input", "directory", "import", "export"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 668. folder-kanban
CREATE icon:folder_kanban CONTENT {
  identity: {
    value: 'folder_kanban',
    slug: 'folder-kanban'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_kanban_name,
    label_i18n: i18n_key:icon_folder_kanban_label,
    keywords: ["folder-kanban", "projects", "manage", "overview", "board", "tickets", "issues", "roadmap", "plan", "intentions", "productivity", "work", "agile", "code", "coding", "directory", "project", "root"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 669. folder-key
CREATE icon:folder_key CONTENT {
  identity: {
    value: 'folder_key',
    slug: 'folder-key'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_key_name,
    label_i18n: i18n_key:icon_folder_key_label,
    keywords: ["folder-key", "directory", "key", "private", "security", "protected"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 670. folder-lock
CREATE icon:folder_lock CONTENT {
  identity: {
    value: 'folder_lock',
    slug: 'folder-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_lock_name,
    label_i18n: i18n_key:icon_folder_lock_label,
    keywords: ["folder-lock", "directory", "lock", "private", "security", "protected"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 671. folder-minus
CREATE icon:folder_minus CONTENT {
  identity: {
    value: 'folder_minus',
    slug: 'folder-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_minus_name,
    label_i18n: i18n_key:icon_folder_minus_label,
    keywords: ["folder-minus", "directory", "remove", "delete"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 672. folder-open-dot
CREATE icon:folder_open_dot CONTENT {
  identity: {
    value: 'folder_open_dot',
    slug: 'folder-open-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_open_dot_name,
    label_i18n: i18n_key:icon_folder_open_dot_label,
    keywords: ["folder-open-dot", "directory", "root", "project", "active", "current", "pinned"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 673. folder-open
CREATE icon:folder_open CONTENT {
  identity: {
    value: 'folder_open',
    slug: 'folder-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_open_name,
    label_i18n: i18n_key:icon_folder_open_label,
    keywords: ["folder-open", "directory"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 674. folder-output
CREATE icon:folder_output CONTENT {
  identity: {
    value: 'folder_output',
    slug: 'folder-output'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_output_name,
    label_i18n: i18n_key:icon_folder_output_label,
    keywords: ["folder-output", "directory", "import", "export"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 675. folder-pen
CREATE icon:folder_pen CONTENT {
  identity: {
    value: 'folder_pen',
    slug: 'folder-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_pen_name,
    label_i18n: i18n_key:icon_folder_pen_label,
    keywords: ["folder-pen", "directory", "rename"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 676. folder-plus
CREATE icon:folder_plus CONTENT {
  identity: {
    value: 'folder_plus',
    slug: 'folder-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_plus_name,
    label_i18n: i18n_key:icon_folder_plus_label,
    keywords: ["folder-plus", "directory", "add", "create", "new"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 677. folder-root
CREATE icon:folder_root CONTENT {
  identity: {
    value: 'folder_root',
    slug: 'folder-root'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_root_name,
    label_i18n: i18n_key:icon_folder_root_label,
    keywords: ["folder-root", "directory", "root", "project", "git", "repo"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 678. folder-search-2
CREATE icon:folder_search_2 CONTENT {
  identity: {
    value: 'folder_search_2',
    slug: 'folder-search-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_search_2_name,
    label_i18n: i18n_key:icon_folder_search_2_label,
    keywords: ["folder-search-2", "directory", "search", "find", "lost", "browser", "lens"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 679. folder-search
CREATE icon:folder_search CONTENT {
  identity: {
    value: 'folder_search',
    slug: 'folder-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_search_name,
    label_i18n: i18n_key:icon_folder_search_label,
    keywords: ["folder-search", "directory", "search", "find", "lost", "browser", "lens"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 680. folder-symlink
CREATE icon:folder_symlink CONTENT {
  identity: {
    value: 'folder_symlink',
    slug: 'folder-symlink'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_symlink_name,
    label_i18n: i18n_key:icon_folder_symlink_label,
    keywords: ["folder-symlink", "directory", "symlink", "symbolic", "link"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 681. folder-sync
CREATE icon:folder_sync CONTENT {
  identity: {
    value: 'folder_sync',
    slug: 'folder-sync'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_sync_name,
    label_i18n: i18n_key:icon_folder_sync_label,
    keywords: ["folder-sync", "directory", "synchronize", "synchronise", "refresh", "reconnect", "transfer", "backup"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 682. folder-tree
CREATE icon:folder_tree CONTENT {
  identity: {
    value: 'folder_tree',
    slug: 'folder-tree'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_tree_name,
    label_i18n: i18n_key:icon_folder_tree_label,
    keywords: ["folder-tree", "directory", "tree", "browser"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 683. folder-up
CREATE icon:folder_up CONTENT {
  identity: {
    value: 'folder_up',
    slug: 'folder-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_up_name,
    label_i18n: i18n_key:icon_folder_up_label,
    keywords: ["folder-up", "directory", "upload", "import", "export"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 684. folder-x
CREATE icon:folder_x CONTENT {
  identity: {
    value: 'folder_x',
    slug: 'folder-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_x_name,
    label_i18n: i18n_key:icon_folder_x_label,
    keywords: ["folder-x", "directory", "remove", "delete"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 685. folder
CREATE icon:folder CONTENT {
  identity: {
    value: 'folder',
    slug: 'folder'
  },
  presentation: {
    name_i18n: i18n_key:icon_folder_name,
    label_i18n: i18n_key:icon_folder_label,
    keywords: ["folder", "directory"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 686. folders
CREATE icon:folders CONTENT {
  identity: {
    value: 'folders',
    slug: 'folders'
  },
  presentation: {
    name_i18n: i18n_key:icon_folders_name,
    label_i18n: i18n_key:icon_folders_label,
    keywords: ["folders", "multiple", "copy", "directories"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 687. footprints
CREATE icon:footprints CONTENT {
  identity: {
    value: 'footprints',
    slug: 'footprints'
  },
  presentation: {
    name_i18n: i18n_key:icon_footprints_name,
    label_i18n: i18n_key:icon_footprints_label,
    keywords: ["footprints", "steps", "walking", "foot", "feet", "trail", "shoe"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 688. forklift
CREATE icon:forklift CONTENT {
  identity: {
    value: 'forklift',
    slug: 'forklift'
  },
  presentation: {
    name_i18n: i18n_key:icon_forklift_name,
    label_i18n: i18n_key:icon_forklift_label,
    keywords: ["forklift", "vehicle", "transport", "logistics"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 689. forward
CREATE icon:forward CONTENT {
  identity: {
    value: 'forward',
    slug: 'forward'
  },
  presentation: {
    name_i18n: i18n_key:icon_forward_name,
    label_i18n: i18n_key:icon_forward_label,
    keywords: ["forward", "send", "share", "email"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 690. frame
CREATE icon:frame CONTENT {
  identity: {
    value: 'frame',
    slug: 'frame'
  },
  presentation: {
    name_i18n: i18n_key:icon_frame_name,
    label_i18n: i18n_key:icon_frame_label,
    keywords: ["frame", "logo", "design", "tool"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 691. framer
CREATE icon:framer CONTENT {
  identity: {
    value: 'framer',
    slug: 'framer'
  },
  presentation: {
    name_i18n: i18n_key:icon_framer_name,
    label_i18n: i18n_key:icon_framer_label,
    keywords: ["framer", "logo", "design", "tool"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 692. frown
CREATE icon:frown CONTENT {
  identity: {
    value: 'frown',
    slug: 'frown'
  },
  presentation: {
    name_i18n: i18n_key:icon_frown_name,
    label_i18n: i18n_key:icon_frown_label,
    keywords: ["frown", "emoji", "face", "bad", "sad", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 693. fuel
CREATE icon:fuel CONTENT {
  identity: {
    value: 'fuel',
    slug: 'fuel'
  },
  presentation: {
    name_i18n: i18n_key:icon_fuel_name,
    label_i18n: i18n_key:icon_fuel_label,
    keywords: ["fuel", "filling-station", "gas", "petrol", "tank"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 694. fullscreen
CREATE icon:fullscreen CONTENT {
  identity: {
    value: 'fullscreen',
    slug: 'fullscreen'
  },
  presentation: {
    name_i18n: i18n_key:icon_fullscreen_name,
    label_i18n: i18n_key:icon_fullscreen_label,
    keywords: ["fullscreen", "expand", "zoom", "preview", "focus", "camera", "lens", "image"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 695. funnel-plus
CREATE icon:funnel_plus CONTENT {
  identity: {
    value: 'funnel_plus',
    slug: 'funnel-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_funnel_plus_name,
    label_i18n: i18n_key:icon_funnel_plus_label,
    keywords: ["funnel-plus", "filter", "hopper", "add", "create", "new"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 696. funnel-x
CREATE icon:funnel_x CONTENT {
  identity: {
    value: 'funnel_x',
    slug: 'funnel-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_funnel_x_name,
    label_i18n: i18n_key:icon_funnel_x_label,
    keywords: ["funnel-x", "filter", "hopper", "remove", "delete"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 697. funnel
CREATE icon:funnel CONTENT {
  identity: {
    value: 'funnel',
    slug: 'funnel'
  },
  presentation: {
    name_i18n: i18n_key:icon_funnel_name,
    label_i18n: i18n_key:icon_funnel_label,
    keywords: ["funnel", "filter", "hopper"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 698. gallery-horizontal-end
CREATE icon:gallery_horizontal_end CONTENT {
  identity: {
    value: 'gallery_horizontal_end',
    slug: 'gallery-horizontal-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_gallery_horizontal_end_name,
    label_i18n: i18n_key:icon_gallery_horizontal_end_label,
    keywords: ["gallery-horizontal-end", "carousel", "pictures", "images", "scroll", "swipe", "album", "portfolio", "history", "versions", "backup", "time machine"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 699. gallery-horizontal
CREATE icon:gallery_horizontal CONTENT {
  identity: {
    value: 'gallery_horizontal',
    slug: 'gallery-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_gallery_horizontal_name,
    label_i18n: i18n_key:icon_gallery_horizontal_label,
    keywords: ["gallery-horizontal", "carousel", "pictures", "images", "scroll", "swipe", "album", "portfolio"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 700. gallery-thumbnails
CREATE icon:gallery_thumbnails CONTENT {
  identity: {
    value: 'gallery_thumbnails',
    slug: 'gallery-thumbnails'
  },
  presentation: {
    name_i18n: i18n_key:icon_gallery_thumbnails_name,
    label_i18n: i18n_key:icon_gallery_thumbnails_label,
    keywords: ["gallery-thumbnails", "carousel", "pictures", "images", "album", "portfolio", "preview"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 701. gallery-vertical-end
CREATE icon:gallery_vertical_end CONTENT {
  identity: {
    value: 'gallery_vertical_end',
    slug: 'gallery-vertical-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_gallery_vertical_end_name,
    label_i18n: i18n_key:icon_gallery_vertical_end_label,
    keywords: ["gallery-vertical-end", "carousel", "pictures", "images", "scroll", "swipe", "album", "portfolio", "history", "versions", "backup", "time machine"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 702. gallery-vertical
CREATE icon:gallery_vertical CONTENT {
  identity: {
    value: 'gallery_vertical',
    slug: 'gallery-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_gallery_vertical_name,
    label_i18n: i18n_key:icon_gallery_vertical_label,
    keywords: ["gallery-vertical", "carousel", "pictures", "images", "scroll", "swipe", "album", "portfolio"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 703. gamepad-2
CREATE icon:gamepad_2 CONTENT {
  identity: {
    value: 'gamepad_2',
    slug: 'gamepad-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_gamepad_2_name,
    label_i18n: i18n_key:icon_gamepad_2_label,
    keywords: ["gamepad-2", "console"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 704. gamepad-directional
CREATE icon:gamepad_directional CONTENT {
  identity: {
    value: 'gamepad_directional',
    slug: 'gamepad-directional'
  },
  presentation: {
    name_i18n: i18n_key:icon_gamepad_directional_name,
    label_i18n: i18n_key:icon_gamepad_directional_label,
    keywords: ["gamepad-directional", "direction", "arrow", "controller", "navigation", "button", "move", "pointer", "arrowhead", "console", "game", "gaming"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 705. gamepad
CREATE icon:gamepad CONTENT {
  identity: {
    value: 'gamepad',
    slug: 'gamepad'
  },
  presentation: {
    name_i18n: i18n_key:icon_gamepad_name,
    label_i18n: i18n_key:icon_gamepad_label,
    keywords: ["gamepad", "console"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 706. gauge
CREATE icon:gauge CONTENT {
  identity: {
    value: 'gauge',
    slug: 'gauge'
  },
  presentation: {
    name_i18n: i18n_key:icon_gauge_name,
    label_i18n: i18n_key:icon_gauge_label,
    keywords: ["gauge", "dashboard", "dial", "meter", "speed", "pressure", "measure", "level"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 707. gavel
CREATE icon:gavel CONTENT {
  identity: {
    value: 'gavel',
    slug: 'gavel'
  },
  presentation: {
    name_i18n: i18n_key:icon_gavel_name,
    label_i18n: i18n_key:icon_gavel_label,
    keywords: ["gavel", "justice", "law", "court", "judgment", "legal", "hands", "penalty", "decision", "authority", "hammer", "mallet"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 708. gem
CREATE icon:gem CONTENT {
  identity: {
    value: 'gem',
    slug: 'gem'
  },
  presentation: {
    name_i18n: i18n_key:icon_gem_name,
    label_i18n: i18n_key:icon_gem_label,
    keywords: ["gem", "diamond", "crystal", "ruby", "jewellery", "price", "special", "present", "gift", "ring", "wedding", "proposal", "marriage", "rubygems"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 709. georgian-lari
CREATE icon:georgian_lari CONTENT {
  identity: {
    value: 'georgian_lari',
    slug: 'georgian-lari'
  },
  presentation: {
    name_i18n: i18n_key:icon_georgian_lari_name,
    label_i18n: i18n_key:icon_georgian_lari_label,
    keywords: ["georgian-lari", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 710. ghost
CREATE icon:ghost CONTENT {
  identity: {
    value: 'ghost',
    slug: 'ghost'
  },
  presentation: {
    name_i18n: i18n_key:icon_ghost_name,
    label_i18n: i18n_key:icon_ghost_label,
    keywords: ["ghost", "pac-man", "spooky"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 711. gift
CREATE icon:gift CONTENT {
  identity: {
    value: 'gift',
    slug: 'gift'
  },
  presentation: {
    name_i18n: i18n_key:icon_gift_name,
    label_i18n: i18n_key:icon_gift_label,
    keywords: ["gift", "present", "box", "birthday", "party"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 712. git-branch-plus
CREATE icon:git_branch_plus CONTENT {
  identity: {
    value: 'git_branch_plus',
    slug: 'git-branch-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_branch_plus_name,
    label_i18n: i18n_key:icon_git_branch_plus_label,
    keywords: ["git-branch-plus", "add", "create", "+"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 713. git-branch
CREATE icon:git_branch CONTENT {
  identity: {
    value: 'git_branch',
    slug: 'git-branch'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_branch_name,
    label_i18n: i18n_key:icon_git_branch_label,
    keywords: ["git-branch", "code", "version control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 714. git-commit-horizontal
CREATE icon:git_commit_horizontal CONTENT {
  identity: {
    value: 'git_commit_horizontal',
    slug: 'git-commit-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_commit_horizontal_name,
    label_i18n: i18n_key:icon_git_commit_horizontal_label,
    keywords: ["git-commit-horizontal", "code", "version control", "waypoint", "stop", "station"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 715. git-commit-vertical
CREATE icon:git_commit_vertical CONTENT {
  identity: {
    value: 'git_commit_vertical',
    slug: 'git-commit-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_commit_vertical_name,
    label_i18n: i18n_key:icon_git_commit_vertical_label,
    keywords: ["git-commit-vertical", "code", "version control", "waypoint", "stop", "station"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 716. git-compare-arrows
CREATE icon:git_compare_arrows CONTENT {
  identity: {
    value: 'git_compare_arrows',
    slug: 'git-compare-arrows'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_compare_arrows_name,
    label_i18n: i18n_key:icon_git_compare_arrows_label,
    keywords: ["git-compare-arrows", "code", "version control", "diff"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 717. git-compare
CREATE icon:git_compare CONTENT {
  identity: {
    value: 'git_compare',
    slug: 'git-compare'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_compare_name,
    label_i18n: i18n_key:icon_git_compare_label,
    keywords: ["git-compare", "code", "version control", "diff"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 718. git-fork
CREATE icon:git_fork CONTENT {
  identity: {
    value: 'git_fork',
    slug: 'git-fork'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_fork_name,
    label_i18n: i18n_key:icon_git_fork_label,
    keywords: ["git-fork", "code", "version control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 719. git-graph
CREATE icon:git_graph CONTENT {
  identity: {
    value: 'git_graph',
    slug: 'git-graph'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_graph_name,
    label_i18n: i18n_key:icon_git_graph_label,
    keywords: ["git-graph", "code", "version control", "commit graph", "commits", "gitlens"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 720. git-merge
CREATE icon:git_merge CONTENT {
  identity: {
    value: 'git_merge',
    slug: 'git-merge'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_merge_name,
    label_i18n: i18n_key:icon_git_merge_label,
    keywords: ["git-merge", "code", "version control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 721. git-pull-request-arrow
CREATE icon:git_pull_request_arrow CONTENT {
  identity: {
    value: 'git_pull_request_arrow',
    slug: 'git-pull-request-arrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_pull_request_arrow_name,
    label_i18n: i18n_key:icon_git_pull_request_arrow_label,
    keywords: ["git-pull-request-arrow", "code", "version control", "open"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 722. git-pull-request-closed
CREATE icon:git_pull_request_closed CONTENT {
  identity: {
    value: 'git_pull_request_closed',
    slug: 'git-pull-request-closed'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_pull_request_closed_name,
    label_i18n: i18n_key:icon_git_pull_request_closed_label,
    keywords: ["git-pull-request-closed", "code", "version control", "rejected", "closed", "cancelled", "x"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 723. git-pull-request-create-arrow
CREATE icon:git_pull_request_create_arrow CONTENT {
  identity: {
    value: 'git_pull_request_create_arrow',
    slug: 'git-pull-request-create-arrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_pull_request_create_arrow_name,
    label_i18n: i18n_key:icon_git_pull_request_create_arrow_label,
    keywords: ["git-pull-request-create-arrow", "code", "version control", "open", "plus", "add", "+"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 724. git-pull-request-create
CREATE icon:git_pull_request_create CONTENT {
  identity: {
    value: 'git_pull_request_create',
    slug: 'git-pull-request-create'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_pull_request_create_name,
    label_i18n: i18n_key:icon_git_pull_request_create_label,
    keywords: ["git-pull-request-create", "code", "version control", "open", "plus", "add", "+"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 725. git-pull-request-draft
CREATE icon:git_pull_request_draft CONTENT {
  identity: {
    value: 'git_pull_request_draft',
    slug: 'git-pull-request-draft'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_pull_request_draft_name,
    label_i18n: i18n_key:icon_git_pull_request_draft_label,
    keywords: ["git-pull-request-draft", "code", "version control", "open", "draft", "dashed"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 726. git-pull-request
CREATE icon:git_pull_request CONTENT {
  identity: {
    value: 'git_pull_request',
    slug: 'git-pull-request'
  },
  presentation: {
    name_i18n: i18n_key:icon_git_pull_request_name,
    label_i18n: i18n_key:icon_git_pull_request_label,
    keywords: ["git-pull-request", "code", "version control", "open"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 727. github
CREATE icon:github CONTENT {
  identity: {
    value: 'github',
    slug: 'github'
  },
  presentation: {
    name_i18n: i18n_key:icon_github_name,
    label_i18n: i18n_key:icon_github_label,
    keywords: ["github", "logo", "version control"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 728. gitlab
CREATE icon:gitlab CONTENT {
  identity: {
    value: 'gitlab',
    slug: 'gitlab'
  },
  presentation: {
    name_i18n: i18n_key:icon_gitlab_name,
    label_i18n: i18n_key:icon_gitlab_label,
    keywords: ["gitlab", "logo", "version control"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 729. glass-water
CREATE icon:glass_water CONTENT {
  identity: {
    value: 'glass_water',
    slug: 'glass-water'
  },
  presentation: {
    name_i18n: i18n_key:icon_glass_water_name,
    label_i18n: i18n_key:icon_glass_water_label,
    keywords: ["glass-water", "beverage", "drink", "glass", "water"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 730. glasses
CREATE icon:glasses CONTENT {
  identity: {
    value: 'glasses',
    slug: 'glasses'
  },
  presentation: {
    name_i18n: i18n_key:icon_glasses_name,
    label_i18n: i18n_key:icon_glasses_label,
    keywords: ["glasses", "glasses", "spectacles"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 731. globe-lock
CREATE icon:globe_lock CONTENT {
  identity: {
    value: 'globe_lock',
    slug: 'globe-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_globe_lock_name,
    label_i18n: i18n_key:icon_globe_lock_label,
    keywords: ["globe-lock", "vpn", "private", "privacy", "network", "world", "browser", "security", "encryption", "protection", "connection"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 732. globe
CREATE icon:globe CONTENT {
  identity: {
    value: 'globe',
    slug: 'globe'
  },
  presentation: {
    name_i18n: i18n_key:icon_globe_name,
    label_i18n: i18n_key:icon_globe_label,
    keywords: ["globe", "world", "browser", "language", "translate"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 733. goal
CREATE icon:goal CONTENT {
  identity: {
    value: 'goal',
    slug: 'goal'
  },
  presentation: {
    name_i18n: i18n_key:icon_goal_name,
    label_i18n: i18n_key:icon_goal_label,
    keywords: ["goal", "flag", "bullseye"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 734. gpu
CREATE icon:gpu CONTENT {
  identity: {
    value: 'gpu',
    slug: 'gpu'
  },
  presentation: {
    name_i18n: i18n_key:icon_gpu_name,
    label_i18n: i18n_key:icon_gpu_label,
    keywords: ["gpu", "processor", "cores", "technology", "computer", "chip", "circuit", "specs", "graphics processing unit", "video card", "display adapter", "gddr", "rendering", "digital image processing", "crypto mining"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 735. graduation-cap
CREATE icon:graduation_cap CONTENT {
  identity: {
    value: 'graduation_cap',
    slug: 'graduation-cap'
  },
  presentation: {
    name_i18n: i18n_key:icon_graduation_cap_name,
    label_i18n: i18n_key:icon_graduation_cap_label,
    keywords: ["graduation-cap", "school", "university", "learn", "study", "mortarboard", "education", "ceremony", "academic", "hat", "diploma", "bachlor's", "master's", "doctorate"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 736. grape
CREATE icon:grape CONTENT {
  identity: {
    value: 'grape',
    slug: 'grape'
  },
  presentation: {
    name_i18n: i18n_key:icon_grape_name,
    label_i18n: i18n_key:icon_grape_label,
    keywords: ["grape", "fruit", "wine", "food"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 737. grid-2x2-check
CREATE icon:grid_2x2_check CONTENT {
  identity: {
    value: 'grid_2x2_check',
    slug: 'grid-2x2-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_grid_2x2_check_name,
    label_i18n: i18n_key:icon_grid_2x2_check_label,
    keywords: ["grid-2x2-check", "table", "rows", "columns", "blocks", "plot", "land", "geometry", "measure", "data", "size", "width", "height", "distance", "surface area", "square meter", "acre"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 738. grid-2x2-plus
CREATE icon:grid_2x2_plus CONTENT {
  identity: {
    value: 'grid_2x2_plus',
    slug: 'grid-2x2-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_grid_2x2_plus_name,
    label_i18n: i18n_key:icon_grid_2x2_plus_label,
    keywords: ["grid-2x2-plus", "table", "rows", "columns", "blocks", "plot", "land", "geometry", "measure", "data", "size", "width", "height", "distance", "surface area", "square meter", "acre"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 739. grid-2x2-x
CREATE icon:grid_2x2_x CONTENT {
  identity: {
    value: 'grid_2x2_x',
    slug: 'grid-2x2-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_grid_2x2_x_name,
    label_i18n: i18n_key:icon_grid_2x2_x_label,
    keywords: ["grid-2x2-x", "table", "rows", "columns", "data", "blocks", "plot", "land", "geometry", "measure", "size", "width", "height", "distance", "surface area", "square meter", "acre"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 740. grid-2x2
CREATE icon:grid_2x2 CONTENT {
  identity: {
    value: 'grid_2x2',
    slug: 'grid-2x2'
  },
  presentation: {
    name_i18n: i18n_key:icon_grid_2x2_name,
    label_i18n: i18n_key:icon_grid_2x2_label,
    keywords: ["grid-2x2", "table", "rows", "columns", "blocks", "plot", "land", "geometry", "measure", "size", "width", "height", "distance", "surface area", "square meter", "acre", "window", "skylight"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 741. grid-3x2
CREATE icon:grid_3x2 CONTENT {
  identity: {
    value: 'grid_3x2',
    slug: 'grid-3x2'
  },
  presentation: {
    name_i18n: i18n_key:icon_grid_3x2_name,
    label_i18n: i18n_key:icon_grid_3x2_label,
    keywords: ["grid-3x2", "table", "rows", "columns", "blocks", "plot", "land", "geometry", "measure", "size", "width", "height", "distance", "surface area", "square meter", "acre", "window"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 742. grid-3x3
CREATE icon:grid_3x3 CONTENT {
  identity: {
    value: 'grid_3x3',
    slug: 'grid-3x3'
  },
  presentation: {
    name_i18n: i18n_key:icon_grid_3x3_name,
    label_i18n: i18n_key:icon_grid_3x3_label,
    keywords: ["grid-3x3", "table", "rows", "columns"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 743. grip-horizontal
CREATE icon:grip_horizontal CONTENT {
  identity: {
    value: 'grip_horizontal',
    slug: 'grip-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_grip_horizontal_name,
    label_i18n: i18n_key:icon_grip_horizontal_label,
    keywords: ["grip-horizontal", "grab", "dots", "handle", "move", "drag"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 744. grip-vertical
CREATE icon:grip_vertical CONTENT {
  identity: {
    value: 'grip_vertical',
    slug: 'grip-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_grip_vertical_name,
    label_i18n: i18n_key:icon_grip_vertical_label,
    keywords: ["grip-vertical", "grab", "dots", "handle", "move", "drag"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 745. grip
CREATE icon:grip CONTENT {
  identity: {
    value: 'grip',
    slug: 'grip'
  },
  presentation: {
    name_i18n: i18n_key:icon_grip_name,
    label_i18n: i18n_key:icon_grip_label,
    keywords: ["grip", "grab", "dots", "handle", "move", "drag"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 746. group
CREATE icon:group CONTENT {
  identity: {
    value: 'group',
    slug: 'group'
  },
  presentation: {
    name_i18n: i18n_key:icon_group_name,
    label_i18n: i18n_key:icon_group_label,
    keywords: ["group", "cubes", "packages", "parts", "units", "collection", "cluster", "gather", "dashed"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 747. guitar
CREATE icon:guitar CONTENT {
  identity: {
    value: 'guitar',
    slug: 'guitar'
  },
  presentation: {
    name_i18n: i18n_key:icon_guitar_name,
    label_i18n: i18n_key:icon_guitar_label,
    keywords: ["guitar", "acoustic", "instrument", "strings", "riff", "rock", "band", "country", "concert", "performance", "play", "lead", "loud", "music", "audio", "sound", "noise"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 748. ham
CREATE icon:ham CONTENT {
  identity: {
    value: 'ham',
    slug: 'ham'
  },
  presentation: {
    name_i18n: i18n_key:icon_ham_name,
    label_i18n: i18n_key:icon_ham_label,
    keywords: ["ham", "food", "pork", "pig", "meat", "bone", "hock", "knuckle", "gammon", "cured"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 749. hamburger
CREATE icon:hamburger CONTENT {
  identity: {
    value: 'hamburger',
    slug: 'hamburger'
  },
  presentation: {
    name_i18n: i18n_key:icon_hamburger_name,
    label_i18n: i18n_key:icon_hamburger_label,
    keywords: ["hamburger", "burger", "cheeseburger", "meat", "beef", "patty", "bun", "fast food", "junk food", "takeaway", "takeout", "snack", "dish", "restaurant", "lunch", "meal", "savory", "savoury", "cookery", "cooking", "grilled", "barbecue", "barbeque", "bbq", "lettuce", "tomato", "relish", "pickles", "onions", "ketchup", "mustard", "mayonnaise"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 750. hammer
CREATE icon:hammer CONTENT {
  identity: {
    value: 'hammer',
    slug: 'hammer'
  },
  presentation: {
    name_i18n: i18n_key:icon_hammer_name,
    label_i18n: i18n_key:icon_hammer_label,
    keywords: ["hammer", "mallet", "nails", "diy", "toolbox", "build", "construction"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 751. hand-coins
CREATE icon:hand_coins CONTENT {
  identity: {
    value: 'hand_coins',
    slug: 'hand-coins'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_coins_name,
    label_i18n: i18n_key:icon_hand_coins_label,
    keywords: ["hand-coins", "savings", "banking", "money", "finance", "offers", "mortgage", "payment", "received", "wage", "payroll", "allowance", "pocket money", "handout", "pennies"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 752. hand-fist
CREATE icon:hand_fist CONTENT {
  identity: {
    value: 'hand_fist',
    slug: 'hand-fist'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_fist_name,
    label_i18n: i18n_key:icon_hand_fist_label,
    keywords: ["hand-fist", "clench", "strength", "power", "unity", "solidarity", "rebellion", "victory", "triumph", "support", "fight", "combat", "brawl"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 753. hand-grab
CREATE icon:hand_grab CONTENT {
  identity: {
    value: 'hand_grab',
    slug: 'hand-grab'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_grab_name,
    label_i18n: i18n_key:icon_hand_grab_label,
    keywords: ["hand-grab", "hand"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 754. hand-heart
CREATE icon:hand_heart CONTENT {
  identity: {
    value: 'hand_heart',
    slug: 'hand-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_heart_name,
    label_i18n: i18n_key:icon_hand_heart_label,
    keywords: ["hand-heart", "love", "like", "emotion"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 755. hand-helping
CREATE icon:hand_helping CONTENT {
  identity: {
    value: 'hand_helping',
    slug: 'hand-helping'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_helping_name,
    label_i18n: i18n_key:icon_hand_helping_label,
    keywords: ["hand-helping", "agreement", "help", "proposal", "charity", "begging", "terms"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 756. hand-metal
CREATE icon:hand_metal CONTENT {
  identity: {
    value: 'hand_metal',
    slug: 'hand-metal'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_metal_name,
    label_i18n: i18n_key:icon_hand_metal_label,
    keywords: ["hand-metal", "rock"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 757. hand-platter
CREATE icon:hand_platter CONTENT {
  identity: {
    value: 'hand_platter',
    slug: 'hand-platter'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_platter_name,
    label_i18n: i18n_key:icon_hand_platter_label,
    keywords: ["hand-platter", "waiter", "waitress", "restaurant", "table service", "served", "dinner", "dining", "meal", "course", "luxury"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 758. hand
CREATE icon:hand CONTENT {
  identity: {
    value: 'hand',
    slug: 'hand'
  },
  presentation: {
    name_i18n: i18n_key:icon_hand_name,
    label_i18n: i18n_key:icon_hand_label,
    keywords: ["hand", "wave", "move", "mouse", "grab"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 759. handbag
CREATE icon:handbag CONTENT {
  identity: {
    value: 'handbag',
    slug: 'handbag'
  },
  presentation: {
    name_i18n: i18n_key:icon_handbag_name,
    label_i18n: i18n_key:icon_handbag_label,
    keywords: ["handbag", "bag", "baggage", "carry", "clutch", "fashion", "luggage", "purse", "tote", "travel"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 760. handshake
CREATE icon:handshake CONTENT {
  identity: {
    value: 'handshake',
    slug: 'handshake'
  },
  presentation: {
    name_i18n: i18n_key:icon_handshake_name,
    label_i18n: i18n_key:icon_handshake_label,
    keywords: ["handshake", "agreement", "partnership", "deal", "business", "assistance", "cooperation", "friendship", "union", "terms"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 761. hard-drive-download
CREATE icon:hard_drive_download CONTENT {
  identity: {
    value: 'hard_drive_download',
    slug: 'hard-drive-download'
  },
  presentation: {
    name_i18n: i18n_key:icon_hard_drive_download_name,
    label_i18n: i18n_key:icon_hard_drive_download_label,
    keywords: ["hard-drive-download", "computer", "server", "memory", "data", "ssd", "disk", "hard disk", "save"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 762. hard-drive-upload
CREATE icon:hard_drive_upload CONTENT {
  identity: {
    value: 'hard_drive_upload',
    slug: 'hard-drive-upload'
  },
  presentation: {
    name_i18n: i18n_key:icon_hard_drive_upload_name,
    label_i18n: i18n_key:icon_hard_drive_upload_label,
    keywords: ["hard-drive-upload", "computer", "server", "memory", "data", "ssd", "disk", "hard disk", "save"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 763. hard-drive
CREATE icon:hard_drive CONTENT {
  identity: {
    value: 'hard_drive',
    slug: 'hard-drive'
  },
  presentation: {
    name_i18n: i18n_key:icon_hard_drive_name,
    label_i18n: i18n_key:icon_hard_drive_label,
    keywords: ["hard-drive", "computer", "server", "memory", "data", "ssd", "disk", "hard disk"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 764. hard-hat
CREATE icon:hard_hat CONTENT {
  identity: {
    value: 'hard_hat',
    slug: 'hard-hat'
  },
  presentation: {
    name_i18n: i18n_key:icon_hard_hat_name,
    label_i18n: i18n_key:icon_hard_hat_label,
    keywords: ["hard-hat", "helmet", "construction", "safety", "savety"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 765. hash
CREATE icon:hash CONTENT {
  identity: {
    value: 'hash',
    slug: 'hash'
  },
  presentation: {
    name_i18n: i18n_key:icon_hash_name,
    label_i18n: i18n_key:icon_hash_label,
    keywords: ["hash", "hashtag", "number", "pound"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 766. hat-glasses
CREATE icon:hat_glasses CONTENT {
  identity: {
    value: 'hat_glasses',
    slug: 'hat-glasses'
  },
  presentation: {
    name_i18n: i18n_key:icon_hat_glasses_name,
    label_i18n: i18n_key:icon_hat_glasses_label,
    keywords: ["hat-glasses", "incognito", "disguise", "costume", "masked", "anonymous", "anonymity", "privacy", "private browsing", "stealth", "hidden", "undercover", "cloak", "invisible", "ghost", "spy", "agent", "detective", "identity", "cap", "fedora", "spectacles", "shades", "sunglasses", "eyewear"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 767. haze
CREATE icon:haze CONTENT {
  identity: {
    value: 'haze',
    slug: 'haze'
  },
  presentation: {
    name_i18n: i18n_key:icon_haze_name,
    label_i18n: i18n_key:icon_haze_label,
    keywords: ["haze", "mist", "fog"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 768. hdmi-port
CREATE icon:hdmi_port CONTENT {
  identity: {
    value: 'hdmi_port',
    slug: 'hdmi-port'
  },
  presentation: {
    name_i18n: i18n_key:icon_hdmi_port_name,
    label_i18n: i18n_key:icon_hdmi_port_label,
    keywords: ["hdmi-port", "socket", "plug", "slot", "controller", "connector", "interface", "console", "signal", "audio", "video", "visual", "av", "data", "input", "output"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 769. heading-1
CREATE icon:heading_1 CONTENT {
  identity: {
    value: 'heading_1',
    slug: 'heading-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_1_name,
    label_i18n: i18n_key:icon_heading_1_label,
    keywords: ["heading-1", "h1", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 770. heading-2
CREATE icon:heading_2 CONTENT {
  identity: {
    value: 'heading_2',
    slug: 'heading-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_2_name,
    label_i18n: i18n_key:icon_heading_2_label,
    keywords: ["heading-2", "h2", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 771. heading-3
CREATE icon:heading_3 CONTENT {
  identity: {
    value: 'heading_3',
    slug: 'heading-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_3_name,
    label_i18n: i18n_key:icon_heading_3_label,
    keywords: ["heading-3", "h3", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 772. heading-4
CREATE icon:heading_4 CONTENT {
  identity: {
    value: 'heading_4',
    slug: 'heading-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_4_name,
    label_i18n: i18n_key:icon_heading_4_label,
    keywords: ["heading-4", "h4", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 773. heading-5
CREATE icon:heading_5 CONTENT {
  identity: {
    value: 'heading_5',
    slug: 'heading-5'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_5_name,
    label_i18n: i18n_key:icon_heading_5_label,
    keywords: ["heading-5", "h5", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 774. heading-6
CREATE icon:heading_6 CONTENT {
  identity: {
    value: 'heading_6',
    slug: 'heading-6'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_6_name,
    label_i18n: i18n_key:icon_heading_6_label,
    keywords: ["heading-6", "h6", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 775. heading
CREATE icon:heading CONTENT {
  identity: {
    value: 'heading',
    slug: 'heading'
  },
  presentation: {
    name_i18n: i18n_key:icon_heading_name,
    label_i18n: i18n_key:icon_heading_label,
    keywords: ["heading", "h1", "html", "markup", "markdown"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 776. headphone-off
CREATE icon:headphone_off CONTENT {
  identity: {
    value: 'headphone_off',
    slug: 'headphone-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_headphone_off_name,
    label_i18n: i18n_key:icon_headphone_off_label,
    keywords: ["headphone-off", "music", "audio", "sound", "mute", "off"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 777. headphones
CREATE icon:headphones CONTENT {
  identity: {
    value: 'headphones',
    slug: 'headphones'
  },
  presentation: {
    name_i18n: i18n_key:icon_headphones_name,
    label_i18n: i18n_key:icon_headphones_label,
    keywords: ["headphones", "music", "audio", "sound"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 778. headset
CREATE icon:headset CONTENT {
  identity: {
    value: 'headset',
    slug: 'headset'
  },
  presentation: {
    name_i18n: i18n_key:icon_headset_name,
    label_i18n: i18n_key:icon_headset_label,
    keywords: ["headset", "music", "audio", "sound", "gaming", "headphones", "headset", "call", "center", "phone", "telephone", "voip", "video"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 779. heart-crack
CREATE icon:heart_crack CONTENT {
  identity: {
    value: 'heart_crack',
    slug: 'heart-crack'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_crack_name,
    label_i18n: i18n_key:icon_heart_crack_label,
    keywords: ["heart-crack", "heartbreak", "sadness", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 780. heart-handshake
CREATE icon:heart_handshake CONTENT {
  identity: {
    value: 'heart_handshake',
    slug: 'heart-handshake'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_handshake_name,
    label_i18n: i18n_key:icon_heart_handshake_label,
    keywords: ["heart-handshake", "agreement", "charity", "help", "deal", "terms", "emotion", "together", "handshake"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 781. heart-minus
CREATE icon:heart_minus CONTENT {
  identity: {
    value: 'heart_minus',
    slug: 'heart-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_minus_name,
    label_i18n: i18n_key:icon_heart_minus_label,
    keywords: ["heart-minus", "unlike", "unfavorite", "remove", "damage", "ui & ux"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 782. heart-off
CREATE icon:heart_off CONTENT {
  identity: {
    value: 'heart_off',
    slug: 'heart-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_off_name,
    label_i18n: i18n_key:icon_heart_off_label,
    keywords: ["heart-off", "unlike", "dislike", "hate", "emotion"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 783. heart-plus
CREATE icon:heart_plus CONTENT {
  identity: {
    value: 'heart_plus',
    slug: 'heart-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_plus_name,
    label_i18n: i18n_key:icon_heart_plus_label,
    keywords: ["heart-plus", "plus", "like", "favorite", "add", "health", "support"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 784. heart-pulse
CREATE icon:heart_pulse CONTENT {
  identity: {
    value: 'heart_pulse',
    slug: 'heart-pulse'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_pulse_name,
    label_i18n: i18n_key:icon_heart_pulse_label,
    keywords: ["heart-pulse", "heartbeat", "pulse", "health", "medical", "blood pressure", "cardiac", "systole", "diastole"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 785. heart
CREATE icon:heart CONTENT {
  identity: {
    value: 'heart',
    slug: 'heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_heart_name,
    label_i18n: i18n_key:icon_heart_label,
    keywords: ["heart", "like", "love", "emotion", "suit", "playing", "cards"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 786. heater
CREATE icon:heater CONTENT {
  identity: {
    value: 'heater',
    slug: 'heater'
  },
  presentation: {
    name_i18n: i18n_key:icon_heater_name,
    label_i18n: i18n_key:icon_heater_label,
    keywords: ["heater", "heating", "warmth", "comfort", "fire", "stove", "electric", "electronics", "amenities"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 787. hexagon
CREATE icon:hexagon CONTENT {
  identity: {
    value: 'hexagon',
    slug: 'hexagon'
  },
  presentation: {
    name_i18n: i18n_key:icon_hexagon_name,
    label_i18n: i18n_key:icon_hexagon_label,
    keywords: ["hexagon", "shape", "node.js", "logo"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 788. highlighter
CREATE icon:highlighter CONTENT {
  identity: {
    value: 'highlighter',
    slug: 'highlighter'
  },
  presentation: {
    name_i18n: i18n_key:icon_highlighter_name,
    label_i18n: i18n_key:icon_highlighter_label,
    keywords: ["highlighter", "mark", "text"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 789. history
CREATE icon:history CONTENT {
  identity: {
    value: 'history',
    slug: 'history'
  },
  presentation: {
    name_i18n: i18n_key:icon_history_name,
    label_i18n: i18n_key:icon_history_label,
    keywords: ["history", "time", "redo", "undo", "rewind", "timeline", "version", "time machine", "backup", "rotate", "ccw"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 790. hop-off
CREATE icon:hop_off CONTENT {
  identity: {
    value: 'hop_off',
    slug: 'hop-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_hop_off_name,
    label_i18n: i18n_key:icon_hop_off_label,
    keywords: ["hop-off", "beer", "brewery", "drink", "hop free", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 791. hop
CREATE icon:hop CONTENT {
  identity: {
    value: 'hop',
    slug: 'hop'
  },
  presentation: {
    name_i18n: i18n_key:icon_hop_name,
    label_i18n: i18n_key:icon_hop_label,
    keywords: ["hop", "beer", "brewery", "drink"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 792. hospital
CREATE icon:hospital CONTENT {
  identity: {
    value: 'hospital',
    slug: 'hospital'
  },
  presentation: {
    name_i18n: i18n_key:icon_hospital_name,
    label_i18n: i18n_key:icon_hospital_label,
    keywords: ["hospital", "infirmary", "sanatorium", "healthcare", "doctor", "hospice", "clinic", "emergency room", "ward", "building", "medical", "vet"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 793. hotel
CREATE icon:hotel CONTENT {
  identity: {
    value: 'hotel',
    slug: 'hotel'
  },
  presentation: {
    name_i18n: i18n_key:icon_hotel_name,
    label_i18n: i18n_key:icon_hotel_label,
    keywords: ["hotel", "building", "hostel", "motel", "inn"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 794. hourglass
CREATE icon:hourglass CONTENT {
  identity: {
    value: 'hourglass',
    slug: 'hourglass'
  },
  presentation: {
    name_i18n: i18n_key:icon_hourglass_name,
    label_i18n: i18n_key:icon_hourglass_label,
    keywords: ["hourglass", "timer", "time", "sandglass"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 795. house-heart
CREATE icon:house_heart CONTENT {
  identity: {
    value: 'house_heart',
    slug: 'house-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_house_heart_name,
    label_i18n: i18n_key:icon_house_heart_label,
    keywords: ["house-heart", "home sweet home", "abode", "building", "residence", "healthy living", "lifestyle"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 796. house-plug
CREATE icon:house_plug CONTENT {
  identity: {
    value: 'house_plug',
    slug: 'house-plug'
  },
  presentation: {
    name_i18n: i18n_key:icon_house_plug_name,
    label_i18n: i18n_key:icon_house_plug_label,
    keywords: ["house-plug", "home", "living", "building", "residence", "architecture", "autarky", "energy"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 797. house-plus
CREATE icon:house_plus CONTENT {
  identity: {
    value: 'house_plus',
    slug: 'house-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_house_plus_name,
    label_i18n: i18n_key:icon_house_plus_label,
    keywords: ["house-plus", "home", "living", "medical", "new", "addition", "building", "residence", "architecture"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 798. house-wifi
CREATE icon:house_wifi CONTENT {
  identity: {
    value: 'house_wifi',
    slug: 'house-wifi'
  },
  presentation: {
    name_i18n: i18n_key:icon_house_wifi_name,
    label_i18n: i18n_key:icon_house_wifi_label,
    keywords: ["house-wifi", "home", "living", "building", "wifi", "connectivity"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 799. house
CREATE icon:house CONTENT {
  identity: {
    value: 'house',
    slug: 'house'
  },
  presentation: {
    name_i18n: i18n_key:icon_house_name,
    label_i18n: i18n_key:icon_house_label,
    keywords: ["house", "home", "living", "building", "residence", "architecture"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 800. ice-cream-bowl
CREATE icon:ice_cream_bowl CONTENT {
  identity: {
    value: 'ice_cream_bowl',
    slug: 'ice-cream-bowl'
  },
  presentation: {
    name_i18n: i18n_key:icon_ice_cream_bowl_name,
    label_i18n: i18n_key:icon_ice_cream_bowl_label,
    keywords: ["ice-cream-bowl", "gelato", "food", "dessert", "dish", "restaurant", "course", "meal"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 801. ice-cream-cone
CREATE icon:ice_cream_cone CONTENT {
  identity: {
    value: 'ice_cream_cone',
    slug: 'ice-cream-cone'
  },
  presentation: {
    name_i18n: i18n_key:icon_ice_cream_cone_name,
    label_i18n: i18n_key:icon_ice_cream_cone_label,
    keywords: ["ice-cream-cone", "gelato", "food"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 802. id-card-lanyard
CREATE icon:id_card_lanyard CONTENT {
  identity: {
    value: 'id_card_lanyard',
    slug: 'id-card-lanyard'
  },
  presentation: {
    name_i18n: i18n_key:icon_id_card_lanyard_name,
    label_i18n: i18n_key:icon_id_card_lanyard_label,
    keywords: ["id-card-lanyard", "id-card", "id-card-lanyard", "identity", "employee", "gate-pass", "badge"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 803. id-card
CREATE icon:id_card CONTENT {
  identity: {
    value: 'id_card',
    slug: 'id-card'
  },
  presentation: {
    name_i18n: i18n_key:icon_id_card_name,
    label_i18n: i18n_key:icon_id_card_label,
    keywords: ["id-card", "card", "badge", "identity", "authentication", "secure"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 804. image-down
CREATE icon:image_down CONTENT {
  identity: {
    value: 'image_down',
    slug: 'image-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_down_name,
    label_i18n: i18n_key:icon_image_down_label,
    keywords: ["image-down", "picture", "photo", "download", "save", "export"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 805. image-minus
CREATE icon:image_minus CONTENT {
  identity: {
    value: 'image_minus',
    slug: 'image-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_minus_name,
    label_i18n: i18n_key:icon_image_minus_label,
    keywords: ["image-minus", "remove", "delete"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 806. image-off
CREATE icon:image_off CONTENT {
  identity: {
    value: 'image_off',
    slug: 'image-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_off_name,
    label_i18n: i18n_key:icon_image_off_label,
    keywords: ["image-off", "picture", "photo"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 807. image-play
CREATE icon:image_play CONTENT {
  identity: {
    value: 'image_play',
    slug: 'image-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_play_name,
    label_i18n: i18n_key:icon_image_play_label,
    keywords: ["image-play", "picture", "gif", "photo"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 808. image-plus
CREATE icon:image_plus CONTENT {
  identity: {
    value: 'image_plus',
    slug: 'image-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_plus_name,
    label_i18n: i18n_key:icon_image_plus_label,
    keywords: ["image-plus", "add", "create", "picture"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 809. image-up
CREATE icon:image_up CONTENT {
  identity: {
    value: 'image_up',
    slug: 'image-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_up_name,
    label_i18n: i18n_key:icon_image_up_label,
    keywords: ["image-up", "picture", "photo", "upload", "import"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 810. image-upscale
CREATE icon:image_upscale CONTENT {
  identity: {
    value: 'image_upscale',
    slug: 'image-upscale'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_upscale_name,
    label_i18n: i18n_key:icon_image_upscale_label,
    keywords: ["image-upscale", "resize", "picture", "sharpen", "increase"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 811. image
CREATE icon:image CONTENT {
  identity: {
    value: 'image',
    slug: 'image'
  },
  presentation: {
    name_i18n: i18n_key:icon_image_name,
    label_i18n: i18n_key:icon_image_label,
    keywords: ["image", "picture", "photo"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 812. images
CREATE icon:images CONTENT {
  identity: {
    value: 'images',
    slug: 'images'
  },
  presentation: {
    name_i18n: i18n_key:icon_images_name,
    label_i18n: i18n_key:icon_images_label,
    keywords: ["images", "picture", "photo", "multiple", "copy", "gallery", "album", "collection", "slideshow", "showcase"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 813. import
CREATE icon:import CONTENT {
  identity: {
    value: 'import',
    slug: 'import'
  },
  presentation: {
    name_i18n: i18n_key:icon_import_name,
    label_i18n: i18n_key:icon_import_label,
    keywords: ["import", "save"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 814. inbox
CREATE icon:inbox CONTENT {
  identity: {
    value: 'inbox',
    slug: 'inbox'
  },
  presentation: {
    name_i18n: i18n_key:icon_inbox_name,
    label_i18n: i18n_key:icon_inbox_label,
    keywords: ["inbox", "email"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 815. indian-rupee
CREATE icon:indian_rupee CONTENT {
  identity: {
    value: 'indian_rupee',
    slug: 'indian-rupee'
  },
  presentation: {
    name_i18n: i18n_key:icon_indian_rupee_name,
    label_i18n: i18n_key:icon_indian_rupee_label,
    keywords: ["indian-rupee", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 816. infinity
CREATE icon:infinity CONTENT {
  identity: {
    value: 'infinity',
    slug: 'infinity'
  },
  presentation: {
    name_i18n: i18n_key:icon_infinity_name,
    label_i18n: i18n_key:icon_infinity_label,
    keywords: ["infinity", "unlimited", "forever", "loop", "math"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 817. info
CREATE icon:info CONTENT {
  identity: {
    value: 'info',
    slug: 'info'
  },
  presentation: {
    name_i18n: i18n_key:icon_info_name,
    label_i18n: i18n_key:icon_info_label,
    keywords: ["info", "help"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 818. inspection-panel
CREATE icon:inspection_panel CONTENT {
  identity: {
    value: 'inspection_panel',
    slug: 'inspection-panel'
  },
  presentation: {
    name_i18n: i18n_key:icon_inspection_panel_name,
    label_i18n: i18n_key:icon_inspection_panel_label,
    keywords: ["inspection-panel", "access", "cover", "tile", "metal", "materials", "screws"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 819. instagram
CREATE icon:instagram CONTENT {
  identity: {
    value: 'instagram',
    slug: 'instagram'
  },
  presentation: {
    name_i18n: i18n_key:icon_instagram_name,
    label_i18n: i18n_key:icon_instagram_label,
    keywords: ["instagram", "logo", "camera", "social"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 820. italic
CREATE icon:italic CONTENT {
  identity: {
    value: 'italic',
    slug: 'italic'
  },
  presentation: {
    name_i18n: i18n_key:icon_italic_name,
    label_i18n: i18n_key:icon_italic_label,
    keywords: ["italic", "oblique", "text", "format"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 821. iteration-ccw
CREATE icon:iteration_ccw CONTENT {
  identity: {
    value: 'iteration_ccw',
    slug: 'iteration-ccw'
  },
  presentation: {
    name_i18n: i18n_key:icon_iteration_ccw_name,
    label_i18n: i18n_key:icon_iteration_ccw_label,
    keywords: ["iteration-ccw", "arrow", "right"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 822. iteration-cw
CREATE icon:iteration_cw CONTENT {
  identity: {
    value: 'iteration_cw',
    slug: 'iteration-cw'
  },
  presentation: {
    name_i18n: i18n_key:icon_iteration_cw_name,
    label_i18n: i18n_key:icon_iteration_cw_label,
    keywords: ["iteration-cw", "arrow", "left"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 823. japanese-yen
CREATE icon:japanese_yen CONTENT {
  identity: {
    value: 'japanese_yen',
    slug: 'japanese-yen'
  },
  presentation: {
    name_i18n: i18n_key:icon_japanese_yen_name,
    label_i18n: i18n_key:icon_japanese_yen_label,
    keywords: ["japanese-yen", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 824. joystick
CREATE icon:joystick CONTENT {
  identity: {
    value: 'joystick',
    slug: 'joystick'
  },
  presentation: {
    name_i18n: i18n_key:icon_joystick_name,
    label_i18n: i18n_key:icon_joystick_label,
    keywords: ["joystick", "game", "console", "control stick"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 825. kanban
CREATE icon:kanban CONTENT {
  identity: {
    value: 'kanban',
    slug: 'kanban'
  },
  presentation: {
    name_i18n: i18n_key:icon_kanban_name,
    label_i18n: i18n_key:icon_kanban_label,
    keywords: ["kanban", "projects", "manage", "overview", "board", "tickets", "issues", "roadmap", "plan", "intentions", "productivity", "work", "agile", "code", "coding"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 826. kayak
CREATE icon:kayak CONTENT {
  identity: {
    value: 'kayak',
    slug: 'kayak'
  },
  presentation: {
    name_i18n: i18n_key:icon_kayak_name,
    label_i18n: i18n_key:icon_kayak_label,
    keywords: ["kayak", "kayak", "boat", "paddle", "water", "sport", "recreation", "adventure", "outdoors", "equipment", "lake", "ocean"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 827. key-round
CREATE icon:key_round CONTENT {
  identity: {
    value: 'key_round',
    slug: 'key-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_key_round_name,
    label_i18n: i18n_key:icon_key_round_label,
    keywords: ["key-round", "password", "login", "authentication", "secure", "unlock"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 828. key-square
CREATE icon:key_square CONTENT {
  identity: {
    value: 'key_square',
    slug: 'key-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_key_square_name,
    label_i18n: i18n_key:icon_key_square_label,
    keywords: ["key-square", "password", "login", "authentication", "secure", "unlock", "car key"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 829. key
CREATE icon:key CONTENT {
  identity: {
    value: 'key',
    slug: 'key'
  },
  presentation: {
    name_i18n: i18n_key:icon_key_name,
    label_i18n: i18n_key:icon_key_label,
    keywords: ["key", "password", "login", "authentication", "secure", "unlock", "keychain", "key ring", "fob"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 830. keyboard-music
CREATE icon:keyboard_music CONTENT {
  identity: {
    value: 'keyboard_music',
    slug: 'keyboard-music'
  },
  presentation: {
    name_i18n: i18n_key:icon_keyboard_music_name,
    label_i18n: i18n_key:icon_keyboard_music_label,
    keywords: ["keyboard-music", "music", "audio", "sound", "noise", "notes", "keys", "chord", "octave", "midi", "controller", "instrument", "electric", "signal", "digital", "studio", "production", "producer", "pianist", "piano", "play", "performance", "concert"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 831. keyboard-off
CREATE icon:keyboard_off CONTENT {
  identity: {
    value: 'keyboard_off',
    slug: 'keyboard-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_keyboard_off_name,
    label_i18n: i18n_key:icon_keyboard_off_label,
    keywords: ["keyboard-off", "unkeys", "layout", "spell", "settings", "mouse"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 832. keyboard
CREATE icon:keyboard CONTENT {
  identity: {
    value: 'keyboard',
    slug: 'keyboard'
  },
  presentation: {
    name_i18n: i18n_key:icon_keyboard_name,
    label_i18n: i18n_key:icon_keyboard_label,
    keywords: ["keyboard", "layout", "spell", "settings", "mouse"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 833. lamp-ceiling
CREATE icon:lamp_ceiling CONTENT {
  identity: {
    value: 'lamp_ceiling',
    slug: 'lamp-ceiling'
  },
  presentation: {
    name_i18n: i18n_key:icon_lamp_ceiling_name,
    label_i18n: i18n_key:icon_lamp_ceiling_label,
    keywords: ["lamp-ceiling", "lighting", "household", "home", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 834. lamp-desk
CREATE icon:lamp_desk CONTENT {
  identity: {
    value: 'lamp_desk',
    slug: 'lamp-desk'
  },
  presentation: {
    name_i18n: i18n_key:icon_lamp_desk_name,
    label_i18n: i18n_key:icon_lamp_desk_label,
    keywords: ["lamp-desk", "lighting", "household", "office", "desk", "home", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 835. lamp-floor
CREATE icon:lamp_floor CONTENT {
  identity: {
    value: 'lamp_floor',
    slug: 'lamp-floor'
  },
  presentation: {
    name_i18n: i18n_key:icon_lamp_floor_name,
    label_i18n: i18n_key:icon_lamp_floor_label,
    keywords: ["lamp-floor", "lighting", "household", "floor", "home", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 836. lamp-wall-down
CREATE icon:lamp_wall_down CONTENT {
  identity: {
    value: 'lamp_wall_down',
    slug: 'lamp-wall-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_lamp_wall_down_name,
    label_i18n: i18n_key:icon_lamp_wall_down_label,
    keywords: ["lamp-wall-down", "lighting", "household", "wall", "home", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 837. lamp-wall-up
CREATE icon:lamp_wall_up CONTENT {
  identity: {
    value: 'lamp_wall_up',
    slug: 'lamp-wall-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_lamp_wall_up_name,
    label_i18n: i18n_key:icon_lamp_wall_up_label,
    keywords: ["lamp-wall-up", "lighting", "household", "wall", "home", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 838. lamp
CREATE icon:lamp CONTENT {
  identity: {
    value: 'lamp',
    slug: 'lamp'
  },
  presentation: {
    name_i18n: i18n_key:icon_lamp_name,
    label_i18n: i18n_key:icon_lamp_label,
    keywords: ["lamp", "lighting", "household", "home", "furniture"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 839. land-plot
CREATE icon:land_plot CONTENT {
  identity: {
    value: 'land_plot',
    slug: 'land-plot'
  },
  presentation: {
    name_i18n: i18n_key:icon_land_plot_name,
    label_i18n: i18n_key:icon_land_plot_label,
    keywords: ["land-plot", "area", "surface", "square metres", "allotment", "parcel", "property", "plane", "acres", "measure", "distance", "isometric", "flag", "golf course", "hole"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 840. landmark
CREATE icon:landmark CONTENT {
  identity: {
    value: 'landmark',
    slug: 'landmark'
  },
  presentation: {
    name_i18n: i18n_key:icon_landmark_name,
    label_i18n: i18n_key:icon_landmark_label,
    keywords: ["landmark", "bank", "building", "capitol", "finance", "money", "museum", "art gallery", "hall", "institute", "pediment", "portico", "columns", "pillars", "classical", "architecture", "government", "institution"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 841. languages
CREATE icon:languages CONTENT {
  identity: {
    value: 'languages',
    slug: 'languages'
  },
  presentation: {
    name_i18n: i18n_key:icon_languages_name,
    label_i18n: i18n_key:icon_languages_label,
    keywords: ["languages", "translate"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 842. laptop-minimal-check
CREATE icon:laptop_minimal_check CONTENT {
  identity: {
    value: 'laptop_minimal_check',
    slug: 'laptop-minimal-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_laptop_minimal_check_name,
    label_i18n: i18n_key:icon_laptop_minimal_check_label,
    keywords: ["laptop-minimal-check", "computer", "screen", "remote", "success", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 843. laptop-minimal
CREATE icon:laptop_minimal CONTENT {
  identity: {
    value: 'laptop_minimal',
    slug: 'laptop-minimal'
  },
  presentation: {
    name_i18n: i18n_key:icon_laptop_minimal_name,
    label_i18n: i18n_key:icon_laptop_minimal_label,
    keywords: ["laptop-minimal", "computer", "screen", "remote"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 844. laptop
CREATE icon:laptop CONTENT {
  identity: {
    value: 'laptop',
    slug: 'laptop'
  },
  presentation: {
    name_i18n: i18n_key:icon_laptop_name,
    label_i18n: i18n_key:icon_laptop_label,
    keywords: ["laptop", "computer", "screen", "remote"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 845. lasso-select
CREATE icon:lasso_select CONTENT {
  identity: {
    value: 'lasso_select',
    slug: 'lasso-select'
  },
  presentation: {
    name_i18n: i18n_key:icon_lasso_select_name,
    label_i18n: i18n_key:icon_lasso_select_label,
    keywords: ["lasso-select", "select", "cursor"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 846. lasso
CREATE icon:lasso CONTENT {
  identity: {
    value: 'lasso',
    slug: 'lasso'
  },
  presentation: {
    name_i18n: i18n_key:icon_lasso_name,
    label_i18n: i18n_key:icon_lasso_label,
    keywords: ["lasso", "select", "cursor"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 847. laugh
CREATE icon:laugh CONTENT {
  identity: {
    value: 'laugh',
    slug: 'laugh'
  },
  presentation: {
    name_i18n: i18n_key:icon_laugh_name,
    label_i18n: i18n_key:icon_laugh_label,
    keywords: ["laugh", "emoji", "face", "happy", "good", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 848. layers-2
CREATE icon:layers_2 CONTENT {
  identity: {
    value: 'layers_2',
    slug: 'layers-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_layers_2_name,
    label_i18n: i18n_key:icon_layers_2_label,
    keywords: ["layers-2", "stack", "pile", "pages", "sheets", "paperwork", "copies", "copy", "duplicate", "double", "shortcuts"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 849. layers
CREATE icon:layers CONTENT {
  identity: {
    value: 'layers',
    slug: 'layers'
  },
  presentation: {
    name_i18n: i18n_key:icon_layers_name,
    label_i18n: i18n_key:icon_layers_label,
    keywords: ["layers", "stack", "pile", "pages", "sheets", "paperwork", "copies", "copy"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 850. layout-dashboard
CREATE icon:layout_dashboard CONTENT {
  identity: {
    value: 'layout_dashboard',
    slug: 'layout-dashboard'
  },
  presentation: {
    name_i18n: i18n_key:icon_layout_dashboard_name,
    label_i18n: i18n_key:icon_layout_dashboard_label,
    keywords: ["layout-dashboard", "masonry", "brick"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 851. layout-grid
CREATE icon:layout_grid CONTENT {
  identity: {
    value: 'layout_grid',
    slug: 'layout-grid'
  },
  presentation: {
    name_i18n: i18n_key:icon_layout_grid_name,
    label_i18n: i18n_key:icon_layout_grid_label,
    keywords: ["layout-grid", "app", "home", "start"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 852. layout-list
CREATE icon:layout_list CONTENT {
  identity: {
    value: 'layout_list',
    slug: 'layout-list'
  },
  presentation: {
    name_i18n: i18n_key:icon_layout_list_name,
    label_i18n: i18n_key:icon_layout_list_label,
    keywords: ["layout-list", "todo", "tasks", "items", "pending", "image", "photo"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 853. layout-panel-left
CREATE icon:layout_panel_left CONTENT {
  identity: {
    value: 'layout_panel_left',
    slug: 'layout-panel-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_layout_panel_left_name,
    label_i18n: i18n_key:icon_layout_panel_left_label,
    keywords: ["layout-panel-left", "app", "home", "start", "grid"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 854. layout-panel-top
CREATE icon:layout_panel_top CONTENT {
  identity: {
    value: 'layout_panel_top',
    slug: 'layout-panel-top'
  },
  presentation: {
    name_i18n: i18n_key:icon_layout_panel_top_name,
    label_i18n: i18n_key:icon_layout_panel_top_label,
    keywords: ["layout-panel-top", "window", "webpage", "block", "section", "grid", "template", "structure"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 855. layout-template
CREATE icon:layout_template CONTENT {
  identity: {
    value: 'layout_template',
    slug: 'layout-template'
  },
  presentation: {
    name_i18n: i18n_key:icon_layout_template_name,
    label_i18n: i18n_key:icon_layout_template_label,
    keywords: ["layout-template", "window", "webpage", "block", "section"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 856. leaf
CREATE icon:leaf CONTENT {
  identity: {
    value: 'leaf',
    slug: 'leaf'
  },
  presentation: {
    name_i18n: i18n_key:icon_leaf_name,
    label_i18n: i18n_key:icon_leaf_label,
    keywords: ["leaf", "sustainability", "nature", "energy", "plant", "autumn"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 857. leafy-green
CREATE icon:leafy_green CONTENT {
  identity: {
    value: 'leafy_green',
    slug: 'leafy-green'
  },
  presentation: {
    name_i18n: i18n_key:icon_leafy_green_name,
    label_i18n: i18n_key:icon_leafy_green_label,
    keywords: ["leafy-green", "salad", "lettuce", "vegetable", "chard", "cabbage", "bok choy"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 858. lectern
CREATE icon:lectern CONTENT {
  identity: {
    value: 'lectern',
    slug: 'lectern'
  },
  presentation: {
    name_i18n: i18n_key:icon_lectern_name,
    label_i18n: i18n_key:icon_lectern_label,
    keywords: ["lectern", "pulpit", "podium", "stand"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 859. library-big
CREATE icon:library_big CONTENT {
  identity: {
    value: 'library_big',
    slug: 'library-big'
  },
  presentation: {
    name_i18n: i18n_key:icon_library_big_name,
    label_i18n: i18n_key:icon_library_big_label,
    keywords: ["library-big", "books", "reading", "written", "authors", "stories", "fiction", "novels", "information", "knowledge", "education", "high school", "university", "college", "academy", "learning", "study", "research", "collection", "vinyl", "records", "albums", "music", "package"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 860. library
CREATE icon:library CONTENT {
  identity: {
    value: 'library',
    slug: 'library'
  },
  presentation: {
    name_i18n: i18n_key:icon_library_name,
    label_i18n: i18n_key:icon_library_label,
    keywords: ["library", "books", "reading", "written", "authors", "stories", "fiction", "novels", "information", "knowledge", "education", "high school", "university", "college", "academy", "learning", "study", "research", "collection", "vinyl", "records", "albums", "music", "package"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 861. life-buoy
CREATE icon:life_buoy CONTENT {
  identity: {
    value: 'life_buoy',
    slug: 'life-buoy'
  },
  presentation: {
    name_i18n: i18n_key:icon_life_buoy_name,
    label_i18n: i18n_key:icon_life_buoy_label,
    keywords: ["life-buoy", "preserver", "life belt", "lifesaver", "help", "rescue", "ship", "ring", "raft", "inflatable", "wheel", "donut"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 862. ligature
CREATE icon:ligature CONTENT {
  identity: {
    value: 'ligature',
    slug: 'ligature'
  },
  presentation: {
    name_i18n: i18n_key:icon_ligature_name,
    label_i18n: i18n_key:icon_ligature_label,
    keywords: ["ligature", "text", "font", "typography", "alternates", "alternatives"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 863. lightbulb-off
CREATE icon:lightbulb_off CONTENT {
  identity: {
    value: 'lightbulb_off',
    slug: 'lightbulb-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_lightbulb_off_name,
    label_i18n: i18n_key:icon_lightbulb_off_label,
    keywords: ["lightbulb-off", "lights"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 864. lightbulb
CREATE icon:lightbulb CONTENT {
  identity: {
    value: 'lightbulb',
    slug: 'lightbulb'
  },
  presentation: {
    name_i18n: i18n_key:icon_lightbulb_name,
    label_i18n: i18n_key:icon_lightbulb_label,
    keywords: ["lightbulb", "idea", "bright", "lights"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 865. line-squiggle
CREATE icon:line_squiggle CONTENT {
  identity: {
    value: 'line_squiggle',
    slug: 'line-squiggle'
  },
  presentation: {
    name_i18n: i18n_key:icon_line_squiggle_name,
    label_i18n: i18n_key:icon_line_squiggle_label,
    keywords: ["line-squiggle", "line", "snakes", "annotate", "curve", "doodle", "stroke", "pen", "tool", "gesture", "draw", "wave", "art", "road"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 866. link-2-off
CREATE icon:link_2_off CONTENT {
  identity: {
    value: 'link_2_off',
    slug: 'link-2-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_link_2_off_name,
    label_i18n: i18n_key:icon_link_2_off_label,
    keywords: ["link-2-off", "unchain", "chain"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 867. link-2
CREATE icon:link_2 CONTENT {
  identity: {
    value: 'link_2',
    slug: 'link-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_link_2_name,
    label_i18n: i18n_key:icon_link_2_label,
    keywords: ["link-2", "chain", "url"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 868. link
CREATE icon:link CONTENT {
  identity: {
    value: 'link',
    slug: 'link'
  },
  presentation: {
    name_i18n: i18n_key:icon_link_name,
    label_i18n: i18n_key:icon_link_label,
    keywords: ["link", "chain", "url"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 869. linkedin
CREATE icon:linkedin CONTENT {
  identity: {
    value: 'linkedin',
    slug: 'linkedin'
  },
  presentation: {
    name_i18n: i18n_key:icon_linkedin_name,
    label_i18n: i18n_key:icon_linkedin_label,
    keywords: ["linkedin", "logo", "social media", "social"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 870. list-check
CREATE icon:list_check CONTENT {
  identity: {
    value: 'list_check',
    slug: 'list-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_check_name,
    label_i18n: i18n_key:icon_list_check_label,
    keywords: ["list-check", "done", "check", "tick", "complete", "list", "to-do", "bom"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 871. list-checks
CREATE icon:list_checks CONTENT {
  identity: {
    value: 'list_checks',
    slug: 'list-checks'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_checks_name,
    label_i18n: i18n_key:icon_list_checks_label,
    keywords: ["list-checks", "todo", "done", "check", "tick", "complete", "tasks", "items", "pending"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 872. list-chevrons-down-up
CREATE icon:list_chevrons_down_up CONTENT {
  identity: {
    value: 'list_chevrons_down_up',
    slug: 'list-chevrons-down-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_chevrons_down_up_name,
    label_i18n: i18n_key:icon_list_chevrons_down_up_label,
    keywords: ["list-chevrons-down-up", "options", "items", "collapse", "expand", "details", "disclosure", "show", "hide", "toggle", "accordion", "more", "less", "fold", "unfold", "vertical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 873. list-chevrons-up-down
CREATE icon:list_chevrons_up_down CONTENT {
  identity: {
    value: 'list_chevrons_up_down',
    slug: 'list-chevrons-up-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_chevrons_up_down_name,
    label_i18n: i18n_key:icon_list_chevrons_up_down_label,
    keywords: ["list-chevrons-up-down", "options", "items", "collapse", "expand", "details", "disclosure", "show", "hide", "toggle", "accordion", "more", "less", "fold", "unfold", "vertical"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 874. list-collapse
CREATE icon:list_collapse CONTENT {
  identity: {
    value: 'list_collapse',
    slug: 'list-collapse'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_collapse_name,
    label_i18n: i18n_key:icon_list_collapse_label,
    keywords: ["list-collapse", "items", "collapse", "expand", "details", "disclosure", "show", "hide", "toggle", "accordion", "more", "less", "fold", "unfold"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 875. list-end
CREATE icon:list_end CONTENT {
  identity: {
    value: 'list_end',
    slug: 'list-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_end_name,
    label_i18n: i18n_key:icon_list_end_label,
    keywords: ["list-end", "queue", "bottom", "end", "playlist"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 876. list-filter-plus
CREATE icon:list_filter_plus CONTENT {
  identity: {
    value: 'list_filter_plus',
    slug: 'list-filter-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_filter_plus_name,
    label_i18n: i18n_key:icon_list_filter_plus_label,
    keywords: ["list-filter-plus", "filter", "plus", "options", "add"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 877. list-filter
CREATE icon:list_filter CONTENT {
  identity: {
    value: 'list_filter',
    slug: 'list-filter'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_filter_name,
    label_i18n: i18n_key:icon_list_filter_label,
    keywords: ["list-filter", "options"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 878. list-indent-decrease
CREATE icon:list_indent_decrease CONTENT {
  identity: {
    value: 'list_indent_decrease',
    slug: 'list-indent-decrease'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_indent_decrease_name,
    label_i18n: i18n_key:icon_list_indent_decrease_label,
    keywords: ["list-indent-decrease", "text", "tab"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 879. list-indent-increase
CREATE icon:list_indent_increase CONTENT {
  identity: {
    value: 'list_indent_increase',
    slug: 'list-indent-increase'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_indent_increase_name,
    label_i18n: i18n_key:icon_list_indent_increase_label,
    keywords: ["list-indent-increase", "text", "tab"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 880. list-minus
CREATE icon:list_minus CONTENT {
  identity: {
    value: 'list_minus',
    slug: 'list-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_minus_name,
    label_i18n: i18n_key:icon_list_minus_label,
    keywords: ["list-minus", "playlist", "remove", "song", "subtract", "delete", "unqueue"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 881. list-music
CREATE icon:list_music CONTENT {
  identity: {
    value: 'list_music',
    slug: 'list-music'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_music_name,
    label_i18n: i18n_key:icon_list_music_label,
    keywords: ["list-music", "playlist", "queue", "music", "audio", "playback"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 882. list-ordered
CREATE icon:list_ordered CONTENT {
  identity: {
    value: 'list_ordered',
    slug: 'list-ordered'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_ordered_name,
    label_i18n: i18n_key:icon_list_ordered_label,
    keywords: ["list-ordered", "number", "order", "queue"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 883. list-plus
CREATE icon:list_plus CONTENT {
  identity: {
    value: 'list_plus',
    slug: 'list-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_plus_name,
    label_i18n: i18n_key:icon_list_plus_label,
    keywords: ["list-plus", "playlist", "add", "song", "track", "new"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 884. list-restart
CREATE icon:list_restart CONTENT {
  identity: {
    value: 'list_restart',
    slug: 'list-restart'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_restart_name,
    label_i18n: i18n_key:icon_list_restart_label,
    keywords: ["list-restart", "reset", "refresh", "reload", "playlist", "replay"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 885. list-start
CREATE icon:list_start CONTENT {
  identity: {
    value: 'list_start',
    slug: 'list-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_start_name,
    label_i18n: i18n_key:icon_list_start_label,
    keywords: ["list-start", "queue", "top", "start", "next", "playlist"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 886. list-todo
CREATE icon:list_todo CONTENT {
  identity: {
    value: 'list_todo',
    slug: 'list-todo'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_todo_name,
    label_i18n: i18n_key:icon_list_todo_label,
    keywords: ["list-todo", "todo", "done", "check", "tick", "complete", "tasks", "items", "pending"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 887. list-tree
CREATE icon:list_tree CONTENT {
  identity: {
    value: 'list_tree',
    slug: 'list-tree'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_tree_name,
    label_i18n: i18n_key:icon_list_tree_label,
    keywords: ["list-tree", "tree", "browser"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 888. list-video
CREATE icon:list_video CONTENT {
  identity: {
    value: 'list_video',
    slug: 'list-video'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_video_name,
    label_i18n: i18n_key:icon_list_video_label,
    keywords: ["list-video", "playlist", "video", "playback"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 889. list-x
CREATE icon:list_x CONTENT {
  identity: {
    value: 'list_x',
    slug: 'list-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_x_name,
    label_i18n: i18n_key:icon_list_x_label,
    keywords: ["list-x", "playlist", "subtract", "remove", "delete", "unqueue"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 890. list
CREATE icon:list CONTENT {
  identity: {
    value: 'list',
    slug: 'list'
  },
  presentation: {
    name_i18n: i18n_key:icon_list_name,
    label_i18n: i18n_key:icon_list_label,
    keywords: ["list", "options"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 891. loader-circle
CREATE icon:loader_circle CONTENT {
  identity: {
    value: 'loader_circle',
    slug: 'loader-circle'
  },
  presentation: {
    name_i18n: i18n_key:icon_loader_circle_name,
    label_i18n: i18n_key:icon_loader_circle_label,
    keywords: ["loader-circle", "loading", "wait", "busy", "progress", "spinner", "spinning", "throbber", "circle"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 892. loader-pinwheel
CREATE icon:loader_pinwheel CONTENT {
  identity: {
    value: 'loader_pinwheel',
    slug: 'loader-pinwheel'
  },
  presentation: {
    name_i18n: i18n_key:icon_loader_pinwheel_name,
    label_i18n: i18n_key:icon_loader_pinwheel_label,
    keywords: ["loader-pinwheel", "loading", "wait", "busy", "progress", "throbber", "spinner", "spinning", "beach ball", "frozen", "freeze"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 893. loader
CREATE icon:loader CONTENT {
  identity: {
    value: 'loader',
    slug: 'loader'
  },
  presentation: {
    name_i18n: i18n_key:icon_loader_name,
    label_i18n: i18n_key:icon_loader_label,
    keywords: ["loader", "loading", "wait", "busy", "progress", "spinner", "spinning", "throbber"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 894. locate-fixed
CREATE icon:locate_fixed CONTENT {
  identity: {
    value: 'locate_fixed',
    slug: 'locate-fixed'
  },
  presentation: {
    name_i18n: i18n_key:icon_locate_fixed_name,
    label_i18n: i18n_key:icon_locate_fixed_label,
    keywords: ["locate-fixed", "map", "gps", "location", "cross"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 895. locate-off
CREATE icon:locate_off CONTENT {
  identity: {
    value: 'locate_off',
    slug: 'locate-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_locate_off_name,
    label_i18n: i18n_key:icon_locate_off_label,
    keywords: ["locate-off", "map", "gps", "location", "cross"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 896. locate
CREATE icon:locate CONTENT {
  identity: {
    value: 'locate',
    slug: 'locate'
  },
  presentation: {
    name_i18n: i18n_key:icon_locate_name,
    label_i18n: i18n_key:icon_locate_label,
    keywords: ["locate", "map", "gps", "location", "cross"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 897. lock-keyhole-open
CREATE icon:lock_keyhole_open CONTENT {
  identity: {
    value: 'lock_keyhole_open',
    slug: 'lock-keyhole-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_lock_keyhole_open_name,
    label_i18n: i18n_key:icon_lock_keyhole_open_label,
    keywords: ["lock-keyhole-open", "security"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 898. lock-keyhole
CREATE icon:lock_keyhole CONTENT {
  identity: {
    value: 'lock_keyhole',
    slug: 'lock-keyhole'
  },
  presentation: {
    name_i18n: i18n_key:icon_lock_keyhole_name,
    label_i18n: i18n_key:icon_lock_keyhole_label,
    keywords: ["lock-keyhole", "security", "password", "secure", "admin"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 899. lock-open
CREATE icon:lock_open CONTENT {
  identity: {
    value: 'lock_open',
    slug: 'lock-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_lock_open_name,
    label_i18n: i18n_key:icon_lock_open_label,
    keywords: ["lock-open", "security"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 900. lock
CREATE icon:lock CONTENT {
  identity: {
    value: 'lock',
    slug: 'lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_lock_name,
    label_i18n: i18n_key:icon_lock_label,
    keywords: ["lock", "security", "password", "secure", "admin"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 901. log-in
CREATE icon:log_in CONTENT {
  identity: {
    value: 'log_in',
    slug: 'log-in'
  },
  presentation: {
    name_i18n: i18n_key:icon_log_in_name,
    label_i18n: i18n_key:icon_log_in_label,
    keywords: ["log-in", "sign in", "arrow", "enter", "auth"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 902. log-out
CREATE icon:log_out CONTENT {
  identity: {
    value: 'log_out',
    slug: 'log-out'
  },
  presentation: {
    name_i18n: i18n_key:icon_log_out_name,
    label_i18n: i18n_key:icon_log_out_label,
    keywords: ["log-out", "sign out", "arrow", "exit", "auth"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 903. logs
CREATE icon:logs CONTENT {
  identity: {
    value: 'logs',
    slug: 'logs'
  },
  presentation: {
    name_i18n: i18n_key:icon_logs_name,
    label_i18n: i18n_key:icon_logs_label,
    keywords: ["logs", "options", "list", "menu", "order", "queue", "tasks", "logs"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 904. lollipop
CREATE icon:lollipop CONTENT {
  identity: {
    value: 'lollipop',
    slug: 'lollipop'
  },
  presentation: {
    name_i18n: i18n_key:icon_lollipop_name,
    label_i18n: i18n_key:icon_lollipop_label,
    keywords: ["lollipop", "lolly", "candy", "sugar", "food", "sweet", "dessert", "spiral"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 905. luggage
CREATE icon:luggage CONTENT {
  identity: {
    value: 'luggage',
    slug: 'luggage'
  },
  presentation: {
    name_i18n: i18n_key:icon_luggage_name,
    label_i18n: i18n_key:icon_luggage_label,
    keywords: ["luggage", "baggage", "luggage", "travel", "suitcase"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 906. magnet
CREATE icon:magnet CONTENT {
  identity: {
    value: 'magnet',
    slug: 'magnet'
  },
  presentation: {
    name_i18n: i18n_key:icon_magnet_name,
    label_i18n: i18n_key:icon_magnet_label,
    keywords: ["magnet", "horseshoe", "lock", "science", "snap"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 907. mail-check
CREATE icon:mail_check CONTENT {
  identity: {
    value: 'mail_check',
    slug: 'mail-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_check_name,
    label_i18n: i18n_key:icon_mail_check_label,
    keywords: ["mail-check", "email", "message", "letter", "subscribe", "delivered", "success", "read", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 908. mail-minus
CREATE icon:mail_minus CONTENT {
  identity: {
    value: 'mail_minus',
    slug: 'mail-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_minus_name,
    label_i18n: i18n_key:icon_mail_minus_label,
    keywords: ["mail-minus", "email", "message", "letter", "remove", "delete"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 909. mail-open
CREATE icon:mail_open CONTENT {
  identity: {
    value: 'mail_open',
    slug: 'mail-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_open_name,
    label_i18n: i18n_key:icon_mail_open_label,
    keywords: ["mail-open", "email", "message", "letter", "read"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 910. mail-plus
CREATE icon:mail_plus CONTENT {
  identity: {
    value: 'mail_plus',
    slug: 'mail-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_plus_name,
    label_i18n: i18n_key:icon_mail_plus_label,
    keywords: ["mail-plus", "email", "message", "letter", "add", "create", "new", "compose"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 911. mail-question-mark
CREATE icon:mail_question_mark CONTENT {
  identity: {
    value: 'mail_question_mark',
    slug: 'mail-question-mark'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_question_mark_name,
    label_i18n: i18n_key:icon_mail_question_mark_label,
    keywords: ["mail-question-mark", "email", "message", "letter", "delivery", "undelivered"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 912. mail-search
CREATE icon:mail_search CONTENT {
  identity: {
    value: 'mail_search',
    slug: 'mail-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_search_name,
    label_i18n: i18n_key:icon_mail_search_label,
    keywords: ["mail-search", "email", "message", "letter", "search", "lens"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 913. mail-warning
CREATE icon:mail_warning CONTENT {
  identity: {
    value: 'mail_warning',
    slug: 'mail-warning'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_warning_name,
    label_i18n: i18n_key:icon_mail_warning_label,
    keywords: ["mail-warning", "email", "message", "letter", "delivery error", "exclamation mark"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 914. mail-x
CREATE icon:mail_x CONTENT {
  identity: {
    value: 'mail_x',
    slug: 'mail-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_x_name,
    label_i18n: i18n_key:icon_mail_x_label,
    keywords: ["mail-x", "email", "message", "letter", "remove", "delete"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 915. mail
CREATE icon:mail CONTENT {
  identity: {
    value: 'mail',
    slug: 'mail'
  },
  presentation: {
    name_i18n: i18n_key:icon_mail_name,
    label_i18n: i18n_key:icon_mail_label,
    keywords: ["mail", "email", "message", "letter", "unread"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 916. mailbox
CREATE icon:mailbox CONTENT {
  identity: {
    value: 'mailbox',
    slug: 'mailbox'
  },
  presentation: {
    name_i18n: i18n_key:icon_mailbox_name,
    label_i18n: i18n_key:icon_mailbox_label,
    keywords: ["mailbox", "emails", "messages", "letters", "mailing list", "newsletter"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 917. mails
CREATE icon:mails CONTENT {
  identity: {
    value: 'mails',
    slug: 'mails'
  },
  presentation: {
    name_i18n: i18n_key:icon_mails_name,
    label_i18n: i18n_key:icon_mails_label,
    keywords: ["mails", "emails", "messages", "letters", "multiple", "mailing list", "newsletter", "copy"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 918. map-minus
CREATE icon:map_minus CONTENT {
  identity: {
    value: 'map_minus',
    slug: 'map-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_minus_name,
    label_i18n: i18n_key:icon_map_minus_label,
    keywords: ["map-minus", "location", "navigation", "travel", "drop", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 919. map-pin-check-inside
CREATE icon:map_pin_check_inside CONTENT {
  identity: {
    value: 'map_pin_check_inside',
    slug: 'map-pin-check-inside'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_check_inside_name,
    label_i18n: i18n_key:icon_map_pin_check_inside_label,
    keywords: ["map-pin-check-inside", "location", "waypoint", "marker", "drop", "done", "tick", "complete", "task", "added"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 920. map-pin-check
CREATE icon:map_pin_check CONTENT {
  identity: {
    value: 'map_pin_check',
    slug: 'map-pin-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_check_name,
    label_i18n: i18n_key:icon_map_pin_check_label,
    keywords: ["map-pin-check", "location", "waypoint", "marker", "drop", "done", "tick", "complete", "task", "added"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 921. map-pin-house
CREATE icon:map_pin_house CONTENT {
  identity: {
    value: 'map_pin_house',
    slug: 'map-pin-house'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_house_name,
    label_i18n: i18n_key:icon_map_pin_house_label,
    keywords: ["map-pin-house", "location", "waypoint", "marker", "drop", "home", "living", "building", "residence", "architecture", "address", "poi", "real estate", "property", "navigation", "destination", "geolocation", "place", "landmark"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 922. map-pin-minus-inside
CREATE icon:map_pin_minus_inside CONTENT {
  identity: {
    value: 'map_pin_minus_inside',
    slug: 'map-pin-minus-inside'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_minus_inside_name,
    label_i18n: i18n_key:icon_map_pin_minus_inside_label,
    keywords: ["map-pin-minus-inside", "location", "waypoint", "marker", "drop", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 923. map-pin-minus
CREATE icon:map_pin_minus CONTENT {
  identity: {
    value: 'map_pin_minus',
    slug: 'map-pin-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_minus_name,
    label_i18n: i18n_key:icon_map_pin_minus_label,
    keywords: ["map-pin-minus", "location", "waypoint", "marker", "drop", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 924. map-pin-off
CREATE icon:map_pin_off CONTENT {
  identity: {
    value: 'map_pin_off',
    slug: 'map-pin-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_off_name,
    label_i18n: i18n_key:icon_map_pin_off_label,
    keywords: ["map-pin-off", "location", "waypoint", "marker", "remove"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 925. map-pin-pen
CREATE icon:map_pin_pen CONTENT {
  identity: {
    value: 'map_pin_pen',
    slug: 'map-pin-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_pen_name,
    label_i18n: i18n_key:icon_map_pin_pen_label,
    keywords: ["map-pin-pen", "location", "waypoint", "marker", "drop", "edit"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 926. map-pin-plus-inside
CREATE icon:map_pin_plus_inside CONTENT {
  identity: {
    value: 'map_pin_plus_inside',
    slug: 'map-pin-plus-inside'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_plus_inside_name,
    label_i18n: i18n_key:icon_map_pin_plus_inside_label,
    keywords: ["map-pin-plus-inside", "location", "waypoint", "marker", "drop", "add", "create", "new"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 927. map-pin-plus
CREATE icon:map_pin_plus CONTENT {
  identity: {
    value: 'map_pin_plus',
    slug: 'map-pin-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_plus_name,
    label_i18n: i18n_key:icon_map_pin_plus_label,
    keywords: ["map-pin-plus", "location", "waypoint", "marker", "drop", "add", "create", "new"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 928. map-pin-x-inside
CREATE icon:map_pin_x_inside CONTENT {
  identity: {
    value: 'map_pin_x_inside',
    slug: 'map-pin-x-inside'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_x_inside_name,
    label_i18n: i18n_key:icon_map_pin_x_inside_label,
    keywords: ["map-pin-x-inside", "location", "waypoint", "marker", "drop", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 929. map-pin-x
CREATE icon:map_pin_x CONTENT {
  identity: {
    value: 'map_pin_x',
    slug: 'map-pin-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_x_name,
    label_i18n: i18n_key:icon_map_pin_x_label,
    keywords: ["map-pin-x", "location", "waypoint", "marker", "drop", "delete", "remove", "erase"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 930. map-pin
CREATE icon:map_pin CONTENT {
  identity: {
    value: 'map_pin',
    slug: 'map-pin'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pin_name,
    label_i18n: i18n_key:icon_map_pin_label,
    keywords: ["map-pin", "location", "waypoint", "marker", "drop"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 931. map-pinned
CREATE icon:map_pinned CONTENT {
  identity: {
    value: 'map_pinned',
    slug: 'map-pinned'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_pinned_name,
    label_i18n: i18n_key:icon_map_pinned_label,
    keywords: ["map-pinned", "location", "waypoint", "marker", "drop"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 932. map-plus
CREATE icon:map_plus CONTENT {
  identity: {
    value: 'map_plus',
    slug: 'map-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_plus_name,
    label_i18n: i18n_key:icon_map_plus_label,
    keywords: ["map-plus", "location", "navigation", "travel", "new", "add", "create"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 933. map
CREATE icon:map CONTENT {
  identity: {
    value: 'map',
    slug: 'map'
  },
  presentation: {
    name_i18n: i18n_key:icon_map_name,
    label_i18n: i18n_key:icon_map_label,
    keywords: ["map", "location", "navigation", "travel"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 934. mars-stroke
CREATE icon:mars_stroke CONTENT {
  identity: {
    value: 'mars_stroke',
    slug: 'mars-stroke'
  },
  presentation: {
    name_i18n: i18n_key:icon_mars_stroke_name,
    label_i18n: i18n_key:icon_mars_stroke_label,
    keywords: ["mars-stroke", "gender", "androgyne", "transgender"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 935. mars
CREATE icon:mars CONTENT {
  identity: {
    value: 'mars',
    slug: 'mars'
  },
  presentation: {
    name_i18n: i18n_key:icon_mars_name,
    label_i18n: i18n_key:icon_mars_label,
    keywords: ["mars", "gender", "sex", "male", "masculine", "man", "boy"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 936. martini
CREATE icon:martini CONTENT {
  identity: {
    value: 'martini',
    slug: 'martini'
  },
  presentation: {
    name_i18n: i18n_key:icon_martini_name,
    label_i18n: i18n_key:icon_martini_label,
    keywords: ["martini", "cocktail", "alcohol", "beverage", "bar", "drink", "glass"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 937. maximize-2
CREATE icon:maximize_2 CONTENT {
  identity: {
    value: 'maximize_2',
    slug: 'maximize-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_maximize_2_name,
    label_i18n: i18n_key:icon_maximize_2_label,
    keywords: ["maximize-2", "fullscreen", "arrows", "expand"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 938. maximize
CREATE icon:maximize CONTENT {
  identity: {
    value: 'maximize',
    slug: 'maximize'
  },
  presentation: {
    name_i18n: i18n_key:icon_maximize_name,
    label_i18n: i18n_key:icon_maximize_label,
    keywords: ["maximize", "fullscreen", "expand", "dashed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 939. medal
CREATE icon:medal CONTENT {
  identity: {
    value: 'medal',
    slug: 'medal'
  },
  presentation: {
    name_i18n: i18n_key:icon_medal_name,
    label_i18n: i18n_key:icon_medal_label,
    keywords: ["medal", "prize", "sports", "winner", "trophy", "award", "achievement"]
  },
  context: {
    category: icon_category:sports,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 940. megaphone-off
CREATE icon:megaphone_off CONTENT {
  identity: {
    value: 'megaphone_off',
    slug: 'megaphone-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_megaphone_off_name,
    label_i18n: i18n_key:icon_megaphone_off_label,
    keywords: ["megaphone-off", "advertisement", "announcement", "attention", "alert", "loudspeaker", "megaphone", "notification", "disable", "silent"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 941. megaphone
CREATE icon:megaphone CONTENT {
  identity: {
    value: 'megaphone',
    slug: 'megaphone'
  },
  presentation: {
    name_i18n: i18n_key:icon_megaphone_name,
    label_i18n: i18n_key:icon_megaphone_label,
    keywords: ["megaphone", "advertisement", "announcement", "attention", "alert", "loudspeaker", "megaphone", "notification"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 942. meh
CREATE icon:meh CONTENT {
  identity: {
    value: 'meh',
    slug: 'meh'
  },
  presentation: {
    name_i18n: i18n_key:icon_meh_name,
    label_i18n: i18n_key:icon_meh_label,
    keywords: ["meh", "emoji", "face", "neutral", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 943. memory-stick
CREATE icon:memory_stick CONTENT {
  identity: {
    value: 'memory_stick',
    slug: 'memory-stick'
  },
  presentation: {
    name_i18n: i18n_key:icon_memory_stick_name,
    label_i18n: i18n_key:icon_memory_stick_label,
    keywords: ["memory-stick", "ram", "random access", "technology", "computer", "chip", "circuit", "specs", "capacity", "gigabytes", "gb"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 944. menu
CREATE icon:menu CONTENT {
  identity: {
    value: 'menu',
    slug: 'menu'
  },
  presentation: {
    name_i18n: i18n_key:icon_menu_name,
    label_i18n: i18n_key:icon_menu_label,
    keywords: ["menu", "bars", "navigation", "hamburger", "options"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 945. merge
CREATE icon:merge CONTENT {
  identity: {
    value: 'merge',
    slug: 'merge'
  },
  presentation: {
    name_i18n: i18n_key:icon_merge_name,
    label_i18n: i18n_key:icon_merge_label,
    keywords: ["merge", "combine", "join", "unite"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 946. message-circle-code
CREATE icon:message_circle_code CONTENT {
  identity: {
    value: 'message_circle_code',
    slug: 'message-circle-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_code_name,
    label_i18n: i18n_key:icon_message_circle_code_label,
    keywords: ["message-circle-code", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "code review", "coding"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 947. message-circle-dashed
CREATE icon:message_circle_dashed CONTENT {
  identity: {
    value: 'message_circle_dashed',
    slug: 'message-circle-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_dashed_name,
    label_i18n: i18n_key:icon_message_circle_dashed_label,
    keywords: ["message-circle-dashed", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "draft"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 948. message-circle-heart
CREATE icon:message_circle_heart CONTENT {
  identity: {
    value: 'message_circle_heart',
    slug: 'message-circle-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_heart_name,
    label_i18n: i18n_key:icon_message_circle_heart_label,
    keywords: ["message-circle-heart", "comment", "chat", "conversation", "dialog", "feedback", "positive", "like", "love", "interest", "valentine", "dating", "date", "speech bubble"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 949. message-circle-more
CREATE icon:message_circle_more CONTENT {
  identity: {
    value: 'message_circle_more',
    slug: 'message-circle-more'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_more_name,
    label_i18n: i18n_key:icon_message_circle_more_label,
    keywords: ["message-circle-more", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "typing", "writing", "responding", "ellipsis", "etc", "et cetera", "...", "\u2026"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 950. message-circle-off
CREATE icon:message_circle_off CONTENT {
  identity: {
    value: 'message_circle_off',
    slug: 'message-circle-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_off_name,
    label_i18n: i18n_key:icon_message_circle_off_label,
    keywords: ["message-circle-off", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "clear", "close", "delete", "remove", "cancel", "silence", "mute", "moderate"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 951. message-circle-plus
CREATE icon:message_circle_plus CONTENT {
  identity: {
    value: 'message_circle_plus',
    slug: 'message-circle-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_plus_name,
    label_i18n: i18n_key:icon_message_circle_plus_label,
    keywords: ["message-circle-plus", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "add"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 952. message-circle-question-mark
CREATE icon:message_circle_question_mark CONTENT {
  identity: {
    value: 'message_circle_question_mark',
    slug: 'message-circle-question-mark'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_question_mark_name,
    label_i18n: i18n_key:icon_message_circle_question_mark_label,
    keywords: ["message-circle-question-mark", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "help"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 953. message-circle-reply
CREATE icon:message_circle_reply CONTENT {
  identity: {
    value: 'message_circle_reply',
    slug: 'message-circle-reply'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_reply_name,
    label_i18n: i18n_key:icon_message_circle_reply_label,
    keywords: ["message-circle-reply", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "reply", "response"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 954. message-circle-warning
CREATE icon:message_circle_warning CONTENT {
  identity: {
    value: 'message_circle_warning',
    slug: 'message-circle-warning'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_warning_name,
    label_i18n: i18n_key:icon_message_circle_warning_label,
    keywords: ["message-circle-warning", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "report", "abuse", "offense", "alert", "danger", "caution", "protected", "exclamation mark"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 955. message-circle-x
CREATE icon:message_circle_x CONTENT {
  identity: {
    value: 'message_circle_x',
    slug: 'message-circle-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_x_name,
    label_i18n: i18n_key:icon_message_circle_x_label,
    keywords: ["message-circle-x", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "clear", "close", "delete", "remove", "cancel", "silence", "mute", "moderate"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 956. message-circle
CREATE icon:message_circle CONTENT {
  identity: {
    value: 'message_circle',
    slug: 'message-circle'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_circle_name,
    label_i18n: i18n_key:icon_message_circle_label,
    keywords: ["message-circle", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 957. message-square-code
CREATE icon:message_square_code CONTENT {
  identity: {
    value: 'message_square_code',
    slug: 'message-square-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_code_name,
    label_i18n: i18n_key:icon_message_square_code_label,
    keywords: ["message-square-code", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "code review", "coding"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 958. message-square-dashed
CREATE icon:message_square_dashed CONTENT {
  identity: {
    value: 'message_square_dashed',
    slug: 'message-square-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_dashed_name,
    label_i18n: i18n_key:icon_message_square_dashed_label,
    keywords: ["message-square-dashed", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "draft"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 959. message-square-diff
CREATE icon:message_square_diff CONTENT {
  identity: {
    value: 'message_square_diff',
    slug: 'message-square-diff'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_diff_name,
    label_i18n: i18n_key:icon_message_square_diff_label,
    keywords: ["message-square-diff", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "add", "patch", "difference", "plus", "minus", "plus-minus", "math", "code review", "coding", "version control", "git"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 960. message-square-dot
CREATE icon:message_square_dot CONTENT {
  identity: {
    value: 'message_square_dot',
    slug: 'message-square-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_dot_name,
    label_i18n: i18n_key:icon_message_square_dot_label,
    keywords: ["message-square-dot", "unread", "unresolved", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 961. message-square-heart
CREATE icon:message_square_heart CONTENT {
  identity: {
    value: 'message_square_heart',
    slug: 'message-square-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_heart_name,
    label_i18n: i18n_key:icon_message_square_heart_label,
    keywords: ["message-square-heart", "comment", "chat", "conversation", "dialog", "feedback", "positive", "like", "love", "interest", "valentine", "dating", "date", "speech bubble"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 962. message-square-lock
CREATE icon:message_square_lock CONTENT {
  identity: {
    value: 'message_square_lock',
    slug: 'message-square-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_lock_name,
    label_i18n: i18n_key:icon_message_square_lock_label,
    keywords: ["message-square-lock", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "secure", "encrypted"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 963. message-square-more
CREATE icon:message_square_more CONTENT {
  identity: {
    value: 'message_square_more',
    slug: 'message-square-more'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_more_name,
    label_i18n: i18n_key:icon_message_square_more_label,
    keywords: ["message-square-more", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "typing", "writing", "responding", "ellipsis", "etc", "et cetera", "...", "\u2026"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 964. message-square-off
CREATE icon:message_square_off CONTENT {
  identity: {
    value: 'message_square_off',
    slug: 'message-square-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_off_name,
    label_i18n: i18n_key:icon_message_square_off_label,
    keywords: ["message-square-off", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "clear", "close", "delete", "remove", "cancel", "silence", "mute", "moderate"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 965. message-square-plus
CREATE icon:message_square_plus CONTENT {
  identity: {
    value: 'message_square_plus',
    slug: 'message-square-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_plus_name,
    label_i18n: i18n_key:icon_message_square_plus_label,
    keywords: ["message-square-plus", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "add"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 966. message-square-quote
CREATE icon:message_square_quote CONTENT {
  identity: {
    value: 'message_square_quote',
    slug: 'message-square-quote'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_quote_name,
    label_i18n: i18n_key:icon_message_square_quote_label,
    keywords: ["message-square-quote", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "blockquote", "quotation", "indent", "reply", "response"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 967. message-square-reply
CREATE icon:message_square_reply CONTENT {
  identity: {
    value: 'message_square_reply',
    slug: 'message-square-reply'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_reply_name,
    label_i18n: i18n_key:icon_message_square_reply_label,
    keywords: ["message-square-reply", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "reply", "response"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 968. message-square-share
CREATE icon:message_square_share CONTENT {
  identity: {
    value: 'message_square_share',
    slug: 'message-square-share'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_share_name,
    label_i18n: i18n_key:icon_message_square_share_label,
    keywords: ["message-square-share", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "network", "forward"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 969. message-square-text
CREATE icon:message_square_text CONTENT {
  identity: {
    value: 'message_square_text',
    slug: 'message-square-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_text_name,
    label_i18n: i18n_key:icon_message_square_text_label,
    keywords: ["message-square-text", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 970. message-square-warning
CREATE icon:message_square_warning CONTENT {
  identity: {
    value: 'message_square_warning',
    slug: 'message-square-warning'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_warning_name,
    label_i18n: i18n_key:icon_message_square_warning_label,
    keywords: ["message-square-warning", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "report", "abuse", "offense", "alert", "danger", "caution", "protected", "exclamation mark"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 971. message-square-x
CREATE icon:message_square_x CONTENT {
  identity: {
    value: 'message_square_x',
    slug: 'message-square-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_x_name,
    label_i18n: i18n_key:icon_message_square_x_label,
    keywords: ["message-square-x", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble", "clear", "close", "delete", "remove", "cancel", "silence", "mute", "moderate"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 972. message-square
CREATE icon:message_square CONTENT {
  identity: {
    value: 'message_square',
    slug: 'message-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_message_square_name,
    label_i18n: i18n_key:icon_message_square_label,
    keywords: ["message-square", "comment", "chat", "conversation", "dialog", "feedback", "speech bubble"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 973. messages-square
CREATE icon:messages_square CONTENT {
  identity: {
    value: 'messages_square',
    slug: 'messages-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_messages_square_name,
    label_i18n: i18n_key:icon_messages_square_label,
    keywords: ["messages-square", "comment", "chat", "conversation", "dialog", "feedback", "speech bubbles", "copy", "multiple", "discussion", "interview", "debate"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 974. mic-off
CREATE icon:mic_off CONTENT {
  identity: {
    value: 'mic_off',
    slug: 'mic-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_mic_off_name,
    label_i18n: i18n_key:icon_mic_off_label,
    keywords: ["mic-off", "record", "sound", "mute", "microphone"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 975. mic-vocal
CREATE icon:mic_vocal CONTENT {
  identity: {
    value: 'mic_vocal',
    slug: 'mic-vocal'
  },
  presentation: {
    name_i18n: i18n_key:icon_mic_vocal_name,
    label_i18n: i18n_key:icon_mic_vocal_label,
    keywords: ["mic-vocal", "lyrics", "voice", "listen", "sound", "music", "radio", "podcast", "karaoke", "singing", "microphone"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 976. mic
CREATE icon:mic CONTENT {
  identity: {
    value: 'mic',
    slug: 'mic'
  },
  presentation: {
    name_i18n: i18n_key:icon_mic_name,
    label_i18n: i18n_key:icon_mic_label,
    keywords: ["mic", "record", "sound", "listen", "radio", "podcast", "microphone"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 977. microchip
CREATE icon:microchip CONTENT {
  identity: {
    value: 'microchip',
    slug: 'microchip'
  },
  presentation: {
    name_i18n: i18n_key:icon_microchip_name,
    label_i18n: i18n_key:icon_microchip_label,
    keywords: ["microchip", "processor", "cores", "technology", "computer", "chip", "integrated circuit", "memory", "ram", "specs", "gpu", "gigahertz", "ghz"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 978. microscope
CREATE icon:microscope CONTENT {
  identity: {
    value: 'microscope',
    slug: 'microscope'
  },
  presentation: {
    name_i18n: i18n_key:icon_microscope_name,
    label_i18n: i18n_key:icon_microscope_label,
    keywords: ["microscope", "medical", "education", "science", "imaging", "research"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 979. microwave
CREATE icon:microwave CONTENT {
  identity: {
    value: 'microwave',
    slug: 'microwave'
  },
  presentation: {
    name_i18n: i18n_key:icon_microwave_name,
    label_i18n: i18n_key:icon_microwave_label,
    keywords: ["microwave", "oven", "cooker", "toaster oven", "bake"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 980. milestone
CREATE icon:milestone CONTENT {
  identity: {
    value: 'milestone',
    slug: 'milestone'
  },
  presentation: {
    name_i18n: i18n_key:icon_milestone_name,
    label_i18n: i18n_key:icon_milestone_label,
    keywords: ["milestone", "signpost", "direction", "right", "east", "forward", "version control", "waypoint"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 981. milk-off
CREATE icon:milk_off CONTENT {
  identity: {
    value: 'milk_off',
    slug: 'milk-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_milk_off_name,
    label_i18n: i18n_key:icon_milk_off_label,
    keywords: ["milk-off", "lactose free", "bottle", "beverage", "drink", "water", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 982. milk
CREATE icon:milk CONTENT {
  identity: {
    value: 'milk',
    slug: 'milk'
  },
  presentation: {
    name_i18n: i18n_key:icon_milk_name,
    label_i18n: i18n_key:icon_milk_label,
    keywords: ["milk", "lactose", "bottle", "beverage", "drink", "water", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 983. minimize-2
CREATE icon:minimize_2 CONTENT {
  identity: {
    value: 'minimize_2',
    slug: 'minimize-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_minimize_2_name,
    label_i18n: i18n_key:icon_minimize_2_label,
    keywords: ["minimize-2", "exit fullscreen", "arrows", "close", "shrink"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 984. minimize
CREATE icon:minimize CONTENT {
  identity: {
    value: 'minimize',
    slug: 'minimize'
  },
  presentation: {
    name_i18n: i18n_key:icon_minimize_name,
    label_i18n: i18n_key:icon_minimize_label,
    keywords: ["minimize", "exit fullscreen", "close", "shrink"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 985. minus
CREATE icon:minus CONTENT {
  identity: {
    value: 'minus',
    slug: 'minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_minus_name,
    label_i18n: i18n_key:icon_minus_label,
    keywords: ["minus", "subtract", "remove", "decrease", "decrement", "reduce", "negative", "calculate", "line", "divider", "separator", "horizontal rule", "hr", "html", "markup", "markdown", "---", "toolbar", "operator", "code", "coding", "minimum", "downgrade"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 986. monitor-check
CREATE icon:monitor_check CONTENT {
  identity: {
    value: 'monitor_check',
    slug: 'monitor-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_check_name,
    label_i18n: i18n_key:icon_monitor_check_label,
    keywords: ["monitor-check", "tv", "screen", "display", "desktop", "running", "active", "virtual machine", "vm"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 987. monitor-cloud
CREATE icon:monitor_cloud CONTENT {
  identity: {
    value: 'monitor_cloud',
    slug: 'monitor-cloud'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_cloud_name,
    label_i18n: i18n_key:icon_monitor_cloud_label,
    keywords: ["monitor-cloud", "virtual machine", "virtual desktop", "vm", "vdi", "computing", "remote work", "monitoring", "infrastructure", "software as a service", "saas", "workstation", "environment", "tv", "screen", "display"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 988. monitor-cog
CREATE icon:monitor_cog CONTENT {
  identity: {
    value: 'monitor_cog',
    slug: 'monitor-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_cog_name,
    label_i18n: i18n_key:icon_monitor_cog_label,
    keywords: ["monitor-cog", "tv", "screen", "display", "virtual machine", "vm", "executable", "settings", "cog", "edit", "gear", "configuration", "preferences", "system", "control panel", "network", "computing"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 989. monitor-dot
CREATE icon:monitor_dot CONTENT {
  identity: {
    value: 'monitor_dot',
    slug: 'monitor-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_dot_name,
    label_i18n: i18n_key:icon_monitor_dot_label,
    keywords: ["monitor-dot", "tv", "screen", "display", "desktop", "running", "active", "virtual machine", "vm"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 990. monitor-down
CREATE icon:monitor_down CONTENT {
  identity: {
    value: 'monitor_down',
    slug: 'monitor-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_down_name,
    label_i18n: i18n_key:icon_monitor_down_label,
    keywords: ["monitor-down", "tv", "screen", "display", "desktop", "download"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 991. monitor-off
CREATE icon:monitor_off CONTENT {
  identity: {
    value: 'monitor_off',
    slug: 'monitor-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_off_name,
    label_i18n: i18n_key:icon_monitor_off_label,
    keywords: ["monitor-off", "share"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 992. monitor-pause
CREATE icon:monitor_pause CONTENT {
  identity: {
    value: 'monitor_pause',
    slug: 'monitor-pause'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_pause_name,
    label_i18n: i18n_key:icon_monitor_pause_label,
    keywords: ["monitor-pause", "tv", "screen", "display", "desktop", "video", "movie", "film", "suspend", "hibernate", "boot", "virtual machine", "vm"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 993. monitor-play
CREATE icon:monitor_play CONTENT {
  identity: {
    value: 'monitor_play',
    slug: 'monitor-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_play_name,
    label_i18n: i18n_key:icon_monitor_play_label,
    keywords: ["monitor-play", "tv", "screen", "display", "desktop", "video", "movie", "film", "running", "start", "boot", "virtual machine", "vm"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 994. monitor-smartphone
CREATE icon:monitor_smartphone CONTENT {
  identity: {
    value: 'monitor_smartphone',
    slug: 'monitor-smartphone'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_smartphone_name,
    label_i18n: i18n_key:icon_monitor_smartphone_label,
    keywords: ["monitor-smartphone", "smartphone", "phone", "cellphone", "device", "mobile", "desktop", "monitor", "responsive", "screens"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 995. monitor-speaker
CREATE icon:monitor_speaker CONTENT {
  identity: {
    value: 'monitor_speaker',
    slug: 'monitor-speaker'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_speaker_name,
    label_i18n: i18n_key:icon_monitor_speaker_label,
    keywords: ["monitor-speaker", "devices", "connect", "cast"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 996. monitor-stop
CREATE icon:monitor_stop CONTENT {
  identity: {
    value: 'monitor_stop',
    slug: 'monitor-stop'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_stop_name,
    label_i18n: i18n_key:icon_monitor_stop_label,
    keywords: ["monitor-stop", "tv", "screen", "display", "desktop", "video", "movie", "film", "stop", "shutdown", "virtual machine", "vm"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 997. monitor-up
CREATE icon:monitor_up CONTENT {
  identity: {
    value: 'monitor_up',
    slug: 'monitor-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_up_name,
    label_i18n: i18n_key:icon_monitor_up_label,
    keywords: ["monitor-up", "tv", "screen", "display", "upload", "connect", "remote", "screen share"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 998. monitor-x
CREATE icon:monitor_x CONTENT {
  identity: {
    value: 'monitor_x',
    slug: 'monitor-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_x_name,
    label_i18n: i18n_key:icon_monitor_x_label,
    keywords: ["monitor-x", "tv", "screen", "display", "desktop", "virtual machine", "vm", "close", "stop", "suspend", "remove", "delete"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 999. monitor
CREATE icon:monitor CONTENT {
  identity: {
    value: 'monitor',
    slug: 'monitor'
  },
  presentation: {
    name_i18n: i18n_key:icon_monitor_name,
    label_i18n: i18n_key:icon_monitor_label,
    keywords: ["monitor", "tv", "screen", "display", "virtual machine", "vm"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1000. moon-star
CREATE icon:moon_star CONTENT {
  identity: {
    value: 'moon_star',
    slug: 'moon-star'
  },
  presentation: {
    name_i18n: i18n_key:icon_moon_star_name,
    label_i18n: i18n_key:icon_moon_star_label,
    keywords: ["moon-star", "dark", "night", "star"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1001. moon
CREATE icon:moon CONTENT {
  identity: {
    value: 'moon',
    slug: 'moon'
  },
  presentation: {
    name_i18n: i18n_key:icon_moon_name,
    label_i18n: i18n_key:icon_moon_label,
    keywords: ["moon", "dark", "night"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1002. motorbike
CREATE icon:motorbike CONTENT {
  identity: {
    value: 'motorbike',
    slug: 'motorbike'
  },
  presentation: {
    name_i18n: i18n_key:icon_motorbike_name,
    label_i18n: i18n_key:icon_motorbike_label,
    keywords: ["motorbike", "moto", "motorcycle", "transport", "vehicle", "drive", "ride", "trip", "race", "racing", "journey", "delivery"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1003. mountain-snow
CREATE icon:mountain_snow CONTENT {
  identity: {
    value: 'mountain_snow',
    slug: 'mountain-snow'
  },
  presentation: {
    name_i18n: i18n_key:icon_mountain_snow_name,
    label_i18n: i18n_key:icon_mountain_snow_label,
    keywords: ["mountain-snow", "alpine", "climb", "snow"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1004. mountain
CREATE icon:mountain CONTENT {
  identity: {
    value: 'mountain',
    slug: 'mountain'
  },
  presentation: {
    name_i18n: i18n_key:icon_mountain_name,
    label_i18n: i18n_key:icon_mountain_label,
    keywords: ["mountain", "climb", "hike", "rock"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1005. mouse-off
CREATE icon:mouse_off CONTENT {
  identity: {
    value: 'mouse_off',
    slug: 'mouse-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_mouse_off_name,
    label_i18n: i18n_key:icon_mouse_off_label,
    keywords: ["mouse-off", "device", "scroll", "click", "disabled"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1006. mouse-pointer-2
CREATE icon:mouse_pointer_2 CONTENT {
  identity: {
    value: 'mouse_pointer_2',
    slug: 'mouse-pointer-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_mouse_pointer_2_name,
    label_i18n: i18n_key:icon_mouse_pointer_2_label,
    keywords: ["mouse-pointer-2", "click", "select"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1007. mouse-pointer-ban
CREATE icon:mouse_pointer_ban CONTENT {
  identity: {
    value: 'mouse_pointer_ban',
    slug: 'mouse-pointer-ban'
  },
  presentation: {
    name_i18n: i18n_key:icon_mouse_pointer_ban_name,
    label_i18n: i18n_key:icon_mouse_pointer_ban_label,
    keywords: ["mouse-pointer-ban", "wait", "busy", "loading", "blocked", "frozen", "freeze"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1008. mouse-pointer-click
CREATE icon:mouse_pointer_click CONTENT {
  identity: {
    value: 'mouse_pointer_click',
    slug: 'mouse-pointer-click'
  },
  presentation: {
    name_i18n: i18n_key:icon_mouse_pointer_click_name,
    label_i18n: i18n_key:icon_mouse_pointer_click_label,
    keywords: ["mouse-pointer-click", "click", "select"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1009. mouse-pointer
CREATE icon:mouse_pointer CONTENT {
  identity: {
    value: 'mouse_pointer',
    slug: 'mouse-pointer'
  },
  presentation: {
    name_i18n: i18n_key:icon_mouse_pointer_name,
    label_i18n: i18n_key:icon_mouse_pointer_label,
    keywords: ["mouse-pointer", "click", "select"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1010. mouse
CREATE icon:mouse CONTENT {
  identity: {
    value: 'mouse',
    slug: 'mouse'
  },
  presentation: {
    name_i18n: i18n_key:icon_mouse_name,
    label_i18n: i18n_key:icon_mouse_label,
    keywords: ["mouse", "device", "scroll", "click"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1011. move-3d
CREATE icon:move_3d CONTENT {
  identity: {
    value: 'move_3d',
    slug: 'move-3d'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_3d_name,
    label_i18n: i18n_key:icon_move_3d_label,
    keywords: ["move-3d", "arrows", "axis", "gizmo", "coordinates", "transform", "translate"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1012. move-diagonal-2
CREATE icon:move_diagonal_2 CONTENT {
  identity: {
    value: 'move_diagonal_2',
    slug: 'move-diagonal-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_diagonal_2_name,
    label_i18n: i18n_key:icon_move_diagonal_2_label,
    keywords: ["move-diagonal-2", "double", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1013. move-diagonal
CREATE icon:move_diagonal CONTENT {
  identity: {
    value: 'move_diagonal',
    slug: 'move-diagonal'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_diagonal_name,
    label_i18n: i18n_key:icon_move_diagonal_label,
    keywords: ["move-diagonal", "double", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1014. move-down-left
CREATE icon:move_down_left CONTENT {
  identity: {
    value: 'move_down_left',
    slug: 'move-down-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_down_left_name,
    label_i18n: i18n_key:icon_move_down_left_label,
    keywords: ["move-down-left", "arrow", "direction"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1015. move-down-right
CREATE icon:move_down_right CONTENT {
  identity: {
    value: 'move_down_right',
    slug: 'move-down-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_down_right_name,
    label_i18n: i18n_key:icon_move_down_right_label,
    keywords: ["move-down-right", "arrow", "direction"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1016. move-down
CREATE icon:move_down CONTENT {
  identity: {
    value: 'move_down',
    slug: 'move-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_down_name,
    label_i18n: i18n_key:icon_move_down_label,
    keywords: ["move-down", "arrow", "direction", "downwards", "south"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1017. move-horizontal
CREATE icon:move_horizontal CONTENT {
  identity: {
    value: 'move_horizontal',
    slug: 'move-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_horizontal_name,
    label_i18n: i18n_key:icon_move_horizontal_label,
    keywords: ["move-horizontal", "double", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1018. move-left
CREATE icon:move_left CONTENT {
  identity: {
    value: 'move_left',
    slug: 'move-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_left_name,
    label_i18n: i18n_key:icon_move_left_label,
    keywords: ["move-left", "arrow", "direction", "back", "west"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1019. move-right
CREATE icon:move_right CONTENT {
  identity: {
    value: 'move_right',
    slug: 'move-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_right_name,
    label_i18n: i18n_key:icon_move_right_label,
    keywords: ["move-right", "arrow", "direction", "trend flat", "east"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1020. move-up-left
CREATE icon:move_up_left CONTENT {
  identity: {
    value: 'move_up_left',
    slug: 'move-up-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_up_left_name,
    label_i18n: i18n_key:icon_move_up_left_label,
    keywords: ["move-up-left", "arrow", "direction"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1021. move-up-right
CREATE icon:move_up_right CONTENT {
  identity: {
    value: 'move_up_right',
    slug: 'move-up-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_up_right_name,
    label_i18n: i18n_key:icon_move_up_right_label,
    keywords: ["move-up-right", "arrow", "direction"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1022. move-up
CREATE icon:move_up CONTENT {
  identity: {
    value: 'move_up',
    slug: 'move-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_up_name,
    label_i18n: i18n_key:icon_move_up_label,
    keywords: ["move-up", "arrow", "direction", "upwards", "north"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1023. move-vertical
CREATE icon:move_vertical CONTENT {
  identity: {
    value: 'move_vertical',
    slug: 'move-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_vertical_name,
    label_i18n: i18n_key:icon_move_vertical_label,
    keywords: ["move-vertical", "double", "arrow"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1024. move
CREATE icon:move CONTENT {
  identity: {
    value: 'move',
    slug: 'move'
  },
  presentation: {
    name_i18n: i18n_key:icon_move_name,
    label_i18n: i18n_key:icon_move_label,
    keywords: ["move", "arrows"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1025. music-2
CREATE icon:music_2 CONTENT {
  identity: {
    value: 'music_2',
    slug: 'music-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_music_2_name,
    label_i18n: i18n_key:icon_music_2_label,
    keywords: ["music-2", "quaver", "eighth note", "note"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1026. music-3
CREATE icon:music_3 CONTENT {
  identity: {
    value: 'music_3',
    slug: 'music-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_music_3_name,
    label_i18n: i18n_key:icon_music_3_label,
    keywords: ["music-3", "crotchet", "minim", "quarter note", "half note", "note"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1027. music-4
CREATE icon:music_4 CONTENT {
  identity: {
    value: 'music_4',
    slug: 'music-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_music_4_name,
    label_i18n: i18n_key:icon_music_4_label,
    keywords: ["music-4", "semiquaver", "sixteenth note", "note"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1028. music
CREATE icon:music CONTENT {
  identity: {
    value: 'music',
    slug: 'music'
  },
  presentation: {
    name_i18n: i18n_key:icon_music_name,
    label_i18n: i18n_key:icon_music_label,
    keywords: ["music", "note", "quaver", "eighth note"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1029. navigation-2-off
CREATE icon:navigation_2_off CONTENT {
  identity: {
    value: 'navigation_2_off',
    slug: 'navigation-2-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_navigation_2_off_name,
    label_i18n: i18n_key:icon_navigation_2_off_label,
    keywords: ["navigation-2-off", "location", "travel"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1030. navigation-2
CREATE icon:navigation_2 CONTENT {
  identity: {
    value: 'navigation_2',
    slug: 'navigation-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_navigation_2_name,
    label_i18n: i18n_key:icon_navigation_2_label,
    keywords: ["navigation-2", "location", "travel"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1031. navigation-off
CREATE icon:navigation_off CONTENT {
  identity: {
    value: 'navigation_off',
    slug: 'navigation-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_navigation_off_name,
    label_i18n: i18n_key:icon_navigation_off_label,
    keywords: ["navigation-off", "location", "travel"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1032. navigation
CREATE icon:navigation CONTENT {
  identity: {
    value: 'navigation',
    slug: 'navigation'
  },
  presentation: {
    name_i18n: i18n_key:icon_navigation_name,
    label_i18n: i18n_key:icon_navigation_label,
    keywords: ["navigation", "location", "travel"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1033. network
CREATE icon:network CONTENT {
  identity: {
    value: 'network',
    slug: 'network'
  },
  presentation: {
    name_i18n: i18n_key:icon_network_name,
    label_i18n: i18n_key:icon_network_label,
    keywords: ["network", "tree"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1034. newspaper
CREATE icon:newspaper CONTENT {
  identity: {
    value: 'newspaper',
    slug: 'newspaper'
  },
  presentation: {
    name_i18n: i18n_key:icon_newspaper_name,
    label_i18n: i18n_key:icon_newspaper_label,
    keywords: ["newspaper", "news", "feed", "home", "magazine", "article", "headline"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1035. nfc
CREATE icon:nfc CONTENT {
  identity: {
    value: 'nfc',
    slug: 'nfc'
  },
  presentation: {
    name_i18n: i18n_key:icon_nfc_name,
    label_i18n: i18n_key:icon_nfc_label,
    keywords: ["nfc", "contactless", "payment", "near-field communication"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1036. non-binary
CREATE icon:non_binary CONTENT {
  identity: {
    value: 'non_binary',
    slug: 'non-binary'
  },
  presentation: {
    name_i18n: i18n_key:icon_non_binary_name,
    label_i18n: i18n_key:icon_non_binary_label,
    keywords: ["non-binary", "gender", "nonbinary", "enby"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1037. notebook-pen
CREATE icon:notebook_pen CONTENT {
  identity: {
    value: 'notebook_pen',
    slug: 'notebook-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_notebook_pen_name,
    label_i18n: i18n_key:icon_notebook_pen_label,
    keywords: ["notebook-pen", "pencil", "notepad", "notes", "noted", "stationery", "sketchbook", "organizer", "organiser", "planner", "diary", "journal", "writing", "write", "written", "reading", "high school", "university", "college", "academy", "student", "study", "research", "homework", "eraser", "rubber"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1038. notebook-tabs
CREATE icon:notebook_tabs CONTENT {
  identity: {
    value: 'notebook_tabs',
    slug: 'notebook-tabs'
  },
  presentation: {
    name_i18n: i18n_key:icon_notebook_tabs_name,
    label_i18n: i18n_key:icon_notebook_tabs_label,
    keywords: ["notebook-tabs", "notepad", "notes", "people", "family", "friends", "acquaintances", "contacts", "details", "addresses", "phone numbers", "directory", "listing", "networking", "alphabetical", "a-z", "organizer", "organiser", "planner", "diary", "stationery"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1039. notebook-text
CREATE icon:notebook_text CONTENT {
  identity: {
    value: 'notebook_text',
    slug: 'notebook-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_notebook_text_name,
    label_i18n: i18n_key:icon_notebook_text_label,
    keywords: ["notebook-text", "notepad", "notes", "pages", "paper", "stationery", "sketchbook", "organizer", "organiser", "planner", "diary", "journal", "writing", "write", "written", "reading", "high school", "university", "college", "academy", "student", "study", "research", "homework", "lines", "opened"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1040. notebook
CREATE icon:notebook CONTENT {
  identity: {
    value: 'notebook',
    slug: 'notebook'
  },
  presentation: {
    name_i18n: i18n_key:icon_notebook_name,
    label_i18n: i18n_key:icon_notebook_label,
    keywords: ["notebook", "notepad", "notes", "stationery", "sketchbook", "moleskine", "closure", "strap", "band", "elastic", "organizer", "organiser", "planner", "diary", "journal", "writing", "written", "writer", "reading", "high school", "university", "college", "academy", "student", "study", "homework", "research"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1041. notepad-text-dashed
CREATE icon:notepad_text_dashed CONTENT {
  identity: {
    value: 'notepad_text_dashed',
    slug: 'notepad-text-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_notepad_text_dashed_name,
    label_i18n: i18n_key:icon_notepad_text_dashed_label,
    keywords: ["notepad-text-dashed", "notebook", "notes", "pages", "paper", "stationery", "diary", "journal", "writing", "write", "written", "draft", "template", "lines"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1042. notepad-text
CREATE icon:notepad_text CONTENT {
  identity: {
    value: 'notepad_text',
    slug: 'notepad-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_notepad_text_name,
    label_i18n: i18n_key:icon_notepad_text_label,
    keywords: ["notepad-text", "notebook", "notes", "pages", "paper", "stationery", "sketchbook", "organizer", "organiser", "planner", "diary", "journal", "writing", "write", "written", "reading", "high school", "university", "college", "academy", "student", "study", "homework", "research", "lines", "opened"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1043. nut-off
CREATE icon:nut_off CONTENT {
  identity: {
    value: 'nut_off',
    slug: 'nut-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_nut_off_name,
    label_i18n: i18n_key:icon_nut_off_label,
    keywords: ["nut-off", "hazelnut", "acorn", "food", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1044. nut
CREATE icon:nut CONTENT {
  identity: {
    value: 'nut',
    slug: 'nut'
  },
  presentation: {
    name_i18n: i18n_key:icon_nut_name,
    label_i18n: i18n_key:icon_nut_label,
    keywords: ["nut", "hazelnut", "acorn", "food", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1045. octagon-alert
CREATE icon:octagon_alert CONTENT {
  identity: {
    value: 'octagon_alert',
    slug: 'octagon-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_octagon_alert_name,
    label_i18n: i18n_key:icon_octagon_alert_label,
    keywords: ["octagon-alert", "warning", "alert", "danger", "exclamation mark"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1046. octagon-minus
CREATE icon:octagon_minus CONTENT {
  identity: {
    value: 'octagon_minus',
    slug: 'octagon-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_octagon_minus_name,
    label_i18n: i18n_key:icon_octagon_minus_label,
    keywords: ["octagon-minus", "stop", "forbidden", "subtract", "remove", "decrease", "reduce", "-", "traffic", "halt", "restricted"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1047. octagon-pause
CREATE icon:octagon_pause CONTENT {
  identity: {
    value: 'octagon_pause',
    slug: 'octagon-pause'
  },
  presentation: {
    name_i18n: i18n_key:icon_octagon_pause_name,
    label_i18n: i18n_key:icon_octagon_pause_label,
    keywords: ["octagon-pause", "music", "audio", "stop"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1048. octagon-x
CREATE icon:octagon_x CONTENT {
  identity: {
    value: 'octagon_x',
    slug: 'octagon-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_octagon_x_name,
    label_i18n: i18n_key:icon_octagon_x_label,
    keywords: ["octagon-x", "delete", "stop", "alert", "warning", "times", "clear", "math"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1049. octagon
CREATE icon:octagon CONTENT {
  identity: {
    value: 'octagon',
    slug: 'octagon'
  },
  presentation: {
    name_i18n: i18n_key:icon_octagon_name,
    label_i18n: i18n_key:icon_octagon_label,
    keywords: ["octagon", "stop", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1050. omega
CREATE icon:omega CONTENT {
  identity: {
    value: 'omega',
    slug: 'omega'
  },
  presentation: {
    name_i18n: i18n_key:icon_omega_name,
    label_i18n: i18n_key:icon_omega_label,
    keywords: ["omega", "greek", "symbol", "mathematics", "education", "physics", "engineering", "ohms", "electrical resistance", "angular frequency", "dynamical systems", "astronomy", "constellations", "philosophy"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1051. option
CREATE icon:option CONTENT {
  identity: {
    value: 'option',
    slug: 'option'
  },
  presentation: {
    name_i18n: i18n_key:icon_option_name,
    label_i18n: i18n_key:icon_option_label,
    keywords: ["option", "keyboard", "key", "mac", "alt", "button"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1052. orbit
CREATE icon:orbit CONTENT {
  identity: {
    value: 'orbit',
    slug: 'orbit'
  },
  presentation: {
    name_i18n: i18n_key:icon_orbit_name,
    label_i18n: i18n_key:icon_orbit_label,
    keywords: ["orbit", "planet", "space", "physics", "satellites", "moons"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1053. origami
CREATE icon:origami CONTENT {
  identity: {
    value: 'origami',
    slug: 'origami'
  },
  presentation: {
    name_i18n: i18n_key:icon_origami_name,
    label_i18n: i18n_key:icon_origami_label,
    keywords: ["origami", "paper", "bird"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1054. package-2
CREATE icon:package_2 CONTENT {
  identity: {
    value: 'package_2',
    slug: 'package-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_2_name,
    label_i18n: i18n_key:icon_package_2_label,
    keywords: ["package-2", "box", "container", "storage", "sealed", "packed", "unopened", "undelivered", "archive", "zip"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1055. package-check
CREATE icon:package_check CONTENT {
  identity: {
    value: 'package_check',
    slug: 'package-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_check_name,
    label_i18n: i18n_key:icon_package_check_label,
    keywords: ["package-check", "confirm", "verified", "done", "todo", "tick", "complete", "task", "delivered"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1056. package-minus
CREATE icon:package_minus CONTENT {
  identity: {
    value: 'package_minus',
    slug: 'package-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_minus_name,
    label_i18n: i18n_key:icon_package_minus_label,
    keywords: ["package-minus", "delete", "remove"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1057. package-open
CREATE icon:package_open CONTENT {
  identity: {
    value: 'package_open',
    slug: 'package-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_open_name,
    label_i18n: i18n_key:icon_package_open_label,
    keywords: ["package-open", "box", "container", "storage", "unpack", "unarchive", "unzip", "opened", "delivered"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1058. package-plus
CREATE icon:package_plus CONTENT {
  identity: {
    value: 'package_plus',
    slug: 'package-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_plus_name,
    label_i18n: i18n_key:icon_package_plus_label,
    keywords: ["package-plus", "new", "add", "create"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1059. package-search
CREATE icon:package_search CONTENT {
  identity: {
    value: 'package_search',
    slug: 'package-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_search_name,
    label_i18n: i18n_key:icon_package_search_label,
    keywords: ["package-search", "find", "product process", "lens"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1060. package-x
CREATE icon:package_x CONTENT {
  identity: {
    value: 'package_x',
    slug: 'package-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_x_name,
    label_i18n: i18n_key:icon_package_x_label,
    keywords: ["package-x", "delete", "remove"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1061. package
CREATE icon:package CONTENT {
  identity: {
    value: 'package',
    slug: 'package'
  },
  presentation: {
    name_i18n: i18n_key:icon_package_name,
    label_i18n: i18n_key:icon_package_label,
    keywords: ["package", "box", "container", "storage", "sealed", "delivery", "undelivered", "unopened", "packed", "archive", "zip", "module"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1062. paint-bucket
CREATE icon:paint_bucket CONTENT {
  identity: {
    value: 'paint_bucket',
    slug: 'paint-bucket'
  },
  presentation: {
    name_i18n: i18n_key:icon_paint_bucket_name,
    label_i18n: i18n_key:icon_paint_bucket_label,
    keywords: ["paint-bucket", "fill", "paint", "bucket", "color", "colour"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1063. paint-roller
CREATE icon:paint_roller CONTENT {
  identity: {
    value: 'paint_roller',
    slug: 'paint-roller'
  },
  presentation: {
    name_i18n: i18n_key:icon_paint_roller_name,
    label_i18n: i18n_key:icon_paint_roller_label,
    keywords: ["paint-roller", "brush", "color", "colour", "decoration", "diy"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1064. paintbrush-vertical
CREATE icon:paintbrush_vertical CONTENT {
  identity: {
    value: 'paintbrush_vertical',
    slug: 'paintbrush-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_paintbrush_vertical_name,
    label_i18n: i18n_key:icon_paintbrush_vertical_label,
    keywords: ["paintbrush-vertical", "brush", "paintbrush", "design", "color", "colour", "decoration", "diy"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1065. paintbrush
CREATE icon:paintbrush CONTENT {
  identity: {
    value: 'paintbrush',
    slug: 'paintbrush'
  },
  presentation: {
    name_i18n: i18n_key:icon_paintbrush_name,
    label_i18n: i18n_key:icon_paintbrush_label,
    keywords: ["paintbrush", "brush", "paintbrush", "design", "color", "colour", "decoration", "diy"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1066. palette
CREATE icon:palette CONTENT {
  identity: {
    value: 'palette',
    slug: 'palette'
  },
  presentation: {
    name_i18n: i18n_key:icon_palette_name,
    label_i18n: i18n_key:icon_palette_label,
    keywords: ["palette", "colors", "colours", "theme", "scheme", "paint", "watercolor", "watercolour", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1067. panda
CREATE icon:panda CONTENT {
  identity: {
    value: 'panda',
    slug: 'panda'
  },
  presentation: {
    name_i18n: i18n_key:icon_panda_name,
    label_i18n: i18n_key:icon_panda_label,
    keywords: ["panda", "animal", "wildlife", "bear", "zoo", "bamboo"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1068. panel-bottom-close
CREATE icon:panel_bottom_close CONTENT {
  identity: {
    value: 'panel_bottom_close',
    slug: 'panel-bottom-close'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_bottom_close_name,
    label_i18n: i18n_key:icon_panel_bottom_close_label,
    keywords: ["panel-bottom-close", "drawer", "dock", "hide", "chevron", "down"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1069. panel-bottom-dashed
CREATE icon:panel_bottom_dashed CONTENT {
  identity: {
    value: 'panel_bottom_dashed',
    slug: 'panel-bottom-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_bottom_dashed_name,
    label_i18n: i18n_key:icon_panel_bottom_dashed_label,
    keywords: ["panel-bottom-dashed", "drawer", "dock", "show", "reveal", "padding", "margin", "guide", "layout", "bleed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1070. panel-bottom-open
CREATE icon:panel_bottom_open CONTENT {
  identity: {
    value: 'panel_bottom_open',
    slug: 'panel-bottom-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_bottom_open_name,
    label_i18n: i18n_key:icon_panel_bottom_open_label,
    keywords: ["panel-bottom-open", "drawer", "dock", "show", "reveal", "chevron", "up"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1071. panel-bottom
CREATE icon:panel_bottom CONTENT {
  identity: {
    value: 'panel_bottom',
    slug: 'panel-bottom'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_bottom_name,
    label_i18n: i18n_key:icon_panel_bottom_label,
    keywords: ["panel-bottom", "drawer", "dock"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1072. panel-left-close
CREATE icon:panel_left_close CONTENT {
  identity: {
    value: 'panel_left_close',
    slug: 'panel-left-close'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_left_close_name,
    label_i18n: i18n_key:icon_panel_left_close_label,
    keywords: ["panel-left-close", "primary", "drawer", "hide", "chevron", "<"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1073. panel-left-dashed
CREATE icon:panel_left_dashed CONTENT {
  identity: {
    value: 'panel_left_dashed',
    slug: 'panel-left-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_left_dashed_name,
    label_i18n: i18n_key:icon_panel_left_dashed_label,
    keywords: ["panel-left-dashed", "sidebar", "primary", "drawer", "show", "reveal", "padding", "margin", "guide", "layout", "bleed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1074. panel-left-open
CREATE icon:panel_left_open CONTENT {
  identity: {
    value: 'panel_left_open',
    slug: 'panel-left-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_left_open_name,
    label_i18n: i18n_key:icon_panel_left_open_label,
    keywords: ["panel-left-open", "primary", "drawer", "show", "reveal", "chevron", "right", ">"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1075. panel-left-right-dashed
CREATE icon:panel_left_right_dashed CONTENT {
  identity: {
    value: 'panel_left_right_dashed',
    slug: 'panel-left-right-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_left_right_dashed_name,
    label_i18n: i18n_key:icon_panel_left_right_dashed_label,
    keywords: ["panel-left-right-dashed", "sidebar", "primary", "drawer", "show", "reveal", "padding", "margin", "guide", "layout", "vertical", "bleed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1076. panel-left
CREATE icon:panel_left CONTENT {
  identity: {
    value: 'panel_left',
    slug: 'panel-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_left_name,
    label_i18n: i18n_key:icon_panel_left_label,
    keywords: ["panel-left", "primary", "drawer"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1077. panel-right-close
CREATE icon:panel_right_close CONTENT {
  identity: {
    value: 'panel_right_close',
    slug: 'panel-right-close'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_right_close_name,
    label_i18n: i18n_key:icon_panel_right_close_label,
    keywords: ["panel-right-close", "sidebar", "secondary", "drawer", "hide", "chevron", ">"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1078. panel-right-dashed
CREATE icon:panel_right_dashed CONTENT {
  identity: {
    value: 'panel_right_dashed',
    slug: 'panel-right-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_right_dashed_name,
    label_i18n: i18n_key:icon_panel_right_dashed_label,
    keywords: ["panel-right-dashed", "sidebar", "secondary", "drawer", "show", "reveal", "padding", "margin", "guide", "layout", "bleed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1079. panel-right-open
CREATE icon:panel_right_open CONTENT {
  identity: {
    value: 'panel_right_open',
    slug: 'panel-right-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_right_open_name,
    label_i18n: i18n_key:icon_panel_right_open_label,
    keywords: ["panel-right-open", "sidebar", "secondary", "drawer", "show", "reveal", "chevron", "left", "<"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1080. panel-right
CREATE icon:panel_right CONTENT {
  identity: {
    value: 'panel_right',
    slug: 'panel-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_right_name,
    label_i18n: i18n_key:icon_panel_right_label,
    keywords: ["panel-right", "sidebar", "secondary", "drawer"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1081. panel-top-bottom-dashed
CREATE icon:panel_top_bottom_dashed CONTENT {
  identity: {
    value: 'panel_top_bottom_dashed',
    slug: 'panel-top-bottom-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_top_bottom_dashed_name,
    label_i18n: i18n_key:icon_panel_top_bottom_dashed_label,
    keywords: ["panel-top-bottom-dashed", "sidebar", "primary", "drawer", "show", "reveal", "padding", "margin", "guide", "layout", "horizontal", "bleed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1082. panel-top-close
CREATE icon:panel_top_close CONTENT {
  identity: {
    value: 'panel_top_close',
    slug: 'panel-top-close'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_top_close_name,
    label_i18n: i18n_key:icon_panel_top_close_label,
    keywords: ["panel-top-close", "menu bar", "drawer", "hide", "chevron", "up"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1083. panel-top-dashed
CREATE icon:panel_top_dashed CONTENT {
  identity: {
    value: 'panel_top_dashed',
    slug: 'panel-top-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_top_dashed_name,
    label_i18n: i18n_key:icon_panel_top_dashed_label,
    keywords: ["panel-top-dashed", "menu bar", "drawer", "show", "reveal", "padding", "margin", "guide", "layout", "bleed"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1084. panel-top-open
CREATE icon:panel_top_open CONTENT {
  identity: {
    value: 'panel_top_open',
    slug: 'panel-top-open'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_top_open_name,
    label_i18n: i18n_key:icon_panel_top_open_label,
    keywords: ["panel-top-open", "menu bar", "drawer", "show", "reveal", "chevron", "down"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1085. panel-top
CREATE icon:panel_top CONTENT {
  identity: {
    value: 'panel_top',
    slug: 'panel-top'
  },
  presentation: {
    name_i18n: i18n_key:icon_panel_top_name,
    label_i18n: i18n_key:icon_panel_top_label,
    keywords: ["panel-top", "drawer", "browser", "webpage"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1086. panels-left-bottom
CREATE icon:panels_left_bottom CONTENT {
  identity: {
    value: 'panels_left_bottom',
    slug: 'panels-left-bottom'
  },
  presentation: {
    name_i18n: i18n_key:icon_panels_left_bottom_name,
    label_i18n: i18n_key:icon_panels_left_bottom_label,
    keywords: ["panels-left-bottom", "drawers", "sidebar", "primary"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1087. panels-right-bottom
CREATE icon:panels_right_bottom CONTENT {
  identity: {
    value: 'panels_right_bottom',
    slug: 'panels-right-bottom'
  },
  presentation: {
    name_i18n: i18n_key:icon_panels_right_bottom_name,
    label_i18n: i18n_key:icon_panels_right_bottom_label,
    keywords: ["panels-right-bottom", "drawers", "sidebar", "secondary"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1088. panels-top-left
CREATE icon:panels_top_left CONTENT {
  identity: {
    value: 'panels_top_left',
    slug: 'panels-top-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_panels_top_left_name,
    label_i18n: i18n_key:icon_panels_top_left_label,
    keywords: ["panels-top-left", "menu bar", "sidebar", "primary", "drawers", "window", "webpage", "projects", "overview"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1089. paperclip
CREATE icon:paperclip CONTENT {
  identity: {
    value: 'paperclip',
    slug: 'paperclip'
  },
  presentation: {
    name_i18n: i18n_key:icon_paperclip_name,
    label_i18n: i18n_key:icon_paperclip_label,
    keywords: ["paperclip", "attachment", "file"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1090. parentheses
CREATE icon:parentheses CONTENT {
  identity: {
    value: 'parentheses',
    slug: 'parentheses'
  },
  presentation: {
    name_i18n: i18n_key:icon_parentheses_name,
    label_i18n: i18n_key:icon_parentheses_label,
    keywords: ["parentheses", "code", "token", "parenthesis", "parens", "brackets", "parameters", "arguments", "args", "input", "call", "math", "formula", "function", "(", ")"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1091. parking-meter
CREATE icon:parking_meter CONTENT {
  identity: {
    value: 'parking_meter',
    slug: 'parking-meter'
  },
  presentation: {
    name_i18n: i18n_key:icon_parking_meter_name,
    label_i18n: i18n_key:icon_parking_meter_label,
    keywords: ["parking-meter", "driving", "car park", "pay", "sidewalk", "pavement"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1092. party-popper
CREATE icon:party_popper CONTENT {
  identity: {
    value: 'party_popper',
    slug: 'party-popper'
  },
  presentation: {
    name_i18n: i18n_key:icon_party_popper_name,
    label_i18n: i18n_key:icon_party_popper_label,
    keywords: ["party-popper", "emoji", "congratulations", "celebration", "party", "tada", "\ud83c\udf89", "\ud83c\udf8a", "excitement", "exciting", "excites", "confetti"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1093. pause
CREATE icon:pause CONTENT {
  identity: {
    value: 'pause',
    slug: 'pause'
  },
  presentation: {
    name_i18n: i18n_key:icon_pause_name,
    label_i18n: i18n_key:icon_pause_label,
    keywords: ["pause", "music", "stop"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1094. paw-print
CREATE icon:paw_print CONTENT {
  identity: {
    value: 'paw_print',
    slug: 'paw-print'
  },
  presentation: {
    name_i18n: i18n_key:icon_paw_print_name,
    label_i18n: i18n_key:icon_paw_print_label,
    keywords: ["paw-print", "pets", "vets", "veterinarian", "domesticated", "cat", "dog", "bear"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1095. pc-case
CREATE icon:pc_case CONTENT {
  identity: {
    value: 'pc_case',
    slug: 'pc-case'
  },
  presentation: {
    name_i18n: i18n_key:icon_pc_case_name,
    label_i18n: i18n_key:icon_pc_case_label,
    keywords: ["pc-case", "computer", "chassis"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1096. pen-line
CREATE icon:pen_line CONTENT {
  identity: {
    value: 'pen_line',
    slug: 'pen-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_pen_line_name,
    label_i18n: i18n_key:icon_pen_line_label,
    keywords: ["pen-line", "pencil", "change", "create", "draw", "writer", "writing", "biro", "ink", "marker", "felt tip", "stationery", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1097. pen-off
CREATE icon:pen_off CONTENT {
  identity: {
    value: 'pen_off',
    slug: 'pen-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_pen_off_name,
    label_i18n: i18n_key:icon_pen_off_label,
    keywords: ["pen-off", "disabled", "inactive", "non-editable", "locked", "read-only", "unmodifiable", "frozen", "restricted", "pencil", "change", "create", "draw", "writer", "writing", "biro", "ink", "marker", "felt tip", "stationery", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1098. pen-tool
CREATE icon:pen_tool CONTENT {
  identity: {
    value: 'pen_tool',
    slug: 'pen-tool'
  },
  presentation: {
    name_i18n: i18n_key:icon_pen_tool_name,
    label_i18n: i18n_key:icon_pen_tool_label,
    keywords: ["pen-tool", "vector", "drawing", "path"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1099. pen
CREATE icon:pen CONTENT {
  identity: {
    value: 'pen',
    slug: 'pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_pen_name,
    label_i18n: i18n_key:icon_pen_label,
    keywords: ["pen", "pencil", "change", "create", "draw", "writer", "writing", "biro", "ink", "marker", "felt tip", "stationery", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1100. pencil-line
CREATE icon:pencil_line CONTENT {
  identity: {
    value: 'pencil_line',
    slug: 'pencil-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_pencil_line_name,
    label_i18n: i18n_key:icon_pencil_line_label,
    keywords: ["pencil-line", "pencil", "change", "create", "draw", "sketch", "draft", "writer", "writing", "biro", "ink", "marker", "felt tip", "stationery", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1101. pencil-off
CREATE icon:pencil_off CONTENT {
  identity: {
    value: 'pencil_off',
    slug: 'pencil-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_pencil_off_name,
    label_i18n: i18n_key:icon_pencil_off_label,
    keywords: ["pencil-off", "disabled", "inactive", "non-editable", "locked", "read-only", "unmodifiable", "frozen", "restricted", "rubber", "edit", "create", "draw", "sketch", "draft", "writer", "writing", "stationery", "artist"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1102. pencil-ruler
CREATE icon:pencil_ruler CONTENT {
  identity: {
    value: 'pencil_ruler',
    slug: 'pencil-ruler'
  },
  presentation: {
    name_i18n: i18n_key:icon_pencil_ruler_name,
    label_i18n: i18n_key:icon_pencil_ruler_label,
    keywords: ["pencil-ruler", "edit", "create", "draw", "sketch", "draft", "writer", "writing", "stationery", "artist", "measurements", "centimeters", "cm", "millimeters", "mm", "metre", "foot", "feet", "inches", "units", "size", "length", "width", "height", "dimensions", "depth", "breadth", "extent"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1103. pencil
CREATE icon:pencil CONTENT {
  identity: {
    value: 'pencil',
    slug: 'pencil'
  },
  presentation: {
    name_i18n: i18n_key:icon_pencil_name,
    label_i18n: i18n_key:icon_pencil_label,
    keywords: ["pencil", "rubber", "edit", "create", "draw", "sketch", "draft", "writer", "writing", "stationery", "artist"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1104. pentagon
CREATE icon:pentagon CONTENT {
  identity: {
    value: 'pentagon',
    slug: 'pentagon'
  },
  presentation: {
    name_i18n: i18n_key:icon_pentagon_name,
    label_i18n: i18n_key:icon_pentagon_label,
    keywords: ["pentagon", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1105. percent
CREATE icon:percent CONTENT {
  identity: {
    value: 'percent',
    slug: 'percent'
  },
  presentation: {
    name_i18n: i18n_key:icon_percent_name,
    label_i18n: i18n_key:icon_percent_label,
    keywords: ["percent", "percentage", "modulo", "modulus", "remainder", "%", "sale", "discount", "offer", "marketing"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1106. person-standing
CREATE icon:person_standing CONTENT {
  identity: {
    value: 'person_standing',
    slug: 'person-standing'
  },
  presentation: {
    name_i18n: i18n_key:icon_person_standing_name,
    label_i18n: i18n_key:icon_person_standing_label,
    keywords: ["person-standing", "people", "human", "accessibility", "stick figure"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1107. philippine-peso
CREATE icon:philippine_peso CONTENT {
  identity: {
    value: 'philippine_peso',
    slug: 'philippine-peso'
  },
  presentation: {
    name_i18n: i18n_key:icon_philippine_peso_name,
    label_i18n: i18n_key:icon_philippine_peso_label,
    keywords: ["philippine-peso", "currency", "peso", "money", "php"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1108. phone-call
CREATE icon:phone_call CONTENT {
  identity: {
    value: 'phone_call',
    slug: 'phone-call'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_call_name,
    label_i18n: i18n_key:icon_phone_call_label,
    keywords: ["phone-call", "ring"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1109. phone-forwarded
CREATE icon:phone_forwarded CONTENT {
  identity: {
    value: 'phone_forwarded',
    slug: 'phone-forwarded'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_forwarded_name,
    label_i18n: i18n_key:icon_phone_forwarded_label,
    keywords: ["phone-forwarded", "call"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1110. phone-incoming
CREATE icon:phone_incoming CONTENT {
  identity: {
    value: 'phone_incoming',
    slug: 'phone-incoming'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_incoming_name,
    label_i18n: i18n_key:icon_phone_incoming_label,
    keywords: ["phone-incoming", "call"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1111. phone-missed
CREATE icon:phone_missed CONTENT {
  identity: {
    value: 'phone_missed',
    slug: 'phone-missed'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_missed_name,
    label_i18n: i18n_key:icon_phone_missed_label,
    keywords: ["phone-missed", "call"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1112. phone-off
CREATE icon:phone_off CONTENT {
  identity: {
    value: 'phone_off',
    slug: 'phone-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_off_name,
    label_i18n: i18n_key:icon_phone_off_label,
    keywords: ["phone-off", "call", "mute"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1113. phone-outgoing
CREATE icon:phone_outgoing CONTENT {
  identity: {
    value: 'phone_outgoing',
    slug: 'phone-outgoing'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_outgoing_name,
    label_i18n: i18n_key:icon_phone_outgoing_label,
    keywords: ["phone-outgoing", "call"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1114. phone
CREATE icon:phone CONTENT {
  identity: {
    value: 'phone',
    slug: 'phone'
  },
  presentation: {
    name_i18n: i18n_key:icon_phone_name,
    label_i18n: i18n_key:icon_phone_label,
    keywords: ["phone", "call"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1115. pi
CREATE icon:pi CONTENT {
  identity: {
    value: 'pi',
    slug: 'pi'
  },
  presentation: {
    name_i18n: i18n_key:icon_pi_name,
    label_i18n: i18n_key:icon_pi_label,
    keywords: ["pi", "constant", "code", "coding", "programming", "symbol", "trigonometry", "geometry", "formula"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1116. piano
CREATE icon:piano CONTENT {
  identity: {
    value: 'piano',
    slug: 'piano'
  },
  presentation: {
    name_i18n: i18n_key:icon_piano_name,
    label_i18n: i18n_key:icon_piano_label,
    keywords: ["piano", "music", "audio", "sound", "noise", "notes", "chord", "keys", "octave", "acoustic", "instrument", "play", "pianist", "performance", "concert"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1117. pickaxe
CREATE icon:pickaxe CONTENT {
  identity: {
    value: 'pickaxe',
    slug: 'pickaxe'
  },
  presentation: {
    name_i18n: i18n_key:icon_pickaxe_name,
    label_i18n: i18n_key:icon_pickaxe_label,
    keywords: ["pickaxe", "mining", "mine", "land worker", "extraction", "labor", "construction", "progress", "advancement", "crafting", "building", "creation"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1118. picture-in-picture-2
CREATE icon:picture_in_picture_2 CONTENT {
  identity: {
    value: 'picture_in_picture_2',
    slug: 'picture-in-picture-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_picture_in_picture_2_name,
    label_i18n: i18n_key:icon_picture_in_picture_2_label,
    keywords: ["picture-in-picture-2", "display", "play", "video", "pop out", "always on top", "window", "inset", "multitask"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1119. picture-in-picture
CREATE icon:picture_in_picture CONTENT {
  identity: {
    value: 'picture_in_picture',
    slug: 'picture-in-picture'
  },
  presentation: {
    name_i18n: i18n_key:icon_picture_in_picture_name,
    label_i18n: i18n_key:icon_picture_in_picture_label,
    keywords: ["picture-in-picture", "display", "play", "video", "pop out", "always on top", "window", "inset", "multitask"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1120. piggy-bank
CREATE icon:piggy_bank CONTENT {
  identity: {
    value: 'piggy_bank',
    slug: 'piggy-bank'
  },
  presentation: {
    name_i18n: i18n_key:icon_piggy_bank_name,
    label_i18n: i18n_key:icon_piggy_bank_label,
    keywords: ["piggy-bank", "money", "savings"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1121. pilcrow-left
CREATE icon:pilcrow_left CONTENT {
  identity: {
    value: 'pilcrow_left',
    slug: 'pilcrow-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_pilcrow_left_name,
    label_i18n: i18n_key:icon_pilcrow_left_label,
    keywords: ["pilcrow-left", "direction", "paragraph", "mark", "paraph", "blind", "typography", "type", "text", "prose", "symbol"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1122. pilcrow-right
CREATE icon:pilcrow_right CONTENT {
  identity: {
    value: 'pilcrow_right',
    slug: 'pilcrow-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_pilcrow_right_name,
    label_i18n: i18n_key:icon_pilcrow_right_label,
    keywords: ["pilcrow-right", "direction", "paragraph", "mark", "paraph", "blind", "typography", "type", "text", "prose", "symbol"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1123. pilcrow
CREATE icon:pilcrow CONTENT {
  identity: {
    value: 'pilcrow',
    slug: 'pilcrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_pilcrow_name,
    label_i18n: i18n_key:icon_pilcrow_label,
    keywords: ["pilcrow", "paragraph", "mark", "paraph", "blind", "typography", "type", "text", "prose", "symbol"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1124. pill-bottle
CREATE icon:pill_bottle CONTENT {
  identity: {
    value: 'pill_bottle',
    slug: 'pill-bottle'
  },
  presentation: {
    name_i18n: i18n_key:icon_pill_bottle_name,
    label_i18n: i18n_key:icon_pill_bottle_label,
    keywords: ["pill-bottle", "medicine", "medication", "prescription", "drug", "supplement", "vitamin", "capsule", "jar", "container", "healthcare", "pharmaceutical", "tablet"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1125. pill
CREATE icon:pill CONTENT {
  identity: {
    value: 'pill',
    slug: 'pill'
  },
  presentation: {
    name_i18n: i18n_key:icon_pill_name,
    label_i18n: i18n_key:icon_pill_label,
    keywords: ["pill", "medicine", "medication", "drug", "prescription", "tablet", "pharmacy"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1126. pin-off
CREATE icon:pin_off CONTENT {
  identity: {
    value: 'pin_off',
    slug: 'pin-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_pin_off_name,
    label_i18n: i18n_key:icon_pin_off_label,
    keywords: ["pin-off", "unpin", "map", "unlock", "unfix", "unsave", "remove"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1127. pin
CREATE icon:pin CONTENT {
  identity: {
    value: 'pin',
    slug: 'pin'
  },
  presentation: {
    name_i18n: i18n_key:icon_pin_name,
    label_i18n: i18n_key:icon_pin_label,
    keywords: ["pin", "save", "map", "lock", "fix"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1128. pipette
CREATE icon:pipette CONTENT {
  identity: {
    value: 'pipette',
    slug: 'pipette'
  },
  presentation: {
    name_i18n: i18n_key:icon_pipette_name,
    label_i18n: i18n_key:icon_pipette_label,
    keywords: ["pipette", "eye dropper", "color picker", "lab", "chemistry"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1129. pizza
CREATE icon:pizza CONTENT {
  identity: {
    value: 'pizza',
    slug: 'pizza'
  },
  presentation: {
    name_i18n: i18n_key:icon_pizza_name,
    label_i18n: i18n_key:icon_pizza_label,
    keywords: ["pizza", "pie", "quiche", "food"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1130. plane-landing
CREATE icon:plane_landing CONTENT {
  identity: {
    value: 'plane_landing',
    slug: 'plane-landing'
  },
  presentation: {
    name_i18n: i18n_key:icon_plane_landing_name,
    label_i18n: i18n_key:icon_plane_landing_label,
    keywords: ["plane-landing", "arrival", "plane", "trip", "airplane", "landing"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1131. plane-takeoff
CREATE icon:plane_takeoff CONTENT {
  identity: {
    value: 'plane_takeoff',
    slug: 'plane-takeoff'
  },
  presentation: {
    name_i18n: i18n_key:icon_plane_takeoff_name,
    label_i18n: i18n_key:icon_plane_takeoff_label,
    keywords: ["plane-takeoff", "departure", "plane", "trip", "airplane", "takeoff"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1132. plane
CREATE icon:plane CONTENT {
  identity: {
    value: 'plane',
    slug: 'plane'
  },
  presentation: {
    name_i18n: i18n_key:icon_plane_name,
    label_i18n: i18n_key:icon_plane_label,
    keywords: ["plane", "plane", "trip", "airplane"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1133. play
CREATE icon:play CONTENT {
  identity: {
    value: 'play',
    slug: 'play'
  },
  presentation: {
    name_i18n: i18n_key:icon_play_name,
    label_i18n: i18n_key:icon_play_label,
    keywords: ["play", "music", "audio", "video", "start", "run"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1134. plug-2
CREATE icon:plug_2 CONTENT {
  identity: {
    value: 'plug_2',
    slug: 'plug-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_plug_2_name,
    label_i18n: i18n_key:icon_plug_2_label,
    keywords: ["plug-2", "electricity", "energy", "socket", "outlet"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1135. plug-zap
CREATE icon:plug_zap CONTENT {
  identity: {
    value: 'plug_zap',
    slug: 'plug-zap'
  },
  presentation: {
    name_i18n: i18n_key:icon_plug_zap_name,
    label_i18n: i18n_key:icon_plug_zap_label,
    keywords: ["plug-zap", "electricity", "energy", "electronics", "charge", "charging", "battery", "connect"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1136. plug
CREATE icon:plug CONTENT {
  identity: {
    value: 'plug',
    slug: 'plug'
  },
  presentation: {
    name_i18n: i18n_key:icon_plug_name,
    label_i18n: i18n_key:icon_plug_label,
    keywords: ["plug", "electricity", "energy", "electronics", "socket", "outlet"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1137. plus
CREATE icon:plus CONTENT {
  identity: {
    value: 'plus',
    slug: 'plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_plus_name,
    label_i18n: i18n_key:icon_plus_label,
    keywords: ["plus", "add", "new", "increase", "increment", "positive", "calculate", "toolbar", "crosshair", "aim", "target", "scope", "sight", "reticule", "maximum", "upgrade", "extra", "+"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1138. pocket-knife
CREATE icon:pocket_knife CONTENT {
  identity: {
    value: 'pocket_knife',
    slug: 'pocket-knife'
  },
  presentation: {
    name_i18n: i18n_key:icon_pocket_knife_name,
    label_i18n: i18n_key:icon_pocket_knife_label,
    keywords: ["pocket-knife", "swiss army knife", "penknife", "multi-tool", "multitask", "blade", "cutter", "gadget", "corkscrew"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1139. pocket
CREATE icon:pocket CONTENT {
  identity: {
    value: 'pocket',
    slug: 'pocket'
  },
  presentation: {
    name_i18n: i18n_key:icon_pocket_name,
    label_i18n: i18n_key:icon_pocket_label,
    keywords: ["pocket", "logo", "save"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1140. podcast
CREATE icon:podcast CONTENT {
  identity: {
    value: 'podcast',
    slug: 'podcast'
  },
  presentation: {
    name_i18n: i18n_key:icon_podcast_name,
    label_i18n: i18n_key:icon_podcast_label,
    keywords: ["podcast", "audio", "music", "mic", "talk", "voice", "subscribe", "subscription", "stream"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1141. pointer-off
CREATE icon:pointer_off CONTENT {
  identity: {
    value: 'pointer_off',
    slug: 'pointer-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_pointer_off_name,
    label_i18n: i18n_key:icon_pointer_off_label,
    keywords: ["pointer-off", "mouse"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1142. pointer
CREATE icon:pointer CONTENT {
  identity: {
    value: 'pointer',
    slug: 'pointer'
  },
  presentation: {
    name_i18n: i18n_key:icon_pointer_name,
    label_i18n: i18n_key:icon_pointer_label,
    keywords: ["pointer", "mouse"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1143. popcorn
CREATE icon:popcorn CONTENT {
  identity: {
    value: 'popcorn',
    slug: 'popcorn'
  },
  presentation: {
    name_i18n: i18n_key:icon_popcorn_name,
    label_i18n: i18n_key:icon_popcorn_label,
    keywords: ["popcorn", "cinema", "movies", "films", "salted", "sweet", "sugar", "candy", "snack"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1144. popsicle
CREATE icon:popsicle CONTENT {
  identity: {
    value: 'popsicle',
    slug: 'popsicle'
  },
  presentation: {
    name_i18n: i18n_key:icon_popsicle_name,
    label_i18n: i18n_key:icon_popsicle_label,
    keywords: ["popsicle", "ice lolly", "ice cream", "sweet", "food"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1145. pound-sterling
CREATE icon:pound_sterling CONTENT {
  identity: {
    value: 'pound_sterling',
    slug: 'pound-sterling'
  },
  presentation: {
    name_i18n: i18n_key:icon_pound_sterling_name,
    label_i18n: i18n_key:icon_pound_sterling_label,
    keywords: ["pound-sterling", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1146. power-off
CREATE icon:power_off CONTENT {
  identity: {
    value: 'power_off',
    slug: 'power-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_power_off_name,
    label_i18n: i18n_key:icon_power_off_label,
    keywords: ["power-off", "on", "off", "device", "switch"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1147. power
CREATE icon:power CONTENT {
  identity: {
    value: 'power',
    slug: 'power'
  },
  presentation: {
    name_i18n: i18n_key:icon_power_name,
    label_i18n: i18n_key:icon_power_label,
    keywords: ["power", "on", "off", "device", "switch", "toggle", "binary", "boolean", "reboot", "restart", "button", "keyboard", "troubleshoot"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1148. presentation
CREATE icon:presentation CONTENT {
  identity: {
    value: 'presentation',
    slug: 'presentation'
  },
  presentation: {
    name_i18n: i18n_key:icon_presentation_name,
    label_i18n: i18n_key:icon_presentation_label,
    keywords: ["presentation", "screen", "whiteboard", "marker pens", "markers", "blackboard", "chalk", "easel", "school", "learning", "lesson", "office", "meeting", "project", "planning"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1149. printer-check
CREATE icon:printer_check CONTENT {
  identity: {
    value: 'printer_check',
    slug: 'printer-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_printer_check_name,
    label_i18n: i18n_key:icon_printer_check_label,
    keywords: ["printer-check", "fax", "office", "device", "success", "printed"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1150. printer
CREATE icon:printer CONTENT {
  identity: {
    value: 'printer',
    slug: 'printer'
  },
  presentation: {
    name_i18n: i18n_key:icon_printer_name,
    label_i18n: i18n_key:icon_printer_label,
    keywords: ["printer", "fax", "office", "device"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1151. projector
CREATE icon:projector CONTENT {
  identity: {
    value: 'projector',
    slug: 'projector'
  },
  presentation: {
    name_i18n: i18n_key:icon_projector_name,
    label_i18n: i18n_key:icon_projector_label,
    keywords: ["projector", "cinema", "film", "movie", "home video", "presentation", "slideshow", "office", "meeting", "project", "planning"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1152. proportions
CREATE icon:proportions CONTENT {
  identity: {
    value: 'proportions',
    slug: 'proportions'
  },
  presentation: {
    name_i18n: i18n_key:icon_proportions_name,
    label_i18n: i18n_key:icon_proportions_label,
    keywords: ["proportions", "screens", "sizes", "rotate", "rotation", "adjust", "aspect ratio", "16:9", "widescreen", "4:3", "resolution", "responsive", "mobile", "desktop", "dimensions", "monitor", "orientation", "portrait", "landscape"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1153. puzzle
CREATE icon:puzzle CONTENT {
  identity: {
    value: 'puzzle',
    slug: 'puzzle'
  },
  presentation: {
    name_i18n: i18n_key:icon_puzzle_name,
    label_i18n: i18n_key:icon_puzzle_label,
    keywords: ["puzzle", "component", "module", "part", "piece"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1154. pyramid
CREATE icon:pyramid CONTENT {
  identity: {
    value: 'pyramid',
    slug: 'pyramid'
  },
  presentation: {
    name_i18n: i18n_key:icon_pyramid_name,
    label_i18n: i18n_key:icon_pyramid_label,
    keywords: ["pyramid", "prism", "triangle", "triangular", "hierarchy", "structure", "geometry", "ancient", "egyptian", "landmark", "tourism"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1155. qr-code
CREATE icon:qr_code CONTENT {
  identity: {
    value: 'qr_code',
    slug: 'qr-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_qr_code_name,
    label_i18n: i18n_key:icon_qr_code_label,
    keywords: ["qr-code", "barcode", "scan", "link", "url", "information", "digital"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1156. quote
CREATE icon:quote CONTENT {
  identity: {
    value: 'quote',
    slug: 'quote'
  },
  presentation: {
    name_i18n: i18n_key:icon_quote_name,
    label_i18n: i18n_key:icon_quote_label,
    keywords: ["quote", "quotation"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1157. rabbit
CREATE icon:rabbit CONTENT {
  identity: {
    value: 'rabbit',
    slug: 'rabbit'
  },
  presentation: {
    name_i18n: i18n_key:icon_rabbit_name,
    label_i18n: i18n_key:icon_rabbit_label,
    keywords: ["rabbit", "animal", "rodent", "pet", "pest", "bunny", "hare", "fast", "speed", "hop"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1158. radar
CREATE icon:radar CONTENT {
  identity: {
    value: 'radar',
    slug: 'radar'
  },
  presentation: {
    name_i18n: i18n_key:icon_radar_name,
    label_i18n: i18n_key:icon_radar_label,
    keywords: ["radar", "scan", "sonar", "detect", "find", "locate"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1159. radiation
CREATE icon:radiation CONTENT {
  identity: {
    value: 'radiation',
    slug: 'radiation'
  },
  presentation: {
    name_i18n: i18n_key:icon_radiation_name,
    label_i18n: i18n_key:icon_radiation_label,
    keywords: ["radiation", "radioactive", "nuclear", "fallout", "waste", "atomic", "physics", "particle", "element", "molecule"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1160. radical
CREATE icon:radical CONTENT {
  identity: {
    value: 'radical',
    slug: 'radical'
  },
  presentation: {
    name_i18n: i18n_key:icon_radical_name,
    label_i18n: i18n_key:icon_radical_label,
    keywords: ["radical", "calculate", "formula", "math", "operator", "root", "square", "symbol"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1161. radio-receiver
CREATE icon:radio_receiver CONTENT {
  identity: {
    value: 'radio_receiver',
    slug: 'radio-receiver'
  },
  presentation: {
    name_i18n: i18n_key:icon_radio_receiver_name,
    label_i18n: i18n_key:icon_radio_receiver_label,
    keywords: ["radio-receiver", "device", "music", "connect"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1162. radio-tower
CREATE icon:radio_tower CONTENT {
  identity: {
    value: 'radio_tower',
    slug: 'radio-tower'
  },
  presentation: {
    name_i18n: i18n_key:icon_radio_tower_name,
    label_i18n: i18n_key:icon_radio_tower_label,
    keywords: ["radio-tower", "signal", "broadcast", "connectivity", "live", "frequency"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1163. radio
CREATE icon:radio CONTENT {
  identity: {
    value: 'radio',
    slug: 'radio'
  },
  presentation: {
    name_i18n: i18n_key:icon_radio_name,
    label_i18n: i18n_key:icon_radio_label,
    keywords: ["radio", "signal", "broadcast", "connectivity", "live", "frequency"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1164. radius
CREATE icon:radius CONTENT {
  identity: {
    value: 'radius',
    slug: 'radius'
  },
  presentation: {
    name_i18n: i18n_key:icon_radius_name,
    label_i18n: i18n_key:icon_radius_label,
    keywords: ["radius", "shape", "circle", "geometry", "trigonometry", "radii", "calculate", "measure", "size"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1165. rail-symbol
CREATE icon:rail_symbol CONTENT {
  identity: {
    value: 'rail_symbol',
    slug: 'rail-symbol'
  },
  presentation: {
    name_i18n: i18n_key:icon_rail_symbol_name,
    label_i18n: i18n_key:icon_rail_symbol_label,
    keywords: ["rail-symbol", "railway", "train", "track", "line"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1166. rainbow
CREATE icon:rainbow CONTENT {
  identity: {
    value: 'rainbow',
    slug: 'rainbow'
  },
  presentation: {
    name_i18n: i18n_key:icon_rainbow_name,
    label_i18n: i18n_key:icon_rainbow_label,
    keywords: ["rainbow", "colors", "colours", "spectrum", "light", "prism", "arc", "clear", "sunshine"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1167. rat
CREATE icon:rat CONTENT {
  identity: {
    value: 'rat',
    slug: 'rat'
  },
  presentation: {
    name_i18n: i18n_key:icon_rat_name,
    label_i18n: i18n_key:icon_rat_label,
    keywords: ["rat", "mouse", "mice", "gerbil", "rodent", "pet", "pest", "plague", "disease"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1168. ratio
CREATE icon:ratio CONTENT {
  identity: {
    value: 'ratio',
    slug: 'ratio'
  },
  presentation: {
    name_i18n: i18n_key:icon_ratio_name,
    label_i18n: i18n_key:icon_ratio_label,
    keywords: ["ratio", "screens", "sizes", "rotate", "rotation", "adjust", "aspect ratio", "proportions", "16:9", "widescreen", "4:3", "resolution", "responsive", "mobile", "desktop", "dimensions", "monitor", "orientation", "portrait", "landscape"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1169. receipt-cent
CREATE icon:receipt_cent CONTENT {
  identity: {
    value: 'receipt_cent',
    slug: 'receipt-cent'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_cent_name,
    label_i18n: i18n_key:icon_receipt_cent_label,
    keywords: ["receipt-cent", "bill", "voucher", "slip", "check", "counterfoil", "currency", "cents", "dollar", "usd", "$", "\u00a2"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1170. receipt-euro
CREATE icon:receipt_euro CONTENT {
  identity: {
    value: 'receipt_euro',
    slug: 'receipt-euro'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_euro_name,
    label_i18n: i18n_key:icon_receipt_euro_label,
    keywords: ["receipt-euro", "bill", "voucher", "slip", "check", "counterfoil", "currency", "\u20ac"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1171. receipt-indian-rupee
CREATE icon:receipt_indian_rupee CONTENT {
  identity: {
    value: 'receipt_indian_rupee',
    slug: 'receipt-indian-rupee'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_indian_rupee_name,
    label_i18n: i18n_key:icon_receipt_indian_rupee_label,
    keywords: ["receipt-indian-rupee", "bill", "voucher", "slip", "check", "counterfoil", "currency", "inr", "\u20b9"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1172. receipt-japanese-yen
CREATE icon:receipt_japanese_yen CONTENT {
  identity: {
    value: 'receipt_japanese_yen',
    slug: 'receipt-japanese-yen'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_japanese_yen_name,
    label_i18n: i18n_key:icon_receipt_japanese_yen_label,
    keywords: ["receipt-japanese-yen", "bill", "voucher", "slip", "check", "counterfoil", "currency", "jpy", "\u00a5"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1173. receipt-pound-sterling
CREATE icon:receipt_pound_sterling CONTENT {
  identity: {
    value: 'receipt_pound_sterling',
    slug: 'receipt-pound-sterling'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_pound_sterling_name,
    label_i18n: i18n_key:icon_receipt_pound_sterling_label,
    keywords: ["receipt-pound-sterling", "bill", "voucher", "slip", "check", "counterfoil", "british", "currency", "gbp", "\u00a3"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1174. receipt-russian-ruble
CREATE icon:receipt_russian_ruble CONTENT {
  identity: {
    value: 'receipt_russian_ruble',
    slug: 'receipt-russian-ruble'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_russian_ruble_name,
    label_i18n: i18n_key:icon_receipt_russian_ruble_label,
    keywords: ["receipt-russian-ruble", "bill", "voucher", "slip", "check", "counterfoil", "currency", "rub", "\u20bd"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1175. receipt-swiss-franc
CREATE icon:receipt_swiss_franc CONTENT {
  identity: {
    value: 'receipt_swiss_franc',
    slug: 'receipt-swiss-franc'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_swiss_franc_name,
    label_i18n: i18n_key:icon_receipt_swiss_franc_label,
    keywords: ["receipt-swiss-franc", "bill", "voucher", "slip", "check", "counterfoil", "currency", "chf", "\u20a3"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1176. receipt-text
CREATE icon:receipt_text CONTENT {
  identity: {
    value: 'receipt_text',
    slug: 'receipt-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_text_name,
    label_i18n: i18n_key:icon_receipt_text_label,
    keywords: ["receipt-text", "bill", "voucher", "slip", "check", "counterfoil", "details", "small print", "terms", "conditions", "contract"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1177. receipt-turkish-lira
CREATE icon:receipt_turkish_lira CONTENT {
  identity: {
    value: 'receipt_turkish_lira',
    slug: 'receipt-turkish-lira'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_turkish_lira_name,
    label_i18n: i18n_key:icon_receipt_turkish_lira_label,
    keywords: ["receipt-turkish-lira", "bill", "voucher", "slip", "check", "counterfoil", "currency", "try", "\u20ba"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1178. receipt
CREATE icon:receipt CONTENT {
  identity: {
    value: 'receipt',
    slug: 'receipt'
  },
  presentation: {
    name_i18n: i18n_key:icon_receipt_name,
    label_i18n: i18n_key:icon_receipt_label,
    keywords: ["receipt", "bill", "voucher", "slip", "check", "counterfoil", "currency", "dollar", "usd", "$"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1179. rectangle-circle
CREATE icon:rectangle_circle CONTENT {
  identity: {
    value: 'rectangle_circle',
    slug: 'rectangle-circle'
  },
  presentation: {
    name_i18n: i18n_key:icon_rectangle_circle_name,
    label_i18n: i18n_key:icon_rectangle_circle_label,
    keywords: ["rectangle-circle", "compose", "keyboard", "key", "button"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1180. rectangle-ellipsis
CREATE icon:rectangle_ellipsis CONTENT {
  identity: {
    value: 'rectangle_ellipsis',
    slug: 'rectangle-ellipsis'
  },
  presentation: {
    name_i18n: i18n_key:icon_rectangle_ellipsis_name,
    label_i18n: i18n_key:icon_rectangle_ellipsis_label,
    keywords: ["rectangle-ellipsis", "login", "password", "authenticate", "2fa", "field", "fill", "ellipsis", "et cetera", "etc", "loader", "loading", "progress", "pending", "throbber", "menu", "options", "operator", "code", "spread", "rest", "more", "further", "extra", "overflow", "dots", "\u2026", "..."]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1181. rectangle-goggles
CREATE icon:rectangle_goggles CONTENT {
  identity: {
    value: 'rectangle_goggles',
    slug: 'rectangle-goggles'
  },
  presentation: {
    name_i18n: i18n_key:icon_rectangle_goggles_name,
    label_i18n: i18n_key:icon_rectangle_goggles_label,
    keywords: ["rectangle-goggles", "vr", "virtual", "augmented", "reality", "headset", "goggles"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1182. rectangle-horizontal
CREATE icon:rectangle_horizontal CONTENT {
  identity: {
    value: 'rectangle_horizontal',
    slug: 'rectangle-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_rectangle_horizontal_name,
    label_i18n: i18n_key:icon_rectangle_horizontal_label,
    keywords: ["rectangle-horizontal", "rectangle", "aspect ratio", "16:9", "horizontal", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1183. rectangle-vertical
CREATE icon:rectangle_vertical CONTENT {
  identity: {
    value: 'rectangle_vertical',
    slug: 'rectangle-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_rectangle_vertical_name,
    label_i18n: i18n_key:icon_rectangle_vertical_label,
    keywords: ["rectangle-vertical", "rectangle", "aspect ratio", "9:16", "vertical", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1184. recycle
CREATE icon:recycle CONTENT {
  identity: {
    value: 'recycle',
    slug: 'recycle'
  },
  presentation: {
    name_i18n: i18n_key:icon_recycle_name,
    label_i18n: i18n_key:icon_recycle_label,
    keywords: ["recycle", "sustainability", "salvage", "arrows"]
  },
  context: {
    category: icon_category:sustainability,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1185. redo-2
CREATE icon:redo_2 CONTENT {
  identity: {
    value: 'redo_2',
    slug: 'redo-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_redo_2_name,
    label_i18n: i18n_key:icon_redo_2_label,
    keywords: ["redo-2", "undo", "rerun", "history"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1186. redo-dot
CREATE icon:redo_dot CONTENT {
  identity: {
    value: 'redo_dot',
    slug: 'redo-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_redo_dot_name,
    label_i18n: i18n_key:icon_redo_dot_label,
    keywords: ["redo-dot", "redo", "history", "step", "over", "forward"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1187. redo
CREATE icon:redo CONTENT {
  identity: {
    value: 'redo',
    slug: 'redo'
  },
  presentation: {
    name_i18n: i18n_key:icon_redo_name,
    label_i18n: i18n_key:icon_redo_label,
    keywords: ["redo", "undo", "rerun", "history"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1188. refresh-ccw-dot
CREATE icon:refresh_ccw_dot CONTENT {
  identity: {
    value: 'refresh_ccw_dot',
    slug: 'refresh-ccw-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_refresh_ccw_dot_name,
    label_i18n: i18n_key:icon_refresh_ccw_dot_label,
    keywords: ["refresh-ccw-dot", "arrows", "rotate", "reload", "synchronise", "synchronize", "circular", "cycle", "issue", "code", "coding", "version control"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1189. refresh-ccw
CREATE icon:refresh_ccw CONTENT {
  identity: {
    value: 'refresh_ccw',
    slug: 'refresh-ccw'
  },
  presentation: {
    name_i18n: i18n_key:icon_refresh_ccw_name,
    label_i18n: i18n_key:icon_refresh_ccw_label,
    keywords: ["refresh-ccw", "arrows", "rotate", "reload", "rerun", "synchronise", "synchronize", "circular", "cycle"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1190. refresh-cw-off
CREATE icon:refresh_cw_off CONTENT {
  identity: {
    value: 'refresh_cw_off',
    slug: 'refresh-cw-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_refresh_cw_off_name,
    label_i18n: i18n_key:icon_refresh_cw_off_label,
    keywords: ["refresh-cw-off", "rotate", "reload", "rerun", "synchronise", "synchronize", "arrows", "circular", "cycle", "cancel", "no", "stop", "error", "disconnect", "ignore"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1191. refresh-cw
CREATE icon:refresh_cw CONTENT {
  identity: {
    value: 'refresh_cw',
    slug: 'refresh-cw'
  },
  presentation: {
    name_i18n: i18n_key:icon_refresh_cw_name,
    label_i18n: i18n_key:icon_refresh_cw_label,
    keywords: ["refresh-cw", "rotate", "reload", "rerun", "synchronise", "synchronize", "arrows", "circular", "cycle"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1192. refrigerator
CREATE icon:refrigerator CONTENT {
  identity: {
    value: 'refrigerator',
    slug: 'refrigerator'
  },
  presentation: {
    name_i18n: i18n_key:icon_refrigerator_name,
    label_i18n: i18n_key:icon_refrigerator_label,
    keywords: ["refrigerator", "frigerator", "fridge", "freezer", "cooler", "icebox", "chiller", "cold storage"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1193. regex
CREATE icon:regex CONTENT {
  identity: {
    value: 'regex',
    slug: 'regex'
  },
  presentation: {
    name_i18n: i18n_key:icon_regex_name,
    label_i18n: i18n_key:icon_regex_label,
    keywords: ["regex", "search", "text", "code"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1194. remove-formatting
CREATE icon:remove_formatting CONTENT {
  identity: {
    value: 'remove_formatting',
    slug: 'remove-formatting'
  },
  presentation: {
    name_i18n: i18n_key:icon_remove_formatting_name,
    label_i18n: i18n_key:icon_remove_formatting_label,
    keywords: ["remove-formatting", "text", "font", "typography", "format", "x", "remove", "delete", "times", "clear"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1195. repeat-1
CREATE icon:repeat_1 CONTENT {
  identity: {
    value: 'repeat_1',
    slug: 'repeat-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_repeat_1_name,
    label_i18n: i18n_key:icon_repeat_1_label,
    keywords: ["repeat-1", "replay"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1196. repeat-2
CREATE icon:repeat_2 CONTENT {
  identity: {
    value: 'repeat_2',
    slug: 'repeat-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_repeat_2_name,
    label_i18n: i18n_key:icon_repeat_2_label,
    keywords: ["repeat-2", "arrows", "retweet", "repost", "share", "repeat", "loop"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1197. repeat
CREATE icon:repeat CONTENT {
  identity: {
    value: 'repeat',
    slug: 'repeat'
  },
  presentation: {
    name_i18n: i18n_key:icon_repeat_name,
    label_i18n: i18n_key:icon_repeat_label,
    keywords: ["repeat", "loop", "arrows"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1198. replace-all
CREATE icon:replace_all CONTENT {
  identity: {
    value: 'replace_all',
    slug: 'replace-all'
  },
  presentation: {
    name_i18n: i18n_key:icon_replace_all_name,
    label_i18n: i18n_key:icon_replace_all_label,
    keywords: ["replace-all", "search", "substitute", "swap", "change"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1199. replace
CREATE icon:replace CONTENT {
  identity: {
    value: 'replace',
    slug: 'replace'
  },
  presentation: {
    name_i18n: i18n_key:icon_replace_name,
    label_i18n: i18n_key:icon_replace_label,
    keywords: ["replace", "search", "substitute", "swap", "change"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1200. reply-all
CREATE icon:reply_all CONTENT {
  identity: {
    value: 'reply_all',
    slug: 'reply-all'
  },
  presentation: {
    name_i18n: i18n_key:icon_reply_all_name,
    label_i18n: i18n_key:icon_reply_all_label,
    keywords: ["reply-all", "email"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1201. reply
CREATE icon:reply CONTENT {
  identity: {
    value: 'reply',
    slug: 'reply'
  },
  presentation: {
    name_i18n: i18n_key:icon_reply_name,
    label_i18n: i18n_key:icon_reply_label,
    keywords: ["reply", "email"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1202. rewind
CREATE icon:rewind CONTENT {
  identity: {
    value: 'rewind',
    slug: 'rewind'
  },
  presentation: {
    name_i18n: i18n_key:icon_rewind_name,
    label_i18n: i18n_key:icon_rewind_label,
    keywords: ["rewind", "music"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1203. ribbon
CREATE icon:ribbon CONTENT {
  identity: {
    value: 'ribbon',
    slug: 'ribbon'
  },
  presentation: {
    name_i18n: i18n_key:icon_ribbon_name,
    label_i18n: i18n_key:icon_ribbon_label,
    keywords: ["ribbon", "awareness", "strip", "band", "tape", "strap", "cordon"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1204. rocket
CREATE icon:rocket CONTENT {
  identity: {
    value: 'rocket',
    slug: 'rocket'
  },
  presentation: {
    name_i18n: i18n_key:icon_rocket_name,
    label_i18n: i18n_key:icon_rocket_label,
    keywords: ["rocket", "release", "boost", "launch", "space", "version"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1205. rocking-chair
CREATE icon:rocking_chair CONTENT {
  identity: {
    value: 'rocking_chair',
    slug: 'rocking-chair'
  },
  presentation: {
    name_i18n: i18n_key:icon_rocking_chair_name,
    label_i18n: i18n_key:icon_rocking_chair_label,
    keywords: ["rocking-chair", "chair", "furniture", "seat"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1206. roller-coaster
CREATE icon:roller_coaster CONTENT {
  identity: {
    value: 'roller_coaster',
    slug: 'roller-coaster'
  },
  presentation: {
    name_i18n: i18n_key:icon_roller_coaster_name,
    label_i18n: i18n_key:icon_roller_coaster_label,
    keywords: ["roller-coaster", "attraction", "entertainment", "amusement park", "theme park", "funfair"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1207. rose
CREATE icon:rose CONTENT {
  identity: {
    value: 'rose',
    slug: 'rose'
  },
  presentation: {
    name_i18n: i18n_key:icon_rose_name,
    label_i18n: i18n_key:icon_rose_label,
    keywords: ["rose", "roses", "thorns", "petals", "plant", "stem", "leaves", "spring", "bloom", "blossom", "gardening", "botanical", "flora", "florist", "bouquet", "bunch", "gift", "date", "romance", "romantic", "valentines day", "special occasion"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1208. rotate-3d
CREATE icon:rotate_3d CONTENT {
  identity: {
    value: 'rotate_3d',
    slug: 'rotate-3d'
  },
  presentation: {
    name_i18n: i18n_key:icon_rotate_3d_name,
    label_i18n: i18n_key:icon_rotate_3d_label,
    keywords: ["rotate-3d", "gizmo", "transform", "orientation", "orbit", "axis"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1209. rotate-ccw-key
CREATE icon:rotate_ccw_key CONTENT {
  identity: {
    value: 'rotate_ccw_key',
    slug: 'rotate-ccw-key'
  },
  presentation: {
    name_i18n: i18n_key:icon_rotate_ccw_key_name,
    label_i18n: i18n_key:icon_rotate_ccw_key_label,
    keywords: ["rotate-ccw-key", "password", "key", "refresh", "change"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1210. rotate-ccw-square
CREATE icon:rotate_ccw_square CONTENT {
  identity: {
    value: 'rotate_ccw_square',
    slug: 'rotate-ccw-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_rotate_ccw_square_name,
    label_i18n: i18n_key:icon_rotate_ccw_square_label,
    keywords: ["rotate-ccw-square", "left", "counter-clockwise", "rotate", "image", "90", "45", "degrees", "\u00b0"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1211. rotate-ccw
CREATE icon:rotate_ccw CONTENT {
  identity: {
    value: 'rotate_ccw',
    slug: 'rotate-ccw'
  },
  presentation: {
    name_i18n: i18n_key:icon_rotate_ccw_name,
    label_i18n: i18n_key:icon_rotate_ccw_label,
    keywords: ["rotate-ccw", "arrow", "left", "counter-clockwise", "restart", "reload", "rerun", "refresh", "backup", "undo", "replay", "redo", "retry", "rewind", "reverse"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1212. rotate-cw-square
CREATE icon:rotate_cw_square CONTENT {
  identity: {
    value: 'rotate_cw_square',
    slug: 'rotate-cw-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_rotate_cw_square_name,
    label_i18n: i18n_key:icon_rotate_cw_square_label,
    keywords: ["rotate-cw-square", "right", "clockwise", "rotate", "image", "90", "45", "degrees", "\u00b0"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1213. rotate-cw
CREATE icon:rotate_cw CONTENT {
  identity: {
    value: 'rotate_cw',
    slug: 'rotate-cw'
  },
  presentation: {
    name_i18n: i18n_key:icon_rotate_cw_name,
    label_i18n: i18n_key:icon_rotate_cw_label,
    keywords: ["rotate-cw", "arrow", "right", "clockwise", "refresh", "reload", "rerun", "redo"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1214. route-off
CREATE icon:route_off CONTENT {
  identity: {
    value: 'route_off',
    slug: 'route-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_route_off_name,
    label_i18n: i18n_key:icon_route_off_label,
    keywords: ["route-off", "path", "journey", "planner", "points", "stops", "stations", "reset", "clear", "cancelled", "closed", "blocked"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1215. route
CREATE icon:route CONTENT {
  identity: {
    value: 'route',
    slug: 'route'
  },
  presentation: {
    name_i18n: i18n_key:icon_route_name,
    label_i18n: i18n_key:icon_route_label,
    keywords: ["route", "path", "journey", "planner", "points", "stops", "stations"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1216. router
CREATE icon:router CONTENT {
  identity: {
    value: 'router',
    slug: 'router'
  },
  presentation: {
    name_i18n: i18n_key:icon_router_name,
    label_i18n: i18n_key:icon_router_label,
    keywords: ["router", "computer", "server", "cloud"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1217. rows-2
CREATE icon:rows_2 CONTENT {
  identity: {
    value: 'rows_2',
    slug: 'rows-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_rows_2_name,
    label_i18n: i18n_key:icon_rows_2_label,
    keywords: ["rows-2", "lines", "list", "queue", "preview", "panel", "paragraphs", "parallel", "series", "split", "vertical", "horizontal", "half", "center", "middle", "even", "drawer"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1218. rows-3
CREATE icon:rows_3 CONTENT {
  identity: {
    value: 'rows_3',
    slug: 'rows-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_rows_3_name,
    label_i18n: i18n_key:icon_rows_3_label,
    keywords: ["rows-3", "lines", "list", "queue", "preview", "paragraphs", "parallel", "series", "split", "vertical", "horizontal", "half", "center", "middle", "even", "drawers"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1219. rows-4
CREATE icon:rows_4 CONTENT {
  identity: {
    value: 'rows_4',
    slug: 'rows-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_rows_4_name,
    label_i18n: i18n_key:icon_rows_4_label,
    keywords: ["rows-4", "lines", "list", "queue", "preview", "paragraphs", "parallel", "series", "split", "vertical", "horizontal", "half", "center", "middle", "even", "drawers", "grill"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1220. rss
CREATE icon:rss CONTENT {
  identity: {
    value: 'rss',
    slug: 'rss'
  },
  presentation: {
    name_i18n: i18n_key:icon_rss_name,
    label_i18n: i18n_key:icon_rss_label,
    keywords: ["rss", "feed", "subscribe", "news", "updates", "notifications", "content", "blog", "articles", "broadcast", "syndication", "reader", "channels", "posts", "publishing", "digest", "alert", "following", "inbox", "newsletter", "weblog", "podcast"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1221. ruler-dimension-line
CREATE icon:ruler_dimension_line CONTENT {
  identity: {
    value: 'ruler_dimension_line',
    slug: 'ruler-dimension-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_ruler_dimension_line_name,
    label_i18n: i18n_key:icon_ruler_dimension_line_label,
    keywords: ["ruler-dimension-line", "measurements", "centimeters", "cm", "millimeters", "mm", "metre", "foot", "feet", "inches", "units", "size", "length", "width", "height", "dimensions", "depth", "breadth", "extent", "stationery"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1222. ruler
CREATE icon:ruler CONTENT {
  identity: {
    value: 'ruler',
    slug: 'ruler'
  },
  presentation: {
    name_i18n: i18n_key:icon_ruler_name,
    label_i18n: i18n_key:icon_ruler_label,
    keywords: ["ruler", "measurements", "centimeters", "cm", "millimeters", "mm", "metre", "foot", "feet", "inches", "units", "size", "length", "width", "height", "dimensions", "depth", "breadth", "extent", "stationery"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1223. russian-ruble
CREATE icon:russian_ruble CONTENT {
  identity: {
    value: 'russian_ruble',
    slug: 'russian-ruble'
  },
  presentation: {
    name_i18n: i18n_key:icon_russian_ruble_name,
    label_i18n: i18n_key:icon_russian_ruble_label,
    keywords: ["russian-ruble", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1224. sailboat
CREATE icon:sailboat CONTENT {
  identity: {
    value: 'sailboat',
    slug: 'sailboat'
  },
  presentation: {
    name_i18n: i18n_key:icon_sailboat_name,
    label_i18n: i18n_key:icon_sailboat_label,
    keywords: ["sailboat", "ship", "boat", "harbor", "harbour", "dock"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1225. salad
CREATE icon:salad CONTENT {
  identity: {
    value: 'salad',
    slug: 'salad'
  },
  presentation: {
    name_i18n: i18n_key:icon_salad_name,
    label_i18n: i18n_key:icon_salad_label,
    keywords: ["salad", "food", "vegetarian", "dish", "restaurant", "course", "meal", "side", "vegetables", "health"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1226. sandwich
CREATE icon:sandwich CONTENT {
  identity: {
    value: 'sandwich',
    slug: 'sandwich'
  },
  presentation: {
    name_i18n: i18n_key:icon_sandwich_name,
    label_i18n: i18n_key:icon_sandwich_label,
    keywords: ["sandwich", "food", "snack", "dish", "restaurant", "lunch", "meal"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1227. satellite-dish
CREATE icon:satellite_dish CONTENT {
  identity: {
    value: 'satellite_dish',
    slug: 'satellite-dish'
  },
  presentation: {
    name_i18n: i18n_key:icon_satellite_dish_name,
    label_i18n: i18n_key:icon_satellite_dish_label,
    keywords: ["satellite-dish", "antenna", "receiver", "dish aerial", "saucer"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1228. satellite
CREATE icon:satellite CONTENT {
  identity: {
    value: 'satellite',
    slug: 'satellite'
  },
  presentation: {
    name_i18n: i18n_key:icon_satellite_name,
    label_i18n: i18n_key:icon_satellite_label,
    keywords: ["satellite", "space station", "orbit", "transmitter"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1229. saudi-riyal
CREATE icon:saudi_riyal CONTENT {
  identity: {
    value: 'saudi_riyal',
    slug: 'saudi-riyal'
  },
  presentation: {
    name_i18n: i18n_key:icon_saudi_riyal_name,
    label_i18n: i18n_key:icon_saudi_riyal_label,
    keywords: ["saudi-riyal", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1230. save-all
CREATE icon:save_all CONTENT {
  identity: {
    value: 'save_all',
    slug: 'save-all'
  },
  presentation: {
    name_i18n: i18n_key:icon_save_all_name,
    label_i18n: i18n_key:icon_save_all_label,
    keywords: ["save-all", "floppy disks", "copy"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1231. save-off
CREATE icon:save_off CONTENT {
  identity: {
    value: 'save_off',
    slug: 'save-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_save_off_name,
    label_i18n: i18n_key:icon_save_off_label,
    keywords: ["save-off", "floppy disk", "unsalvageable"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1232. save
CREATE icon:save CONTENT {
  identity: {
    value: 'save',
    slug: 'save'
  },
  presentation: {
    name_i18n: i18n_key:icon_save_name,
    label_i18n: i18n_key:icon_save_label,
    keywords: ["save", "floppy disk"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1233. scale-3d
CREATE icon:scale_3d CONTENT {
  identity: {
    value: 'scale_3d',
    slug: 'scale-3d'
  },
  presentation: {
    name_i18n: i18n_key:icon_scale_3d_name,
    label_i18n: i18n_key:icon_scale_3d_label,
    keywords: ["scale-3d", "gizmo", "transform", "size", "axis"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1234. scale
CREATE icon:scale CONTENT {
  identity: {
    value: 'scale',
    slug: 'scale'
  },
  presentation: {
    name_i18n: i18n_key:icon_scale_name,
    label_i18n: i18n_key:icon_scale_label,
    keywords: ["scale", "balance", "legal", "license", "right", "rule", "law"]
  },
  context: {
    category: icon_category:navigation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1235. scaling
CREATE icon:scaling CONTENT {
  identity: {
    value: 'scaling',
    slug: 'scaling'
  },
  presentation: {
    name_i18n: i18n_key:icon_scaling_name,
    label_i18n: i18n_key:icon_scaling_label,
    keywords: ["scaling", "scale", "resize", "design"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1236. scan-barcode
CREATE icon:scan_barcode CONTENT {
  identity: {
    value: 'scan_barcode',
    slug: 'scan-barcode'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_barcode_name,
    label_i18n: i18n_key:icon_scan_barcode_label,
    keywords: ["scan-barcode", "checkout", "till", "cart", "transaction", "purchase", "buy", "product", "packaging", "retail", "consumer"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1237. scan-eye
CREATE icon:scan_eye CONTENT {
  identity: {
    value: 'scan_eye',
    slug: 'scan-eye'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_eye_name,
    label_i18n: i18n_key:icon_scan_eye_label,
    keywords: ["scan-eye", "preview", "zoom", "expand", "fullscreen", "gallery", "image", "camera", "watch", "surveillance", "retina", "focus", "lens", "biometric", "identification", "authentication", "access", "login"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1238. scan-face
CREATE icon:scan_face CONTENT {
  identity: {
    value: 'scan_face',
    slug: 'scan-face'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_face_name,
    label_i18n: i18n_key:icon_scan_face_label,
    keywords: ["scan-face", "face", "biometric", "identification", "authentication", "2fa", "access", "login", "dashed"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1239. scan-heart
CREATE icon:scan_heart CONTENT {
  identity: {
    value: 'scan_heart',
    slug: 'scan-heart'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_heart_name,
    label_i18n: i18n_key:icon_scan_heart_label,
    keywords: ["scan-heart", "health", "heart rate", "pulse", "monitoring", "healthiness", "screening", "dashed"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1240. scan-line
CREATE icon:scan_line CONTENT {
  identity: {
    value: 'scan_line',
    slug: 'scan-line'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_line_name,
    label_i18n: i18n_key:icon_scan_line_label,
    keywords: ["scan-line", "checkout", "till", "cart", "transaction", "purchase", "buy", "product", "packaging", "retail", "consumer", "qr-code", "dashed"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1241. scan-qr-code
CREATE icon:scan_qr_code CONTENT {
  identity: {
    value: 'scan_qr_code',
    slug: 'scan-qr-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_qr_code_name,
    label_i18n: i18n_key:icon_scan_qr_code_label,
    keywords: ["scan-qr-code", "barcode", "scan", "qrcode", "url", "information", "digital", "scanner"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1242. scan-search
CREATE icon:scan_search CONTENT {
  identity: {
    value: 'scan_search',
    slug: 'scan-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_search_name,
    label_i18n: i18n_key:icon_scan_search_label,
    keywords: ["scan-search", "preview", "zoom", "expand", "fullscreen", "gallery", "image", "focus", "lens"]
  },
  context: {
    category: icon_category:photography,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1243. scan-text
CREATE icon:scan_text CONTENT {
  identity: {
    value: 'scan_text',
    slug: 'scan-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_text_name,
    label_i18n: i18n_key:icon_scan_text_label,
    keywords: ["scan-text", "recognition", "read", "translate", "copy", "lines"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1244. scan
CREATE icon:scan CONTENT {
  identity: {
    value: 'scan',
    slug: 'scan'
  },
  presentation: {
    name_i18n: i18n_key:icon_scan_name,
    label_i18n: i18n_key:icon_scan_label,
    keywords: ["scan", "qr-code", "barcode", "checkout", "augmented reality", "ar", "target", "surveillance", "camera", "lens", "focus", "frame", "select", "box", "boundary", "bounds", "area", "square", "dashed"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1245. school
CREATE icon:school CONTENT {
  identity: {
    value: 'school',
    slug: 'school'
  },
  presentation: {
    name_i18n: i18n_key:icon_school_name,
    label_i18n: i18n_key:icon_school_label,
    keywords: ["school", "building", "education", "childhood", "university", "learning", "campus", "scholar", "student", "lecture", "degree", "course", "academia", "study", "knowledge", "classroom", "research", "diploma", "graduation", "professor", "tutorial", "homework", "assignment", "exam"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1246. scissors-line-dashed
CREATE icon:scissors_line_dashed CONTENT {
  identity: {
    value: 'scissors_line_dashed',
    slug: 'scissors-line-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_scissors_line_dashed_name,
    label_i18n: i18n_key:icon_scissors_line_dashed_label,
    keywords: ["scissors-line-dashed", "cut here", "along", "snip", "chop", "stationery", "crafts", "instructions", "diagram"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1247. scissors
CREATE icon:scissors CONTENT {
  identity: {
    value: 'scissors',
    slug: 'scissors'
  },
  presentation: {
    name_i18n: i18n_key:icon_scissors_name,
    label_i18n: i18n_key:icon_scissors_label,
    keywords: ["scissors", "cut", "snip", "chop", "stationery", "crafts"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1248. screen-share-off
CREATE icon:screen_share_off CONTENT {
  identity: {
    value: 'screen_share_off',
    slug: 'screen-share-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_screen_share_off_name,
    label_i18n: i18n_key:icon_screen_share_off_label,
    keywords: ["screen-share-off", "desktop", "disconnect", "monitor"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1249. screen-share
CREATE icon:screen_share CONTENT {
  identity: {
    value: 'screen_share',
    slug: 'screen-share'
  },
  presentation: {
    name_i18n: i18n_key:icon_screen_share_name,
    label_i18n: i18n_key:icon_screen_share_label,
    keywords: ["screen-share", "host", "desktop", "monitor"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1250. scroll-text
CREATE icon:scroll_text CONTENT {
  identity: {
    value: 'scroll_text',
    slug: 'scroll-text'
  },
  presentation: {
    name_i18n: i18n_key:icon_scroll_text_name,
    label_i18n: i18n_key:icon_scroll_text_label,
    keywords: ["scroll-text", "paper", "log", "scripture", "document", "notes", "parchment", "list", "long", "script", "story", "code", "coding"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1251. scroll
CREATE icon:scroll CONTENT {
  identity: {
    value: 'scroll',
    slug: 'scroll'
  },
  presentation: {
    name_i18n: i18n_key:icon_scroll_name,
    label_i18n: i18n_key:icon_scroll_label,
    keywords: ["scroll", "paper", "log", "scripture", "document", "notes", "parchment", "list", "long", "script", "story", "code", "coding"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1252. search-check
CREATE icon:search_check CONTENT {
  identity: {
    value: 'search_check',
    slug: 'search-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_search_check_name,
    label_i18n: i18n_key:icon_search_check_label,
    keywords: ["search-check", "find", "scan", "magnifier", "magnifying glass", "found", "correct", "complete", "tick", "lens"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1253. search-code
CREATE icon:search_code CONTENT {
  identity: {
    value: 'search_code',
    slug: 'search-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_search_code_name,
    label_i18n: i18n_key:icon_search_code_label,
    keywords: ["search-code", "find", "scan", "magnifier", "magnifying glass", "grep", "chevrons", "<>", "lens"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1254. search-slash
CREATE icon:search_slash CONTENT {
  identity: {
    value: 'search_slash',
    slug: 'search-slash'
  },
  presentation: {
    name_i18n: i18n_key:icon_search_slash_name,
    label_i18n: i18n_key:icon_search_slash_label,
    keywords: ["search-slash", "find", "scan", "magnifier", "magnifying glass", "stop", "clear", "cancel", "abort", "/", "lens"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1255. search-x
CREATE icon:search_x CONTENT {
  identity: {
    value: 'search_x',
    slug: 'search-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_search_x_name,
    label_i18n: i18n_key:icon_search_x_label,
    keywords: ["search-x", "find", "scan", "magnifier", "magnifying glass", "stop", "clear", "cancel", "abort", "lens"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1256. search
CREATE icon:search CONTENT {
  identity: {
    value: 'search',
    slug: 'search'
  },
  presentation: {
    name_i18n: i18n_key:icon_search_name,
    label_i18n: i18n_key:icon_search_label,
    keywords: ["search", "find", "scan", "magnifier", "magnifying glass", "lens"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1257. section
CREATE icon:section CONTENT {
  identity: {
    value: 'section',
    slug: 'section'
  },
  presentation: {
    name_i18n: i18n_key:icon_section_name,
    label_i18n: i18n_key:icon_section_label,
    keywords: ["section", "mark", "typography", "punctuation", "legal", "type", "text", "prose", "symbol"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1258. send-horizontal
CREATE icon:send_horizontal CONTENT {
  identity: {
    value: 'send_horizontal',
    slug: 'send-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_send_horizontal_name,
    label_i18n: i18n_key:icon_send_horizontal_label,
    keywords: ["send-horizontal", "email", "message", "mail", "paper airplane", "paper aeroplane", "submit"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1259. send-to-back
CREATE icon:send_to_back CONTENT {
  identity: {
    value: 'send_to_back',
    slug: 'send-to-back'
  },
  presentation: {
    name_i18n: i18n_key:icon_send_to_back_name,
    label_i18n: i18n_key:icon_send_to_back_label,
    keywords: ["send-to-back", "bring", "send", "move", "under", "back", "backwards", "overlap", "layer", "order"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1260. send
CREATE icon:send CONTENT {
  identity: {
    value: 'send',
    slug: 'send'
  },
  presentation: {
    name_i18n: i18n_key:icon_send_name,
    label_i18n: i18n_key:icon_send_label,
    keywords: ["send", "email", "message", "mail", "paper airplane", "paper aeroplane", "submit"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1261. separator-horizontal
CREATE icon:separator_horizontal CONTENT {
  identity: {
    value: 'separator_horizontal',
    slug: 'separator-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_separator_horizontal_name,
    label_i18n: i18n_key:icon_separator_horizontal_label,
    keywords: ["separator-horizontal", "move", "split"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1262. separator-vertical
CREATE icon:separator_vertical CONTENT {
  identity: {
    value: 'separator_vertical',
    slug: 'separator-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_separator_vertical_name,
    label_i18n: i18n_key:icon_separator_vertical_label,
    keywords: ["separator-vertical", "move", "split"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1263. server-cog
CREATE icon:server_cog CONTENT {
  identity: {
    value: 'server_cog',
    slug: 'server-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_server_cog_name,
    label_i18n: i18n_key:icon_server_cog_label,
    keywords: ["server-cog", "cloud", "storage", "computing", "cog", "gear"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1264. server-crash
CREATE icon:server_crash CONTENT {
  identity: {
    value: 'server_crash',
    slug: 'server-crash'
  },
  presentation: {
    name_i18n: i18n_key:icon_server_crash_name,
    label_i18n: i18n_key:icon_server_crash_label,
    keywords: ["server-crash", "cloud", "storage", "problem", "error"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1265. server-off
CREATE icon:server_off CONTENT {
  identity: {
    value: 'server_off',
    slug: 'server-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_server_off_name,
    label_i18n: i18n_key:icon_server_off_label,
    keywords: ["server-off", "cloud", "storage"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1266. server
CREATE icon:server CONTENT {
  identity: {
    value: 'server',
    slug: 'server'
  },
  presentation: {
    name_i18n: i18n_key:icon_server_name,
    label_i18n: i18n_key:icon_server_label,
    keywords: ["server", "cloud", "storage"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1267. settings-2
CREATE icon:settings_2 CONTENT {
  identity: {
    value: 'settings_2',
    slug: 'settings-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_settings_2_name,
    label_i18n: i18n_key:icon_settings_2_label,
    keywords: ["settings-2", "cog", "edit", "gear", "preferences", "slider"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1268. settings
CREATE icon:settings CONTENT {
  identity: {
    value: 'settings',
    slug: 'settings'
  },
  presentation: {
    name_i18n: i18n_key:icon_settings_name,
    label_i18n: i18n_key:icon_settings_label,
    keywords: ["settings", "cog", "edit", "gear", "preferences"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1269. shapes
CREATE icon:shapes CONTENT {
  identity: {
    value: 'shapes',
    slug: 'shapes'
  },
  presentation: {
    name_i18n: i18n_key:icon_shapes_name,
    label_i18n: i18n_key:icon_shapes_label,
    keywords: ["shapes", "triangle", "equilateral", "square", "circle", "classification", "different", "collection", "toy", "blocks", "learning"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1270. share-2
CREATE icon:share_2 CONTENT {
  identity: {
    value: 'share_2',
    slug: 'share-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_share_2_name,
    label_i18n: i18n_key:icon_share_2_label,
    keywords: ["share-2", "network", "connections"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1271. share
CREATE icon:share CONTENT {
  identity: {
    value: 'share',
    slug: 'share'
  },
  presentation: {
    name_i18n: i18n_key:icon_share_name,
    label_i18n: i18n_key:icon_share_label,
    keywords: ["share", "network", "connections"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1272. sheet
CREATE icon:sheet CONTENT {
  identity: {
    value: 'sheet',
    slug: 'sheet'
  },
  presentation: {
    name_i18n: i18n_key:icon_sheet_name,
    label_i18n: i18n_key:icon_sheet_label,
    keywords: ["sheet", "spreadsheets", "table", "excel"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1273. shell
CREATE icon:shell CONTENT {
  identity: {
    value: 'shell',
    slug: 'shell'
  },
  presentation: {
    name_i18n: i18n_key:icon_shell_name,
    label_i18n: i18n_key:icon_shell_label,
    keywords: ["shell", "beach", "sand", "holiday", "sealife", "fossil", "ammonite", "biology", "ocean", "terminal", "command line", "session", "bash", "zsh", "roll", "wrap", "chewing gum", "bubble gum", "sweet", "sugar", "hosepipe", "carpet", "string", "spiral", "spinner", "hypnotise", "hypnosis"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1274. shield-alert
CREATE icon:shield_alert CONTENT {
  identity: {
    value: 'shield_alert',
    slug: 'shield-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_alert_name,
    label_i18n: i18n_key:icon_shield_alert_label,
    keywords: ["shield-alert", "unshielded", "cybersecurity", "insecure", "unsecured", "safety", "unsafe", "protection", "unprotected", "guardian", "unguarded", "unarmored", "unarmoured", "defenseless", "defenceless", "undefended", "defender", "blocked", "stopped", "intercepted", "interception", "saved", "thwarted", "threat", "prevention", "unprevented", "antivirus", "vigilance", "vigilant", "detection", "detected", "scanned", "found", "exploit", "vulnerability", "vulnerable", "weakness", "infection", "infected", "comprimised", "data leak", "audited", "admin", "verification", "unverified", "uncertified", "warning", "emergency", "attention", "urgent", "alarm", "crest", "bravery", "strength", "tough", "attacked", "damaged", "injured", "hit", "expired", "disabled", "inactive", "error", "exclamation mark", "!"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1275. shield-ban
CREATE icon:shield_ban CONTENT {
  identity: {
    value: 'shield_ban',
    slug: 'shield-ban'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_ban_name,
    label_i18n: i18n_key:icon_shield_ban_label,
    keywords: ["shield-ban", "unshielded", "cybersecurity", "insecure", "unsecured", "safety", "unsafe", "protection", "unprotected", "guardian", "unguarded", "unarmored", "unarmoured", "defenseless", "defenceless", "undefended", "defender", "blocked", "stopped", "intercepted", "interception", "saved", "thwarted", "threat", "prevention", "unprevented", "antivirus", "vigilance", "vigilant", "detection", "detected", "scanned", "found", "exploit", "vulnerability", "vulnerable", "weakness", "infection", "infected", "comprimised", "data leak", "audited", "admin", "verification", "unverified", "uncertified", "cancel", "error", "crest", "bravery", "attacked", "damaged", "injured", "hit", "expired", "eliminated", "disabled", "inactive", "/"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1276. shield-check
CREATE icon:shield_check CONTENT {
  identity: {
    value: 'shield_check',
    slug: 'shield-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_check_name,
    label_i18n: i18n_key:icon_shield_check_label,
    keywords: ["shield-check", "cybersecurity", "secured", "safety", "protection", "protected", "guardian", "guarded", "armored", "armoured", "defense", "defence", "defended", "blocked", "threat", "prevention", "prevented", "antivirus", "vigilance", "vigilant", "active", "activated", "enabled", "detection", "scanned", "found", "strength", "strong", "tough", "invincible", "invincibility", "invulnerable", "undamaged", "audited", "admin", "verification", "verified", "certification", "certified", "tested", "passed", "qualified", "cleared", "cleaned", "disinfected", "uninfected", "task", "completed", "todo", "done", "ticked", "checked", "crest", "bravery"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1277. shield-ellipsis
CREATE icon:shield_ellipsis CONTENT {
  identity: {
    value: 'shield_ellipsis',
    slug: 'shield-ellipsis'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_ellipsis_name,
    label_i18n: i18n_key:icon_shield_ellipsis_label,
    keywords: ["shield-ellipsis", "cybersecurity", "securing", "protecting", "guarding", "armoring", "armouring", "defending", "blocking", "preventing", "antivirus", "detecting", "scanning", "finding", "auditing", "admin", "verifying", "crest", "upgrading", "loader", "loading", "throbber", "progress", "dots", "more", "etc", "...", "\u2026"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1278. shield-half
CREATE icon:shield_half CONTENT {
  identity: {
    value: 'shield_half',
    slug: 'shield-half'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_half_name,
    label_i18n: i18n_key:icon_shield_half_label,
    keywords: ["shield-half", "cybersecurity", "secure", "safety", "protection", "guardian", "armored", "armoured", "defense", "defence", "defender", "block", "threat", "prevention", "antivirus", "vigilance", "vigilant", "detection", "scan", "strength", "strong", "tough", "invincible", "invincibility", "invulnerable", "undamaged", "audit", "admin", "verification", "crest", "logo", "sigil", "flag", "team", "faction", "fraternity", "university", "college", "academy", "school", "education", "uniform", "bravery", "knight", "foot soldier", "infantry", "trooper", "pawn", "battle", "war", "military", "ranking", "army", "cadet", "scout"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1279. shield-minus
CREATE icon:shield_minus CONTENT {
  identity: {
    value: 'shield_minus',
    slug: 'shield-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_minus_name,
    label_i18n: i18n_key:icon_shield_minus_label,
    keywords: ["shield-minus", "unshield", "cybersecurity", "unsecure", "unguard", "unblock", "antivirus", "clean", "clear", "disinfect", "patch", "fix", "stop", "cancel", "remove", "relax", "admin", "crest", "bravery", "weakened", "damaged", "hit", "unarm", "disable", "deactivate", "decommission", "downgraded", "minimum", "-"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1280. shield-off
CREATE icon:shield_off CONTENT {
  identity: {
    value: 'shield_off',
    slug: 'shield-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_off_name,
    label_i18n: i18n_key:icon_shield_off_label,
    keywords: ["shield-off", "unshielded", "cybersecurity", "insecure", "unsecured", "safety", "unsafe", "protection", "unprotected", "guardian", "unguarded", "unarmored", "unarmoured", "defenseless", "defenceless", "undefended", "defender", "interception", "threat", "prevention", "unprevented", "antivirus", "detection", "undetected", "exploit", "vulnerability", "vulnerable", "weakness", "infected", "infection", "comprimised", "data leak", "unaudited", "admin", "verification", "unverified", "inactive", "cancelled", "error", "crest", "bravery", "damaged", "injured", "hit", "expired", "eliminated"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1281. shield-plus
CREATE icon:shield_plus CONTENT {
  identity: {
    value: 'shield_plus',
    slug: 'shield-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_plus_name,
    label_i18n: i18n_key:icon_shield_plus_label,
    keywords: ["shield-plus", "cybersecurity", "secure", "safety", "protection", "guardian", "armored", "armoured", "defense", "defence", "defender", "block", "threat", "prevention", "antivirus", "vigilance", "vigilant", "detection", "scan", "strength", "strong", "tough", "invincible", "invincibility", "invulnerable", "undamaged", "extra", "added", "professional", "enterprise", "full", "maximum", "upgraded", "ultra", "activate", "enable", "audit", "admin", "verification", "crest", "medic", "+"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1282. shield-question-mark
CREATE icon:shield_question_mark CONTENT {
  identity: {
    value: 'shield_question_mark',
    slug: 'shield-question-mark'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_question_mark_name,
    label_i18n: i18n_key:icon_shield_question_mark_label,
    keywords: ["shield-question-mark", "unshielded", "cybersecurity", "insecure", "unsecured", "safety", "unsafe", "protection", "unprotected", "guardian", "unguarded", "unarmored", "unarmoured", "defenseless", "defenceless", "undefended", "defender", "threat", "prevention", "unprevented", "antivirus", "vigilance", "vigilant", "detection", "undetected", "scan", "find", "exploit", "vulnerability", "vulnerable", "weakness", "infection", "comprimised", "data leak", "audit", "admin", "verification", "unverified", "uncertified", "uncertain", "unknown", "inactive", "crest", "question mark", "?"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1283. shield-user
CREATE icon:shield_user CONTENT {
  identity: {
    value: 'shield_user',
    slug: 'shield-user'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_user_name,
    label_i18n: i18n_key:icon_shield_user_label,
    keywords: ["shield-user", "shield", "user", "admin", "protection", "protected", "safety", "guard"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1284. shield-x
CREATE icon:shield_x CONTENT {
  identity: {
    value: 'shield_x',
    slug: 'shield-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_x_name,
    label_i18n: i18n_key:icon_shield_x_label,
    keywords: ["shield-x", "unshielded", "cybersecurity", "insecure", "unsecured", "safety", "unsafe", "protection", "unprotected", "guardian", "unguarded", "unarmored", "unarmoured", "defenseless", "defenceless", "undefended", "defender", "blocked", "stopped", "intercepted", "interception", "saved", "thwarted", "threat", "prevention", "prevented", "antivirus", "vigilance", "vigilant", "detection", "detected", "scanned", "found", "exploit", "vulnerability", "vulnerable", "weakness", "infection", "infected", "comprimised", "data leak", "audited", "admin", "verification", "unverified", "inactive", "cancel", "error", "wrong", "false", "crest", "bravery", "attacked", "damaged", "injured", "hit", "dead", "deceased", "expired", "eliminated", "exterminated"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1285. shield
CREATE icon:shield CONTENT {
  identity: {
    value: 'shield',
    slug: 'shield'
  },
  presentation: {
    name_i18n: i18n_key:icon_shield_name,
    label_i18n: i18n_key:icon_shield_label,
    keywords: ["shield", "cybersecurity", "secure", "safety", "protection", "guardian", "armored", "armoured", "defense", "defence", "defender", "block", "threat", "prevention", "antivirus", "vigilance", "vigilant", "detection", "scan", "find", "strength", "strong", "tough", "invincible", "invincibility", "invulnerable", "undamaged", "audit", "admin", "verification", "crest", "bravery", "knight", "foot soldier", "infantry", "trooper", "pawn", "battle", "war", "military", "army", "cadet", "scout"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1286. ship-wheel
CREATE icon:ship_wheel CONTENT {
  identity: {
    value: 'ship_wheel',
    slug: 'ship-wheel'
  },
  presentation: {
    name_i18n: i18n_key:icon_ship_wheel_name,
    label_i18n: i18n_key:icon_ship_wheel_label,
    keywords: ["ship-wheel", "steering", "rudder", "boat", "knots", "nautical mile", "maritime", "sailing", "yacht", "cruise", "ocean liner", "tanker", "vessel", "navy", "trip"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1287. ship
CREATE icon:ship CONTENT {
  identity: {
    value: 'ship',
    slug: 'ship'
  },
  presentation: {
    name_i18n: i18n_key:icon_ship_name,
    label_i18n: i18n_key:icon_ship_label,
    keywords: ["ship", "boat", "knots", "nautical mile", "maritime", "sailing", "yacht", "cruise", "ocean liner", "tanker", "vessel", "navy", "trip", "releases"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1288. shirt
CREATE icon:shirt CONTENT {
  identity: {
    value: 'shirt',
    slug: 'shirt'
  },
  presentation: {
    name_i18n: i18n_key:icon_shirt_name,
    label_i18n: i18n_key:icon_shirt_label,
    keywords: ["shirt", "t-shirt", "shopping", "store", "clothing", "clothes"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1289. shopping-bag
CREATE icon:shopping_bag CONTENT {
  identity: {
    value: 'shopping_bag',
    slug: 'shopping-bag'
  },
  presentation: {
    name_i18n: i18n_key:icon_shopping_bag_name,
    label_i18n: i18n_key:icon_shopping_bag_label,
    keywords: ["shopping-bag", "ecommerce", "cart", "purchase", "store"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1290. shopping-basket
CREATE icon:shopping_basket CONTENT {
  identity: {
    value: 'shopping_basket',
    slug: 'shopping-basket'
  },
  presentation: {
    name_i18n: i18n_key:icon_shopping_basket_name,
    label_i18n: i18n_key:icon_shopping_basket_label,
    keywords: ["shopping-basket", "cart", "e-commerce", "store", "purchase", "products", "items", "ingredients"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1291. shopping-cart
CREATE icon:shopping_cart CONTENT {
  identity: {
    value: 'shopping_cart',
    slug: 'shopping-cart'
  },
  presentation: {
    name_i18n: i18n_key:icon_shopping_cart_name,
    label_i18n: i18n_key:icon_shopping_cart_label,
    keywords: ["shopping-cart", "trolley", "cart", "basket", "e-commerce", "store", "purchase", "products", "items", "ingredients"]
  },
  context: {
    category: icon_category:shopping,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1292. shovel
CREATE icon:shovel CONTENT {
  identity: {
    value: 'shovel',
    slug: 'shovel'
  },
  presentation: {
    name_i18n: i18n_key:icon_shovel_name,
    label_i18n: i18n_key:icon_shovel_label,
    keywords: ["shovel", "dig", "spade", "treasure"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1293. shower-head
CREATE icon:shower_head CONTENT {
  identity: {
    value: 'shower_head',
    slug: 'shower-head'
  },
  presentation: {
    name_i18n: i18n_key:icon_shower_head_name,
    label_i18n: i18n_key:icon_shower_head_label,
    keywords: ["shower-head", "shower", "bath", "bathroom", "amenities", "services"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1294. shredder
CREATE icon:shredder CONTENT {
  identity: {
    value: 'shredder',
    slug: 'shredder'
  },
  presentation: {
    name_i18n: i18n_key:icon_shredder_name,
    label_i18n: i18n_key:icon_shredder_label,
    keywords: ["shredder", "file", "paper", "tear", "cut", "delete", "destroy", "remove", "erase", "document", "destruction", "secure", "security", "confidential", "data", "trash", "dispose", "disposal", "information", "waste", "permanent"]
  },
  context: {
    category: icon_category:mail,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1295. shrimp
CREATE icon:shrimp CONTENT {
  identity: {
    value: 'shrimp',
    slug: 'shrimp'
  },
  presentation: {
    name_i18n: i18n_key:icon_shrimp_name,
    label_i18n: i18n_key:icon_shrimp_label,
    keywords: ["shrimp", "seafood", "shellfish", "crustacean", "prawn", "scallop", "whelk", "arthropod", "littleneck", "quahog", "cherrystone"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1296. shrink
CREATE icon:shrink CONTENT {
  identity: {
    value: 'shrink',
    slug: 'shrink'
  },
  presentation: {
    name_i18n: i18n_key:icon_shrink_name,
    label_i18n: i18n_key:icon_shrink_label,
    keywords: ["shrink", "scale", "fullscreen"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1297. shrub
CREATE icon:shrub CONTENT {
  identity: {
    value: 'shrub',
    slug: 'shrub'
  },
  presentation: {
    name_i18n: i18n_key:icon_shrub_name,
    label_i18n: i18n_key:icon_shrub_label,
    keywords: ["shrub", "forest", "undergrowth", "park", "nature"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1298. shuffle
CREATE icon:shuffle CONTENT {
  identity: {
    value: 'shuffle',
    slug: 'shuffle'
  },
  presentation: {
    name_i18n: i18n_key:icon_shuffle_name,
    label_i18n: i18n_key:icon_shuffle_label,
    keywords: ["shuffle", "music", "random", "reorder"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1299. sigma
CREATE icon:sigma CONTENT {
  identity: {
    value: 'sigma',
    slug: 'sigma'
  },
  presentation: {
    name_i18n: i18n_key:icon_sigma_name,
    label_i18n: i18n_key:icon_sigma_label,
    keywords: ["sigma", "sum", "calculate", "formula", "math", "enumeration", "enumerate"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1300. signal-high
CREATE icon:signal_high CONTENT {
  identity: {
    value: 'signal_high',
    slug: 'signal-high'
  },
  presentation: {
    name_i18n: i18n_key:icon_signal_high_name,
    label_i18n: i18n_key:icon_signal_high_label,
    keywords: ["signal-high", "connection", "wireless", "gsm", "phone", "2g", "3g", "4g", "5g"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1301. signal-low
CREATE icon:signal_low CONTENT {
  identity: {
    value: 'signal_low',
    slug: 'signal-low'
  },
  presentation: {
    name_i18n: i18n_key:icon_signal_low_name,
    label_i18n: i18n_key:icon_signal_low_label,
    keywords: ["signal-low", "connection", "wireless", "gsm", "phone", "2g", "3g", "4g", "5g"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1302. signal-medium
CREATE icon:signal_medium CONTENT {
  identity: {
    value: 'signal_medium',
    slug: 'signal-medium'
  },
  presentation: {
    name_i18n: i18n_key:icon_signal_medium_name,
    label_i18n: i18n_key:icon_signal_medium_label,
    keywords: ["signal-medium", "connection", "wireless", "gsm", "phone", "2g", "3g", "4g", "5g"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1303. signal-zero
CREATE icon:signal_zero CONTENT {
  identity: {
    value: 'signal_zero',
    slug: 'signal-zero'
  },
  presentation: {
    name_i18n: i18n_key:icon_signal_zero_name,
    label_i18n: i18n_key:icon_signal_zero_label,
    keywords: ["signal-zero", "connection", "wireless", "gsm", "phone", "2g", "3g", "4g", "5g", "lost"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1304. signal
CREATE icon:signal CONTENT {
  identity: {
    value: 'signal',
    slug: 'signal'
  },
  presentation: {
    name_i18n: i18n_key:icon_signal_name,
    label_i18n: i18n_key:icon_signal_label,
    keywords: ["signal", "connection", "wireless", "gsm", "phone", "2g", "3g", "4g", "5g"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1305. signature
CREATE icon:signature CONTENT {
  identity: {
    value: 'signature',
    slug: 'signature'
  },
  presentation: {
    name_i18n: i18n_key:icon_signature_name,
    label_i18n: i18n_key:icon_signature_label,
    keywords: ["signature", "text", "format", "input", "contract", "autograph", "handwriting", "sign", "cursive", "ink", "scribble", "authorize", "personal", "agreement", "legal", "document", "identity", "authentic", "approval", "verification", "unique"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1306. signpost-big
CREATE icon:signpost_big CONTENT {
  identity: {
    value: 'signpost_big',
    slug: 'signpost-big'
  },
  presentation: {
    name_i18n: i18n_key:icon_signpost_big_name,
    label_i18n: i18n_key:icon_signpost_big_label,
    keywords: ["signpost-big", "bidirectional", "left", "right", "east", "west"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1307. signpost
CREATE icon:signpost CONTENT {
  identity: {
    value: 'signpost',
    slug: 'signpost'
  },
  presentation: {
    name_i18n: i18n_key:icon_signpost_name,
    label_i18n: i18n_key:icon_signpost_label,
    keywords: ["signpost", "bidirectional", "left", "right", "east", "west"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1308. siren
CREATE icon:siren CONTENT {
  identity: {
    value: 'siren',
    slug: 'siren'
  },
  presentation: {
    name_i18n: i18n_key:icon_siren_name,
    label_i18n: i18n_key:icon_siren_label,
    keywords: ["siren", "police", "ambulance", "emergency", "security", "alert", "alarm", "light"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1309. skip-back
CREATE icon:skip_back CONTENT {
  identity: {
    value: 'skip_back',
    slug: 'skip-back'
  },
  presentation: {
    name_i18n: i18n_key:icon_skip_back_name,
    label_i18n: i18n_key:icon_skip_back_label,
    keywords: ["skip-back", "arrow", "previous", "music"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1310. skip-forward
CREATE icon:skip_forward CONTENT {
  identity: {
    value: 'skip_forward',
    slug: 'skip-forward'
  },
  presentation: {
    name_i18n: i18n_key:icon_skip_forward_name,
    label_i18n: i18n_key:icon_skip_forward_label,
    keywords: ["skip-forward", "arrow", "skip", "next", "music"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1311. skull
CREATE icon:skull CONTENT {
  identity: {
    value: 'skull',
    slug: 'skull'
  },
  presentation: {
    name_i18n: i18n_key:icon_skull_name,
    label_i18n: i18n_key:icon_skull_label,
    keywords: ["skull", "death", "danger", "bone"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1312. slack
CREATE icon:slack CONTENT {
  identity: {
    value: 'slack',
    slug: 'slack'
  },
  presentation: {
    name_i18n: i18n_key:icon_slack_name,
    label_i18n: i18n_key:icon_slack_label,
    keywords: ["slack", "logo"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1313. slash
CREATE icon:slash CONTENT {
  identity: {
    value: 'slash',
    slug: 'slash'
  },
  presentation: {
    name_i18n: i18n_key:icon_slash_name,
    label_i18n: i18n_key:icon_slash_label,
    keywords: ["slash", "divide", "division", "or", "/"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1314. slice
CREATE icon:slice CONTENT {
  identity: {
    value: 'slice',
    slug: 'slice'
  },
  presentation: {
    name_i18n: i18n_key:icon_slice_name,
    label_i18n: i18n_key:icon_slice_label,
    keywords: ["slice", "cutter", "scalpel", "knife"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1315. sliders-horizontal
CREATE icon:sliders_horizontal CONTENT {
  identity: {
    value: 'sliders_horizontal',
    slug: 'sliders-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_sliders_horizontal_name,
    label_i18n: i18n_key:icon_sliders_horizontal_label,
    keywords: ["sliders-horizontal", "settings", "filters", "controls"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1316. sliders-vertical
CREATE icon:sliders_vertical CONTENT {
  identity: {
    value: 'sliders_vertical',
    slug: 'sliders-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_sliders_vertical_name,
    label_i18n: i18n_key:icon_sliders_vertical_label,
    keywords: ["sliders-vertical", "settings", "controls"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1317. smartphone-charging
CREATE icon:smartphone_charging CONTENT {
  identity: {
    value: 'smartphone_charging',
    slug: 'smartphone-charging'
  },
  presentation: {
    name_i18n: i18n_key:icon_smartphone_charging_name,
    label_i18n: i18n_key:icon_smartphone_charging_label,
    keywords: ["smartphone-charging", "phone", "cellphone", "device", "power", "screen"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1318. smartphone-nfc
CREATE icon:smartphone_nfc CONTENT {
  identity: {
    value: 'smartphone_nfc',
    slug: 'smartphone-nfc'
  },
  presentation: {
    name_i18n: i18n_key:icon_smartphone_nfc_name,
    label_i18n: i18n_key:icon_smartphone_nfc_label,
    keywords: ["smartphone-nfc", "contactless", "payment", "near-field communication", "screen"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1319. smartphone
CREATE icon:smartphone CONTENT {
  identity: {
    value: 'smartphone',
    slug: 'smartphone'
  },
  presentation: {
    name_i18n: i18n_key:icon_smartphone_name,
    label_i18n: i18n_key:icon_smartphone_label,
    keywords: ["smartphone", "phone", "cellphone", "device", "screen"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1320. smile-plus
CREATE icon:smile_plus CONTENT {
  identity: {
    value: 'smile_plus',
    slug: 'smile-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_smile_plus_name,
    label_i18n: i18n_key:icon_smile_plus_label,
    keywords: ["smile-plus", "emoji", "face", "happy", "good", "emotion", "react", "reaction", "add"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1321. smile
CREATE icon:smile CONTENT {
  identity: {
    value: 'smile',
    slug: 'smile'
  },
  presentation: {
    name_i18n: i18n_key:icon_smile_name,
    label_i18n: i18n_key:icon_smile_label,
    keywords: ["smile", "emoji", "face", "happy", "good", "emotion"]
  },
  context: {
    category: icon_category:emoji,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1322. snail
CREATE icon:snail CONTENT {
  identity: {
    value: 'snail',
    slug: 'snail'
  },
  presentation: {
    name_i18n: i18n_key:icon_snail_name,
    label_i18n: i18n_key:icon_snail_label,
    keywords: ["snail", "animal", "insect", "slow", "speed", "delicacy", "spiral"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1323. snowflake
CREATE icon:snowflake CONTENT {
  identity: {
    value: 'snowflake',
    slug: 'snowflake'
  },
  presentation: {
    name_i18n: i18n_key:icon_snowflake_name,
    label_i18n: i18n_key:icon_snowflake_label,
    keywords: ["snowflake", "cold", "weather", "freeze", "snow", "winter"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1324. soap-dispenser-droplet
CREATE icon:soap_dispenser_droplet CONTENT {
  identity: {
    value: 'soap_dispenser_droplet',
    slug: 'soap-dispenser-droplet'
  },
  presentation: {
    name_i18n: i18n_key:icon_soap_dispenser_droplet_name,
    label_i18n: i18n_key:icon_soap_dispenser_droplet_label,
    keywords: ["soap-dispenser-droplet", "wash", "bath", "water", "liquid", "fluid", "wet", "moisture", "damp", "bead", "globule"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1325. sofa
CREATE icon:sofa CONTENT {
  identity: {
    value: 'sofa',
    slug: 'sofa'
  },
  presentation: {
    name_i18n: i18n_key:icon_sofa_name,
    label_i18n: i18n_key:icon_sofa_label,
    keywords: ["sofa", "armchair", "furniture", "leisure", "lounge", "loveseat", "couch"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1326. soup
CREATE icon:soup CONTENT {
  identity: {
    value: 'soup',
    slug: 'soup'
  },
  presentation: {
    name_i18n: i18n_key:icon_soup_name,
    label_i18n: i18n_key:icon_soup_label,
    keywords: ["soup", "food", "dish", "restaurant", "course", "meal", "bowl", "starter"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1327. space
CREATE icon:space CONTENT {
  identity: {
    value: 'space',
    slug: 'space'
  },
  presentation: {
    name_i18n: i18n_key:icon_space_name,
    label_i18n: i18n_key:icon_space_label,
    keywords: ["space", "text", "selection", "letters", "characters", "font", "typography"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1328. spade
CREATE icon:spade CONTENT {
  identity: {
    value: 'spade',
    slug: 'spade'
  },
  presentation: {
    name_i18n: i18n_key:icon_spade_name,
    label_i18n: i18n_key:icon_spade_label,
    keywords: ["spade", "shape", "suit", "playing", "cards"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1329. sparkle
CREATE icon:sparkle CONTENT {
  identity: {
    value: 'sparkle',
    slug: 'sparkle'
  },
  presentation: {
    name_i18n: i18n_key:icon_sparkle_name,
    label_i18n: i18n_key:icon_sparkle_label,
    keywords: ["sparkle", "star", "effect", "filter", "night", "magic", "shiny", "glitter", "twinkle", "celebration"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1330. sparkles
CREATE icon:sparkles CONTENT {
  identity: {
    value: 'sparkles',
    slug: 'sparkles'
  },
  presentation: {
    name_i18n: i18n_key:icon_sparkles_name,
    label_i18n: i18n_key:icon_sparkles_label,
    keywords: ["sparkles", "stars", "effect", "filter", "night", "magic"]
  },
  context: {
    category: icon_category:cursors,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1331. speaker
CREATE icon:speaker CONTENT {
  identity: {
    value: 'speaker',
    slug: 'speaker'
  },
  presentation: {
    name_i18n: i18n_key:icon_speaker_name,
    label_i18n: i18n_key:icon_speaker_label,
    keywords: ["speaker", "sound", "audio", "music", "tweeter", "subwoofer", "bass", "production", "producer", "dj"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1332. speech
CREATE icon:speech CONTENT {
  identity: {
    value: 'speech',
    slug: 'speech'
  },
  presentation: {
    name_i18n: i18n_key:icon_speech_name,
    label_i18n: i18n_key:icon_speech_label,
    keywords: ["speech", "disability", "disabled", "dda", "human", "accessibility", "people", "sound"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1333. spell-check-2
CREATE icon:spell_check_2 CONTENT {
  identity: {
    value: 'spell_check_2',
    slug: 'spell-check-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_spell_check_2_name,
    label_i18n: i18n_key:icon_spell_check_2_label,
    keywords: ["spell-check-2", "spelling", "error", "mistake", "oversight", "typo", "correction", "code", "linter", "a"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1334. spell-check
CREATE icon:spell_check CONTENT {
  identity: {
    value: 'spell_check',
    slug: 'spell-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_spell_check_name,
    label_i18n: i18n_key:icon_spell_check_label,
    keywords: ["spell-check", "spelling", "error", "mistake", "oversight", "typo", "correction", "code", "linter", "a"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1335. spline-pointer
CREATE icon:spline_pointer CONTENT {
  identity: {
    value: 'spline_pointer',
    slug: 'spline-pointer'
  },
  presentation: {
    name_i18n: i18n_key:icon_spline_pointer_name,
    label_i18n: i18n_key:icon_spline_pointer_label,
    keywords: ["spline-pointer", "path", "tool", "curve", "node", "click", "pointer", "target", "vector"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1336. spline
CREATE icon:spline CONTENT {
  identity: {
    value: 'spline',
    slug: 'spline'
  },
  presentation: {
    name_i18n: i18n_key:icon_spline_name,
    label_i18n: i18n_key:icon_spline_label,
    keywords: ["spline", "path", "pen", "tool", "shape", "curve", "draw"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1337. split
CREATE icon:split CONTENT {
  identity: {
    value: 'split',
    slug: 'split'
  },
  presentation: {
    name_i18n: i18n_key:icon_split_name,
    label_i18n: i18n_key:icon_split_label,
    keywords: ["split", "break", "disband", "divide", "separate", "branch", "disunite"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1338. spool
CREATE icon:spool CONTENT {
  identity: {
    value: 'spool',
    slug: 'spool'
  },
  presentation: {
    name_i18n: i18n_key:icon_spool_name,
    label_i18n: i18n_key:icon_spool_label,
    keywords: ["spool", "bobbin", "spindle", "yarn", "thread", "string", "sewing", "needlework"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1339. spotlight
CREATE icon:spotlight CONTENT {
  identity: {
    value: 'spotlight',
    slug: 'spotlight'
  },
  presentation: {
    name_i18n: i18n_key:icon_spotlight_name,
    label_i18n: i18n_key:icon_spotlight_label,
    keywords: ["spotlight", "winner", "soapbox", "stage", "entertainment", "drama", "podium", "actor", "actress", "singer", "light", "beam", "play", "theatre", "show", "focus", "concert", "performance", "lens", "leaderboard", "followspot", "best", "highlight"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1340. spray-can
CREATE icon:spray_can CONTENT {
  identity: {
    value: 'spray_can',
    slug: 'spray-can'
  },
  presentation: {
    name_i18n: i18n_key:icon_spray_can_name,
    label_i18n: i18n_key:icon_spray_can_label,
    keywords: ["spray-can", "paint", "color", "graffiti", "decoration", "aerosol", "deodorant", "shaving foam", "air freshener"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1341. sprout
CREATE icon:sprout CONTENT {
  identity: {
    value: 'sprout',
    slug: 'sprout'
  },
  presentation: {
    name_i18n: i18n_key:icon_sprout_name,
    label_i18n: i18n_key:icon_sprout_label,
    keywords: ["sprout", "eco", "green", "growth", "leaf", "nature", "plant", "seed", "spring", "sustainability"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1342. square-activity
CREATE icon:square_activity CONTENT {
  identity: {
    value: 'square_activity',
    slug: 'square-activity'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_activity_name,
    label_i18n: i18n_key:icon_square_activity_label,
    keywords: ["square-activity", "pulse", "action", "motion", "movement", "exercise", "fitness", "healthcare", "heart rate monitor", "vital signs", "vitals", "emergency room", "er", "intensive care", "hospital", "defibrillator", "earthquake", "siesmic", "magnitude", "richter scale", "aftershock", "tremor", "shockwave", "audio", "waveform", "synthesizer", "synthesiser", "music"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1343. square-arrow-down-left
CREATE icon:square_arrow_down_left CONTENT {
  identity: {
    value: 'square_arrow_down_left',
    slug: 'square-arrow-down-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_down_left_name,
    label_i18n: i18n_key:icon_square_arrow_down_left_label,
    keywords: ["square-arrow-down-left", "direction", "south-west", "diagonal", "sign", "turn", "keyboard", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1344. square-arrow-down-right
CREATE icon:square_arrow_down_right CONTENT {
  identity: {
    value: 'square_arrow_down_right',
    slug: 'square-arrow-down-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_down_right_name,
    label_i18n: i18n_key:icon_square_arrow_down_right_label,
    keywords: ["square-arrow-down-right", "direction", "south-east", "diagonal", "sign", "turn", "keyboard", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1345. square-arrow-down
CREATE icon:square_arrow_down CONTENT {
  identity: {
    value: 'square_arrow_down',
    slug: 'square-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_down_name,
    label_i18n: i18n_key:icon_square_arrow_down_label,
    keywords: ["square-arrow-down", "backwards", "reverse", "direction", "south", "sign", "keyboard", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1346. square-arrow-left
CREATE icon:square_arrow_left CONTENT {
  identity: {
    value: 'square_arrow_left',
    slug: 'square-arrow-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_left_name,
    label_i18n: i18n_key:icon_square_arrow_left_label,
    keywords: ["square-arrow-left", "previous", "back", "direction", "west", "sign", "keyboard", "button", "<-"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1347. square-arrow-out-down-left
CREATE icon:square_arrow_out_down_left CONTENT {
  identity: {
    value: 'square_arrow_out_down_left',
    slug: 'square-arrow-out-down-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_out_down_left_name,
    label_i18n: i18n_key:icon_square_arrow_out_down_left_label,
    keywords: ["square-arrow-out-down-left", "outwards", "direction", "south-west", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1348. square-arrow-out-down-right
CREATE icon:square_arrow_out_down_right CONTENT {
  identity: {
    value: 'square_arrow_out_down_right',
    slug: 'square-arrow-out-down-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_out_down_right_name,
    label_i18n: i18n_key:icon_square_arrow_out_down_right_label,
    keywords: ["square-arrow-out-down-right", "outwards", "direction", "south-east", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1349. square-arrow-out-up-left
CREATE icon:square_arrow_out_up_left CONTENT {
  identity: {
    value: 'square_arrow_out_up_left',
    slug: 'square-arrow-out-up-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_out_up_left_name,
    label_i18n: i18n_key:icon_square_arrow_out_up_left_label,
    keywords: ["square-arrow-out-up-left", "outwards", "direction", "north-west", "diagonal"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1350. square-arrow-out-up-right
CREATE icon:square_arrow_out_up_right CONTENT {
  identity: {
    value: 'square_arrow_out_up_right',
    slug: 'square-arrow-out-up-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_out_up_right_name,
    label_i18n: i18n_key:icon_square_arrow_out_up_right_label,
    keywords: ["square-arrow-out-up-right", "outwards", "direction", "north-east", "diagonal", "share", "open", "external", "link"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1351. square-arrow-right
CREATE icon:square_arrow_right CONTENT {
  identity: {
    value: 'square_arrow_right',
    slug: 'square-arrow-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_right_name,
    label_i18n: i18n_key:icon_square_arrow_right_label,
    keywords: ["square-arrow-right", "next", "forward", "direction", "west", "sign", "keyboard", "button", "->"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1352. square-arrow-up-left
CREATE icon:square_arrow_up_left CONTENT {
  identity: {
    value: 'square_arrow_up_left',
    slug: 'square-arrow-up-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_up_left_name,
    label_i18n: i18n_key:icon_square_arrow_up_left_label,
    keywords: ["square-arrow-up-left", "direction", "north-west", "diagonal", "sign", "keyboard", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1353. square-arrow-up-right
CREATE icon:square_arrow_up_right CONTENT {
  identity: {
    value: 'square_arrow_up_right',
    slug: 'square-arrow-up-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_up_right_name,
    label_i18n: i18n_key:icon_square_arrow_up_right_label,
    keywords: ["square-arrow-up-right", "direction", "north-east", "diagonal", "sign", "keyboard", "button", "share"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1354. square-arrow-up
CREATE icon:square_arrow_up CONTENT {
  identity: {
    value: 'square_arrow_up',
    slug: 'square-arrow-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_arrow_up_name,
    label_i18n: i18n_key:icon_square_arrow_up_label,
    keywords: ["square-arrow-up", "forward", "direction", "north", "sign", "keyboard", "button"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1355. square-asterisk
CREATE icon:square_asterisk CONTENT {
  identity: {
    value: 'square_asterisk',
    slug: 'square-asterisk'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_asterisk_name,
    label_i18n: i18n_key:icon_square_asterisk_label,
    keywords: ["square-asterisk", "password", "secret", "access", "key", "multiply", "multiplication", "glob pattern", "wildcard", "*"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1356. square-bottom-dashed-scissors
CREATE icon:square_bottom_dashed_scissors CONTENT {
  identity: {
    value: 'square_bottom_dashed_scissors',
    slug: 'square-bottom-dashed-scissors'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_bottom_dashed_scissors_name,
    label_i18n: i18n_key:icon_square_bottom_dashed_scissors_label,
    keywords: ["square-bottom-dashed-scissors", "cut", "snippet", "chop", "stationery", "crafts"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1357. square-chart-gantt
CREATE icon:square_chart_gantt CONTENT {
  identity: {
    value: 'square_chart_gantt',
    slug: 'square-chart-gantt'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_chart_gantt_name,
    label_i18n: i18n_key:icon_square_chart_gantt_label,
    keywords: ["square-chart-gantt", "projects", "manage", "overview", "roadmap", "plan", "intentions", "timeline", "deadline", "date", "event", "range", "period", "productivity", "work", "agile", "code", "coding", "toolbar", "button"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1358. square-check-big
CREATE icon:square_check_big CONTENT {
  identity: {
    value: 'square_check_big',
    slug: 'square-check-big'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_check_big_name,
    label_i18n: i18n_key:icon_square_check_big_label,
    keywords: ["square-check-big", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1359. square-check
CREATE icon:square_check CONTENT {
  identity: {
    value: 'square_check',
    slug: 'square-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_check_name,
    label_i18n: i18n_key:icon_square_check_label,
    keywords: ["square-check", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1360. square-chevron-down
CREATE icon:square_chevron_down CONTENT {
  identity: {
    value: 'square_chevron_down',
    slug: 'square-chevron-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_chevron_down_name,
    label_i18n: i18n_key:icon_square_chevron_down_label,
    keywords: ["square-chevron-down", "back", "menu", "panel"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1361. square-chevron-left
CREATE icon:square_chevron_left CONTENT {
  identity: {
    value: 'square_chevron_left',
    slug: 'square-chevron-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_chevron_left_name,
    label_i18n: i18n_key:icon_square_chevron_left_label,
    keywords: ["square-chevron-left", "back", "previous", "less than", "fewer", "menu", "panel", "button", "keyboard", "<"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1362. square-chevron-right
CREATE icon:square_chevron_right CONTENT {
  identity: {
    value: 'square_chevron_right',
    slug: 'square-chevron-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_chevron_right_name,
    label_i18n: i18n_key:icon_square_chevron_right_label,
    keywords: ["square-chevron-right", "forward", "next", "more than", "greater", "menu", "panel", "code", "coding", "command line", "terminal", "prompt", "shell", "console", ">"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1363. square-chevron-up
CREATE icon:square_chevron_up CONTENT {
  identity: {
    value: 'square_chevron_up',
    slug: 'square-chevron-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_chevron_up_name,
    label_i18n: i18n_key:icon_square_chevron_up_label,
    keywords: ["square-chevron-up", "caret", "keyboard", "button", "mac", "control", "ctrl", "superscript", "exponential", "power", "ahead", "menu", "panel", "^"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1364. square-code
CREATE icon:square_code CONTENT {
  identity: {
    value: 'square_code',
    slug: 'square-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_code_name,
    label_i18n: i18n_key:icon_square_code_label,
    keywords: ["square-code", "gist", "source", "programming", "html", "xml", "coding"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1365. square-dashed-bottom-code
CREATE icon:square_dashed_bottom_code CONTENT {
  identity: {
    value: 'square_dashed_bottom_code',
    slug: 'square-dashed-bottom-code'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dashed_bottom_code_name,
    label_i18n: i18n_key:icon_square_dashed_bottom_code_label,
    keywords: ["square-dashed-bottom-code", "rectangle", "aspect ratio", "1:1", "shape", "snippet", "code", "coding"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1366. square-dashed-bottom
CREATE icon:square_dashed_bottom CONTENT {
  identity: {
    value: 'square_dashed_bottom',
    slug: 'square-dashed-bottom'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dashed_bottom_name,
    label_i18n: i18n_key:icon_square_dashed_bottom_label,
    keywords: ["square-dashed-bottom", "rectangle", "aspect ratio", "1:1", "shape", "snippet", "code", "coding"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1367. square-dashed-kanban
CREATE icon:square_dashed_kanban CONTENT {
  identity: {
    value: 'square_dashed_kanban',
    slug: 'square-dashed-kanban'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dashed_kanban_name,
    label_i18n: i18n_key:icon_square_dashed_kanban_label,
    keywords: ["square-dashed-kanban", "projects", "manage", "overview", "board", "tickets", "issues", "roadmap", "plan", "intentions", "productivity", "work", "agile", "draft", "template", "boilerplate", "code", "coding"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1368. square-dashed-mouse-pointer
CREATE icon:square_dashed_mouse_pointer CONTENT {
  identity: {
    value: 'square_dashed_mouse_pointer',
    slug: 'square-dashed-mouse-pointer'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dashed_mouse_pointer_name,
    label_i18n: i18n_key:icon_square_dashed_mouse_pointer_label,
    keywords: ["square-dashed-mouse-pointer", "inspector", "element", "mouse", "click", "pointer", "box", "browser", "selector", "target", "dom", "node"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1369. square-dashed-top-solid
CREATE icon:square_dashed_top_solid CONTENT {
  identity: {
    value: 'square_dashed_top_solid',
    slug: 'square-dashed-top-solid'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dashed_top_solid_name,
    label_i18n: i18n_key:icon_square_dashed_top_solid_label,
    keywords: ["square-dashed-top-solid", "square", "border", "width", "layout", "style", "design", "rectangular", "marquee", "dashed", "box", "rectangle", "aspect ratio", "1:1"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1370. square-dashed
CREATE icon:square_dashed CONTENT {
  identity: {
    value: 'square_dashed',
    slug: 'square-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dashed_name,
    label_i18n: i18n_key:icon_square_dashed_label,
    keywords: ["square-dashed", "selection", "square", "rectangular", "marquee", "tool", "dashed", "box"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1371. square-divide
CREATE icon:square_divide CONTENT {
  identity: {
    value: 'square_divide',
    slug: 'square-divide'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_divide_name,
    label_i18n: i18n_key:icon_square_divide_label,
    keywords: ["square-divide", "calculate", "math", "\u00f7", "/"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1372. square-dot
CREATE icon:square_dot CONTENT {
  identity: {
    value: 'square_dot',
    slug: 'square-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_dot_name,
    label_i18n: i18n_key:icon_square_dot_label,
    keywords: ["square-dot", "git", "diff", "modified", "."]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1373. square-equal
CREATE icon:square_equal CONTENT {
  identity: {
    value: 'square_equal',
    slug: 'square-equal'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_equal_name,
    label_i18n: i18n_key:icon_square_equal_label,
    keywords: ["square-equal", "calculate", "="]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1374. square-function
CREATE icon:square_function CONTENT {
  identity: {
    value: 'square_function',
    slug: 'square-function'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_function_name,
    label_i18n: i18n_key:icon_square_function_label,
    keywords: ["square-function", "programming", "code", "automation", "math"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1375. square-kanban
CREATE icon:square_kanban CONTENT {
  identity: {
    value: 'square_kanban',
    slug: 'square-kanban'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_kanban_name,
    label_i18n: i18n_key:icon_square_kanban_label,
    keywords: ["square-kanban", "projects", "manage", "overview", "board", "tickets", "issues", "roadmap", "plan", "intentions", "productivity", "work", "agile", "code", "coding", "toolbar", "button"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1376. square-library
CREATE icon:square_library CONTENT {
  identity: {
    value: 'square_library',
    slug: 'square-library'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_library_name,
    label_i18n: i18n_key:icon_square_library_label,
    keywords: ["square-library", "books", "reading", "written", "authors", "stories", "fiction", "novels", "information", "knowledge", "education", "high school", "university", "college", "academy", "learning", "study", "research", "collection", "vinyl", "records", "albums", "music", "package"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1377. square-m
CREATE icon:square_m CONTENT {
  identity: {
    value: 'square_m',
    slug: 'square-m'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_m_name,
    label_i18n: i18n_key:icon_square_m_label,
    keywords: ["square-m", "metro", "subway", "underground", "track", "line"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1378. square-menu
CREATE icon:square_menu CONTENT {
  identity: {
    value: 'square_menu',
    slug: 'square-menu'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_menu_name,
    label_i18n: i18n_key:icon_square_menu_label,
    keywords: ["square-menu", "bars", "navigation", "hamburger", "options", "menu bar", "panel"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1379. square-minus
CREATE icon:square_minus CONTENT {
  identity: {
    value: 'square_minus',
    slug: 'square-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_minus_name,
    label_i18n: i18n_key:icon_square_minus_label,
    keywords: ["square-minus", "subtract", "remove", "decrease", "reduce", "calculator", "button", "keyboard", "line", "divider", "separator", "horizontal rule", "hr", "html", "markup", "markdown", "---", "toolbar", "operator", "code", "coding", "minimum", "downgrade"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1380. square-mouse-pointer
CREATE icon:square_mouse_pointer CONTENT {
  identity: {
    value: 'square_mouse_pointer',
    slug: 'square-mouse-pointer'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_mouse_pointer_name,
    label_i18n: i18n_key:icon_square_mouse_pointer_label,
    keywords: ["square-mouse-pointer", "inspector", "element", "mouse", "click", "pointer", "box", "browser", "selector", "target", "dom", "node"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1381. square-parking-off
CREATE icon:square_parking_off CONTENT {
  identity: {
    value: 'square_parking_off',
    slug: 'square-parking-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_parking_off_name,
    label_i18n: i18n_key:icon_square_parking_off_label,
    keywords: ["square-parking-off", "parking lot", "car park", "no parking"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1382. square-parking
CREATE icon:square_parking CONTENT {
  identity: {
    value: 'square_parking',
    slug: 'square-parking'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_parking_name,
    label_i18n: i18n_key:icon_square_parking_label,
    keywords: ["square-parking", "parking lot", "car park"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1383. square-pause
CREATE icon:square_pause CONTENT {
  identity: {
    value: 'square_pause',
    slug: 'square-pause'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_pause_name,
    label_i18n: i18n_key:icon_square_pause_label,
    keywords: ["square-pause", "music", "audio", "stop"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1384. square-pen
CREATE icon:square_pen CONTENT {
  identity: {
    value: 'square_pen',
    slug: 'square-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_pen_name,
    label_i18n: i18n_key:icon_square_pen_label,
    keywords: ["square-pen", "pencil", "edit", "change", "create", "draw", "sketch", "draft", "writer", "writing", "biro", "ink", "marker", "felt tip", "stationery", "artist"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1385. square-percent
CREATE icon:square_percent CONTENT {
  identity: {
    value: 'square_percent',
    slug: 'square-percent'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_percent_name,
    label_i18n: i18n_key:icon_square_percent_label,
    keywords: ["square-percent", "verified", "unverified", "sale", "discount", "offer", "marketing", "sticker", "price tag"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1386. square-pi
CREATE icon:square_pi CONTENT {
  identity: {
    value: 'square_pi',
    slug: 'square-pi'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_pi_name,
    label_i18n: i18n_key:icon_square_pi_label,
    keywords: ["square-pi", "constant", "code", "coding", "programming", "symbol", "trigonometry", "geometry", "formula"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1387. square-pilcrow
CREATE icon:square_pilcrow CONTENT {
  identity: {
    value: 'square_pilcrow',
    slug: 'square-pilcrow'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_pilcrow_name,
    label_i18n: i18n_key:icon_square_pilcrow_label,
    keywords: ["square-pilcrow", "paragraph", "mark", "paraph", "blind", "typography", "type", "text", "prose", "symbol"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1388. square-play
CREATE icon:square_play CONTENT {
  identity: {
    value: 'square_play',
    slug: 'square-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_play_name,
    label_i18n: i18n_key:icon_square_play_label,
    keywords: ["square-play", "music", "audio", "video", "start", "run"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1389. square-plus
CREATE icon:square_plus CONTENT {
  identity: {
    value: 'square_plus',
    slug: 'square-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_plus_name,
    label_i18n: i18n_key:icon_square_plus_label,
    keywords: ["square-plus", "add", "new", "increase", "increment", "positive", "calculate", "calculator", "button", "keyboard", "toolbar", "maximum", "upgrade", "extra", "operator", "join", "concatenate", "code", "coding", "+"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1390. square-power
CREATE icon:square_power CONTENT {
  identity: {
    value: 'square_power',
    slug: 'square-power'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_power_name,
    label_i18n: i18n_key:icon_square_power_label,
    keywords: ["square-power", "on", "off", "device", "switch", "toggle", "binary", "boolean", "reboot", "restart", "button", "keyboard", "troubleshoot"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1391. square-radical
CREATE icon:square_radical CONTENT {
  identity: {
    value: 'square_radical',
    slug: 'square-radical'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_radical_name,
    label_i18n: i18n_key:icon_square_radical_label,
    keywords: ["square-radical", "calculate", "formula", "math", "operator", "root", "square", "symbol"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1392. square-round-corner
CREATE icon:square_round_corner CONTENT {
  identity: {
    value: 'square_round_corner',
    slug: 'square-round-corner'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_round_corner_name,
    label_i18n: i18n_key:icon_square_round_corner_label,
    keywords: ["square-round-corner", "border", "radius", "style", "design", "corner", "layout", "round", "rounded"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1393. square-scissors
CREATE icon:square_scissors CONTENT {
  identity: {
    value: 'square_scissors',
    slug: 'square-scissors'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_scissors_name,
    label_i18n: i18n_key:icon_square_scissors_label,
    keywords: ["square-scissors", "cut", "snippet", "chop", "stationery", "crafts", "toolbar", "button"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1394. square-sigma
CREATE icon:square_sigma CONTENT {
  identity: {
    value: 'square_sigma',
    slug: 'square-sigma'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_sigma_name,
    label_i18n: i18n_key:icon_square_sigma_label,
    keywords: ["square-sigma", "sum", "calculate", "formula", "math", "enumeration", "enumerate"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1395. square-slash
CREATE icon:square_slash CONTENT {
  identity: {
    value: 'square_slash',
    slug: 'square-slash'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_slash_name,
    label_i18n: i18n_key:icon_square_slash_label,
    keywords: ["square-slash", "git", "diff", "ignored", "divide", "division", "shortcut", "or", "/"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1396. square-split-horizontal
CREATE icon:square_split_horizontal CONTENT {
  identity: {
    value: 'square_split_horizontal',
    slug: 'square-split-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_split_horizontal_name,
    label_i18n: i18n_key:icon_square_split_horizontal_label,
    keywords: ["square-split-horizontal", "split", "divide"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1397. square-split-vertical
CREATE icon:square_split_vertical CONTENT {
  identity: {
    value: 'square_split_vertical',
    slug: 'square-split-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_split_vertical_name,
    label_i18n: i18n_key:icon_square_split_vertical_label,
    keywords: ["square-split-vertical", "split", "divide"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1398. square-square
CREATE icon:square_square CONTENT {
  identity: {
    value: 'square_square',
    slug: 'square-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_square_name,
    label_i18n: i18n_key:icon_square_square_label,
    keywords: ["square-square", "float", "center", "rectangle"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1399. square-stack
CREATE icon:square_stack CONTENT {
  identity: {
    value: 'square_stack',
    slug: 'square-stack'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_stack_name,
    label_i18n: i18n_key:icon_square_stack_label,
    keywords: ["square-stack", "versions", "clone", "copy", "duplicate", "multiple", "revisions", "version control", "backup", "history"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1400. square-star
CREATE icon:square_star CONTENT {
  identity: {
    value: 'square_star',
    slug: 'square-star'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_star_name,
    label_i18n: i18n_key:icon_square_star_label,
    keywords: ["square-star", "badge", "medal", "honour", "decoration", "order", "pin", "laurel", "trophy", "medallion", "insignia", "bronze", "silver", "gold"]
  },
  context: {
    category: icon_category:sports,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1401. square-stop
CREATE icon:square_stop CONTENT {
  identity: {
    value: 'square_stop',
    slug: 'square-stop'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_stop_name,
    label_i18n: i18n_key:icon_square_stop_label,
    keywords: ["square-stop", "media", "music"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1402. square-terminal
CREATE icon:square_terminal CONTENT {
  identity: {
    value: 'square_terminal',
    slug: 'square-terminal'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_terminal_name,
    label_i18n: i18n_key:icon_square_terminal_label,
    keywords: ["square-terminal", "code", "command line", "prompt", "shell"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1403. square-user-round
CREATE icon:square_user_round CONTENT {
  identity: {
    value: 'square_user_round',
    slug: 'square-user-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_user_round_name,
    label_i18n: i18n_key:icon_square_user_round_label,
    keywords: ["square-user-round", "person", "account", "contact"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1404. square-user
CREATE icon:square_user CONTENT {
  identity: {
    value: 'square_user',
    slug: 'square-user'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_user_name,
    label_i18n: i18n_key:icon_square_user_label,
    keywords: ["square-user", "person", "account", "contact"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1405. square-x
CREATE icon:square_x CONTENT {
  identity: {
    value: 'square_x',
    slug: 'square-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_x_name,
    label_i18n: i18n_key:icon_square_x_label,
    keywords: ["square-x", "cancel", "close", "delete", "remove", "times", "clear", "math", "multiply", "multiplication"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1406. square
CREATE icon:square CONTENT {
  identity: {
    value: 'square',
    slug: 'square'
  },
  presentation: {
    name_i18n: i18n_key:icon_square_name,
    label_i18n: i18n_key:icon_square_label,
    keywords: ["square", "stop", "playback", "music", "audio", "video", "rectangle", "aspect ratio", "1:1", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1407. squares-exclude
CREATE icon:squares_exclude CONTENT {
  identity: {
    value: 'squares_exclude',
    slug: 'squares-exclude'
  },
  presentation: {
    name_i18n: i18n_key:icon_squares_exclude_name,
    label_i18n: i18n_key:icon_squares_exclude_label,
    keywords: ["squares-exclude", "square", "pathfinder", "path", "exclude", "invert", "xor", "shape", "vector"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1408. squares-intersect
CREATE icon:squares_intersect CONTENT {
  identity: {
    value: 'squares_intersect',
    slug: 'squares-intersect'
  },
  presentation: {
    name_i18n: i18n_key:icon_squares_intersect_name,
    label_i18n: i18n_key:icon_squares_intersect_label,
    keywords: ["squares-intersect", "square", "pathfinder", "path", "intersect", "shape", "include", "vector"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1409. squares-subtract
CREATE icon:squares_subtract CONTENT {
  identity: {
    value: 'squares_subtract',
    slug: 'squares-subtract'
  },
  presentation: {
    name_i18n: i18n_key:icon_squares_subtract_name,
    label_i18n: i18n_key:icon_squares_subtract_label,
    keywords: ["squares-subtract", "square", "pathfinder", "path", "minus", "subtract", "subtraction", "shape", "front", "vector"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1410. squares-unite
CREATE icon:squares_unite CONTENT {
  identity: {
    value: 'squares_unite',
    slug: 'squares-unite'
  },
  presentation: {
    name_i18n: i18n_key:icon_squares_unite_name,
    label_i18n: i18n_key:icon_squares_unite_label,
    keywords: ["squares-unite", "square", "pathfinder", "path", "unite", "union", "shape", "merge", "vector"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1411. squircle-dashed
CREATE icon:squircle_dashed CONTENT {
  identity: {
    value: 'squircle_dashed',
    slug: 'squircle-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_squircle_dashed_name,
    label_i18n: i18n_key:icon_squircle_dashed_label,
    keywords: ["squircle-dashed", "shape", "pending", "progress", "issue", "draft", "code", "coding", "version control"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1412. squircle
CREATE icon:squircle CONTENT {
  identity: {
    value: 'squircle',
    slug: 'squircle'
  },
  presentation: {
    name_i18n: i18n_key:icon_squircle_name,
    label_i18n: i18n_key:icon_squircle_label,
    keywords: ["squircle", "shape"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1413. squirrel
CREATE icon:squirrel CONTENT {
  identity: {
    value: 'squirrel',
    slug: 'squirrel'
  },
  presentation: {
    name_i18n: i18n_key:icon_squirrel_name,
    label_i18n: i18n_key:icon_squirrel_label,
    keywords: ["squirrel", "animal", "rodent", "pet", "pest", "nuts", "retrieve", "updates", "storage", "stash"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1414. stamp
CREATE icon:stamp CONTENT {
  identity: {
    value: 'stamp',
    slug: 'stamp'
  },
  presentation: {
    name_i18n: i18n_key:icon_stamp_name,
    label_i18n: i18n_key:icon_stamp_label,
    keywords: ["stamp", "mark", "print", "clone", "loyalty", "library"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1415. star-half
CREATE icon:star_half CONTENT {
  identity: {
    value: 'star_half',
    slug: 'star-half'
  },
  presentation: {
    name_i18n: i18n_key:icon_star_half_name,
    label_i18n: i18n_key:icon_star_half_label,
    keywords: ["star-half", "bookmark", "favorite", "like", "review", "rating"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1416. star-off
CREATE icon:star_off CONTENT {
  identity: {
    value: 'star_off',
    slug: 'star-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_star_off_name,
    label_i18n: i18n_key:icon_star_off_label,
    keywords: ["star-off", "dislike", "unlike", "remove", "unrate"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1417. star
CREATE icon:star CONTENT {
  identity: {
    value: 'star',
    slug: 'star'
  },
  presentation: {
    name_i18n: i18n_key:icon_star_name,
    label_i18n: i18n_key:icon_star_label,
    keywords: ["star", "bookmark", "favorite", "like", "review", "rating"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1418. step-back
CREATE icon:step_back CONTENT {
  identity: {
    value: 'step_back',
    slug: 'step-back'
  },
  presentation: {
    name_i18n: i18n_key:icon_step_back_name,
    label_i18n: i18n_key:icon_step_back_label,
    keywords: ["step-back", "arrow", "previous", "music", "left", "reverse"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1419. step-forward
CREATE icon:step_forward CONTENT {
  identity: {
    value: 'step_forward',
    slug: 'step-forward'
  },
  presentation: {
    name_i18n: i18n_key:icon_step_forward_name,
    label_i18n: i18n_key:icon_step_forward_label,
    keywords: ["step-forward", "arrow", "next", "music", "right", "continue"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1420. stethoscope
CREATE icon:stethoscope CONTENT {
  identity: {
    value: 'stethoscope',
    slug: 'stethoscope'
  },
  presentation: {
    name_i18n: i18n_key:icon_stethoscope_name,
    label_i18n: i18n_key:icon_stethoscope_label,
    keywords: ["stethoscope", "phonendoscope", "medical", "heart", "lungs", "sound"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1421. sticker
CREATE icon:sticker CONTENT {
  identity: {
    value: 'sticker',
    slug: 'sticker'
  },
  presentation: {
    name_i18n: i18n_key:icon_sticker_name,
    label_i18n: i18n_key:icon_sticker_label,
    keywords: ["sticker", "reaction", "emotion", "smile", "happy", "feedback"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1422. sticky-note
CREATE icon:sticky_note CONTENT {
  identity: {
    value: 'sticky_note',
    slug: 'sticky-note'
  },
  presentation: {
    name_i18n: i18n_key:icon_sticky_note_name,
    label_i18n: i18n_key:icon_sticky_note_label,
    keywords: ["sticky-note", "post-it", "comment", "annotation", "reaction", "memo", "reminder", "todo", "task", "idea", "brainstorm", "document", "page", "paper", "sheet", "stationary", "office"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1423. store
CREATE icon:store CONTENT {
  identity: {
    value: 'store',
    slug: 'store'
  },
  presentation: {
    name_i18n: i18n_key:icon_store_name,
    label_i18n: i18n_key:icon_store_label,
    keywords: ["store", "shop", "supermarket", "stand", "boutique", "building"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1424. stretch-horizontal
CREATE icon:stretch_horizontal CONTENT {
  identity: {
    value: 'stretch_horizontal',
    slug: 'stretch-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_stretch_horizontal_name,
    label_i18n: i18n_key:icon_stretch_horizontal_label,
    keywords: ["stretch-horizontal", "items", "flex", "justify", "distribute"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1425. stretch-vertical
CREATE icon:stretch_vertical CONTENT {
  identity: {
    value: 'stretch_vertical',
    slug: 'stretch-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_stretch_vertical_name,
    label_i18n: i18n_key:icon_stretch_vertical_label,
    keywords: ["stretch-vertical", "items", "flex", "justify", "distribute"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1426. strikethrough
CREATE icon:strikethrough CONTENT {
  identity: {
    value: 'strikethrough',
    slug: 'strikethrough'
  },
  presentation: {
    name_i18n: i18n_key:icon_strikethrough_name,
    label_i18n: i18n_key:icon_strikethrough_label,
    keywords: ["strikethrough", "cross out", "delete", "remove", "format"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1427. subscript
CREATE icon:subscript CONTENT {
  identity: {
    value: 'subscript',
    slug: 'subscript'
  },
  presentation: {
    name_i18n: i18n_key:icon_subscript_name,
    label_i18n: i18n_key:icon_subscript_label,
    keywords: ["subscript", "text"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1428. sun-dim
CREATE icon:sun_dim CONTENT {
  identity: {
    value: 'sun_dim',
    slug: 'sun-dim'
  },
  presentation: {
    name_i18n: i18n_key:icon_sun_dim_name,
    label_i18n: i18n_key:icon_sun_dim_label,
    keywords: ["sun-dim", "brightness", "dim", "low", "brightness low"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1429. sun-medium
CREATE icon:sun_medium CONTENT {
  identity: {
    value: 'sun_medium',
    slug: 'sun-medium'
  },
  presentation: {
    name_i18n: i18n_key:icon_sun_medium_name,
    label_i18n: i18n_key:icon_sun_medium_label,
    keywords: ["sun-medium", "brightness", "medium"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1430. sun-moon
CREATE icon:sun_moon CONTENT {
  identity: {
    value: 'sun_moon',
    slug: 'sun-moon'
  },
  presentation: {
    name_i18n: i18n_key:icon_sun_moon_name,
    label_i18n: i18n_key:icon_sun_moon_label,
    keywords: ["sun-moon", "dark", "light", "moon", "sun", "brightness", "theme", "auto theme", "system theme", "appearance"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1431. sun-snow
CREATE icon:sun_snow CONTENT {
  identity: {
    value: 'sun_snow',
    slug: 'sun-snow'
  },
  presentation: {
    name_i18n: i18n_key:icon_sun_snow_name,
    label_i18n: i18n_key:icon_sun_snow_label,
    keywords: ["sun-snow", "weather", "air conditioning", "temperature", "hot", "cold", "seasons"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1432. sun
CREATE icon:sun CONTENT {
  identity: {
    value: 'sun',
    slug: 'sun'
  },
  presentation: {
    name_i18n: i18n_key:icon_sun_name,
    label_i18n: i18n_key:icon_sun_label,
    keywords: ["sun", "brightness", "weather", "light", "summer"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1433. sunrise
CREATE icon:sunrise CONTENT {
  identity: {
    value: 'sunrise',
    slug: 'sunrise'
  },
  presentation: {
    name_i18n: i18n_key:icon_sunrise_name,
    label_i18n: i18n_key:icon_sunrise_label,
    keywords: ["sunrise", "weather", "time", "morning", "day"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1434. sunset
CREATE icon:sunset CONTENT {
  identity: {
    value: 'sunset',
    slug: 'sunset'
  },
  presentation: {
    name_i18n: i18n_key:icon_sunset_name,
    label_i18n: i18n_key:icon_sunset_label,
    keywords: ["sunset", "weather", "time", "evening", "night"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1435. superscript
CREATE icon:superscript CONTENT {
  identity: {
    value: 'superscript',
    slug: 'superscript'
  },
  presentation: {
    name_i18n: i18n_key:icon_superscript_name,
    label_i18n: i18n_key:icon_superscript_label,
    keywords: ["superscript", "text", "exponent"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1436. swatch-book
CREATE icon:swatch_book CONTENT {
  identity: {
    value: 'swatch_book',
    slug: 'swatch-book'
  },
  presentation: {
    name_i18n: i18n_key:icon_swatch_book_name,
    label_i18n: i18n_key:icon_swatch_book_label,
    keywords: ["swatch-book", "colors", "colours", "swatches", "pantone", "shades", "tint", "hue", "saturation", "brightness", "theme", "scheme", "palette", "samples", "textile", "carpet"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1437. swiss-franc
CREATE icon:swiss_franc CONTENT {
  identity: {
    value: 'swiss_franc',
    slug: 'swiss-franc'
  },
  presentation: {
    name_i18n: i18n_key:icon_swiss_franc_name,
    label_i18n: i18n_key:icon_swiss_franc_label,
    keywords: ["swiss-franc", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1438. switch-camera
CREATE icon:switch_camera CONTENT {
  identity: {
    value: 'switch_camera',
    slug: 'switch-camera'
  },
  presentation: {
    name_i18n: i18n_key:icon_switch_camera_name,
    label_i18n: i18n_key:icon_switch_camera_label,
    keywords: ["switch-camera", "photo", "selfie", "front", "back"]
  },
  context: {
    category: icon_category:communication,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1439. sword
CREATE icon:sword CONTENT {
  identity: {
    value: 'sword',
    slug: 'sword'
  },
  presentation: {
    name_i18n: i18n_key:icon_sword_name,
    label_i18n: i18n_key:icon_sword_label,
    keywords: ["sword", "battle", "challenge", "game", "war", "weapon"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1440. swords
CREATE icon:swords CONTENT {
  identity: {
    value: 'swords',
    slug: 'swords'
  },
  presentation: {
    name_i18n: i18n_key:icon_swords_name,
    label_i18n: i18n_key:icon_swords_label,
    keywords: ["swords", "battle", "challenge", "game", "war", "weapon"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1441. syringe
CREATE icon:syringe CONTENT {
  identity: {
    value: 'syringe',
    slug: 'syringe'
  },
  presentation: {
    name_i18n: i18n_key:icon_syringe_name,
    label_i18n: i18n_key:icon_syringe_label,
    keywords: ["syringe", "medicine", "medical", "needle", "pump", "plunger", "nozzle", "blood"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1442. table-2
CREATE icon:table_2 CONTENT {
  identity: {
    value: 'table_2',
    slug: 'table-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_2_name,
    label_i18n: i18n_key:icon_table_2_label,
    keywords: ["table-2", "spreadsheet", "grid"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1443. table-cells-merge
CREATE icon:table_cells_merge CONTENT {
  identity: {
    value: 'table_cells_merge',
    slug: 'table-cells-merge'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_cells_merge_name,
    label_i18n: i18n_key:icon_table_cells_merge_label,
    keywords: ["table-cells-merge", "spreadsheet", "grid", "row"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1444. table-cells-split
CREATE icon:table_cells_split CONTENT {
  identity: {
    value: 'table_cells_split',
    slug: 'table-cells-split'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_cells_split_name,
    label_i18n: i18n_key:icon_table_cells_split_label,
    keywords: ["table-cells-split", "spreadsheet", "grid", "row"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1445. table-columns-split
CREATE icon:table_columns_split CONTENT {
  identity: {
    value: 'table_columns_split',
    slug: 'table-columns-split'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_columns_split_name,
    label_i18n: i18n_key:icon_table_columns_split_label,
    keywords: ["table-columns-split", "spreadsheet", "grid", "cut", "break", "divide", "separate", "segment"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1446. table-of-contents
CREATE icon:table_of_contents CONTENT {
  identity: {
    value: 'table_of_contents',
    slug: 'table-of-contents'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_of_contents_name,
    label_i18n: i18n_key:icon_table_of_contents_label,
    keywords: ["table-of-contents", "toc", "outline", "navigation", "document structure", "index", "overview", "sections", "chapters", "content", "documentation", "manual", "knowledge base", "faq"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1447. table-properties
CREATE icon:table_properties CONTENT {
  identity: {
    value: 'table_properties',
    slug: 'table-properties'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_properties_name,
    label_i18n: i18n_key:icon_table_properties_label,
    keywords: ["table-properties", "property list", "plist", "spreadsheet", "grid", "dictionary", "object", "hash"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1448. table-rows-split
CREATE icon:table_rows_split CONTENT {
  identity: {
    value: 'table_rows_split',
    slug: 'table-rows-split'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_rows_split_name,
    label_i18n: i18n_key:icon_table_rows_split_label,
    keywords: ["table-rows-split", "spreadsheet", "grid", "cut", "break", "divide", "separate", "segment"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1449. table
CREATE icon:table CONTENT {
  identity: {
    value: 'table',
    slug: 'table'
  },
  presentation: {
    name_i18n: i18n_key:icon_table_name,
    label_i18n: i18n_key:icon_table_label,
    keywords: ["table", "spreadsheet", "grid"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1450. tablet-smartphone
CREATE icon:tablet_smartphone CONTENT {
  identity: {
    value: 'tablet_smartphone',
    slug: 'tablet-smartphone'
  },
  presentation: {
    name_i18n: i18n_key:icon_tablet_smartphone_name,
    label_i18n: i18n_key:icon_tablet_smartphone_label,
    keywords: ["tablet-smartphone", "responsive", "screens", "browser", "testing", "mobile"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1451. tablet
CREATE icon:tablet CONTENT {
  identity: {
    value: 'tablet',
    slug: 'tablet'
  },
  presentation: {
    name_i18n: i18n_key:icon_tablet_name,
    label_i18n: i18n_key:icon_tablet_label,
    keywords: ["tablet", "device"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1452. tablets
CREATE icon:tablets CONTENT {
  identity: {
    value: 'tablets',
    slug: 'tablets'
  },
  presentation: {
    name_i18n: i18n_key:icon_tablets_name,
    label_i18n: i18n_key:icon_tablets_label,
    keywords: ["tablets", "medicine", "medication", "drug", "prescription", "pills", "pharmacy"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1453. tag
CREATE icon:tag CONTENT {
  identity: {
    value: 'tag',
    slug: 'tag'
  },
  presentation: {
    name_i18n: i18n_key:icon_tag_name,
    label_i18n: i18n_key:icon_tag_label,
    keywords: ["tag", "label", "badge", "ticket", "mark"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1454. tags
CREATE icon:tags CONTENT {
  identity: {
    value: 'tags',
    slug: 'tags'
  },
  presentation: {
    name_i18n: i18n_key:icon_tags_name,
    label_i18n: i18n_key:icon_tags_label,
    keywords: ["tags", "labels", "badges", "tickets", "marks", "copy", "multiple"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1455. tally-1
CREATE icon:tally_1 CONTENT {
  identity: {
    value: 'tally_1',
    slug: 'tally-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_tally_1_name,
    label_i18n: i18n_key:icon_tally_1_label,
    keywords: ["tally-1", "count", "score", "enumerate", "days", "one", "1", "first", "bar", "prison", "cell", "sentence"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1456. tally-2
CREATE icon:tally_2 CONTENT {
  identity: {
    value: 'tally_2',
    slug: 'tally-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_tally_2_name,
    label_i18n: i18n_key:icon_tally_2_label,
    keywords: ["tally-2", "count", "score", "enumerate", "days", "two", "2", "second", "double", "bars", "prison", "cell", "sentence"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1457. tally-3
CREATE icon:tally_3 CONTENT {
  identity: {
    value: 'tally_3',
    slug: 'tally-3'
  },
  presentation: {
    name_i18n: i18n_key:icon_tally_3_name,
    label_i18n: i18n_key:icon_tally_3_label,
    keywords: ["tally-3", "count", "score", "enumerate", "days", "three", "3", "third", "triple", "bars", "prison", "cell", "sentence"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1458. tally-4
CREATE icon:tally_4 CONTENT {
  identity: {
    value: 'tally_4',
    slug: 'tally-4'
  },
  presentation: {
    name_i18n: i18n_key:icon_tally_4_name,
    label_i18n: i18n_key:icon_tally_4_label,
    keywords: ["tally-4", "count", "score", "enumerate", "days", "4", "fourth", "quadruple", "bars", "prison", "cell", "sentence"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1459. tally-5
CREATE icon:tally_5 CONTENT {
  identity: {
    value: 'tally_5',
    slug: 'tally-5'
  },
  presentation: {
    name_i18n: i18n_key:icon_tally_5_name,
    label_i18n: i18n_key:icon_tally_5_label,
    keywords: ["tally-5", "count", "score", "enumerate", "days", "five", "5", "fifth", "bars", "prison", "cell", "sentence", "slash", "/"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1460. tangent
CREATE icon:tangent CONTENT {
  identity: {
    value: 'tangent',
    slug: 'tangent'
  },
  presentation: {
    name_i18n: i18n_key:icon_tangent_name,
    label_i18n: i18n_key:icon_tangent_label,
    keywords: ["tangent", "tangential", "shape", "circle", "geometry", "trigonometry", "bezier curve"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1461. target
CREATE icon:target CONTENT {
  identity: {
    value: 'target',
    slug: 'target'
  },
  presentation: {
    name_i18n: i18n_key:icon_target_name,
    label_i18n: i18n_key:icon_target_label,
    keywords: ["target", "logo", "bullseye", "deadline", "projects", "overview", "work", "productivity"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1462. telescope
CREATE icon:telescope CONTENT {
  identity: {
    value: 'telescope',
    slug: 'telescope'
  },
  presentation: {
    name_i18n: i18n_key:icon_telescope_name,
    label_i18n: i18n_key:icon_telescope_label,
    keywords: ["telescope", "astronomy", "space", "discovery", "exploration", "explore", "vision", "perspective", "focus", "stargazing", "observe", "view"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1463. tent-tree
CREATE icon:tent_tree CONTENT {
  identity: {
    value: 'tent_tree',
    slug: 'tent-tree'
  },
  presentation: {
    name_i18n: i18n_key:icon_tent_tree_name,
    label_i18n: i18n_key:icon_tent_tree_label,
    keywords: ["tent-tree", "camping", "campsite", "holiday", "retreat", "nomadic", "wilderness", "outdoors"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1464. tent
CREATE icon:tent CONTENT {
  identity: {
    value: 'tent',
    slug: 'tent'
  },
  presentation: {
    name_i18n: i18n_key:icon_tent_name,
    label_i18n: i18n_key:icon_tent_label,
    keywords: ["tent", "tipi", "teepee", "wigwam", "lodge", "camping", "campsite", "holiday", "retreat", "nomadic", "native american", "indian", "wilderness", "outdoors"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1465. terminal
CREATE icon:terminal CONTENT {
  identity: {
    value: 'terminal',
    slug: 'terminal'
  },
  presentation: {
    name_i18n: i18n_key:icon_terminal_name,
    label_i18n: i18n_key:icon_terminal_label,
    keywords: ["terminal", "code", "command line", "prompt", "shell"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1466. test-tube-diagonal
CREATE icon:test_tube_diagonal CONTENT {
  identity: {
    value: 'test_tube_diagonal',
    slug: 'test-tube-diagonal'
  },
  presentation: {
    name_i18n: i18n_key:icon_test_tube_diagonal_name,
    label_i18n: i18n_key:icon_test_tube_diagonal_label,
    keywords: ["test-tube-diagonal", "tube", "vial", "phial", "flask", "ampoule", "ampule", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1467. test-tube
CREATE icon:test_tube CONTENT {
  identity: {
    value: 'test_tube',
    slug: 'test-tube'
  },
  presentation: {
    name_i18n: i18n_key:icon_test_tube_name,
    label_i18n: i18n_key:icon_test_tube_label,
    keywords: ["test-tube", "tube", "vial", "phial", "flask", "ampoule", "ampule", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1468. test-tubes
CREATE icon:test_tubes CONTENT {
  identity: {
    value: 'test_tubes',
    slug: 'test-tubes'
  },
  presentation: {
    name_i18n: i18n_key:icon_test_tubes_name,
    label_i18n: i18n_key:icon_test_tubes_label,
    keywords: ["test-tubes", "tubes", "vials", "phials", "flasks", "ampoules", "ampules", "lab", "chemistry", "experiment", "test"]
  },
  context: {
    category: icon_category:science,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1469. text-align-center
CREATE icon:text_align_center CONTENT {
  identity: {
    value: 'text_align_center',
    slug: 'text-align-center'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_align_center_name,
    label_i18n: i18n_key:icon_text_align_center_label,
    keywords: ["text-align-center", "text", "alignment", "center"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1470. text-align-end
CREATE icon:text_align_end CONTENT {
  identity: {
    value: 'text_align_end',
    slug: 'text-align-end'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_align_end_name,
    label_i18n: i18n_key:icon_text_align_end_label,
    keywords: ["text-align-end", "text", "alignment", "right"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1471. text-align-justify
CREATE icon:text_align_justify CONTENT {
  identity: {
    value: 'text_align_justify',
    slug: 'text-align-justify'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_align_justify_name,
    label_i18n: i18n_key:icon_text_align_justify_label,
    keywords: ["text-align-justify", "text", "alignment", "justified", "menu", "list"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1472. text-align-start
CREATE icon:text_align_start CONTENT {
  identity: {
    value: 'text_align_start',
    slug: 'text-align-start'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_align_start_name,
    label_i18n: i18n_key:icon_text_align_start_label,
    keywords: ["text-align-start", "text", "alignment", "left", "list"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1473. text-cursor-input
CREATE icon:text_cursor_input CONTENT {
  identity: {
    value: 'text_cursor_input',
    slug: 'text-cursor-input'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_cursor_input_name,
    label_i18n: i18n_key:icon_text_cursor_input_label,
    keywords: ["text-cursor-input", "select"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1474. text-cursor
CREATE icon:text_cursor CONTENT {
  identity: {
    value: 'text_cursor',
    slug: 'text-cursor'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_cursor_name,
    label_i18n: i18n_key:icon_text_cursor_label,
    keywords: ["text-cursor", "select"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1475. text-initial
CREATE icon:text_initial CONTENT {
  identity: {
    value: 'text_initial',
    slug: 'text-initial'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_initial_name,
    label_i18n: i18n_key:icon_text_initial_label,
    keywords: ["text-initial", "drop cap", "text", "format", "typography", "letter", "font size"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1476. text-quote
CREATE icon:text_quote CONTENT {
  identity: {
    value: 'text_quote',
    slug: 'text-quote'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_quote_name,
    label_i18n: i18n_key:icon_text_quote_label,
    keywords: ["text-quote", "blockquote", "quotation", "indent", "reply", "response"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1477. text-search
CREATE icon:text_search CONTENT {
  identity: {
    value: 'text_search',
    slug: 'text-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_search_name,
    label_i18n: i18n_key:icon_text_search_label,
    keywords: ["text-search", "find", "data", "copy", "txt", "pdf", "document", "scan", "magnifier", "magnifying glass", "lens"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1478. text-select
CREATE icon:text_select CONTENT {
  identity: {
    value: 'text_select',
    slug: 'text-select'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_select_name,
    label_i18n: i18n_key:icon_text_select_label,
    keywords: ["text-select", "find", "search", "selection", "dashed"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1479. text-wrap
CREATE icon:text_wrap CONTENT {
  identity: {
    value: 'text_wrap',
    slug: 'text-wrap'
  },
  presentation: {
    name_i18n: i18n_key:icon_text_wrap_name,
    label_i18n: i18n_key:icon_text_wrap_label,
    keywords: ["text-wrap", "words", "lines", "break", "paragraph"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1480. theater
CREATE icon:theater CONTENT {
  identity: {
    value: 'theater',
    slug: 'theater'
  },
  presentation: {
    name_i18n: i18n_key:icon_theater_name,
    label_i18n: i18n_key:icon_theater_label,
    keywords: ["theater", "theater", "theatre", "entertainment", "podium", "stage", "musical"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1481. thermometer-snowflake
CREATE icon:thermometer_snowflake CONTENT {
  identity: {
    value: 'thermometer_snowflake',
    slug: 'thermometer-snowflake'
  },
  presentation: {
    name_i18n: i18n_key:icon_thermometer_snowflake_name,
    label_i18n: i18n_key:icon_thermometer_snowflake_label,
    keywords: ["thermometer-snowflake", "temperature", "celsius", "fahrenheit", "weather", "cold", "freeze", "freezing"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1482. thermometer-sun
CREATE icon:thermometer_sun CONTENT {
  identity: {
    value: 'thermometer_sun',
    slug: 'thermometer-sun'
  },
  presentation: {
    name_i18n: i18n_key:icon_thermometer_sun_name,
    label_i18n: i18n_key:icon_thermometer_sun_label,
    keywords: ["thermometer-sun", "temperature", "celsius", "fahrenheit", "weather", "warm", "hot"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1483. thermometer
CREATE icon:thermometer CONTENT {
  identity: {
    value: 'thermometer',
    slug: 'thermometer'
  },
  presentation: {
    name_i18n: i18n_key:icon_thermometer_name,
    label_i18n: i18n_key:icon_thermometer_label,
    keywords: ["thermometer", "temperature", "celsius", "fahrenheit", "weather"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1484. thumbs-down
CREATE icon:thumbs_down CONTENT {
  identity: {
    value: 'thumbs_down',
    slug: 'thumbs-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_thumbs_down_name,
    label_i18n: i18n_key:icon_thumbs_down_label,
    keywords: ["thumbs-down", "dislike", "bad", "emotion"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1485. thumbs-up
CREATE icon:thumbs_up CONTENT {
  identity: {
    value: 'thumbs_up',
    slug: 'thumbs-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_thumbs_up_name,
    label_i18n: i18n_key:icon_thumbs_up_label,
    keywords: ["thumbs-up", "like", "good", "emotion"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1486. ticket-check
CREATE icon:ticket_check CONTENT {
  identity: {
    value: 'ticket_check',
    slug: 'ticket-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_check_name,
    label_i18n: i18n_key:icon_ticket_check_label,
    keywords: ["ticket-check", "entry", "pass", "voucher", "event", "concert", "show", "booked", "purchased", "receipt", "redeemed", "validated", "verified", "certified", "checked", "used"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1487. ticket-minus
CREATE icon:ticket_minus CONTENT {
  identity: {
    value: 'ticket_minus',
    slug: 'ticket-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_minus_name,
    label_i18n: i18n_key:icon_ticket_minus_label,
    keywords: ["ticket-minus", "entry", "pass", "voucher", "event", "concert", "show", "remove", "cancel", "unbook", "subtract", "decrease", "-"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1488. ticket-percent
CREATE icon:ticket_percent CONTENT {
  identity: {
    value: 'ticket_percent',
    slug: 'ticket-percent'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_percent_name,
    label_i18n: i18n_key:icon_ticket_percent_label,
    keywords: ["ticket-percent", "discount", "reduced", "offer", "voucher", "entry", "pass", "event", "concert", "show", "book", "purchase", "%"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1489. ticket-plus
CREATE icon:ticket_plus CONTENT {
  identity: {
    value: 'ticket_plus',
    slug: 'ticket-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_plus_name,
    label_i18n: i18n_key:icon_ticket_plus_label,
    keywords: ["ticket-plus", "entry", "pass", "voucher", "event", "concert", "show", "book", "purchase", "add", "+"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1490. ticket-slash
CREATE icon:ticket_slash CONTENT {
  identity: {
    value: 'ticket_slash',
    slug: 'ticket-slash'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_slash_name,
    label_i18n: i18n_key:icon_ticket_slash_label,
    keywords: ["ticket-slash", "entry", "pass", "voucher", "event", "concert", "show", "redeemed", "used", "marked", "checked", "verified", "spoiled", "invalidated", "void", "denied", "refused", "banned", "barred", "forbidden", "prohibited", "cancelled", "cancellation", "refunded", "delete", "remove", "clear", "error"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1491. ticket-x
CREATE icon:ticket_x CONTENT {
  identity: {
    value: 'ticket_x',
    slug: 'ticket-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_x_name,
    label_i18n: i18n_key:icon_ticket_x_label,
    keywords: ["ticket-x", "entry", "pass", "voucher", "event", "concert", "show", "cancelled", "cancellation", "refunded", "used", "void", "invalidated", "spoiled", "denied", "refused", "banned", "barred", "forbidden", "prohibited", "delete", "remove", "clear", "error", "x"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1492. ticket
CREATE icon:ticket CONTENT {
  identity: {
    value: 'ticket',
    slug: 'ticket'
  },
  presentation: {
    name_i18n: i18n_key:icon_ticket_name,
    label_i18n: i18n_key:icon_ticket_label,
    keywords: ["ticket", "entry", "pass", "voucher", "event", "concert", "show", "perforated", "dashed"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1493. tickets-plane
CREATE icon:tickets_plane CONTENT {
  identity: {
    value: 'tickets_plane',
    slug: 'tickets-plane'
  },
  presentation: {
    name_i18n: i18n_key:icon_tickets_plane_name,
    label_i18n: i18n_key:icon_tickets_plane_label,
    keywords: ["tickets-plane", "plane", "trip", "airplane", "flight", "travel", "fly", "takeoff", "vacation", "passenger", "pass", "check-in", "airport"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1494. tickets
CREATE icon:tickets CONTENT {
  identity: {
    value: 'tickets',
    slug: 'tickets'
  },
  presentation: {
    name_i18n: i18n_key:icon_tickets_name,
    label_i18n: i18n_key:icon_tickets_label,
    keywords: ["tickets", "trip", "travel", "pass", "entry", "voucher", "event", "concert", "show", "perforated", "dashed"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1495. timer-off
CREATE icon:timer_off CONTENT {
  identity: {
    value: 'timer_off',
    slug: 'timer-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_timer_off_name,
    label_i18n: i18n_key:icon_timer_off_label,
    keywords: ["timer-off", "time", "timer", "stopwatch"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1496. timer-reset
CREATE icon:timer_reset CONTENT {
  identity: {
    value: 'timer_reset',
    slug: 'timer-reset'
  },
  presentation: {
    name_i18n: i18n_key:icon_timer_reset_name,
    label_i18n: i18n_key:icon_timer_reset_label,
    keywords: ["timer-reset", "time", "timer", "stopwatch"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1497. timer
CREATE icon:timer CONTENT {
  identity: {
    value: 'timer',
    slug: 'timer'
  },
  presentation: {
    name_i18n: i18n_key:icon_timer_name,
    label_i18n: i18n_key:icon_timer_label,
    keywords: ["timer", "time", "timer", "stopwatch"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1498. toggle-left
CREATE icon:toggle_left CONTENT {
  identity: {
    value: 'toggle_left',
    slug: 'toggle-left'
  },
  presentation: {
    name_i18n: i18n_key:icon_toggle_left_name,
    label_i18n: i18n_key:icon_toggle_left_label,
    keywords: ["toggle-left", "on", "off", "switch", "boolean"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1499. toggle-right
CREATE icon:toggle_right CONTENT {
  identity: {
    value: 'toggle_right',
    slug: 'toggle-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_toggle_right_name,
    label_i18n: i18n_key:icon_toggle_right_label,
    keywords: ["toggle-right", "on", "off", "switch", "boolean"]
  },
  context: {
    category: icon_category:layout,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1500. toilet
CREATE icon:toilet CONTENT {
  identity: {
    value: 'toilet',
    slug: 'toilet'
  },
  presentation: {
    name_i18n: i18n_key:icon_toilet_name,
    label_i18n: i18n_key:icon_toilet_label,
    keywords: ["toilet", "toilet", "potty", "bathroom", "washroom"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1501. tool-case
CREATE icon:tool_case CONTENT {
  identity: {
    value: 'tool_case',
    slug: 'tool-case'
  },
  presentation: {
    name_i18n: i18n_key:icon_tool_case_name,
    label_i18n: i18n_key:icon_tool_case_label,
    keywords: ["tool-case", "tools", "maintenance", "repair"]
  },
  context: {
    category: icon_category:tools,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1502. tornado
CREATE icon:tornado CONTENT {
  identity: {
    value: 'tornado',
    slug: 'tornado'
  },
  presentation: {
    name_i18n: i18n_key:icon_tornado_name,
    label_i18n: i18n_key:icon_tornado_label,
    keywords: ["tornado", "weather", "wind", "storm", "hurricane"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1503. torus
CREATE icon:torus CONTENT {
  identity: {
    value: 'torus',
    slug: 'torus'
  },
  presentation: {
    name_i18n: i18n_key:icon_torus_name,
    label_i18n: i18n_key:icon_torus_label,
    keywords: ["torus", "donut", "doughnut", "ring", "hollow", "3d", "fast food", "junk food", "snack", "treat", "sweet", "sugar", "dessert"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1504. touchpad-off
CREATE icon:touchpad_off CONTENT {
  identity: {
    value: 'touchpad_off',
    slug: 'touchpad-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_touchpad_off_name,
    label_i18n: i18n_key:icon_touchpad_off_label,
    keywords: ["touchpad-off", "trackpad", "cursor"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1505. touchpad
CREATE icon:touchpad CONTENT {
  identity: {
    value: 'touchpad',
    slug: 'touchpad'
  },
  presentation: {
    name_i18n: i18n_key:icon_touchpad_name,
    label_i18n: i18n_key:icon_touchpad_label,
    keywords: ["touchpad", "trackpad", "cursor"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1506. tower-control
CREATE icon:tower_control CONTENT {
  identity: {
    value: 'tower_control',
    slug: 'tower-control'
  },
  presentation: {
    name_i18n: i18n_key:icon_tower_control_name,
    label_i18n: i18n_key:icon_tower_control_label,
    keywords: ["tower-control", "airport", "travel", "tower", "transportation", "lighthouse"]
  },
  context: {
    category: icon_category:travel,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1507. toy-brick
CREATE icon:toy_brick CONTENT {
  identity: {
    value: 'toy_brick',
    slug: 'toy-brick'
  },
  presentation: {
    name_i18n: i18n_key:icon_toy_brick_name,
    label_i18n: i18n_key:icon_toy_brick_label,
    keywords: ["toy-brick", "lego", "block", "addon", "plugin", "integration"]
  },
  context: {
    category: icon_category:gaming,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1508. tractor
CREATE icon:tractor CONTENT {
  identity: {
    value: 'tractor',
    slug: 'tractor'
  },
  presentation: {
    name_i18n: i18n_key:icon_tractor_name,
    label_i18n: i18n_key:icon_tractor_label,
    keywords: ["tractor", "farming", "farmer", "ranch", "harvest", "equipment", "vehicle"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1509. traffic-cone
CREATE icon:traffic_cone CONTENT {
  identity: {
    value: 'traffic_cone',
    slug: 'traffic-cone'
  },
  presentation: {
    name_i18n: i18n_key:icon_traffic_cone_name,
    label_i18n: i18n_key:icon_traffic_cone_label,
    keywords: ["traffic-cone", "roadworks", "tarmac", "safety", "block"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1510. train-front-tunnel
CREATE icon:train_front_tunnel CONTENT {
  identity: {
    value: 'train_front_tunnel',
    slug: 'train-front-tunnel'
  },
  presentation: {
    name_i18n: i18n_key:icon_train_front_tunnel_name,
    label_i18n: i18n_key:icon_train_front_tunnel_label,
    keywords: ["train-front-tunnel", "railway", "metro", "subway", "underground", "speed", "bullet", "fast", "track", "line"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1511. train-front
CREATE icon:train_front CONTENT {
  identity: {
    value: 'train_front',
    slug: 'train-front'
  },
  presentation: {
    name_i18n: i18n_key:icon_train_front_name,
    label_i18n: i18n_key:icon_train_front_label,
    keywords: ["train-front", "railway", "metro", "subway", "underground", "high-speed", "bullet", "fast", "track", "line"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1512. train-track
CREATE icon:train_track CONTENT {
  identity: {
    value: 'train_track',
    slug: 'train-track'
  },
  presentation: {
    name_i18n: i18n_key:icon_train_track_name,
    label_i18n: i18n_key:icon_train_track_label,
    keywords: ["train-track", "railway", "line"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1513. tram-front
CREATE icon:tram_front CONTENT {
  identity: {
    value: 'tram_front',
    slug: 'tram-front'
  },
  presentation: {
    name_i18n: i18n_key:icon_tram_front_name,
    label_i18n: i18n_key:icon_tram_front_label,
    keywords: ["tram-front", "railway", "metro", "subway", "underground", "track", "line", "tourism"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1514. transgender
CREATE icon:transgender CONTENT {
  identity: {
    value: 'transgender',
    slug: 'transgender'
  },
  presentation: {
    name_i18n: i18n_key:icon_transgender_name,
    label_i18n: i18n_key:icon_transgender_label,
    keywords: ["transgender", "gender", "inclusive"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1515. trash-2
CREATE icon:trash_2 CONTENT {
  identity: {
    value: 'trash_2',
    slug: 'trash-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_trash_2_name,
    label_i18n: i18n_key:icon_trash_2_label,
    keywords: ["trash-2", "garbage", "delete", "remove", "bin"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1516. trash
CREATE icon:trash CONTENT {
  identity: {
    value: 'trash',
    slug: 'trash'
  },
  presentation: {
    name_i18n: i18n_key:icon_trash_name,
    label_i18n: i18n_key:icon_trash_label,
    keywords: ["trash", "empty", "deletion", "cleanup", "junk", "clear", "garbage", "delete", "remove", "bin", "waste", "recycle", "discard", "binoculars", "rubbish"]
  },
  context: {
    category: icon_category:files,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1517. tree-deciduous
CREATE icon:tree_deciduous CONTENT {
  identity: {
    value: 'tree_deciduous',
    slug: 'tree-deciduous'
  },
  presentation: {
    name_i18n: i18n_key:icon_tree_deciduous_name,
    label_i18n: i18n_key:icon_tree_deciduous_label,
    keywords: ["tree-deciduous", "tree", "forest", "park", "nature"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1518. tree-palm
CREATE icon:tree_palm CONTENT {
  identity: {
    value: 'tree_palm',
    slug: 'tree-palm'
  },
  presentation: {
    name_i18n: i18n_key:icon_tree_palm_name,
    label_i18n: i18n_key:icon_tree_palm_label,
    keywords: ["tree-palm", "vacation", "leisure", "island"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1519. tree-pine
CREATE icon:tree_pine CONTENT {
  identity: {
    value: 'tree_pine',
    slug: 'tree-pine'
  },
  presentation: {
    name_i18n: i18n_key:icon_tree_pine_name,
    label_i18n: i18n_key:icon_tree_pine_label,
    keywords: ["tree-pine", "tree", "pine", "forest", "park", "nature"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1520. trees
CREATE icon:trees CONTENT {
  identity: {
    value: 'trees',
    slug: 'trees'
  },
  presentation: {
    name_i18n: i18n_key:icon_trees_name,
    label_i18n: i18n_key:icon_trees_label,
    keywords: ["trees", "tree", "forest", "park", "nature"]
  },
  context: {
    category: icon_category:nature,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1521. trello
CREATE icon:trello CONTENT {
  identity: {
    value: 'trello',
    slug: 'trello'
  },
  presentation: {
    name_i18n: i18n_key:icon_trello_name,
    label_i18n: i18n_key:icon_trello_label,
    keywords: ["trello", "logo", "brand"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1522. trending-down
CREATE icon:trending_down CONTENT {
  identity: {
    value: 'trending_down',
    slug: 'trending-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_trending_down_name,
    label_i18n: i18n_key:icon_trending_down_label,
    keywords: ["trending-down", "statistics"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1523. trending-up-down
CREATE icon:trending_up_down CONTENT {
  identity: {
    value: 'trending_up_down',
    slug: 'trending-up-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_trending_up_down_name,
    label_i18n: i18n_key:icon_trending_up_down_label,
    keywords: ["trending-up-down", "arrows", "estimated", "indeterminate", "data fluctuation", "uncertain", "forecast", "variable", "prediction", "dynamic", "volatile"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1524. trending-up
CREATE icon:trending_up CONTENT {
  identity: {
    value: 'trending_up',
    slug: 'trending-up'
  },
  presentation: {
    name_i18n: i18n_key:icon_trending_up_name,
    label_i18n: i18n_key:icon_trending_up_label,
    keywords: ["trending-up", "statistics"]
  },
  context: {
    category: icon_category:charts,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1525. triangle-alert
CREATE icon:triangle_alert CONTENT {
  identity: {
    value: 'triangle_alert',
    slug: 'triangle-alert'
  },
  presentation: {
    name_i18n: i18n_key:icon_triangle_alert_name,
    label_i18n: i18n_key:icon_triangle_alert_label,
    keywords: ["triangle-alert", "warning", "alert", "danger", "exclamation mark", "linter"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1526. triangle-dashed
CREATE icon:triangle_dashed CONTENT {
  identity: {
    value: 'triangle_dashed',
    slug: 'triangle-dashed'
  },
  presentation: {
    name_i18n: i18n_key:icon_triangle_dashed_name,
    label_i18n: i18n_key:icon_triangle_dashed_label,
    keywords: ["triangle-dashed", "equilateral", "delta", "shape", "pyramid", "hierarchy", "dashed"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1527. triangle-right
CREATE icon:triangle_right CONTENT {
  identity: {
    value: 'triangle_right',
    slug: 'triangle-right'
  },
  presentation: {
    name_i18n: i18n_key:icon_triangle_right_name,
    label_i18n: i18n_key:icon_triangle_right_label,
    keywords: ["triangle-right", "volume", "controls", "controller", "tv remote", "geometry", "delta", "ramp", "slope", "incline", "increase"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1528. triangle
CREATE icon:triangle CONTENT {
  identity: {
    value: 'triangle',
    slug: 'triangle'
  },
  presentation: {
    name_i18n: i18n_key:icon_triangle_name,
    label_i18n: i18n_key:icon_triangle_label,
    keywords: ["triangle", "equilateral", "delta", "shape", "pyramid", "hierarchy"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1529. trophy
CREATE icon:trophy CONTENT {
  identity: {
    value: 'trophy',
    slug: 'trophy'
  },
  presentation: {
    name_i18n: i18n_key:icon_trophy_name,
    label_i18n: i18n_key:icon_trophy_label,
    keywords: ["trophy", "prize", "sports", "winner", "achievement", "award", "champion", "celebration", "victory"]
  },
  context: {
    category: icon_category:sports,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1530. truck-electric
CREATE icon:truck_electric CONTENT {
  identity: {
    value: 'truck_electric',
    slug: 'truck-electric'
  },
  presentation: {
    name_i18n: i18n_key:icon_truck_electric_name,
    label_i18n: i18n_key:icon_truck_electric_label,
    keywords: ["truck-electric", "delivery", "van", "shipping", "haulage", "lorry", "electric"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1531. truck
CREATE icon:truck CONTENT {
  identity: {
    value: 'truck',
    slug: 'truck'
  },
  presentation: {
    name_i18n: i18n_key:icon_truck_name,
    label_i18n: i18n_key:icon_truck_label,
    keywords: ["truck", "delivery", "van", "shipping", "haulage", "lorry"]
  },
  context: {
    category: icon_category:transportation,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1532. turkish-lira
CREATE icon:turkish_lira CONTENT {
  identity: {
    value: 'turkish_lira',
    slug: 'turkish-lira'
  },
  presentation: {
    name_i18n: i18n_key:icon_turkish_lira_name,
    label_i18n: i18n_key:icon_turkish_lira_label,
    keywords: ["turkish-lira", "currency", "money", "payment"]
  },
  context: {
    category: icon_category:finance,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1533. turntable
CREATE icon:turntable CONTENT {
  identity: {
    value: 'turntable',
    slug: 'turntable'
  },
  presentation: {
    name_i18n: i18n_key:icon_turntable_name,
    label_i18n: i18n_key:icon_turntable_label,
    keywords: ["turntable", "record player", "gramophone", "stereo", "phonograph", "vinyl", "lp", "disc", "platter", "cut", "music", "analog", "retro", "dj deck", "disc jockey", "scratch", "spinning"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1534. turtle
CREATE icon:turtle CONTENT {
  identity: {
    value: 'turtle',
    slug: 'turtle'
  },
  presentation: {
    name_i18n: i18n_key:icon_turtle_name,
    label_i18n: i18n_key:icon_turtle_label,
    keywords: ["turtle", "animal", "pet", "tortoise", "slow", "speed"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1535. tv-minimal-play
CREATE icon:tv_minimal_play CONTENT {
  identity: {
    value: 'tv_minimal_play',
    slug: 'tv-minimal-play'
  },
  presentation: {
    name_i18n: i18n_key:icon_tv_minimal_play_name,
    label_i18n: i18n_key:icon_tv_minimal_play_label,
    keywords: ["tv-minimal-play", "flatscreen", "television", "stream", "display", "widescreen", "high-definition", "hd", "1080p", "4k", "8k", "smart", "digital", "video", "movie", "live", "ott", "running", "start", "film", "home cinema", "entertainment", "showtime", "channels", "catchup"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1536. tv-minimal
CREATE icon:tv_minimal CONTENT {
  identity: {
    value: 'tv_minimal',
    slug: 'tv-minimal'
  },
  presentation: {
    name_i18n: i18n_key:icon_tv_minimal_name,
    label_i18n: i18n_key:icon_tv_minimal_label,
    keywords: ["tv-minimal", "flatscreen", "television", "stream", "display", "widescreen", "high-definition", "hd", "1080p", "4k", "8k", "smart", "digital", "video", "home cinema", "entertainment", "showtime", "channels", "catchup"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1537. tv
CREATE icon:tv CONTENT {
  identity: {
    value: 'tv',
    slug: 'tv'
  },
  presentation: {
    name_i18n: i18n_key:icon_tv_name,
    label_i18n: i18n_key:icon_tv_label,
    keywords: ["tv", "television", "stream", "display", "widescreen", "high-definition", "hd", "1080p", "4k", "8k", "smart", "digital", "video", "entertainment", "showtime", "channels", "terrestrial", "satellite", "cable", "broadcast", "live", "frequency", "tune", "scan", "aerial", "receiver", "transmission", "signal", "connection", "connectivity"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1538. twitch
CREATE icon:twitch CONTENT {
  identity: {
    value: 'twitch',
    slug: 'twitch'
  },
  presentation: {
    name_i18n: i18n_key:icon_twitch_name,
    label_i18n: i18n_key:icon_twitch_label,
    keywords: ["twitch", "logo", "social"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1539. twitter
CREATE icon:twitter CONTENT {
  identity: {
    value: 'twitter',
    slug: 'twitter'
  },
  presentation: {
    name_i18n: i18n_key:icon_twitter_name,
    label_i18n: i18n_key:icon_twitter_label,
    keywords: ["twitter", "logo", "social"]
  },
  context: {
    category: icon_category:brands,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1540. type-outline
CREATE icon:type_outline CONTENT {
  identity: {
    value: 'type_outline',
    slug: 'type-outline'
  },
  presentation: {
    name_i18n: i18n_key:icon_type_outline_name,
    label_i18n: i18n_key:icon_type_outline_label,
    keywords: ["type-outline", "text", "font", "typography", "silhouette", "profile", "contour", "stroke", "line"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1541. type
CREATE icon:type CONTENT {
  identity: {
    value: 'type',
    slug: 'type'
  },
  presentation: {
    name_i18n: i18n_key:icon_type_name,
    label_i18n: i18n_key:icon_type_label,
    keywords: ["type", "text", "font", "typography"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1542. umbrella-off
CREATE icon:umbrella_off CONTENT {
  identity: {
    value: 'umbrella_off',
    slug: 'umbrella-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_umbrella_off_name,
    label_i18n: i18n_key:icon_umbrella_off_label,
    keywords: ["umbrella-off", "rain", "weather", "uncovered", "uninsured", "antivirus", "unprotected", "risky"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1543. umbrella
CREATE icon:umbrella CONTENT {
  identity: {
    value: 'umbrella',
    slug: 'umbrella'
  },
  presentation: {
    name_i18n: i18n_key:icon_umbrella_name,
    label_i18n: i18n_key:icon_umbrella_label,
    keywords: ["umbrella", "rain", "weather"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1544. underline
CREATE icon:underline CONTENT {
  identity: {
    value: 'underline',
    slug: 'underline'
  },
  presentation: {
    name_i18n: i18n_key:icon_underline_name,
    label_i18n: i18n_key:icon_underline_label,
    keywords: ["underline", "text", "format"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1545. undo-2
CREATE icon:undo_2 CONTENT {
  identity: {
    value: 'undo_2',
    slug: 'undo-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_undo_2_name,
    label_i18n: i18n_key:icon_undo_2_label,
    keywords: ["undo-2", "redo", "rerun", "history", "back", "return", "reverse", "revert", "direction", "u-turn"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1546. undo-dot
CREATE icon:undo_dot CONTENT {
  identity: {
    value: 'undo_dot',
    slug: 'undo-dot'
  },
  presentation: {
    name_i18n: i18n_key:icon_undo_dot_name,
    label_i18n: i18n_key:icon_undo_dot_label,
    keywords: ["undo-dot", "redo", "history", "step", "back"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1547. undo
CREATE icon:undo CONTENT {
  identity: {
    value: 'undo',
    slug: 'undo'
  },
  presentation: {
    name_i18n: i18n_key:icon_undo_name,
    label_i18n: i18n_key:icon_undo_label,
    keywords: ["undo", "redo", "rerun", "history"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1548. unfold-horizontal
CREATE icon:unfold_horizontal CONTENT {
  identity: {
    value: 'unfold_horizontal',
    slug: 'unfold-horizontal'
  },
  presentation: {
    name_i18n: i18n_key:icon_unfold_horizontal_name,
    label_i18n: i18n_key:icon_unfold_horizontal_label,
    keywords: ["unfold-horizontal", "arrow", "collapse", "fold", "vertical", "dashed"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1549. unfold-vertical
CREATE icon:unfold_vertical CONTENT {
  identity: {
    value: 'unfold_vertical',
    slug: 'unfold-vertical'
  },
  presentation: {
    name_i18n: i18n_key:icon_unfold_vertical_name,
    label_i18n: i18n_key:icon_unfold_vertical_label,
    keywords: ["unfold-vertical", "arrow", "expand", "vertical", "dashed"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1550. ungroup
CREATE icon:ungroup CONTENT {
  identity: {
    value: 'ungroup',
    slug: 'ungroup'
  },
  presentation: {
    name_i18n: i18n_key:icon_ungroup_name,
    label_i18n: i18n_key:icon_ungroup_label,
    keywords: ["ungroup", "cubes", "packages", "parts", "units", "collection", "cluster", "separate"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1551. university
CREATE icon:university CONTENT {
  identity: {
    value: 'university',
    slug: 'university'
  },
  presentation: {
    name_i18n: i18n_key:icon_university_name,
    label_i18n: i18n_key:icon_university_label,
    keywords: ["university", "building", "education", "childhood", "school", "college", "academy", "institute"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1552. unlink-2
CREATE icon:unlink_2 CONTENT {
  identity: {
    value: 'unlink_2',
    slug: 'unlink-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_unlink_2_name,
    label_i18n: i18n_key:icon_unlink_2_label,
    keywords: ["unlink-2", "url", "unchain"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1553. unlink
CREATE icon:unlink CONTENT {
  identity: {
    value: 'unlink',
    slug: 'unlink'
  },
  presentation: {
    name_i18n: i18n_key:icon_unlink_name,
    label_i18n: i18n_key:icon_unlink_label,
    keywords: ["unlink", "url", "unchain"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1554. unplug
CREATE icon:unplug CONTENT {
  identity: {
    value: 'unplug',
    slug: 'unplug'
  },
  presentation: {
    name_i18n: i18n_key:icon_unplug_name,
    label_i18n: i18n_key:icon_unplug_label,
    keywords: ["unplug", "electricity", "energy", "electronics", "socket", "outlet", "disconnect"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1555. upload
CREATE icon:upload CONTENT {
  identity: {
    value: 'upload',
    slug: 'upload'
  },
  presentation: {
    name_i18n: i18n_key:icon_upload_name,
    label_i18n: i18n_key:icon_upload_label,
    keywords: ["upload", "file"]
  },
  context: {
    category: icon_category:arrows,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1556. usb
CREATE icon:usb CONTENT {
  identity: {
    value: 'usb',
    slug: 'usb'
  },
  presentation: {
    name_i18n: i18n_key:icon_usb_name,
    label_i18n: i18n_key:icon_usb_label,
    keywords: ["usb", "universal", "serial", "bus", "controller", "connector", "interface"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1557. user-check
CREATE icon:user_check CONTENT {
  identity: {
    value: 'user_check',
    slug: 'user-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_check_name,
    label_i18n: i18n_key:icon_user_check_label,
    keywords: ["user-check", "followed", "subscribed", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1558. user-cog
CREATE icon:user_cog CONTENT {
  identity: {
    value: 'user_cog',
    slug: 'user-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_cog_name,
    label_i18n: i18n_key:icon_user_cog_label,
    keywords: ["user-cog", "settings", "edit", "cog", "gear"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1559. user-lock
CREATE icon:user_lock CONTENT {
  identity: {
    value: 'user_lock',
    slug: 'user-lock'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_lock_name,
    label_i18n: i18n_key:icon_user_lock_label,
    keywords: ["user-lock", "person", "lock", "locked", "account", "secure"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1560. user-minus
CREATE icon:user_minus CONTENT {
  identity: {
    value: 'user_minus',
    slug: 'user-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_minus_name,
    label_i18n: i18n_key:icon_user_minus_label,
    keywords: ["user-minus", "delete", "remove", "unfollow", "unsubscribe"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1561. user-pen
CREATE icon:user_pen CONTENT {
  identity: {
    value: 'user_pen',
    slug: 'user-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_pen_name,
    label_i18n: i18n_key:icon_user_pen_label,
    keywords: ["user-pen", "person", "account", "contact", "profile", "edit", "change"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1562. user-plus
CREATE icon:user_plus CONTENT {
  identity: {
    value: 'user_plus',
    slug: 'user-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_plus_name,
    label_i18n: i18n_key:icon_user_plus_label,
    keywords: ["user-plus", "new", "add", "create", "follow", "subscribe"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1563. user-round-check
CREATE icon:user_round_check CONTENT {
  identity: {
    value: 'user_round_check',
    slug: 'user-round-check'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_check_name,
    label_i18n: i18n_key:icon_user_round_check_label,
    keywords: ["user-round-check", "followed", "subscribed", "done", "todo", "tick", "complete", "task"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1564. user-round-cog
CREATE icon:user_round_cog CONTENT {
  identity: {
    value: 'user_round_cog',
    slug: 'user-round-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_cog_name,
    label_i18n: i18n_key:icon_user_round_cog_label,
    keywords: ["user-round-cog", "settings", "edit", "cog", "gear"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1565. user-round-minus
CREATE icon:user_round_minus CONTENT {
  identity: {
    value: 'user_round_minus',
    slug: 'user-round-minus'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_minus_name,
    label_i18n: i18n_key:icon_user_round_minus_label,
    keywords: ["user-round-minus", "delete", "remove", "unfollow", "unsubscribe"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1566. user-round-pen
CREATE icon:user_round_pen CONTENT {
  identity: {
    value: 'user_round_pen',
    slug: 'user-round-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_pen_name,
    label_i18n: i18n_key:icon_user_round_pen_label,
    keywords: ["user-round-pen", "person", "account", "contact", "profile", "edit", "change"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1567. user-round-plus
CREATE icon:user_round_plus CONTENT {
  identity: {
    value: 'user_round_plus',
    slug: 'user-round-plus'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_plus_name,
    label_i18n: i18n_key:icon_user_round_plus_label,
    keywords: ["user-round-plus", "new", "add", "create", "follow", "subscribe"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1568. user-round-search
CREATE icon:user_round_search CONTENT {
  identity: {
    value: 'user_round_search',
    slug: 'user-round-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_search_name,
    label_i18n: i18n_key:icon_user_round_search_label,
    keywords: ["user-round-search", "person", "account", "contact", "find", "scan", "magnifier", "magnifying glass", "lens"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1569. user-round-x
CREATE icon:user_round_x CONTENT {
  identity: {
    value: 'user_round_x',
    slug: 'user-round-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_x_name,
    label_i18n: i18n_key:icon_user_round_x_label,
    keywords: ["user-round-x", "delete", "remove", "unfollow", "unsubscribe", "unavailable"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1570. user-round
CREATE icon:user_round CONTENT {
  identity: {
    value: 'user_round',
    slug: 'user-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_round_name,
    label_i18n: i18n_key:icon_user_round_label,
    keywords: ["user-round", "person", "account", "contact"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1571. user-search
CREATE icon:user_search CONTENT {
  identity: {
    value: 'user_search',
    slug: 'user-search'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_search_name,
    label_i18n: i18n_key:icon_user_search_label,
    keywords: ["user-search", "person", "account", "contact", "find", "scan", "magnifier", "magnifying glass", "lens"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1572. user-star
CREATE icon:user_star CONTENT {
  identity: {
    value: 'user_star',
    slug: 'user-star'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_star_name,
    label_i18n: i18n_key:icon_user_star_label,
    keywords: ["user-star", "person", "account", "favorite", "contact", "like", "review", "rating", "admin"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1573. user-x
CREATE icon:user_x CONTENT {
  identity: {
    value: 'user_x',
    slug: 'user-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_x_name,
    label_i18n: i18n_key:icon_user_x_label,
    keywords: ["user-x", "delete", "remove", "unfollow", "unsubscribe", "unavailable"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1574. user
CREATE icon:user CONTENT {
  identity: {
    value: 'user',
    slug: 'user'
  },
  presentation: {
    name_i18n: i18n_key:icon_user_name,
    label_i18n: i18n_key:icon_user_label,
    keywords: ["user", "person", "account", "contact"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1575. users-round
CREATE icon:users_round CONTENT {
  identity: {
    value: 'users_round',
    slug: 'users-round'
  },
  presentation: {
    name_i18n: i18n_key:icon_users_round_name,
    label_i18n: i18n_key:icon_users_round_label,
    keywords: ["users-round", "group", "people"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1576. users
CREATE icon:users CONTENT {
  identity: {
    value: 'users',
    slug: 'users'
  },
  presentation: {
    name_i18n: i18n_key:icon_users_name,
    label_i18n: i18n_key:icon_users_label,
    keywords: ["users", "group", "people"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1577. utensils-crossed
CREATE icon:utensils_crossed CONTENT {
  identity: {
    value: 'utensils_crossed',
    slug: 'utensils-crossed'
  },
  presentation: {
    name_i18n: i18n_key:icon_utensils_crossed_name,
    label_i18n: i18n_key:icon_utensils_crossed_label,
    keywords: ["utensils-crossed", "fork", "knife", "cutlery", "flatware", "tableware", "silverware", "food", "restaurant", "meal", "breakfast", "dinner", "supper"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1578. utensils
CREATE icon:utensils CONTENT {
  identity: {
    value: 'utensils',
    slug: 'utensils'
  },
  presentation: {
    name_i18n: i18n_key:icon_utensils_name,
    label_i18n: i18n_key:icon_utensils_label,
    keywords: ["utensils", "fork", "knife", "cutlery", "flatware", "tableware", "silverware", "food", "restaurant", "meal", "breakfast", "dinner", "supper"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1579. utility-pole
CREATE icon:utility_pole CONTENT {
  identity: {
    value: 'utility_pole',
    slug: 'utility-pole'
  },
  presentation: {
    name_i18n: i18n_key:icon_utility_pole_name,
    label_i18n: i18n_key:icon_utility_pole_label,
    keywords: ["utility-pole", "electricity", "energy", "transmission line", "telegraph pole", "power lines", "phone"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1580. variable
CREATE icon:variable CONTENT {
  identity: {
    value: 'variable',
    slug: 'variable'
  },
  presentation: {
    name_i18n: i18n_key:icon_variable_name,
    label_i18n: i18n_key:icon_variable_label,
    keywords: ["variable", "code", "coding", "programming", "symbol", "calculate", "algebra", "x", "parentheses", "parenthesis", "brackets", "parameter", "(", ")"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1581. vault
CREATE icon:vault CONTENT {
  identity: {
    value: 'vault',
    slug: 'vault'
  },
  presentation: {
    name_i18n: i18n_key:icon_vault_name,
    label_i18n: i18n_key:icon_vault_label,
    keywords: ["vault", "safe", "lockbox", "deposit", "locker", "coffer", "strongbox", "safety", "secure", "storage", "valuables", "bank"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1582. vector-square
CREATE icon:vector_square CONTENT {
  identity: {
    value: 'vector_square',
    slug: 'vector-square'
  },
  presentation: {
    name_i18n: i18n_key:icon_vector_square_name,
    label_i18n: i18n_key:icon_vector_square_label,
    keywords: ["vector-square", "shape", "geometry", "art", "width", "height", "size", "calculate", "measure", "select", "graphics", "box"]
  },
  context: {
    category: icon_category:shapes,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1583. vegan
CREATE icon:vegan CONTENT {
  identity: {
    value: 'vegan',
    slug: 'vegan'
  },
  presentation: {
    name_i18n: i18n_key:icon_vegan_name,
    label_i18n: i18n_key:icon_vegan_label,
    keywords: ["vegan", "vegetarian", "fruitarian", "herbivorous", "animal rights", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1584. venetian-mask
CREATE icon:venetian_mask CONTENT {
  identity: {
    value: 'venetian_mask',
    slug: 'venetian-mask'
  },
  presentation: {
    name_i18n: i18n_key:icon_venetian_mask_name,
    label_i18n: i18n_key:icon_venetian_mask_label,
    keywords: ["venetian-mask", "mask", "masquerade", "impersonate", "secret", "incognito"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1585. venus-and-mars
CREATE icon:venus_and_mars CONTENT {
  identity: {
    value: 'venus_and_mars',
    slug: 'venus-and-mars'
  },
  presentation: {
    name_i18n: i18n_key:icon_venus_and_mars_name,
    label_i18n: i18n_key:icon_venus_and_mars_label,
    keywords: ["venus-and-mars", "gender", "sex", "intersex", "androgynous", "hermaphrodite"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1586. venus
CREATE icon:venus CONTENT {
  identity: {
    value: 'venus',
    slug: 'venus'
  },
  presentation: {
    name_i18n: i18n_key:icon_venus_name,
    label_i18n: i18n_key:icon_venus_label,
    keywords: ["venus", "gender", "sex", "female", "feminine", "woman", "girl"]
  },
  context: {
    category: icon_category:medical,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1587. vibrate-off
CREATE icon:vibrate_off CONTENT {
  identity: {
    value: 'vibrate_off',
    slug: 'vibrate-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_vibrate_off_name,
    label_i18n: i18n_key:icon_vibrate_off_label,
    keywords: ["vibrate-off", "smartphone", "notification", "rumble", "haptic feedback", "notifications", "screen"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1588. vibrate
CREATE icon:vibrate CONTENT {
  identity: {
    value: 'vibrate',
    slug: 'vibrate'
  },
  presentation: {
    name_i18n: i18n_key:icon_vibrate_name,
    label_i18n: i18n_key:icon_vibrate_label,
    keywords: ["vibrate", "smartphone", "notification", "rumble", "haptic feedback", "screen"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1589. video-off
CREATE icon:video_off CONTENT {
  identity: {
    value: 'video_off',
    slug: 'video-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_video_off_name,
    label_i18n: i18n_key:icon_video_off_label,
    keywords: ["video-off", "camera", "movie", "film"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1590. video
CREATE icon:video CONTENT {
  identity: {
    value: 'video',
    slug: 'video'
  },
  presentation: {
    name_i18n: i18n_key:icon_video_name,
    label_i18n: i18n_key:icon_video_label,
    keywords: ["video", "camera", "movie", "film", "recording", "motion picture", "camcorder", "reel"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1591. videotape
CREATE icon:videotape CONTENT {
  identity: {
    value: 'videotape',
    slug: 'videotape'
  },
  presentation: {
    name_i18n: i18n_key:icon_videotape_name,
    label_i18n: i18n_key:icon_videotape_label,
    keywords: ["videotape", "vhs", "movie", "film", "recording", "motion picture", "showreel", "cassette"]
  },
  context: {
    category: icon_category:devices,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1592. view
CREATE icon:view CONTENT {
  identity: {
    value: 'view',
    slug: 'view'
  },
  presentation: {
    name_i18n: i18n_key:icon_view_name,
    label_i18n: i18n_key:icon_view_label,
    keywords: ["view", "eye", "look"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1593. voicemail
CREATE icon:voicemail CONTENT {
  identity: {
    value: 'voicemail',
    slug: 'voicemail'
  },
  presentation: {
    name_i18n: i18n_key:icon_voicemail_name,
    label_i18n: i18n_key:icon_voicemail_label,
    keywords: ["voicemail", "phone", "cassette", "tape", "reel", "recording", "audio"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1594. volleyball
CREATE icon:volleyball CONTENT {
  identity: {
    value: 'volleyball',
    slug: 'volleyball'
  },
  presentation: {
    name_i18n: i18n_key:icon_volleyball_name,
    label_i18n: i18n_key:icon_volleyball_label,
    keywords: ["volleyball", "beach", "sand", "net", "holiday", "vacation", "summer", "soccer", "football", "futbol", "kick", "pitch", "goal", "score", "bounce", "leather", "wool", "yarn", "knitting", "sewing", "thread", "embroidery", "textile"]
  },
  context: {
    category: icon_category:sports,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1595. volume-1
CREATE icon:volume_1 CONTENT {
  identity: {
    value: 'volume_1',
    slug: 'volume-1'
  },
  presentation: {
    name_i18n: i18n_key:icon_volume_1_name,
    label_i18n: i18n_key:icon_volume_1_label,
    keywords: ["volume-1", "music", "sound", "speaker"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1596. volume-2
CREATE icon:volume_2 CONTENT {
  identity: {
    value: 'volume_2',
    slug: 'volume-2'
  },
  presentation: {
    name_i18n: i18n_key:icon_volume_2_name,
    label_i18n: i18n_key:icon_volume_2_label,
    keywords: ["volume-2", "music", "sound", "speaker"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1597. volume-off
CREATE icon:volume_off CONTENT {
  identity: {
    value: 'volume_off',
    slug: 'volume-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_volume_off_name,
    label_i18n: i18n_key:icon_volume_off_label,
    keywords: ["volume-off", "music", "sound", "mute", "speaker"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1598. volume-x
CREATE icon:volume_x CONTENT {
  identity: {
    value: 'volume_x',
    slug: 'volume-x'
  },
  presentation: {
    name_i18n: i18n_key:icon_volume_x_name,
    label_i18n: i18n_key:icon_volume_x_label,
    keywords: ["volume-x", "music", "sound", "mute", "speaker"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1599. volume
CREATE icon:volume CONTENT {
  identity: {
    value: 'volume',
    slug: 'volume'
  },
  presentation: {
    name_i18n: i18n_key:icon_volume_name,
    label_i18n: i18n_key:icon_volume_label,
    keywords: ["volume", "music", "sound", "mute", "speaker"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1600. vote
CREATE icon:vote CONTENT {
  identity: {
    value: 'vote',
    slug: 'vote'
  },
  presentation: {
    name_i18n: i18n_key:icon_vote_name,
    label_i18n: i18n_key:icon_vote_label,
    keywords: ["vote", "vote", "poll", "ballot", "political", "social", "check", "tick"]
  },
  context: {
    category: icon_category:social,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1601. wallet-cards
CREATE icon:wallet_cards CONTENT {
  identity: {
    value: 'wallet_cards',
    slug: 'wallet-cards'
  },
  presentation: {
    name_i18n: i18n_key:icon_wallet_cards_name,
    label_i18n: i18n_key:icon_wallet_cards_label,
    keywords: ["wallet-cards", "money", "finance", "pocket", "credit", "purchase", "payment", "shopping", "retail", "consumer", "cc"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1602. wallet-minimal
CREATE icon:wallet_minimal CONTENT {
  identity: {
    value: 'wallet_minimal',
    slug: 'wallet-minimal'
  },
  presentation: {
    name_i18n: i18n_key:icon_wallet_minimal_name,
    label_i18n: i18n_key:icon_wallet_minimal_label,
    keywords: ["wallet-minimal", "finance", "pocket"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1603. wallet
CREATE icon:wallet CONTENT {
  identity: {
    value: 'wallet',
    slug: 'wallet'
  },
  presentation: {
    name_i18n: i18n_key:icon_wallet_name,
    label_i18n: i18n_key:icon_wallet_label,
    keywords: ["wallet", "money", "finance", "pocket"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1604. wallpaper
CREATE icon:wallpaper CONTENT {
  identity: {
    value: 'wallpaper',
    slug: 'wallpaper'
  },
  presentation: {
    name_i18n: i18n_key:icon_wallpaper_name,
    label_i18n: i18n_key:icon_wallpaper_label,
    keywords: ["wallpaper", "background", "texture", "image", "art", "design", "visual", "decor", "pattern", "screen", "cover", "lock screen"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1605. wand-sparkles
CREATE icon:wand_sparkles CONTENT {
  identity: {
    value: 'wand_sparkles',
    slug: 'wand-sparkles'
  },
  presentation: {
    name_i18n: i18n_key:icon_wand_sparkles_name,
    label_i18n: i18n_key:icon_wand_sparkles_label,
    keywords: ["wand-sparkles", "magic", "wizard", "magician"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1606. wand
CREATE icon:wand CONTENT {
  identity: {
    value: 'wand',
    slug: 'wand'
  },
  presentation: {
    name_i18n: i18n_key:icon_wand_name,
    label_i18n: i18n_key:icon_wand_label,
    keywords: ["wand", "magic", "selection"]
  },
  context: {
    category: icon_category:design,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1607. warehouse
CREATE icon:warehouse CONTENT {
  identity: {
    value: 'warehouse',
    slug: 'warehouse'
  },
  presentation: {
    name_i18n: i18n_key:icon_warehouse_name,
    label_i18n: i18n_key:icon_warehouse_label,
    keywords: ["warehouse", "storage", "storehouse", "depot", "depository", "repository", "stockroom", "logistics", "building"]
  },
  context: {
    category: icon_category:buildings,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1608. washing-machine
CREATE icon:washing_machine CONTENT {
  identity: {
    value: 'washing_machine',
    slug: 'washing-machine'
  },
  presentation: {
    name_i18n: i18n_key:icon_washing_machine_name,
    label_i18n: i18n_key:icon_washing_machine_label,
    keywords: ["washing-machine", "tumble dryer", "amenities", "electronics", "cycle", "clothes", "rinse", "spin", "drum"]
  },
  context: {
    category: icon_category:home,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1609. watch
CREATE icon:watch CONTENT {
  identity: {
    value: 'watch',
    slug: 'watch'
  },
  presentation: {
    name_i18n: i18n_key:icon_watch_name,
    label_i18n: i18n_key:icon_watch_label,
    keywords: ["watch", "clock", "time"]
  },
  context: {
    category: icon_category:time,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1610. waves-ladder
CREATE icon:waves_ladder CONTENT {
  identity: {
    value: 'waves_ladder',
    slug: 'waves-ladder'
  },
  presentation: {
    name_i18n: i18n_key:icon_waves_ladder_name,
    label_i18n: i18n_key:icon_waves_ladder_label,
    keywords: ["waves-ladder", "swimming", "water", "pool", "lifeguard", "ocean", "\ud83c\udf0a", "\ud83c\udfca\u200d\u2642\ufe0f", "\ud83c\udfca\u200d\u2640\ufe0f", "\ud83c\udfca", "\ud83e\udd7d"]
  },
  context: {
    category: icon_category:sports,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1611. waves
CREATE icon:waves CONTENT {
  identity: {
    value: 'waves',
    slug: 'waves'
  },
  presentation: {
    name_i18n: i18n_key:icon_waves_name,
    label_i18n: i18n_key:icon_waves_label,
    keywords: ["waves", "water", "sea", "sound", "hertz", "wavelength", "vibrate"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1612. waypoints
CREATE icon:waypoints CONTENT {
  identity: {
    value: 'waypoints',
    slug: 'waypoints'
  },
  presentation: {
    name_i18n: i18n_key:icon_waypoints_name,
    label_i18n: i18n_key:icon_waypoints_label,
    keywords: ["waypoints", "indirection", "vpn", "virtual private network", "proxy", "connections", "bounce", "reroute", "path", "journey", "planner", "stops", "stations", "shared", "spread", "viral"]
  },
  context: {
    category: icon_category:security,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1613. webcam
CREATE icon:webcam CONTENT {
  identity: {
    value: 'webcam',
    slug: 'webcam'
  },
  presentation: {
    name_i18n: i18n_key:icon_webcam_name,
    label_i18n: i18n_key:icon_webcam_label,
    keywords: ["webcam", "camera", "security"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1614. webhook-off
CREATE icon:webhook_off CONTENT {
  identity: {
    value: 'webhook_off',
    slug: 'webhook-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_webhook_off_name,
    label_i18n: i18n_key:icon_webhook_off_label,
    keywords: ["webhook-off", "push api", "interface", "callback"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1615. webhook
CREATE icon:webhook CONTENT {
  identity: {
    value: 'webhook',
    slug: 'webhook'
  },
  presentation: {
    name_i18n: i18n_key:icon_webhook_name,
    label_i18n: i18n_key:icon_webhook_label,
    keywords: ["webhook", "push api", "interface", "callback"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1616. weight
CREATE icon:weight CONTENT {
  identity: {
    value: 'weight',
    slug: 'weight'
  },
  presentation: {
    name_i18n: i18n_key:icon_weight_name,
    label_i18n: i18n_key:icon_weight_label,
    keywords: ["weight", "mass", "heavy", "lead", "metal", "measure", "geometry", "scales", "balance"]
  },
  context: {
    category: icon_category:math,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1617. wheat-off
CREATE icon:wheat_off CONTENT {
  identity: {
    value: 'wheat_off',
    slug: 'wheat-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_wheat_off_name,
    label_i18n: i18n_key:icon_wheat_off_label,
    keywords: ["wheat-off", "corn", "cereal", "grain", "gluten free", "allergy", "intolerance", "diet"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1618. wheat
CREATE icon:wheat CONTENT {
  identity: {
    value: 'wheat',
    slug: 'wheat'
  },
  presentation: {
    name_i18n: i18n_key:icon_wheat_name,
    label_i18n: i18n_key:icon_wheat_label,
    keywords: ["wheat", "corn", "cereal", "grain", "gluten"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1619. whole-word
CREATE icon:whole_word CONTENT {
  identity: {
    value: 'whole_word',
    slug: 'whole-word'
  },
  presentation: {
    name_i18n: i18n_key:icon_whole_word_name,
    label_i18n: i18n_key:icon_whole_word_label,
    keywords: ["whole-word", "text", "selection", "letters", "characters", "font", "typography"]
  },
  context: {
    category: icon_category:text,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1620. wifi-cog
CREATE icon:wifi_cog CONTENT {
  identity: {
    value: 'wifi_cog',
    slug: 'wifi-cog'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_cog_name,
    label_i18n: i18n_key:icon_wifi_cog_label,
    keywords: ["wifi-cog", "connection", "signal", "wireless", "directory", "settings", "control", "preferences", "cog", "edit", "gear"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1621. wifi-high
CREATE icon:wifi_high CONTENT {
  identity: {
    value: 'wifi_high',
    slug: 'wifi-high'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_high_name,
    label_i18n: i18n_key:icon_wifi_high_label,
    keywords: ["wifi-high", "connection", "signal", "wireless"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1622. wifi-low
CREATE icon:wifi_low CONTENT {
  identity: {
    value: 'wifi_low',
    slug: 'wifi-low'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_low_name,
    label_i18n: i18n_key:icon_wifi_low_label,
    keywords: ["wifi-low", "connection", "signal", "wireless"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1623. wifi-off
CREATE icon:wifi_off CONTENT {
  identity: {
    value: 'wifi_off',
    slug: 'wifi-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_off_name,
    label_i18n: i18n_key:icon_wifi_off_label,
    keywords: ["wifi-off", "disabled"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1624. wifi-pen
CREATE icon:wifi_pen CONTENT {
  identity: {
    value: 'wifi_pen',
    slug: 'wifi-pen'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_pen_name,
    label_i18n: i18n_key:icon_wifi_pen_label,
    keywords: ["wifi-pen", "edit", "wifi", "pen", "change", "network"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1625. wifi-sync
CREATE icon:wifi_sync CONTENT {
  identity: {
    value: 'wifi_sync',
    slug: 'wifi-sync'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_sync_name,
    label_i18n: i18n_key:icon_wifi_sync_label,
    keywords: ["wifi-sync", "connection", "signal", "wireless", "synchronize", "reconnect", "reset", "restart"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1626. wifi-zero
CREATE icon:wifi_zero CONTENT {
  identity: {
    value: 'wifi_zero',
    slug: 'wifi-zero'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_zero_name,
    label_i18n: i18n_key:icon_wifi_zero_label,
    keywords: ["wifi-zero", "connection", "signal", "wireless"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1627. wifi
CREATE icon:wifi CONTENT {
  identity: {
    value: 'wifi',
    slug: 'wifi'
  },
  presentation: {
    name_i18n: i18n_key:icon_wifi_name,
    label_i18n: i18n_key:icon_wifi_label,
    keywords: ["wifi", "connection", "signal", "wireless"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1628. wind-arrow-down
CREATE icon:wind_arrow_down CONTENT {
  identity: {
    value: 'wind_arrow_down',
    slug: 'wind-arrow-down'
  },
  presentation: {
    name_i18n: i18n_key:icon_wind_arrow_down_name,
    label_i18n: i18n_key:icon_wind_arrow_down_label,
    keywords: ["wind-arrow-down", "weather", "air", "pressure", "blow"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1629. wind
CREATE icon:wind CONTENT {
  identity: {
    value: 'wind',
    slug: 'wind'
  },
  presentation: {
    name_i18n: i18n_key:icon_wind_name,
    label_i18n: i18n_key:icon_wind_label,
    keywords: ["wind", "weather", "air", "blow"]
  },
  context: {
    category: icon_category:weather,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1630. wine-off
CREATE icon:wine_off CONTENT {
  identity: {
    value: 'wine_off',
    slug: 'wine-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_wine_off_name,
    label_i18n: i18n_key:icon_wine_off_label,
    keywords: ["wine-off", "alcohol", "beverage", "drink", "glass", "alcohol free", "abstinence", "abstaining", "teetotalism", "allergy", "intolerance"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1631. wine
CREATE icon:wine CONTENT {
  identity: {
    value: 'wine',
    slug: 'wine'
  },
  presentation: {
    name_i18n: i18n_key:icon_wine_name,
    label_i18n: i18n_key:icon_wine_label,
    keywords: ["wine", "alcohol", "beverage", "bar", "drink", "glass", "sommelier", "vineyard", "winery"]
  },
  context: {
    category: icon_category:food_beverage,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1632. workflow
CREATE icon:workflow CONTENT {
  identity: {
    value: 'workflow',
    slug: 'workflow'
  },
  presentation: {
    name_i18n: i18n_key:icon_workflow_name,
    label_i18n: i18n_key:icon_workflow_label,
    keywords: ["workflow", "action", "continuous integration", "ci", "automation", "devops", "network", "node", "connection"]
  },
  context: {
    category: icon_category:development,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1633. worm
CREATE icon:worm CONTENT {
  identity: {
    value: 'worm',
    slug: 'worm'
  },
  presentation: {
    name_i18n: i18n_key:icon_worm_name,
    label_i18n: i18n_key:icon_worm_label,
    keywords: ["worm", "invertebrate", "grub", "larva", "snake", "crawl", "wiggle", "slither", "pest control", "computer virus", "malware"]
  },
  context: {
    category: icon_category:animals,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1634. wrench
CREATE icon:wrench CONTENT {
  identity: {
    value: 'wrench',
    slug: 'wrench'
  },
  presentation: {
    name_i18n: i18n_key:icon_wrench_name,
    label_i18n: i18n_key:icon_wrench_label,
    keywords: ["wrench", "account", "settings", "spanner", "diy", "toolbox", "build", "construction"]
  },
  context: {
    category: icon_category:account,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1635. x
CREATE icon:x CONTENT {
  identity: {
    value: 'x',
    slug: 'x'
  },
  presentation: {
    name_i18n: i18n_key:icon_x_name,
    label_i18n: i18n_key:icon_x_label,
    keywords: ["x", "cancel", "close", "cross", "delete", "ex", "remove", "times", "clear", "math", "multiply", "multiplication"]
  },
  context: {
    category: icon_category:notifications,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1636. youtube
CREATE icon:youtube CONTENT {
  identity: {
    value: 'youtube',
    slug: 'youtube'
  },
  presentation: {
    name_i18n: i18n_key:icon_youtube_name,
    label_i18n: i18n_key:icon_youtube_label,
    keywords: ["youtube", "logo", "social", "video", "play"]
  },
  context: {
    category: icon_category:multimedia,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1637. zap-off
CREATE icon:zap_off CONTENT {
  identity: {
    value: 'zap_off',
    slug: 'zap-off'
  },
  presentation: {
    name_i18n: i18n_key:icon_zap_off_name,
    label_i18n: i18n_key:icon_zap_off_label,
    keywords: ["zap-off", "flash", "camera", "lightning", "electricity", "energy"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1638. zap
CREATE icon:zap CONTENT {
  identity: {
    value: 'zap',
    slug: 'zap'
  },
  presentation: {
    name_i18n: i18n_key:icon_zap_name,
    label_i18n: i18n_key:icon_zap_label,
    keywords: ["zap", "flash", "camera", "lightning", "electricity", "energy"]
  },
  context: {
    category: icon_category:connectivity,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1639. zoom-in
CREATE icon:zoom_in CONTENT {
  identity: {
    value: 'zoom_in',
    slug: 'zoom-in'
  },
  presentation: {
    name_i18n: i18n_key:icon_zoom_in_name,
    label_i18n: i18n_key:icon_zoom_in_label,
    keywords: ["zoom-in", "magnifying glass", "plus"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};

-- 1640. zoom-out
CREATE icon:zoom_out CONTENT {
  identity: {
    value: 'zoom_out',
    slug: 'zoom-out'
  },
  presentation: {
    name_i18n: i18n_key:icon_zoom_out_name,
    label_i18n: i18n_key:icon_zoom_out_label,
    keywords: ["zoom-out", "magnifying glass", "plus"]
  },
  context: {
    category: icon_category:accessibility,
    usage_hints: [],
    semantic_meaning: NONE
  },
  status: {
    is_active: true,
    is_system_icon: true,
    source: 'system'
  },
  timestamp: {}
};
