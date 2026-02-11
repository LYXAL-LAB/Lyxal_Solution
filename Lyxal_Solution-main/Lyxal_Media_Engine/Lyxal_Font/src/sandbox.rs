use std::path::{Path, PathBuf};
use path_clean::PathClean;
use thiserror::Error;

#[derive(Debug, Error)]
pub enum SandboxError {
    #[error("Path is outside of whitelist: {0}")]
    AccessDenied(String),
    #[error("Path must be absolute: {0}")]
    NotAbsolute(String),
    #[error("IO Error: {0}")]
    Io(#[from] std::io::Error),
}

#[derive(Debug, Clone)]
pub struct Sandbox {
    whitelist: Vec<PathBuf>,
}

impl Sandbox {
    pub fn new(mut whitelist: Vec<PathBuf>) -> Self {
        // Canonicalize whitelist roots if possible? 
        // Or store as is but insist they are absolute.
        // For determinism in CI, we deal with relative paths?
        // CTO says "Sandbox Strict". Best to work with Abs paths.
        Self { whitelist }
    }

    /// Validates and resolves a path against the whitelist.
    /// Returns the absolute path if valid, or Error.
    pub fn validate(&self, path: &Path) -> Result<PathBuf, SandboxError> {
        // 1. Clean path (resolve ..)
        let clean_path = if path.is_absolute() {
            path.to_path_buf().clean()
        } else {
             // If relative, we don't know relative to what?
             // Usually loading font "assets/fonts/arial.ttf".
             // We require caller to join it with a root first?
             // Or we accept relative and check if it's inside any whitelist root?
             // Let's enforce ABSOLUTE paths for validation to avoid ambiguity.
             return Err(SandboxError::NotAbsolute(path.display().to_string()));
        };

        // 2. Check if it starts with any whitelist prefix
        for root in &self.whitelist {
             // root must also be cleaned/absolute ideally
             if clean_path.starts_with(root) {
                 return Ok(clean_path);
             }
        }

        Err(SandboxError::AccessDenied(clean_path.display().to_string()))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;

    #[test]
    fn test_sandbox_allows_whitelisted() {
        let root = env::current_dir().unwrap();
        let sandbox = Sandbox::new(vec![root.clone()]);
        
        let valid_file = root.join("Cargo.toml");
        assert!(sandbox.validate(&valid_file).is_ok());
    }

    #[test]
    fn test_sandbox_denies_outside() {
        let root = env::current_dir().unwrap();
        let sandbox = Sandbox::new(vec![root.clone()]);
        
        // Parent of current dir
        let outside = root.parent().unwrap().to_path_buf();
        assert!(sandbox.validate(&outside).is_err());
    }
    
    #[test]
    fn test_sandbox_denies_traversal() {
         let root = env::current_dir().unwrap();
         let sandbox = Sandbox::new(vec![root.clone()]);
         
         // Path inside but traverses out
         // e.g. /app/../etc/passwd
         // path-clean should resolve this BEFORE checking starts_with
         let tricky = root.join("..").join("secret.txt");
         // This should resolve to parent/secret.txt which is outside root
         assert!(sandbox.validate(&tricky).is_err());
    }
}
