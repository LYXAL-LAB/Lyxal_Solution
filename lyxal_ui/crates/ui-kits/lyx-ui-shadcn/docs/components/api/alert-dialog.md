# Alert Dialog Component API

A modal dialog for critical confirmations and destructive actions.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-alert-dialog = "0.7"
```

```rust
use shadcn_ui_leptos_alert_dialog::AlertDialog;
```

---

## Import

```rust
use shadcn_ui_leptos_alert_dialog::{
    AlertDialog,
    AlertDialogTrigger,
    AlertDialogContent,
    AlertDialogHeader,
    AlertDialogTitle,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogCancel,
    AlertDialogAction
};
```

---

## Component API

### AlertDialog

Root component managing dialog state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### AlertDialogAction

Primary action button (usually destructive).

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `on_click` | `Option<Callback<()>>` | `None` | Click handler |

### AlertDialogCancel

Cancel button that closes dialog.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `on_click` | `Option<Callback<()>>` | `None` | Click handler |

---

## Usage Examples

### Basic Alert Dialog

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_alert_dialog::*;

#[component]
pub fn DeleteConfirmation() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <AlertDialog
            open=open.into()
            on_open_change=Some(Callback::new(move |v| set_open.set(v)))
        >
            <AlertDialogTrigger>
                <button class="text-destructive">"Delete Account"</button>
            </AlertDialogTrigger>
            <AlertDialogContent>
                <AlertDialogHeader>
                    <AlertDialogTitle>"Are you sure?"</AlertDialogTitle>
                    <AlertDialogDescription>
                        "This action cannot be undone. This will permanently \
                        delete your account and remove all data."
                    </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                    <AlertDialogCancel>"Cancel"</AlertDialogCancel>
                    <AlertDialogAction on_click=Some(Callback::new(move |_| {
                        // Perform deletion
                        set_open.set(false);
                    }))>
                        "Delete"
                    </AlertDialogAction>
                </AlertDialogFooter>
            </AlertDialogContent>
        </AlertDialog>
    }
}
```

---

## CSS Classes

```css
.alert-dialog-content {
    fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg
    translate-x-[-50%] translate-y-[-50%] gap-4 border
    bg-background p-6 shadow-lg duration-200
}

.alert-dialog-action {
    bg-destructive text-destructive-foreground
    hover:bg-destructive/90
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Escape** | Close dialog |
| **Enter** | Confirm action (when focused) |

---

## TypeScript API

```typescript
interface AlertDialogProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

export const AlertDialog: React.FC<AlertDialogProps>;
export const AlertDialogTrigger: React.FC<ComponentProps>;
export const AlertDialogContent: React.FC<ComponentProps>;
export const AlertDialogAction: React.FC<ButtonProps>;
export const AlertDialogCancel: React.FC<ButtonProps>;
```

---

*Source: [packages/leptos/alert-dialog/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/alert-dialog/src/default.rs)*
