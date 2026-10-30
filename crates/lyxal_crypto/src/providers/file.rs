//! Linux trusted-directory profile. std checks do NOT resist hostile ancestor mutation.
use crate::{CryptoError, KeyId, ResolvedKey};
use std::path::{Path, PathBuf};
/// Generation is an explicit development-only choice, never a repair for corruption.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum KeyGenerationPolicy {
    /// Missing, invalid or insecure files always fail.
    RequireExisting,
    /// Generate only for an absent final name in an existing trusted directory.
    AllowGenerateDevelopment,
}
/// Explicit key file loading. No cached refresh, destructive repair or historic-key deletion.
///
/// Host MUST qualify the filesystem and provide trusted, private, immutable ancestors.
/// This provider does not defeat an attacker controlling the process, its UID or parents.
/// Atomic namespace publication is distinct from durable storage and successful cleanup.
pub struct FileKeyProvider {
    path: PathBuf,
    id: KeyId,
    policy: KeyGenerationPolicy,
}
impl FileKeyProvider {
    /// Configure an absolute path; validation happens on each explicit load.
    pub fn new(path: impl AsRef<Path>, id: KeyId, policy: KeyGenerationPolicy) -> Self {
        Self {
            path: path.as_ref().to_owned(),
            id,
            policy,
        }
    }
    /// Load/sync the final key, or generate in development if and only if it is absent.
    /// No filesystem support/physical durability claim follows merely from a successful test.
    pub fn load(&self) -> Result<ResolvedKey, CryptoError> {
        #[cfg(all(target_os = "linux", target_arch = "x86_64"))]
        {
            linux::load(self, &mut linux::NoHooks)
        }
        #[cfg(not(all(target_os = "linux", target_arch = "x86_64")))]
        {
            Err(CryptoError::UnsupportedStorage)
        }
    }
}
#[cfg(all(target_os = "linux", target_arch = "x86_64"))]
mod linux {
    use super::*;
    use crate::{EncryptionKey, IoOperation};
    use base64::{engine::general_purpose::STANDARD, Engine};
    use rand_core::{OsRng, RngCore};
    use std::{
        fs::{self, File, Metadata, OpenOptions},
        io::{ErrorKind, Read, Write},
        os::unix::{
            ffi::OsStrExt,
            fs::{MetadataExt, OpenOptionsExt},
        },
        sync::Arc,
    };
    use zeroize::Zeroizing;
    pub(super) trait Hooks {
        fn point(&mut self, phase: IoOperation) -> Result<(), CryptoError>;
        fn random_name(&mut self, out: &mut [u8; 16]) -> Result<(), CryptoError> {
            OsRng
                .try_fill_bytes(out)
                .map_err(|_| CryptoError::RandomUnavailable)
        }
    }
    pub(super) struct NoHooks;
    impl Hooks for NoHooks {
        fn point(&mut self, _: IoOperation) -> Result<(), CryptoError> {
            Ok(())
        }
    }
    fn io(phase: IoOperation, err: std::io::Error) -> CryptoError {
        CryptoError::Io(phase, err.kind())
    }
    fn metadata(path: &Path) -> Result<Metadata, CryptoError> {
        fs::symlink_metadata(path).map_err(|e| io(IoOperation::Metadata, e))
    }
    fn same(a: &Metadata, b: &Metadata) -> bool {
        a.dev() == b.dev()
            && a.ino() == b.ino()
            && a.mode() == b.mode()
            && a.uid() == b.uid()
            && a.gid() == b.gid()
            && a.len() == b.len()
            && a.mtime() == b.mtime()
            && a.mtime_nsec() == b.mtime_nsec()
    }
    fn validate_parent(provider: &FileKeyProvider) -> Result<(PathBuf, Metadata), CryptoError> {
        let bytes = provider.path.as_os_str().as_bytes();
        if !bytes.starts_with(b"/")
            || bytes.ends_with(b"/")
            || bytes.windows(2).any(|w| w == b"//")
            || bytes.split(|b| *b == b'/').any(|s| s == b"." || s == b"..")
        {
            return Err(CryptoError::InsecureKeyFile);
        }
        let parent = provider
            .path
            .parent()
            .ok_or(CryptoError::InsecureKeyFile)?
            .to_owned();
        let mut walked = PathBuf::new();
        for part in parent.components() {
            walked.push(part);
            let meta = metadata(&walked)?;
            if meta.file_type().is_symlink() || !meta.is_dir() {
                return Err(CryptoError::InsecureKeyFile);
            }
        }
        let meta = metadata(&parent)?;
        if !matches!(meta.mode() & 0o7777, 0o700 | 0o500) {
            return Err(CryptoError::InsecureKeyFile);
        }
        Ok((parent, meta))
    }
    fn validate_file(meta: &Metadata, parent: &Metadata) -> Result<(), CryptoError> {
        if !meta.is_file()
            || meta.file_type().is_symlink()
            || !matches!(meta.mode() & 0o7777, 0o600 | 0o400)
            || meta.uid() != parent.uid()
        {
            return Err(CryptoError::InsecureKeyFile);
        }
        Ok(())
    }
    fn sync_directory(parent: &Path) -> Result<(), std::io::Error> {
        File::open(parent)?.sync_all()
    }
    fn sync_final(file: &File, parent: &Path) -> Result<(), CryptoError> {
        file.sync_all()
            .map_err(|e| CryptoError::DurabilityUncertain(IoOperation::SyncFile, e.kind()))?;
        sync_directory(parent)
            .map_err(|e| CryptoError::DurabilityUncertain(IoOperation::SyncDirectory, e.kind()))
    }
    fn read_final(
        provider: &FileKeyProvider,
        parent: &Path,
        parent_meta: &Metadata,
    ) -> Result<ResolvedKey, CryptoError> {
        let before = match fs::symlink_metadata(&provider.path) {
            Ok(m) => m,
            Err(e) if e.kind() == ErrorKind::NotFound => return Err(CryptoError::KeyUnavailable),
            Err(e) => return Err(io(IoOperation::Metadata, e)),
        };
        validate_file(&before, parent_meta)?;
        if !matches!(before.len(), 44 | 45) {
            return Err(CryptoError::InvalidKeyEncoding);
        }
        let mut file = File::open(&provider.path).map_err(|e| io(IoOperation::Open, e))?;
        let opened = file.metadata().map_err(|e| io(IoOperation::Metadata, e))?;
        if !same(&before, &opened) {
            return Err(CryptoError::InsecureKeyFile);
        }
        validate_file(&opened, parent_meta)?;
        let mut raw = Zeroizing::new([0u8; 46]);
        let mut n = 0;
        while n < raw.len() {
            match file.read(&mut raw[n..]) {
                Ok(0) => break,
                Ok(count) => n += count,
                Err(e) if e.kind() == ErrorKind::Interrupted => continue,
                Err(e) => return Err(io(IoOperation::Read, e)),
            }
        }
        if !(n == 44 || (n == 45 && raw[44] == b'\n')) {
            return Err(CryptoError::InvalidKeyEncoding);
        }
        let after_handle = file.metadata().map_err(|e| io(IoOperation::Metadata, e))?;
        let after_path = metadata(&provider.path)?;
        if !same(&opened, &after_handle) || !same(&opened, &after_path) {
            return Err(CryptoError::InsecureKeyFile);
        }
        let parent_after = metadata(parent)?;
        if parent_after.dev() != parent_meta.dev()
            || parent_after.ino() != parent_meta.ino()
            || parent_after.mode() != parent_meta.mode()
            || parent_after.uid() != parent_meta.uid()
        {
            return Err(CryptoError::InsecureKeyFile);
        }
        let key = super::super::decode_key(&raw[..44])?;
        sync_final(&file, parent)?;
        Ok(ResolvedKey::new(provider.id.clone(), Arc::new(key)))
    }
    fn cleanup(
        path: &Path,
        created: &Metadata,
        parent: &Path,
        published: bool,
    ) -> Result<(), CryptoError> {
        let result = (|| {
            let now = fs::symlink_metadata(path)?;
            if now.dev() != created.dev() || now.ino() != created.ino() || !now.is_file() {
                return Err(std::io::Error::from(ErrorKind::PermissionDenied));
            }
            fs::remove_file(path)?;
            sync_directory(parent)
        })();
        result.map_err(|e| {
            if published {
                CryptoError::CleanupFailed(IoOperation::Cleanup, e.kind())
            } else {
                io(IoOperation::Cleanup, e)
            }
        })
    }
    pub(super) fn load(
        provider: &FileKeyProvider,
        hooks: &mut impl Hooks,
    ) -> Result<ResolvedKey, CryptoError> {
        let (parent, parent_meta) = validate_parent(provider)?;
        match read_final(provider, &parent, &parent_meta) {
            Ok(key) => return Ok(key),
            Err(CryptoError::KeyUnavailable) => {}
            Err(e) => return Err(e),
        }
        if provider.policy == KeyGenerationPolicy::RequireExisting {
            return Err(CryptoError::KeyUnavailable);
        }
        if parent_meta.mode() & 0o7777 != 0o700 {
            return Err(CryptoError::InsecureKeyFile);
        }
        let key = EncryptionKey::generate()?;
        let mut encoded = Zeroizing::new([0u8; 44]);
        STANDARD
            .encode_slice(key.expose(), &mut encoded[..])
            .map_err(|_| CryptoError::InvalidKeyEncoding)?;
        let mut temporary = None;
        for _ in 0..8 {
            let mut random = [0u8; 16];
            hooks.random_name(&mut random)?;
            let path = parent.join(format!(".lyxal-key-{}", hex::encode(random)));
            match OpenOptions::new()
                .write(true)
                .create_new(true)
                .mode(0o600)
                .open(&path)
            {
                Ok(file) => {
                    temporary = Some((path, file));
                    break;
                }
                Err(e) if e.kind() == ErrorKind::AlreadyExists => continue,
                Err(e) => return Err(io(IoOperation::Create, e)),
            }
        }
        let (temp, mut file) = temporary.ok_or(CryptoError::Io(
            IoOperation::Create,
            ErrorKind::AlreadyExists,
        ))?;
        let identity = file.metadata().map_err(|e| io(IoOperation::Metadata, e))?;
        let mut published = false;
        let outcome = (|| {
            hooks.point(IoOperation::Create)?;
            validate_file(&identity, &parent_meta)?;
            // A test-only hook after a partial write exercises the unpublished-file invariant.
            file.write_all(&encoded[..22])
                .map_err(|e| io(IoOperation::Write, e))?;
            hooks.point(IoOperation::Write)?;
            file.write_all(&encoded[22..])
                .map_err(|e| io(IoOperation::Write, e))?;
            file.sync_all().map_err(|e| io(IoOperation::SyncFile, e))?;
            hooks.point(IoOperation::SyncFile)?;
            match fs::hard_link(&temp, &provider.path) {
                Ok(()) => {
                    published = true;
                }
                Err(e) if e.kind() == ErrorKind::AlreadyExists => {
                    return read_final(provider, &parent, &parent_meta)
                }
                Err(e) => return Err(io(IoOperation::Publish, e)),
            }
            hooks.point(IoOperation::Publish).map_err(|_| {
                CryptoError::DurabilityUncertain(IoOperation::Publish, ErrorKind::Other)
            })?;
            sync_directory(&parent).map_err(|e| {
                CryptoError::DurabilityUncertain(IoOperation::SyncDirectory, e.kind())
            })?;
            hooks.point(IoOperation::SyncDirectory).map_err(|_| {
                CryptoError::DurabilityUncertain(IoOperation::SyncDirectory, ErrorKind::Other)
            })?;
            // Re-open/recheck the published inode; never return a merely generated unpublished key.
            read_final(provider, &parent, &parent_meta)
        })();
        let clean = cleanup(&temp, &identity, &parent, published);
        match outcome {
            Err(e) => Err(e),
            Ok(key) => {
                clean?;
                hooks.point(IoOperation::Cleanup).map_err(|_| {
                    CryptoError::CleanupFailed(IoOperation::Cleanup, ErrorKind::Other)
                })?;
                Ok(key)
            }
        }
    }
}

#[cfg(all(test, target_os = "linux", target_arch = "x86_64"))]
mod tests {
    use super::*;
    use crate::IoOperation;
    use std::{
        fs,
        io::ErrorKind,
        os::unix::fs::PermissionsExt,
        process::{Command, Stdio},
        time::{Duration, Instant},
    };
    fn directory() -> tempfile::TempDir {
        let dir = tempfile::tempdir().unwrap();
        fs::set_permissions(dir.path(), fs::Permissions::from_mode(0o700)).unwrap();
        dir
    }
    fn provider(path: &Path) -> FileKeyProvider {
        FileKeyProvider::new(
            path,
            KeyId::parse("test").unwrap(),
            KeyGenerationPolicy::AllowGenerateDevelopment,
        )
    }
    struct Failure(IoOperation);
    impl linux::Hooks for Failure {
        fn point(&mut self, phase: IoOperation) -> Result<(), CryptoError> {
            if phase == self.0 {
                Err(CryptoError::Io(phase, ErrorKind::StorageFull))
            } else {
                Ok(())
            }
        }
    }
    #[test]
    fn failures_before_and_after_publication_are_distinct() {
        for phase in [
            IoOperation::Create,
            IoOperation::Write,
            IoOperation::SyncFile,
            IoOperation::Publish,
            IoOperation::SyncDirectory,
            IoOperation::Cleanup,
        ] {
            let dir = directory();
            let path = dir.path().join("master.key");
            let configured = provider(&path);
            let error = linux::load(&configured, &mut Failure(phase)).unwrap_err();
            match phase {
                IoOperation::Create | IoOperation::Write | IoOperation::SyncFile => {
                    assert!(matches!(error, CryptoError::Io(_, _)));
                    assert!(!path.exists());
                }
                IoOperation::Publish | IoOperation::SyncDirectory => {
                    assert!(matches!(error, CryptoError::DurabilityUncertain(_, _)));
                    assert!(configured.load().is_ok());
                }
                IoOperation::Cleanup => {
                    assert!(matches!(error, CryptoError::CleanupFailed(_, _)));
                    assert!(configured.load().is_ok());
                }
                _ => unreachable!(),
            }
            assert!(!fs::read_dir(dir.path()).unwrap().any(|e| e
                .unwrap()
                .file_name()
                .as_encoded_bytes()
                .starts_with(b".lyxal-key-")));
        }
    }
    struct NameFailure;
    impl linux::Hooks for NameFailure {
        fn point(&mut self, _: IoOperation) -> Result<(), CryptoError> {
            Ok(())
        }
        fn random_name(&mut self, out: &mut [u8; 16]) -> Result<(), CryptoError> {
            out.fill(0x41);
            Err(CryptoError::RandomUnavailable)
        }
    }
    struct Collision {
        calls: usize,
    }
    impl linux::Hooks for Collision {
        fn point(&mut self, _: IoOperation) -> Result<(), CryptoError> {
            Ok(())
        }
        fn random_name(&mut self, out: &mut [u8; 16]) -> Result<(), CryptoError> {
            self.calls += 1;
            out.fill(0);
            Ok(())
        }
    }
    #[test]
    fn temporary_name_failures_are_bounded_and_preserve_foreign_files() {
        let dir = directory();
        let path = dir.path().join("master.key");
        assert!(matches!(
            linux::load(&provider(&path), &mut NameFailure),
            Err(CryptoError::RandomUnavailable)
        ));
        assert!(!path.exists());
        let foreign = dir
            .path()
            .join(".lyxal-key-00000000000000000000000000000000");
        fs::write(&foreign, b"foreign fixture").unwrap();
        let mut collision = Collision { calls: 0 };
        assert!(matches!(
            linux::load(&provider(&path), &mut collision),
            Err(CryptoError::Io(
                IoOperation::Create,
                ErrorKind::AlreadyExists
            ))
        ));
        assert_eq!(collision.calls, 8);
        assert_eq!(fs::read(&foreign).unwrap(), b"foreign fixture");
        assert!(provider(&path).load().is_ok());
        assert_eq!(fs::read(&foreign).unwrap(), b"foreign fixture");
    }
    struct Crash {
        phase: IoOperation,
        dir: PathBuf,
    }
    impl linux::Hooks for Crash {
        fn point(&mut self, phase: IoOperation) -> Result<(), CryptoError> {
            if phase == self.phase {
                fs::write(self.dir.join("ready"), b"").unwrap();
                loop {
                    std::thread::park();
                }
            }
            Ok(())
        }
    }
    #[test]
    #[ignore = "private process-interruption helper"]
    fn crash_child() {
        let dir = PathBuf::from(std::env::var_os("LYXAL_PRIVATE_CRASH_DIR").unwrap());
        let phase = match std::env::var("LYXAL_PRIVATE_CRASH_PHASE").unwrap().as_str() {
            "Create" => IoOperation::Create,
            "Write" => IoOperation::Write,
            "SyncFile" => IoOperation::SyncFile,
            "Publish" => IoOperation::Publish,
            "SyncDirectory" => IoOperation::SyncDirectory,
            "Cleanup" => IoOperation::Cleanup,
            _ => panic!("invalid test phase"),
        };
        let _ = linux::load(
            &provider(&dir.join("master.key")),
            &mut Crash { phase, dir },
        );
        panic!("test hook was not reached");
    }
    #[test]
    fn interrupted_process_never_leaves_an_accepted_partial_final() {
        for phase in [
            IoOperation::Create,
            IoOperation::Write,
            IoOperation::SyncFile,
            IoOperation::Publish,
            IoOperation::SyncDirectory,
            IoOperation::Cleanup,
        ] {
            let dir = directory();
            let mut child = Command::new(std::env::current_exe().unwrap())
                .args([
                    "--ignored",
                    "--exact",
                    "providers::file::tests::crash_child",
                ])
                .env("LYXAL_PRIVATE_CRASH_DIR", dir.path())
                .env("LYXAL_PRIVATE_CRASH_PHASE", format!("{phase:?}"))
                .stdout(Stdio::null())
                .stderr(Stdio::null())
                .spawn()
                .unwrap();
            let deadline = Instant::now() + Duration::from_secs(10);
            while !dir.path().join("ready").exists() {
                if Instant::now() > deadline {
                    let _ = child.kill();
                    panic!("private crash hook timeout");
                }
                std::thread::sleep(Duration::from_millis(1));
            }
            child.kill().unwrap();
            child.wait().unwrap();
            let path = dir.path().join("master.key");
            let strict = FileKeyProvider::new(
                &path,
                KeyId::parse("test").unwrap(),
                KeyGenerationPolicy::RequireExisting,
            );
            if matches!(
                phase,
                IoOperation::Create | IoOperation::Write | IoOperation::SyncFile
            ) {
                assert!(matches!(strict.load(), Err(CryptoError::KeyUnavailable)));
            } else {
                assert_eq!(fs::metadata(&path).unwrap().len(), 44);
                assert!(strict.load().is_ok());
            }
        }
    }
}
