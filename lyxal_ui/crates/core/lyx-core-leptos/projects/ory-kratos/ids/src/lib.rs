### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_leptos\projects\ory-kratos\lyx-core-lyx_core_ids\src\lib.rs
```rust
1: ### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\core\lyx-core-lyx-core-lyx_core_lyx-core-lyx_core_leptos\projects\ory-kratos\lyx-core-lyx_core_lyx-core-lyx_core_ids\src\lib.rs
2: ```rust
3: 1: pub static REGISTER_BUTTON_ID: &'static str = "register_button_id";
4: 2: pub static REGISTRATION_FORM_ID: &'static str = "registration_form_id";
5: 3: 
6: 4: pub static EMAIL_INPUT_ID: &'static str = "email_input_id";
7: 5: pub static PASSWORD_INPUT_ID: &'static str = "password_input_id";
8: 6: 
9: 7: pub static VERIFY_EMAIL_DIV_ID: &'static str = "verify_email_div_id";
10: 8: pub static VERIFICATION_FORM_ID: &'static str = "verification_form_id";
11: 9: 
12: 10: pub static LOGIN_FORM_ID: &'static str = "login_form_id";
13: 11: 
14: 12: pub static REGISTER_ROUTE: &'static str = "/register";
15: 13: pub static VERIFICATION_ROUTE: &'static str = "/verification";
16: 14: pub static LOGIN_ROUTE: &'static str = "/login";
17: 15: pub static KRATOS_ERROR_ROUTE: &'static str = "/kratos_error";
18: 16: pub static RECOVERY_ROUTE: &'static str = "/recovery";
19: 17: pub static SETTINGS_ROUTE: &'static str = "/settings";
20: 18: 
21: 19: pub static ERROR_ERROR_ID: &'static str = "error_template_id";
22: 20: pub static ERROR_COOKIES_ID: &'static str = "error_cookies_id";
23: 21: 
24: 22: pub static VERFICATION_CODE_ID: &'static str = "verification_code_id";
25: 23: 
26: 24: pub static KRATOS_FORM_SUBMIT_ID: &'static str = "kratos_form_submit_id";
27: 25: 
28: 26: pub static LOGOUT_BUTTON_ID: &'static str = "logout_button_id";
29: 27: pub static LOGIN_BUTTON_ID: &'static str = "login_button_id";
30: 28: /// This function is for use in kratos_html, it takes the name of the input node and it
31: 29: /// matches it according to what we've specified in the kratos schema file. If we change the schema.
32: 30: /// I.e use a phone instead of an email, the identifier id will change and break tests that expect an email.
33: 31: /// i.e use oidc instead of password, as auth method... that will break tests too.
34: 32: /// Which is good.
35: 33: pub fn match_name_to_id(name: String) -> &'static str {
36: 34:     match name.as_str() {
37: 35:         "traits.email" => EMAIL_INPUT_ID,
38: 36:         "identifier" => EMAIL_INPUT_ID,
39: 37:         "email" => EMAIL_INPUT_ID,
40: 38:         "password" => PASSWORD_INPUT_ID,
41: 39:         "code" => VERFICATION_CODE_ID,
42: 40:         "totp_code" => VERFICATION_CODE_ID,
43: 41:         _ => "",
44: 42:     }
45: 43: }
46: 44: 
47: 45: pub static POST_POST_TEXT_AREA_ID: &'static str = "post_post_text_area_id";
48: 46: pub static POST_POST_SUBMIT_ID: &'static str = "post_post_submit_id";
49: 47: pub static POST_ADD_EDITOR_BUTTON_ID: &'static str = "post_add_editor_button_id";
50: 48: pub static POST_ADD_EDITOR_INPUT_ID: &'static str = "add_editor_input_id";
51: 49: pub static POST_ADD_EDITOR_SUBMIT_ID: &'static str = "post_add_editor_submit_id";
52: 50: pub static POST_DELETE_ID: &'static str = "post_delete_id";
53: 51: pub static POST_EDIT_TEXT_AREA_ID: &'static str = "post_edit_text_area_id";
54: 52: pub static POST_EDIT_SUBMIT_ID: &'static str = "post_edit_submit_id";
55: 53: pub static POST_SHOW_LIST_BUTTON_ID: &'static str = "post_show_list_button_id";
56: 54: 
57: 55: pub static CLEAR_COOKIES_BUTTON_ID: &'static str = "clear_cookies_button_id";
58: 56: 
59: 57: pub static RECOVERY_FORM_ID: &'static str = "recovery_form_id";
60: 58: pub static RECOVER_EMAIL_BUTTON_ID: &'static str = "recover_email_button_id";
61: 59: 
62: 60: pub static RECOVERY_PASSWORD: &'static str = "RECOVERY_SuPeRsAfEpAsSwOrD1234!";
63: 61: pub static PASSWORD: &'static str = "SuPeRsAfEpAsSwOrD1234!";
64: 62: 
65: 63: pub static SETTINGS_FORM_ID: &'static str = "settings_form_id";
66: ```
```
