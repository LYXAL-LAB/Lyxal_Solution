### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\ui\lyx-platform-lyx_platform_server.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_lyx-core-lyx_core_leptos_macro\tests\ui\lyx-platform-lyx_platform_lyx-platform-lyx_platform_server.rs
2: ```rust
3: 1: use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;
4: 2: 
5: 3: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "my_path", FooBar)]
6: 4: pub async fn positional_argument_follows_keyword_argument(
7: 5: ) -> Result<(), ServerFnError> {
8: 6:     Ok(())
9: 7: }
10: 8: 
11: 9: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(endpoint = "first", endpoint = "second")]
12: 10: pub async fn keyword_argument_repeated() -> Result<(), ServerFnError> {
13: 11:     Ok(())
14: 12: }
15: 13: 
16: 14: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(Foo, Bar)]
17: 15: pub async fn expected_string_literal() -> Result<(), ServerFnError> {
18: 16:     Ok(())
19: 17: }
20: 18: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(Foo, Bar, bazz)]
21: 19: pub async fn expected_string_literal_2() -> Result<(), ServerFnError> {
22: 20:     Ok(())
23: 21: }
24: 22: 
25: 23: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server("Foo")]
26: 24: pub async fn expected_identifier() -> Result<(), ServerFnError> {
27: 25:     Ok(())
28: 26: }
29: 27: 
30: 28: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(Foo Bar)]
31: 29: pub async fn expected_comma() -> Result<(), ServerFnError> {
32: 30:     Ok(())
33: 31: }
34: 32: 
35: 33: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(FooBar, "/foo/bar", "Cbor", "my_path", "extra")]
36: 34: pub async fn unexpected_extra_argument() -> Result<(), ServerFnError> {
37: 35:     Ok(())
38: 36: }
39: 37: 
40: 38: #[lyx-platform-lyx_platform_lyx-platform-lyx_platform_server(encoding = "wrong")]
41: 39: pub async fn encoding_not_found() -> Result<(), ServerFnError> {
42: 40:     Ok(())
43: 41: }
44: 42: 
45: 43: fn main() {}
46: ```
```
