use std::collections::HashMap;
use std::sync::Arc;
use leptos::Oco;
use leptos::prelude::{AttributeValue, IntoAttributeValue};

pub trait IntoAttributeName {
fn to_attribute_name(&self) -> &'static str;
}

impl IntoAttributeName for &'static str {
fn to_attribute_name(&self) -> &'static str {
self
}
}

#[derive(Debug, Clone)]
pub struct LeptonicAttributes {
pub map: HashMap<&'static str, LeptonicAttribute>,
}

impl LeptonicAttributes {
pub fn new() -> Self {
Self {
map: HashMap::new(),
}
}

pub fn insert(
&mut self,
k: impl IntoAttributeName,
v: LeptonicAttribute,
) -> Option<LeptonicAttribute> {
self.map.insert(k.to_attribute_name(), v)
}

pub fn insert_entry<IntoAttrName: IntoAttributeName>(
&mut self,
entry: (IntoAttrName, LeptonicAttribute),
) -> Option<LeptonicAttribute> {
let (k, v) = entry;
self.map.insert(k.to_attribute_name(), v)
}

pub fn merge(
&mut self,
iter: impl IntoIterator<Item = (&'static str, LeptonicAttribute)>,
) {
self.map.extend(iter);
}
}

impl IntoIterator for LeptonicAttributes {
type Item = (&'static str, LeptonicAttribute);
type IntoIter = std::collections::hash_map::IntoIter<&'static str, LeptonicAttribute>;

fn into_iter(self) -> Self::IntoIter {
self.map.into_iter()
}
}

#[derive(Clone)]
pub enum LeptonicAttribute {
String(Oco<'static, str>),
Fn(Arc<dyn Fn() -> LeptonicAttribute + Send + Sync>),
Bool(bool),
Option(Option<Oco<'static, str>>),
}

impl std::fmt::Debug for LeptonicAttribute {
fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
match self {
Self::String(s) => f.debug_tuple("String").field(s).finish(),
Self::Fn(_) => f.debug_tuple("Fn").finish(),
Self::Bool(b) => f.debug_tuple("Bool").field(b).finish(),
Self::Option(o) => f.debug_tuple("Option").field(o).finish(),
}
}
}

impl LeptonicAttribute {
pub fn prepend(&self, string: String) -> Self {
match self {
Self::String(s) => Self::String(Oco::Owned(format!("{string} {s}"))),
Self::Fn(f) => {
let f = f.clone();
Self::Fn(Arc::new(move || f().prepend(string.clone())))
}
Self::Option(o) => {
Self::Option(o.as_ref().map(|s| Oco::Owned(format!("{string} {s}"))))
}
Self::Bool(_) => panic!("Cannot prepend something to an LeptonicAttribute::Bool."),
}
}

pub fn into_leptonic_attribute_value(self) -> AttributeValue {
match self {
Self::String(s) => s.into_leptonic_attribute_value(),
Self::Bool(b) => b.into_leptonic_attribute_value(),
Self::Option(o) => o.into_leptonic_attribute_value(),
Self::Fn(f) => {
let f = f.clone();
(move || f().into_leptonic_attribute_value()).into_leptonic_attribute_value()
}
}
}
}

impl IntoAttributeValue for LeptonicAttribute {
fn into_leptonic_attribute_value(self) -> AttributeValue {
self.into_leptonic_attribute_value()
}
}

pub trait LeptonicIntoLeptonicAttribute {
fn into_leptonic_attribute(self) -> LeptonicAttribute;
}

impl LeptonicIntoLeptonicAttribute for String {
fn into_leptonic_attribute(self) -> LeptonicAttribute {
LeptonicAttribute::String(Oco::Owned(self))
}
}

impl LeptonicIntoLeptonicAttribute for &'static str {
fn into_leptonic_attribute(self) -> LeptonicAttribute {
LeptonicAttribute::String(Oco::Borrowed(self))
}
}

impl LeptonicIntoLeptonicAttribute for Oco<'static, str> {
fn into_leptonic_attribute(self) -> LeptonicAttribute {
LeptonicAttribute::String(self)
}
}

impl LeptonicIntoLeptonicAttribute for bool {
fn into_leptonic_attribute(self) -> LeptonicAttribute {
LeptonicAttribute::Bool(self)
}
}

impl LeptonicIntoLeptonicAttribute for LeptonicAttribute {
fn into_leptonic_attribute(self) -> LeptonicAttribute {
self
}
}
