use std::collections::HashMap;
use std::hash::{Hash, Hasher};
use ahash::AHasher;
use lyxal_types::LyxalStudioData;
use lyxal_types::style::StyleDecl;

pub struct LyxalStyleSheet {
    /// Mapping du hash vers la rÃ¨gle CSS complÃ¨te
    /// Exemple: "c123" -> ".c123 { color: red; }"
    pub rules: HashMap<String, String>,
    
    /// Mapping de l'ID de source de style vers ses classes atomiques gÃ©nÃ©rÃ©es
    pub style_source_to_classes: HashMap<String, Vec<String>>,
}

impl LyxalStyleSheet {
    pub fn new() -> Self {
        Self {
            rules: HashMap::new(),
            style_source_to_classes: HashMap::new(),
        }
    }

    /// GÃ©nÃ¨re le CSS complet Ã  partir des donnÃ©es Lyxal
    pub fn generate(&mut self, data: &LyxalStudioData) -> String {
        self.rules.clear();
        self.style_source_to_classes.clear();

        // On regroupe par breakpoint pour gÃ©nÃ©rer des blocs @media propres
        let mut by_breakpoint: HashMap<String, Vec<&StyleDecl>> = HashMap::new();

        for decl in data.styles.values() {
            by_breakpoint
                .entry(decl.breakpoint_id.clone())
                .or_default()
                .push(decl);
        }

        let mut css_output = String::new();

        // 1. GÃ©rer le breakpoint par dÃ©faut (souvent "base" ou sans min-width)
        if let Some(decls) = by_breakpoint.get("base").or_else(|| by_breakpoint.get("")) {
             for decl in decls {
                let class_name = self.process_declaration(decl);
                self.style_source_to_classes
                    .entry(decl.style_source_id.clone())
                    .or_default()
                    .push(class_name);
             }
        }

        // 2. Assembler les rÃ¨gles de base
        for rule in self.rules.values() {
            css_output.push_str(rule);
            css_output.push('\n');
        }

        // 3. TODO: GÃ©rer les Media Queries pour les autres breakpoints
        // Cela nÃ©cessitera de trier les breakpoints par largeur

        css_output
    }

    fn process_declaration(&mut self, decl: &StyleDecl) -> String {
        let mut hasher = AHasher::default();
        decl.property.hash(&mut hasher);
        // On transforme la valeur JSON en string pour le hash
        decl.value.to_string().hash(&mut hasher);
        decl.breakpoint_id.hash(&mut hasher);
        decl.state.hash(&mut hasher);
        
        let hash_val = hasher.finish();
        let class_name = format!("lc-{:x}", hash_val);

        if !self.rules.contains_key(&class_name) {
            let value_str = self.format_value(&decl.value);
            let selector = if let Some(state) = &decl.state {
                format!(".{}:{}", class_name, state)
            } else {
                format!(".{}", class_name)
            };
            let rule = format!("{} {{ {}: {}; }}", selector, decl.property, value_str);
            self.rules.insert(class_name.clone(), rule);
        }

        class_name
    }

    fn format_value(&self, value: &serde_json::Value) -> String {
        match value {
            serde_json::Value::String(s) => s.clone(),
            serde_json::Value::Number(n) => n.to_string(),
            _ => value.to_string(),
        }
    }

    /// RÃ©cupÃ¨re la liste des classes pour un ID d'instance donnÃ©
    pub fn get_classes(&self, style_source_id: &str) -> String {
        self.style_source_to_classes
            .get(style_source_id)
            .map(|v| v.join(" "))
            .unwrap_or_default()
    }
}

