### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\ory-kratos\lyx-core-lyx_core_e2e\tests\fixtures\mod.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\ory-kratos\lyx-core-lyx_core_lyx-core-lyx_core_e2e\tests\fixtures\mod.rs
2: ```rust
3: 1: pub mod steps;
4: 2: use anyhow::{anyhow, Result};
5: 3: 
6: 4: pub async fn wait() {
7: 5:     tokio::time::sleep(tokio::time::Duration::from_millis(75)).await;
8: 6: }
9: 7: 
10: 8: use regex::Regex;
11: 9: 
12: 10: fn extract_code_and_link(text: &str) -> Result<(String, String)> {
13: 11:     // Regex pattern for a six-digit number
14: 12:     let number_regex = Regex::new(r"\b\d{6}\b").unwrap();
15: 13:     // Regex pattern for a URL
16: 14:     let url_regex = Regex::new(r">(https?://[^<]+)<").unwrap(); // Simplified URL pattern
17: 15: 
18: 16:     // Search for a six-digit number
19: 17:     let number = number_regex
20: 18:         .find(text)
21: 19:         .map(|match_| match_.as_str().to_string())
22: 20:         .ok_or(anyhow!("Can't find number match"))?;
23: 21: 
24: 22:     // Search for a URL
25: 23:     let url = url_regex
26: 24:         .find(text)
27: 25:         .map(|match_| match_.as_str().to_string())
28: 26:         .ok_or(anyhow!("Can't find url match in \n {text}"))?;
29: 27:     let url = url.trim_matches(|c| c == '>' || c == '<').to_string();
30: 28:     let url = url.replace("amp;", "");
31: 29:     Ok((number, url))
32: 30: }
33: 31: 
34: 32: fn extract_code(text: &str) -> Result<String> {
35: 33:     // Regex pattern for a six-digit number
36: 34:     let number_regex = Regex::new(r"\b\d{6}\b").unwrap();
37: 35: 
38: 36:     // Search for a six-digit number
39: 37:     let number = number_regex
40: 38:         .find(text)
41: 39:         .map(|match_| match_.as_str().to_string())
42: 40:         .ok_or(anyhow!("Can't find number match"))?;
43: 41:     Ok(number)
44: 42: }
45: ```
```
