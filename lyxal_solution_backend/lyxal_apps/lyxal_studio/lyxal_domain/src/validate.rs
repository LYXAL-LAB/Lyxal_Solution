pub fn validate_domain(domain: &str) -> Result<String, String> {
    let host = if domain.contains("://") {
        url::Url::parse(domain).map_err(|_| "Invalid URL")?
            .host_str().ok_or("No host")?.to_string()
    } else {
        url::Url::parse(&format!("https://{}", domain)).map_err(|_| "Invalid domain")?
            .host_str().ok_or("No host")?.to_string()
    };

    let parts: Vec<&str> = host.split('.').collect();
    if parts.len() < 2 {
        return Err(format!("The domain '{}' must have at least two levels.", host));
    }
    if parts.len() > 4 {
        return Err(format!("The domain '{}' must have at most four levels.", host));
    }

    Ok(host)
}

