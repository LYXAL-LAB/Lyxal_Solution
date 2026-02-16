# Calendar Component API

A calendar component for date selection and display.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-calendar = "0.7"
```

```rust
use shadcn_ui_leptos_calendar::Calendar;
```

---

## Component API

### Calendar

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `Signal<Option<NaiveDate>>` | **Required** | Selected date |
| `on_change` | `Option<Callback<Option<NaiveDate>>>` | `None` | Change handler |
| `disabled` | `Signal<bool>` | `false` | Disable calendar |
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |

---

## Usage Examples

### Basic Calendar

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_calendar::Calendar;
use chrono::NaiveDate;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (date, set_date) = signal(None);

    view! {
        <Calendar
            value=date.into()
            on_change=Some(Callback::new(move |d| set_date.set(d)))
        />
    }
}
```

---

## CSS Classes

```css
.calendar {
    p-3 space-y-4
}

.calendar-day {
    p-2 text-center hover:bg-accent rounded-md cursor-pointer
}

.calendar-day-selected {
    bg-primary text-primary-foreground
}

.calendar-day-disabled {
    opacity-50 cursor-not-allowed
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Arrow Keys** | Navigate dates |
| **Page Up/Down** | Navigate months |
| **Enter** | Select date |

---

## TypeScript API

```typescript
interface CalendarProps {
  value?: Date | null;
  onChange?: (date: Date | null) => void;
  disabled?: boolean;
  className?: string;
}

export const Calendar: React.FC<CalendarProps>;
```

---

*Source: [packages/leptos/calendar/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/calendar/src/default.rs)*
