//! Tests du rendu : pluriels CLDR, messages, dates, nombres, montants.

use super::*;

const NNBSP: &str = "\u{202f}";
const NBSP: &str = "\u{a0}";

fn fmt(locale: &str) -> Formatter {
    Formatter::new(locale).expect("langue")
}

fn render(locale: &str, text: &str, args: &MessageArgs) -> Result<String, FormatError> {
    fmt(locale).format_message(text, Syntax::IcuMf1, args, "UTC")
}

fn count(n: i64) -> MessageArgs {
    MessageArgs::new().integer("n", n)
}

#[test]
fn cardinal_plurals_follow_cldr() {
    let text = "{n, plural, zero {zero} one {one} two {two} few {few} many {many} other {other}}";
    let cases: &[(&str, &[(i64, &str)])] = &[
        (
            "fr",
            &[(0, "one"), (1, "one"), (2, "other"), (1_000_000, "many")],
        ),
        ("en", &[(0, "other"), (1, "one"), (2, "other")]),
        (
            "ar",
            &[
                (0, "zero"),
                (1, "one"),
                (2, "two"),
                (3, "few"),
                (11, "many"),
                (100, "other"),
            ],
        ),
        (
            "pl",
            &[
                (1, "one"),
                (2, "few"),
                (5, "many"),
                (22, "few"),
                (25, "many"),
            ],
        ),
        (
            "ru",
            &[
                (1, "one"),
                (2, "few"),
                (5, "many"),
                (21, "one"),
                (11, "many"),
            ],
        ),
        ("ja", &[(0, "other"), (1, "other"), (2, "other")]),
    ];
    for (locale, expected) in cases {
        for (n, category) in *expected {
            assert_eq!(
                render(locale, text, &count(*n)).as_deref(),
                Ok(*category),
                "{locale} {n}"
            );
        }
    }
}

#[test]
fn decimal_plural_uses_its_fraction_digits() {
    let text = "{n, plural, one {one} other {other}}";
    let args = MessageArgs::new().decimal("n", "1.5").expect("nombre");
    assert_eq!(render("fr", text, &args).as_deref(), Ok("one"));
    assert_eq!(render("en", text, &args).as_deref(), Ok("other"));
    let args = MessageArgs::new().decimal("n", "1.0").expect("nombre");
    assert_eq!(render("en", text, &args).as_deref(), Ok("other"));
}

#[test]
fn ordinal_plurals_follow_cldr() {
    let english = "{n, selectordinal, one {#st} two {#nd} few {#rd} other {#th}}";
    for (n, expected) in [
        (1, "1st"),
        (2, "2nd"),
        (3, "3rd"),
        (4, "4th"),
        (11, "11th"),
        (21, "21st"),
    ] {
        assert_eq!(render("en", english, &count(n)).as_deref(), Ok(expected));
    }
    let french = "{n, selectordinal, one {#er} other {#e}}";
    assert_eq!(render("fr", french, &count(1)).as_deref(), Ok("1er"));
    assert_eq!(render("fr", french, &count(2)).as_deref(), Ok("2e"));
}

#[test]
fn exact_values_offset_and_pound() {
    let text = "{n, plural, =0 {aucun article} one {# article} other {# articles}}";
    assert_eq!(
        render("fr", text, &count(0)).as_deref(),
        Ok("aucun article")
    );
    assert_eq!(render("fr", text, &count(1)).as_deref(), Ok("1 article"));
    assert_eq!(
        render("fr", text, &count(12_345)),
        Ok(format!("12{NNBSP}345 articles"))
    );
    let offset = "{n, plural, offset:1 =0 {personne} =1 {{who}} one {{who} et # autre} other {{who} et # autres}}";
    let args = |n| MessageArgs::new().integer("n", n).text("who", "Ada");
    assert_eq!(render("fr", offset, &args(0)).as_deref(), Ok("personne"));
    assert_eq!(render("fr", offset, &args(1)).as_deref(), Ok("Ada"));
    assert_eq!(
        render("fr", offset, &args(2)).as_deref(),
        Ok("Ada et 1 autre")
    );
    assert_eq!(
        render("fr", offset, &args(4)).as_deref(),
        Ok("Ada et 3 autres")
    );
    // Une valeur exacte se compare en nombre : « 0.0 » et « 2.00 » trouvent « =0 » et « =2 »
    let exact = "{n, plural, =0 {aucun} =2 {une paire} other {# articles}}";
    let decimal = |value: &str| MessageArgs::new().decimal("n", value).expect("nombre");
    assert_eq!(render("fr", exact, &decimal("0.0")).as_deref(), Ok("aucun"));
    assert_eq!(
        render("fr", exact, &decimal("2.00")).as_deref(),
        Ok("une paire")
    );
    assert_eq!(
        render("fr", exact, &decimal("2.5")).as_deref(),
        Ok("2,5 articles")
    );
    assert_eq!(
        render("fr", exact, &decimal("20")).as_deref(),
        Ok("20 articles")
    );
    // Hors d'un pluriel, « # » est un caractère
    assert_eq!(
        render("fr", "n° #", &MessageArgs::new()).as_deref(),
        Ok("n° #")
    );
}

#[test]
fn select_nesting_and_apostrophes() {
    let text = "{g, select, female {Elle a {n, plural, one {# message} other {# messages}}} other {Il a {n, plural, one {# message} other {# messages}}}}";
    let args = |g: &str, n| MessageArgs::new().text("g", g).integer("n", n);
    assert_eq!(
        render("fr", text, &args("female", 1)).as_deref(),
        Ok("Elle a 1 message")
    );
    assert_eq!(
        render("fr", text, &args("inconnu", 3)).as_deref(),
        Ok("Il a 3 messages")
    );
    let quoted = "L''article '{exemple}' de {name} n'est pas l'été";
    assert_eq!(
        render("fr", quoted, &MessageArgs::new().text("name", "Ada")).as_deref(),
        Ok("L'article {exemple} de Ada n'est pas l'été")
    );
}

#[test]
fn arguments_are_formatted_by_type() {
    let instant = "2026-03-29T01:30:00Z".parse().expect("instant");
    let args = MessageArgs::new()
        .text("who", "Ada")
        .decimal("n", "1234.5")
        .expect("nombre")
        .datetime("d", instant);
    assert_eq!(
        render("fr", "{who} : {n} le {d}", &args),
        Ok(format!("Ada : 1{NNBSP}234,5 le 29 mars 2026, 01:30"))
    );
    assert_eq!(
        render("fr", "{n, number} / {n, number, integer}", &args),
        Ok(format!("1{NNBSP}234,5 / 1{NNBSP}234"))
    );
    let ratio = MessageArgs::new().decimal("r", "0.256").expect("nombre");
    assert_eq!(
        render("fr", "{r, number, percent}", &ratio),
        Ok(format!("25,6{NBSP}%"))
    );
    assert_eq!(
        render("en", "{r, number, percent}", &ratio).as_deref(),
        Ok("25.6%")
    );
}

#[test]
fn missing_or_mistyped_arguments_are_errors() {
    assert_eq!(
        render("fr", "Bonjour {name}", &MessageArgs::new()),
        Err(FormatError::ArgumentMissing {
            name: "name".to_string()
        })
    );
    let text_args = MessageArgs::new().text("n", "trois");
    assert_eq!(
        render("fr", "{n, plural, one {a} other {b}}", &text_args),
        Err(FormatError::ArgumentType {
            name: "n".to_string(),
            expected: "number"
        })
    );
    assert_eq!(
        render("fr", "{n, date}", &text_args),
        Err(FormatError::ArgumentType {
            name: "n".to_string(),
            expected: "datetime"
        })
    );
    assert_eq!(
        render("fr", "{n, select, a {x} other {y}}", &count(1)),
        Err(FormatError::ArgumentType {
            name: "n".to_string(),
            expected: "string"
        })
    );
    let half = MessageArgs::new().decimal("n", "1.5").expect("nombre");
    assert_eq!(
        render("fr", "{n, plural, offset:1 one {a} other {b}}", &half),
        Err(FormatError::ArgumentType {
            name: "n".to_string(),
            expected: "integer"
        })
    );
}

#[test]
fn invalid_messages_are_refused_with_their_position() {
    let formatter = fmt("fr");
    for (text, offset) in [("Bonjour {name", 13), ("{n, plural, one {x}}", 19)] {
        match formatter.check_message(text, Syntax::IcuMf1) {
            Err(FormatError::MessageInvalid { offset: found, .. }) => {
                assert_eq!(found, offset, "{text}");
            }
            other => panic!("{text} : {other:?}"),
        }
        assert_eq!(
            formatter
                .format_message(text, Syntax::IcuMf1, &count(1), "UTC")
                .map_err(|e| e.code()),
            Err("I18N_MESSAGE_INVALID")
        );
    }
    // Éléments hors du sous-ensemble pris en charge
    for text in [
        "{n, number, ::currency/EUR}",
        "{n, number, currency}",
        "{d, date, ::yMMMd}",
        "{d, date, full}",
        "{n, spellout}",
    ] {
        assert_eq!(
            formatter
                .check_message(text, Syntax::IcuMf1)
                .map_err(|e| e.code()),
            Err("I18N_MESSAGE_INVALID"),
            "{text}"
        );
    }
    // Un texte brut n'est pas lu comme un message ; les balises restent du texte
    assert_eq!(
        formatter.check_message("f(x) = {x | x > 0", Syntax::Plain),
        Ok(())
    );
    assert_eq!(
        formatter
            .format_message("{pas lu}", Syntax::Plain, &MessageArgs::new(), "UTC")
            .as_deref(),
        Ok("{pas lu}")
    );
    assert_eq!(
        render("fr", "<b>gras</b>", &MessageArgs::new()).as_deref(),
        Ok("<b>gras</b>")
    );
}

/// Mêmes verdicts que `fn::i18n_message_check` (banc `tests/controles.test.surql`).
#[test]
fn verdicts_match_the_database_check() {
    let formatter = fmt("fr");
    let accepted = [
        "{n, plural, one {# jour} other {# jours}} pour {who}",
        "Bonjour {name}, {count, plural, offset:1 =0 {rien} one {# article} other {# articles de {shop}}} le {day, date, short}.",
        "L''article '{exemple}' coûte {price, number} et c'est tout",
        "{n, selectordinal, one {#st} two {#nd} few {#rd} other {#th}} {m, plural, one {x} other {y}}",
    ];
    for text in accepted {
        assert_eq!(
            formatter.check_message(text, Syntax::IcuMf1),
            Ok(()),
            "{text}"
        );
    }
    let refused = [
        "a {b",
        "{n, plural, one {x} other {y}",
        "{x, spellout}",
        "{n, plural, one {x}} {o, selectordinal, one {x}} {s, select, a {x}}",
    ];
    for text in refused {
        assert!(
            formatter.check_message(text, Syntax::IcuMf1).is_err(),
            "{text}"
        );
    }
    // Seul écart : la base refuse une accolade fermante isolée, qu'ICU rend comme du texte
    assert_eq!(
        render("fr", "a } b", &MessageArgs::new()).as_deref(),
        Ok("a } b")
    );
}

#[test]
fn dates_follow_the_zone_and_its_clock_changes() {
    let fr = fmt("fr");
    let medium = DateStyle::DateTime(Length::Medium);
    // Passage à l'heure d'été à Paris le 29 mars 2026 : 02:00 devient 03:00
    let before: Timestamp = "2026-03-29T00:30:00Z".parse().expect("instant");
    let after: Timestamp = "2026-03-29T01:30:00Z".parse().expect("instant");
    assert_eq!(
        fr.format_date(before, "Europe/Paris", medium).as_deref(),
        Ok("29 mars 2026, 01:30")
    );
    assert_eq!(
        fr.format_date(after, "Europe/Paris", medium).as_deref(),
        Ok("29 mars 2026, 03:30")
    );
    // Retour à l'heure d'hiver le 25 octobre 2026 : 03:00 redevient 02:00
    let winter: Timestamp = "2026-10-25T01:30:00Z".parse().expect("instant");
    assert_eq!(
        fr.format_date(winter, "Europe/Paris", medium).as_deref(),
        Ok("25 oct. 2026, 02:30")
    );
    // Décalage d'une demi-heure, changement de jour
    let evening: Timestamp = "2026-06-30T20:00:00Z".parse().expect("instant");
    assert_eq!(
        fr.format_date(evening, "Asia/Kolkata", DateStyle::DateTime(Length::Long))
            .as_deref(),
        Ok("1 juillet 2026 à 01:30")
    );
    assert_eq!(
        fr.format_date(evening, "UTC", DateStyle::Date(Length::Short))
            .as_deref(),
        Ok("30/06/2026")
    );
    assert_eq!(
        fr.format_date(evening, "UTC", DateStyle::Time(Length::Short))
            .as_deref(),
        Ok("20:00")
    );
    assert_eq!(
        fr.format_date(evening, "UTC", DateStyle::Time(Length::Medium))
            .as_deref(),
        Ok("20:00:00")
    );
    assert_eq!(
        fmt("en-US").format_date(evening, "America/New_York", medium),
        Ok(format!("Jun 30, 2026, 4:00{NNBSP}PM"))
    );
    assert_eq!(
        fmt("de")
            .format_date(evening, "Europe/Berlin", DateStyle::Date(Length::Long))
            .as_deref(),
        Ok("30. Juni 2026")
    );
    assert_eq!(
        fr.format_date(evening, "Mars/Olympus", medium),
        Err(FormatError::TimezoneUnknown {
            zone: "Mars/Olympus".to_string()
        })
    );
}

#[test]
fn numbers_and_amounts_follow_the_locale() {
    let amount = parse_decimal("1234567.89").expect("nombre");
    assert_eq!(
        fmt("fr").format_number(&amount),
        format!("1{NNBSP}234{NNBSP}567,89")
    );
    assert_eq!(fmt("en").format_number(&amount), "1,234,567.89");
    assert_eq!(fmt("de").format_number(&amount), "1.234.567,89");
    let price = parse_decimal("1234.50").expect("nombre");
    assert_eq!(
        fmt("fr").format_currency(&price, "EUR"),
        Ok(format!("1{NNBSP}234,50{NBSP}€"))
    );
    assert_eq!(
        fmt("en-US").format_currency(&price, "EUR").as_deref(),
        Ok("€1,234.50")
    );
    assert_eq!(
        fmt("en-US").format_currency(&price, "USD").as_deref(),
        Ok("$1,234.50")
    );
    assert_eq!(
        fmt("de").format_currency(&price, "CHF"),
        Ok(format!("1.234,50{NBSP}CHF"))
    );
    // Monnaie sans décimale : le montant est affiché tel qu'il est fourni
    let yen = parse_decimal("1234").expect("nombre");
    assert_eq!(
        fmt("ja").format_currency(&yen, "JPY").as_deref(),
        Ok("￥1,234")
    );
    for code in ["eur", "EURO", "€", ""] {
        assert_eq!(
            fmt("fr").format_currency(&price, code),
            Err(FormatError::CurrencyUnknown {
                code: code.to_string()
            })
        );
    }
}

#[test]
fn decimals_are_parsed_exactly() {
    assert_eq!(
        parse_decimal(" -0.10 ").expect("nombre").to_string(),
        "-0.10"
    );
    for text in ["", "abc", "1,5", "NaN"] {
        assert_eq!(
            parse_decimal(text),
            Err(FormatError::NumberInvalid {
                value: text.to_string()
            }),
            "{text}"
        );
    }
}

#[test]
fn locales_and_syntaxes_are_parsed() {
    assert_eq!(fmt("fr_CA").locale(), "fr-CA");
    assert_eq!(fmt("zh-Hant-TW").locale(), "zh-Hant-TW");
    assert_eq!(
        Formatter::new("pas une langue").map(|f| f.locale()),
        Err(FormatError::LocaleUnsupported {
            locale: "pas une langue".to_string()
        })
    );
    assert_eq!(Syntax::parse("icu_mf1"), Some(Syntax::IcuMf1));
    assert_eq!(Syntax::parse("plain"), Some(Syntax::Plain));
    assert_eq!(Syntax::parse("mf2"), None);
    assert_eq!(Length::parse("full"), None);
}

#[test]
fn every_error_code_is_defined_in_the_master_data() {
    let master = std::fs::read_to_string(concat!(
        env!("CARGO_MANIFEST_DIR"),
        "/error/rendu/error_rendu.surql"
    ))
    .expect("master data");
    for code in FormatError::CODES {
        assert!(
            master.contains(&format!("error_definition:{code})")),
            "{code}"
        );
    }
}
