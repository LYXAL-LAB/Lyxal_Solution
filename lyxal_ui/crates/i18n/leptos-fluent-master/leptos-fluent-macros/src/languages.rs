use std::borrow::Cow;
use std::fs;
use std::path::PathBuf;
use std::rc::Rc;

type LangCode = String;
type LangName = String;
type LangDir = String;
type LangFlag = Option<String>;
type LangScript = Option<String>;
pub(crate) type ParsedLanguage =
(LangCode, LangName, LangDir, LangFlag, LangScript);

#[cfg(any(feature = "json", feature = "yaml", feature = "json5"))]
#[derive(serde::Deserialize)]
#[serde(untagged)]
enum RawLanguagesFileLanguage {
Basic(String, String),
CodeNameDir(String, String, String),
CodeNameDirFlag(String, String, String, String),
}

#[cfg(any(feature = "json", feature = "yaml", feature = "json5"))]
fn fill_languages_file(
languages: &[RawLanguagesFileLanguage],
) -> Vec<ParsedLanguage> {
let mut locales = vec![];
for tuple in languages {
match tuple {
RawLanguagesFileLanguage::Basic(lang_code, lang_name) => locales
.push(locale_from_lang_code(
lang_code,
lang_name,
iso639_to_dir(&code_to_iso639(lang_code)),
None,
)),
RawLanguagesFileLanguage::CodeNameDir(
lang_code,
lang_name,
dir,
) => locales
.push(locale_from_lang_code(lang_code, lang_name, dir, None)),
RawLanguagesFileLanguage::CodeNameDirFlag(
lang_code,
lang_name,
dir,
flag,
) => locales.push(locale_from_lang_code(
lang_code,
lang_name,
dir,
Some(flag.to_owned()),
)),
}
}
locales
}

#[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
pub(crate) fn read_languages_file(
path: &PathBuf,
) -> Result<Vec<ParsedLanguage>, String> {
#[cfg(feature = "tracing")]
tracing::trace!("Reading languages file {:?}", path);

#[cfg(feature = "json")]
{
let file_extension = path.extension().unwrap_or_default();
if file_extension == "json" {
match fs::read_to_string(path) {
Ok(content) => {
match serde_json::from_str::<Vec<RawLanguagesFileLanguage>>(
content.as_str(),
) {
Ok(languages) => Ok(fill_languages_file(&languages)),
Err(e) => {
let error_message = format!(
"Invalid JSON in languages file {}: {}",
path.to_string_lossy(),
e
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}
}
Err(e) => {
let error_message = format!(
"Couldn't read languages file {}: {}",
path.to_string_lossy(),
e,
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}
} else {
let error_message = format!(
concat!(
"The languages file should be a JSON file because",
" you've enabled the 'json' feature.",
" Found file extension {:?}"
),
file_extension
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}

#[cfg(all(not(feature = "json"), feature = "yaml"))]
{
let file_extension = path.extension().unwrap_or_default();
if file_extension == "yaml" || file_extension == "yml" {
match fs::read_to_string(path) {
Ok(content) => {
match serde_yaml::from_str::<Vec<RawLanguagesFileLanguage>>(
content.as_str(),
) {
Ok(languages) => Ok(fill_languages_file(&languages)),
Err(e) => {
let error_message = format!(
"Invalid YAML in languages file {}: {}",
path.to_string_lossy(),
e.to_string()
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}
}
Err(e) => {
let error_message = format!(
"Couldn't read languages file {}: {}",
path.to_string_lossy(),
e,
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}
} else {
let error_message = format!(
concat!(
"The languages file should be a YAML file because",
" you've enabled the 'yaml' feature.",
" Found file extension {:?}"
),
file_extension
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}

#[cfg(all(
not(any(feature = "json", feature = "yaml")),
feature = "json5"
))]
{
let file_extension = path.extension().unwrap_or_default();
if file_extension == "json5" {
match fs::read_to_string(path) {
Ok(content) => {
match json5::from_str::<Vec<RawLanguagesFileLanguage>>(
content.as_str(),
) {
Ok(languages) => Ok(fill_languages_file(&languages)),
Err(e) => {
let error_message = format!(
"Invalid JSON5 in languages file {}: {}",
path.to_string_lossy(),
e.to_string()
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}
}
Err(e) => {
let error_message = format!(
"Couldn't read languages file {}: {}",
path.to_string_lossy(),
e,
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}
} else {
let error_message = format!(
concat!(
"The languages file should be a JSON5 file because",
" you've enabled the 'json5' feature.",
" Found file extension {:?}"
),
file_extension
);

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}

#[cfg(not(any(feature = "json", feature = "yaml", feature = "json5")))]
{
_ = path;
let error_message = concat!(
"No feature enabled to read languages file.",
" Enable either the 'json', 'yaml' or 'json5' feature.",
)
.to_string();

#[cfg(feature = "tracing")]
tracing::error!("{}", error_message);

Err(error_message)
}
}

#[cfg_attr(feature = "tracing", tracing::instrument(level = "trace", skip_all))]
pub(crate) fn read_locales_folder(
path: &PathBuf,
) -> (Vec<ParsedLanguage>, Vec<String>) {
#[cfg(feature = "tracing")]
tracing::trace!("Reading locales folder {:?}", path);

let mut errors = vec![];

let mut language_codes: Vec<(String, Rc<str>, LangScript)> = vec![];
for entry in fs::read_dir(path).expect("Couldn't read locales folder") {
let entry = entry.expect("Couldn't read entry");
let path = entry.path();
if !path.is_dir() {
continue;
}
let lang_code = path.file_name().unwrap().to_str().unwrap();
let iso639_code = code_to_iso639(lang_code).into_owned();
let script = extract_script_from_lang_code(lang_code);
language_codes.push((
iso639_code,
Rc::clone(&lang_code.into()),
script,
));
}

let iso639_language_codes: Vec<&str> =
language_codes.iter().map(|(a, _, _)| a.as_ref()).collect();
let mut locales = vec![];
for (iso639_code, lang_code, script) in &language_codes {
let use_country_code = iso639_language_codes
.iter()
.filter(|&c| c == iso639_code)
.count()
> 1;
let lang_name =
language_name_from_language_code(lang_code, use_country_code);
if lang_name.is_empty() {
errors.push(format!(
concat!(
"Couldn't find language name for code \"{}\". Provide it",
" from a languages file (see `languages` parameter).",
),
&lang_code,
));
continue;
}
let lang_dir = iso639_to_dir(iso639_code);
locales.push(locale_from_parts(
lang_code,
lang_name,
lang_dir,
script.as_ref(),
));
}
locales.sort_by(|a, b| a.1.cmp(&b.1));

#[cfg(feature = "tracing")]
if !errors.is_empty() {
tracing::warn!("Errors reading locales folder: {:?}", errors);
} else {
tracing::trace!("Read locales: {:?}", locales);
}

(locales, errors)
}

pub(crate) fn build_languages_quote(
languages: &[ParsedLanguage],
) -> proc_macro2::TokenStream {
format!(
"[{}]",
languages
.iter()
.map(|(id, name, dir, flag, script)| {
generate_code_for_static_language(id, name, dir, flag, script)
})
.collect::<Vec<String>>()
.join(",")
)
.parse::<proc_macro2::TokenStream>()
.unwrap()
}

fn generate_code_for_static_language(
id: &str,
name: &str,
dir: &str,
flag: &Option<String>,
script: &Option<String>,
) -> String {
format!(
concat!(
"&::leptos_fluent::Language{{",
"id:\"{}\",",
"name:\"{}\",",
"dir:{},",
"flag:{},",
"script:{}",
"}}",
),
id,
name,
match dir {
"ltr" => "&::leptos_fluent::WritingDirection::Ltr",
"rtl" => "&::leptos_fluent::WritingDirection::Rtl",
_ => "&::leptos_fluent::WritingDirection::Auto",
},
match flag {
Some(f) => format!("Some(\"{f}\")"),
None => "None".to_string(),
},
match script {
Some(s) => format!("Some(\"{s}\")"),
None => "None".to_string(),
},
)
}

fn extract_script_from_lang_code(code: &str) -> Option<String> {
let mut parts = code.split(['-', '_']);
let _language = parts.next();
parts.find_map(|part| {
if part.len() == 4 && part.chars().all(|c| c.is_ascii_alphabetic()) {
let mut normalized = String::with_capacity(4);
let mut chars = part.chars();
if let Some(first) = chars.next() {
normalized.push(first.to_ascii_uppercase());
}
for ch in chars {
normalized.push(ch.to_ascii_lowercase());
}
Some(normalized)
} else {
None
}
})
}

#[cfg(any(feature = "json", feature = "yaml", feature = "json5"))]
fn locale_from_lang_code(
lang_code: &str,
lang_name: &str,
dir: &str,
explicit_flag: Option<String>,
) -> ParsedLanguage {
let script = extract_script_from_lang_code(lang_code);
let flag = explicit_flag.or_else(|| {
code_to_country_code(lang_code)
.and_then(|country_code| country_code_to_emoji_flag(&country_code))
.map(|f| f.to_owned())
});
(
lang_code.to_owned(),
lang_name.to_owned(),
dir.to_owned(),
flag,
script,
)
}

fn locale_from_parts(
lang_code: &str,
lang_name: &str,
lang_dir: &str,
script: Option<&String>,
) -> ParsedLanguage {
let script_owned = script
.cloned()
.or_else(|| extract_script_from_lang_code(lang_code));
let flag = code_to_country_code(lang_code)
.and_then(|country_code| country_code_to_emoji_flag(&country_code))
.map(|f| f.to_string());
(
lang_code.to_string(),
lang_name.to_string(),
lang_dir.to_string(),
flag,
script_owned,
)
}

fn language_name_with_script_override(
code: &str,
script: &str,
) -> Option<&'static str> {
let mut normalized = code.to_lowercase().replace('_', "-");
let mut parts = normalized.split('-').collect::<Vec<&str>>();
if parts.len() >= 3
&& parts[1].len() == 4
&& parts[1].chars().all(|c| c.is_ascii_alphabetic())
{
parts.remove(1);
normalized = parts.join("-");
}
let script_lc = script.to_lowercase();
match (normalized.as_str(), script_lc.as_str()) {
("sr", "latn") => Some("Srpski (Latinica)"),
("sr", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°)"),
("sr-ba", "latn") => Some("Srpski (Latinica, Bosna i Hercegovina)"),
("sr-ba", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð‘Ð¾ÑÐ½Ð° Ð¸ Ð¥ÐµÑ€Ñ†ÐµÐ³Ð¾Ð²Ð¸Ð½Ð°)"),
("sr-me", "latn") => Some("Srpski (Latinica, Crna Gora)"),
("sr-me", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð¦Ñ€Ð½Ð° Ð“Ð¾Ñ€Ð°)"),
("sr-rs", "latn") => Some("Srpski (Latinica, Srbija)"),
("sr-rs", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð¡Ñ€Ð±Ð¸Ñ˜Ð°)"),
("sr-xk", "latn") => Some("Srpski (Latinica, Kosovo)"),
("sr-xk", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, ÐšÐ¾ÑÐ¾Ð²Ð¾)"),
("sr-bih", "latn") => Some("Srpski (Latinica, Bosna i Hercegovina)"),
("sr-bih", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð‘Ð¾ÑÐ½Ð° Ð¸ Ð¥ÐµÑ€Ñ†ÐµÐ³Ð¾Ð²Ð¸Ð½Ð°)"),
("sr-mne", "latn") => Some("Srpski (Latinica, Crna Gora)"),
("sr-mne", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð¦Ñ€Ð½Ð° Ð“Ð¾Ñ€Ð°)"),
("sr-srb", "latn") => Some("Srpski (Latinica, Srbija)"),
("sr-srb", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð¡Ñ€Ð±Ð¸Ñ˜Ð°)"),
("sr-xkk", "latn") => Some("Srpski (Latinica, Kosovo)"),
("sr-xkk", "cyrl") => Some("Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, ÐšÐ¾ÑÐ¾Ð²Ð¾)"),
("zh", "hans") | ("zh-hans", _) => Some("ä¸­æ–‡ (ç®€ä½“)"),
("zh", "hant") | ("zh-hant", _) => Some("ä¸­æ–‡ (ç¹é«”)"),
("zh-cn", "hans") => Some("ä¸­æ–‡ (ç®€ä½“)"),
("zh-tw", "hant") => Some("ä¸­æ–‡ (ç¹é«”)"),
("zh-hk", "hant") => Some("ä¸­æ–‡ (é¦™æ¸¯ç¹é«”)"),
("zh-hk", "hans") => Some("ä¸­æ–‡ (é¦™æ¸¯ç®€ä½“)"),
("zh-sg", "hans") => Some("ä¸­æ–‡ (æ–°åŠ å¡ç®€ä½“)"),
("zh-mo", "hant") => Some("ä¸­æ–‡ (æ¾³é–€ç¹é«”)"),
_ => None,
}
}

#[cfg(test)]
mod tests {
use super::*;

#[test]
fn extract_script_handles_sr_and_zh_variants() {
assert_eq!(
extract_script_from_lang_code("sr-Latn-RS"),
Some("Latn".into())
);
assert_eq!(
extract_script_from_lang_code("sr-Cyrl"),
Some("Cyrl".into())
);
assert_eq!(
extract_script_from_lang_code("zh-Hans-CN"),
Some("Hans".into())
);
assert_eq!(
extract_script_from_lang_code("zh-Hant-TW"),
Some("Hant".into())
);
assert_eq!(extract_script_from_lang_code("en-US"), None);
}

#[test]
fn language_name_override_applies_for_scripts() {
assert_eq!(
language_name_from_language_code("sr-Latn-RS", true),
"Srpski (Latinica, Srbija)"
);
assert_eq!(
language_name_from_language_code("sr-Cyrl-RS", true),
"Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‹Ð¸Ñ€Ð¸Ð»Ð¸Ñ†Ð°, Ð¡Ñ€Ð±Ð¸Ñ˜Ð°)"
);
assert_eq!(
language_name_from_language_code("zh-Hant-TW", true),
"ä¸­æ–‡ (ç¹é«”)"
);
assert_eq!(
language_name_from_language_code("zh-Hans-CN", true),
"ä¸­æ–‡ (ç®€ä½“)"
);
}

#[test]
fn country_code_detection_ignores_script() {
assert_eq!(code_to_country_code("sr-Latn-RS"), Some("RS".to_string()));
assert_eq!(code_to_country_code("sr-Cyrl-RS"), Some("RS".to_string()));
assert_eq!(code_to_country_code("zh-Hant-TW"), Some("TW".to_string()));
assert_eq!(code_to_country_code("zh-Hans-CN"), Some("CN".to_string()));
}
}

fn code_to_iso639(code: &str) -> Cow<'_, str> {
let splitter = if code.contains('_') {
'_'
} else if code.contains('-') {
'-'
} else if code.chars().any(char::is_uppercase) {
return code.to_lowercase().into();
} else {
return code.into();
};
let mut iso639 = String::with_capacity(code.len());
for ch in code.chars() {
if ch == splitter {
break;
}
iso639.push(ch);
}
iso639.into()
}

fn code_to_country_code(code: &str) -> Option<String> {
let splitter = if code.contains('_') {
'_'
} else if code.contains('-') {
'-'
} else {
return None;
};
let mut parts = code.split(splitter).collect::<Vec<&str>>();
if parts.len() <= 1 {
return None;
}
if parts[1].len() == 4 && parts[1].chars().all(|c| c.is_ascii_alphabetic())
{
if parts.len() <= 2 {
return None;
}
parts.remove(1);
}
parts.get(1).map(|part| part.to_ascii_uppercase())
}

/// Convert an ISO-639 language code to a directionality string.
///
/// Taken from https://github.com/chladog/iso-639-1-dir
fn iso639_to_dir(code: &str) -> &'static str {
match code {
"aa" => "ltr",
"ab" => "ltr",
"ae" => "ltr",
"af" => "ltr",
"ak" => "ltr",
"am" => "ltr",
"an" => "ltr",
"ar" => "rtl",
"as" => "ltr",
"av" => "ltr",
"ay" => "ltr",
"az" => "ltr",
"ba" => "ltr",
"be" => "ltr",
"bg" => "ltr",
"bi" => "ltr",
"bm" => "auto",
"bn" => "ltr",
"bo" => "ltr",
"br" => "ltr",
"bs" => "ltr",
"ca" => "ltr",
"ce" => "ltr",
"ch" => "ltr",
"co" => "ltr",
"cr" => "ltr",
"cs" => "ltr",
"cu" => "ltr",
"cv" => "ltr",
"cy" => "ltr",
"da" => "ltr",
"de" => "ltr",
"dv" => "rtl",
"dz" => "ltr",
"ee" => "ltr",
"el" => "ltr",
"en" => "ltr",
"eo" => "ltr",
"es" => "ltr",
"et" => "ltr",
"eu" => "ltr",
"fa" => "rtl",
"ff" => "ltr",
"fi" => "ltr",
"fj" => "ltr",
"fo" => "ltr",
"fr" => "ltr",
"fy" => "ltr",
"ga" => "ltr",
"gd" => "ltr",
"gl" => "ltr",
"gn" => "ltr",
"gu" => "ltr",
"gv" => "ltr",
"ha" => "ltr",
"he" => "rtl",
"hi" => "ltr",
"ho" => "ltr",
"hr" => "ltr",
"ht" => "ltr",
"hu" => "ltr",
"hy" => "ltr",
"hz" => "ltr",
"ia" => "ltr",
"id" => "ltr",
"ie" => "ltr",
"ig" => "ltr",
"ii" => "ltr",
"ik" => "ltr",
"io" => "ltr",
"is" => "ltr",
"it" => "ltr",
"iu" => "ltr",
"ja" => "auto", // (top to bottom)
"jv" => "ltr",
"ka" => "ltr",
"kg" => "ltr",
"ki" => "ltr",
"kj" => "ltr",
"kk" => "ltr",
"kl" => "ltr",
"km" => "ltr",
"kn" => "ltr",
"ko" => "auto", // (top to bottom)
"kr" => "ltr",
"ks" => "rtl",
"ku" => "rtl",
"kv" => "ltr",
"kw" => "ltr",
"ky" => "ltr",
"la" => "ltr",
"lb" => "ltr",
"lg" => "ltr",
"li" => "ltr",
"ln" => "ltr",
"lo" => "ltr",
"lt" => "ltr",
"lu" => "ltr",
"lv" => "ltr",
"mg" => "ltr",
"mh" => "ltr",
"mi" => "ltr",
"mk" => "ltr",
"ml" => "ltr",
"mn" => "auto", // (top to bottom)
"mr" => "ltr",
"ms" => "ltr",
"mt" => "ltr",
"my" => "ltr",
"na" => "ltr",
"nb" => "ltr",
"nd" => "ltr",
"ne" => "ltr",
"ng" => "ltr",
"nl" => "ltr",
"nn" => "ltr",
"no" => "ltr",
"nr" => "ltr",
"nv" => "ltr",
"ny" => "ltr",
"oc" => "ltr",
"oj" => "ltr",
"om" => "ltr",
"or" => "ltr",
"os" => "ltr",
"pa" => "rtl",
"pi" => "ltr",
"pl" => "ltr",
"ps" => "rtl",
"pt" => "ltr",
"qu" => "ltr",
"rm" => "ltr",
"rn" => "ltr",
"ro" => "ltr",
"ru" => "ltr",
"rw" => "ltr",
"sa" => "ltr",
"sc" => "ltr",
"sd" => "rtl",
"se" => "ltr",
"sg" => "ltr",
"si" => "ltr",
"sk" => "ltr",
"sl" => "ltr",
"sm" => "ltr",
"sn" => "ltr",
"so" => "ltr",
"sq" => "ltr",
"sr" => "ltr",
"ss" => "ltr",
"st" => "ltr",
"su" => "ltr",
"sv" => "ltr",
"sw" => "ltr",
"ta" => "ltr",
"te" => "ltr",
"tg" => "ltr",
"th" => "ltr",
"ti" => "ltr",
"tk" => "rtl",
"tl" => "ltr",
"tn" => "ltr",
"to" => "ltr",
"tr" => "ltr",
"ts" => "ltr",
"tt" => "ltr",
"tw" => "ltr",
"ty" => "ltr",
"ug" => "rtl",
"uk" => "ltr",
"ur" => "rtl",
"uz" => "ltr",
"ve" => "ltr",
"vi" => "auto", // (top to bottom)
"vo" => "ltr",
"wa" => "ltr",
"wo" => "ltr",
"xh" => "ltr",
"yi" => "rtl",
"yo" => "ltr",
"za" => "auto", // (top to bottom)
"zh" => "auto", // (top to bottom)
"zu" => "ltr",
_ => "auto",
}
}

fn language_name_from_language_code(
code: &str,
use_country_code: bool,
) -> &'static str {
if let Some(script) = extract_script_from_lang_code(code) {
if let Some(name) = language_name_with_script_override(code, &script) {
return name;
}
}

if use_country_code {
let mut normalized = code.to_string().to_lowercase().replace('_', "-");
let mut parts = normalized.split('-').collect::<Vec<&str>>();
if parts.len() >= 3
&& parts[1].len() == 4
&& parts[1].chars().all(|c| c.is_ascii_alphabetic())
{
parts.remove(1);
normalized = parts.join("-");
}
match normalized.as_str() {
// lang (3 letter) -> number
"jbo-001" => return "Lojban (World)",
// lang (2 letter) -> country (2 letter)
"af-na" => return "Afrikaans (Namibia)",
"af-za" => return "Afrikaans (South Africa)",
"ak-gh" => return "Akan (Ghana)",
"am-et" => return "áŠ áˆ›áˆ­áŠ› (áŠ¢á‰µá‹®áŒµá‹«)",
"ar-ae" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¥Ù…Ø§Ø±Ø§Øª Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© Ø§Ù„Ù…ØªØ­Ø¯Ø©)",
"ar-bh" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¨Ø­Ø±ÙŠÙ†)",
"ar-dj" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¬ÙŠØ¨ÙˆØªÙŠ)",
"ar-dz" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¬Ø²Ø§Ø¦Ø±)",
"ar-eg" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù…ØµØ±)",
"ar-eh" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ØµØ­Ø±Ø§Ø¡ Ø§Ù„ØºØ±Ø¨ÙŠØ©)",
"ar-er" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¥Ø±ÙŠØªØ±ÙŠØ§)",
"ar-il" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¥Ø³Ø±Ø§Ø¦ÙŠÙ„)",
"ar-iq" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¹Ø±Ø§Ù‚)",
"ar-jo" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø£Ø±Ø¯Ù†)",
"ar-km" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¬Ø²Ø± Ø§Ù„Ù‚Ù…Ø±)",
"ar-kw" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ÙƒÙˆÙŠØª)",
"ar-lb" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù„Ø¨Ù†Ø§Ù†)",
"ar-ly" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù„ÙŠØ¨ÙŠØ§)",
"ar-ma" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ù…ØºØ±Ø¨)",
"ar-mr" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù…ÙˆØ±ÙŠØªØ§Ù†ÙŠØ§)",
"ar-om" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¹Ù…Ø§Ù†)",
"ar-ps" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (ÙÙ„Ø³Ø·ÙŠÙ†)",
"ar-qa" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù‚Ø·Ø±)",
"ar-sa" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ù…Ù…Ù„ÙƒØ© Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© Ø§Ù„Ø³Ø¹ÙˆØ¯ÙŠØ©)",
"ar-sd" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø³ÙˆØ¯Ø§Ù†)",
"ar-so" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ØµÙˆÙ…Ø§Ù„)",
"ar-ss" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¬Ù†ÙˆØ¨ Ø§Ù„Ø³ÙˆØ¯Ø§Ù†)",
"ar-sy" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø³ÙˆØ±ÙŠØ§)",
"ar-td" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (ØªØ´Ø§Ø¯)",
"ar-tn" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (ØªÙˆÙ†Ø³)",
"ar-ye" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ÙŠÙ…Ù†)",
"as-in" => return "à¦…à¦¸à¦®à§€à¦¯à¦¼à¦¾ (à¦­à¦¾à§°à¦¤)",
"az-az" => return "AzÉ™rbaycan dili (AzÉ™rbaycan)",
"ba-ru" => return "Ð±Ð°ÑˆÒ¡Ð¾Ñ€Ñ‚ Ñ‚ÐµÐ»Ðµ (Ð Ð¾ÑÑÐ¸Ñ)",
"be-by" => return "Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÐºÐ°Ñ Ð¼Ð¾Ð²Ð° (Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÑŒ)",
"bg-bg" => return "Ð±ÑŠÐ»Ð³Ð°Ñ€ÑÐºÐ¸ ÐµÐ·Ð¸Ðº (Ð‘ÑŠÐ»Ð³Ð°Ñ€Ð¸Ñ)",
"bm-ml" => return "ß“ßŠß¡ßŠß£ßŠß£ßžßŠß£ (ßžßŠß²ßžßŠß²)",
"bn-bd" => return "à¦¬à¦¾à¦‚à¦²à¦¾ (à¦¬à¦¾à¦‚à¦²à¦¾à¦¦à§‡à¦¶)",
"bn-in" => return "à¦¬à¦¾à¦‚à¦²à¦¾ (à¦­à¦¾à¦°à¦¤)",
"bo-cn" => return "à½–à½¼à½‘à¼‹à½¦à¾à½‘à¼‹ (à½¢à¾’à¾±à¼‹à½“à½‚)",
"bo-in" => return "à½–à½¼à½‘à¼‹à½¦à¾à½‘à¼‹ (à½­à½²à¼‹à½à½²)",
"br-fr" => return "Brezhoneg (FraÃ±s)",
"bs-ba" => return "Bosanski (Bosna i Hercegovina)",
"ca-ad" => return "CatalÃ  (Andorra)",
"ca-es" => return "CatalÃ  (Espanya)",
"ca-fr" => return "CatalÃ  (FranÃ§a)",
"ca-it" => return "CatalÃ  (ItÃ lia)",
"ce-ru" => return "Ð½Ð¾Ñ…Ñ‡Ð¸Ð¹Ð½ Ð¼Ð¾Ñ‚Ñ‚ (Ð Ð¾ÑÑÐ¸)",
"co-fr" => return "Corsu (France)",
"cs-cz" => return "ÄŒeÅ¡tina (ÄŒeskÃ¡ republika)",
"cv-ru" => return "Ñ‡Ó‘Ð²Ð°Ñˆ Ñ‡Ó—Ð»Ñ…Ð¸ (Ð Ð¾ÑÑÐ¸)",
"cy-gb" => return "Cymraeg (Y Deyrnas Unedig)",
"da-dk" => return "Dansk (Danmark)",
"da-gl" => return "Dansk (GrÃ¸nland)",
"de-at" => return "Deutsch (Ã–sterreich)",
"de-be" => return "Deutsch (Belgien)",
"de-ch" => return "Deutsch (Schweiz)",
"de-de" => return "Deutsch (Deutschland)",
"de-it" => return "Deutsch (Italien)",
"de-li" => return "Deutsch (Liechtenstein)",
"de-lu" => return "Deutsch (Luxemburg)",
"dv-mv" => return "Þ‹Þ¨ÞˆÞ¬Þ€Þ¨ (Þ‹Þ¨ÞˆÞ¬Þ€Þ¨)",
"dz-bt" => return "à½¢à¾«à½¼à½„à¼‹à½à¼‹ (à½ à½–à¾²à½´à½‚à¼‹à½¡à½´à½£)",
"ee-gh" => return "EÊ‹egbe (Ghana)",
"ee-tg" => return "EÊ‹egbe (Togo)",
"el-cy" => return "ÎÎ­Î± Î•Î»Î»Î·Î½Î¹ÎºÎ¬ (ÎšÏÏ€ÏÎ¿Ï‚)",
"el-gr" => return "ÎÎ­Î± Î•Î»Î»Î·Î½Î¹ÎºÎ¬ (Î•Î»Î»Î¬Î´Î±)",
"en-ad" => return "English (Andorra)",
"en-ae" => return "English (United Arab Emirates)",
"en-ag" => return "English (Antigua and Barbuda)",
"en-ai" => return "English (Anguilla)",
"en-al" => return "English (Albania)",
"en-ar" => return "English (Argentina)",
"en-as" => return "English (American Samoa)",
"en-at" => return "English (Austria)",
"en-au" => return "English (Australia)",
"en-ba" => return "English (Bosnia and Herzegovina)",
"en-bb" => return "English (Barbados)",
"en-bd" => return "English (Bangladesh)",
"en-be" => return "English (Belgium)",
"en-bg" => return "English (Bulgaria)",
"en-bi" => return "English (Burundi)",
"en-bm" => return "English (Bermuda)",
"en-br" => return "English (Brazil)",
"en-bs" => return "English (Bahamas)",
"en-bw" => return "English (Botswana)",
"en-bz" => return "English (Belize)",
"en-ca" => return "English (Canada)",
"en-cc" => return "English (Cocos Islands)",
"en-ch" => return "English (Switzerland)",
"en-ck" => return "English (Cook Islands)",
"en-cl" => return "English (Chile)",
"en-cm" => return "English (Cameroon)",
"en-cn" => return "English (China)",
"en-co" => return "English (Colombia)",
"en-cx" => return "English (Christmas Island)",
"en-cy" => return "English (Cyprus)",
"en-cz" => return "English (Czech Republic)",
"en-de" => return "English (Germany)",
"en-dg" => return "English (Diego Garcia)",
"en-dk" => return "English (Denmark)",
"en-dm" => return "English (Dominica)",
"en-ee" => return "English (Estonia)",
"en-er" => return "English (Eritrea)",
"en-es" => return "English (Spain)",
"en-fi" => return "English (Finland)",
"en-fj" => return "English (Fiji)",
"en-fk" => return "English (Falkland Islands)",
"en-fm" => return "English (Micronesia)",
"en-fr" => return "English (France)",
"en-gb" => return "English (United Kingdom)",
"en-gd" => return "English (Grenada)",
"en-gg" => return "English (Guernsey)",
"en-gh" => return "English (Ghana)",
"en-gi" => return "English (Gibraltar)",
"en-gm" => return "English (Gambia)",
"en-gr" => return "English (Greece)",
"en-gu" => return "English (Guam)",
"en-gy" => return "English (Guyana)",
"en-hk" => return "English (Hong Kong)",
"en-hu" => return "English (Hungary)",
"en-hr" => return "English (Croatia)",
"en-id" => return "English (Indonesia)",
"en-ie" => return "English (Ireland)",
"en-il" => return "English (Israel)",
"en-im" => return "English (Isle of Man)",
"en-in" => return "English (India)",
"en-io" => return "English (British Indian Ocean Territory)",
"en-is" => return "English (Iceland)",
"en-it" => return "English (Italy)",
"en-je" => return "English (Jersey)",
"en-jm" => return "English (Jamaica)",
"en-jp" => return "English (Japan)",
"en-ke" => return "English (Kenya)",
"en-ki" => return "English (Kiribati)",
"en-kn" => return "English (Saint Kitts and Nevis)",
"en-kr" => return "English (South Korea)",
"en-ky" => return "English (Cayman Islands)",
"en-lc" => return "English (Saint Lucia)",
"en-lr" => return "English (Liberia)",
"en-ls" => return "English (Lesotho)",
"en-lt" => return "English (Lithuania)",
"en-lu" => return "English (Luxembourg)",
"en-lv" => return "English (Latvia)",
"en-me" => return "English (Montenegro)",
"en-mh" => return "English (Marshall Islands)",
"en-mg" => return "English (Madagascar)",
"en-mm" => return "English (Myanmar)",
"en-mp" => return "English (Northern Mariana Islands)",
"en-mo" => return "English (Macao)",
"en-ms" => return "English (Montserrat)",
"en-mt" => return "English (Malta)",
"en-mu" => return "English (Mauritius)",
"en-mv" => return "English (Maldives)",
"en-mw" => return "English (Malawi)",
"en-mx" => return "English (Mexico)",
"en-my" => return "English (Malaysia)",
"en-na" => return "English (Namibia)",
"en-nf" => return "English (Norfolk Island)",
"en-ng" => return "English (Nigeria)",
"en-nl" => return "English (Netherlands)",
"en-no" => return "English (Norway)",
"en-nr" => return "English (Nauru)",
"en-nu" => return "English (Niue)",
"en-nz" => return "English (New Zealand)",
"en-pg" => return "English (Papua New Guinea)",
"en-ph" => return "English (Philippines)",
"en-pk" => return "English (Pakistan)",
"en-pl" => return "English (Poland)",
"en-pn" => return "English (Pitcairn Islands)",
"en-pr" => return "English (Puerto Rico)",
"en-pt" => return "English (Portugal)",
"en-pw" => return "English (Palau)",
"en-ro" => return "English (Romania)",
"en-rs" => return "English (Serbia)",
"en-ru" => return "English (Russia)",
"en-rw" => return "English (Rwanda)",
"en-sa" => return "English (Saudi Arabia)",
"en-sb" => return "English (Solomon Islands)",
"en-sc" => return "English (Seychelles)",
"en-sd" => return "English (Sudan)",
"en-se" => return "English (Sweden)",
"en-sg" => return "English (Singapore)",
"en-sh" => return "English (Saint Helena)",
"en-si" => return "English (Slovenia)",
"en-sk" => return "English (Slovakia)",
"en-sl" => return "English (Sierra Leone)",
"en-ss" => return "English (South Sudan)",
"en-sx" => return "English (Sint Maarten)",
"en-sz" => return "English (Swaziland)",
"en-tc" => return "English (Turks and Caicos Islands)",
"en-th" => return "English (Thailand)",
"en-tk" => return "English (Tokelau)",
"en-to" => return "English (Tonga)",
"en-tr" => return "English (Turkey)",
"en-tt" => return "English (Trinidad and Tobago)",
"en-tv" => return "English (Tuvalu)",
"en-tw" => return "English (Taiwan)",
"en-tz" => return "English (Tanzania)",
"en-ua" => return "English (Ukraine)",
"en-ug" => return "English (Uganda)",
"en-um" => return "English (United States Minor Outlying Islands)",
"en-us" => return "English (United States)",
"en-vc" => return "English (Saint Vincent and the Grenadines)",
"en-vg" => return "English (British Virgin Islands)",
"en-vi" => return "English (U.S. Virgin Islands)",
"en-vu" => return "English (Vanuatu)",
"en-ws" => return "English (Samoa)",
"en-za" => return "English (South Africa)",
"en-zm" => return "English (Zambia)",
"en-zw" => return "English (Zimbabwe)",
"es-ag" => return "EspaÃ±ol (Antigua y Barbuda)",
"es-ai" => return "EspaÃ±ol (Anguilla)",
"es-ar" => return "EspaÃ±ol (Argentina)",
"es-aw" => return "EspaÃ±ol (Aruba)",
"es-bb" => return "EspaÃ±ol (Barbados)",
"es-bl" => return "EspaÃ±ol (Saint BarthÃ©lemy)",
"es-bm" => return "EspaÃ±ol (Bermuda)",
"es-bo" => return "EspaÃ±ol (Bolivia)",
"es-bq" => return "EspaÃ±ol (Caribe holandÃ©s)",
"es-br" => return "EspaÃ±ol (Brasil)",
"es-bs" => return "EspaÃ±ol (Bahamas)",
"es-bz" => return "EspaÃ±ol (Belice)",
"es-ca" => return "EspaÃ±ol (CanadÃ¡)",
"es-cl" => return "EspaÃ±ol (Chile)",
"es-co" => return "EspaÃ±ol (Colombia)",
"es-cu" => return "EspaÃ±ol (Cuba)",
"es-cr" => return "EspaÃ±ol (Costa Rica)",
"es-cw" => return "EspaÃ±ol (CuraÃ§ao)",
"es-dm" => return "EspaÃ±ol (Dominica)",
"es-do" => return "EspaÃ±ol (RepÃºblica Dominicana)",
"es-ea" => return "EspaÃ±ol (Ceuta y Melilla)",
"es-fk" => return "EspaÃ±ol (Islas Malvinas)",
"es-gd" => return "EspaÃ±ol (Granada)",
"es-ec" => return "EspaÃ±ol (Ecuador)",
"es-es" => return "EspaÃ±ol (EspaÃ±a)",
"es-gf" => return "EspaÃ±ol (Guayana francesa)",
"es-gl" => return "EspaÃ±ol (Groenlandia)",
"es-gp" => return "EspaÃ±ol (Guadalupe)",
"es-gq" => return "EspaÃ±ol (Guinea Ecuatorial)",
"es-gt" => return "EspaÃ±ol (Guatemala)",
"es-gy" => return "EspaÃ±ol (Guayana)",
"es-hn" => return "EspaÃ±ol (Honduras)",
"es-ht" => return "EspaÃ±ol (HaitÃ­)",
"es-ic" => return "EspaÃ±ol (Islas Canarias)",
"es-kn" => return "EspaÃ±ol (San CristÃ³bal y Nieves)",
"es-ky" => return "EspaÃ±ol (Islas CaimÃ¡n)",
"es-lc" => return "EspaÃ±ol (Santa LucÃ­a)",
"es-mf" => return "EspaÃ±ol (San MartÃ­n)",
"es-mq" => return "EspaÃ±ol (Martinica)",
"es-ms" => return "EspaÃ±ol (Montserrat)",
"es-mx" => return "EspaÃ±ol (MÃ©xico)",
"es-ni" => return "EspaÃ±ol (Nicaragua)",
"es-pa" => return "EspaÃ±ol (PanamÃ¡)",
"es-pe" => return "EspaÃ±ol (PerÃº)",
"es-ph" => return "EspaÃ±ol (Filipinas)",
"es-pm" => return "EspaÃ±ol (San Pedro y MiquelÃ³n)",
"es-pr" => return "EspaÃ±ol (Puerto Rico)",
"es-py" => return "EspaÃ±ol (Paraguay)",
"es-sr" => return "EspaÃ±ol (Surinam)",
"es-sv" => return "EspaÃ±ol (El Salvador)",
"es-sx" => return "EspaÃ±ol (San MartÃ­n)",
"es-tc" => return "EspaÃ±ol (Islas Turcas y Caicos)",
"es-tt" => return "EspaÃ±ol (Trinidad y Tobago)",
"es-us" => return "EspaÃ±ol (Estados Unidos)",
"es-uy" => return "EspaÃ±ol (Uruguay)",
"es-vc" => return "EspaÃ±ol (San Vicente y las Granadinas)",
"es-ve" => return "EspaÃ±ol (Venezuela)",
"es-vg" => return "EspaÃ±ol (Islas VÃ­rgenes BritÃ¡nicas)",
"es-vi" => return "EspaÃ±ol (Islas VÃ­rgenes de los Estados Unidos)",
"et-ee" => return "Eesti (Eesti)",
"eu-es" => return "Euskara (Espainia)",
"fa-af" => return "ÙØ§Ø±Ø³ÛŒ (Ø§ÙØºØ§Ù†Ø³ØªØ§Ù†)",
"fa-ir" => return "ÙØ§Ø±Ø³ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"ff-bf" => return "Fulfulde (Burkina Faso)",
"ff-cm" => return "Fulfulde (Cameroun)",
"ff-gh" => return "Fulfulde (Ghana)",
"ff-gm" => return "Fulfulde (Gambia)",
"ff-gn" => return "Fulfulde (GuinÃ©e)",
"ff-gw" => return "Fulfulde (GuinÃ©e-Bissau)",
"ff-mr" => return "Fulfulde (Mauritanie)",
"ff-ne" => return "Fulfulde (Niger)",
"ff-ng" => return "Fulfulde (Nigeria)",
"ff-lr" => return "Fulfulde (LibÃ©ria)",
"ff-sl" => return "Fulfulde (Sierra Leone)",
"ff-sn" => return "Fulfulde (SÃ©nÃ©gal)",
"fi-fi" => return "suomi (Suomi)",
"fo-dk" => return "FÃ¸royskt (Danmark)",
"fo-fo" => return "FÃ¸royskt (FÃ¸royar)",
"fr-be" => return "FranÃ§ais (Belgique)",
"fr-bf" => return "FranÃ§ais (Burkina Faso)",
"fr-bi" => return "FranÃ§ais (Burundi)",
"fr-bj" => return "FranÃ§ais (BÃ©nin)",
"fr-bl" => return "FranÃ§ais (Saint-BarthÃ©lemy)",
"fr-ca" => return "FranÃ§ais (Canada)",
"fr-cd" => return "FranÃ§ais (Congo)",
"fr-cf" => return "FranÃ§ais (RÃ©publique centrafricaine)",
"fr-cg" => return "FranÃ§ais (Congo)",
"fr-ch" => return "FranÃ§ais (Suisse)",
"fr-ci" => return "FranÃ§ais (CÃ´te d'Ivoire)",
"fr-cm" => return "FranÃ§ais (Cameroun)",
"fr-dj" => return "FranÃ§ais (Djibouti)",
"fr-dz" => return "FranÃ§ais (AlgÃ©rie)",
"fr-fr" => return "FranÃ§ais (France)",
"fr-ga" => return "FranÃ§ais (Gabon)",
"fr-gf" => return "FranÃ§ais (Guyane franÃ§aise)",
"fr-gn" => return "FranÃ§ais (GuinÃ©e)",
"fr-gp" => return "FranÃ§ais (Guadeloupe)",
"fr-gq" => return "FranÃ§ais (GuinÃ©e Ã©quatoriale)",
"fr-ht" => return "FranÃ§ais (HaÃ¯ti)",
"fr-km" => return "FranÃ§ais (Comores)",
"fr-ma" => return "FranÃ§ais (Maroc)",
"fr-mc" => return "FranÃ§ais (Monaco)",
"fr-mf" => return "FranÃ§ais (Saint-Martin)",
"fr-nc" => return "FranÃ§ais (Nouvelle-CalÃ©donie)",
"fr-ne" => return "FranÃ§ais (Niger)",
"fr-lu" => return "FranÃ§ais (Luxembourg)",
"fr-mg" => return "FranÃ§ais (Madagascar)",
"fr-ml" => return "FranÃ§ais (Mali)",
"fr-mq" => return "FranÃ§ais (Martinique)",
"fr-mr" => return "FranÃ§ais (Mauritanie)",
"fr-mu" => return "FranÃ§ais (Maurice)",
"fr-pf" => return "FranÃ§ais (PolynÃ©sie franÃ§aise)",
"fr-pm" => return "FranÃ§ais (Saint-Pierre-et-Miquelon)",
"fr-re" => return "FranÃ§ais (RÃ©union)",
"fr-rw" => return "FranÃ§ais (Rwanda)",
"fr-sc" => return "FranÃ§ais (Seychelles)",
"fr-sn" => return "FranÃ§ais (SÃ©nÃ©gal)",
"fr-sy" => return "FranÃ§ais (Syrie)",
"fr-td" => return "FranÃ§ais (Tchad)",
"fr-tg" => return "FranÃ§ais (Togo)",
"fr-tn" => return "FranÃ§ais (Tunisie)",
"fr-vu" => return "FranÃ§ais (Vanuatu)",
"fr-wf" => return "FranÃ§ais (Wallis-et-Futuna)",
"fr-yt" => return "FranÃ§ais (Mayotte)",
"fy-nl" => return "Frysk (NederlÃ¢n)",
"ga-ie" => return "Gaeilge (Ã‰ire)",
"gd-gb" => return "GÃ idhlig (An RÃ¬oghachd Aonaichte)",
"gl-es" => return "Galego (EspaÃ±a)",
"gn-py" => return "AvaÃ±e'áº½ (ParaguÃ¡i)",
"gu-in" => return "àª—à«àªœàª°àª¾àª¤à«€ (àª­àª¾àª°àª¤)",
"gv-im" => return "Gaelg (Ellan Vannin)",
"ha-gh" => return "Hausa (Ghana)",
"ha-ne" => return "Hausa (Nijar)",
"ha-ng" => return "Hausa (Najeriya)",
"he-il" => return "×¢×‘×¨×™×ª (×™×©×¨××œ)",
"hi-in" => return "à¤¹à¤¿à¤¨à¥à¤¦à¥€ (à¤­à¤¾à¤°à¤¤)",
"hr-ba" => return "Hrvatski (Bosna i Hercegovina)",
"hr-hr" => return "Hrvatski (Hrvatska)",
"hu-hu" => return "Magyar (MagyarorszÃ¡g)",
"hy-am" => return "Õ€Õ¡ÕµÕ¥Ö€Õ§Õ¶ (Õ€Õ¡ÕµÕ¡Õ½Õ¿Õ¡Õ¶)",
"id-id" => return "Bahasa Indonesia (Indonesia)",
"ig-ng" => return "Igbo (Nigeria)",
"ii-cn" => return "ê†ˆêŒ ê‰™ (ä¸­å›½)",
"is-is" => return "Ãslenska (Ãsland)",
"it-ch" => return "Italiano (Svizzera)",
"it-it" => return "Italiano (Italia)",
"it-sm" => return "Italiano (San Marino)",
"it-va" => return "Italiano (CittÃ  del Vaticano)",
"iu-ca" => return "áƒá“„á’ƒá‘Žá‘á‘¦ (Canada)",
"ja-jp" => return "æ—¥æœ¬èªž (æ—¥æœ¬)",
"jv-id" => return "ê¦§ê¦±ê¦—ê¦® (Indonesia)", // TODO: check this
"ka-ge" => return "áƒ¥áƒáƒ áƒ—áƒ£áƒšáƒ˜ (áƒ¡áƒáƒ¥áƒáƒ áƒ—áƒ•áƒ”áƒšáƒ)",
"ki-ke" => return "GÄ©kÅ©yÅ© (Kenya)",
"kk-kz" => return "ÒšÐ°Ð·Ð°Ò› Ñ‚Ñ–Ð»Ñ– (ÒšÐ°Ð·Ð°Ò›ÑÑ‚Ð°Ð½)",
"kl-gl" => return "Kalaallisut (Kalaallit Nunaat)",
"km-kh" => return "áž—áž¶ážŸáž¶ážáŸ’áž˜áŸ‚ážš (áž€áž˜áŸ’áž–áž»áž‡áž¶)",
"kn-in" => return "à²•à²¨à³à²¨à²¡ (à²­à²¾à²°à²¤)",
"ko-kp" => return "í•œêµ­ì–´(ë¶í•œ)",
"ks-in" => return "à¤•à¤¶à¥à¤®à¥€à¤°à¥€ (à¤­à¤¾à¤°à¤¤)",
"ku-tr" => return "KurdÃ® (Tirkiye)",
"kw-gb" => return "Cornish (United Kingdom)",
"ky-kg" => return "ÐšÑ‹Ñ€Ð³Ñ‹Ð·ÑÑ‚Ð°Ð½Ð´Ñ‹Ðº (ÐšÑ‹Ñ€Ð³Ñ‹Ð·ÑÑ‚Ð°Ð½)",
"lb-lu" => return "LÃ«tzebuergesch (LÃ«tzebuerg)",
"lg-ug" => return "Luganda (Yuganda)", // TODO: check this
"ln-ao" => return "LingÃ¡la (Angola)",  // TODO: check this
"ln-cf" => return "LingÃ¡la (RÃ©publique centrafricaine)", // TODO: check this
"ln-cg" => return "LingÃ¡la (Congo)", // TODO: check this
"lo-la" => return "àºžàº²àºªàº²àº¥àº²àº§ (àº¥àº²àº§)",
"lt-lt" => return "LietuviÅ³ kalba (Lietuva)",
"lu-cd" => return "Kiluba (Congo)",
"lv-lv" => return "LatvieÅ¡u valoda (Latvija)",
"mg-mg" => return "Malagasy (Madagascar)",
"mi-nz" => return "MÄori (Aotearoa)",
"mk-mk" => return "ÐœÐ°ÐºÐµÐ´Ð¾Ð½ÑÐºÐ¸ (ÐœÐ°ÐºÐµÐ´Ð¾Ð½Ð¸Ñ˜Ð°)",
"ml-in" => return "à´®à´²à´¯à´¾à´³à´‚ (à´­à´¾à´°à´¤à´‚)",
"mn-mn" => return "ÐœÐ¾Ð½Ð³Ð¾Ð» Ñ…ÑÐ» (ÐœÐ¾Ð½Ð³Ð¾Ð»)",
"mr-in" => return "à¤®à¤°à¤¾à¤ à¥€ (à¤­à¤¾à¤°à¤¤)",
"ms-bn" => return "Bahasa Melayu (Brunei)",
"ms-my" => return "Bahasa Melayu (Malaysia)",
"ms-sg" => return "Bahasa Melayu (Singapura)",
"mt-mt" => return "Malti (Malta)",
"my-mm" => return "á€—á€™á€¬á€…á€¬ (á€™á€¼á€”á€ºá€™á€¬)",
"nb-no" => return "Norsk bokmÃ¥l (Norge)",
"nb-sj" => return "Norsk bokmÃ¥l (Svalbard og Jan Mayen)",
"nd-zw" => return "isiNdebele (Zimbabwe)",
"ne-in" => return "à¤¨à¥‡à¤ªà¤¾à¤²à¥€ (à¤­à¤¾à¤°à¤¤)",
"ne-np" => return "à¤¨à¥‡à¤ªà¤¾à¤²à¥€ (à¤¨à¥‡à¤ªà¤¾à¤²)",
"nl-aw" => return "Nederlands (Aruba)",
"nl-be" => return "Nederlands (BelgiÃ«)",
"nl-bq" => return "Nederlands (Caribisch Nederland)",
"nl-cw" => return "Nederlands (CuraÃ§ao)",
"nl-nl" => return "Nederlands (Nederland)",
"nl-sr" => return "Nederlands (Suriname)",
"nl-sx" => return "Nederlands (Sint Maarten)",
"nn-no" => return "Norsk nynorsk (Noreg)",
"nr-za" => return "isiNdebele (South Africa)",
"ny-mw" => return "Chichewa (Malawi)",
"oc-fr" => return "Occitan (France)",
"os-ge" => return "Ð˜Ñ€Ð¾Ð½ Ã¦Ð²Ð·Ð°Ð³ (Ð Ð¾ÑÑÐ¸)",
"om-et" => return "Afaan Oromoo (Itoophiyaa)",
"om-ke" => return "Afaan Oromoo (Keeniyaa)",
"or-in" => return "à¬“à¬¡à¬¼à¬¿à¬† (à¬­à¬¾à¬°à¬¤)",
"os-ru" => return "Ð˜Ñ€Ð¾Ð½ Ã¦Ð²Ð·Ð°Ð³ (Ð Ð¾ÑÑÐ¸)",
"pa-in" => return "à¨ªà©°à¨œà¨¾à¨¬à©€ (à¨­à¨¾à¨°à¨¤)",
"pa-pk" => return "Ù¾Ù†Ø¬Ø§Ø¨ÛŒ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"pl-pl" => return "Polski (Polska)",
"ps-af" => return "Ù¾ÚšØªÙˆ (Ø§ÙØºØ§Ù†Ø³ØªØ§Ù†)",
"ps-pk" => return "Ù¾ÚšØªÙˆ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"pt-ao" => return "PortuguÃªs (Angola)",
"pt-br" => return "PortuguÃªs (Brasil)",
"pt-ch" => return "PortuguÃªs (SuÃ­Ã§a)",
"pt-cv" => return "PortuguÃªs (Cabo Verde)",
"pt-fr" => return "PortuguÃªs (FranÃ§a)",
"pt-gq" => return "PortuguÃªs (GuinÃ© Equatorial)",
"pt-gw" => return "PortuguÃªs (GuinÃ©-Bissau)",
"pt-mz" => return "PortuguÃªs (MoÃ§ambique)",
"pt-lu" => return "PortuguÃªs (Luxemburgo)",
"pt-mo" => return "PortuguÃªs (Macau)",
"pt-pt" => return "PortuguÃªs (Portugal)",
"pt-st" => return "PortuguÃªs (SÃ£o TomÃ© e PrÃ­ncipe)",
"pt-tl" => return "PortuguÃªs (Timor-Leste)",
"qu-bo" => return "Runa simi (Bolivia)",
"qu-ec" => return "Runa simi (Ecuador)",
"qu-pe" => return "Runa simi (PerÃº)",
"rn-bi" => return "Ikirundi (Burundi)",
"ro-md" => return "RomÃ¢nÄƒ (Republica Moldova)",
"ro-ro" => return "RomÃ¢nÄƒ (RomÃ¢nia)",
"ru-by" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÑŒ)",
"ru-kg" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (ÐšÐ¸Ñ€Ð³Ð¸Ð·Ð¸Ñ)",
"ru-kz" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (ÐšÐ°Ð·Ð°Ñ…ÑÑ‚Ð°Ð½)",
"ru-md" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (ÐœÐ¾Ð»Ð´Ð¾Ð²Ð°)",
"ru-ru" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (Ð Ð¾ÑÑÐ¸Ñ)",
"ru-ua" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (Ð£ÐºÑ€Ð°Ð¸Ð½Ð°)",
"rw-rw" => return "Kinyarwanda (Rwanda)",
"sa-in" => return "à¤¸à¤‚à¤¸à¥à¤•à¥ƒà¤¤à¤®à¥ (à¤­à¤¾à¤°à¤¤à¤ƒ)",
"sa-it" => return "à¤¸à¤‚à¤¸à¥à¤•à¥ƒà¤¤à¤®à¥ (à¤‡à¤Ÿà¤²à¥€)",
"sd-pk" => return "Ø³Ù†ÚŒÙŠ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"se-fi" => return "DavvisÃ¡megiella (Suopma)",
"se-no" => return "DavvisÃ¡megiella (Norga)",
"se-se" => return "DavvisÃ¡megiella (RuoÅ§Å§a)",
"sg-cf" => return "SÃ¤ngÃ¶ (RÃ©publique centrafricaine)",
"si-lk" => return "à·ƒà·’à¶‚à·„à¶½ (à·à·Šâ€à¶»à·“ à¶½à¶‚à¶šà·)",
"sk-sk" => return "SlovenÄina (SlovenskÃ¡ republika)",
"sl-si" => return "SlovenÅ¡Äina (Slovenija)",
"sn-zw" => return "chiShona (Zimbabwe)",
"so-et" => return "Soomaaliga (Itoobiya)",
"so-ke" => return "Soomaaliga (Kenya)",
"so-so" => return "Soomaaliga (Soomaaliya)",
"sq-al" => return "Shqip (ShqipÃ«ri)",
"sq-mk" => return "Shqip (Maqedoni)",
"sq-xk" => return "Shqip (KosovÃ«)",
"sr-ba" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‘Ð¾ÑÐ½Ð° Ð¸ Ð¥ÐµÑ€Ñ†ÐµÐ³Ð¾Ð²Ð¸Ð½Ð°)",
"sr-me" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð¦Ñ€Ð½Ð° Ð“Ð¾Ñ€Ð°)",
"sr-rs" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð¡Ñ€Ð±Ð¸Ñ˜Ð°)",
"sr-xk" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (ÐšÐ¾ÑÐ¾Ð²Ð¾)",
"ss-sz" => return "SiSwati (Swaziland)",
"ss-za" => return "SiSwati (South Africa)",
"st-ls" => return "Sesotho (Lesotho)",
"st-za" => return "Sesotho (South Africa)",
"sv-ax" => return "Svenska (Ã…land)",
"sv-fi" => return "Svenska (Finland)",
"sw-cd" => return "Kiswahili (Jamhuri ya Kidemokrasia ya Kongo)",
"sw-ke" => return "Kiswahili (Kenya)",
"sw-tz" => return "Kiswahili (Tanzania)",
"sw-ug" => return "Kiswahili (Uganda)",
"ta-in" => return "à®¤à®®à®¿à®´à¯ (à®‡à®¨à¯à®¤à®¿à®¯à®¾)",
"ta-lk" => return "à®¤à®®à®¿à®´à¯ (à®‡à®²à®™à¯à®•à¯ˆ)",
"ta-my" => return "à®¤à®®à®¿à®´à¯ (à®®à®²à¯‡à®šà®¿à®¯à®¾)",
"ta-sg" => return "à®¤à®®à®¿à®´à¯ (à®šà®¿à®™à¯à®•à®ªà¯à®ªà¯‚à®°à¯)",
"te-in" => return "à°¤à±†à°²à±à°—à± (à°­à°¾à°°à°¤)",
"tg-tj" => return "Ñ‚Ð¾Ò·Ð¸ÐºÓ£ (Ð¢Ð¾Ò·Ð¸ÐºÐ¸ÑÑ‚Ð¾Ð½)",
"th-th" => return "à¹„à¸—à¸¢ (à¹„à¸—à¸¢)",
"ti-er" => return "á‰µáŒáˆ­áŠ› (áŠ¤áˆ­á‰µáˆ«)",
"ti-et" => return "á‰µáŒáˆ­áŠ› (áŠ¢á‰µá‹®áŒµá‹«)",
"tk-tm" => return "TÃ¼rkmenÃ§e (TÃ¼rkmenistan)",
"tn-bw" => return "Setswana (Botswana)",
"tn-za" => return "Setswana (South Africa)",
"to-to" => return "faka Tonga (Tonga)",
"tr-cy" => return "TÃ¼rkÃ§e (KÄ±brÄ±s)",
"tr-tr" => return "TÃ¼rkÃ§e (TÃ¼rkiye)",
"ts-za" => return "Xitsonga (South Africa)",
"tt-ru" => return "Ð¢Ð°Ñ‚Ð°Ñ€ Ñ‚ÐµÐ»Ðµ (Ð Ð¾ÑÑÐ¸Ñ)",
"ug-cn" => return "Ø¦Û‡ÙŠØºÛ‡Ø±Ú†Û• (Ø¬Û‡Ú­Ú¯Ùˆ)",
"uk-ua" => return "Ð£ÐºÑ€Ð°Ñ—Ð½ÑÑŒÐºÐ° (Ð£ÐºÑ€Ð°Ñ—Ð½Ð°)",
"ur-in" => return "Ø§Ø±Ø¯Ùˆ (Ø¨Ú¾Ø§Ø±Øª)",
"ur-pk" => return "Ø§Ø±Ø¯Ùˆ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"uz-af" => return "O'zbekiston (Afg'oniston)",
"uz-uz" => return "O'zbekiston (O'zbekiston)",
"ve-za" => return "Tshivená¸“a (South Africa)",
"vi-vn" => return "Tiáº¿ng Viá»‡t (Viá»‡t Nam)",
"wa-be" => return "Walon (Belgique)",
"wo-sn" => return "Wolof (SÃ©nÃ©gal)", // TODO: Check this, seems French
"xh-za" => return "isiXhosa (South Africa)",
"yo-bj" => return "YorÃ¹bÃ¡ (BÃ©nin)",
"yo-ng" => return "YorÃ¹bÃ¡ (NÃ Ã¬jÃ­rÃ­Ã )",
"zh-cn" => return "ä¸­æ–‡ (ç®€ä½“)",
"zh-hk" => return "ä¸­æ–‡ (é¦™æ¸¯)",
"zh-mo" => return "ä¸­æ–‡ (æ¾³é–€)",
"zh-sg" => return "ä¸­æ–‡ (æ–°åŠ å¡)",
"zh-tw" => return "ä¸­æ–‡ (ç¹é«”)",
"zu-za" => return "isiZulu (South Africa)",

// lang (2 letter) -> country (3 letter)
"af-nam" => return "Afrikaans (Namibia)",
"af-zaf" => return "Afrikaans (South Africa)",
"ak-gha" => return "Akan (Ghana)",
"am-eth" => return "áŠ áˆ›áˆ­áŠ› (áŠ¢á‰µá‹®áŒµá‹«)",
"ar-001" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©",
"ar-are" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¥Ù…Ø§Ø±Ø§Øª Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© Ø§Ù„Ù…ØªØ­Ø¯Ø©)",
"ar-bhr" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¨Ø­Ø±ÙŠÙ†)",
"ar-com" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¬Ø²Ø± Ø§Ù„Ù‚Ù…Ø±)",
"ar-dji" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¬ÙŠØ¨ÙˆØªÙŠ)",
"ar-dza" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¬Ø²Ø§Ø¦Ø±)",
"ar-egy" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù…ØµØ±)",
"ar-eri" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¥Ø±ÙŠØªØ±ÙŠØ§)",
"ar-esh" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ØµØ­Ø±Ø§Ø¡ Ø§Ù„ØºØ±Ø¨ÙŠØ©)",
"ar-irq" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø¹Ø±Ø§Ù‚)",
"ar-isr" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¥Ø³Ø±Ø§Ø¦ÙŠÙ„)",
"ar-jor" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø£Ø±Ø¯Ù†)",
"ar-kwt" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ÙƒÙˆÙŠØª)",
"ar-lbn" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù„Ø¨Ù†Ø§Ù†)",
"ar-lby" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù„ÙŠØ¨ÙŠØ§)",
"ar-mar" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ù…ØºØ±Ø¨)",
"ar-mrt" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù…ÙˆØ±ÙŠØªØ§Ù†ÙŠØ§)",
"ar-omn" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¹Ù…Ø§Ù†)",
"ar-pse" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (ÙÙ„Ø³Ø·ÙŠÙ†)",
"ar-qat" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ù‚Ø·Ø±)",
"ar-sau" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ù…Ù…Ù„ÙƒØ© Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© Ø§Ù„Ø³Ø¹ÙˆØ¯ÙŠØ©)",
"ar-sdn" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„Ø³ÙˆØ¯Ø§Ù†)",
"ar-som" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø§Ù„ØµÙˆÙ…Ø§Ù„)",
"ar-ssd" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø¬Ù†ÙˆØ¨ Ø§Ù„Ø³ÙˆØ¯Ø§Ù†)",
"ar-syr" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (Ø³ÙˆØ±ÙŠØ§)",
"ar-tcd" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (ØªØ´Ø§Ø¯)",
"ar-tun" => return "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ© (ØªÙˆÙ†Ø³)",
"as-ind" => return "à¦…à¦¸à¦®à§€à¦¯à¦¼à¦¾ (à¦­à¦¾à§°à¦¤)",
"az-aze" => return "AzÉ™rbaycan dili (AzÉ™rbaycan)",
"ba-rus" => return "Ð±Ð°ÑˆÒ¡Ð¾Ñ€Ñ‚ Ñ‚ÐµÐ»Ðµ (Ð Ð¾ÑÑÐ¸Ñ)",
"be-blr" => return "Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÐºÐ°Ñ Ð¼Ð¾Ð²Ð° (Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÑŒ)",
"bg-bgr" => return "Ð±ÑŠÐ»Ð³Ð°Ñ€ÑÐºÐ¸ ÐµÐ·Ð¸Ðº (Ð‘ÑŠÐ»Ð³Ð°Ñ€Ð¸Ñ)",
"bm-mli" => return "ß“ßŠß¡ßŠß£ßŠß£ßžßŠß£ (ßžßŠß²ßžßŠß²)",
"bn-bgd" => return "à¦¬à¦¾à¦‚à¦²à¦¾ (à¦¬à¦¾à¦‚à¦²à¦¾à¦¦à§‡à¦¶)",
"bn-ind" => return "à¦¬à¦¾à¦‚à¦²à¦¾ (à¦­à¦¾à¦°à¦¤)",
"bo-chn" => return "à½–à½¼à½‘à¼‹à½¦à¾à½‘à¼‹ (à½¢à¾’à¾±à¼‹à½“à½‚)",
"bo-ind" => return "à½–à½¼à½‘à¼‹à½¦à¾à½‘à¼‹ (à½­à½²à¼‹à½à½²)",
"br-fra" => return "Brezhoneg (FraÃ±s)",
"bs-bih" => return "Bosanski (Bosna i Hercegovina)",
"ca-and" => return "CatalÃ  (Andorra)",
"ca-esp" => return "CatalÃ  (Espanya)",
"ca-fra" => return "CatalÃ  (FranÃ§a)",
"ca-ita" => return "CatalÃ  (ItÃ lia)",
"ce-rus" => return "Ð½Ð¾Ñ…Ñ‡Ð¸Ð¹Ð½ Ð¼Ð¾Ñ‚Ñ‚ (Ð Ð¾ÑÑÐ¸)",
"co-fra" => return "Corsu (France)",
"cs-cze" => return "ÄŒeÅ¡tina (ÄŒeskÃ¡ republika)",
"cv-rus" => return "Ñ‡Ó‘Ð²Ð°Ñˆ Ñ‡Ó—Ð»Ñ…Ð¸ (Ð Ð¾ÑÑÐ¸)",
"cy-gbr" => return "Cymraeg (Y Deyrnas Unedig)",
"da-dnk" => return "Dansk (Danmark)",
"da-grl" => return "Dansk (GrÃ¸nland)",
"de-aut" => return "Deutsch (Ã–sterreich)",
"de-bel" => return "Deutsch (Belgien)",
"de-che" => return "Deutsch (Schweiz)",
"de-deu" => return "Deutsch (Deutschland)",
"de-ita" => return "Deutsch (Italien)",
"de-lie" => return "Deutsch (Liechtenstein)",
"de-lux" => return "Deutsch (Luxemburg)",
"dv-mdv" => return "Þ‹Þ¨ÞˆÞ¬Þ€Þ¨ (Þ‹Þ¨ÞˆÞ¬Þ€Þ¨)",
"dz-btn" => return "à½¢à¾«à½¼à½„à¼‹à½à¼‹ (à½ à½–à¾²à½´à½‚à¼‹à½¡à½´à½£)",
"ee-gha" => return "EÊ‹egbe (Ghana)",
"ee-tgo" => return "EÊ‹egbe (Togo)",
"el-cyp" => return "ÎÎ­Î± Î•Î»Î»Î·Î½Î¹ÎºÎ¬ (ÎšÏÏ€ÏÎ¿Ï‚)",
"el-grc" => return "ÎÎ­Î± Î•Î»Î»Î·Î½Î¹ÎºÎ¬ (Î•Î»Î»Î¬Î´Î±)",
"en-001" => return "English",
"en-150" => return "English (Europe)",
"en-aia" => return "English (Anguilla)",
"en-alb" => return "English (Albania)",
"en-and" => return "English (Andorra)",
"en-are" => return "English (United Arab Emirates)",
"en-arg" => return "English (Argentina)",
"en-asm" => return "English (American Samoa)",
"en-atg" => return "English (Antigua and Barbuda)",
"en-aus" => return "English (Australia)",
"en-aut" => return "English (Austria)",
"en-bdi" => return "English (Burundi)",
"en-bel" => return "English (Belgium)",
"en-bgd" => return "English (Bangladesh)",
"en-bgr" => return "English (Bulgaria)",
"en-bhs" => return "English (Bahamas)",
"en-bih" => return "English (Bosnia and Herzegovina)",
"en-bmu" => return "English (Bermuda)",
"en-blz" => return "English (Belize)",
"en-bra" => return "English (Brazil)",
"en-brb" => return "English (Barbados)",
"en-bwa" => return "English (Botswana)",
"en-can" => return "English (Canada)",
"en-cck" => return "English (Cocos Islands)",
"en-che" => return "English (Switzerland)",
"en-chl" => return "English (Chile)",
"en-chn" => return "English (China)",
"en-cmr" => return "English (Cameroon)",
"en-cok" => return "English (Cook Islands)",
"en-col" => return "English (Colombia)",
"en-cxr" => return "English (Christmas Island)",
"en-cym" => return "English (Cayman Islands)",
"en-cyp" => return "English (Cyprus)",
"en-cze" => return "English (Czech Republic)",
"en-deu" => return "English (Germany)",
"en-dga" => return "English (Diego Garcia)",
"en-dma" => return "English (Dominica)",
"en-dnk" => return "English (Denmark)",
"en-esp" => return "English (Spain)",
"en-fin" => return "English (Finland)",
"en-eri" => return "English (Eritrea)",
"en-est" => return "English (Estonia)",
"en-fji" => return "English (Fiji)",
"en-flk" => return "English (Falkland Islands)",
"en-fra" => return "English (France)",
"en-fsm" => return "English (Micronesia)",
"en-gbr" => return "English (United Kingdom)",
"en-ggy" => return "English (Guernsey)",
"en-gha" => return "English (Ghana)",
"en-gib" => return "English (Gibraltar)",
"en-gmb" => return "English (Gambia)",
"en-grc" => return "English (Greece)",
"en-grd" => return "English (Grenada)",
"en-gum" => return "English (Guam)",
"en-guy" => return "English (Guyana)",
"en-hkg" => return "English (Hong Kong)",
"en-hrv" => return "English (Croatia)",
"en-hun" => return "English (Hungary)",
"en-imn" => return "English (Isle of Man)",
"en-idn" => return "English (Indonesia)",
"en-ind" => return "English (India)",
"en-iot" => return "English (British Indian Ocean Territory)",
"en-irl" => return "English (Ireland)",
"en-isl" => return "English (Iceland)",
"en-isr" => return "English (Israel)",
"en-ita" => return "English (Italy)",
"en-jam" => return "English (Jamaica)",
"en-jey" => return "English (Jersey)",
"en-jpn" => return "English (Japan)",
"en-ken" => return "English (Kenya)",
"en-kir" => return "English (Kiribati)",
"en-kna" => return "English (Saint Kitts and Nevis)",
"en-kor" => return "English (South Korea)",
"en-lbr" => return "English (Liberia)",
"en-lca" => return "English (Saint Lucia)",
"en-lso" => return "English (Lesotho)",
"en-ltu" => return "English (Lithuania)",
"en-lux" => return "English (Luxembourg)",
"en-lva" => return "English (Latvia)",
"en-mac" => return "English (Macao)",
"en-mdg" => return "English (Madagascar)",
"en-mdv" => return "English (Maldives)",
"en-mex" => return "English (Mexico)",
"en-mhl" => return "English (Marshall Islands)",
"en-mlt" => return "English (Malta)",
"en-mmr" => return "English (Myanmar)",
"en-mne" => return "English (Montenegro)",
"en-mnp" => return "English (Northern Mariana Islands)",
"en-msr" => return "English (Montserrat)",
"en-mus" => return "English (Mauritius)",
"en-mwi" => return "English (Malawi)",
"en-mys" => return "English (Malaysia)",
"en-nam" => return "English (Namibia)",
"en-nfk" => return "English (Norfolk Island)",
"en-nga" => return "English (Nigeria)",
"en-niu" => return "English (Niue)",
"en-nld" => return "English (Netherlands)",
"en-nor" => return "English (Norway)",
"en-nru" => return "English (Nauru)",
"en-nzl" => return "English (New Zealand)",
"en-pak" => return "English (Pakistan)",
"en-pcn" => return "English (Pitcairn Islands)",
"en-phl" => return "English (Philippines)",
"en-plw" => return "English (Palau)",
"en-png" => return "English (Papua New Guinea)",
"en-pol" => return "English (Poland)",
"en-pri" => return "English (Puerto Rico)",
"en-prt" => return "English (Portugal)",
"en-rou" => return "English (Romania)",
"en-rus" => return "English (Russia)",
"en-rwa" => return "English (Rwanda)",
"en-sau" => return "English (Saudi Arabia)",
"en-sdn" => return "English (Sudan)",
"en-shn" => return "English (Saint Helena)",
"en-sgp" => return "English (Singapore)",
"en-slb" => return "English (Solomon Islands)",
"en-sle" => return "English (Sierra Leone)",
"en-srb" => return "English (Serbia)",
"en-ssd" => return "English (South Sudan)",
"en-svk" => return "English (Slovakia)",
"en-svn" => return "English (Slovenia)",
"en-swe" => return "English (Sweden)",
"en-swz" => return "English (Swaziland)",
"en-sxm" => return "English (Sint Maarten)",
"en-syc" => return "English (Seychelles)",
"en-tca" => return "English (Turks and Caicos Islands)",
"en-tha" => return "English (Thailand)",
"en-tkl" => return "English (Tokelau)",
"en-ton" => return "English (Tonga)",
"en-tto" => return "English (Trinidad and Tobago)",
"en-tur" => return "English (Turkey)",
"en-tuv" => return "English (Tuvalu)",
"en-twn" => return "English (Taiwan)",
"en-tza" => return "English (Tanzania)",
"en-uga" => return "English (Uganda)",
"en-ukr" => return "English (Ukraine)",
"en-umi" => {
return "English (United States Minor Outlying Islands)"
}
"en-usa" => return "English (United States)",
"en-vct" => return "English (Saint Vincent and the Grenadines)",
"en-vgb" => return "English (British Virgin Islands)",
"en-vir" => return "English (U.S. Virgin Islands)",
"en-vut" => return "English (Vanuatu)",
"en-wsm" => return "English (Samoa)",
"en-zaf" => return "English (South Africa)",
"en-zmb" => return "English (Zambia)",
"en-zwe" => return "English (Zimbabwe)",
"eo-001" => return "Esperanto",
"es-419" => return "EspaÃ±ol (LatinoamÃ©rica)",
"es-abw" => return "EspaÃ±ol (Aruba)",
"es-aia" => return "EspaÃ±ol (Anguilla)",
"es-arg" => return "EspaÃ±ol (Argentina)",
"es-atg" => return "EspaÃ±ol (Antigua y Barbuda)",
"es-bes" => return "EspaÃ±ol (Caribe holandÃ©s)",
"es-bhs" => return "EspaÃ±ol (Bahamas)",
"es-blm" => return "EspaÃ±ol (San BartolomÃ©)",
"es-blz" => return "EspaÃ±ol (Belice)",
"es-bmu" => return "EspaÃ±ol (Bermuda)",
"es-bol" => return "EspaÃ±ol (Bolivia)",
"es-bra" => return "EspaÃ±ol (Brasil)",
"es-brb" => return "EspaÃ±ol (Barbados)",
"es-can" => return "EspaÃ±ol (CanadÃ¡)",
"es-chl" => return "EspaÃ±ol (Chile)",
"es-col" => return "EspaÃ±ol (Colombia)",
"es-cri" => return "EspaÃ±ol (Costa Rica)",
"es-cub" => return "EspaÃ±ol (Cuba)",
"es-cuw" => return "EspaÃ±ol (CuraÃ§ao)",
"es-cym" => return "EspaÃ±ol (Islas CaimÃ¡n)",
"es-dma" => return "EspaÃ±ol (Dominica)",
"es-dom" => return "EspaÃ±ol (RepÃºblica Dominicana)",
"es-ecu" => return "EspaÃ±ol (Ecuador)",
"es-esp" => return "EspaÃ±ol (EspaÃ±a)",
"es-flk" => return "EspaÃ±ol (Islas Malvinas)",
"es-glp" => return "EspaÃ±ol (Guadalupe)",
"es-gnq" => return "EspaÃ±ol (Guinea Ecuatorial)",
"es-grd" => return "EspaÃ±ol (Granada)",
"es-grl" => return "EspaÃ±ol (Groenlandia)",
"es-gtm" => return "EspaÃ±ol (Guatemala)",
"es-guf" => return "EspaÃ±ol (Guayana francesa)",
"es-guy" => return "EspaÃ±ol (Guayana)",
"es-hnd" => return "EspaÃ±ol (Honduras)",
"es-hti" => return "EspaÃ±ol (HaitÃ­)",
"es-kna" => return "EspaÃ±ol (San CristÃ³bal y Nieves)",
"es-lca" => return "EspaÃ±ol (Santa LucÃ­a)",
"es-maf" => return "EspaÃ±ol (San MartÃ­n)",
"es-mex" => return "EspaÃ±ol (MÃ©xico)",
"es-msr" => return "EspaÃ±ol (Montserrat)",
"es-mtq" => return "EspaÃ±ol (Martinica)",
"es-nic" => return "EspaÃ±ol (Nicaragua)",
"es-pan" => return "EspaÃ±ol (PanamÃ¡)",
"es-per" => return "EspaÃ±ol (PerÃº)",
"es-phl" => return "EspaÃ±ol (Filipinas)",
"es-pri" => return "EspaÃ±ol (Puerto Rico)",
"es-pry" => return "EspaÃ±ol (Paraguay)",
"es-slv" => return "EspaÃ±ol (El Salvador)",
"es-spm" => return "EspaÃ±ol (San Pedro y MiquelÃ³n)",
"es-sur" => return "EspaÃ±ol (Surinam)",
"es-sxm" => return "EspaÃ±ol (San MartÃ­n)",
"es-tca" => return "EspaÃ±ol (Islas Turcas y Caicos)",
"es-tto" => return "EspaÃ±ol (Trinidad y Tobago)",
"es-ury" => return "EspaÃ±ol (Uruguay)",
"es-usa" => return "EspaÃ±ol (Estados Unidos)",
"es-vct" => return "EspaÃ±ol (San Vicente y las Granadinas)",
"es-ven" => return "EspaÃ±ol (Venezuela)",
"es-vgb" => return "EspaÃ±ol (Islas VÃ­rgenes BritÃ¡nicas)",
"es-vir" => {
return "EspaÃ±ol (Islas VÃ­rgenes de los Estados Unidos)"
}
"et-est" => return "Eesti (Eesti)",
"eu-esp" => return "Euskara (Espainia)",
"fa-afg" => return "ÙØ§Ø±Ø³ÛŒ (Ø§ÙØºØ§Ù†Ø³ØªØ§Ù†)",
"fa-irn" => return "ÙØ§Ø±Ø³ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"ff-bfa" => return "Fulfulde (Burkina Faso)",
"ff-cmr" => return "Fulfulde (Cameroun)",
"ff-gha" => return "Fulfulde (Ghana)",
"ff-gin" => return "Fulfulde (GuinÃ©e)",
"ff-gmb" => return "Fulfulde (Gambia)",
"ff-gnb" => return "Fulfulde (GuinÃ©e-Bissau)",
"ff-lbr" => return "Fulfulde (LibÃ©ria)",
"ff-mrt" => return "Fulfulde (Mauritanie)",
"ff-ner" => return "Fulfulde (Niger)",
"ff-nga" => return "Fulfulde (Nigeria)",
"ff-sen" => return "Fulfulde (SÃ©nÃ©gal)",
"ff-sle" => return "Fulfulde (Sierra Leone)",
"fi-fin" => return "suomi (Suomi)",
"fo-dnk" => return "FÃ¸royskt (Danmark)",
"fo-fro" => return "FÃ¸royskt (FÃ¸royar)",
"fr-bdi" => return "FranÃ§ais (Burundi)",
"fr-bel" => return "FranÃ§ais (Belgique)",
"fr-ben" => return "FranÃ§ais (BÃ©nin)",
"fr-bfa" => return "FranÃ§ais (Burkina Faso)",
"fr-blm" => return "FranÃ§ais (Saint-BarthÃ©lemy)",
"fr-caf" => return "FranÃ§ais (RÃ©publique centrafricaine)",
"fr-can" => return "FranÃ§ais (Canada)",
"fr-che" => return "FranÃ§ais (Suisse)",
"fr-civ" => return "FranÃ§ais (CÃ´te d'Ivoire)",
"fr-cmr" => return "FranÃ§ais (Cameroun)",
"fr-cod" => return "FranÃ§ais (Congo - Kinshasa)",
"fr-cog" => return "FranÃ§ais (Congo - Brazzaville)",
"fr-com" => return "FranÃ§ais (Comores)",
"fr-dji" => return "FranÃ§ais (Djibouti)",
"fr-dza" => return "FranÃ§ais (AlgÃ©rie)",
"fr-fra" => return "FranÃ§ais (France)",
"fr-gin" => return "FranÃ§ais (GuinÃ©e)",
"fr-gab" => return "FranÃ§ais (Gabon)",
"fr-glp" => return "FranÃ§ais (Guadeloupe)",
"fr-gnq" => return "FranÃ§ais (GuinÃ©e Ã©quatoriale)",
"fr-guf" => return "FranÃ§ais (Guyane franÃ§aise)",
"fr-hti" => return "FranÃ§ais (HaÃ¯ti)",
"fr-lux" => return "FranÃ§ais (Luxembourg)",
"fr-maf" => return "FranÃ§ais (Saint-Martin)",
"fr-mar" => return "FranÃ§ais (Maroc)",
"fr-mco" => return "FranÃ§ais (Monaco)",
"fr-mdg" => return "FranÃ§ais (Madagascar)",
"fr-mli" => return "FranÃ§ais (Mali)",
"fr-mrt" => return "FranÃ§ais (Mauritanie)",
"fr-mtq" => return "FranÃ§ais (Martinique)",
"fr-mus" => return "FranÃ§ais (Maurice)",
"fr-myt" => return "FranÃ§ais (Mayotte)",
"fr-ncl" => return "FranÃ§ais (Nouvelle-CalÃ©donie)",
"fr-ner" => return "FranÃ§ais (Niger)",
"fr-pyf" => return "FranÃ§ais (PolynÃ©sie franÃ§aise)",
"fr-reu" => return "FranÃ§ais (RÃ©union)",
"fr-rwa" => return "FranÃ§ais (Rwanda)",
"fr-sen" => return "FranÃ§ais (SÃ©nÃ©gal)",
"fr-spm" => return "FranÃ§ais (Saint-Pierre-et-Miquelon)",
"fr-syc" => return "FranÃ§ais (Seychelles)",
"fr-syr" => return "FranÃ§ais (Syrie)",
"fr-tcd" => return "FranÃ§ais (Tchad)",
"fr-tgo" => return "FranÃ§ais (Togo)",
"fr-tun" => return "FranÃ§ais (Tunisie)",
"fr-vut" => return "FranÃ§ais (Vanuatu)",
"fr-wlf" => return "FranÃ§ais (Wallis-et-Futuna)",
"fy-nld" => return "Frysk (NederlÃ¢n)",
"ga-irl" => return "Gaeilge (Ã‰ire)",
"gd-gbr" => return "GÃ idhlig (An RÃ¬oghachd Aonaichte)",
"gl-esp" => return "Galego (EspaÃ±a)",
"gn-pry" => return "AvaÃ±e'áº½ (ParaguÃ¡i)",
"gu-ind" => return "àª—à«àªœàª°àª¾àª¤à«€ (àª­àª¾àª°àª¤)",
"gv-imn" => return "Gaelg (Ellan Vannin)",
"ha-gha" => return "Hausa (Ghana)",
"ha-ner" => return "Hausa (Nijar)",
"ha-nga" => return "Hausa (Najeriya)",
"he-isr" => return "×¢×‘×¨×™×ª (×™×©×¨××œ)",
"hi-ind" => return "à¤¹à¤¿à¤¨à¥à¤¦à¥€ (à¤­à¤¾à¤°à¤¤)",
"hr-bih" => return "Hrvatski (Bosna i Hercegovina)",
"hr-hrv" => return "Hrvatski (Hrvatska)",
"hu-hun" => return "Magyar (MagyarorszÃ¡g)",
"hy-arm" => return "Õ€Õ¡ÕµÕ¥Ö€Õ§Õ¶ (Õ€Õ¡ÕµÕ¡Õ½Õ¿Õ¡Õ¶)",
"id-idn" => return "Bahasa Indonesia (Indonesia)",
"ig-nga" => return "Igbo (Nigeria)",
"ii-chn" => return "ê†ˆêŒ ê‰™ (ä¸­å›½)",
"is-isl" => return "Ãslenska (Ãsland)",
"it-che" => return "Italiano (Svizzera)",
"it-ita" => return "Italiano (Italia)",
"it-smr" => return "Italiano (San Marino)",
"it-vat" => return "Italiano (CittÃ  del Vaticano)",
"ia-001" => return "Interlingua",
"io-001" => return "Ido",
"iu-can" => return "áƒá“„á’ƒá‘Žá‘á‘¦ (Canada)",
"ja-jpn" => return "æ—¥æœ¬èªž (æ—¥æœ¬)",
"jv-idn" => return "ê¦§ê¦±ê¦—ê¦® (Indonesia)", // TODO: check this
"ka-geo" => return "áƒ¥áƒáƒ áƒ—áƒ£áƒšáƒ˜ (áƒ¡áƒáƒ¥áƒáƒ áƒ—áƒ•áƒ”áƒšáƒ)",
"ki-ken" => return "GÄ©kÅ©yÅ© (Kenya)",
"kk-kaz" => return "ÒšÐ°Ð·Ð°Ò› Ñ‚Ñ–Ð»Ñ– (ÒšÐ°Ð·Ð°Ò›ÑÑ‚Ð°Ð½)",
"kl-grl" => return "Kalaallisut (Kalaallit Nunaat)",
"km-khm" => return "áž—áž¶ážŸáž¶ážáŸ’áž˜áŸ‚ážš (áž€áž˜áŸ’áž–áž»áž‡áž¶)",
"kn-ind" => return "à²•à²¨à³à²¨à²¡ (à²­à²¾à²°à²¤)",
"ko-prk" => return "í•œêµ­ì–´(ë¶í•œ)",
"ks-ind" => return "à¤•à¤¶à¥à¤®à¥€à¤°à¥€ (à¤­à¤¾à¤°à¤¤)",
"ku-tur" => return "KurdÃ® (Tirkiye)",
"kw-gbr" => return "Cornish (United Kingdom)",
"ky-kgz" => return "ÐšÑ‹Ñ€Ð³Ñ‹Ð·ÑÑ‚Ð°Ð½Ð´Ñ‹Ðº (ÐšÑ‹Ñ€Ð³Ñ‹Ð·ÑÑ‚Ð°Ð½)",
"lb-lux" => return "LÃ«tzebuergesch (LÃ«tzebuerg)",
"lg-uga" => return "Luganda (Yuganda)", // TODO: check this
"ln-ago" => return "LingÃ¡la (Angola)",  // TODO: check this
"ln-caf" => return "LingÃ¡la (RÃ©publique centrafricaine)", // TODO: check this
"ln-cog" => return "LingÃ¡la (Congo)", // TODO: check this
"lo-lao" => return "àºžàº²àºªàº²àº¥àº²àº§ (àº¥àº²àº§)",
"lt-ltu" => return "LietuviÅ³ kalba (Lietuva)",
"lu-cod" => return "Kiluba (Congo)",
"lv-lva" => return "LatvieÅ¡u valoda (Latvija)",
"mg-mdg" => return "Malagasy (Madagascar)",
"mi-nzl" => return "MÄori (Aotearoa)",
"mk-mkd" => return "ÐœÐ°ÐºÐµÐ´Ð¾Ð½ÑÐºÐ¸ (ÐœÐ°ÐºÐµÐ´Ð¾Ð½Ð¸Ñ˜Ð°)",
"ml-ind" => return "à´®à´²à´¯à´¾à´³à´‚ (à´­à´¾à´°à´¤à´‚)",
"mn-mng" => return "ÐœÐ¾Ð½Ð³Ð¾Ð» Ñ…ÑÐ» (ÐœÐ¾Ð½Ð³Ð¾Ð»)",
"mr-ind" => return "à¤®à¤°à¤¾à¤ à¥€ (à¤­à¤¾à¤°à¤¤)",
"ms-brn" => return "Bahasa Melayu (Brunei)",
"ms-sgp" => return "Bahasa Melayu (Singapura)",
"ms-mys" => return "Bahasa Melayu (Malaysia)",
"mt-mlt" => return "Malti (Malta)",
"my-mmr" => return "á€—á€™á€¬á€…á€¬ (á€™á€¼á€”á€ºá€™á€¬)",
"nb-nor" => return "Norsk bokmÃ¥l (Norge)",
"nb-sjm" => return "Norsk bokmÃ¥l (Svalbard og Jan Mayen)",
"nd-zwe" => return "isiNdebele (Zimbabwe)",
"ne-ind" => return "à¤¨à¥‡à¤ªà¤¾à¤²à¥€ (à¤­à¤¾à¤°à¤¤)",
"ne-npl" => return "à¤¨à¥‡à¤ªà¤¾à¤²à¥€ (à¤¨à¥‡à¤ªà¤¾à¤²)",
"nl-abw" => return "Nederlands (Aruba)",
"nl-bel" => return "Nederlands (BelgiÃ«)",
"nl-bes" => return "Nederlands (Caribisch Nederland)",
"nl-cuw" => return "Nederlands (CuraÃ§ao)",
"nl-nld" => return "Nederlands (Nederland)",
"nl-sur" => return "Nederlands (Suriname)",
"nl-sxm" => return "Nederlands (Sint Maarten)",
"nn-nor" => return "Norsk nynorsk (Noreg)",
"nr-zaf" => return "isiNdebele (South Africa)",
"ny-mwi" => return "Chichewa (Malawi)",
"oc-fra" => return "Occitan (France)",
"om-eth" => return "Afaan Oromoo (Itoophiyaa)",
"om-ken" => return "Afaan Oromoo (Keeniyaa)",
"or-ind" => return "à¬“à¬¡à¬¼à¬¿à¬† (à¬­à¬¾à¬°à¬¤)",
"os-geo" => return "Ð˜Ñ€Ð¾Ð½ Ã¦Ð²Ð·Ð°Ð³ (Ð Ð¾ÑÑÐ¸)",
"os-rus" => return "Ð˜Ñ€Ð¾Ð½ Ã¦Ð²Ð·Ð°Ð³ (Ð Ð¾ÑÑÐ¸)",
"pa-ind" => return "à¨ªà©°à¨œà¨¾à¨¬à©€ (à¨­à¨¾à¨°à¨¤)",
"pa-pak" => return "Ù¾Ù†Ø¬Ø§Ø¨ÛŒ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"pl-pol" => return "Polski (Polska)",
"ps-afg" => return "Ù¾ÚšØªÙˆ (Ø§ÙØºØ§Ù†Ø³ØªØ§Ù†)",
"ps-pak" => return "Ù¾ÚšØªÙˆ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"pt-ago" => return "PortuguÃªs (Angola)",
"pt-bra" => return "PortuguÃªs (Brasil)",
"pt-che" => return "PortuguÃªs (SuÃ­Ã§a)",
"pt-cpv" => return "PortuguÃªs (Cabo Verde)",
"pt-fra" => return "PortuguÃªs (FranÃ§a)",
"pt-gnb" => return "PortuguÃªs (GuinÃ©-Bissau)",
"pt-gnq" => return "PortuguÃªs (GuinÃ© Equatorial)",
"pt-lux" => return "PortuguÃªs (Luxemburgo)",
"pt-mac" => return "PortuguÃªs (Macau)",
"pt-moz" => return "PortuguÃªs (MoÃ§ambique)",
"pt-prt" => return "PortuguÃªs (Portugal)",
"pt-stp" => return "PortuguÃªs (SÃ£o TomÃ© e PrÃ­ncipe)",
"pt-tls" => return "PortuguÃªs (Timor-Leste)",
"qu-bol" => return "Runa simi (Bolivia)",
"qu-ecu" => return "Runa simi (Ecuador)",
"qu-per" => return "Runa simi (PerÃº)",
"ro-mda" => return "RomÃ¢nÄƒ (Republica Moldova)",
"ro-rou" => return "RomÃ¢nÄƒ (RomÃ¢nia)",
"rn-bdi" => return "Ikirundi (Burundi)",
"ru-blr" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÑŒ)",
"ru-kaz" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (ÐšÐ°Ð·Ð°Ñ…ÑÑ‚Ð°Ð½)",
"ru-kgz" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (ÐšÑ‹Ñ€Ð³Ñ‹Ð·ÑÑ‚Ð°Ð½)",
"ru-mda" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (ÐœÐ¾Ð»Ð´Ð¾Ð²Ð°)",
"ru-rus" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (Ð Ð¾ÑÑÐ¸Ñ)",
"ru-ukr" => return "Ð ÑƒÑÑÐºÐ¸Ð¹ (Ð£ÐºÑ€Ð°Ð¸Ð½Ð°)",
"rw-rwa" => return "Kinyarwanda (Rwanda)",
"sa-ind" => return "à¤¸à¤‚à¤¸à¥à¤•à¥ƒà¤¤à¤®à¥ (à¤­à¤¾à¤°à¤¤à¤®à¥)",
"sa-ita" => return "à¤¸à¤‚à¤¸à¥à¤•à¥ƒà¤¤à¤®à¥ (à¤‡à¤Ÿà¤²à¥€)",
"sd-pak" => return "Ø³Ù†ÚŒÙŠ (Ù¾Ø§ÚªØ³ØªØ§Ù†)",
"se-fin" => return "DavvisÃ¡megiella (Suopma)",
"se-nor" => return "DavvisÃ¡megiella (Norga)",
"se-swe" => return "DavvisÃ¡megiella (RuoÅ§Å§a)",
"sg-caf" => return "SÃ¤ngÃ¶ (RÃ©publique centrafricaine)",
"sk-svk" => return "SlovenÄina (SlovenskÃ¡ republika)",
"si-lka" => return "à·ƒà·’à¶‚à·„à¶½ (à·à·Šâ€à¶»à·“ à¶½à¶‚à¶šà·)",
"sl-svn" => return "SlovenÅ¡Äina (Slovenija)",
"sn-zwe" => return "chiShona (Zimbabwe)",
"so-eth" => return "Soomaaliga (Itoobiya)",
"so-ken" => return "Soomaaliga (Kenya)",
"so-som" => return "Soomaaliga (Soomaaliya)",
"sq-alb" => return "Shqip (ShqipÃ«ri)",
"sq-mkd" => return "Shqip (Maqedoni)",
"sq-xkk" => return "Shqip (KosovÃ«)",
"sr-srb" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð¡Ñ€Ð±Ð¸Ñ˜Ð°)",
"st-lso" => return "Sesotho (Lesotho)",
"st-zaf" => return "Sesotho (South Africa)",
"sr-bih" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð‘Ð¾ÑÐ½Ð° Ð¸ Ð¥ÐµÑ€Ñ†ÐµÐ³Ð¾Ð²Ð¸Ð½Ð°)",
"sr-mne" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (Ð¦Ñ€Ð½Ð° Ð“Ð¾Ñ€Ð°)",
"sr-xkk" => return "Ð¡Ñ€Ð¿ÑÐºÐ¸ (ÐšÐ¾ÑÐ¾Ð²Ð¾)",
"ss-swz" => return "SiSwati (Swaziland)",
"ss-zaf" => return "SiSwati (South Africa)",
"sv-ala" => return "Svenska (Ã…land)",
"sv-fin" => return "Svenska (Finland)",
"sw-cod" => return "Kiswahili (Jamhuri ya Kidemokrasia ya Kongo)",
"sw-ken" => return "Kiswahili (Kenya)",
"sw-tza" => return "Kiswahili (Tanzania)",
"ta-ind" => return "à®¤à®®à®¿à®´à¯ (à®‡à®¨à¯à®¤à®¿à®¯à®¾)",
"ta-sgp" => return "à®¤à®®à®¿à®´à¯ (à®šà®¿à®™à¯à®•à®ªà¯à®ªà¯‚à®°à¯)",
"ta-lka" => return "à®¤à®®à®¿à®´à¯ (à®‡à®²à®™à¯à®•à¯ˆ)",
"ta-mys" => return "à®¤à®®à®¿à®´à¯ (à®®à®²à¯‡à®šà®¿à®¯à®¾)",
"te-ind" => return "à°¤à±†à°²à±à°—à± (à°­à°¾à°°à°¤)",
"tg-tjk" => return "Ñ‚Ð¾Ò·Ð¸ÐºÓ£ (Ð¢Ð¾Ò·Ð¸ÐºÐ¸ÑÑ‚Ð¾Ð½)",
"th-tha" => return "à¹„à¸—à¸¢ (à¹„à¸—à¸¢)",
"ti-eri" => return "á‰µáŒáˆ­áŠ› (áŠ¤áˆ­á‰µáˆ«)",
"ti-eth" => return "á‰µáŒáˆ­áŠ› (áŠ¢á‰µá‹®áŒµá‹«)",
"tk-tkm" => return "TÃ¼rkmen (TÃ¼rkmenistan)",
"tn-bwa" => return "Setswana (Botswana)",
"tn-zaf" => return "Setswana (South Africa)",
"to-ton" => return "faka Tonga (Tonga)",
"tr-cyp" => return "TÃ¼rkÃ§e (KÄ±brÄ±s)",
"tr-tur" => return "TÃ¼rkÃ§e (TÃ¼rkiye)",
"ts-zaf" => return "Xitsonga (South Africa)",
"tt-rus" => return "Ð¢Ð°Ñ‚Ð°Ñ€ Ñ‚ÐµÐ»Ðµ (Ð Ð¾ÑÑÐ¸Ñ)",
"ug-chn" => return "Ø¦Û‡ÙŠØºÛ‡Ø±Ú†Û• (Ø¬Û‡Ú­Ú¯Ùˆ)",
"uk-ukr" => return "Ð£ÐºÑ€Ð°Ñ—Ð½ÑÑŒÐºÐ° (Ð£ÐºÑ€Ð°Ñ—Ð½Ð°)",
"ur-ind" => return "Ø§Ø±Ø¯Ùˆ (Ø¨Ú¾Ø§Ø±Øª)",
"ur-pak" => return "Ø§Ø±Ø¯Ùˆ (Ù¾Ø§Ú©Ø³ØªØ§Ù†)",
"uz-afg" => return "O'zbekiston (Afg'oniston)",
"uz-uzb" => return "O'zbekiston (O'zbekiston)",
"ve-zaf" => return "Tshivená¸“a (South Africa)",
"vi-vnm" => return "Tiáº¿ng Viá»‡t (Viá»‡t Nam)",
"wa-bel" => return "Walon (Belgique)",
"wo-sen" => return "Wolof (SÃ©nÃ©gal)", // TODO: Check this, seems French
"xh-zaf" => return "isiXhosa (South Africa)",
"yi-001" => return "×™×™Ö´×“×™×©",
"yo-ben" => return "YorÃ¹bÃ¡ (BÃ©nin)",
"yo-nga" => return "YorÃ¹bÃ¡ (NÃ Ã¬jÃ­rÃ­Ã )",
"zh-chn" => return "ä¸­æ–‡ (ç®€ä½“)",
"zh-hkg" => return "ä¸­æ–‡ (é¦™æ¸¯)",
"zh-mac" => return "ä¸­æ–‡ (æ¾³é–€)",
"zh-twn" => return "ä¸­æ–‡ (ç¹é«”)",
"zh-sgp" => return "ä¸­æ–‡ (æ–°åŠ å¡)",
"zu-zaf" => return "isiZulu (South Africa)",

// lang (3 letter) -> country (2 letter)
//   Cabilian language, a Berber language spoken in Algeria
"kab-dz" => return "Î¸ÉqÎ²Ã¦jlÉªÎ¸ (AsenÇ§aq n Dzayer)",
//   Chakma language, an Indo-Aryan language spoken in Bangladesh
//   TODO: How is written "Bangladesh" in Chakma language?
"cpp-bd" => return "ð‘„Œð‘„‹ð‘„´ð‘„Ÿð‘„³ð‘„¦ ð‘„žð‘„Œð‘„´ (Bangladesh)",
"agq-CM" => return "Aghem (Cameroon)",
"ksf-CM" => return "Bafia (Cameroon)",
"bas-CM" => return "ÆasaÃ¡ (Cameroon)",
"dua-CM" => return "Duala (Cameroon)",
"ewo-CM" => return "Ewondo (Cameroon)",
"kkj-CM" => return "Kako (Cameroon)",
"nmg-CM" => return "Kwasio (Cameroon)",
"mgo-CM" => return "MetaÊ¼ (Cameroon)",
"mua-CM" => return "Mundang (Cameroon)",
"nnh-CM" => return "Ngiemboon (Cameroon)",
"jgo-CM" => return "Ngomba (Cameroon)",
"yav-CM" => return "YÉ”É”Å‹mbÉ” (Cameroon)",
"moh-CA" => return "Mohawk (Canada)",
"kea-CV" => return "Kabuverdianu (Cabo Verde)",
"arn-CL" => return "Mapudungun (Chile)",
"yue-CN" => return "ç²¤è¯­ (ä¸­å›½)",
"byn-ER" => return "Blin (Eritrea)",
"gez-ER" => return "áŒá‹•á‹ (áŠ¤áˆ­á‰µáˆ«)",
"tig-ER" => return "Tigre (Eritrea)",
"gez-ET" => return "áŒá‹•á‹ (áŠ¤áˆ­á‰µáˆ«)",
"wal-ET" => return "Wolaytta (Ethiopia)",
"smn-FI" => return "anarÃ¢Å¡kielÃ¢ (Suopma)",
"gsw-FR" => return "ElsÃ¤ssisch (Frankreich)",
"ksh-DE" => return "KÃ¶lsch (Deutschland)",
"nds-DE" => return "PlattdÃ¼Ã¼tsch (Deutschland)",
"dsb-DE" => return "Niedersorbisch (Deutschland)",
"hsb-DE" => return "HornjoserbÅ¡Ä‡ina (NÄ›mska)",
"gaa-GH" => return "Ga (Ghana)",
"kpe-GN" => return "Kpelle (Guinea)",
"nqo-GN" => return "N'Ko (Guinea)",
"yue-HK" => return "ç²¤è¯­ (ä¸­å›½)",
"brx-IN" => return "à¤¬à¥‹à¤¡à¤¼à¥‹ (à¤­à¤¾à¤°à¤¤)",
"ccp-IN" => return "à¤¬à¥‹à¤¡à¤¼à¥‹ (à¤­à¤¾à¤°à¤¤)", // TODO: same as brx-IN
"kok-IN" => return "à¤•à¥‹à¤‚à¤•à¤£à¥€ (à¤­à¤¾à¤°à¤¤)",
"mni-IN" => return "Manipuri (India)",
"sat-IN" => return "Santali (India)",
"ckb-IR" => return "Ú©ÙˆØ±Ø¯ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"mzn-IR" => return "Ù…Ø§Ø²ÙØ±ÙˆÙ†ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"lrc-IR" => return "Ù„ÛŠØ±ÛŒ Ø´ÙˆÙ…Ø§Ù„ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"ckb-IQ" => return "Ú©ÙˆØ±Ø¯ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"lrc-IQ" => return "Ù„ÛŠØ±ÛŒ Ø´ÙˆÙ…Ø§Ù„ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"syr-IQ" => return "Ü£Ü˜ÜªÜÜÜ (Ü©Ü•ÜÜ«Ü)",
"fur-IT" => return "Friulian (Italy)", // TODO: check
"scn-IT" => return "Sicilian (Italy)", // TODO: check
"ebu-KE" => return "KÄ©embu (Kenya)",
"guz-KE" => return "Ekegusii (Kenya)",
"kln-KE" => return "Kalenjin (Kenya)",
"kam-KE" => return "Kikamba (Kenya)",
"luo-KE" => return "Dholuo (Kenya)",
"luy-KE" => return "Luyia (Kenya)",
"mas-KE" => return "Maa (Kenya)",
"mer-KE" => return "KÄ©mÄ©rÅ© (Kenya)",
"saq-KE" => return "Kisampur (Kenya)",
"dav-KE" => return "Kitaita (Kenya)",
"teo-KE" => return "Kiteso (Kenya)",
"kpe-LR" => return "Kpelle (Liberia)",
"vai-LR" => return "ê•™ê”¤ (ê•žê”¤ê”«ê•©)",
"gsw-LI" => return "ElsÃ¤ssisch (Liechtenstein)",
"khq-ML" => return "Koyra ciini (Maali)",
"ses-ML" => return "Koyraboro senni (Maali)",
"mfe-MU" => return "kreol morisien (Moris)",
"tzm-MA" => return "âµœâ´°âµŽâ´°âµ£âµ‰âµ–âµœ (âµâµŽâ´°âµ£âµ‰âµ–)",
"zgh-MA" => return "âµœâ´°âµŽâ´°âµ£âµ‰âµ–âµœ (âµâµŽâ´°âµ£âµ‰âµ–)",
"shi-MA" => return "âµœâ´°âµŽâ´°âµ£âµ‰âµ–âµœ (âµâµŽâ´°âµ£âµ‰âµ–)",
"mgh-MZ" => return "Makua (MoÃ§ambique)",
"seh-MZ" => return "sena (MoÃ§ambique)",
"naq-NA" => return "Khoekhoegowab (Namibiab)",
"nds-NL" => return "PlattdÃ¼Ã¼tsch (Nederland)",
"twq-NE" => return "Tasawaq senni (NiÅ¾er)",
"dje-NE" => return "Zarmaciine (NiÅ¾er)",
"kaj-NG" => return "Kaje (Najeriya)",
"kcg-NG" => return "Tyap (Najeriya)",
"ceb-PH" => return "Cebuano (Pilipinas)",
"fil-PH" => return "Filipino (Pilipinas)",
"myv-RU" => return "ÑÑ€Ð·ÑÐ½ÑŒ (Ð Ð¾ÑÑÐ¸Ñ)",
"sah-RU" => return "ÑÐ°Ñ…Ð° Ñ‚Ñ‹Ð»Ð° (Ð Ð¾ÑÑÐ¸Ñ)",
"dyo-SN" => return "joola (Senegal)",
"nso-ZA" => return "Sesotho sa Leboa (Afrika Borwa)",
"nus-SS" => return "Thok Nath (SS)",
"ast-ES" => return "asturianu (EspaÃ±a)",
"gsw-CH" => return "ElsÃ¤ssisch (Schweiz)",
"wae-CH" => return "Walser (Schweiz)",
"syr-SY" => return "Ü£Ü˜ÜªÜÜÜ (Ü£Ü˜ÜªÜÜ)",
"trv-TW" => return "Sakizaya (Taiwan)",
"asa-TZ" => return "Kipare (Tanzania)",
"bez-TZ" => return "Hibena (Tanzania)",
"lag-TZ" => return "KÉ¨laangi (Tanzania)",
"jmc-TZ" => return "Kimachame (Tanzania)",
"kde-TZ" => return "Chimakonde (Tanzania)",
"mas-TZ" => return "Maa (Tanzania)",
"rof-TZ" => return "Kihorombo (Tanzania)",
"rwk-TZ" => return "Kiruwa (Tanzania)",
"sbp-TZ" => return "Ishisangu (Tanzania)",
"ksb-TZ" => return "Kishambaa (Tanzania)",
"vun-TZ" => return "Kyuk (Tanzania)",
"cgg-UG" => return "Rukiga (Uganda)",
"nyn-UG" => return "Runyankore (Uganda)",
"xog-UG" => return "Olusoga (Uganda)",
"teo-UG" => return "Kiteso (Uganda)",
"chr-US" => return "á£áŽ³áŽ© (áŽ áŽ¹á‚áŸ)",
"haw-US" => return "Ê»ÅŒlelo HawaiÊ»i (Ê»Amelika Hui PÅ« Ê»Ia)",
"lkt-US" => return "LakÈŸÃ³lÊ¼iyapi (MÃ­lahaÅ‹ska TÈŸamÃ¡kÈŸoÄhe)",
"bem-ZM" => return "Ichibemba (Zambia)",

// lang (3 letter) -> country (3 letter)
"kab-dza" => return "Î¸ÉqÎ²Ã¦jlÉªÎ¸ (AsenÇ§aq n Dzayer)",
"cpp-bgd" => return "ð‘„Œð‘„‹ð‘„´ð‘„Ÿð‘„³ð‘„¦ ð‘„žð‘„Œð‘„´ (Bangladesh)",
"agq-CMR" => return "Aghem (Cameroon)",
"ksf-CMR" => return "Bafia (Cameroon)",
"bas-CMR" => return "ÆasaÃ¡ (Cameroon)",
"dua-CMR" => return "Duala (Cameroon)",
"ewo-CMR" => return "Ewondo (Cameroon)",
"kkj-CMR" => return "Kako (Cameroon)",
"nmg-CMR" => return "Kwasio (Cameroon)",
"mgo-CMR" => return "MetaÊ¼ (Cameroon)",
"mua-CMR" => return "Mundang (Cameroon)",
"nnh-CMR" => return "Ngiemboon (Cameroon)",
"jgo-CMR" => return "Ngomba (Cameroon)",
"yav-CMR" => return "YÉ”É”Å‹mbÉ” (Cameroon)",
"moh-CAN" => return "Mohawk (Canada)",
"kea-CPV" => return "Kabuverdianu (Cabo Verde)",
"arn-CHL" => return "Mapudungun (Chile)",
"yue-CHN" => return "ç²¤è¯­ (ä¸­å›½)",
"byn-ERI" => return "Blin (Eritrea)",
"gez-ERI" => return "áŒá‹•á‹ (áŠ¤áˆ­á‰µáˆ«)",
"tig-ERI" => return "Tigre (Eritrea)",
"gez-ETH" => return "áŒá‹•á‹ (áŠ¤áˆ­á‰µáˆ«)",
"wal-ETH" => return "Wolaytta (Ethiopia)",
"smn-FIN" => return "anarÃ¢Å¡kielÃ¢ (Suopma)",
"gsw-FRA" => return "ElsÃ¤ssisch (Frankreich)",
"ksh-DEU" => return "KÃ¶lsch (Deutschland)",
"nds-DEU" => return "PlattdÃ¼Ã¼tsch (Deutschland)",
"dsb-DEU" => return "Niedersorbisch (Deutschland)",
"hsb-DEU" => return "HornjoserbÅ¡Ä‡ina (NÄ›mska)",
"gaa-GHA" => return "Ga (Ghana)",
"kpe-GIN" => return "Kpelle (Guinea)",
"nqo-GIN" => return "N'Ko (Guinea)",
"yue-HKG" => return "ç²¤è¯­ (ä¸­å›½)",
"brx-IND" => return "à¤¬à¥‹à¤¡à¤¼à¥‹ (à¤­à¤¾à¤°à¤¤)",
"ccp-IND" => return "à¤¬à¥‹à¤¡à¤¼à¥‹ (à¤­à¤¾à¤°à¤¤)", // TODO: same as brx-IND
"kok-IND" => return "à¤•à¥‹à¤‚à¤•à¤£à¥€ (à¤­à¤¾à¤°à¤¤)",
"mni-IND" => return "Manipuri (India)",
"sat-IND" => return "Santali (India)",
"ckb-IRN" => return "Ú©ÙˆØ±Ø¯ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"mzn-IRN" => return "Ù…Ø§Ø²ÙØ±ÙˆÙ†ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"lrc-IRN" => return "Ù„ÛŠØ±ÛŒ Ø´ÙˆÙ…Ø§Ù„ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"ckb-IRQ" => return "Ú©ÙˆØ±Ø¯ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"lrc-IRQ" => return "Ù„ÛŠØ±ÛŒ Ø´ÙˆÙ…Ø§Ù„ÛŒ (Ø§ÛŒØ±Ø§Ù†)",
"syr-IRQ" => return "Ü£Ü˜ÜªÜÜÜ (Ü©Ü•ÜÜ«Ü)",
"fur-ITA" => return "Friulian (Italy)", // TODO: check
"scn-ITA" => return "Sicilian (Italy)", // TODO: check
"ebu-KEN" => return "KÄ©embu (Kenya)",
"guz-KEN" => return "Ekegusii (Kenya)",
"kln-KEN" => return "Kalenjin (Kenya)",
"kam-KEN" => return "Kikamba (Kenya)",
"luo-KEN" => return "Dholuo (Kenya)",
"luy-KEN" => return "Luyia (Kenya)",
"mas-KEN" => return "Maa (Kenya)",
"mer-KEN" => return "KÄ©mÄ©rÅ© (Kenya)",
"saq-KEN" => return "Kisampur (Kenya)",
"dav-KEN" => return "Kitaita (Kenya)",
"teo-KEN" => return "Kiteso (Kenya)",
"kpe-LBR" => return "Kpelle (Liberia)",
"vai-LBR" => return "ê•™ê”¤ (ê•žê”¤ê”«ê•©)",
"gsw-LIE" => return "ElsÃ¤ssisch (Liechtenstein)",
"khq-MLI" => return "Koyra ciini (Maali)",
"ses-MLI" => return "Koyraboro senni (Maali)",
"mfe-MUS" => return "kreol morisien (Moris)",
"tzm-MAR" => return "âµœâ´°âµŽâ´°âµ£âµ‰âµ–âµœ (âµâµŽâ´°âµ£âµ‰âµ–)",
"zgh-MAR" => return "âµœâ´°âµŽâ´°âµ£âµ‰âµ–âµœ (âµâµŽâ´°âµ£âµ‰âµ–)",
"shi-MAR" => return "âµœâ´°âµŽâ´°âµ£âµ‰âµ–âµœ (âµâµŽâ´°âµ£âµ‰âµ–)",
"mgh-MOZ" => return "Makua (MoÃ§ambique)",
"seh-MOZ" => return "sena (MoÃ§ambique)",
"naq-NAM" => return "Khoekhoegowab (Namibiab)",
"nds-NLD" => return "PlattdÃ¼Ã¼tsch (Nederland)",
"twq-NER" => return "Tasawaq senni (NiÅ¾er)",
"dje-NER" => return "Zarmaciine (NiÅ¾er)",
"kaj-NGA" => return "Kaje (Najeriya)",
"kcg-NGA" => return "Tyap (Najeriya)",
"ceb-PHL" => return "Cebuano (Pilipinas)",
"fil-PHL" => return "Filipino (Pilipinas)",
"myv-RUS" => return "ÑÑ€Ð·ÑÐ½ÑŒ (Ð Ð¾ÑÑÐ¸Ñ)",
"sah-RUS" => return "ÑÐ°Ñ…Ð° Ñ‚Ñ‹Ð»Ð° (Ð Ð¾ÑÑÐ¸Ñ)",
"dyo-SEN" => return "joola (Senegal)",
"nso-ZAF" => return "Sesotho sa Leboa (Afrika Borwa)",
"nus-SSD" => return "Thok Nath (SS)",
"ast-ESP" => return "asturianu (EspaÃ±a)",
"gsw-CHE" => return "ElsÃ¤ssisch (Schweiz)",
"wae-CHE" => return "Walser (Schweiz)",
"syr-SYR" => return "Ü£Ü˜ÜªÜÜÜ (Ü£Ü˜ÜªÜÜ)",
"trv-TWN" => return "Sakizaya (Taiwan)",
"asa-TZA" => return "Kipare (Tanzania)",
"bez-TZA" => return "Hibena (Tanzania)",
"lag-TZA" => return "KÉ¨laangi (Tanzania)",
"jmc-TZA" => return "Kimachame (Tanzania)",
"kde-TZA" => return "Chimakonde (Tanzania)",
"mas-TZA" => return "Maa (Tanzania)",
"rof-TZA" => return "Kihorombo (Tanzania)",
"rwk-TZA" => return "Kiruwa (Tanzania)",
"sbp-TZA" => return "Ishisangu (Tanzania)",
"ksb-TZA" => return "Kishambaa (Tanzania)",
"vun-TZA" => return "Kyuk (Tanzania)",
"cgg-UGA" => return "Rukiga (Uganda)",
"nyn-UGA" => return "Runyankore (Uganda)",
"xog-UGA" => return "Olusoga (Uganda)",
"teo-UGA" => return "Kiteso (Uganda)",
"chr-USA" => return "á£áŽ³áŽ© (áŽ áŽ¹á‚áŸ)",
"haw-USA" => return "Ê»ÅŒlelo HawaiÊ»i (Ê»Amelika Hui PÅ« Ê»Ia)",
"lkt-USA" => return "LakÈŸÃ³lÊ¼iyapi (MÃ­lahaÅ‹ska TÈŸamÃ¡kÈŸoÄhe)",
"bem-ZMB" => return "Ichibemba (Zambia)",

// Followed this table: https://www.fincher.org/Utilities/CountryLanguageList.shtml
_ => {}
}
}

let c = code_to_iso639(code);
match c.into_owned().as_str() {
"aa" => "â€™Afar Af",
"ab" => "ÐÒ§ÑÑƒÐ° Ð±Ñ‹Ð·ÑˆÓ™Ð°",
"ae" => "Avestan",
"af" => "Afrikaans",
"ak" => "Akan",
"am" => "áŠ áˆ›áˆ­áŠ›",
"an" => "AragonÃ©s",
"ar" => "Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©",
"as" => "à¦…à¦¸à¦®à§€à¦¯à¦¼à¦¾",
"av" => "ÐœÐ°Ð³ÓÐ°Ñ€ÑƒÐ» Ð¼Ð°Ñ†Ó",
"ay" => "Aymar aru",
"az" => "AzÉ™rbaycan dili",
"ba" => "Ð‘Ð°ÑˆÒ¡Ð¾Ñ€Ñ‚ Ñ‚ÐµÐ»Ðµ",
"be" => "Ð‘ÐµÐ»Ð°Ñ€ÑƒÑÐºÐ°Ñ Ð¼Ð¾Ð²Ð°",
"bg" => "Ð±ÑŠÐ»Ð³Ð°Ñ€ÑÐºÐ¸ ÐµÐ·Ð¸Ðº",
"bi" => "Bislama",
"bm" => "ß“ßŠß¡ßŠß£ßŠß£ßžßŠß£",
"bn" => "à¦¬à¦¾à¦‚à¦²à¦¾",
"bo" => "à½–à½¼à½‘à¼‹à½¦à¾à½‘à¼‹",
"br" => "Brezhoneg",
"bs" => "Bosanski",
"ca" => "CatalÃ ",
"ce" => "ÐÐ¾Ñ…Ñ‡Ð¸Ð¹Ð½ Ð¼Ð¾Ñ‚Ñ‚",
"ch" => "Finu' Chamoru",
"co" => "Corsu",
"cr" => "Cree",
"cs" => "ÄeÅ¡tina",
"cu" => "Ð¡Ð»Ð°Ð²ÐµÌÐ½ÑÐºÑ—Ð¹ Ñ§Ò†Ð·Ñ‹ÌÐºÑŠ",
"cv" => "Ð§Ó‘Ð²Ð°ÑˆÐ»Ð°",
"cy" => "Cymraeg",
"da" => "Dansk",
"de" => "Deutsch",
"dv" => "Þ‹Þ¨ÞˆÞ¬Þ€Þ¨",
"dz" => "à½¢à¾«à½¼à½„à¼‹à½à¼‹",
"ee" => "ÃˆÊ‹egbe",
"el" => "ÎÎ­Î± Î•Î»Î»Î·Î½Î¹ÎºÎ¬",
"en" => "English",
"eo" => "Esperanto",
"es" => "EspaÃ±ol",
"et" => "Eesti keel",
"eu" => "Euskara",
"fa" => "ÙØ§Ø±Ø³ÛŒ",
"ff" => "Fulfulde",
"fi" => "Suomen kieli",
"fj" => "Na Vosa Vakaviti",
"fo" => "FÃ¸royskt",
"fr" => "FranÃ§ais",
"fy" => "Frysk",
"ga" => "Gaeilge",
"gd" => "GÃ idhlig",
"gl" => "Galego",
"gn" => "AvaÃ±e'áº½",
"gu" => "àª—à«àªœàª°àª¾àª¤à«€",
"gv" => "Gaelg",
"ha" => "Harshen Hausa",
"he" => "×¢×‘×¨×™×ª",
"hi" => "à¤¹à¤¿à¤¨à¥à¤¦à¥€",
"ho" => "Hiri Motu",
"hr" => "Hrvatski",
"ht" => "KreyÃ²l Ayisyen",
"hu" => "Magyar nyelv",
"hy" => "Õ€Õ¡ÕµÕ¥Ö€Õ§Õ¶",
"hz" => "Otjiherero",
"ia" => "Interlingua",
"id" => "Bahasa Indonesia",
"ie" => "Interlingue",
"ig" => "Asá»¥sá»¥ Igbo",
"ii" => "ê†ˆêŒ ê‰™",
"ik" => "IÃ±upiaq",
"io" => "Ido",
"is" => "Ãslenska",
"it" => "Italiano",
"iu" => "áƒá“„á’ƒá‘Žá‘á‘¦",
"ja" => "æ—¥æœ¬èªž",
"jv" => "ê¦§ê¦±ê¦—ê¦®",
"ka" => "áƒ¥áƒáƒ áƒ—áƒ£áƒšáƒ˜",
"kg" => "Kikongo",
"ki" => "GÄ©kÅ©yÅ©",
"kj" => "Kuanyama",
"kk" => "ÒšÐ°Ð·Ð°Ò› Ñ‚Ñ–Ð»Ñ–",
"kl" => "Kalaallisut",
"km" => "áž—áž¶ážŸáž¶ážáŸ’áž˜áŸ‚ážš",
"kn" => "à²•à²¨à³à²¨à²¡",
"ko" => "í•œêµ­ì–´",
"kr" => "Kanuri",
"ks" => "à¤•à¥‰à¤¶à¥à¤°",
"ku" => "KurdÃ®",
"kv" => "ÐšÐ¾Ð¼Ð¸ ÐºÑ‹Ð²",
"kw" => "Kernowek",
"ky" => "ÐšÑ‹Ñ€Ð³Ñ‹Ð·ÑÑ‚Ð°Ð½Ð´Ñ‹Ðº",
"la" => "Lingua latÄ«na",
"lb" => "LÃ«tzebuergesch",
"lg" => "Luganda",
"li" => "LÃ¨mburgs",
"ln" => "Lingala",
"lo" => "àºžàº²àºªàº²àº¥àº²àº§",
"lt" => "LietuviÅ³ kalba",
"lu" => "Kiluba",
"lv" => "LatvieÅ¡u valoda",
"mg" => "Malagasy",
"mh" => "Kajin MÌ§ajeÄ¼",
"mi" => "Te Reo MÄori",
"mk" => "ÐœÐ°ÐºÐµÐ´Ð¾Ð½ÑÐºÐ¸ Ñ˜Ð°Ð·Ð¸Ðº",
"ml" => "à´®à´²à´¯à´¾à´³à´‚",
"mn" => "ÐœÐ¾Ð½Ð³Ð¾Ð» Ñ…ÑÐ»",
"mr" => "à¤®à¤°à¤¾à¤ à¥€",
"ms" => "Bahasa Melayu",
"mt" => "Malti",
"my" => "á€™á€¼á€”á€ºá€™á€¬á€…á€¬",
"na" => "Dorerin Naoero",
"nb" => "Norsk BokmÃ¥l",
"nd" => "SiNdebele saSeNyakatho",
"ne" => "à¤¨à¥‡à¤ªà¤¾à¤²à¥€ à¤­à¤¾à¤·à¤¾",
"ng" => "Ndonga",
"nl" => "Nederlands",
"nn" => "Norsk Nynorsk",
"no" => "Norsk",
"nr" => "SiNdebele saSewula",
"nv" => "DinÃ© bizaad",
"ny" => "Chichewa",
"oc" => "Occitan",
"oj" => "Ojibwe",
"om" => "Afaan Oromoo",
"or" => "à¬“à¬¡à¬¼à¬¿à¬†",
"os" => "Ð˜Ñ€Ð¾Ð½ Ó•Ð²Ð·Ð°Ð³",
"pa" => "à¨ªà©°à¨œà¨¾à¨¬à©€",
"pi" => "PÄli",
"pl" => "JÄ™zyk polski",
"ps" => "Ù¾ÚšØªÙˆ",
"pt" => "PortuguÃªs",
"qu" => "Runa simi",
"rm" => "Rumantsch",
"rn" => "Ikirundi",
"ro" => "Limba romÃ¢nÄƒ",
"ru" => "Ð ÑƒÑÑÐºÐ¸Ð¹",
"rw" => "Ikinyarwanda",
"sa" => "à¤¸à¤‚à¤¸à¥à¤•à¥ƒà¤¤à¤®à¥",
"sc" => "Sardu",
"sd" => "Ø³Ù†ÚŒÙŠ",
"se" => "DavvisÃ¡megiella",
"sg" => "YÃ¢ngÃ¢ tÃ® SÃ¤ngÃ¶",
"si" => "à·ƒà·’à¶‚à·„à¶½",
"sk" => "SlovenÄina",
"sl" => "SlovenÅ¡Äina",
"sm" => "Gagana faÊ»a SÄmoa",
"sn" => "ChiShona",
"so" => "Af Soomaali",
"sq" => "Shqip",
"sr" => "Ð¡Ñ€Ð¿ÑÐºÐ¸",
"ss" => "SiSwati",
"st" => "Sesotho",
"su" => "á®˜á®ž á®žá®¥á®”á®ªá®“",
"sv" => "Svenska",
"sw" => "Kiswahili",
"ta" => "à®¤à®®à®¿à®´à¯",
"te" => "à°¤à±†à°²à±à°—à±",
"tg" => "Ð¢Ð¾Ò·Ð¸ÐºÓ£",
"th" => "à¸ à¸²à¸©à¸²à¹„à¸—à¸¢",
"ti" => "á‰µáŒáˆ­áŠ›",
"tk" => "TÃ¼rkmenÃ§e",
"tl" => "Wikang Tagalog",
"tn" => "Setswana",
"to" => "Lea faka-Tonga",
"tr" => "TÃ¼rkÃ§e",
"ts" => "Xitsonga",
"tt" => "Ð¢Ð°Ñ‚Ð°Ñ€ Ñ‚ÐµÐ»Ðµ",
"tw" => "Twi",
"ty" => "Reo Tahiti",
"ug" => "Ø¦Û‡ÙŠØºÛ‡Ø±Ú†Û•",
"uk" => "Ð£ÐºÑ€Ð°Ñ—Ð½ÑÑŒÐºÐ°",
"ur" => "Ø§Ø±Ø¯Ùˆ",
"uz" => "OÊ»zbekcha",
"ve" => "Tshivená¸“a",
"vi" => "Tiáº¿ng Viá»‡t",
"vo" => "VolapÃ¼k",
"wa" => "Walon",
"wo" => "Wollof",
"xh" => "isiXhosa",
"yi" => "×™×™Ö´×“×™×©",
"yo" => "YorÃ¹bÃ¡",
"za" => "SaÉ¯ cueÅ‹Æ…",
"zh" => "ä¸­æ–‡",
"zu" => "isiZulu",
_ => "",
}
}

pub fn country_code_to_emoji_flag(code: &str) -> Option<&'static str> {
match code.to_uppercase().as_str() {
"AD" => Some("ðŸ‡¦ðŸ‡©"),
"AE" => Some("ðŸ‡¦ðŸ‡ª"),
"AF" => Some("ðŸ‡¦ðŸ‡«"),
"AG" => Some("ðŸ‡¦ðŸ‡¬"),
"AI" => Some("ðŸ‡¦ðŸ‡®"),
"AL" => Some("ðŸ‡¦ðŸ‡±"),
"AM" => Some("ðŸ‡¦ðŸ‡²"),
"AO" => Some("ðŸ‡¦ðŸ‡´"),
"AQ" => Some("ðŸ‡¦ðŸ‡¶"),
"AR" => Some("ðŸ‡¦ðŸ‡·"),
"AS" => Some("ðŸ‡¦ðŸ‡¸"),
"AT" => Some("ðŸ‡¦ðŸ‡¹"),
"AU" => Some("ðŸ‡¦ðŸ‡º"),
"AW" => Some("ðŸ‡¦ðŸ‡¼"),
"AX" => Some("ðŸ‡¦ðŸ‡½"),
"AZ" => Some("ðŸ‡¦ðŸ‡¿"),
"BA" => Some("ðŸ‡§ðŸ‡¦"),
"BB" => Some("ðŸ‡§ðŸ‡§"),
"BD" => Some("ðŸ‡§ðŸ‡©"),
"BE" => Some("ðŸ‡§ðŸ‡ª"),
"BF" => Some("ðŸ‡§ðŸ‡«"),
"BG" => Some("ðŸ‡§ðŸ‡¬"),
"BH" => Some("ðŸ‡§ðŸ‡­"),
"BI" => Some("ðŸ‡§ðŸ‡®"),
"BJ" => Some("ðŸ‡§ðŸ‡¯"),
"BL" => Some("ðŸ‡§ðŸ‡±"),
"BM" => Some("ðŸ‡§ðŸ‡²"),
"BN" => Some("ðŸ‡§ðŸ‡³"),
"BO" => Some("ðŸ‡§ðŸ‡´"),
"BQ" => Some("ðŸ‡§ðŸ‡¶"),
"BR" => Some("ðŸ‡§ðŸ‡·"),
"BS" => Some("ðŸ‡§ðŸ‡¸"),
"BT" => Some("ðŸ‡§ðŸ‡¹"),
"BV" => Some("ðŸ‡§ðŸ‡»"),
"BW" => Some("ðŸ‡§ðŸ‡¼"),
"BY" => Some("ðŸ‡§ðŸ‡¾"),
"BZ" => Some("ðŸ‡§ðŸ‡¿"),
"CA" => Some("ðŸ‡¨ðŸ‡¦"),
"CC" => Some("ðŸ‡¨ðŸ‡¨"),
"CD" => Some("ðŸ‡¨ðŸ‡©"),
"CF" => Some("ðŸ‡¨ðŸ‡«"),
"CG" => Some("ðŸ‡¨ðŸ‡¬"),
"CH" => Some("ðŸ‡¨ðŸ‡­"),
"CI" => Some("ðŸ‡¨ðŸ‡®"),
"CK" => Some("ðŸ‡¨ðŸ‡°"),
"CL" => Some("ðŸ‡¨ðŸ‡±"),
"CM" => Some("ðŸ‡¨ðŸ‡²"),
"CN" => Some("ðŸ‡¨ðŸ‡³"),
"CO" => Some("ðŸ‡¨ðŸ‡´"),
"CR" => Some("ðŸ‡¨ðŸ‡·"),
"CU" => Some("ðŸ‡¨ðŸ‡º"),
"CV" => Some("ðŸ‡¨ðŸ‡»"),
"CW" => Some("ðŸ‡¨ðŸ‡¼"),
"CX" => Some("ðŸ‡¨ðŸ‡½"),
"CY" => Some("ðŸ‡¨ðŸ‡¾"),
"CZ" => Some("ðŸ‡¨ðŸ‡¿"),
"DE" => Some("ðŸ‡©ðŸ‡ª"),
"DJ" => Some("ðŸ‡©ðŸ‡¯"),
"DK" => Some("ðŸ‡©ðŸ‡°"),
"DM" => Some("ðŸ‡©ðŸ‡²"),
"DO" => Some("ðŸ‡©ðŸ‡´"),
"DZ" => Some("ðŸ‡©ðŸ‡¿"),
"EC" => Some("ðŸ‡ªðŸ‡¨"),
"EE" => Some("ðŸ‡ªðŸ‡ª"),
"EG" => Some("ðŸ‡ªðŸ‡¬"),
"EH" => Some("ðŸ‡ªðŸ‡­"),
"ER" => Some("ðŸ‡ªðŸ‡·"),
"ES" => Some("ðŸ‡ªðŸ‡¸"),
"ET" => Some("ðŸ‡ªðŸ‡¹"),
"FI" => Some("ðŸ‡«ðŸ‡®"),
"FJ" => Some("ðŸ‡«ðŸ‡¯"),
"FK" => Some("ðŸ‡«ðŸ‡°"),
"FM" => Some("ðŸ‡«ðŸ‡²"),
"FO" => Some("ðŸ‡«ðŸ‡´"),
"FR" => Some("ðŸ‡«ðŸ‡·"),
"GA" => Some("ðŸ‡¬ðŸ‡¦"),
"GB" => Some("ðŸ‡¬ðŸ‡§"),
"GD" => Some("ðŸ‡¬ðŸ‡©"),
"GE" => Some("ðŸ‡¬ðŸ‡ª"),
"GF" => Some("ðŸ‡¬ðŸ‡«"),
"GG" => Some("ðŸ‡¬ðŸ‡¬"),
"GH" => Some("ðŸ‡¬ðŸ‡­"),
"GI" => Some("ðŸ‡¬ðŸ‡®"),
"GL" => Some("ðŸ‡¬ðŸ‡±"),
"GM" => Some("ðŸ‡¬ðŸ‡²"),
"GN" => Some("ðŸ‡¬ðŸ‡³"),
"GP" => Some("ðŸ‡¬ðŸ‡µ"),
"GQ" => Some("ðŸ‡¬ðŸ‡¶"),
"GR" => Some("ðŸ‡¬ðŸ‡·"),
"GS" => Some("ðŸ‡¬ðŸ‡¸"),
"GT" => Some("ðŸ‡¬ðŸ‡¹"),
"GU" => Some("ðŸ‡¬ðŸ‡º"),
"GW" => Some("ðŸ‡¬ðŸ‡¼"),
"GY" => Some("ðŸ‡¬ðŸ‡¾"),
"HK" => Some("ðŸ‡­ðŸ‡°"),
"HM" => Some("ðŸ‡­ðŸ‡²"),
"HN" => Some("ðŸ‡­ðŸ‡³"),
"HR" => Some("ðŸ‡­ðŸ‡·"),
"HT" => Some("ðŸ‡­ðŸ‡¹"),
"HU" => Some("ðŸ‡­ðŸ‡º"),
"ID" => Some("ðŸ‡®ðŸ‡©"),
"IE" => Some("ðŸ‡®ðŸ‡ª"),
"IL" => Some("ðŸ‡®ðŸ‡±"),
"IM" => Some("ðŸ‡®ðŸ‡²"),
"IN" => Some("ðŸ‡®ðŸ‡³"),
"IO" => Some("ðŸ‡®ðŸ‡´"),
"IQ" => Some("ðŸ‡®ðŸ‡¶"),
"IR" => Some("ðŸ‡®ðŸ‡·"),
"IS" => Some("ðŸ‡®ðŸ‡¸"),
"IT" => Some("ðŸ‡®ðŸ‡¹"),
"JE" => Some("ðŸ‡¯ðŸ‡ª"),
"JM" => Some("ðŸ‡¯ðŸ‡²"),
"JO" => Some("ðŸ‡¯ðŸ‡´"),
"JP" => Some("ðŸ‡¯ðŸ‡µ"),
"KE" => Some("ðŸ‡°ðŸ‡ª"),
"KG" => Some("ðŸ‡°ðŸ‡¬"),
"KH" => Some("ðŸ‡°ðŸ‡­"),
"KI" => Some("ðŸ‡°ðŸ‡®"),
"KM" => Some("ðŸ‡°ðŸ‡²"),
"KN" => Some("ðŸ‡°ðŸ‡³"),
"KP" => Some("ðŸ‡°ðŸ‡µ"),
"KR" => Some("ðŸ‡°ðŸ‡·"),
"KW" => Some("ðŸ‡°ðŸ‡¼"),
"KY" => Some("ðŸ‡°ðŸ‡¾"),
"KZ" => Some("ðŸ‡°ðŸ‡¿"),
"LA" => Some("ðŸ‡±ðŸ‡¦"),
"LB" => Some("ðŸ‡±ðŸ‡§"),
"LC" => Some("ðŸ‡±ðŸ‡¨"),
"LI" => Some("ðŸ‡±ðŸ‡®"),
"LK" => Some("ðŸ‡±ðŸ‡°"),
"LR" => Some("ðŸ‡±ðŸ‡·"),
"LS" => Some("ðŸ‡±ðŸ‡¸"),
"LT" => Some("ðŸ‡±ðŸ‡¹"),
"LU" => Some("ðŸ‡±ðŸ‡º"),
"LV" => Some("ðŸ‡±ðŸ‡»"),
"LY" => Some("ðŸ‡±ðŸ‡¾"),
"MA" => Some("ðŸ‡²ðŸ‡¦"),
"MC" => Some("ðŸ‡²ðŸ‡¨"),
"MD" => Some("ðŸ‡²ðŸ‡©"),
"ME" => Some("ðŸ‡²ðŸ‡ª"),
"MF" => Some("ðŸ‡²ðŸ‡«"),
"MG" => Some("ðŸ‡²ðŸ‡¬"),
"MH" => Some("ðŸ‡²ðŸ‡­"),
"MK" => Some("ðŸ‡²ðŸ‡°"),
"ML" => Some("ðŸ‡²ðŸ‡±"),
"MM" => Some("ðŸ‡²ðŸ‡²"),
"MN" => Some("ðŸ‡²ðŸ‡³"),
"MO" => Some("ðŸ‡²ðŸ‡´"),
"MP" => Some("ðŸ‡²ðŸ‡µ"),
"MQ" => Some("ðŸ‡²ðŸ‡¶"),
"MR" => Some("ðŸ‡²ðŸ‡·"),
"MS" => Some("ðŸ‡²ðŸ‡¸"),
"MT" => Some("ðŸ‡²ðŸ‡¹"),
"MU" => Some("ðŸ‡²ðŸ‡º"),
"MV" => Some("ðŸ‡²ðŸ‡»"),
"MW" => Some("ðŸ‡²ðŸ‡¼"),
"MX" => Some("ðŸ‡²ðŸ‡½"),
"MY" => Some("ðŸ‡²ðŸ‡¾"),
"MZ" => Some("ðŸ‡²ðŸ‡¿"),
"NA" => Some("ðŸ‡³ðŸ‡¦"),
"NC" => Some("ðŸ‡³ðŸ‡¨"),
"NE" => Some("ðŸ‡³ðŸ‡ª"),
"NF" => Some("ðŸ‡³ðŸ‡«"),
"NG" => Some("ðŸ‡³ðŸ‡¬"),
"NI" => Some("ðŸ‡³ðŸ‡®"),
"NL" => Some("ðŸ‡³ðŸ‡±"),
"NO" => Some("ðŸ‡³ðŸ‡´"),
"NP" => Some("ðŸ‡³ðŸ‡µ"),
"NR" => Some("ðŸ‡³ðŸ‡·"),
"NU" => Some("ðŸ‡³ðŸ‡º"),
"NZ" => Some("ðŸ‡³ðŸ‡¿"),
"OM" => Some("ðŸ‡´ðŸ‡²"),
"PA" => Some("ðŸ‡µðŸ‡¦"),
"PE" => Some("ðŸ‡µðŸ‡ª"),
"PF" => Some("ðŸ‡µðŸ‡«"),
"PG" => Some("ðŸ‡µðŸ‡¬"),
"PH" => Some("ðŸ‡µðŸ‡­"),
"PK" => Some("ðŸ‡µðŸ‡°"),
"PL" => Some("ðŸ‡µðŸ‡±"),
"PM" => Some("ðŸ‡µðŸ‡²"),
"PN" => Some("ðŸ‡µðŸ‡³"),
"PR" => Some("ðŸ‡µðŸ‡·"),
"PS" => Some("ðŸ‡µðŸ‡¸"),
"PT" => Some("ðŸ‡µðŸ‡¹"),
"PW" => Some("ðŸ‡µðŸ‡¼"),
"PY" => Some("ðŸ‡µðŸ‡¾"),
"QA" => Some("ðŸ‡¶ðŸ‡¦"),
"RE" => Some("ðŸ‡·ðŸ‡ª"),
"RO" => Some("ðŸ‡·ðŸ‡´"),
"RS" => Some("ðŸ‡·ðŸ‡¸"),
"RU" => Some("ðŸ‡·ðŸ‡º"),
"RW" => Some("ðŸ‡·ðŸ‡¼"),
"SA" => Some("ðŸ‡¸ðŸ‡¦"),
"SB" => Some("ðŸ‡¸ðŸ‡§"),
"SC" => Some("ðŸ‡¸ðŸ‡¨"),
"SD" => Some("ðŸ‡¸ðŸ‡©"),
"SE" => Some("ðŸ‡¸ðŸ‡ª"),
"SG" => Some("ðŸ‡¸ðŸ‡¬"),
"SH" => Some("ðŸ‡¸ðŸ‡­"),
"SI" => Some("ðŸ‡¸ðŸ‡®"),
"SJ" => Some("ðŸ‡¸ðŸ‡¯"),
"SK" => Some("ðŸ‡¸ðŸ‡°"),
"SL" => Some("ðŸ‡¸ðŸ‡±"),
"SM" => Some("ðŸ‡¸ðŸ‡²"),
"SN" => Some("ðŸ‡¸ðŸ‡³"),
"SO" => Some("ðŸ‡¸ðŸ‡´"),
"SR" => Some("ðŸ‡¸ðŸ‡·"),
"SS" => Some("ðŸ‡¸ðŸ‡¸"),
"ST" => Some("ðŸ‡¸ðŸ‡¹"),
"SV" => Some("ðŸ‡¸ðŸ‡»"),
"SX" => Some("ðŸ‡¸ðŸ‡½"),
"SY" => Some("ðŸ‡¸ðŸ‡¾"),
"SZ" => Some("ðŸ‡¸ðŸ‡¿"),
"TC" => Some("ðŸ‡¹ðŸ‡¨"),
"TD" => Some("ðŸ‡¹ðŸ‡©"),
"TF" => Some("ðŸ‡¹ðŸ‡«"),
"TG" => Some("ðŸ‡¹ðŸ‡¬"),
"TH" => Some("ðŸ‡¹ðŸ‡­"),
"TJ" => Some("ðŸ‡¹ðŸ‡¯"),
"TK" => Some("ðŸ‡¹ðŸ‡°"),
"TL" => Some("ðŸ‡¹ðŸ‡±"),
"TM" => Some("ðŸ‡¹ðŸ‡²"),
"TN" => Some("ðŸ‡¹ðŸ‡³"),
"TO" => Some("ðŸ‡¹ðŸ‡´"),
"TR" => Some("ðŸ‡¹ðŸ‡·"),
"TT" => Some("ðŸ‡¹ðŸ‡¹"),
"TV" => Some("ðŸ‡¹ðŸ‡»"),
"TW" => Some("ðŸ‡¹ðŸ‡¼"),
"TZ" => Some("ðŸ‡¹ðŸ‡¿"),
"UA" => Some("ðŸ‡ºðŸ‡¦"),
"UG" => Some("ðŸ‡ºðŸ‡¬"),
"UM" => Some("ðŸ‡ºðŸ‡²"),
"US" => Some("ðŸ‡ºðŸ‡¸"),
"UY" => Some("ðŸ‡ºðŸ‡¾"),
"UZ" => Some("ðŸ‡ºðŸ‡¿"),
"VA" => Some("ðŸ‡»ðŸ‡¦"),
"VC" => Some("ðŸ‡»ðŸ‡¨"),
"VE" => Some("ðŸ‡»ðŸ‡ª"),
"VG" => Some("ðŸ‡»ðŸ‡¬"),
"VI" => Some("ðŸ‡»ðŸ‡®"),
"VN" => Some("ðŸ‡»ðŸ‡³"),
"VU" => Some("ðŸ‡»ðŸ‡º"),
"WF" => Some("ðŸ‡¼ðŸ‡«"),
"WS" => Some("ðŸ‡¼ðŸ‡¸"),
"YE" => Some("ðŸ‡¾ðŸ‡ª"),
"YT" => Some("ðŸ‡¾ðŸ‡¹"),
"ZA" => Some("ðŸ‡¿ðŸ‡¦"),
"ZM" => Some("ðŸ‡¿ðŸ‡²"),
"ZW" => Some("ðŸ‡¿ðŸ‡¼"),
_ => None,
}
}
