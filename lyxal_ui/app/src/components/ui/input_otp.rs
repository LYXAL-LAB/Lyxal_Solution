use leptos::prelude::*;
use leptos_ui::void;

mod components {
    use super::*;
    void! {InputOTPSlot, input, "size-16 text-xl font-semibold text-center text-gray-700 bg-gray-100 rounded-md border border-gray-300 transition-all focus:border-blue-500 outline-hidden"}
}

pub use components::*;

/* ========================================================== */
/*                     ✨ FUNCTIONS ✨                        */
/* ========================================================== */

#[component]
pub fn InputOTP(children: Children) -> impl IntoView {
    view! {
        <div data-name="InputOTP" class="flex gap-2.5 justify-center items-center">
            {children()}
        </div>

        <script src="/components/otp.js" />
    }
}