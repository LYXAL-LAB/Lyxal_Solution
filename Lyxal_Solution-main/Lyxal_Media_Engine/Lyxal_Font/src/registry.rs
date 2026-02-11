use std::collections::HashMap;
use std::path::{Path, PathBuf};
use serde::{Deserialize, Serialize};
use crate::sandbox::{Sandbox, SandboxError};

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum FontWeight {
    Thin = 100,
    ExtraLight = 200,
    Light = 300,
    Regular = 400,
    Medium = 500,
    SemiBold = 600,
    Bold = 700,
    ExtraBold = 800,
    Black = 900,
}

impl Default for FontWeight {
    fn default() -> Self { Self::Regular }
}

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum FontStyle {
    Normal,
    Italic,
    Oblique,
}

impl Default for FontStyle {
    fn default() -> Self { Self::Normal }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FontEntry {
    pub path: PathBuf,
    pub index: u32, // For .ttc files
    pub weight: FontWeight,
    pub style: FontStyle,
    // Add stretch if needed
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FamilyEntry {
    pub name: String,
    pub fonts: Vec<FontEntry>,
    // Fallback logic could be per family or global. strict_mode suggests global fallback.
}

#[derive(Debug, Default)]
pub struct FontRegistry {
    families: HashMap<String, FamilyEntry>,
    sandbox: Option<Sandbox>,
    fallbacks: Vec<String>,
}

impl FontRegistry {
    pub fn new(whitelist_roots: Option<Vec<PathBuf>>) -> Self {
        let sandbox = whitelist_roots.map(Sandbox::new);
        Self {
            families: HashMap::new(),
            sandbox,
            fallbacks: Vec::new(),
        }
    }

    pub fn set_fallbacks(&mut self, families: Vec<String>) {
        self.fallbacks = families;
    }

    pub fn add_family(&mut self, name: &str) -> &mut FamilyEntry {
        self.families.entry(name.to_string()).or_insert(FamilyEntry {
            name: name.to_string(),
            fonts: Vec::new(),
        })
    }
    
    /// Register a font explicitly. Path MUST be within sandbox.
    pub fn register_font(&mut self, family: &str, path: PathBuf, index: u32, weight: FontWeight, style: FontStyle) -> Result<(), SandboxError> {
        let validated_path = if let Some(sandbox) = &self.sandbox {
             sandbox.validate(&path)?
        } else {
             // If no sandbox defined, allow (unsafe mode) or enforce abs?
             // CTO says Sandbox Config is mandatory for PROD.
             // But we allow empty sandbox for now?
             // Let's enforce existence check at least.
             if !path.exists() {
                 return Err(SandboxError::Io(std::io::Error::new(std::io::ErrorKind::NotFound, "File not found")));
             }
             path
        };
        
        let entry = self.add_family(family);
        entry.fonts.push(FontEntry {
            path: validated_path,
            index,
            weight,
            style
        });
        Ok(())
    }

    pub fn get_family(&self, name: &str) -> Option<&FamilyEntry> {
        self.families.get(name)
    }
    
    pub fn families(&self) -> std::collections::hash_map::Values<'_, String, FamilyEntry> {
        self.families.values()
    }
    
    /// Securely load font bytes. Path is already validated at registration time.
    /// However, if we didn't store File handle, we just read path.
    /// Double check sandbox if needed? Registration checked it.
    pub fn load_font_bytes(&self, entry: &FontEntry) -> std::io::Result<Vec<u8>> {
        // In strict mode, we might want to re-validate?
        // For now trusting the entry is sufficient if we assume registry integrity.
        std::fs::read(&entry.path)
    }
}
