# Switch Component API

A toggle switch component for binary on/off states.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-switch = "0.7"
```

```rust
use shadcn_ui_leptos_switch::Switch;
```

---

## Import

```rust
use shadcn_ui_leptos_switch::{
    Switch,
    SwitchRoot,
    SwitchThumb,
    SwitchLabel,
    SwitchVariant,
    SwitchSize
};
```

---

## Component API

### Switch

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `checked` | `Signal<bool>` | **Required** | Switch state |
| `on_change` | `Option<Callback<bool>>` | `None` | Change handler |
| `variant` | `MaybeProp<SwitchVariant>` | `Default` | Visual variant |
| `size` | `MaybeProp<SwitchSize>` | `Md` | Switch size |
| `disabled` | `Signal<bool>` | `false` | Disable switch |
| `animated` | `Signal<bool>` | `true` | Enable animation |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |

### SwitchVariant

```rust
pub enum SwitchVariant {
    Default,      // Primary color when checked
    Success,      // Green when checked
    Warning,      // Yellow when checked
    Destructive,  // Red when checked
    Info,         // Blue when checked
}
```

### SwitchSize

```rust
pub enum SwitchSize {
    Sm,  // Small (h-4 w-7)
    Md,  // Medium (h-6 w-11)
    Lg,  // Large (h-8 w-14)
}
```

---

## Usage Examples

### Basic Switch

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_switch::Switch;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (enabled, set_enabled) = signal(false);

    view! {
        <div class="flex items-center space-x-2">
            <Switch
                checked=enabled.into()
                on_change=Some(Callback::new(move |is_checked| {
                    set_enabled.set(is_checked);
                }))
                id="notifications"
            />
            <label for="notifications">"Enable notifications"</label>
        </div>
    }
}
```

### Variants

```rust
view! {
    <div class="space-y-4">
        <Switch variant=SwitchVariant::Default checked=Signal::derive(|| true) />
        <Switch variant=SwitchVariant::Success checked=Signal::derive(|| true) />
        <Switch variant=SwitchVariant::Warning checked=Signal::derive(|| true) />
        <Switch variant=SwitchVariant::Destructive checked=Signal::derive(|| true) />
        <Switch variant=SwitchVariant::Info checked=Signal::derive(|| true) />
    </div>
}
```

### Sizes

```rust
view! {
    <div class="flex items-center gap-4">
        <Switch size=SwitchSize::Sm checked=Signal::derive(|| true) />
        <Switch size=SwitchSize::Md checked=Signal::derive(|| true) />
        <Switch size=SwitchSize::Lg checked=Signal::derive(|| true) />
    </div>
}
```

---

## CSS Classes

```css
.switch-root {
    peer inline-flex h-6 w-11 shrink-0 cursor-pointer
    items-center rounded-full border-2 border-transparent
    transition-colors focus-visible:outline-none
    focus-visible:ring-2 focus-visible:ring-ring
    focus-visible:ring-offset-2 disabled:cursor-not-allowed
    disabled:opacity-50
}

.switch-root[data-state="checked"] {
    bg-primary
}

.switch-root[data-state="unchecked"] {
    bg-input
}

.switch-thumb {
    pointer-events-none block h-5 w-5 rounded-full
    bg-background shadow-lg ring-0 transition-transform
}

.switch-thumb[data-state="checked"] {
    translate-x-5
}

.switch-thumb[data-state="unchecked"] {
    translate-x-0
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Space** | Toggle switch |

---

## TypeScript API

```typescript
interface SwitchProps {
  checked: boolean;
  onChange?: (checked: boolean) => void;
  variant?: 'default' | 'success' | 'warning' | 'destructive' | 'info';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  animated?: boolean;
  className?: string;
  id?: string;
}

export const Switch: React.FC<SwitchProps>;
```

---

*Source: [packages/leptos/switch/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/switch/src/default.rs)*
