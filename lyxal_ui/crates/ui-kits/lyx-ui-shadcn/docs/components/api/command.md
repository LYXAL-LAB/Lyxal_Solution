# Command Component API

A command palette component for quick actions and navigation.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-command = "0.7"
```

```rust
use shadcn_ui_leptos_command::Command;
```

---

## Import

```rust
use shadcn_ui_leptos_command::{
    Command,
    CommandInput,
    CommandList,
    CommandItem,
    CommandGroup,
    CommandSeparator,
    CommandEmpty
};
```

---

## Component API

### Command

Root container for command palette.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `open` | `Signal<bool>` | **Required** | Open state |
| `on_open_change` | `Option<Callback<bool>>` | `None` | Change handler |

### CommandInput

Search input for filtering commands.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `placeholder` | `MaybeProp<String>` | `"Type a command..."` | Placeholder text |

### CommandItem

Individual command item.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `value` | `String` | **Required** | Search value |
| `on_select` | `Option<Callback<()>>` | `None` | Select handler |

---

## Usage Examples

### Basic Command Palette

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_command::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    let (open, set_open) = signal(false);

    view! {
        <div>
            <button on:click=move |_| set_open.set(true)>
                "Open Command Palette"
            </button>

            <Command
                open=open.into()
                on_open_change=Some(Callback::new(move |v| set_open.set(v)))
            >
                <CommandInput placeholder="Type a command..." />
                <CommandList>
                    <CommandEmpty>"No results found"</CommandEmpty>
                    <CommandGroup heading="Suggestions">
                        <CommandItem value="calendar" on_select=Some(Callback::new(move |_| println!("Calendar")))>
                            "Calendar"
                        </CommandItem>
                        <CommandItem value="settings">
                            "Settings"
                        </CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        </div>
    }
}
```

---

## CSS Classes

```css
.command {
    flex h-full w-full flex-col overflow-hidden rounded-md
    bg-popover text-popover-foreground
}

.command-input {
    flex h-11 w-full rounded-md bg-transparent py-3
    text-sm outline-none placeholder:text-muted-foreground
}

.command-item {
    relative flex cursor-pointer select-none items-center
    rounded-sm px-2 py-1.5 text-sm outline-none
    hover:bg-accent hover:text-accent-foreground
}
```

---

## Accessibility

### Keyboard Navigation

| Key | Action |
|-----|--------|
| **Type** | Filter commands |
| **Arrow Keys** | Navigate items |
| **Enter** | Execute command |
| **Escape** | Close palette |
| **Ctrl+K** | Open palette (global) |

---

## TypeScript API

```typescript
interface CommandProps {
  open: boolean;
  onOpenChange?: (open: boolean) => void;
}

export const Command: React.FC<CommandProps>;
export const CommandInput: React.FC<{ placeholder?: string }>;
export const CommandList: React.FC<ComponentProps>;
export const CommandItem: React.FC<{ value: string; onSelect?: () => void }>;
```

---

*Source: [packages/leptos/command/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/command/src/default.rs)*
