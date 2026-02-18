use crate::math::shared::use_simple_math;
use leptos::prelude::*;
use leptos::reactive::wrappers::read::Signal;
use num::Float;
use paste::paste;

use_simple_math!(
/// Reactive `round()`.
///
/// ## Demo
///
/// [Link to Demo](https://github.com/Synphonyte/use/tree/main/lyx-ui-foundations-lyx_ui_foundations_lyx-ui-foundations-lyx_ui_foundations_examples/use_round)
///
/// ## Usage
///
/// /// # use leptos::prelude::*;
/// # use lyx_logic_use::math::use_round;
/// #
/// # #[component]
/// # fn Demo() -> impl IntoView {
/// let (value, set_value) = signal(45.95);
/// let result: Signal<f64> = use_round(value); // 46
/// #
/// # assert_eq!(result.get(), 46.0);
/// # view! { }
/// # }
/// // #[doc(cfg(feature = "math"))]
round
);
