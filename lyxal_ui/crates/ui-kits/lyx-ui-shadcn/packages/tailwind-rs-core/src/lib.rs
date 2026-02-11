### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
### C:\Users\Administrator\Downloads\zed-0.222.1-pre\lyxal_ui\crates\ui-kits\lyx_ui_shadcn\packages\tailwind-rs-core\src\lib.rs
```rust
//! # tailwind-rs-core
//! 
//! Type-safe Tailwind CSS class generation for Rust web frameworks.
//! 
//! This crate provides compile-time validation and type-safe generation of Tailwind CSS classes,
//! with support for dynamic styling, responsive design, and theme systems.
//! 
//! ## Features
//! 
//! - 🛡️ **Type Safety**: Compile-time validation of Tailwind classes
//! - ⚡ **Performance**: Optimized class generation and merging
//! - 🎨 **Dynamic Styling**: Runtime class generation with type safety
//! - 📱 **Responsive**: Type-safe responsive design utilities
//! - 🎭 **Theming**: Built-in theme and variant system
//! - 🔧 **Framework Agnostic**: Works with any Rust web framework
//! 
//! ## Quick Start
//! 
//! ```rust
//! use tailwind_rs_core::*;
//! 
//! // Type-safe class generation
//! let classes = classes! {
//!     base: "px-4 py-2 rounded-md font-medium",
//!     variant: "bg-blue-600 text-white hover:bg-blue-700",
//!     responsive: "sm:text-sm md:text-base lg:text-lg",
//! };
//! 
//! // Dynamic styling with type safety
//! let color = Color::Blue;
//! let dynamic_classes = classes! {
//!     background: color.background(600),
//!     text: color.text(),
//!     hover: color.hover(700),
//! };
//! ```
//! 
//! ## Integration with Leptos
//! 
//! ```rust
//! use leptos::*;
//! use tailwind_rs_core::*;
//! 
//! #[component]
//! pub fn Button(variant: ButtonVariant) -> impl IntoView {
//!     let classes = classes! {
//!         base: "px-4 py-2 rounded-md font-medium transition-colors",
//!         variant: match variant {
//!             ButtonVariant::Primary => "bg-blue-600 text-white hover:bg-blue-700",
//!             ButtonVariant::Secondary => "bg-gray-200 text-gray-900 hover:bg-gray-300",
//!         },
//!     };
//!     
//!     view! { <button class=classes>"Click me"</button> }
//! }
//! ```

pub mod classes;
pub mod colors;
pub mod responsive;
pub mod themes;
pub mod validation;

// Re-export main types and macros
pub use classes::*;
pub use colors::*;
pub use responsive::*;
pub use themes::*;
pub use validation::*;

// Re-export specific items to avoid conflicts
pub use colors::utils as color_utils;
pub use responsive::utils as responsive_utils;
pub use responsive::media_queries;
pub use responsive::patterns;

// Re-export macros (when available)
// #[cfg(feature = "macros")]
// pub use tailwind_rs_core_macros::*;

#[cfg(feature = "leptos")]
pub mod leptos_integration;

#[cfg(feature = "leptos")]
pub use leptos_integration::*;
```
```
```
```
```
```
```
```
```
```
```
```
```
```
