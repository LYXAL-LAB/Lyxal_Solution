use regex::Regex;

pub fn sanitize_s3_key(s: &str) -> String {
    let re_special = Regex::new(r"[\\x00-\\x1F\\x7F]+|[&$@=;/:+\\s,?]+").unwrap();
    let re_avoid = Regex::new(r"[\\x80-\\xFF]+|[\\\\{^}%\\`\\\\]'\\\"<>#|]+").unwrap();
    let s = re_special.replace_all(s, "_");
    let s = re_avoid.replace_all(&s, "_");
    s.into_owned()
}

pub fn extended_encode_uri_component(s: &str) -> String {
    urlencoding::encode(s)
        .replace("!", "%21")
        .replace("'", "%27")
        .replace("(", "%28")
        .replace(")", "%29")
        .replace("*", "%2A")
}

