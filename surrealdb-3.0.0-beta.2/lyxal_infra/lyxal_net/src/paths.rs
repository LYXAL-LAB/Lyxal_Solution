use std::path::{Path, PathBuf};
use std::fs;
use std::io;
use crate::error::{NetError, Result};

#[derive(Debug, Clone, Default)]
pub struct PathLayout {
    pub data_dir: PathBuf,
    pub config_dir: PathBuf,
    pub log_dir: PathBuf,
    
    // Derived
    pub identity_path: PathBuf,
    pub trust_store_path: PathBuf,
}

impl PathLayout {
    pub fn resolve(env_data_override: Option<String>) -> Result<Self> {
        let (data_dir, config_dir, log_dir) = if let Some(d) = env_data_override {
            let root = PathBuf::from(d);
            (root.join("data"), root.join("config"), root.join("logs"))
        } else {
            Self::os_defaults()?
        };

        // Create with failsafe
        Self::ensure_dir(&data_dir, 0o700)?;
        Self::ensure_dir(&config_dir, 0o700)?;
        Self::ensure_dir(&log_dir, 0o700)?;

        Ok(Self {
            identity_path: data_dir.join("node.key"),
            trust_store_path: config_dir.join("trusted_peers.toml"),
            data_dir,
            config_dir,
            log_dir,
        })
    }
    
    fn os_defaults() -> Result<(PathBuf, PathBuf, PathBuf)> {
        // Data: /var/lib/lyxal OR %APPDATA%/Lyxal/data OR ~/Library/Application Support/Lyxal
        let data_root = dirs::data_dir().ok_or_else(|| NetError::Generic("Could not resolve data dir".into()))?
            .join("Lyxal");
            
        // Config: /etc/lyxal OR %APPDATA%/Lyxal/config OR ~/Library/Preferences/Lyxal
        let config_root = dirs::config_dir().ok_or_else(|| NetError::Generic("Could not resolve config dir".into()))?
            .join("Lyxal");
            
        // Logs: /var/log/lyxal OR %LOCALAPPDATA%/Lyxal/logs OR ~/Library/Logs/Lyxal
        // On Windows, local_data_dir is often LocalAppData. 
        // dirs::state_dir() -> Linux: /run/user/ID ? No.
        // Let's stick to XDG / Standard:
        // Linux: data_dir=~/.local/share/Lyxal (user) or /var/lib/lyxal (system - handled by override if root)
        
        let log_root = if cfg!(target_os = "linux") {
            // User mode default
            dirs::data_dir().unwrap().join("Lyxal").join("logs")
        } else if cfg!(target_os = "windows") {
             dirs::data_local_dir().unwrap().join("Lyxal").join("logs")
        } else {
             // Mac
             dirs::home_dir().unwrap().join("Library").join("Logs").join("Lyxal")
        };
        
        Ok((data_root, config_root, log_root))
    }
    
    fn ensure_dir(path: &Path, mode: u32) -> Result<()> {
        if !path.exists() {
            fs::create_dir_all(path).map_err(|e| NetError::Io(e))?;
        }
        
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let meta = fs::metadata(path).map_err(|e| NetError::Io(e))?;
            let mut perms = meta.permissions();
            if (perms.mode() & 0o777) != mode {
                perms.set_mode(mode);
                fs::set_permissions(path, perms).map_err(|e| NetError::Io(e))?;
            }
        }
        
        Ok(())
    }
}
