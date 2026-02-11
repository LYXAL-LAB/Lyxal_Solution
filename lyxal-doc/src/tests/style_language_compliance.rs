use crate::styles::*;
use std::collections::BTreeMap;

fn setup_test_stylesheet() -> StyleSheet {
    let mut sheet = StyleSheet::new("Test Theme".to_string(), "1.0".to_string());

    // 1. Style de base (Root/Paragraph)
    sheet.base_styles.insert("paragraph".to_string(), StyleDefinition {
        parent: None,
        properties: BTreeMap::from([
            ("font_size".to_string(), StyleValue::Number(12.0)),
            ("text_color".to_string(), StyleValue::Color("#000000".to_string())),
        ]),
    });

    // 2. Héritage (Heading hérite de Paragraph)
    sheet.base_styles.insert("heading".to_string(), StyleDefinition {
        parent: Some("paragraph".to_string()),
        properties: BTreeMap::from([
            ("font_size".to_string(), StyleValue::Number(24.0)),
            ("font_weight".to_string(), StyleValue::Number(700.0)),
        ]),
    });

    // 3. Intent (Disclaimer)
    sheet.base_styles.insert("disclaimer".to_string(), StyleDefinition {
        parent: None,
        properties: BTreeMap::from([
            ("text_color".to_string(), StyleValue::Color("#FF0000".to_string())),
            ("bg_color".to_string(), StyleValue::Color("#FFF0F0".to_string())),
        ]),
    });

    // 4. Variante (Dark Mode)
    sheet.variants.insert("mode:dark".to_string(), VariantOverlay {
        context_key: "mode:dark".to_string(),
        overrides: BTreeMap::from([
            ("paragraph".to_string(), BTreeMap::from([
                ("text_color".to_string(), StyleValue::Color("#FFFFFF".to_string())),
            ])),
        ]),
    });

    sheet
}

#[test]
fn test_style_inheritance_and_override() {
    let sheet = setup_test_stylesheet();
    let engine = StyleEngine::new(sheet);

    // Résoudre "heading" sans StyleRef ni Intent
    let styles = engine.resolve_element_style("heading", None, None, RenderContext::Print).unwrap();

    // Doit avoir sa propre font_size (24) et hériter du text_color (Black)
    assert_eq!(styles.get("font_size"), Some(&StyleValue::Number(24.0)));
    assert_eq!(styles.get("text_color"), Some(&StyleValue::Color("#000000".to_string())));
    assert_eq!(styles.get("font_weight"), Some(&StyleValue::Number(700.0)));
}

#[test]
fn test_style_intent_override() {
    let sheet = setup_test_stylesheet();
    let engine = StyleEngine::new(sheet);

    // Paragraphe avec Intent "disclaimer"
    let styles = engine.resolve_element_style("paragraph", None, Some("disclaimer"), RenderContext::Print).unwrap();

    // L'Intent doit surcharger la couleur de texte du paragraphe
    assert_eq!(styles.get("text_color"), Some(&StyleValue::Color("#FF0000".to_string())));
    assert_eq!(styles.get("bg_color"), Some(&StyleValue::Color("#FFF0F0".to_string())));
    assert_eq!(styles.get("font_size"), Some(&StyleValue::Number(12.0)));
}

#[test]
fn test_style_variant_dark_mode() {
    let sheet = setup_test_stylesheet();
    let engine = StyleEngine::new(sheet);

    // Paragraphe en Dark Mode
    let styles = engine.resolve_element_style("paragraph", None, None, RenderContext::Dark).unwrap();

    // La variante doit surcharger la couleur (White au lieu de Black)
    // Et l'unité de taille doit être convertie (12 * 1.33 = 15.96)
    assert_eq!(styles.get("text_color"), Some(&StyleValue::Color("#FFFFFF".to_string())));
    
    if let Some(StyleValue::Number(size)) = styles.get("font_size") {
        assert!((size - 15.96).abs() < 0.01);
    } else {
        panic!("font_size manquante ou mauvais type");
    }
}

#[test]
fn test_style_cycle_detection() {
    let mut sheet = StyleSheet::new("Cycle Theme".to_string(), "1.0".to_string());
    
    // A -> B -> A
    sheet.base_styles.insert("A".to_string(), StyleDefinition {
        parent: Some("B".to_string()),
        properties: BTreeMap::new(),
    });
    sheet.base_styles.insert("B".to_string(), StyleDefinition {
        parent: Some("A".to_string()),
        properties: BTreeMap::new(),
    });

    let engine = StyleEngine::new(sheet);
    let result = engine.resolve_element_style("A", None, None, RenderContext::Print);

    assert!(matches!(result, Err(StyleError::InheritanceCycle(_))));
}

#[test]
fn test_style_unit_conversion_print_vs_screen() {
    let sheet = setup_test_stylesheet();
    let engine = StyleEngine::new(sheet);

    // Print Context (1:1)
    let styles_print = engine.resolve_element_style("paragraph", None, None, RenderContext::Print).unwrap();
    assert_eq!(styles_print.get("font_size"), Some(&StyleValue::Number(12.0)));

    // Screen Context (1:1.33)
    let styles_screen = engine.resolve_element_style("paragraph", None, None, RenderContext::Screen).unwrap();
    if let Some(StyleValue::Number(size)) = styles_screen.get("font_size") {
        assert!((size - 15.96).abs() < 0.01);
    }
}

