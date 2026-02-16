pub fn to_bytes(value: &str) -> u64 {
    (value.parse::<f64>().unwrap_or(4.5) * 1_000_000.0) as u64
}

