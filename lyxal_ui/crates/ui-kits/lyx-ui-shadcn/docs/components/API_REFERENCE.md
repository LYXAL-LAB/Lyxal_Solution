# Leptos Shadcn UI - Component API Reference

Complete API documentation for all components in the leptos-shadcn-ui library.

---

## Table of Contents

- [Form Components](#form-components)
- [Layout Components](#layout-components)
- [Navigation Components](#navigation-components)
- [Overlay Components](#overlay-components)
- [Data Display & Feedback Components](#data-display--feedback-components)
- [Interactive Components](#interactive-components)
- [Utility Components](#utility-components)

---

## Form Components

### [Button](#button) | [Input](#input) | [Label](#label) | [Checkbox](#checkbox) | [Switch](#switch) | [Radio Group](#radio-group) | [Select](#select) | [Textarea](#textarea) | [Form](#form) | [Combobox](#combobox) | [Command](#command) | [Input OTP](#input-otp)

---

## Layout Components

### [Card](#card) | [Separator](#separator) | [Tabs](#tabs) | [Accordion](#accordion) | [Collapsible](#collapsible) | [Scroll Area](#scroll-area) | [Aspect Ratio](#aspect-ratio) | [Resizable](#resizable)

---

## Navigation Components

### [Breadcrumb](#breadcrumb) | [Navigation Menu](#navigation-menu) | [Context Menu](#context-menu) | [Dropdown Menu](#dropdown-menu) | [Menubar](#menubar)

---

## Overlay Components

### [Dialog](#dialog) | [Popover](#popover) | [Tooltip](#tooltip) | [Alert Dialog](#alert-dialog) | [Sheet](#sheet) | [Drawer](#drawer) | [Hover Card](#hover-card)

---

## Data Display & Feedback Components

### [Alert](#alert) | [Badge](#badge) | [Skeleton](#skeleton) | [Progress](#progress) | [Toast](#toast) | [Table](#table) | [Calendar](#calendar) | [Date Picker](#date-picker) | [Pagination](#pagination)

---

## Interactive Components

### [Slider](#slider) | [Toggle](#toggle) | [Carousel](#carousel) | [Avatar](#avatar)

---

## Utility Components

### [Error Boundary](#error-boundary) | [Lazy Loading](#lazy-loading) | [Registry](#registry)

---

## Detailed Component Documentation

Select a component below to view its complete API documentation:

- **[Button](./api/button.md)** - Interactive button with multiple variants and sizes
- **[Input](./api/input.md)** - Text input with validation support
- **[Dialog](./api/dialog.md)** - Modal dialog component
- **[Card](./api/card.md)** - Content container with header, body, and footer
- **[Tabs](./api/tabs.md)** - Tabbed content switcher
- **[Select](./api/select.md)** - Dropdown selection component
- **[Checkbox](./api/checkbox.md)** - Binary selection input
- **[Switch](./api/switch.md)** - Toggle switch component
- **[Radio Group](./api/radio-group.md)** - Single selection from options
- **[Textarea](./api/textarea.md)** - Multi-line text input
- **[Label](./api/label.md)** - Form label component
- **[Form](./api/form.md)** - Form container with validation
- **[Alert](./api/alert.md)** - Alert message display
- **[Badge](./api/badge.md)** - Status indicator badge
- **[Skeleton](./api/skeleton.md)** - Loading placeholder
- **[Progress](./api/progress.md)** - Progress indicator
- **[Toast](./api/toast.md)** - Temporary notification
- **[Table](./api/table.md)** - Data table display
- **[Separator](./api/separator.md)** - Visual divider
- **[Accordion](./api/accordion.md)** - Collapsible content sections
- **[Collapsible](./api/collapsible.md)** - Show/hide content toggle
- **[Scroll Area](./api/scroll-area.md)** - Custom scrollable container
- **[Aspect Ratio](./api/aspect-ratio.md)** - Fixed aspect ratio container
- **[Resizable](./api/resizable.md)** - Resizable panel layout
- **[Breadcrumb](./api/breadcrumb.md)** - Navigation breadcrumb
- **[Navigation Menu](./api/navigation-menu.md)** - Site navigation
- **[Context Menu](./api/context-menu.md)** - Right-click context menu
- **[Dropdown Menu](./api/dropdown-menu.md)** - Dropdown action menu
- **[Menubar](./api/menubar.md)** - Application menu bar
- **[Dialog](./api/dialog.md)** - Modal dialog
- **[Popover](./api/popover.md)** - Floating content container
- **[Tooltip](./api/tooltip.md)** - Hover information tip
- **[Alert Dialog](./api/alert-dialog.md)** - Confirmation dialog
- **[Sheet](./api/sheet.md)** - Side panel drawer
- **[Drawer](./api/drawer.md)** - Slide-out drawer
- **[Hover Card](./api/hover-card.md)** - Hover-triggered card
- **[Calendar](./api/calendar.md)** - Date picker calendar
- **[Date Picker](./api/date-picker.md)** - Date selection component
- **[Pagination](./api/pagination.md)** - Page navigation
- **[Slider](./api/slider.md)** - Range slider input
- **[Toggle](./api/toggle.md)** - Toggle button
- **[Carousel](./api/carousel.md)** - Image/content carousel
- **[Avatar](./api/avatar.md)** - User avatar display
- **[Combobox](./api/combobox.md)** - Searchable select
- **[Command](./api/command.md)** - Command palette
- **[Input OTP](./api/input-otp.md)** - One-time password input
- **[Error Boundary](./api/error-boundary.md)** - Error handling wrapper
- **[Lazy Loading](./api/lazy-loading.md)** - Lazy component loading
- **[Registry](./api/registry.md)** - Component registry

---

## Common Props Reference

Most components support these common props:

### Core Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `id` | `Option<String>` | `None` | Unique identifier for the component |
| `class` | `Option<String>` | `None` | Additional CSS classes |
| `style` | `Option<Style>` | `None` | Inline styles |

### Accessibility Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `aria_label` | `Option<String>` | `None` | Accessible name for screen readers |
| `aria_describedby` | `Option<String>` | `None` | ID of element describing this component |
| `aria_labelledby` | `Option<String>` | `None` | ID of element labeling this component |
| `role` | `Option<String>` | `None` | ARIA role override |

### State Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `disabled` | `Signal<bool>` | `false` | Disable component interaction |
| `readonly` | `Option<bool>` | `false` | Make component read-only |

---

## Variant System

Components support multiple visual variants:

### Button Variants
```rust
pub enum ButtonVariant {
    Default,
    Destructive,
    Outline,
    Secondary,
    Ghost,
    Link,
}
```

### Button Sizes
```rust
pub enum ButtonSize {
    Default,
    Sm,
    Lg,
    Icon,
}
```

---

## Theme Support

All components support two theme variants:
- **Default Theme** - Standard shadcn/ui styling
- **New York Theme** - Alternative design system

```rust
// Import Default theme
use shadcn_ui_leptos_button::Button;

// Import New York theme
use shadcn_ui_leptos_button::ButtonNewYork;
```

---

## Signal-Managed Components

Many components offer signal-managed variants with enhanced reactivity:

```rust
use shadcn_ui_leptos_button::SignalManagedButton;

// Provides built-in state management
let button_state = SignalManagedButtonState::new();
```

---

## TypeScript Definitions

TypeScript definitions are available for JavaScript/TypeScript interoperability:

```typescript
import { Button } from '@leptos-shadcn-ui/button';

interface ButtonProps {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link';
  size?: 'default' | 'sm' | 'lg' | 'icon';
  disabled?: boolean;
  onClick?: () => void;
  children?: React.ReactNode;
}
```

---

## Examples

See the [Example Usage Guide](./example-usage.md) for comprehensive examples of all components.

---

## Accessibility

All components follow WCAG 2.1 AA standards. See the [Accessibility Guide](./ACCESSIBILITY_GUIDE.md) for details.

---

*Last Updated: January 2026*
*Version: 0.7.0*
