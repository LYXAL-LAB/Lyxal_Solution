# Dialog Component API

A modal dialog component for displaying important information or capturing user input in an overlay.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-dialog = "0.7"
```

```rust
use shadcn_ui_leptos_dialog::Dialog;
```

---

## Import

```rust
// Default theme
use shadcn_ui_leptos_dialog::{
    Dialog,
    DialogTrigger,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter,
    DialogClose
};

// New York theme
use shadcn_ui_leptos_dialog::{
    Dialog as DialogNewYork,
    DialogTrigger as DialogTriggerNewYork,
    // ... other components
};

// Signal-managed variant
use shadcn_ui_leptos_dialog::{
    SignalManagedDialog,
    SignalManagedDialogState
};
```

---

## Component API

### Dialog (Root)

The context provider that manages dialog state.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Controls dialog visibility |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Called when open state changes |
| `children` | `Option<Children>` | `None` | Dialog content |

### DialogTrigger

Button that opens the dialog.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `id` | `MaybeProp<String>` | `None` | Unique identifier |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `node_ref` | `AnyNodeRef` | `None` | Node reference |
| `as_child` | `Option<Callback<DialogTriggerChildProps, AnyView>>` | `None` | Render as custom element |
| `children` | `Option<Children>` | `None` | Trigger content |

### DialogContent

The main dialog container with backdrop.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `style` | `Signal<Style>` | `None` | Inline styles |
| `children` | `Option<Children>` | `None` | Dialog content |

### DialogHeader

Header section for title and description.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Header content |

### DialogTitle

Dialog title (accessibility required).

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Title text |

### DialogDescription

Optional description text.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Description text |

### DialogFooter

Footer section for action buttons.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Footer content |

### DialogClose

Button that closes the dialog.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Button content |

---

## Usage Examples

### Basic Dialog

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_dialog::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Dialog open=open.into() on_open_change=Some(Callback::new(move |is_open| {
            set_open.set(is_open);
        }))>
            <DialogTrigger>
                <button>"Open Dialog"</button>
            </DialogTrigger>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>"Are you sure?"</DialogTitle>
                </DialogHeader>
                <div class="py-4">
                    "This action cannot be undone."
                </div>
                <DialogFooter>
                    <DialogClose>
                        <button>"Cancel"</button>
                    </DialogClose>
                    <button class="bg-destructive">"Confirm"</button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    }
}
```

### Custom Trigger Button

```rust
view! {
    <Dialog open=open.into()>
        <DialogTrigger as_child=Callback::new(|props| {
            view! {
                <button
                    class=props.class
                    on:click=move |_| set_open.set(true)
                >
                    "Open"
                </button>
            }.into_any()
        })>
        </DialogTrigger>
        // ... rest of dialog
    </Dialog>
}
```

### With Description

```rust
view! {
    <DialogContent>
        <DialogHeader>
            <DialogTitle>"Delete Account"</DialogTitle>
            <DialogDescription>
                "This will permanently delete your account and all associated data. \
                This action cannot be undone."
            </DialogDescription>
        </DialogHeader>
        // ... actions
    </DialogContent>
}
```

### Form Dialog

```rust
#[component]
pub fn CreateUserDialog() -> impl IntoView {
    let (open, set_open) = signal(false);
    let (name, set_name) = signal(String::new());
    let (email, set_email) = signal(String::new());

    let handle_submit = move |_| {
        // Create user...
        set_open.set(false);
    };

    view! {
        <Dialog open=open.into()>
            <DialogTrigger>
                <button>"Add User"</button>
            </DialogTrigger>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>"Create New User"</DialogTitle>
                    <DialogDescription>
                        "Enter the user's information below"
                    </DialogDescription>
                </DialogHeader>
                <form on:submit=handle_submit class="space-y-4">
                    <div>
                        <label>"Name"</label>
                        <input
                            type="text"
                            on:input=move |e| set_name.set(event_target_value(&e))
                        />
                    </div>
                    <div>
                        <label>"Email"</label>
                        <input
                            type="email"
                            on:input=move |e| set_email.set(event_target_value(&e))
                        />
                    </div>
                    <DialogFooter>
                        <DialogClose>
                            <button type="button">"Cancel"</button>
                        </DialogClose>
                        <button type="submit">"Create"</button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    }
}
```

### Confirmation Dialog

```rust
#[component]
pub fn ConfirmDelete() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <Dialog open=open.into()>
            <DialogTrigger>
                <button class="text-destructive">"Delete"</button>
            </DialogTrigger>
            <DialogContent>
                <DialogHeader>
                    <DialogTitle>"Delete Item"</DialogTitle>
                    <DialogDescription>
                        "Are you sure you want to delete this item? \
                        This action cannot be undone."
                    </DialogDescription>
                </DialogHeader>
                <DialogFooter>
                    <DialogClose>
                        <button variant="outline">"Cancel"</button>
                    </DialogClose>
                    <button
                        class="bg-destructive"
                        on:click=move |_| {
                            // Delete logic...
                            set_open.set(false);
                        }
                    >
                        "Delete"
                    </button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    }
}
```

### Custom Styling

```rust
view! {
    <DialogContent class="sm:max-w-md">
        <DialogHeader>
            <DialogTitle class="text-lg font-semibold">
                "Custom Styled Dialog"
            </DialogTitle>
        </DialogHeader>
        <div class="mt-4">
            "Content with custom styling"
        </div>
    </DialogContent>
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Escape** | Close dialog |
| **Tab** | Navigate focus within dialog |
| **Shift+Tab** | Navigate backwards |

### ARIA Attributes

The component automatically manages:

- `role="dialog"` - Dialog role
- `aria-modal="true"` - Modal state
- `aria-labelledby` - References title element
- `aria-describedby` - References description element

### Focus Management

1. **Focus trap** - Tab cycles within dialog
2. **Initial focus** - First focusable element
3. **Return focus** - Focus returns to trigger on close
4. **Backdrop click** - Click outside closes dialog

### Screen Reader Support

```rust
// Good: Proper title and description
<DialogContent>
    <DialogHeader>
        <DialogTitle>"Delete Account"</DialogTitle>
        <DialogDescription>
            "This will permanently delete your account"
        </DialogDescription>
    </DialogHeader>
</DialogContent>

// Good: Descriptive trigger
<DialogTrigger>
    <button>"Delete Account"</button>
</DialogTrigger>
```

---

## CSS Classes

### Content Classes

```css
.dialog-content {
    fixed inset-0 z-50 flex items-center justify-center
    bg-background/80 backdrop-blur-sm
    data-[state=open]:animate-in data-[state=closed]:animate-out
    data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0
    data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95
    data-[state=closed]:slide-out-to-left-1/2
    data-[state=closed]:slide-out-to-top-[48%]
    data-[state=open]:slide-in-from-left-1/2
    data-[state=open]:slide-in-from-top-[48%]
    sm:rounded-lg
}
```

### Header Classes

```css
.dialog-header {
    flex flex-col space-y-1.5 text-center sm:text-left
}
```

### Title Classes

```css
.dialog-title {
    text-lg font-semibold leading-none tracking-tight
}
```

### Description Classes

```css
.dialog-description {
    text-sm text-muted-foreground
}
```

### Footer Classes

```css
.dialog-footer {
    flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2
}
```

---

## TypeScript API

```typescript
interface DialogProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
  children?: React.ReactNode;
}

interface DialogContentProps {
  className?: string;
  children?: React.ReactNode;
}

interface DialogHeaderProps {
  className?: string;
  children?: React.ReactNode;
}

interface DialogTitleProps {
  className?: string;
  children?: React.ReactNode;
}

interface DialogDescriptionProps {
  className?: string;
  children?: React.ReactNode;
}

interface DialogFooterProps {
  className?: string;
  children?: React.ReactNode;
}

export const Dialog: React.FC<DialogProps>;
export const DialogTrigger: React.FC<ButtonProps>;
export const DialogContent: React.FC<DialogContentProps>;
export const DialogHeader: React.FC<DialogHeaderProps>;
export const DialogTitle: React.FC<DialogTitleProps>;
export const DialogDescription: React.FC<DialogDescriptionProps>;
export const DialogFooter: React.FC<DialogFooterProps>;
export const DialogClose: React.FC<ButtonProps>;
```

---

## Best Practices

1. **Always provide a title** - Required for accessibility
2. **Use descriptions for context** - Explain the dialog's purpose
3. **Provide clear actions** - Make cancel/confirm obvious
4. **Handle escape key** - Built-in, but test your implementation
5. **Return focus properly** - Ensures good UX for keyboard users

---

## See Also

- [Alert Dialog](./alert-dialog.md) - For critical confirmations
- [Sheet](./sheet.md) - Side panel alternative
- [Popover](./popover.md) - Non-modal overlay
- [Accessibility Guide](../ACCESSIBILITY_GUIDE.md)

---

*Source: [packages/leptos/dialog/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/dialog/src/default.rs)*
