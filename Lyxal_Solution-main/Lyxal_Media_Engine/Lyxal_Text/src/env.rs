use cosmic_text::{FontSystem};
use lyxal_font::{FontRegistry, FontWeight, FontStyle};
use std::sync::{Arc, Mutex};

/// Controlled Text Environment. 
/// Replaces the default cosmic-text global/system loader.
pub struct TextEnvironment {
    pub font_system: Arc<Mutex<FontSystem>>,
}

impl TextEnvironment {
    /// Create a new environment from a strict FontRegistry.
    /// No system fonts are loaded.
    pub fn new(registry: &FontRegistry) -> Result<Self, Box<dyn std::error::Error>> {
        let mut db = cosmic_text::fontdb::Database::new();
        
        // Load all fonts from registry into DB
        for family in registry.families() {
            for font_entry in &family.fonts {
                match registry.load_font_bytes(font_entry) {
                    Ok(bytes) => {
                        let source = cosmic_text::fontdb::Source::Binary(Arc::new(bytes));
                        db.load_font_source(source);
                        // Note: cosmic-text auto-detects properties from bytes.
                        // We might want to enforce properties from registry?
                        // cosmic-text doesn't easily allow overriding parsed properties 
                        // when using load_font_source.
                        // Ideally we trust the file matches the metadata.
                    }
                    Err(e) => {
                        // In strict mode, we should error?
                        eprintln!("Failed to load font {:?}: {}", font_entry.path, e);
                        // return Err(Box::new(e)); 
                    }
                }
            }
        }
        
        // Setup Swap (Standard locale en-US default)
        // We explicitly avoid system fonts.
        let locale = "en-US";
        let font_system = FontSystem::new_with_locale_and_db(locale.to_string(), db);
        
        Ok(Self {
            font_system: Arc::new(Mutex::new(font_system)),
        })
    }
}
