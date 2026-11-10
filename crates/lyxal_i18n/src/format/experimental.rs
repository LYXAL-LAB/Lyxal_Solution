//! Montants et pourcentages : seules utilisations de `icu_experimental`, dont l'API n'est pas
//! stable. Toute montée de version de cette crate se limite à ce fichier.

use fixed_decimal::Decimal;
use icu::locale::Locale;
use icu_experimental::dimension::currency::formatter::CurrencyFormatter;
use icu_experimental::dimension::currency::CurrencyType;
use icu_experimental::dimension::percent::formatter::PercentFormatter;

use super::FormatError;

pub(super) fn currency(
    locale: &Locale,
    amount: &Decimal,
    code: &str,
) -> Result<String, FormatError> {
    let unknown = || FormatError::CurrencyUnknown {
        code: code.to_string(),
    };
    if code.len() != 3 || !code.bytes().all(|b| b.is_ascii_uppercase()) {
        return Err(unknown());
    }
    let currency = CurrencyType::try_from_str(code).map_err(|_| unknown())?;
    let formatter = CurrencyFormatter::try_new_symbol(locale.into(), currency, Default::default())
        .map_err(|_| FormatError::LocaleUnsupported {
            locale: locale.to_string(),
        })?;
    let formatted = formatter.format_fixed_decimal(amount).to_string();
    Ok(formatted)
}

pub(super) fn percent(locale: &Locale, value: &Decimal) -> Result<String, FormatError> {
    let formatter = PercentFormatter::try_new(locale.into(), Default::default()).map_err(|_| {
        FormatError::LocaleUnsupported {
            locale: locale.to_string(),
        }
    })?;
    let mut scaled = value.clone();
    scaled.multiply_pow10(2);
    scaled.trim_start();
    let formatted = formatter.format(&scaled).to_string();
    Ok(formatted)
}
