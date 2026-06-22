use crate::constants::*;
use slug::slugify;

pub fn validate_project_domain(input: &str) -> Result<String, String> {
    let domain = slugify(input);
    if domain.len() < MIN_DOMAIN_LENGTH {
        return Err(format!("Minimum {} characters required", MIN_DOMAIN_LENGTH));
    }
    if RESERVED_DOMAINS.contains(&domain.as_str()) {
        return Err(format!("Domain {} is reserved", domain));
    }
    if RESERVED_PREFIXES.iter().any(|p| domain.starts_with(p)) {
        return Err(format!("Domain {} is reserved", domain));
    }
    Ok(domain)
}

