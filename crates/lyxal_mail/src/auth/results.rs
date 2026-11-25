// SPDX-License-Identifier: AGPL-3.0-only

//! En-tête `Authentication-Results` (RFC 8601), écrit depuis la RFC : écriture de nos résultats
//! et retrait des en-têtes reçus qui portent notre `authserv-id` (§5).
//!
//! Les valeurs écrites viennent de nos seuls contrôles ; chacune est un `token` ou une chaîne
//! entre guillemets échappée, sans caractère de contrôle ni octet hors de l'ASCII (aucune
//! injection d'en-tête). `smtp.mailfrom` porte le **domaine** de l'identité contrôlée, jamais
//! l'adresse.

use super::dkim::DkimOutput;
use super::dmarc::DmarcOutput;
use super::headers::{HeaderError, MessageHeaders};
use super::iprev::IprevOutput;
use super::spf::{SpfIdentity, SpfOutput};

/// Nom du champ.
const FIELD_NAME: &str = "Authentication-Results";
/// Profondeur maximale des commentaires lus avant l'`authserv-id`.
const MAX_COMMENT_DEPTH: usize = 8;

/// Résultats à écrire dans un en-tête `Authentication-Results`.
#[derive(Clone, Debug, PartialEq, Eq)]
pub struct AuthenticationResults {
    authserv_id: String,
    entries: Vec<String>,
}

impl AuthenticationResults {
    /// En-tête vide pour notre `authserv-id` (le nom de l'hôte, `smtp.hostname`).
    pub fn new(authserv_id: &str) -> Self {
        Self {
            authserv_id: pvalue(authserv_id),
            entries: Vec::new(),
        }
    }

    /// Résultat SPF (`smtp.mailfrom` ou `smtp.helo`).
    pub fn spf(&mut self, output: &SpfOutput) -> &mut Self {
        let property = match output.identity {
            SpfIdentity::MailFrom => "smtp.mailfrom",
            SpfIdentity::Helo => "smtp.helo",
        };
        let mut entry = format!("spf={}", output.result.as_str());
        if let Some(domain) = &output.domain {
            entry.push_str(&format!(" {property}={}", pvalue(domain)));
        }
        self.entries.push(entry);
        self
    }

    /// Résultats DKIM, une entrée par signature (`header.d`, `header.s`, `header.b`).
    pub fn dkim(&mut self, outputs: &[DkimOutput]) -> &mut Self {
        for output in outputs {
            let mut entry = format!("dkim={}", output.result.as_str());
            if let Some(domain) = &output.domain {
                entry.push_str(&format!(" header.d={}", pvalue(domain)));
            }
            if let Some(selector) = &output.selector {
                entry.push_str(&format!(" header.s={}", pvalue(selector)));
            }
            if let Some(prefix) = &output.signature_prefix {
                entry.push_str(&format!(" header.b={}", pvalue(prefix)));
            }
            self.entries.push(entry);
        }
        self
    }

    /// Résultats DMARC, une entrée par domaine d'auteur (`header.from`, `policy.dmarc`).
    pub fn dmarc(&mut self, outputs: &[DmarcOutput]) -> &mut Self {
        for output in outputs {
            let mut entry = format!(
                "dmarc={} header.from={}",
                output.result.as_str(),
                pvalue(&output.from_domain)
            );
            if let Some(policy) = output.policy {
                entry.push_str(&format!(" policy.dmarc={}", policy.as_str()));
            }
            self.entries.push(entry);
        }
        self
    }

    /// Résultat du nom inverse (`policy.iprev`).
    pub fn iprev(&mut self, output: &IprevOutput) -> &mut Self {
        self.entries.push(format!(
            "iprev={} policy.iprev={}",
            output.result.as_str(),
            pvalue(&output.ip.to_string())
        ));
        self
    }

    /// Champ complet, fin de ligne comprise, une méthode par ligne repliée ; `none` s'il n'y a
    /// aucun résultat (§2.2).
    pub fn to_header(&self) -> String {
        let mut header = format!("{FIELD_NAME}: {}", self.authserv_id);
        if self.entries.is_empty() {
            header.push_str("; none");
        }
        for entry in &self.entries {
            header.push_str(";\r\n\t");
            header.push_str(entry);
        }
        header.push_str("\r\n");
        header
    }
}

/// Valeur : `token` (RFC 2045 §5.1) si possible, sinon chaîne entre guillemets ; caractères de
/// contrôle et non ASCII retirés.
fn pvalue(value: &str) -> String {
    let clean: String = value
        .chars()
        .filter(|character| character.is_ascii() && !character.is_ascii_control())
        .collect();
    let is_token = !clean.is_empty()
        && clean
            .bytes()
            .all(|byte| byte.is_ascii_graphic() && !b"()<>@,;:\\\"/[]?=".contains(&byte));
    if is_token {
        return clean;
    }
    let mut quoted = String::with_capacity(clean.len() + 2);
    quoted.push('"');
    for character in clean.chars() {
        if character == '"' || character == '\\' {
            quoted.push('\\');
        }
        quoted.push(character);
    }
    quoted.push('"');
    quoted
}

/// Retire de l'en-tête les champs `Authentication-Results` dont l'`authserv-id` est le nôtre
/// (casse ignorée) ; les autres champs et le corps sont gardés octet pour octet.
pub fn strip_forged_results(message: &[u8], authserv_id: &str) -> Result<Vec<u8>, HeaderError> {
    let headers = MessageHeaders::parse(message)?;
    let base = message.as_ptr() as usize;
    let mut kept = Vec::with_capacity(message.len());
    let mut position = 0;
    for field in &headers.fields {
        if !field.is(FIELD_NAME)
            || !read_authserv_id(field.value).is_some_and(|id| id.eq_ignore_ascii_case(authserv_id))
        {
            continue;
        }
        let start = (field.raw.as_ptr() as usize).saturating_sub(base);
        kept.extend_from_slice(message.get(position..start).unwrap_or_default());
        position = start + field.raw.len();
    }
    kept.extend_from_slice(message.get(position..).unwrap_or_default());
    Ok(kept)
}

/// `authserv-id` d'une valeur reçue : premier mot après les espaces et commentaires.
fn read_authserv_id(value: &[u8]) -> Option<String> {
    let mut index = 0;
    loop {
        match value.get(index)? {
            b' ' | b'\t' | b'\r' | b'\n' => index += 1,
            b'(' => index = skip_comment(value, index)?,
            _ => break,
        }
    }
    if value.get(index) == Some(&b'"') {
        let mut id = Vec::new();
        index += 1;
        loop {
            match value.get(index)? {
                b'"' => break,
                b'\\' => {
                    id.push(*value.get(index + 1)?);
                    index += 2;
                }
                byte => {
                    id.push(*byte);
                    index += 1;
                }
            }
        }
        return String::from_utf8(id).ok();
    }
    let rest = value.get(index..)?;
    let end = rest
        .iter()
        .position(|byte| matches!(byte, b';' | b' ' | b'\t' | b'\r' | b'\n' | b'('))
        .unwrap_or(rest.len());
    String::from_utf8(rest.get(..end)?.to_vec()).ok()
}

/// Position après un commentaire (imbrication bornée).
fn skip_comment(value: &[u8], start: usize) -> Option<usize> {
    let mut depth = 0usize;
    let mut index = start;
    loop {
        match value.get(index)? {
            b'(' => {
                depth += 1;
                if depth > MAX_COMMENT_DEPTH {
                    return None;
                }
            }
            b')' => {
                depth -= 1;
                if depth == 0 {
                    return Some(index + 1);
                }
            }
            b'\\' => index += 1,
            _ => {}
        }
        index += 1;
    }
}

#[cfg(test)]
#[allow(clippy::unwrap_used, clippy::expect_used)]
mod tests {
    use super::*;
    use crate::auth::{DkimResult, DmarcPolicy, DmarcResult, IprevResult, SpfResult};

    #[test]
    fn ecriture() {
        let mut results = AuthenticationResults::new("mx.lyxal.test");
        results
            .spf(&SpfOutput {
                result: SpfResult::Pass,
                identity: SpfIdentity::MailFrom,
                domain: Some("example.net".into()),
            })
            .spf(&SpfOutput {
                result: SpfResult::None,
                identity: SpfIdentity::Helo,
                domain: None,
            })
            .dkim(&[DkimOutput {
                result: DkimResult::Pass,
                domain: Some("example.net".into()),
                selector: Some("sel".into()),
                signature_prefix: Some("ab/+=cd1".into()),
                testing: false,
            }])
            .dmarc(&[DmarcOutput {
                result: DmarcResult::Pass,
                from_domain: "example.net".into(),
                record_domain: Some("example.net".into()),
                policy: Some(DmarcPolicy::Reject),
                percentage: 100,
                spf_aligned: true,
                dkim_aligned: true,
            }])
            .iprev(&IprevOutput {
                result: IprevResult::Pass,
                ip: "2001:db8::1".parse().unwrap(),
                name: Some("mail.example.net".into()),
            });
        assert_eq!(
            results.to_header(),
            "Authentication-Results: mx.lyxal.test;\r\n\
             \tspf=pass smtp.mailfrom=example.net;\r\n\
             \tspf=none;\r\n\
             \tdkim=pass header.d=example.net header.s=sel header.b=\"ab/+=cd1\";\r\n\
             \tdmarc=pass header.from=example.net policy.dmarc=reject;\r\n\
             \tiprev=pass policy.iprev=\"2001:db8::1\"\r\n"
        );
        assert_eq!(
            AuthenticationResults::new("mx.lyxal.test").to_header(),
            "Authentication-Results: mx.lyxal.test; none\r\n"
        );
    }

    #[test]
    fn echappement() {
        assert_eq!(pvalue("example.net"), "example.net");
        assert_eq!(pvalue("a\r\nX-Injecte: 1"), "\"aX-Injecte: 1\"");
        assert_eq!(pvalue("a\"b\\c"), "\"a\\\"b\\\\c\"");
        assert_eq!(pvalue("été"), "t");
        assert_eq!(pvalue(""), "\"\"");
    }

    #[test]
    fn retrait_des_en_tetes_falsifies() {
        let message = b"Received: x\r\n\
            Authentication-Results: MX.Lyxal.Test; spf=pass\r\n\
            Authentication-Results: (commentaire (imbrique)) mx.lyxal.test 1;\r\n dkim=pass\r\n\
            Authentication-Results: \"mx.lyxal.test\"; dmarc=pass\r\n\
            Authentication-Results: autre.example; spf=fail\r\n\
            Authentication-Results: mx.lyxal.test.evil; spf=fail\r\n\
            Subject: s\r\n\r\nAuthentication-Results: mx.lyxal.test; corps garde\r\n";
        let stripped = strip_forged_results(message, "mx.lyxal.test").unwrap();
        assert_eq!(
            stripped,
            b"Received: x\r\n\
            Authentication-Results: autre.example; spf=fail\r\n\
            Authentication-Results: mx.lyxal.test.evil; spf=fail\r\n\
            Subject: s\r\n\r\nAuthentication-Results: mx.lyxal.test; corps garde\r\n"
                .to_vec()
        );
        let untouched = b"Subject: s\r\n\r\ncorps\r\n";
        assert_eq!(
            strip_forged_results(untouched, "mx.lyxal.test").unwrap(),
            untouched.to_vec()
        );
        assert!(strip_forged_results(b" mal\r\n\r\n", "mx.lyxal.test").is_err());
        assert_eq!(read_authserv_id(b" ((((((((((x))))))))) id;"), None);
    }
}
