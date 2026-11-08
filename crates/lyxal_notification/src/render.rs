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

use minijinja::value::Value;
use minijinja::{AutoEscape, Environment, UndefinedBehavior};

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
            return Err(NotificationError::Render(
                "aucune version du gabarit dans une langue utilisable".to_string(),
            ));
        };
        let env = self.environment();
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

    fn environment(&self) -> Environment<'static> {
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
        env
    }
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
                .expect_err("aucune version")
                .to_string(),
            "rendu impossible : aucune version du gabarit dans une langue utilisable"
        );
    }
}
