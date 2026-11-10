//! Rendu selon la langue : messages ICU MessageFormat 1, nombres, dates et montants.
//!
//! Données Unicode CLDR embarquées par ICU4X pour toutes les langues ; fuseaux horaires par
//! `jiff` (base du système, copie embarquée sinon). Aucune erreur n'est masquée : un message
//! invalide, un argument manquant ou un fuseau inconnu renvoie un `FormatError`.

mod experimental;
mod message;
#[cfg(test)]
mod tests;
mod value;

use icu::calendar::Iso;
use icu::datetime::{fieldsets, DateTimeFormatter};
use icu::decimal::DecimalFormatter;
use icu::locale::Locale;
use icu::plurals::{PluralCategory, PluralRules};
use icu::time::DateTime;
use jiff::tz::TimeZone;
use jiff::Timestamp;
use jiff_icu::ConvertFrom;

pub use fixed_decimal::Decimal;
pub use value::{parse_decimal, ArgValue, MessageArgs};

/// Version de CLDR des données embarquées par ICU4X 2.4 (crates `icu_*_data`). À mettre à jour
/// avec la version d'`icu` ; elle peut différer un temps de celle du référentiel des langues.
pub const ICU_CLDR_VERSION: &str = "49";

/// Erreur de rendu ; `code()` donne le code de la master data `I18N_*`.
#[derive(Debug, Clone, PartialEq, Eq, thiserror::Error)]
pub enum FormatError {
    /// Étiquette de langue illisible.
    #[error("langue non prise en charge : {locale}")]
    LocaleUnsupported {
        /// Étiquette reçue.
        locale: String,
    },
    /// Message illisible ou élément hors du sous-ensemble pris en charge.
    #[error("message invalide à la position {offset} : {reason}")]
    MessageInvalid {
        /// Raison.
        reason: String,
        /// Position dans le texte (caractères).
        offset: usize,
    },
    /// Argument du message absent des valeurs fournies.
    #[error("argument manquant : {name}")]
    ArgumentMissing {
        /// Nom de l'argument.
        name: String,
    },
    /// Valeur d'un type incompatible avec l'usage de l'argument.
    #[error("argument {name} : {expected} attendu")]
    ArgumentType {
        /// Nom de l'argument.
        name: String,
        /// Type attendu.
        expected: &'static str,
    },
    /// Fuseau horaire absent de la base IANA.
    #[error("fuseau horaire inconnu : {zone}")]
    TimezoneUnknown {
        /// Identifiant reçu.
        zone: String,
    },
    /// Code de monnaie qui n'a pas la forme ISO 4217.
    #[error("monnaie inconnue : {code}")]
    CurrencyUnknown {
        /// Code reçu.
        code: String,
    },
    /// Texte qui n'est pas un nombre décimal.
    #[error("nombre invalide : {value}")]
    NumberInvalid {
        /// Texte reçu.
        value: String,
    },
}

impl FormatError {
    /// Code stable de l'erreur (master data `error/rendu/`).
    pub fn code(&self) -> &'static str {
        match self {
            Self::LocaleUnsupported { .. } => "I18N_LOCALE_UNSUPPORTED",
            Self::MessageInvalid { .. } => "I18N_MESSAGE_INVALID",
            Self::ArgumentMissing { .. } => "I18N_ARGUMENT_MISSING",
            Self::ArgumentType { .. } => "I18N_ARGUMENT_TYPE",
            Self::TimezoneUnknown { .. } => "I18N_TIMEZONE_UNKNOWN",
            Self::CurrencyUnknown { .. } => "I18N_CURRENCY_UNKNOWN",
            Self::NumberInvalid { .. } => "I18N_NUMBER_INVALID",
        }
    }

    /// Tous les codes, pour le contrôle de la master data.
    pub const CODES: [&'static str; 7] = [
        "I18N_LOCALE_UNSUPPORTED",
        "I18N_MESSAGE_INVALID",
        "I18N_ARGUMENT_MISSING",
        "I18N_ARGUMENT_TYPE",
        "I18N_TIMEZONE_UNKNOWN",
        "I18N_CURRENCY_UNKNOWN",
        "I18N_NUMBER_INVALID",
    ];
}

/// Syntaxe d'un texte (champ `syntax` de `i18n_translation`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Syntax {
    /// ICU MessageFormat 1.
    IcuMf1,
    /// Texte rendu tel quel.
    Plain,
}

impl Syntax {
    /// Syntaxe depuis sa valeur en base (`icu_mf1`, `plain`).
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "icu_mf1" => Some(Self::IcuMf1),
            "plain" => Some(Self::Plain),
            _ => None,
        }
    }
}

/// Longueur d'un format de date ou d'heure.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Length {
    /// Court (`29/03/2026`, `03:30`).
    Short,
    /// Moyen (`29 mars 2026`, `03:30:00`).
    Medium,
    /// Long (`29 mars 2026`).
    Long,
}

impl Length {
    /// Longueur depuis son nom (`short`, `medium`, `long`).
    pub fn parse(value: &str) -> Option<Self> {
        match value {
            "short" => Some(Self::Short),
            "medium" => Some(Self::Medium),
            "long" => Some(Self::Long),
            _ => None,
        }
    }
}

/// Partie d'un instant à afficher.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DateStyle {
    /// Date seule.
    Date(Length),
    /// Heure seule (court : heures et minutes ; sinon avec les secondes).
    Time(Length),
    /// Date et heure (heures et minutes).
    DateTime(Length),
}

/// Rendu pour une langue. Coûteux à construire, à garder en cache (`Translator::formatter`).
pub struct Formatter {
    locale: Locale,
    cardinal: PluralRules,
    ordinal: PluralRules,
    decimal: DecimalFormatter,
}

impl std::fmt::Debug for Formatter {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.debug_struct("Formatter")
            .field("locale", &self.locale.to_string())
            .finish()
    }
}

impl Formatter {
    /// Rendu pour une étiquette BCP 47 ; une langue sans données propres suit son repli CLDR.
    pub fn new(locale: &str) -> Result<Self, FormatError> {
        let unsupported = || FormatError::LocaleUnsupported {
            locale: locale.to_string(),
        };
        let locale: Locale = locale
            .replace('_', "-")
            .parse()
            .map_err(|_| unsupported())?;
        Ok(Self {
            cardinal: PluralRules::try_new_cardinal((&locale).into()).map_err(|_| unsupported())?,
            ordinal: PluralRules::try_new_ordinal((&locale).into()).map_err(|_| unsupported())?,
            decimal: DecimalFormatter::try_new((&locale).into(), Default::default())
                .map_err(|_| unsupported())?,
            locale,
        })
    }

    /// Étiquette de la langue.
    pub fn locale(&self) -> String {
        self.locale.to_string()
    }

    /// Rend un texte : `plain` tel quel, `icu_mf1` avec ses arguments ; les dates sont affichées
    /// dans le fuseau `zone` (identifiant IANA).
    pub fn format_message(
        &self,
        text: &str,
        syntax: Syntax,
        args: &MessageArgs,
        zone: &str,
    ) -> Result<String, FormatError> {
        match syntax {
            Syntax::Plain => Ok(text.to_string()),
            Syntax::IcuMf1 => message::render(self, text, args, zone),
        }
    }

    /// Vérifie qu'un texte est lisible et n'utilise que les éléments pris en charge.
    pub fn check_message(&self, text: &str, syntax: Syntax) -> Result<(), FormatError> {
        match syntax {
            Syntax::Plain => Ok(()),
            Syntax::IcuMf1 => message::check(text),
        }
    }

    /// Nombre selon la langue (`12 345,67`).
    pub fn format_number(&self, value: &Decimal) -> String {
        self.decimal.format(value).to_string()
    }

    /// Pourcentage selon la langue : `0.25` donne `25 %`.
    pub fn format_percent(&self, value: &Decimal) -> Result<String, FormatError> {
        experimental::percent(&self.locale, value)
    }

    /// Montant selon la langue (`1 234,56 €`) ; `currency` est un code ISO 4217.
    pub fn format_currency(&self, amount: &Decimal, currency: &str) -> Result<String, FormatError> {
        experimental::currency(&self.locale, amount, currency)
    }

    /// Instant affiché dans un fuseau horaire (identifiant IANA, `UTC` compris).
    pub fn format_date(
        &self,
        instant: Timestamp,
        zone: &str,
        style: DateStyle,
    ) -> Result<String, FormatError> {
        let timezone = TimeZone::get(zone).map_err(|_| FormatError::TimezoneUnknown {
            zone: zone.to_string(),
        })?;
        let civil = DateTime::<Iso>::convert_from(instant.to_zoned(timezone).datetime());
        let unsupported = |_| FormatError::LocaleUnsupported {
            locale: self.locale.to_string(),
        };
        let prefs = (&self.locale).into();
        Ok(match style {
            DateStyle::Date(length) => {
                let fields = match length {
                    Length::Short => fieldsets::YMD::short(),
                    Length::Medium => fieldsets::YMD::medium(),
                    Length::Long => fieldsets::YMD::long(),
                };
                DateTimeFormatter::try_new(prefs, fields)
                    .map_err(unsupported)?
                    .format(&civil)
                    .to_string()
            }
            DateStyle::Time(length) => {
                let fields = match length {
                    Length::Short => fieldsets::T::hm(),
                    Length::Medium | Length::Long => fieldsets::T::hms(),
                };
                DateTimeFormatter::try_new(prefs, fields)
                    .map_err(unsupported)?
                    .format(&civil)
                    .to_string()
            }
            DateStyle::DateTime(length) => {
                let fields = match length {
                    Length::Short => fieldsets::YMD::short(),
                    Length::Medium => fieldsets::YMD::medium(),
                    Length::Long => fieldsets::YMD::long(),
                }
                .with_time_hm();
                DateTimeFormatter::try_new(prefs, fields)
                    .map_err(unsupported)?
                    .format(&civil)
                    .to_string()
            }
        })
    }

    /// Catégorie de pluriel d'un nombre (cardinal ou ordinal).
    pub(crate) fn plural_category(&self, value: &Decimal, ordinal: bool) -> PluralCategory {
        if ordinal {
            self.ordinal.category_for(value)
        } else {
            self.cardinal.category_for(value)
        }
    }
}
