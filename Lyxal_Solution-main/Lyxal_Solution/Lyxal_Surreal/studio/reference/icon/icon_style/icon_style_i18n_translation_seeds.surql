-- =============================================================================
-- SEEDS: i18n_translation for icon_style
-- =============================================================================
-- Traductions pour les styles d'icônes
-- Langues: FR, EN, IT, DE, ES
-- Ordre de déploiement : Après icon_style_i18n_key_seeds.surql
-- =============================================================================

-- =============================================================================
-- 1. STROKE (OUTLINE)
-- =============================================================================

-- Français
RELATE i18n_key:icon_style_stroke_name->translation->language:fr
  SET text = 'Contour';

RELATE i18n_key:icon_style_stroke_description->translation->language:fr
  SET text = 'Icônes en contour avec trait, sans remplissage';

-- Anglais
RELATE i18n_key:icon_style_stroke_name->translation->language:en
  SET text = 'Stroke (Outline)';

RELATE i18n_key:icon_style_stroke_description->translation->language:en
  SET text = 'Outline icons with stroke, no fill';

-- Italien
RELATE i18n_key:icon_style_stroke_name->translation->language:it
  SET text = 'Contorno';

RELATE i18n_key:icon_style_stroke_description->translation->language:it
  SET text = 'Icone con contorno e tratto, senza riempimento';

-- Allemand
RELATE i18n_key:icon_style_stroke_name->translation->language:de
  SET text = 'Kontur';

RELATE i18n_key:icon_style_stroke_description->translation->language:de
  SET text = 'Kontur-Icons mit Strich, ohne Füllung';

-- Espagnol
RELATE i18n_key:icon_style_stroke_name->translation->language:es
  SET text = 'Contorno';

RELATE i18n_key:icon_style_stroke_description->translation->language:es
  SET text = 'Iconos con contorno y trazo, sin relleno';

-- =============================================================================
-- 2. SOLID (FILLED)
-- =============================================================================

-- Français
RELATE i18n_key:icon_style_solid_name->translation->language:fr
  SET text = 'Plein';

RELATE i18n_key:icon_style_solid_description->translation->language:fr
  SET text = 'Icônes remplies de couleur, sans contour';

-- Anglais
RELATE i18n_key:icon_style_solid_name->translation->language:en
  SET text = 'Solid (Filled)';

RELATE i18n_key:icon_style_solid_description->translation->language:en
  SET text = 'Filled icons with color, no outline';

-- Italien
RELATE i18n_key:icon_style_solid_name->translation->language:it
  SET text = 'Pieno';

RELATE i18n_key:icon_style_solid_description->translation->language:it
  SET text = 'Icone riempite di colore, senza contorno';

-- Allemand
RELATE i18n_key:icon_style_solid_name->translation->language:de
  SET text = 'Ausgefüllt';

RELATE i18n_key:icon_style_solid_description->translation->language:de
  SET text = 'Gefüllte Icons mit Farbe, ohne Kontur';

-- Espagnol
RELATE i18n_key:icon_style_solid_name->translation->language:es
  SET text = 'Sólido';

RELATE i18n_key:icon_style_solid_description->translation->language:es
  SET text = 'Iconos rellenos de color, sin contorno';

-- =============================================================================
-- 3. DUOTONE
-- =============================================================================

-- Français
RELATE i18n_key:icon_style_duotone_name->translation->language:fr
  SET text = 'Bicolore';

RELATE i18n_key:icon_style_duotone_description->translation->language:fr
  SET text = 'Icônes avec deux niveaux d\'opacité pour effet de profondeur';

-- Anglais
RELATE i18n_key:icon_style_duotone_name->translation->language:en
  SET text = 'Duotone';

RELATE i18n_key:icon_style_duotone_description->translation->language:en
  SET text = 'Icons with two opacity levels for depth effect';

-- Italien
RELATE i18n_key:icon_style_duotone_name->translation->language:it
  SET text = 'Bicolore';

RELATE i18n_key:icon_style_duotone_description->translation->language:it
  SET text = 'Icone con due livelli di opacità per effetto di profondità';

-- Allemand
RELATE i18n_key:icon_style_duotone_name->translation->language:de
  SET text = 'Duoton';

RELATE i18n_key:icon_style_duotone_description->translation->language:de
  SET text = 'Icons mit zwei Deckkraftstufen für Tiefeneffekt';

-- Espagnol
RELATE i18n_key:icon_style_duotone_name->translation->language:es
  SET text = 'Duotono';

RELATE i18n_key:icon_style_duotone_description->translation->language:es
  SET text = 'Iconos con dos niveles de opacidad para efecto de profundidad';

-- =============================================================================
-- 4. MIXED
-- =============================================================================

-- Français
RELATE i18n_key:icon_style_mixed_name->translation->language:fr
  SET text = 'Mixte';

RELATE i18n_key:icon_style_mixed_description->translation->language:fr
  SET text = 'Combinaison de contour et plein dans le même pack';

-- Anglais
RELATE i18n_key:icon_style_mixed_name->translation->language:en
  SET text = 'Mixed';

RELATE i18n_key:icon_style_mixed_description->translation->language:en
  SET text = 'Combination of stroke and solid in the same pack';

-- Italien
RELATE i18n_key:icon_style_mixed_name->translation->language:it
  SET text = 'Misto';

RELATE i18n_key:icon_style_mixed_description->translation->language:it
  SET text = 'Combinazione di contorno e pieno nello stesso pacchetto';

-- Allemand
RELATE i18n_key:icon_style_mixed_name->translation->language:de
  SET text = 'Gemischt';

RELATE i18n_key:icon_style_mixed_description->translation->language:de
  SET text = 'Kombination von Kontur und Ausgefüllt im selben Paket';

-- Espagnol
RELATE i18n_key:icon_style_mixed_name->translation->language:es
  SET text = 'Mixto';

RELATE i18n_key:icon_style_mixed_description->translation->language:es
  SET text = 'Combinación de contorno y sólido en el mismo paquete';

-- =============================================================================
-- 5. CUSTOM
-- =============================================================================

-- Français
RELATE i18n_key:icon_style_custom_name->translation->language:fr
  SET text = 'Personnalisé';

RELATE i18n_key:icon_style_custom_description->translation->language:fr
  SET text = 'Style personnalisé ou spécifique créé pour Lyxal';

-- Anglais
RELATE i18n_key:icon_style_custom_name->translation->language:en
  SET text = 'Custom';

RELATE i18n_key:icon_style_custom_description->translation->language:en
  SET text = 'Custom or specific style created for Lyxal';

-- Italien
RELATE i18n_key:icon_style_custom_name->translation->language:it
  SET text = 'Personalizzato';

RELATE i18n_key:icon_style_custom_description->translation->language:it
  SET text = 'Stile personalizzato o specifico creato per Lyxal';

-- Allemand
RELATE i18n_key:icon_style_custom_name->translation->language:de
  SET text = 'Benutzerdefiniert';

RELATE i18n_key:icon_style_custom_description->translation->language:de
  SET text = 'Benutzerdefinierter oder spezifischer Stil für Lyxal erstellt';

-- Espagnol
RELATE i18n_key:icon_style_custom_name->translation->language:es
  SET text = 'Personalizado';

RELATE i18n_key:icon_style_custom_description->translation->language:es
  SET text = 'Estilo personalizado o específico creado para Lyxal';

