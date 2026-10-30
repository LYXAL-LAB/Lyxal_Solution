//! Exact identities and the byte-for-byte enc:v2 authentication domain.
use crate::{ContextField, CryptoError, KeyId};
use std::fmt;
const PREFIX: &[u8] = b"lyxal:crypto:enc:v2:aes-256-gcm\0";
#[derive(Clone, PartialEq, Eq)]
enum Domain {
    Tenant {
        tenant: String,
        module: String,
        resource: String,
        record_id: String,
        field: String,
    },
    Global {
        purpose: String,
    },
}
/// An authorized context supplied by the host, never normalized or inferred.
#[derive(Clone, PartialEq, Eq)]
pub struct SecretContext {
    domain: Domain,
}
fn valid_ascii(s: &str, max: usize, first_lower: bool, allow_dot: bool) -> bool {
    !s.is_empty()
        && s.len() <= max
        && (!first_lower || s.as_bytes()[0].is_ascii_lowercase())
        && s.bytes().all(|b| {
            if first_lower {
                b.is_ascii_lowercase()
                    || b.is_ascii_digit()
                    || b == b'_'
                    || (allow_dot && b".-".contains(&b))
            } else {
                b.is_ascii_alphanumeric() || b"_-".contains(&b)
            }
        })
}
fn edge_space(c: char) -> bool {
    matches!(c, '\u{9}'..='\u{d}' | '\u{20}' | '\u{85}' | '\u{a0}' | '\u{1680}' | '\u{2000}'..='\u{200a}' | '\u{2028}' | '\u{2029}' | '\u{202f}' | '\u{205f}' | '\u{3000}')
}
impl SecretContext {
    /// Exact tenant identity: no default tenant, trimming, case folding or Unicode normalization.
    pub fn with_tenant(
        tenant: &str,
        module: &str,
        resource: &str,
        record_id: &str,
        field: &str,
    ) -> Result<Self, CryptoError> {
        for (s, max, lower, label) in [
            (tenant, 128, false, ContextField::Tenant),
            (module, 64, true, ContextField::Module),
            (resource, 64, true, ContextField::Resource),
            (field, 64, true, ContextField::Field),
        ] {
            if !valid_ascii(s, max, lower, false) {
                return Err(CryptoError::InvalidContextField(label));
            }
        }
        if record_id.is_empty()
            || record_id.len() > 1024
            || record_id
                .chars()
                .any(|c| matches!(c,'\u{0}'..='\u{1f}' | '\u{7f}'..='\u{9f}'))
            || record_id.starts_with(edge_space)
            || record_id.ends_with(edge_space)
        {
            return Err(CryptoError::InvalidContextField(ContextField::RecordId));
        }
        Ok(Self {
            domain: Domain::Tenant {
                tenant: tenant.to_owned(),
                module: module.to_owned(),
                resource: resource.to_owned(),
                record_id: record_id.to_owned(),
                field: field.to_owned(),
            },
        })
    }
    /// Global infrastructure domain with an explicit purpose, never empty AAD.
    pub fn global(purpose: &str) -> Result<Self, CryptoError> {
        if !valid_ascii(purpose, 128, true, true) {
            return Err(CryptoError::InvalidContextField(ContextField::Purpose));
        }
        Ok(Self {
            domain: Domain::Global {
                purpose: purpose.to_owned(),
            },
        })
    }
    pub(crate) fn aad(&self, key_id: &KeyId) -> Vec<u8> {
        let mut out = Vec::with_capacity(1465);
        out.extend_from_slice(PREFIX);
        let mut append = |mode: u8, fields: &[&str]| {
            out.push(mode);
            for s in fields {
                out.extend_from_slice(&(s.len() as u32).to_be_bytes());
                out.extend_from_slice(s.as_bytes());
            }
        };
        match &self.domain {
            Domain::Tenant {
                tenant,
                module,
                resource,
                record_id,
                field,
            } => append(
                1,
                &[key_id.as_str(), tenant, module, resource, record_id, field],
            ),
            Domain::Global { purpose } => append(2, &[key_id.as_str(), purpose]),
        }
        out
    }
}
impl fmt::Debug for SecretContext {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("SecretContext([REDACTED])")
    }
}
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn exact_reference_aad_and_domains() {
        let ctx =
            SecretContext::with_tenant("Acme", "booking", "setting", "rec_é", "password").unwrap();
        assert_eq!(hex::encode(ctx.aad(&KeyId::parse("k1").unwrap())),"6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0001000000026b310000000441636d6500000007626f6f6b696e670000000773657474696e67000000067265635fc3a90000000870617373776f7264");
        assert_ne!(
            ctx.aad(&KeyId::parse("k1").unwrap()),
            ctx.aad(&KeyId::parse("k2").unwrap())
        );
        let global = SecretContext::global("smtp.password").unwrap();
        assert_eq!(hex::encode(global.aad(&KeyId::parse("k1").unwrap())),"6c7978616c3a63727970746f3a656e633a76323a6165732d3235362d67636d0002000000026b310000000d736d74702e70617373776f7264");
    }
}
