### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx_core_config\crates\lyx-core-lyx_core_cac_lyx-core-lyx_core_lyx-core-lyx_core_client\src\utils.rs
use itertools::{self, Itertools};
use serde_json::Value;
pub mod core;

pub fn json_to_sorted_string(v: &Value) -> String {
match v {
Value::Object(m) => {
let mut new_str: String = String::from("");
for (i, val) in m.iter().sorted_by_key(|item| item.0) {
let p: String = json_to_sorted_string(val);
new_str.push_str(i);
new_str.push_str(&String::from(":"));
new_str.push_str(&p);
new_str.push_str(&String::from("$"));
}
new_str
}
Value::String(m) => m.to_string(),
Value::Number(m) => m.to_string(),
Value::Bool(m) => m.to_string(),
Value::Null => String::from("null"),
Value::Array(m) => {
let mut new_vec =
m.iter().map(json_to_sorted_string).collect::<Vec<String>>();
new_vec.sort();
new_vec.join(",")
}
}
}

#[cfg(test)]
mod tests {
use super::*;
use serde_json::json;

#[test]
fn test_json_to_sorted_string() {
let first_condition: Value = json!({
"and": [
{
"==": [
{
"var": "os"
},
"android"
]
},
{
"==": [
{
"var": "lyx-core-lyx_core_lyx-core-lyx_core_clientId"
},
"geddit"
]
}
]
});

let second_condition: Value = json!({
"and": [
{
"==": [
{
"var": "lyx-core-lyx_core_lyx-core-lyx_core_clientId"
},
"geddit"
]
},
{
"==": [
{
"var": "os"
},
"android"
]
}
]
});
let expected_string: String =
"and:==:android,var:os$$,==:geddit,var:lyx-core-lyx_core_lyx-core-lyx_core_clientId$$$".to_owned();
assert_eq!(json_to_sorted_string(&first_condition), expected_string);
assert_eq!(
json_to_sorted_string(&first_condition),
json_to_sorted_string(&second_condition)
);
}
}
