//! Rendu des messages : gabarits MiniJinja en bac à sable.
//!
//! * aucun chargeur : `include`, `import` et `extends` échouent ;
//! * variable affichée inconnue = erreur (`SemiStrict` ; un test `{% if %}` sur une variable
//!   absente reste permis) ;
//! * échappement HTML automatique pour le corps et la mise en page HTML ;
//! * budget d'exécution (`fuel`) et profondeur de récursion bornés ;
//! * objet ramené à une seule ligne (aucun caractère de contrôle : pas d'injection d'en-tête).
//!
//! Variables : `recipient` (`email`, `locale`, `name`), `payload`, `secret`, `organization`
//! (`name`). Le message rendu n'est conservé nulle part.
//!
//! Un gabarit existe en une seule version. Ses phrases sont des clés `lyxal_i18n` appelées par
//! `t("clé", nom=valeur, …)` : le texte, lu à la réservation dans la langue de l'envoi, est
//! rendu par `lyxal_i18n` dans la **langue du texte retenu** (un texte servi en repli garde ses
//! propres pluriels), puis échappé dans le HTML comme toute variable. Une clé que le gabarit
//! n'a pas déclarée, une clé inconnue de `lyxal_i18n`, un argument absent ou un message
//! invalide font échouer le rendu.
//!
//! Filtres de `lyxal_i18n` : `format_number`, `format_currency(code)`,
//! `format_date(style, zone)`, dans la langue de l'envoi (avec la région du destinataire quand
//! sa langue est celle de l'envoi : `en-GB` pour un envoi en `en`). Une valeur invalide fait
//! échouer le rendu : rien n'est envoyé avec une valeur fausse.

use lyxal_i18n::{
    parse_decimal, DateStyle, FormatError, Formatter, Length, MessageArgs, ResolvedText, Syntax,
};
use minijinja::value::{Kwargs, Value, ValueKind};
use minijinja::{AutoEscape, Environment, Error, ErrorKind, UndefinedBehavior};
use std::collections::HashMap;
use std::sync::Arc;

use crate::error::{NotificationError, NotificationResult};
use crate::models::ClaimedJob;

/// Budget d'exécution par gabarit (instructions MiniJinja).
pub const DEFAULT_FUEL: u64 = 50_000;
/// Taille maximale d'un message rendu (octets, corps HTML).
pub const MAX_RENDERED_BYTES: usize = 512 * 1024;

/// Message rendu.
pub struct RenderedEmail {
    /// Objet, sur une ligne.
    pub subject: String,
    /// Corps HTML (mise en page comprise).
    pub html: String,
    /// Corps texte (mise en page comprise).
    pub text: String,
}

impl std::fmt::Debug for RenderedEmail {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str("RenderedEmail([REDACTED])")
    }
}

/// Moteur de rendu (sans état partagé entre messages).
pub struct Renderer {
    fuel: u64,
}

impl Default for Renderer {
    fn default() -> Self {
        Self { fuel: DEFAULT_FUEL }
    }
}

impl Renderer {
    /// Moteur avec un budget d'exécution par gabarit.
    pub fn with_fuel(fuel: u64) -> Self {
        Self { fuel }
    }

    /// Rend l'objet, le corps HTML et le corps texte d'une étape réservée.
    pub fn render(
        &self,
        job: &ClaimedJob,
        secret: Option<&serde_json::Map<String, serde_json::Value>>,
    ) -> NotificationResult<RenderedEmail> {
        let (Some(subject), Some(html_body), Some(text_body)) =
            (&job.subject, &job.html_body, &job.text_body)
        else {
            return Err(NotificationError::Render("étape sans gabarit".to_string()));
        };
        if let Some(code) = &job.texts_error {
            return Err(NotificationError::Render(format!(
                "textes du gabarit illisibles : {code}"
            )));
        }
        let Some(send_locale) = job.locale.as_deref() else {
            return Err(NotificationError::Render(
                "langue de l'envoi absente".to_string(),
            ));
        };
        let unreadable = |error: FormatError| NotificationError::Render(error.to_string());
        let formatter = Formatter::new(format_locale(job.recipient.locale.as_deref(), send_locale))
            .map_err(unreadable)?;
        let texts = Texts::new(&job.texts).map_err(unreadable)?;
        let env = self.environment(Arc::new(formatter), Arc::new(texts));
        let context = Value::from_pairs([
            (
                "recipient",
                Value::from_pairs([
                    ("email", Value::from(job.recipient.email.clone())),
                    ("locale", optional(&job.recipient.locale)),
                    ("name", optional(&job.recipient.name)),
                ]),
            ),
            ("payload", json_value(&job.payload)),
            (
                "secret",
                secret.map_or_else(
                    || Value::from_pairs(Vec::<(String, Value)>::new()),
                    |map| json_value(&serde_json::Value::Object(map.clone())),
                ),
            ),
            (
                "organization",
                Value::from_pairs([("name", optional(&job.organization_name))]),
            ),
        ]);
        let subject = render(&env, "subject.txt", subject, context.clone())?;
        let html = render(&env, "body.html", html_body, context.clone())?;
        let text = render(&env, "body.txt", text_body, context.clone())?;
        let html = match &job.layout_html {
            Some(layout) => render(
                &env,
                "layout.html",
                layout,
                with_content(&context, Value::from_safe_string(html)),
            )?,
            None => html,
        };
        let text = match &job.layout_text {
            Some(layout) => render(
                &env,
                "layout.txt",
                layout,
                with_content(&context, Value::from(text)),
            )?,
            None => text,
        };
        if html.len() > MAX_RENDERED_BYTES || text.len() > MAX_RENDERED_BYTES {
            return Err(NotificationError::Render(
                "message rendu trop volumineux".to_string(),
            ));
        }
        Ok(RenderedEmail {
            subject: single_line(&subject),
            html,
            text,
        })
    }

    fn environment(&self, formatter: Arc<Formatter>, texts: Arc<Texts>) -> Environment<'static> {
        let mut env = Environment::new();
        env.set_undefined_behavior(UndefinedBehavior::SemiStrict);
        env.set_fuel(Some(self.fuel));
        env.set_recursion_limit(32);
        env.set_auto_escape_callback(|name| {
            if name.ends_with(".html") {
                AutoEscape::Html
            } else {
                AutoEscape::None
            }
        });
        env.add_function("t", move |key: String, args: Kwargs| {
            texts.render(&key, &args)
        });
        let numbers = Arc::clone(&formatter);
        env.add_filter("format_number", move |value: Value| {
            Ok::<_, Error>(numbers.format_number(&decimal(&value)?))
        });
        let amounts = Arc::clone(&formatter);
        env.add_filter("format_currency", move |value: Value, currency: String| {
            amounts
                .format_currency(&decimal(&value)?, &currency)
                .map_err(filter_error)
        });
        env.add_filter(
            "format_date",
            move |value: Value, style: Option<String>, zone: Option<String>| {
                let instant = value
                    .as_str()
                    .and_then(|text| text.parse().ok())
                    .ok_or_else(|| invalid("date RFC 3339 attendue"))?;
                let style = date_style(style.as_deref().unwrap_or("medium"))?;
                formatter
                    .format_date(instant, zone.as_deref().unwrap_or("UTC"), style)
                    .map_err(filter_error)
            },
        );
        env
    }
}

/// Langue des nombres et des dates : celle du destinataire quand sa langue est celle de
/// l'envoi (sa région est gardée), sinon celle de l'envoi.
fn format_locale<'a>(recipient: Option<&'a str>, send: &'a str) -> &'a str {
    let language = |tag: &str| tag.split('-').next().map(str::to_ascii_lowercase);
    match recipient {
        Some(tag) if language(tag) == language(send) => tag,
        _ => send,
    }
}

/// Textes des clés du gabarit, chacun avec le rendu de sa propre langue.
struct Texts {
    by_key: HashMap<String, (ResolvedText, Syntax)>,
    formatters: HashMap<String, Formatter>,
}

impl Texts {
    fn new(texts: &[ResolvedText]) -> Result<Self, FormatError> {
        let mut by_key = HashMap::with_capacity(texts.len());
        let mut formatters = HashMap::new();
        for text in texts {
            let syntax =
                Syntax::parse(&text.syntax).ok_or_else(|| FormatError::MessageInvalid {
                    reason: format!("syntaxe inconnue : {}", text.syntax),
                    offset: 0,
                })?;
            if let Some(locale) = &text.locale {
                if !formatters.contains_key(locale) {
                    formatters.insert(locale.clone(), Formatter::new(locale)?);
                }
            }
            by_key.insert(text.key.clone(), (text.clone(), syntax));
        }
        Ok(Self { by_key, formatters })
    }

    /// Texte d'une clé, rendu avec ses arguments dans la langue du texte retenu.
    fn render(&self, key: &str, args: &Kwargs) -> Result<String, Error> {
        let (text, syntax) = self
            .by_key
            .get(key)
            .ok_or_else(|| invalid("clé absente des clés déclarées par le gabarit"))?;
        let formatter = text
            .locale
            .as_ref()
            .and_then(|locale| self.formatters.get(locale))
            .filter(|_| !text.missing)
            .ok_or_else(|| invalid("clé non déclarée dans lyxal_i18n"))?;
        let mut values = MessageArgs::new();
        for name in args.args() {
            let value: Value = args.get(name)?;
            values = match value.kind() {
                ValueKind::String => values.text(name, value.as_str().unwrap_or_default()),
                ValueKind::Number => match i64::try_from(value.clone()) {
                    Ok(integer) => values.integer(name, integer),
                    Err(_) => values
                        .decimal(name, &value.to_string())
                        .map_err(filter_error)?,
                },
                _ => return Err(invalid("argument de texte : chaîne ou nombre attendu")),
            };
        }
        args.assert_all_used()?;
        formatter
            .format_message(&text.text, *syntax, &values, "UTC")
            .map_err(filter_error)
    }
}

fn invalid(detail: &'static str) -> Error {
    Error::new(ErrorKind::InvalidOperation, detail)
}

/// Erreur de rendu de `lyxal_i18n` : son code seulement, jamais la valeur.
fn filter_error(error: FormatError) -> Error {
    Error::new(ErrorKind::InvalidOperation, error.code())
}

/// Nombre exact d'une valeur de gabarit : entier, écriture décimale en texte, ou nombre à
/// virgule de la charge utile JSON (repris par son écriture la plus courte).
fn decimal(value: &Value) -> Result<lyxal_i18n::Decimal, Error> {
    let text = match value.kind() {
        ValueKind::Number => value.to_string(),
        ValueKind::String => value.as_str().unwrap_or_default().to_string(),
        _ => return Err(invalid("nombre attendu")),
    };
    parse_decimal(&text).map_err(filter_error)
}

/// Style d'une date : `short`, `medium`, `long` (date seule), `datetime_short`,
/// `datetime_medium`, `datetime_long`, `time`.
fn date_style(name: &str) -> Result<DateStyle, Error> {
    let unknown = || invalid("style de date inconnu");
    Ok(match name {
        "time" => DateStyle::Time(Length::Short),
        _ => match name.strip_prefix("datetime_") {
            Some(length) => DateStyle::DateTime(Length::parse(length).ok_or_else(unknown)?),
            None => DateStyle::Date(Length::parse(name).ok_or_else(unknown)?),
        },
    })
}

fn render(
    env: &Environment<'_>,
    name: &str,
    source: &str,
    context: Value,
) -> NotificationResult<String> {
    env.render_named_str(name, source, context)
        // L'erreur MiniJinja décrit le gabarit (nom, ligne, variable), jamais les valeurs
        .map_err(|error| NotificationError::Render(format!("{name} : {}", error.kind())))
}

fn with_content(context: &Value, content: Value) -> Value {
    let mut pairs: Vec<(String, Value)> = ["recipient", "payload", "secret", "organization"]
        .iter()
        .filter_map(|key| context.get_attr(key).ok().map(|v| ((*key).to_string(), v)))
        .collect();
    pairs.push(("content".to_string(), content));
    Value::from_pairs(pairs)
}

fn optional(value: &Option<String>) -> Value {
    value.clone().map_or(Value::from(()), Value::from)
}

/// Conversion JSON → valeur MiniJinja.
fn json_value(value: &serde_json::Value) -> Value {
    match value {
        serde_json::Value::Null => Value::from(()),
        serde_json::Value::Bool(b) => Value::from(*b),
        serde_json::Value::Number(n) => n
            .as_i64()
            .map(Value::from)
            .or_else(|| n.as_f64().map(Value::from))
            .unwrap_or_else(|| Value::from(n.to_string())),
        serde_json::Value::String(s) => Value::from(s.clone()),
        serde_json::Value::Array(items) => items.iter().map(json_value).collect(),
        serde_json::Value::Object(map) => Value::from_pairs(
            map.iter()
                .map(|(k, v)| (k.clone(), json_value(v)))
                .collect::<Vec<_>>(),
        ),
    }
}

/// Objet sur une ligne : caractères de contrôle remplacés par une espace.
fn single_line(subject: &str) -> String {
    subject
        .chars()
        .map(|c| if c.is_control() { ' ' } else { c })
        .collect::<String>()
        .trim()
        .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::models::Recipient;

    fn job(subject: &str, html: &str, text: &str) -> ClaimedJob {
        let id = lyxal_surreal::RecordId::new("notification_job", "j");
        ClaimedJob {
            job_id: id.clone(),
            claim_token: "t".into(),
            run_id: id,
            tenant: None,
            tenant_key: None,
            organization_name: Some("Alpha & Fils".into()),
            idempotency_key: "k".into(),
            attempt: 1,
            recipient: Recipient {
                email: "claire@exemple.fr".into(),
                locale: Some("fr".into()),
                name: Some("Claire".into()),
            },
            locale: Some("fr".into()),
            subject: Some(subject.into()),
            html_body: Some(html.into()),
            text_body: Some(text.into()),
            texts: Vec::new(),
            texts_error: None,
            layout_html: None,
            layout_text: None,
            payload: serde_json::json!({ "n": "<b>D-1</b>" }),
            secret: None,
            sensitive: false,
            from_name: None,
            reply_to: None,
        }
    }

    #[test]
    fn html_is_escaped_text_is_not() {
        let rendered = Renderer::default()
            .render(
                &job(
                    "Devis {{ payload.n }}",
                    "<p>{{ payload.n }} {{ organization.name }}</p>",
                    "{{ payload.n }}",
                ),
                None,
            )
            .expect("rendu");
        assert_eq!(
            rendered.html,
            "<p>&lt;b&gt;D-1&lt;&#x2f;b&gt; Alpha &amp; Fils</p>"
        );
        assert_eq!(rendered.text, "<b>D-1</b>");
        assert_eq!(rendered.subject, "Devis <b>D-1</b>");
    }

    fn localized(
        locale: &str,
        text: &str,
        payload: serde_json::Value,
    ) -> NotificationResult<String> {
        let mut j = job("Objet", "<p>x</p>", text);
        j.recipient.locale = Some(locale.into());
        j.locale = Some(locale.into());
        j.payload = payload;
        Renderer::default()
            .render(&j, None)
            .map(|rendered| rendered.text)
    }

    #[test]
    fn i18n_filters_follow_the_recipient_locale() {
        let payload = serde_json::json!({
            "count": 12345,
            "total": "1234.50",
            "ratio": 2.5,
            "due_at": "2026-03-29T01:30:00Z"
        });
        let text = "{{ payload.count | format_number }} ; {{ payload.ratio | format_number }} ; \
{{ payload.total | format_currency(\"EUR\") }} ; {{ payload.due_at | format_date(\"long\", \"Europe/Paris\") }} ; \
{{ payload.due_at | format_date(\"datetime_medium\", \"Europe/Paris\") }} ; {{ payload.due_at | format_date }} ; \
{{ payload.due_at | format_date(\"time\") }}";
        assert_eq!(
            localized("fr", text, payload.clone()).expect("rendu"),
            "12\u{202f}345 ; 2,5 ; 1\u{202f}234,50\u{a0}€ ; 29 mars 2026 ; 29 mars 2026, 03:30 ; 29 mars 2026 ; 01:30"
        );
        assert_eq!(
            localized("en-US", text, payload).expect("rendu"),
            "12,345 ; 2.5 ; €1,234.50 ; March 29, 2026 ; Mar 29, 2026, 3:30\u{202f}AM ; Mar 29, 2026 ; 1:30\u{202f}AM"
        );
    }

    #[test]
    fn i18n_filters_follow_the_send_locale() {
        let mut j = job("Objet", "<p>x</p>", "{{ payload.n | format_number }}");
        j.recipient.locale = None;
        j.locale = Some("de".into());
        j.payload = serde_json::json!({ "n": "1234.5" });
        assert_eq!(
            Renderer::default().render(&j, None).expect("rendu").text,
            "1.234,5"
        );
    }

    #[test]
    fn i18n_filters_refuse_invalid_values() {
        let payload = serde_json::json!({ "n": "douze", "d": "demain", "ok": "2026-03-29T01:30:00Z", "list": [1] });
        for text in [
            "{{ payload.n | format_number }}",
            "{{ payload.list | format_number }}",
            "{{ payload.n | format_currency(\"EUR\") }}",
            "{{ 12 | format_currency(\"euro\") }}",
            "{{ payload.d | format_date }}",
            "{{ payload.ok | format_date(\"full\") }}",
            "{{ payload.ok | format_date(\"long\", \"Mars/Olympus\") }}",
        ] {
            assert!(
                matches!(
                    localized("fr", text, payload.clone()),
                    Err(NotificationError::Render(_))
                ),
                "{text}"
            );
        }
        // Langue de l'envoi illisible : aucun rendu
        assert!(matches!(
            localized("pas une langue", "x", serde_json::json!({})),
            Err(NotificationError::Render(_))
        ));
    }

    fn resolved(key: &str, text: &str, syntax: &str, locale: &str) -> ResolvedText {
        ResolvedText {
            key: key.into(),
            text: text.into(),
            syntax: syntax.into(),
            locale: Some(locale.into()),
            overridden: false,
            missing: false,
        }
    }

    const ITEMS_FR: &str = "{count, plural, one {# article} other {# articles}}";
    const ITEMS_EN: &str = "{count, plural, one {# item} other {# items}}";

    #[test]
    fn translated_texts_are_rendered_with_their_arguments() {
        let mut j = job(
            "{{ t(\"devis.objet\", number=payload.n) }}",
            "<p>{{ t(\"devis.salut\", name=recipient.name) }} {{ t(\"devis.lignes\", count=payload.count) }}</p>",
            "{{ t(\"devis.lignes\", count=payload.count) }} / {{ t(\"devis.total\", ratio=payload.ratio) }}",
        );
        j.recipient.name = Some("<Claire>".into());
        j.payload = serde_json::json!({ "n": "D-1", "count": 1, "ratio": 2.5 });
        j.texts = vec![
            resolved("devis.objet", "Devis {number}", "icu_mf1", "fr"),
            resolved(
                "devis.salut",
                "Bonjour {name} & bienvenue,",
                "icu_mf1",
                "fr",
            ),
            resolved("devis.lignes", ITEMS_FR, "icu_mf1", "fr"),
            resolved(
                "devis.total",
                "Coefficient {ratio, number}",
                "icu_mf1",
                "fr",
            ),
        ];
        let rendered = Renderer::default().render(&j, None).expect("rendu");
        assert_eq!(rendered.subject, "Devis D-1");
        // Texte traduit et arguments échappés dans le HTML, jamais dans le texte
        assert_eq!(
            rendered.html,
            "<p>Bonjour &lt;Claire&gt; &amp; bienvenue, 1 article</p>"
        );
        assert_eq!(rendered.text, "1 article / Coefficient 2,5");
        j.payload = serde_json::json!({ "n": "D-1", "count": 3, "ratio": 2 });
        assert_eq!(
            Renderer::default().render(&j, None).expect("rendu").text,
            "3 articles / Coefficient 2"
        );
    }

    #[test]
    fn a_fallback_text_keeps_the_plural_rules_of_its_own_locale() {
        // Envoi en anglais ; la clé n'a qu'un texte français, servi en repli : zéro est au
        // singulier en français (« 0 article »), au pluriel en anglais (« 0 items »)
        let mut j = job("Objet", "<p>x</p>", "{{ t(\"a.lignes\", count=0) }} ; {{ t(\"a.items\", count=0) }} ; {{ 1234.5 | format_number }}");
        j.recipient.locale = Some("en-GB".into());
        j.locale = Some("en".into());
        j.texts = vec![
            resolved("a.lignes", ITEMS_FR, "icu_mf1", "fr"),
            resolved("a.items", ITEMS_EN, "icu_mf1", "en"),
        ];
        assert_eq!(
            Renderer::default().render(&j, None).expect("rendu").text,
            "0 article ; 0 items ; 1,234.5"
        );
        // Destinataire d'une autre langue que l'envoi : nombres dans la langue de l'envoi
        j.recipient.locale = Some("de".into());
        j.locale = Some("fr".into());
        assert!(Renderer::default()
            .render(&j, None)
            .expect("rendu")
            .text
            .ends_with("1\u{202f}234,5"));
    }

    #[test]
    fn unusable_texts_stop_the_rendering() {
        let texts = vec![
            resolved("a.simple", "Bonjour", "plain", "fr"),
            resolved("a.nom", "Bonjour {name}", "icu_mf1", "fr"),
            ResolvedText {
                key: "a.absente".into(),
                text: "a.absente".into(),
                syntax: "plain".into(),
                locale: None,
                overridden: false,
                missing: true,
            },
            resolved("a.cassee", "{count, plural, one {#}", "icu_mf1", "fr"),
        ];
        let render = |text: &str| {
            let mut j = job("Objet", "<p>x</p>", text);
            j.texts = texts.clone();
            Renderer::default().render(&j, None).map(|r| r.text)
        };
        assert_eq!(render("{{ t(\"a.simple\") }}").expect("rendu"), "Bonjour");
        for text in [
            // clé que le gabarit n'a pas déclarée
            "{{ t(\"a.autre\") }}",
            // clé inconnue de lyxal_i18n
            "{{ t(\"a.absente\") }}",
            // argument absent, argument d'un type refusé
            "{{ t(\"a.nom\") }}",
            "{{ t(\"a.nom\", name=payload.absent) }}",
            "{{ t(\"a.nom\", name=[1]) }}",
            // message invalide
            "{{ t(\"a.cassee\", count=1) }}",
            // appel sans clé
            "{{ t() }}",
        ] {
            assert!(
                matches!(render(text), Err(NotificationError::Render(_))),
                "{text}"
            );
        }
        // Textes illisibles à la réservation, syntaxe inconnue, langue de l'envoi absente
        let mut unreadable = job("Objet", "<p>x</p>", "x");
        unreadable.texts_error = Some("I18N_PERMISSION_DENIED".into());
        assert_eq!(
            Renderer::default()
                .render(&unreadable, None)
                .expect_err("textes illisibles")
                .to_string(),
            "rendu impossible : textes du gabarit illisibles : I18N_PERMISSION_DENIED"
        );
        let mut unknown = job("Objet", "<p>x</p>", "x");
        unknown.texts = vec![resolved("a.b", "x", "mf2", "fr")];
        assert!(Renderer::default().render(&unknown, None).is_err());
        let mut no_locale = job("Objet", "<p>x</p>", "x");
        no_locale.locale = None;
        assert!(Renderer::default().render(&no_locale, None).is_err());
    }

    #[test]
    fn secrets_and_layout_are_rendered() {
        let mut j = job("Code", "<p>{{ secret.code }}</p>", "{{ secret.code }}");
        j.layout_html = Some("<div>{{ content }}</div>".into());
        j.layout_text = Some("-- {{ content }} --".into());
        let secret = serde_json::json!({ "code": "123456" });
        let rendered = Renderer::default()
            .render(&j, secret.as_object())
            .expect("rendu");
        assert_eq!(rendered.html, "<div><p>123456</p></div>");
        assert_eq!(rendered.text, "-- 123456 --");
    }

    #[test]
    fn unknown_variable_is_an_error_but_may_be_tested() {
        let renderer = Renderer::default();
        assert!(renderer
            .render(&job("{{ payload.absent }}", "x", "x"), None)
            .is_err());
        assert!(renderer
            .render(
                &job("{% if payload.absent %}oui{% endif %}ok", "x", "x"),
                None
            )
            .is_ok());
        assert!(renderer
            .render(&job("{{ secret.code }}", "x", "x"), None)
            .is_err());
    }

    #[test]
    fn includes_are_impossible_and_fuel_is_bounded() {
        let renderer = Renderer::with_fuel(1_000);
        assert!(renderer
            .render(&job("{% include 'autre' %}", "x", "x"), None)
            .is_err());
        assert!(renderer
            .render(
                &job("{% for i in range(100000) %}{{ i }}{% endfor %}", "x", "x"),
                None
            )
            .is_err());
    }

    #[test]
    fn subject_is_kept_on_one_line_and_missing_template_is_an_error() {
        let rendered = Renderer::default()
            .render(&job("Bonjour\r\nBcc: espion@x.test", "x", "x"), None)
            .expect("rendu");
        assert!(!rendered.subject.contains('\n') && !rendered.subject.contains('\r'));
        let mut missing = job("s", "h", "t");
        missing.subject = None;
        assert_eq!(
            Renderer::default()
                .render(&missing, None)
                .expect_err("aucun gabarit")
                .to_string(),
            "rendu impossible : étape sans gabarit"
        );
    }
}
