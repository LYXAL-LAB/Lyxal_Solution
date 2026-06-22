pub const MIN_DOMAIN_LENGTH: usize = 10;

pub const RESERVED_DOMAINS: &[&str] = &[
    "customer", "customers", "proxy-fallback", "local",
    "image-transform", "image-transforms", "images-transform", "images-transforms",
    "assets", "static-assets", "fonts", "images",
];

pub const RESERVED_PREFIXES: &[&str] = &["wstd_sys_", "wstd-sys-", "lyxal-sys-"];

