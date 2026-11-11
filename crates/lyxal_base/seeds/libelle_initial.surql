-- ============================================================================
-- SEEDS : libellés du socle des unités et des types d'unités (clés lyxal_i18n)
-- MODULE : lyxal_base
-- TABLES : i18n_namespace, i18n_key, i18n_translation
-- STANDARD : CREATE protégé par record::exists, rejouable (AGENTS.md §5.5)
-- ============================================================================
-- Espace de noms base, langue source fr. Une clé par type (base.unite_type_<code>) et par
-- unité (base.unite_<code>), texte source en français et traduction anglaise, syntaxe plain.
-- Un texte existant n'est pas modifié au rejeu. Tous les champs sont écrits, y compris ceux que
-- la base calcule, pour une installation par import (OPTION IMPORT).

IF !record::exists(i18n_namespace:base) THEN (
    CREATE i18n_namespace:base CONTENT { key: "base", module: "lyxal_base", description: "Libellés des unités de mesure et des types d'unités", source_locale: i18n_locale:⟨fr⟩, created_at: time::now(), updated_at: time::now() }
) END;

-- Types

IF !record::exists(i18n_key:⟨base.unite_type_longueur⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_longueur⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_longueur", full_key: "base.unite_type_longueur", description: "Libellé du type d'unité LONGUEUR", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_longueur", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_longueur", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_longueur⟩, locale: i18n_locale:⟨fr⟩, text: "Longueur", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Longueur"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_longueur", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_longueur", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_longueur⟩, locale: i18n_locale:⟨en⟩, text: "Length", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Longueur"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_surface⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_surface⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_surface", full_key: "base.unite_type_surface", description: "Libellé du type d'unité SURFACE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_surface", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_surface", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_surface⟩, locale: i18n_locale:⟨fr⟩, text: "Surface", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Surface"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_surface", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_surface", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_surface⟩, locale: i18n_locale:⟨en⟩, text: "Area", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Surface"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_volume⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_volume⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_volume", full_key: "base.unite_type_volume", description: "Libellé du type d'unité VOLUME", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_volume", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_volume", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_volume⟩, locale: i18n_locale:⟨fr⟩, text: "Volume", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Volume"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_volume", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_volume", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_volume⟩, locale: i18n_locale:⟨en⟩, text: "Volume", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Volume"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_masse⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_masse⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_masse", full_key: "base.unite_type_masse", description: "Libellé du type d'unité MASSE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_masse", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_masse", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_masse⟩, locale: i18n_locale:⟨fr⟩, text: "Masse", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Masse"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_masse", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_masse", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_masse⟩, locale: i18n_locale:⟨en⟩, text: "Mass", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Masse"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_duree⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_duree⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_duree", full_key: "base.unite_type_duree", description: "Libellé du type d'unité DUREE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_duree", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_duree", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_duree⟩, locale: i18n_locale:⟨fr⟩, text: "Durée", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Durée"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_duree", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_duree", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_duree⟩, locale: i18n_locale:⟨en⟩, text: "Duration", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Durée"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_quantite⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_quantite⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_quantite", full_key: "base.unite_type_quantite", description: "Libellé du type d'unité QUANTITE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_quantite", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_quantite", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_quantite⟩, locale: i18n_locale:⟨fr⟩, text: "Quantité / décompte", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Quantité / décompte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_quantite", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_quantite", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_quantite⟩, locale: i18n_locale:⟨en⟩, text: "Quantity / count", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Quantité / décompte"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_conditionnement⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_conditionnement⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_conditionnement", full_key: "base.unite_type_conditionnement", description: "Libellé du type d'unité CONDITIONNEMENT", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_conditionnement", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_conditionnement", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_conditionnement⟩, locale: i18n_locale:⟨fr⟩, text: "Conditionnement", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Conditionnement"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_conditionnement", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_conditionnement", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_conditionnement⟩, locale: i18n_locale:⟨en⟩, text: "Packaging", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Conditionnement"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_energie⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_energie⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_energie", full_key: "base.unite_type_energie", description: "Libellé du type d'unité ENERGIE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_energie", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_energie", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_energie⟩, locale: i18n_locale:⟨fr⟩, text: "Énergie", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Énergie"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_energie", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_energie", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_energie⟩, locale: i18n_locale:⟨en⟩, text: "Energy", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Énergie"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_puissance⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_puissance⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_puissance", full_key: "base.unite_type_puissance", description: "Libellé du type d'unité PUISSANCE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_puissance", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_puissance", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_puissance⟩, locale: i18n_locale:⟨fr⟩, text: "Puissance", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Puissance"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_puissance", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_puissance", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_puissance⟩, locale: i18n_locale:⟨en⟩, text: "Power", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Puissance"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_pression⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_pression⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_pression", full_key: "base.unite_type_pression", description: "Libellé du type d'unité PRESSION", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_pression", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_pression", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_pression⟩, locale: i18n_locale:⟨fr⟩, text: "Pression", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pression"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_pression", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_pression", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_pression⟩, locale: i18n_locale:⟨en⟩, text: "Pressure", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pression"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_type_debit⟩) THEN (
    CREATE i18n_key:⟨base.unite_type_debit⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_type_debit", full_key: "base.unite_type_debit", description: "Libellé du type d'unité DEBIT", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_debit", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_debit", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_debit⟩, locale: i18n_locale:⟨fr⟩, text: "Débit", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Débit"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_type_debit", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_type_debit", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_type_debit⟩, locale: i18n_locale:⟨en⟩, text: "Flow rate", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Débit"), created_at: time::now(), updated_at: time::now() }
) END;

-- Unités

IF !record::exists(i18n_key:⟨base.unite_km⟩) THEN (
    CREATE i18n_key:⟨base.unite_km⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_km", full_key: "base.unite_km", description: "Libellé de l'unité KM", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_km", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_km", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_km⟩, locale: i18n_locale:⟨fr⟩, text: "Kilomètre", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Kilomètre"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_km", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_km", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_km⟩, locale: i18n_locale:⟨en⟩, text: "Kilometre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Kilomètre"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_m⟩) THEN (
    CREATE i18n_key:⟨base.unite_m⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_m", full_key: "base.unite_m", description: "Libellé de l'unité M", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_m⟩, locale: i18n_locale:⟨fr⟩, text: "Mètre", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_m⟩, locale: i18n_locale:⟨en⟩, text: "Metre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_ml⟩) THEN (
    CREATE i18n_key:⟨base.unite_ml⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_ml", full_key: "base.unite_ml", description: "Libellé de l'unité ML", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ml", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ml", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_ml⟩, locale: i18n_locale:⟨fr⟩, text: "Mètre linéaire", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre linéaire"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ml", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ml", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_ml⟩, locale: i18n_locale:⟨en⟩, text: "Linear metre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre linéaire"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_cm⟩) THEN (
    CREATE i18n_key:⟨base.unite_cm⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_cm", full_key: "base.unite_cm", description: "Libellé de l'unité CM", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_cm", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_cm", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_cm⟩, locale: i18n_locale:⟨fr⟩, text: "Centimètre", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Centimètre"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_cm", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_cm", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_cm⟩, locale: i18n_locale:⟨en⟩, text: "Centimetre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Centimètre"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_mm⟩) THEN (
    CREATE i18n_key:⟨base.unite_mm⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_mm", full_key: "base.unite_mm", description: "Libellé de l'unité MM", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_mm", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_mm", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_mm⟩, locale: i18n_locale:⟨fr⟩, text: "Millimètre", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Millimètre"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_mm", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_mm", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_mm⟩, locale: i18n_locale:⟨en⟩, text: "Millimetre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Millimètre"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_ha⟩) THEN (
    CREATE i18n_key:⟨base.unite_ha⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_ha", full_key: "base.unite_ha", description: "Libellé de l'unité HA", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ha", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ha", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_ha⟩, locale: i18n_locale:⟨fr⟩, text: "Hectare", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Hectare"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ha", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ha", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_ha⟩, locale: i18n_locale:⟨en⟩, text: "Hectare", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Hectare"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_m2⟩) THEN (
    CREATE i18n_key:⟨base.unite_m2⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_m2", full_key: "base.unite_m2", description: "Libellé de l'unité M2", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m2", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m2", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_m2⟩, locale: i18n_locale:⟨fr⟩, text: "Mètre carré", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre carré"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m2", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m2", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_m2⟩, locale: i18n_locale:⟨en⟩, text: "Square metre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre carré"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_m3⟩) THEN (
    CREATE i18n_key:⟨base.unite_m3⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_m3", full_key: "base.unite_m3", description: "Libellé de l'unité M3", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m3", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m3", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_m3⟩, locale: i18n_locale:⟨fr⟩, text: "Mètre cube", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre cube"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m3", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m3", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_m3⟩, locale: i18n_locale:⟨en⟩, text: "Cubic metre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre cube"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_ltr⟩) THEN (
    CREATE i18n_key:⟨base.unite_ltr⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_ltr", full_key: "base.unite_ltr", description: "Libellé de l'unité LTR", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ltr", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ltr", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_ltr⟩, locale: i18n_locale:⟨fr⟩, text: "Litre", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Litre"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ltr", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ltr", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_ltr⟩, locale: i18n_locale:⟨en⟩, text: "Litre", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Litre"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_t⟩) THEN (
    CREATE i18n_key:⟨base.unite_t⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_t", full_key: "base.unite_t", description: "Libellé de l'unité T", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_t", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_t", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_t⟩, locale: i18n_locale:⟨fr⟩, text: "Tonne", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Tonne"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_t", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_t", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_t⟩, locale: i18n_locale:⟨en⟩, text: "Tonne", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Tonne"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_kg⟩) THEN (
    CREATE i18n_key:⟨base.unite_kg⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_kg", full_key: "base.unite_kg", description: "Libellé de l'unité KG", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_kg", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_kg", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_kg⟩, locale: i18n_locale:⟨fr⟩, text: "Kilogramme", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Kilogramme"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_kg", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_kg", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_kg⟩, locale: i18n_locale:⟨en⟩, text: "Kilogram", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Kilogramme"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_g⟩) THEN (
    CREATE i18n_key:⟨base.unite_g⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_g", full_key: "base.unite_g", description: "Libellé de l'unité G", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_g", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_g", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_g⟩, locale: i18n_locale:⟨fr⟩, text: "Gramme", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Gramme"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_g", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_g", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_g⟩, locale: i18n_locale:⟨en⟩, text: "Gram", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Gramme"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_mois⟩) THEN (
    CREATE i18n_key:⟨base.unite_mois⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_mois", full_key: "base.unite_mois", description: "Libellé de l'unité MOIS", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_mois", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_mois", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_mois⟩, locale: i18n_locale:⟨fr⟩, text: "Mois", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mois"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_mois", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_mois", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_mois⟩, locale: i18n_locale:⟨en⟩, text: "Month", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mois"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_sem⟩) THEN (
    CREATE i18n_key:⟨base.unite_sem⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_sem", full_key: "base.unite_sem", description: "Libellé de l'unité SEM", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_sem", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_sem", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_sem⟩, locale: i18n_locale:⟨fr⟩, text: "Semaine", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Semaine"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_sem", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_sem", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_sem⟩, locale: i18n_locale:⟨en⟩, text: "Week", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Semaine"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_j⟩) THEN (
    CREATE i18n_key:⟨base.unite_j⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_j", full_key: "base.unite_j", description: "Libellé de l'unité J", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_j", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_j", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_j⟩, locale: i18n_locale:⟨fr⟩, text: "Jour", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Jour"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_j", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_j", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_j⟩, locale: i18n_locale:⟨en⟩, text: "Day", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Jour"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_h⟩) THEN (
    CREATE i18n_key:⟨base.unite_h⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_h", full_key: "base.unite_h", description: "Libellé de l'unité H", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_h", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_h", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_h⟩, locale: i18n_locale:⟨fr⟩, text: "Heure", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Heure"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_h", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_h", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_h⟩, locale: i18n_locale:⟨en⟩, text: "Hour", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Heure"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_u⟩) THEN (
    CREATE i18n_key:⟨base.unite_u⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_u", full_key: "base.unite_u", description: "Libellé de l'unité U", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_u", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_u", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_u⟩, locale: i18n_locale:⟨fr⟩, text: "Unité", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Unité"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_u", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_u", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_u⟩, locale: i18n_locale:⟨en⟩, text: "Unit", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Unité"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_pce⟩) THEN (
    CREATE i18n_key:⟨base.unite_pce⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_pce", full_key: "base.unite_pce", description: "Libellé de l'unité PCE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_pce", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_pce", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_pce⟩, locale: i18n_locale:⟨fr⟩, text: "Pièce", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pièce"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_pce", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_pce", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_pce⟩, locale: i18n_locale:⟨en⟩, text: "Piece", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Pièce"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_ens⟩) THEN (
    CREATE i18n_key:⟨base.unite_ens⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_ens", full_key: "base.unite_ens", description: "Libellé de l'unité ENS", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ens", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ens", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_ens⟩, locale: i18n_locale:⟨fr⟩, text: "Ensemble", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Ensemble"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_ens", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_ens", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_ens⟩, locale: i18n_locale:⟨en⟩, text: "Set", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Ensemble"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_paire⟩) THEN (
    CREATE i18n_key:⟨base.unite_paire⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_paire", full_key: "base.unite_paire", description: "Libellé de l'unité PAIRE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_paire", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_paire", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_paire⟩, locale: i18n_locale:⟨fr⟩, text: "Paire", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Paire"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_paire", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_paire", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_paire⟩, locale: i18n_locale:⟨en⟩, text: "Pair", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Paire"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_forfait⟩) THEN (
    CREATE i18n_key:⟨base.unite_forfait⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_forfait", full_key: "base.unite_forfait", description: "Libellé de l'unité FORFAIT", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_forfait", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_forfait", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_forfait⟩, locale: i18n_locale:⟨fr⟩, text: "Forfait", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Forfait"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_forfait", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_forfait", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_forfait⟩, locale: i18n_locale:⟨en⟩, text: "Lump sum", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Forfait"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_roul⟩) THEN (
    CREATE i18n_key:⟨base.unite_roul⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_roul", full_key: "base.unite_roul", description: "Libellé de l'unité ROUL", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_roul", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_roul", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_roul⟩, locale: i18n_locale:⟨fr⟩, text: "Rouleau", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Rouleau"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_roul", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_roul", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_roul⟩, locale: i18n_locale:⟨en⟩, text: "Roll", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Rouleau"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_sac⟩) THEN (
    CREATE i18n_key:⟨base.unite_sac⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_sac", full_key: "base.unite_sac", description: "Libellé de l'unité SAC", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_sac", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_sac", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_sac⟩, locale: i18n_locale:⟨fr⟩, text: "Sac", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Sac"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_sac", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_sac", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_sac⟩, locale: i18n_locale:⟨en⟩, text: "Bag", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Sac"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_pal⟩) THEN (
    CREATE i18n_key:⟨base.unite_pal⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_pal", full_key: "base.unite_pal", description: "Libellé de l'unité PAL", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_pal", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_pal", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_pal⟩, locale: i18n_locale:⟨fr⟩, text: "Palette", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Palette"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_pal", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_pal", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_pal⟩, locale: i18n_locale:⟨en⟩, text: "Pallet", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Palette"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_bte⟩) THEN (
    CREATE i18n_key:⟨base.unite_bte⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_bte", full_key: "base.unite_bte", description: "Libellé de l'unité BTE", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_bte", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_bte", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_bte⟩, locale: i18n_locale:⟨fr⟩, text: "Boîte", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Boîte"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_bte", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_bte", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_bte⟩, locale: i18n_locale:⟨en⟩, text: "Box", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Boîte"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_cart⟩) THEN (
    CREATE i18n_key:⟨base.unite_cart⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_cart", full_key: "base.unite_cart", description: "Libellé de l'unité CART", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_cart", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_cart", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_cart⟩, locale: i18n_locale:⟨fr⟩, text: "Carton", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Carton"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_cart", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_cart", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_cart⟩, locale: i18n_locale:⟨en⟩, text: "Carton", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Carton"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_kwh⟩) THEN (
    CREATE i18n_key:⟨base.unite_kwh⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_kwh", full_key: "base.unite_kwh", description: "Libellé de l'unité KWH", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_kwh", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_kwh", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_kwh⟩, locale: i18n_locale:⟨fr⟩, text: "Kilowatt-heure", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Kilowatt-heure"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_kwh", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_kwh", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_kwh⟩, locale: i18n_locale:⟨en⟩, text: "Kilowatt-hour", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Kilowatt-heure"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_w⟩) THEN (
    CREATE i18n_key:⟨base.unite_w⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_w", full_key: "base.unite_w", description: "Libellé de l'unité W", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_w", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_w", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_w⟩, locale: i18n_locale:⟨fr⟩, text: "Watt", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Watt"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_w", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_w", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_w⟩, locale: i18n_locale:⟨en⟩, text: "Watt", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Watt"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_bar⟩) THEN (
    CREATE i18n_key:⟨base.unite_bar⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_bar", full_key: "base.unite_bar", description: "Libellé de l'unité BAR", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_bar", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_bar", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_bar⟩, locale: i18n_locale:⟨fr⟩, text: "Bar", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Bar"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_bar", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_bar", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_bar⟩, locale: i18n_locale:⟨en⟩, text: "Bar", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Bar"), created_at: time::now(), updated_at: time::now() }
) END;

IF !record::exists(i18n_key:⟨base.unite_m3h⟩) THEN (
    CREATE i18n_key:⟨base.unite_m3h⟩ CONTENT { namespace: i18n_namespace:base, name: "unite_m3h", full_key: "base.unite_m3h", description: "Libellé de l'unité M3H", params: [], created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m3h", "fr", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m3h", "fr", "installation"] CONTENT { key: i18n_key:⟨base.unite_m3h⟩, locale: i18n_locale:⟨fr⟩, text: "Mètre cube par heure", syntax: "plain", scope_key: "installation", is_source: true, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre cube par heure"), created_at: time::now(), updated_at: time::now() }
) END;
IF !record::exists(i18n_translation:["base.unite_m3h", "en", "installation"]) THEN (
    CREATE i18n_translation:["base.unite_m3h", "en", "installation"] CONTENT { key: i18n_key:⟨base.unite_m3h⟩, locale: i18n_locale:⟨en⟩, text: "Cubic metre per hour", syntax: "plain", scope_key: "installation", is_source: false, state: "translated", revision: 1, outdated: false, source_hash: crypto::blake3("Mètre cube par heure"), created_at: time::now(), updated_at: time::now() }
) END;
