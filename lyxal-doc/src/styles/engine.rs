use crate::styles::model::*;
use crate::styles::visual::*;
use crate::styles::error::StyleError;
use std::collections::{BTreeMap, HashSet};

pub struct StyleEngine {
    sheet: StyleSheet,
}

impl StyleEngine {
    pub fn new(sheet: StyleSheet) -> Self {
        Self { sheet }
    }

    /// Résout le style pour un élément donné selon la cascade :
    /// Role -> StyleRef -> Intent -> Variants
    pub fn resolve_element_style(
        &self,
        role: &str,
        style_ref: Option<&str>,
        intent: Option<&str>,
        context: RenderContext,
    ) -> Result<BTreeMap<String, StyleValue>, StyleError> {
        let mut resolved = BTreeMap::new();

        // 1. Appliquer le style de base (Role)
        if let Some(role_style) = self.get_flattened_style(role)? {
            resolved.extend(role_style);
        }

        // 2. Appliquer StyleRef (Surcharge explicite)
        if let Some(ref_name) = style_ref {
            if let Some(ref_style) = self.get_flattened_style(ref_name)? {
                resolved.extend(ref_style);
            }
        }

        // 3. Appliquer Intent (Surcharge sémantique)
        if let Some(intent_name) = intent {
            if let Some(intent_style) = self.get_flattened_style(intent_name)? {
                resolved.extend(intent_style);
            }
        }

        // 4. Appliquer les Variantes (Overlay contextuel)
        self.apply_variants(&mut resolved, context);

        // 5. Conversion des unités selon le contexte
        self.convert_units(&mut resolved, context);

        Ok(resolved)
    }

    fn get_flattened_style(&self, name: &str) -> Result<Option<BTreeMap<String, StyleValue>>, StyleError> {
        let mut combined_props = BTreeMap::new();
        let mut current_name = name.to_string();
        let mut visited = HashSet::new();

        while let Some(style_def) = self.sheet.base_styles.get(&current_name) {
            if !visited.insert(current_name.clone()) {
                return Err(StyleError::InheritanceCycle(name.to_string()));
            }

            // On fusionne les propriétés (le style enfant gagne sur le parent)
            // Donc on parcourt de l'enfant vers le parent, mais on n'écrase que si absent.
            for (k, v) in &style_def.properties {
                combined_props.entry(k.clone()).or_insert_with(|| v.clone());
            }

            if let Some(ref parent) = style_def.parent {
                current_name = parent.clone();
            } else {
                break;
            }
        }

        if combined_props.is_empty() && !self.sheet.base_styles.contains_key(name) {
            return Ok(None);
        }

        Ok(Some(combined_props))
    }

    fn apply_variants(&self, props: &mut BTreeMap<String, StyleValue>, context: RenderContext) {
        let variant_key = match context {
            RenderContext::Dark => "mode:dark",
            RenderContext::Print => "media:print",
            RenderContext::Screen => "media:screen",
        };

        if let Some(variant) = self.sheet.variants.get(variant_key) {
            for (style_name, overrides) in &variant.overrides {
                // Pour simplifier v1.0, on applique les variantes si elles matchent le nom du style d'origine
                // Ou on pourrait avoir des variantes globales.
                for (k, v) in overrides {
                    props.insert(k.clone(), v.clone());
                }
            }
        }
    }

    fn convert_units(&self, props: &mut BTreeMap<String, StyleValue>, context: RenderContext) {
        // Règle normative : 1 unit = 1pt en Print, 1.33px en Screen
        let multiplier = match context {
            RenderContext::Print => 1.0,
            RenderContext::Screen => 1.33,
            RenderContext::Dark => 1.33,
        };

        for (k, v) in props.iter_mut() {
            if k.contains("size") || k.contains("width") || k.contains("margin") || k.contains("padding") {
                if let StyleValue::Number(n) = v {
                    *v = StyleValue::Number(*n * multiplier);
                }
            }
        }
    }
}

