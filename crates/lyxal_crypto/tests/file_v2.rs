#![cfg(all(target_os = "linux", target_arch = "x86_64"))]
use lyxal_crypto::*;
use std::{
    fs,
    os::unix::fs::{symlink, PermissionsExt},
    sync::Arc,
};
fn id() -> KeyId {
    KeyId::parse("local").unwrap()
}
fn private_dir() -> tempfile::TempDir {
    let d = tempfile::tempdir().unwrap();
    fs::set_permissions(d.path(), fs::Permissions::from_mode(0o700)).unwrap();
    d
}
fn engine(key: ResolvedKey) -> CryptoEngine<StaticKeyResolver> {
    let mut b = KeyRingBuilder::new();
    b.insert_resolved(key, KeyUse::Active).unwrap();
    CryptoEngine::new(StaticKeyResolver::new(Arc::new(b.build().unwrap())))
}
#[test]
fn generated_key_is_private_persistent_and_shared_between_loads() {
    let d = private_dir();
    let p = d.path().join("master.key");
    let f = FileKeyProvider::new(&p, id(), KeyGenerationPolicy::AllowGenerateDevelopment);
    let a = engine(f.load().unwrap());
    let b = engine(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting)
            .load()
            .unwrap(),
    );
    assert_eq!(
        fs::metadata(&p).unwrap().permissions().mode() & 0o777,
        0o600
    );
    assert_eq!(fs::metadata(&p).unwrap().len(), 44);
    let ctx = SecretContext::global("provider.test").unwrap();
    let envelope = a
        .seal(&SecretBytes::new(b"synthetic".to_vec()).unwrap(), &ctx)
        .unwrap();
    assert_eq!(
        b.open(&envelope, &ctx).unwrap().expose_secret(),
        b"synthetic"
    );
    assert_eq!(fs::read_dir(d.path()).unwrap().count(), 1);
}
#[test]
fn strict_mode_symlinks_permissions_and_corruption_fail_closed() {
    let d = private_dir();
    let p = d.path().join("master.key");
    assert!(matches!(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting).load(),
        Err(CryptoError::KeyUnavailable)
    ));
    fs::write(&p, b"bad").unwrap();
    fs::set_permissions(&p, fs::Permissions::from_mode(0o600)).unwrap();
    assert!(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::AllowGenerateDevelopment)
            .load()
            .is_err()
    );
    assert_eq!(fs::read(&p).unwrap(), b"bad");
    fs::write(&p, b"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=").unwrap();
    fs::set_permissions(&p, fs::Permissions::from_mode(0o644)).unwrap();
    assert!(matches!(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting).load(),
        Err(CryptoError::InsecureKeyFile)
    ));
    fs::set_permissions(&p, fs::Permissions::from_mode(0o400)).unwrap();
    assert!(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting)
            .load()
            .is_ok()
    );
    let l = d.path().join("link.key");
    symlink(&p, &l).unwrap();
    assert!(matches!(
        FileKeyProvider::new(&l, id(), KeyGenerationPolicy::RequireExisting).load(),
        Err(CryptoError::InsecureKeyFile)
    ));
}
#[test]
fn key_file_formats_and_private_parent_are_strict() {
    let d = private_dir();
    let p = d.path().join("master.key");
    for value in [
        "",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\r\n",
        " AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
        "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\n\n",
    ] {
        fs::write(&p, value).unwrap();
        fs::set_permissions(&p, fs::Permissions::from_mode(0o600)).unwrap();
        assert!(
            FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting)
                .load()
                .is_err()
        );
    }
    fs::write(&p, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=\n").unwrap();
    assert!(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting)
            .load()
            .is_ok()
    );
    fs::set_permissions(d.path(), fs::Permissions::from_mode(0o755)).unwrap();
    assert!(
        FileKeyProvider::new(&p, id(), KeyGenerationPolicy::RequireExisting)
            .load()
            .is_err()
    );
}

#[test]
#[ignore = "invoked only as an isolated multiprocess worker"]
fn file_subprocess_worker() {
    let d = std::path::PathBuf::from(std::env::var_os("LYXAL_CRYPTO_TEST_DIR").unwrap());
    let index = std::env::var("LYXAL_CRYPTO_TEST_INDEX").unwrap();
    fs::write(d.join(format!("ready-{index}")), b"").unwrap();
    let deadline = std::time::Instant::now() + std::time::Duration::from_secs(15);
    while !d.join("start").exists() {
        assert!(std::time::Instant::now() < deadline);
        std::thread::sleep(std::time::Duration::from_millis(1));
    }
    let provider = FileKeyProvider::new(
        d.join("master.key"),
        id(),
        KeyGenerationPolicy::AllowGenerateDevelopment,
    );
    let engine = engine(provider.load().unwrap());
    let ctx = SecretContext::global("provider.test").unwrap();
    let result = engine
        .seal(&SecretBytes::new(b"synthetic".to_vec()).unwrap(), &ctx)
        .unwrap();
    fs::write(d.join(format!("out-{index}")), result.encode()).unwrap();
}

#[test]
fn multiprocess_publication_16_workers_100_rounds() {
    use std::{
        process::{Command, Stdio},
        time::{Duration, Instant},
    };
    let executable = std::env::current_exe().unwrap();
    for round in 0..100 {
        let d = private_dir();
        let mut children = Vec::new();
        for index in 0..16 {
            children.push(
                Command::new(&executable)
                    .args(["--ignored", "--exact", "file_subprocess_worker"])
                    .env("LYXAL_CRYPTO_TEST_DIR", d.path())
                    .env("LYXAL_CRYPTO_TEST_INDEX", index.to_string())
                    .stdout(Stdio::null())
                    .stderr(Stdio::piped())
                    .spawn()
                    .unwrap(),
            );
        }
        let deadline = Instant::now() + Duration::from_secs(15);
        while (0..16).any(|i| !d.path().join(format!("ready-{i}")).exists()) {
            assert!(Instant::now() < deadline, "barrier timeout");
            std::thread::sleep(Duration::from_millis(1));
        }
        fs::write(d.path().join("start"), b"").unwrap();
        for child in children {
            let output = child.wait_with_output().unwrap();
            assert!(
                output.status.success(),
                "round {round}: {}",
                String::from_utf8_lossy(&output.stderr)
            );
        }
        let engine = engine(
            FileKeyProvider::new(
                d.path().join("master.key"),
                id(),
                KeyGenerationPolicy::RequireExisting,
            )
            .load()
            .unwrap(),
        );
        let ctx = SecretContext::global("provider.test").unwrap();
        for i in 0..16 {
            let text = fs::read_to_string(d.path().join(format!("out-{i}"))).unwrap();
            let envelope = EncryptedEnvelope::parse(&text).unwrap();
            assert_eq!(
                engine.open(&envelope, &ctx).unwrap().expose_secret(),
                b"synthetic"
            );
        }
        assert!(!fs::read_dir(d.path()).unwrap().any(|e| e
            .unwrap()
            .file_name()
            .as_encoded_bytes()
            .starts_with(b".lyxal-key-")));
    }
}

#[test]
fn special_files_parent_links_and_permission_variants_are_rejected() {
    use std::os::unix::net::UnixListener;
    let dir = private_dir();
    let path = dir.path().join("master.key");
    for mode in [0o640, 0o604, 0o700, 0o4600, 0o200] {
        fs::write(&path, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=").unwrap();
        fs::set_permissions(&path, fs::Permissions::from_mode(mode)).unwrap();
        assert!(matches!(
            FileKeyProvider::new(&path, id(), KeyGenerationPolicy::RequireExisting).load(),
            Err(CryptoError::InsecureKeyFile)
        ));
        fs::remove_file(&path).unwrap();
    }
    fs::create_dir(&path).unwrap();
    assert!(
        FileKeyProvider::new(&path, id(), KeyGenerationPolicy::RequireExisting)
            .load()
            .is_err()
    );
    fs::remove_dir(&path).unwrap();
    let socket = UnixListener::bind(&path).unwrap();
    assert!(
        FileKeyProvider::new(&path, id(), KeyGenerationPolicy::RequireExisting)
            .load()
            .is_err()
    );
    drop(socket);
    fs::remove_file(&path).unwrap();
    assert!(std::process::Command::new("mkfifo")
        .arg(&path)
        .status()
        .unwrap()
        .success());
    assert!(matches!(
        FileKeyProvider::new(&path, id(), KeyGenerationPolicy::RequireExisting).load(),
        Err(CryptoError::InsecureKeyFile)
    ));
    fs::remove_file(&path).unwrap();
    let real = dir.path().join("real");
    fs::create_dir(&real).unwrap();
    fs::set_permissions(&real, fs::Permissions::from_mode(0o700)).unwrap();
    let link = dir.path().join("parent-link");
    symlink(&real, &link).unwrap();
    assert!(matches!(
        FileKeyProvider::new(
            link.join("key"),
            id(),
            KeyGenerationPolicy::AllowGenerateDevelopment
        )
        .load(),
        Err(CryptoError::InsecureKeyFile)
    ));
    assert!(FileKeyProvider::new(
        "relative.key",
        id(),
        KeyGenerationPolicy::AllowGenerateDevelopment
    )
    .load()
    .is_err());
}
