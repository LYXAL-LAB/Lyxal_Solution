use crate::math::shared::use_binary_logic;
use leptos::prelude::*;
use leptos::reactive::wrappers::read::Signal;
use paste::paste;

use_binary_logic!(
/// Reactive `OR` condition.
///
/// ## Demo
///
/// [Link to Demo](https://github.com/Synphonyte/use/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/use_or)
///
/// ## Usage
///
/// /// # use leptos::prelude::*;
/// # use lyx_logic_use::math::use_or;
/// #
/// # #[component]
/// # fn Demo() -> impl IntoView {
/// let (a, set_a) = signal(true);
/// let (b, set_b) = signal(false);
///
/// let a_or_b = use_or(a, b);
/// #
/// # view! { }
/// # }
/// // #[doc(cfg(feature = "math"))]
or
||
);
