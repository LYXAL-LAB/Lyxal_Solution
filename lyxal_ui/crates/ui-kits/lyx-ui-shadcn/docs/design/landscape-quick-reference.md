# Landscape Orientation Quick Reference

Quick reference for landscape orientation utilities and patterns in Leptos-Shadcn-UI.

## Include Orientation CSS

```html
<link rel="stylesheet" href="/style/orientation.css">
```

---

## Orientation Classes

### Basic Orientation

| Class | Effect |
|-------|--------|
| `landscape:flex-row` | Row direction in landscape |
| `landscape:flex-col` | Column direction in landscape |
| `portrait:flex-col` | Column direction in portrait |
| `portrait:hidden` | Hide in portrait mode |
| `landscape:hidden` | Hide in landscape mode |
| `landscape:block` | Display as block in landscape |
| `landscape:flex` | Display as flex in landscape |

### Grid in Landscape

| Class | Effect |
|-------|--------|
| `landscape:grid-cols-2` | 2 columns in landscape |
| `landscape:grid-cols-3` | 3 columns in landscape |
| `landscape:grid-cols-4` | 4 columns in landscape |

### Spacing in Landscape

| Class | Effect |
|-------|--------|
| `landscape:gap-4` | 1rem gap in landscape |
| `landscape:gap-6` | 1.5rem gap in landscape |
| `landscape:p-4` | 1rem padding in landscape |
| `landscape:p-6` | 1.5rem padding in landscape |

---

## Tablet Landscape Classes

### Medium Landscape (768px+)

| Class | Effect |
|-------|--------|
| `landscape-md:flex-row` | Row direction on tablet landscape |
| `landscape-md:grid-cols-2` | 2 columns on tablet landscape |
| `landscape-md:grid-cols-3` | 3 columns on tablet landscape |
| `landscape-md:gap-6` | 1.5rem gap on tablet landscape |
| `landscape-md:p-6` | 1.5rem padding on tablet landscape |

### Tablet Layouts

| Class | Effect |
|-------|--------|
| `tablet-landscape-2-col` | Two-column layout |
| `tablet-landscape-side-by-side` | Side-by-side content |
| `tablet-landscape-container` | Wider container for landscape |

---

## Component Patterns

### Stack to Row

```rust
const ORIENTATION_STACK_ROW = &str =
    "flex flex-col portrait:flex-col landscape:flex-row landscape:gap-6";
```

### Single to Multi Column

```rust
const ORIENTATION_COLS = &str =
    "grid grid-cols-1 portrait:grid-cols-1 \
     landscape:grid-cols-2 landscape-md:grid-cols-3";
```

### Bottom Nav Transform

```rust
const BOTTOM_NAV = &str =
    "fixed bottom-0 left-0 right-0 landscape:hidden";

const TOP_NAV = &str =
    "hidden landscape:flex landscape:flex-row";
```

### Form Layout

```rust
const FORM_FIELD = &str =
    "flex flex-col gap-2 portrait:flex-col \
     landscape:landscape-form-inline landscape:gap-4";
```

### Card Layout

```rust
const CARD = &str =
    "flex flex-col gap-4 portrait:flex-col \
     landscape:landscape-card-horizontal";

const CARD_MEDIA = &str =
    "w-full portrait:w-full portrait:h-48 \
     landscape:landscape-card-media";
```

---

## Common Patterns

### Pattern 1: Side-by-Side Content

```rust
<div class="
    flex flex-col gap-4
    portrait:flex-col
    landscape:flex-row landscape:gap-6
">
    <div class="flex-1">{ /* Left */ }</div>
    <div class="flex-1">{ /* Right */ }</div>
</div>
```

### Pattern 2: Adaptive Grid

```rust
<div class="
    grid grid-cols-1 gap-4
    portrait:grid-cols-1
    landscape:grid-cols-2
    landscape-md:grid-cols-3
">
    { /* Cards */ }
</div>
```

### Pattern 3: Navigation

```rust
// Bottom nav for portrait
<nav class="
    fixed bottom-0 left-0 right-0
    landscape:hidden portrait:flex
">
    { /* Nav items */ }
</nav>

// Horizontal nav for landscape
<nav class="
    hidden landscape:flex landscape:flex-row
">
    { /* Nav items */ }
</nav>
```

### Pattern 4: Form Inline

```rust
<div class="
    flex flex-col gap-2
    portrait:flex-col
    landscape:landscape-form-inline landscape:gap-4
">
    <label class="portrait:text-left landscape:text-right">
        "Label"
    </label>
    <input class="flex-1" />
</div>
```

---

## Safe Areas in Landscape

| Class | Effect |
|-------|--------|
| `landscape:pl-safe` | Left safe area padding |
| `landscape:pr-safe` | Right safe area padding |
| `landscape:px-safe` | Both sides safe area padding |

---

## Typography in Landscape

| Class | Effect |
|-------|--------|
| `landscape:text-sm` | Smaller text in landscape |
| `landscape:text-base` | Base text in landscape |
| `landscape:truncate` | Truncate text in landscape |
| `landscape:line-clamp-2` | Clamp to 2 lines in landscape |

---

## Viewport Sizes for Testing

| Device | Landscape Width | Landscape Height |
|--------|----------------|------------------|
| iPad | 1024px | 768px |
| iPad Air | 1180px | 820px |
| iPad Pro 11" | 1194px | 834px |
| iPad Pro 12.9" | 1366px | 1024px |
| Galaxy Tab S9 | 1280px | 800px |
| iPhone 14 Pro | 852px | 393px |

---

## Testing Checklist

- [ ] Rotate from portrait to landscape
- [ ] Rotate from landscape to portrait
- [ ] Test on iPad (1024×768)
- [ ] Test on smaller tablet (800×600)
- [ ] Test split-screen (1/3 width = ~340px)
- [ ] Verify no horizontal scroll
- [ ] Check touch targets remain 44×44px minimum
- [ ] Test form inputs in landscape
- [ ] Verify navigation adapts correctly
- [ ] Check safe areas with notches

---

## Quick Tips

1. **Always test both orientations** - Don't assume portrait-only
2. **Use width advantages** - Side-by-side layouts in landscape
3. **Maintain touch targets** - 44×44px minimum in all orientations
4. **Consider use cases** - Media, productivity, gaming
5. **Test real devices** - Emulators don't always match
6. **Handle safe areas** - Notches may be on sides in landscape
7. **Consider split-screen** - Test at narrow widths in landscape

---

## Media Query Reference

```css
/* All landscape devices */
@media (orientation: landscape) { }

/* Tablet landscape (768px+) */
@media (min-width: 768px) and (orientation: landscape) { }

/* Small landscape (480px+) */
@media (min-width: 480px) and (orientation: landscape) { }

/* All portrait devices */
@media (orientation: portrait) { }
```

---

## See Also

- [Landscape Orientation Guide](./landscape-orientation.md) - Comprehensive guide
- [Mobile Design Guidelines](./mobile-guidelines.md) - Mobile-first approach
- [Mobile Utilities](./mobile-utilities.md) - General responsive utilities
