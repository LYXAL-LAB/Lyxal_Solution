# Accordion Component API

A vertically collapsible component for organizing content into expandable sections.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-accordion = "0.7"
```

```rust
use shadcn_ui_leptos_accordion::Accordion;
```

---

## Import

```rust
use shadcn_ui_leptos_accordion::{
    Accordion,
    AccordionItem,
    AccordionTrigger,
    AccordionContent
};
```

---

## Component API

### Accordion

Root container managing accordion state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<String>` | **Required** | Currently open item |
| `on_change` | `Option<Callback<String>>` | `None` | Change handler |
| `multiple` | `Signal<bool>` | `false` | Allow multiple open |
| `collapsible` | `Signal<bool>` | `true` | Allow collapsing all |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### AccordionItem

Individual accordion section.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String` | **Required** | Item identifier |
| `disabled` | `Signal<bool>` | `false` | Disable item |

### AccordionTrigger

Clickable header for accordion item.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

### AccordionContent

Collapsible content area.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Accordion

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_accordion::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (value, set_value) = signal("item-1".to_string());

    view! {
        <Accordion
            value=value.into()
            on_change=Some(Callback::new(move |v| set_value.set(v)))
        >
            <AccordionItem value="item-1">
                <AccordionTrigger>"Is it accessible?"</AccordionTrigger>
                <AccordionContent>
                    "Yes. It adheres to the WAI-ARIA design pattern."
                </AccordionContent>
            </AccordionItem>

            <AccordionItem value="item-2">
                <AccordionTrigger>"Is it styled?"</AccordionTrigger>
                <AccordionContent>
                    "Yes. It comes with default styles."
                </AccordionContent>
            </AccordionItem>
        </Accordion>
    }
}
```

---

## CSS Classes

```css
.accordion {
    border-b
}

.accordion-item {
    border-b
}

.accordion-trigger {
    flex flex-1 items-center justify-between
    py-4 font-medium transition-all
    hover:underline [&[data-state=open]>svg]:rotate-180
}

.accordion-content {
    overflow-hidden text-sm transition-all
}

.accordion-content[data-state=closed] {
    animate-accordion-up
}

.accordion-content[data-state=open] {
    animate-accordion-down
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Tab** | Navigate accordion |
| **Enter/Space** | Toggle section |
| **Arrow Down** | Next section |
| **Arrow Up** | Previous section |
| **Home** | First section |
| **End** | Last section |

---

## TypeScript API

```typescript
interface AccordionProps {
  value: string;
  onChange?: (value: string) => void;
  multiple?: boolean;
  collapsible?: boolean;
  className?: string;
  children?: React.ReactNode;
}

export const Accordion: React.FC<AccordionProps>;
export const AccordionItem: React.FC<{ value: string; disabled?: boolean }>;
export const AccordionTrigger: React.FC<ComponentProps>;
export const AccordionContent: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/accordion/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/accordion/src/default.rs)*
