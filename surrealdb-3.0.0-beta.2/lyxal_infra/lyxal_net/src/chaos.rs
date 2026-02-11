/// Chaos Engineering module for Lyxal OS.
/// Allows injecting controlled failures (aborts, panics) during tests.

#[macro_export]
macro_rules! failpoint {
    ($name:expr) => {
        if let Ok(val) = std::env::var("LYXAL_FAILPOINT") {
            if val == $name {
                log::error!("!!! CHAOS INJECTION: Failpoint '{}' triggered !!!", $name);
                std::process::abort();
            }
        }
    };
}

#[macro_export]
macro_rules! error_point {
    ($name:expr, $err:expr) => {
        if let Ok(val) = std::env::var("LYXAL_ERRORPOINT") {
            if val == $name {
                log::error!("!!! CHAOS INJECTION: Errorpoint '{}' triggered !!!", $name);
                return Err($err.into());
            }
        }
    };
}
