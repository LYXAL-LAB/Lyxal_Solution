use super::country::Country;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Default, Serialize, Deserialize)]
pub struct PhoneNumber {
    pub digits: String,
    pub max_digits: usize,
}

impl PhoneNumber {
    pub fn new(digits: &str, max_digits: usize) -> Self {
        let digits = digits.chars().filter(|c| c.is_ascii_digit()).collect();
        Self { digits, max_digits }
    }

    pub fn is_empty(&self) -> bool {
        self.digits.is_empty()
    }

    pub fn set(&self, other: PhoneNumber) {
        // Since this is a struct (not a signal), set usually implies mutability or signal wrapper.
        // But in `input_phone.rs`, `value` is `RwSignal<PhoneNumber>`.
        // `value.set(phone)` replaces the whole struct.
        // So this method might not be needed on the struct itself unless it's for internal logic?
        // Wait, `value.set(phone)` uses RwSignal::set.
        // The error log didn't complain about `PhoneNumber::set`.
        // But `input_phone.rs` uses `value.set(phone)` where `value` is `RwSignal`.
        // So `PhoneNumber` doesn't need `set`.
    }

    pub fn format(&self, country: Country) -> String {
        // Basic formatting stub
        let dial_code = country.dial_code_formatted();
        format!("{} {}", dial_code, self.digits)
        // Improved logic would group digits
    }
}

pub struct PhoneFormat {
    pub max_digits: usize,
}

impl PhoneFormat {
    pub fn for_country(country: Country) -> Self {
        match country {
            _ => Self { max_digits: 15 },
        }
    }

    pub fn placeholder(&self) -> &'static str {
        "123 456 7890"
    }
}
