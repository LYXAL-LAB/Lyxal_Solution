//! Responsive design utilities for Tailwind CSS.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

/// Orientation of the viewport.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Orientation {
/// Portrait orientation (height >= width)
Portrait,
/// Landscape orientation (width > height)
Landscape,
}

/// Display density/PPI category.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum DisplayDensity {
/// Standard density (1x)
Standard,
/// High density / Retina (2x)
High,
/// Extra high density (3x)
ExtraHigh,
}

/// Hover capability of the device.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum HoverCapability {
/// Device supports hover (desktop)
Hover,
/// Device does not support hover (mobile/touch)
None,
}

/// Pointer type for the device.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum PointerType {
/// Fine pointer (mouse)
Fine,
/// Coarse pointer (touch/finger)
Coarse,
}

/// Breakpoint definitions for responsive design.
#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub enum Breakpoint {
/// Extra small screens (0-639px) - mobile first
Xs,
/// Small screens (640px and up)
Sm,
/// Medium screens (768px and up)
Md,
/// Large screens (1024px and up)
Lg,
/// Extra large screens (1280px and up)
Xl,
/// 2X large screens (1536px and up)
Xl2,
}

impl Breakpoint {
/// Get the breakpoint prefix for Tailwind classes.
pub fn prefix(&self) -> &'static str {
match self {
Breakpoint::Xs => "",
Breakpoint::Sm => "sm",
Breakpoint::Md => "md",
Breakpoint::Lg => "lg",
Breakpoint::Xl => "xl",
Breakpoint::Xl2 => "2xl",
}
}

/// Get the minimum width in pixels for this breakpoint.
pub fn min_width(&self) -> u32 {
match self {
Breakpoint::Xs => 0,
Breakpoint::Sm => 640,
Breakpoint::Md => 768,
Breakpoint::Lg => 1024,
Breakpoint::Xl => 1280,
Breakpoint::Xl2 => 1536,
}
}

/// Get the maximum width in pixels for this breakpoint.
pub fn max_width(&self) -> Option<u32> {
match self {
Breakpoint::Xs => Some(639),
Breakpoint::Sm => Some(767),
Breakpoint::Md => Some(1023),
Breakpoint::Lg => Some(1279),
Breakpoint::Xl => Some(1535),
Breakpoint::Xl2 => None,
}
}
}

/// A responsive design system that provides type-safe responsive classes.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct Responsive {
/// Classes for different breakpoints
pub breakpoints: HashMap<Breakpoint, String>,
}

impl Responsive {
/// Create a new Responsive instance.
pub fn new() -> Self {
Self {
breakpoints: HashMap::new(),
}
}

/// Add classes for a specific breakpoint.
pub fn breakpoint(mut self, breakpoint: Breakpoint, classes: impl Into<String>) -> Self {
self.breakpoints.insert(breakpoint, classes.into());
self
}

/// Add classes for small screens.
pub fn sm(self, classes: impl Into<String>) -> Self {
self.breakpoint(Breakpoint::Sm, classes)
}

/// Add classes for medium screens.
pub fn md(self, classes: impl Into<String>) -> Self {
self.breakpoint(Breakpoint::Md, classes)
}

/// Add classes for large screens.
pub fn lg(self, classes: impl Into<String>) -> Self {
self.breakpoint(Breakpoint::Lg, classes)
}

/// Add classes for extra large screens.
pub fn xl(self, classes: impl Into<String>) -> Self {
self.breakpoint(Breakpoint::Xl, classes)
}

/// Add classes for 2X large screens.
pub fn xl2(self, classes: impl Into<String>) -> Self {
self.breakpoint(Breakpoint::Xl2, classes)
}

/// Generate the final responsive class string.
pub fn to_string(&self) -> String {
let mut classes = Vec::new();

// Sort breakpoints by min-width to ensure proper order
let mut sorted_breakpoints: Vec<_> = self.breakpoints.iter().collect();
sorted_breakpoints.sort_by_key(|(bp, _)| bp.min_width());

for (breakpoint, class) in sorted_breakpoints {
classes.push(format!("{}:{}", breakpoint.prefix(), class));
}

classes.join(" ")
}

/// Merge with another Responsive instance.
pub fn merge(mut self, other: Responsive) -> Self {
for (breakpoint, classes) in other.breakpoints {
self.breakpoints.insert(breakpoint, classes);
}
self
}
}

impl Default for Responsive {
fn default() -> Self {
Self::new()
}
}

/// A builder for creating responsive designs with a fluent API.
#[derive(Debug, Default)]
pub struct ResponsiveBuilder {
responsive: Responsive,
}

impl ResponsiveBuilder {
/// Create a new ResponsiveBuilder.
pub fn new() -> Self {
Self {
responsive: Responsive::new(),
}
}

/// Add classes for small screens.
pub fn sm(mut self, classes: impl Into<String>) -> Self {
self.responsive = self.responsive.sm(classes);
self
}

/// Add classes for medium screens.
pub fn md(mut self, classes: impl Into<String>) -> Self {
self.responsive = self.responsive.md(classes);
self
}

/// Add classes for large screens.
pub fn lg(mut self, classes: impl Into<String>) -> Self {
self.responsive = self.responsive.lg(classes);
self
}

/// Add classes for extra large screens.
pub fn xl(mut self, classes: impl Into<String>) -> Self {
self.responsive = self.responsive.xl(classes);
self
}

/// Add classes for 2X large screens.
pub fn xl2(mut self, classes: impl Into<String>) -> Self {
self.responsive = self.responsive.xl2(classes);
self
}

/// Build the final Responsive instance.
pub fn build(self) -> Responsive {
self.responsive
}
}

/// Utility function to create a ResponsiveBuilder.
pub fn responsive() -> ResponsiveBuilder {
ResponsiveBuilder::new()
}

/// Predefined responsive patterns for common use cases.
pub mod patterns {
use super::*;

/// Mobile-first text sizing pattern.
pub fn text_sizing() -> Responsive {
Responsive::new()
.sm("text-sm")
.md("text-base")
.lg("text-lg")
.xl("text-xl")
}

/// Mobile-first spacing pattern.
pub fn spacing() -> Responsive {
Responsive::new()
.sm("p-2")
.md("p-4")
.lg("p-6")
.xl("p-8")
}

/// Mobile-first grid pattern.
pub fn grid() -> Responsive {
Responsive::new()
.sm("grid-cols-1")
.md("grid-cols-2")
.lg("grid-cols-3")
.xl("grid-cols-4")
}

/// Mobile-first flex pattern.
pub fn flex() -> Responsive {
Responsive::new()
.sm("flex-col")
.md("flex-row")
}

/// Mobile-first visibility pattern.
pub fn visibility() -> Responsive {
Responsive::new()
.sm("hidden")
.md("block")
}
}

/// Utility functions for responsive design.
pub mod utils {
use super::*;

/// Create a responsive instance from a string.
pub fn from_string(input: &str) -> Responsive {
let mut responsive = Responsive::new();
let parts: Vec<&str> = input.split_whitespace().collect();

for part in parts {
if let Some((prefix, class)) = part.split_once(':') {
let breakpoint = match prefix {
"sm" => Breakpoint::Sm,
"md" => Breakpoint::Md,
"lg" => Breakpoint::Lg,
"xl" => Breakpoint::Xl,
"2xl" => Breakpoint::Xl2,
_ => continue,
};
responsive = responsive.breakpoint(breakpoint, class);
}
}

responsive
}

/// Get all available breakpoints.
pub fn all_breakpoints() -> Vec<Breakpoint> {
vec![
Breakpoint::Xs,
Breakpoint::Sm,
Breakpoint::Md,
Breakpoint::Lg,
Breakpoint::Xl,
Breakpoint::Xl2,
]
}

/// Check if a breakpoint is active based on screen width.
pub fn is_breakpoint_active(breakpoint: &Breakpoint, screen_width: u32) -> bool {
screen_width >= breakpoint.min_width()
}

/// Get the current breakpoint based on screen width.
pub fn get_breakpoint(screen_width: u32) -> Breakpoint {
match screen_width {
0..=639 => Breakpoint::Xs,
640..=767 => Breakpoint::Sm,
768..=1023 => Breakpoint::Md,
1024..=1279 => Breakpoint::Lg,
1280..=1535 => Breakpoint::Xl,
_ => Breakpoint::Xl2,
}
}

/// Check if the screen is in mobile range.
pub fn is_mobile(screen_width: u32) -> bool {
screen_width < 768
}

/// Check if the screen is in tablet range.
pub fn is_tablet(screen_width: u32) -> bool {
screen_width >= 768 && screen_width < 1024
}

/// Check if the screen is in desktop range.
pub fn is_desktop(screen_width: u32) -> bool {
screen_width >= 1024
}
}

/// Viewport information for responsive design.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Viewport {
/// Current width of the viewport in pixels
pub width: u32,
/// Current height of the viewport in pixels
pub height: u32,
/// Current orientation of the viewport
pub orientation: Orientation,
/// Device pixel ratio for high-DPI displays
pub device_pixel_ratio: f32,
/// Whether the device supports hover
pub hover_capability: HoverCapability,
/// Pointer type of the device
pub pointer_type: PointerType,
}

impl Viewport {
/// Create a new Viewport instance.
pub fn new(width: u32, height: u32) -> Self {
let orientation = if height >= width {
Orientation::Portrait
} else {
Orientation::Landscape
};

Self {
width,
height,
orientation,
device_pixel_ratio: 1.0,
hover_capability: HoverCapability::Hover,
pointer_type: PointerType::Fine,
}
}

/// Create a viewport with full device information.
pub fn with_device_info(
width: u32,
height: u32,
device_pixel_ratio: f32,
hover: HoverCapability,
pointer: PointerType,
) -> Self {
let orientation = if height >= width {
Orientation::Portrait
} else {
Orientation::Landscape
};

Self {
width,
height,
orientation,
device_pixel_ratio,
hover_capability: hover,
pointer_type: pointer,
}
}

/// Get the current breakpoint based on viewport width.
pub fn breakpoint(&self) -> Breakpoint {
utils::get_breakpoint(self.width)
}

/// Check if the viewport is in mobile range.
pub fn is_mobile(&self) -> bool {
utils::is_mobile(self.width)
}

/// Check if the viewport is in tablet range.
pub fn is_tablet(&self) -> bool {
utils::is_tablet(self.width)
}

/// Check if the viewport is in desktop range.
pub fn is_desktop(&self) -> bool {
utils::is_desktop(self.width)
}

/// Check if the device supports hover.
pub fn can_hover(&self) -> bool {
self.hover_capability == HoverCapability::Hover
}

/// Check if the device has a fine pointer (mouse).
pub fn has_fine_pointer(&self) -> bool {
self.pointer_type == PointerType::Fine
}

/// Get the display density category.
pub fn display_density(&self) -> DisplayDensity {
if self.device_pixel_ratio >= 3.0 {
DisplayDensity::ExtraHigh
} else if self.device_pixel_ratio >= 2.0 {
DisplayDensity::High
} else {
DisplayDensity::Standard
}
}

/// Get the minimum touch target size for this device.
/// Returns 44px for touch devices (iOS/Android standard),
/// or 24px for mouse-only devices.
pub fn min_touch_target(&self) -> u32 {
if self.pointer_type == PointerType::Coarse {
44
} else {
24
}
}

/// Get responsive classes based on current viewport.
pub fn responsive_classes(&self) -> String {
let bp = self.breakpoint();
let mut classes = Vec::new();

// Add breakpoint-specific base classes
match bp {
Breakpoint::Xs => classes.push("text-sm px-3 py-2"),
Breakpoint::Sm => classes.push("text-sm px-4 py-2"),
Breakpoint::Md => classes.push("text-base px-4 py-2"),
Breakpoint::Lg => classes.push("text-base px-6 py-3"),
Breakpoint::Xl => classes.push("text-lg px-6 py-3"),
Breakpoint::Xl2 => classes.push("text-lg px-8 py-4"),
}

// Add touch-specific adjustments
if self.pointer_type == PointerType::Coarse {
classes.push("min-w-[44px] min-h-[44px]");
}

classes.join(" ")
}

/// Update the viewport dimensions.
pub fn update_dimensions(&mut self, width: u32, height: u32) {
self.width = width;
self.height = height;
self.orientation = if height >= width {
Orientation::Portrait
} else {
Orientation::Landscape
};
}
}

impl Default for Viewport {
fn default() -> Self {
Self::new(1024, 768)
}
}

/// A media query helper for generating CSS media queries.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct MediaQuery {
/// The media query condition
pub condition: String,
}

impl MediaQuery {
/// Create a new media query with a custom condition.
pub fn new(condition: impl Into<String>) -> Self {
Self {
condition: condition.into(),
}
}

/// Create a min-width media query.
pub fn min_width(width: u32) -> Self {
Self::new(format!("(min-width: {}px)", width))
}

/// Create a max-width media query.
pub fn max_width(width: u32) -> Self {
Self::new(format!("(max-width: {}px)", width))
}

/// Create a media query for a range of widths.
pub fn width_range(min: u32, max: u32) -> Self {
Self::new(format!("(min-width: {}px) and (max-width: {}px)", min, max))
}

/// Create an orientation media query.
pub fn orientation(orientation: Orientation) -> Self {
match orientation {
Orientation::Portrait => Self::new("(orientation: portrait)"),
Orientation::Landscape => Self::new("(orientation: landscape)"),
}
}

/// Create a hover media query.
pub fn hover() -> Self {
Self::new("(hover: hover)")
}

/// Create a no-hover media query.
pub fn no_hover() -> Self {
Self::new("(hover: none)")
}

/// Create a pointer media query.
pub fn pointer(pointer: PointerType) -> Self {
match pointer {
PointerType::Fine => Self::new("(pointer: fine)"),
PointerType::Coarse => Self::new("(pointer: coarse)"),
}
}

/// Create a high-DPI media query.
pub fn high_dpi() -> Self {
Self::new("(-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi)")
}

/// Generate the CSS @media rule.
pub fn to_css(&self, content: &str) -> String {
format!("@media {} {{\n{}\n}}", self.condition, content)
}

/// Generate the CSS @media rule with a selector.
pub fn to_css_with_selector(&self, selector: &str, content: &str) -> String {
format!(
"@media {} {{\n{} {{\n{}\n}}\n}}",
self.condition, selector, content
)
}
}

/// Utility functions for creating common media queries.
pub mod media_queries {
use super::*;

/// Mobile-first media query (max-width: 767px).
pub fn mobile_only() -> MediaQuery {
MediaQuery::max_width(767)
}

/// Tablet media query (min-width: 768px and max-width: 1023px).
pub fn tablet_only() -> MediaQuery {
MediaQuery::width_range(768, 1023)
}

/// Desktop media query (min-width: 1024px).
pub fn desktop_only() -> MediaQuery {
MediaQuery::min_width(1024)
}

/// Touch devices media query.
pub fn touch_devices() -> String {
"@media (hover: none) and (pointer: coarse)".to_string()
}

/// Mouse devices media query.
pub fn mouse_devices() -> String {
"@media (hover: hover) and (pointer: fine)".to_string()
}

/// Portrait orientation media query.
pub fn portrait() -> MediaQuery {
MediaQuery::orientation(Orientation::Portrait)
}

/// Landscape orientation media query.
pub fn landscape() -> MediaQuery {
MediaQuery::orientation(Orientation::Landscape)
}

/// Print media query.
pub fn print() -> MediaQuery {
MediaQuery::new("print")
}

/// Reduced motion media query for accessibility.
pub fn prefers_reduced_motion() -> MediaQuery {
MediaQuery::new("(prefers-reduced-motion: reduce)")
}

/// Dark mode media query.
pub fn prefers_dark() -> MediaQuery {
MediaQuery::new("(prefers-color-scheme: dark)")
}

/// Light mode media query.
pub fn prefers_light() -> MediaQuery {
MediaQuery::new("(prefers-color-scheme: light)")
}

/// High contrast media query.
pub fn prefers_high_contrast() -> MediaQuery {
MediaQuery::new("(prefers-contrast: high)")
}
}

#[cfg(test)]
mod tests {
use super::*;

#[test]
fn test_breakpoint_prefix() {
assert_eq!(Breakpoint::Xs.prefix(), "");
assert_eq!(Breakpoint::Sm.prefix(), "sm");
assert_eq!(Breakpoint::Md.prefix(), "md");
assert_eq!(Breakpoint::Lg.prefix(), "lg");
assert_eq!(Breakpoint::Xl.prefix(), "xl");
assert_eq!(Breakpoint::Xl2.prefix(), "2xl");
}

#[test]
fn test_breakpoint_min_width() {
assert_eq!(Breakpoint::Xs.min_width(), 0);
assert_eq!(Breakpoint::Sm.min_width(), 640);
assert_eq!(Breakpoint::Md.min_width(), 768);
assert_eq!(Breakpoint::Lg.min_width(), 1024);
assert_eq!(Breakpoint::Xl.min_width(), 1280);
assert_eq!(Breakpoint::Xl2.min_width(), 1536);
}

#[test]
fn test_responsive_creation() {
let responsive = Responsive::new()
.sm("text-sm")
.md("text-base")
.lg("text-lg");

let result = responsive.to_string();
assert!(result.contains("sm:text-sm"));
assert!(result.contains("md:text-base"));
assert!(result.contains("lg:text-lg"));
}

#[test]
fn test_responsive_builder() {
let responsive = responsive()
.sm("p-2")
.md("p-4")
.lg("p-6")
.build();

let result = responsive.to_string();
assert!(result.contains("sm:p-2"));
assert!(result.contains("md:p-4"));
assert!(result.contains("lg:p-6"));
}

#[test]
fn test_responsive_merge() {
let responsive1 = Responsive::new()
.sm("text-sm")
.md("text-base");

let responsive2 = Responsive::new()
.lg("text-lg")
.xl("text-xl");

let merged = responsive1.merge(responsive2);
let result = merged.to_string();

assert!(result.contains("sm:text-sm"));
assert!(result.contains("md:text-base"));
assert!(result.contains("lg:text-lg"));
assert!(result.contains("xl:text-xl"));
}

#[test]
fn test_patterns() {
let text_sizing = patterns::text_sizing();
let result = text_sizing.to_string();

assert!(result.contains("sm:text-sm"));
assert!(result.contains("md:text-base"));
assert!(result.contains("lg:text-lg"));
assert!(result.contains("xl:text-xl"));
}

#[test]
fn test_utils_from_string() {
let responsive = utils::from_string("sm:text-sm md:text-base lg:text-lg");
let result = responsive.to_string();

assert!(result.contains("sm:text-sm"));
assert!(result.contains("md:text-base"));
assert!(result.contains("lg:text-lg"));
}

#[test]
fn test_utils_is_breakpoint_active() {
assert!(utils::is_breakpoint_active(&Breakpoint::Sm, 640));
assert!(utils::is_breakpoint_active(&Breakpoint::Sm, 800));
assert!(!utils::is_breakpoint_active(&Breakpoint::Sm, 500));

assert!(utils::is_breakpoint_active(&Breakpoint::Md, 768));
assert!(utils::is_breakpoint_active(&Breakpoint::Md, 1000));
assert!(!utils::is_breakpoint_active(&Breakpoint::Md, 700));
}

#[test]
fn test_utils_get_breakpoint() {
assert_eq!(utils::get_breakpoint(500), Breakpoint::Xs);
assert_eq!(utils::get_breakpoint(640), Breakpoint::Sm);
assert_eq!(utils::get_breakpoint(768), Breakpoint::Md);
assert_eq!(utils::get_breakpoint(1024), Breakpoint::Lg);
assert_eq!(utils::get_breakpoint(1280), Breakpoint::Xl);
assert_eq!(utils::get_breakpoint(1600), Breakpoint::Xl2);
}

#[test]
fn test_viewport_creation() {
let viewport = Viewport::new(1920, 1080);
assert_eq!(viewport.width, 1920);
assert_eq!(viewport.height, 1080);
assert_eq!(viewport.orientation, Orientation::Landscape);
assert!(viewport.is_desktop());
}

#[test]
fn test_viewport_mobile() {
let viewport = Viewport::new(375, 667);
assert_eq!(viewport.orientation, Orientation::Portrait);
assert!(viewport.is_mobile());
assert!(!viewport.is_tablet());
assert!(!viewport.is_desktop());
}

#[test]
fn test_viewport_touch_target() {
let mobile = Viewport::with_device_info(
375,
667,
2.0,
HoverCapability::None,
PointerType::Coarse,
);
assert_eq!(mobile.min_touch_target(), 44);

let desktop = Viewport::with_device_info(
1920,
1080,
1.0,
HoverCapability::Hover,
PointerType::Fine,
);
assert_eq!(desktop.min_touch_target(), 24);
}

#[test]
fn test_media_query() {
let mq = MediaQuery::min_width(768);
assert_eq!(mq.condition, "(min-width: 768px)");

let css = mq.to_css("body { font-size: 16px; }");
assert!(css.contains("@media (min-width: 768px)"));
}
}
