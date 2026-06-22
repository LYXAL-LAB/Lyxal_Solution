use slug::slugify;
use nanoid::nanoid;
use crate::constants::MIN_DOMAIN_LENGTH;

pub fn generate_domain(title: &str) -> String {
    let slugified = slugify(title);
    let suffix_len = if slugified.len() >= MIN_DOMAIN_LENGTH { 5 } else { MIN_DOMAIN_LENGTH - slugified.len() };
    format!("{}-{}", slugified, nanoid!(suffix_len))
}

