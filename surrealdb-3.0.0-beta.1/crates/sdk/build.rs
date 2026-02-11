fn main() {
	if cfg!(target_family = "wasm") {
		println!("cargo:rustc-cfg=wasm");
		println!("cargo::rustc-check-cfg=cfg(wasm)");
	}
	if cfg!(any(
		feature = "kv-mem",
		feature = "kv-indxdb",
		feature = "kv-lyxalkv",
	)) {
		println!("cargo:rustc-cfg=storage");
		println!("cargo::rustc-check-cfg=cfg(storage)");
	}
}
