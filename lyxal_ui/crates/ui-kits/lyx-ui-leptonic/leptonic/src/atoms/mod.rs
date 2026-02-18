use crate::LeptonicAttribute;
use std::sync::Arc;
use leptos::prelude::Oco;

pub mod button;
pub mod button_group;
pub mod hoverable;
pub mod link;
pub mod press;
pub mod popover;

pub mod prelude {
pub use super::button::Button;
pub use super::button_group::ButtonGroup;
pub use super::hoverable::Hoverable;
pub use super::link::AnchorLink;
pub use super::popover::Popover;
pub use super::popover::PopoverContent;
pub use super::popover::PopoverTrigger;
}

trait AttributeExt {
fn prepend(self, string: Oco<'static, str>) -> Self;
}

impl AttributeExt for LeptonicAttribute {
fn prepend(self, string: Oco<'static, str>) -> Self {
match self {
LeptonicAttribute::String(s) => LeptonicAttribute::String(Oco::Owned(format!("{string} {}", s))),
LeptonicAttribute::Fn(f) => {
let f = f.clone();
LeptonicAttribute::Fn(Arc::new(move || f().prepend(string.to_string())))
},
LeptonicAttribute::Option(o) => {
LeptonicAttribute::Option(o.map(|s| Oco::Owned(format!("{string} {}", s))))
}
LeptonicAttribute::Bool(_) => panic!("Cannot prepend something to an LeptonicAttribute::Bool."),
}
}
}
