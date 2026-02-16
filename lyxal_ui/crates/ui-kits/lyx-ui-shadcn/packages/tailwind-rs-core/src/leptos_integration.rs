//! Leptos integration for tailwind-rs-core.

#[cfg(feature = "leptos")]
use leptos::prelude::*;
#[cfg(feature = "leptos")]
use crate::{TailwindClasses, Color, Responsive, Viewport, Breakpoint, Orientation};

#[cfg(feature = "leptos")]
/// A Leptos-compatible class signal that provides reactive styling.
#[derive(Debug, Clone)]
pub struct ClassSignal {
    /// The current classes
    pub classes: ReadSignal<String>,
    /// The setter for classes
    pub set_classes: WriteSignal<String>,
}

#[cfg(feature = "leptos")]
impl ClassSignal {
    /// Create a new ClassSignal with initial classes.
    pub fn new(initial_classes: impl Into<String>) -> Self {
        let (classes, set_classes) = signal(initial_classes.into());
        Self { classes, set_classes }
    }

    /// Create a new ClassSignal from a TailwindClasses instance.
    pub fn from_tailwind_classes(classes: TailwindClasses) -> Self {
        Self::new(classes.to_string())
    }

    /// Update the classes with a new TailwindClasses instance.
    pub fn update(&self, classes: TailwindClasses) {
        self.set_classes.set(classes.to_string());
    }

    /// Merge new classes with existing ones.
    pub fn merge(&self, new_classes: impl Into<String>) {
        let current = self.classes.get();
        let merged = format!("{} {}", current, new_classes.into());
        self.set_classes.set(merged);
    }

    /// Get the current classes as a string.
    pub fn get(&self) -> String {
        self.classes.get()
    }

    /// Set the classes to a new value.
    pub fn set(&self, classes: impl Into<String>) {
        self.set_classes.set(classes.into());
    }
}

#[cfg(feature = "leptos")]
/// A simple theme manager that provides reactive theme switching.
#[derive(Debug, Clone)]
pub struct ThemeSignal {
    /// The current theme name
    pub theme_name: ReadSignal<String>,
    /// The setter for theme name
    pub set_theme_name: WriteSignal<String>,
}

#[cfg(feature = "leptos")]
impl ThemeSignal {
    /// Create a new ThemeSignal with the default theme.
    pub fn new(initial_theme_name: impl Into<String>) -> Self {
        let (theme_name, set_theme_name) = signal(initial_theme_name.into());
        Self { theme_name, set_theme_name }
    }

    /// Set a new theme by name.
    pub fn set_theme(&self, theme_name: impl Into<String>) {
        self.set_theme_name.set(theme_name.into());
    }

    /// Switch to the next theme in the cycle.
    pub fn next_theme(&self) {
        let current = self.theme_name.get();
        let next = match current.as_str() {
            "default" => "dark",
            "dark" => "light",
            "light" => "high-contrast",
            "high-contrast" => "monochrome",
            "monochrome" => "default",
            _ => "default",
        };
        self.set_theme(next);
    }

    /// Switch to the previous theme in the cycle.
    pub fn prev_theme(&self) {
        let current = self.theme_name.get();
        let prev = match current.as_str() {
            "default" => "monochrome",
            "dark" => "default",
            "light" => "dark",
            "high-contrast" => "light",
            "monochrome" => "high-contrast",
            _ => "default",
        };
        self.set_theme(prev);
    }
}

#[cfg(feature = "leptos")]
/// A simple color manager that provides reactive color switching.
#[derive(Debug, Clone)]
pub struct ColorSignal {
    /// The current color
    pub color: ReadSignal<Color>,
    /// The setter for color
    pub set_color: WriteSignal<Color>,
}

#[cfg(feature = "leptos")]
impl ColorSignal {
    /// Create a new ColorSignal with an initial color.
    pub fn new(initial_color: Color) -> Self {
        let (color, set_color) = signal(initial_color);
        Self { color, set_color }
    }

    /// Set a new color.
    pub fn set_color(&self, color: Color) {
        self.set_color.set(color);
    }

    /// Switch to the next color in the cycle.
    pub fn next_color(&self) {
        let current = self.color.get();
        let next = match current {
            Color::Blue => Color::Green,
            Color::Green => Color::Purple,
            Color::Purple => Color::Orange,
            Color::Orange => Color::Red,
            Color::Red => Color::Yellow,
            Color::Yellow => Color::Pink,
            Color::Pink => Color::Indigo,
            Color::Indigo => Color::Gray,
            Color::Gray => Color::Blue,
            _ => Color::Blue,
        };
        self.set_color.set(next);
    }
}

#[cfg(feature = "leptos")]
/// A simple responsive manager that provides reactive responsive design.
#[derive(Debug, Clone)]
pub struct ResponsiveSignal {
    /// The current responsive settings
    pub responsive: ReadSignal<Responsive>,
    /// The setter for responsive settings
    pub set_responsive: WriteSignal<Responsive>,
}

#[cfg(feature = "leptos")]
impl ResponsiveSignal {
    /// Create a new ResponsiveSignal with initial settings.
    pub fn new(initial_responsive: Responsive) -> Self {
        let (responsive, set_responsive) = signal(initial_responsive);
        Self { responsive, set_responsive }
    }

    /// Set new responsive settings.
    pub fn set_responsive(&self, responsive: Responsive) {
        self.set_responsive.set(responsive);
    }
}

#[cfg(feature = "leptos")]
/// A viewport signal that provides reactive viewport information for responsive design.
#[derive(Debug, Clone)]
pub struct ViewportSignal {
    /// The current viewport
    pub viewport: ReadSignal<Viewport>,
    /// The setter for viewport
    pub set_viewport: WriteSignal<Viewport>,
    /// The current breakpoint (derived from viewport width)
    pub breakpoint: Memo<Breakpoint>,
    /// Whether the viewport is mobile
    pub is_mobile: Memo<bool>,
    /// Whether the viewport is tablet
    pub is_tablet: Memo<bool>,
    /// Whether the viewport is desktop
    pub is_desktop: Memo<bool>,
    /// Current orientation
    pub orientation: Memo<Orientation>,
}

#[cfg(feature = "leptos")]
impl ViewportSignal {
    /// Create a new ViewportSignal with default viewport.
    pub fn new() -> Self {
        Self::with_viewport(Viewport::default())
    }

    /// Create a new ViewportSignal with a specific viewport.
    pub fn with_viewport(initial_viewport: Viewport) -> Self {
        let (viewport, set_viewport) = signal(initial_viewport);

        let breakpoint = Memo::new({
            let viewport = viewport.clone();
            move |_| viewport.get().breakpoint()
        });

        let is_mobile = Memo::new({
            let viewport = viewport.clone();
            move |_| viewport.get().is_mobile()
        });

        let is_tablet = Memo::new({
            let viewport = viewport.clone();
            move |_| viewport.get().is_tablet()
        });

        let is_desktop = Memo::new({
            let viewport = viewport.clone();
            move |_| viewport.get().is_desktop()
        });

        let orientation = Memo::new({
            let viewport = viewport.clone();
            move |_| viewport.get().orientation
        });

        Self {
            viewport,
            set_viewport,
            breakpoint,
            is_mobile,
            is_tablet,
            is_desktop,
            orientation,
        }
    }

    /// Create from width and height.
    pub fn from_dimensions(width: u32, height: u32) -> Self {
        Self::with_viewport(Viewport::new(width, height))
    }

    /// Update the viewport dimensions.
    pub fn update_dimensions(&self, width: u32, height: u32) {
        let mut vp = self.viewport.get();
        vp.update_dimensions(width, height);
        self.set_viewport.set(vp);
    }

    /// Set a new viewport.
    pub fn set_viewport_value(&self, viewport: Viewport) {
        self.set_viewport.set(viewport);
    }

    /// Get responsive classes based on current viewport.
    pub fn responsive_classes(&self) -> String {
        self.viewport.get().responsive_classes()
    }

    /// Check if the device supports hover.
    pub fn can_hover(&self) -> bool {
        self.viewport.get().can_hover()
    }

    /// Check if the device has a fine pointer.
    pub fn has_fine_pointer(&self) -> bool {
        self.viewport.get().has_fine_pointer()
    }

    /// Get the minimum touch target size.
    pub fn min_touch_target(&self) -> u32 {
        self.viewport.get().min_touch_target()
    }

    /// Get the current viewport as a string for debugging.
    pub fn debug_string(&self) -> String {
        let vp = self.viewport.get();
        format!(
            "Viewport: {}x{}, {}, {:?}",
            vp.width, vp.height, vp.breakpoint().prefix(), vp.orientation
        )
    }
}

#[cfg(feature = "leptos")]
impl Default for ViewportSignal {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(feature = "leptos")]
/// Helper functions for creating dynamic classes with tailwind-rs-core
pub mod helpers {
    use super::*;

    /// Create theme classes based on theme name
    pub fn theme_classes(theme_name: &str) -> String {
        match theme_name {
            "default" => "bg-white text-gray-900 border-gray-200".to_string(),
            "dark" => "bg-gray-900 text-white border-gray-700".to_string(),
            "light" => "bg-gray-50 text-gray-900 border-gray-200".to_string(),
            "high-contrast" => "bg-black text-white border-white".to_string(),
            "monochrome" => "bg-gray-100 text-gray-800 border-gray-400".to_string(),
            _ => "bg-white text-gray-900 border-gray-200".to_string(),
        }
    }

    /// Create color classes based on color
    pub fn color_classes(color: &Color) -> String {
        match color {
            Color::Blue => "text-blue-600 border-blue-200 bg-blue-50".to_string(),
            Color::Green => "text-green-600 border-green-200 bg-green-50".to_string(),
            Color::Purple => "text-purple-600 border-purple-200 bg-purple-50".to_string(),
            Color::Orange => "text-orange-600 border-orange-200 bg-orange-50".to_string(),
            Color::Red => "text-red-600 border-red-200 bg-red-50".to_string(),
            Color::Yellow => "text-yellow-600 border-yellow-200 bg-yellow-50".to_string(),
            Color::Pink => "text-pink-600 border-pink-200 bg-pink-50".to_string(),
            Color::Indigo => "text-indigo-600 border-indigo-200 bg-indigo-50".to_string(),
            Color::Gray => "text-gray-600 border-gray-200 bg-gray-50".to_string(),
            _ => "text-gray-600 border-gray-200 bg-gray-50".to_string(),
        }
    }

    /// Create responsive classes based on breakpoint
    pub fn responsive_classes(breakpoint: &str) -> String {
        match breakpoint {
            "sm" => "text-sm p-2".to_string(),
            "md" => "text-base p-4".to_string(),
            "lg" => "text-lg p-6".to_string(),
            "xl" => "text-xl p-8".to_string(),
            _ => "text-base p-4".to_string(),
        }
    }

    /// Combine multiple class sources into a single TailwindClasses instance
    pub fn combine_classes(
        base_classes: &str,
        theme_name: &str,
        color: &Color,
        breakpoint: &str,
    ) -> TailwindClasses {
        TailwindClasses::new(base_classes)
            .custom(&theme_classes(theme_name))
            .custom(&color_classes(color))
            .responsive(breakpoint, &responsive_classes(breakpoint))
    }
}
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

