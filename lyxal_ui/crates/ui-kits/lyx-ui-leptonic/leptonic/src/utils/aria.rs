use std::{rc::Rc, str::FromStr};

use educe::Educe;
use leptos::*;

use super::props::IntoAttributeName;

#[derive(Debug, Clone)]
pub enum AriaAttribute {
    /// see: <https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles>
    Role(GenericAttribute<AriaRole>),
    /// see: <https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/LeptonicAttributes/aria-controls>
    Controls(GenericAttribute<AriaControls>),
    /// see: <https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/LeptonicAttributes/aria-haspopup>
    HasPopup(GenericAttribute<AriaHasPopup>),
    /// see: <https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/LeptonicAttributes/aria-expanded>
    Expanded(GenericAttribute<AriaExpanded>),
}

impl From<AriaAttribute> for (&'static str, LeptonicAttribute) {
    fn from(value: AriaAttribute) -> Self {
        let attr_name = value.to_attribute_name();
        match value {
            AriaAttribute::Role(val) => (attr_name, val.into_leptonic_attribute()),
            AriaAttribute::Controls(val) => (attr_name, val.into_leptonic_attribute()),
            AriaAttribute::HasPopup(val) => (attr_name, val.into_leptonic_attribute()),
            AriaAttribute::Expanded(val) => (attr_name, val.into_leptonic_attribute()),
        }
    }
}

impl IntoAttributeName for AriaAttribute {
    fn to_attribute_name(&self) -> &'static str {
        match self {
            Self::Role(_) => "role",
            Self::Controls(_) => "aria-controls",
            Self::HasPopup(_) => "aria-haspopup",
            Self::Expanded(_) => "aria-expanded",
        }
    }
}

impl std::fmt::Display for AriaAttribute {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        f.write_str(self.to_attribute_name())
    }
}

// ----------------------------------------------------------------------------------

#[derive(Clone, Educe)]
#[educe(Debug)]
pub enum GenericAttribute<T: LeptonicIntoLeptonicAttribute + 'static> {
    /// A plain value.
    Static(T),
    /// A (presumably reactive) function, which will be run inside an effect to do targeted updates to the LeptonicAttribute.
    Fn(#[educe(Debug(ignore))] Rc<dyn Fn() -> T>),
    /// An optional value, which sets the LeptonicAttribute to the value if `Some` and removes the LeptonicAttribute if `None`.
    Option(Option<T>),
    /// A boolean LeptonicAttribute, which sets the LeptonicAttribute if `true` and removes the LeptonicAttribute if `false`.
    Bool(bool),
}

impl<T: LeptonicIntoLeptonicAttribute + Clone + 'static, F: Fn() -> T + 'static> From<F> for GenericAttribute<T> {
    fn from(f: F) -> Self {
        Self::Fn(Rc::new(f))
    }
}

#[cfg(not(feature = "nightly"))]
impl<T: LeptonicIntoLeptonicAttribute + Clone + 'static> From<Signal<T>> for GenericAttribute<T> {
    fn from(signal: Signal<T>) -> Self {
        Self::Fn(Rc::new(move || signal.get()))
    }
}

impl<T: LeptonicIntoLeptonicAttribute + 'static> LeptonicIntoLeptonicAttribute for GenericAttribute<T> {
    fn into_leptonic_attribute(self) -> LeptonicAttribute {
        match self {
            GenericAttribute::Static(v) => v.into_leptonic_attribute(),
            GenericAttribute::Fn(v) => LeptonicAttribute::Fn(Rc::new(move || v().into_leptonic_attribute())),
            GenericAttribute::Option(v) => match v {
                Some(t) => t.into_leptonic_attribute(),
                None => LeptonicAttribute::Option(None),
            },
            GenericAttribute::Bool(v) => LeptonicAttribute::Bool(v),
        }
    }

    fn into_leptonic_attribute_boxed(self: Box<Self>) -> LeptonicAttribute {
        self.into_leptonic_attribute()
    }
}

// ----------------------------------------------------------------------------------

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AriaRole {
    /// See: <https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Roles/link_role>
    Link,
}

impl LeptonicIntoLeptonicAttribute for AriaRole {
    fn into_leptonic_attribute(self) -> LeptonicAttribute {
        match self {
            Self::Link => LeptonicAttribute::String(Oco::Borrowed("link")),
        }
    }

    fn into_leptonic_attribute_boxed(self: Box<Self>) -> LeptonicAttribute {
        self.into_leptonic_attribute()
    }
}

// ----------------------------------------------------------------------------------

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum AriaControls {
    // A space-separated list of one or more ID values referencing the elements being controlled by the current element.
    Id(Vec<String>),
    Undefined,
}

impl LeptonicIntoLeptonicAttribute for AriaControls {
    fn into_leptonic_attribute(self) -> LeptonicAttribute {
        match self {
            Self::Id(ids) => LeptonicAttribute::String(Oco::Owned(ids.join(" "))),
            Self::Undefined => LeptonicAttribute::Option(None),
        }
    }

    fn into_leptonic_attribute_boxed(self: Box<Self>) -> LeptonicAttribute {
        self.into_leptonic_attribute()
    }
}

// ----------------------------------------------------------------------------------

#[derive(Default, Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AriaHasPopup {
    // The element does not have a popup.
    #[default]
    False,

    /// The popup is a menu.
    True,

    /// The popup is a menu.
    Menu,

    /// The popup is a listbox.
    Listbox,

    /// The popup is a tree.
    Tree,

    /// The popup is a grid.
    Grid,

    /// The popup is a dialog.
    Dialog,
}

impl AriaHasPopup {
    pub fn into_str(self) -> &'static str {
        match self {
            Self::False => "false",
            Self::True => "true",
            Self::Menu => "menu",
            Self::Listbox => "listbox",
            Self::Tree => "tree",
            Self::Grid => "grid",
            Self::Dialog => "dialog",
        }
    }
}

impl LeptonicIntoLeptonicAttribute for AriaHasPopup {
    fn into_leptonic_attribute(self) -> LeptonicAttribute {
        LeptonicAttribute::String(self.into_str().into())
    }

    fn into_leptonic_attribute_boxed(self: Box<Self>) -> LeptonicAttribute {
        self.into_leptonic_attribute()
    }
}

// ----------------------------------------------------------------------------------

#[derive(Default, Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum AriaExpanded {
    // The element does not own or control a grouping element that is expandable.
    #[default]
    Undefined,

    // The grouping element this element owns or controls is collapsed.
    False,

    /// The grouping element this element owns or controls is expanded.
    True,
}

impl AriaExpanded {
    pub fn into_str(self) -> &'static str {
        match self {
            Self::Undefined => "undefined",
            Self::False => "false",
            Self::True => "true",
        }
    }
}

impl FromStr for AriaExpanded {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "undefined" => Ok(Self::Undefined),
            "false" => Ok(Self::False),
            "true" => Ok(Self::True),
            other => Err(format!(
                "String '{other}' is no a valid AriaExpanded variant."
            )),
        }
    }
}

impl From<bool> for AriaExpanded {
    fn from(value: bool) -> Self {
        match value {
            true => Self::True,
            false => Self::False,
        }
    }
}

// TODO: Do we want this impl? Is the None => Undefined mapping a valid assumption?
impl From<Option<bool>> for AriaExpanded {
    fn from(value: Option<bool>) -> Self {
        match value {
            Some(value) => Self::from(value),
            None => Self::Undefined,
        }
    }
}

impl LeptonicIntoLeptonicAttribute for AriaExpanded {
    fn into_leptonic_attribute(self) -> LeptonicAttribute {
        LeptonicAttribute::String(self.into_str().into())
    }

    fn into_leptonic_attribute_boxed(self: Box<Self>) -> LeptonicAttribute {
        LeptonicAttribute::String(self.into_str().into())
    }
}

// ----------------------------------------------------------------------------------
