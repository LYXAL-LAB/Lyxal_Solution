//! Rendu d'un message ICU MessageFormat 1 depuis l'arbre du lecteur FormatJS.
//!
//! Sous-ensemble pris en charge : argument, `number` (défaut, `integer`, `percent`), `date` et
//! `time` (`short`, `medium`, `long`), `plural`, `selectordinal`, `select`. Les squelettes
//! (`::…`) et les balises sont refusés.

use fixed_decimal::Decimal;
use formatjs_icu_messageformat_parser::types::{
    DateTimeSkeletonOrStyle, MessageFormatElement, NumberSkeletonOrStyle, PluralElement,
    PluralType, ValidPluralRule,
};
use formatjs_icu_messageformat_parser::{Parser, ParserOptions};
use icu::plurals::PluralCategory;

use super::{ArgValue, DateStyle, FormatError, Formatter, Length, MessageArgs};

fn invalid(reason: impl Into<String>) -> FormatError {
    FormatError::MessageInvalid {
        reason: reason.into(),
        offset: 0,
    }
}

fn parse(text: &str) -> Result<Vec<MessageFormatElement>, FormatError> {
    let options = ParserOptions {
        ignore_tag: true,
        requires_other_clause: true,
        ..ParserOptions::default()
    };
    Parser::new(text, options)
        .parse()
        .map_err(|error| FormatError::MessageInvalid {
            reason: format!("{:?}", error.kind),
            offset: error.location.start.offset,
        })
}

/// Style d'un élément `number`.
enum NumberStyle {
    Default,
    Integer,
    Percent,
}

fn number_style(style: Option<&NumberSkeletonOrStyle>) -> Result<NumberStyle, FormatError> {
    match style {
        None => Ok(NumberStyle::Default),
        Some(NumberSkeletonOrStyle::String(name)) => match name.trim() {
            "" => Ok(NumberStyle::Default),
            "integer" => Ok(NumberStyle::Integer),
            "percent" => Ok(NumberStyle::Percent),
            other => Err(invalid(format!(
                "style de nombre non pris en charge : {other}"
            ))),
        },
        Some(NumberSkeletonOrStyle::Skeleton(_)) => {
            Err(invalid("squelette de nombre non pris en charge"))
        }
    }
}

fn length(style: Option<&DateTimeSkeletonOrStyle>) -> Result<Length, FormatError> {
    match style {
        None => Ok(Length::Medium),
        Some(DateTimeSkeletonOrStyle::String(name)) => Length::parse(name.trim())
            .ok_or_else(|| invalid(format!("style de date non pris en charge : {name}"))),
        Some(DateTimeSkeletonOrStyle::Skeleton(_)) => {
            Err(invalid("squelette de date non pris en charge"))
        }
    }
}

/// Vérifie la structure d'un message sans le rendre.
pub(super) fn check(text: &str) -> Result<(), FormatError> {
    check_elements(&parse(text)?)
}

fn check_elements(elements: &[MessageFormatElement]) -> Result<(), FormatError> {
    for element in elements {
        match element {
            MessageFormatElement::Literal(_)
            | MessageFormatElement::Argument(_)
            | MessageFormatElement::Pound(_) => {}
            MessageFormatElement::Number(number) => {
                number_style(number.style.as_ref())?;
            }
            MessageFormatElement::Date(date) | MessageFormatElement::Time(date) => {
                length(date.style.as_ref())?;
            }
            MessageFormatElement::Select(select) => {
                for option in select.options.values() {
                    check_elements(&option.value)?;
                }
            }
            MessageFormatElement::Plural(plural) => {
                for option in plural.options.values() {
                    check_elements(&option.value)?;
                }
            }
            MessageFormatElement::Tag(_) => return Err(invalid("balise non prise en charge")),
        }
    }
    Ok(())
}

/// Rend un message avec ses arguments.
pub(super) fn render(
    formatter: &Formatter,
    text: &str,
    args: &MessageArgs,
    zone: &str,
) -> Result<String, FormatError> {
    let elements = parse(text)?;
    let mut output = String::with_capacity(text.len());
    let context = Context {
        formatter,
        args,
        zone,
    };
    context.write(&elements, None, &mut output)?;
    Ok(output)
}

struct Context<'a> {
    formatter: &'a Formatter,
    args: &'a MessageArgs,
    zone: &'a str,
}

impl Context<'_> {
    fn value(&self, name: &str) -> Result<&ArgValue, FormatError> {
        self.args
            .get(name)
            .ok_or_else(|| FormatError::ArgumentMissing {
                name: name.to_string(),
            })
    }

    fn number(&self, name: &str) -> Result<&Decimal, FormatError> {
        match self.value(name)? {
            ArgValue::Number(number) => Ok(number),
            _ => Err(FormatError::ArgumentType {
                name: name.to_string(),
                expected: "number",
            }),
        }
    }

    fn date(&self, name: &str, style: DateStyle) -> Result<String, FormatError> {
        match self.value(name)? {
            ArgValue::DateTime(instant) => self.formatter.format_date(*instant, self.zone, style),
            _ => Err(FormatError::ArgumentType {
                name: name.to_string(),
                expected: "datetime",
            }),
        }
    }

    /// `pound` : nombre affiché par `#` dans la branche de pluriel en cours.
    fn write(
        &self,
        elements: &[MessageFormatElement],
        pound: Option<&Decimal>,
        output: &mut String,
    ) -> Result<(), FormatError> {
        for element in elements {
            match element {
                MessageFormatElement::Literal(literal) => output.push_str(&literal.value),
                MessageFormatElement::Argument(argument) => match self.value(&argument.value)? {
                    ArgValue::Text(text) => output.push_str(text),
                    ArgValue::Number(number) => {
                        output.push_str(&self.formatter.format_number(number));
                    }
                    ArgValue::DateTime(instant) => output.push_str(&self.formatter.format_date(
                        *instant,
                        self.zone,
                        DateStyle::DateTime(Length::Medium),
                    )?),
                },
                MessageFormatElement::Number(number) => {
                    let value = self.number(&number.value)?;
                    match number_style(number.style.as_ref())? {
                        NumberStyle::Default => {
                            output.push_str(&self.formatter.format_number(value));
                        }
                        NumberStyle::Integer => {
                            let mut rounded = value.clone();
                            rounded.round(0);
                            output.push_str(&self.formatter.format_number(&rounded));
                        }
                        NumberStyle::Percent => {
                            output.push_str(&self.formatter.format_percent(value)?);
                        }
                    }
                }
                MessageFormatElement::Date(date) => {
                    let style = DateStyle::Date(length(date.style.as_ref())?);
                    output.push_str(&self.date(&date.value, style)?);
                }
                MessageFormatElement::Time(time) => {
                    let style = DateStyle::Time(length(time.style.as_ref())?);
                    output.push_str(&self.date(&time.value, style)?);
                }
                MessageFormatElement::Select(select) => {
                    let ArgValue::Text(choice) = self.value(&select.value)? else {
                        return Err(FormatError::ArgumentType {
                            name: select.value.clone(),
                            expected: "string",
                        });
                    };
                    let branch = select
                        .options
                        .get(choice.as_str())
                        .or_else(|| select.options.get("other"))
                        .ok_or_else(|| invalid("branche other absente"))?;
                    self.write(&branch.value, pound, output)?;
                }
                MessageFormatElement::Plural(plural) => self.plural(plural, output)?,
                MessageFormatElement::Pound(_) => match pound {
                    Some(number) => output.push_str(&self.formatter.format_number(number)),
                    None => output.push('#'),
                },
                MessageFormatElement::Tag(_) => return Err(invalid("balise non prise en charge")),
            }
        }
        Ok(())
    }

    fn plural(&self, plural: &PluralElement, output: &mut String) -> Result<(), FormatError> {
        let value = self.number(&plural.value)?;
        // Valeur exacte (« =0 ») avant les catégories de la langue
        let exact = ValidPluralRule::Exact(format!("={value}"));
        let shown = if plural.offset == 0 {
            value.clone()
        } else {
            // Le décalage ne s'applique qu'à un nombre entier
            let whole: i64 = value
                .to_string()
                .parse()
                .map_err(|_| FormatError::ArgumentType {
                    name: plural.value.clone(),
                    expected: "integer",
                })?;
            Decimal::from(whole - i64::from(plural.offset))
        };
        let branch = match plural.options.get(&exact) {
            Some(branch) => branch,
            None => {
                let ordinal = plural.plural_type == PluralType::Ordinal;
                let category = match self.formatter.plural_category(&shown, ordinal) {
                    PluralCategory::Zero => ValidPluralRule::Zero,
                    PluralCategory::One => ValidPluralRule::One,
                    PluralCategory::Two => ValidPluralRule::Two,
                    PluralCategory::Few => ValidPluralRule::Few,
                    PluralCategory::Many => ValidPluralRule::Many,
                    PluralCategory::Other => ValidPluralRule::Other,
                };
                plural
                    .options
                    .get(&category)
                    .or_else(|| plural.options.get(&ValidPluralRule::Other))
                    .ok_or_else(|| invalid("branche other absente"))?
            }
        };
        self.write(&branch.value, Some(&shown), output)
    }
}
