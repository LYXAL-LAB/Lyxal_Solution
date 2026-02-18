//! Leptos port of shadcn/ui slider

mod signal_managed;
mod default;
mod new_york;

pub use default::{
Slider, RangeSlider, SliderRoot, SliderVariant, SliderSize
};
pub use new_york::{
Slider as SliderNewYork, RangeSlider as RangeSliderNewYork,
SliderRoot as SliderRootNewYork, SliderVariant as SliderVariantNewYork,
SliderSize as SliderSizeNewYork
};

mod tests;

mod tdd_tests;

// Signal-managed exports
pub use signal_managed::*;
