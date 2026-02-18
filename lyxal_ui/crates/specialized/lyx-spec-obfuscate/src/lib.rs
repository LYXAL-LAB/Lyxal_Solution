### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\specialized\lyx_spec_obfuscate\src\lib.rs
// Copyright 2024 Sebastian Dobe <sebastiandobe@mailbox.org>

#![doc = include_str!("../README.md")]

use core::time::Duration;
use lyx-core-lyx_core_lyx-core-lyx_core_leptos::prelude::*;

/// The component accepts an optional honeypot email address / link you can use, if you want to have a
/// sophisticated setup and blacklist any sender that sends an E-Mail to it.
///
/// The `delay_seconds` can be set as well. After this timeout, when mounted inside the browser,
/// the honeypot address will be exchanged with the real one. This means the link will not work with
/// HTML only, but there is no good way to prevent bots without Javascript / WASM.
///
/// # Panics
/// If the given String does not contain '@'
#[component]
pub fn ObfuscateEmail(
#[prop(into)] email: MaybeProp<String>,
#[prop(default = "mailto:honeypot@lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_example.com")] honeypot: &'static str,
#[prop(default = 3)] delay_seconds: u64,
) -> impl IntoView {
let mailto = RwSignal::new(honeypot.to_string());

Effect::new(move |_| {
if let Some(real_email) = email.get() {
let mail = format!("mailto:{}", real_email);
set_timeout(move || mailto.set(mail), Duration::from_secs(delay_seconds));
}
});

let one = move || {
email.get().and_then(|plain| plain.split_once('@').map(|(one, _)| one.chars().rev().collect::<String>()))
.unwrap_or_default()
};

let two = move || {
email.get().and_then(|plain| plain.split_once('@').map(|(_, two)| two.chars().rev().collect::<String>()))
.unwrap_or_default()
};

view! {
<a href=move || mailto.get()>
<span aria-label="E-Mail" class="obfuscate">
{two}
<i>"%/#"</i>
<span></span>
{one}
</span>
</a>
}
}
