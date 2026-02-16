# Registry Component API

A component registry for managing and accessing components.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-registry = "0.7"
```

```rust
use shadcn_ui_leptos_registry::Registry;
```

---

## Component API

### Registry

The registry provides component discovery and metadata.

---

## Usage Examples

### Using the Registry

```rust
use shadcn_ui_leptos_registry::Registry;

#[component]
pub fn MyComponent() -> impl IntoView {
    // Get component metadata
    let components = Registry::get_all_components();

    view! {
        <div>
            {components.iter().map(|c| {
                view! {
                    <div>
                        <h3>{c.name.clone()}</h3>
                        <p>{c.description.clone()}</p>
                    </div>
                }
            }).collect::<Vec<_>>()}
        </div>
    }
}
```

---

## TypeScript API

```typescript
export const Registry: {
  getAllComponents: () => ComponentMetadata[];
  getComponent: (name: string) => ComponentMetadata | null;
};
```

---

*Source: [packages/leptos/registry/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/registry/src/default.rs)*
