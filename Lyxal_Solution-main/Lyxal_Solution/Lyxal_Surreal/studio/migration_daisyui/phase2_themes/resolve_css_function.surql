-- ============================================================================
-- FUNCTION : fn::resolve_css_classes
-- Description : Résolution automatique des classes CSS depuis les mappings
-- Module : studio/css_mapping
-- ============================================================================

DEFINE FUNCTION fn::resolve_css_classes(
  $element_code: string,
  $framework: string,
  $theme: option<record<studio_theme>> DEFAULT NONE,
  $tenant_id: option<string> DEFAULT NONE
) {
  -- 1. Récupérer l'élément CSS du dictionnaire
  LET $element = SELECT * FROM css_dictionary
    WHERE identity.code = $element_code
    LIMIT 1;

  IF !$element {
    THROW "CSS element not found: " + $element_code;
  }

  -- 2. Récupérer le mapping framework de base (priorité 1)
  LET $framework_mapping = SELECT * FROM css_framework_mapping
    WHERE css_element = $element.id AND framework = $framework
    ORDER BY metadata.priority DESC
    LIMIT 1;

  IF !$framework_mapping {
    THROW "No framework mapping found for element: " + $element_code + " and framework: " + $framework;
  }

  -- 3. Récupérer les overrides de thème (si thème spécifié)
  LET $theme_overrides = [];
  IF $theme {
    $theme_overrides = SELECT * FROM css_theme_mapping
      WHERE css_element = $element.id AND theme = $theme
      AND (conditions.tenant_ids CONTAINS $tenant_id OR conditions.tenant_ids = NONE)
      ORDER BY metadata.priority DESC;
  }

  -- 4. Appliquer les overrides par priorité
  LET $final_classes = $framework_mapping.mapping.classes;
  LET $final_custom_css = $framework_mapping.mapping.custom_css;
  LET $final_responsive = $element.styles.responsive;

  FOR $override IN $theme_overrides {
    -- Ajouter les classes supplémentaires
    IF $override.overrides.additional_classes {
      $final_classes = array::concat($final_classes, $override.overrides.additional_classes);
    }

    -- Override le CSS personnalisé (si spécifié)
    IF $override.overrides.custom_css {
      $final_custom_css = $override.overrides.custom_css;
    }

    -- Override le responsive (si spécifié)
    IF $override.overrides.responsive_overrides {
      $final_responsive = $override.overrides.responsive_overrides;
    }
  }

  -- 5. Retourner le résultat final
  RETURN {
    element_code: $element_code,
    framework: $framework,
    theme: $theme,
    tenant_id: $tenant_id,

    base_classes: $framework_mapping.mapping.classes,
    additional_classes: array::difference($final_classes, $framework_mapping.mapping.classes),
    all_classes: $final_classes,

    custom_css: $final_custom_css,
    responsive: $final_responsive,

    metadata: {
      element_version: $element.metadata.version,
      mapping_version: $framework_mapping.metadata.version,
      overrides_count: array::len($theme_overrides),
      resolved_at: time::now()
    }
  };
};

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- Résolution simple (framework + élément)
-- SELECT fn::resolve_css_classes("primary_button", "tailwind");

-- Résolution avec thème
-- SELECT fn::resolve_css_classes("primary_button", "tailwind", studio_theme:corporate);

-- Résolution complète (tenant + thème)
-- SELECT fn::resolve_css_classes("primary_button", "tailwind", studio_theme:corporate, "tenant_xyz");

-- ============================================================================
-- FONCTIONS UTILITAIRES ASSOCIÉES
-- ============================================================================

-- Vérifier si un mapping existe
DEFINE FUNCTION fn::css_mapping_exists(
  $element_code: string,
  $framework: string,
  $theme: option<record<studio_theme>> DEFAULT NONE
) {
  LET $element = SELECT id FROM css_dictionary WHERE identity.code = $element_code LIMIT 1;
  IF !$element { RETURN false; }

  LET $framework_mapping = SELECT id FROM css_framework_mapping
    WHERE css_element = $element.id AND framework = $framework LIMIT 1;
  IF !$framework_mapping { RETURN false; }

  IF $theme {
    LET $theme_mapping = SELECT id FROM css_theme_mapping
      WHERE css_element = $element.id AND theme = $theme LIMIT 1;
    RETURN !!$theme_mapping;
  }

  RETURN true;
};

-- Lister tous les éléments disponibles
DEFINE FUNCTION fn::list_css_elements() {
  RETURN SELECT
    identity.code,
    identity.name,
    metadata.category,
    metadata.semantic_meaning,
    compatibility.supported_frameworks
  FROM css_dictionary;
};

-- Lister les frameworks supportés pour un élément
DEFINE FUNCTION fn::get_supported_frameworks($element_code: string) {
  LET $element = SELECT * FROM css_dictionary WHERE identity.code = $element_code LIMIT 1;
  IF !$element { THROW "Element not found"; }

  LET $mappings = SELECT framework FROM css_framework_mapping
    WHERE css_element = $element.id;

  RETURN array::distinct($mappings.framework);
};

-- Valider un mapping
DEFINE FUNCTION fn::validate_css_mapping(
  $element_code: string,
  $framework: string
) {
  LET $exists = fn::css_mapping_exists($element_code, $framework);
  IF !$exists {
    RETURN {
      valid: false,
      error: "Mapping not found",
      element_code: $element_code,
      framework: $framework
    };
  }

  LET $resolved = fn::resolve_css_classes($element_code, $framework);

  RETURN {
    valid: true,
    element_code: $element_code,
    framework: $framework,
    classes_count: array::len($resolved.all_classes),
    has_custom_css: !!$resolved.custom_css,
    has_responsive: !!$resolved.responsive
  };
};
