# Mobile Component Patterns

Quick reference for implementing mobile-first patterns in common components.

## Quick Reference Table

| Component | Mobile Pattern | Desktop Pattern |
|-----------|---------------|-----------------|
| Button | Full width, h-11 minimum | Auto width, h-10 |
| Input | Full width, h-12 | Auto width, h-10 |
| Card | Stacked vertical | Grid layout |
| Dialog | Full screen modal | Centered modal |
| Table | Card view or scroll | Standard table |
| Navigation | Bottom bar or hamburger | Top horizontal |
| Form | Stacked labels | Inline labels |

---

## Button Patterns

### Primary Action Button

```rust
// Full width on mobile for primary CTAs
const BUTTON_PRIMARY = &str =
    "inline-flex items-center justify-center \
     w-full sm:w-auto \
     h-11 sm:h-10 \
     rounded-md px-8 py-2 \
     bg-primary text-primary-foreground \
     font-medium transition-colors";
```

### Button Group

```rust
// Stack on mobile, row on desktop
const BUTTON_GROUP = &str =
    "flex flex-col gap-3 sm:flex-row sm:gap-2";

// Or use responsive grid
const BUTTON_GROUP_GRID = &str =
    "grid grid-cols-2 gap-3 sm:grid-cols-4 sm:gap-2";
```

### Icon Button

```rust
// Minimum 44px touch target
const ICON_BUTTON = &str =
    "inline-flex items-center justify-center \
     h-11 w-11 sm:h-10 sm:w-10 \
     rounded-md \
     hover:bg-accent";
```

---

## Input Patterns

### Form Field

```rust
// Label above, input full width on mobile
const FORM_FIELD = &str =
    "flex flex-col gap-2 \
     sm:grid sm:grid-cols-[140px_1fr] sm:items-center sm:gap-4";

const FORM_LABEL = &str =
    "text-sm font-medium sm:text-right";

const FORM_INPUT = &str =
    "flex h-12 sm:h-10 w-full rounded-md border \
     px-3 py-2 text-sm";
```

### Search Input

```rust
// Full width on mobile
const SEARCH_INPUT = &str =
    "flex h-12 sm:h-10 w-full rounded-full border \
     pl-4 pr-10 \
     sm:w-64 sm:rounded-md";
```

### Textarea

```rust
const TEXTAREA = &str =
    "flex min-h-[120px] w-full rounded-md border \
     px-3 py-2 text-sm resize-none";
```

---

## Card Patterns

### Responsive Card Grid

```rust
const CARD_GRID = &str =
    "grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4";

const CARD = &str =
    "rounded-lg border bg-card text-card-foreground shadow-sm \
     p-4 sm:p-6";
```

### Horizontal Card (Media + Content)

```rust
// Stacked on mobile, side-by-side on desktop
const CARD_HORIZONTAL = &str =
    "flex flex-col gap-4 sm:flex-row";

const CARD_MEDIA = &str =
    "w-full sm:w-48 sm:h-32 \
     rounded-md object-cover";

const CARD_CONTENT = &str =
    "flex-1 space-y-2";
```

---

## Dialog/Modal Patterns

### Full-Sheet Mobile, Modal Desktop

```rust
const DIALOG_CONTENT = &str =
    "fixed left-0 right-0 bottom-0 top-0 z-50 \
     bg-background \
     sm:left-[50%] sm:top-[50%] sm:bottom-auto sm:right-auto \
     sm:translate-x-[-50%] sm:translate-y-[-50%] \
     sm:rounded-lg sm:max-w-lg";
```

### Bottom Sheet

```rust
const BOTTOM_SHEET = &str =
    "fixed left-0 right-0 bottom-0 z-50 \
     rounded-t-2xl border-t \
     p-4 pb-safe \
     sm:hidden";
```

---

## Table Patterns

### Scrollable Table

```rust
const TABLE_WRAPPER = &str =
    "w-full overflow-x-auto -mx-4 px-4 sm:mx-0 sm:px-0";

const TABLE = &str =
    "w-full min-w-[600px]"; // Force scroll on small screens
```

### Card View Alternative

```rust
// Each row becomes a card on mobile
const TABLE_ROW_MOBILE = &str =
    "flex flex-col gap-2 p-4 border-b sm:table-row sm:p-0 sm:border-0";

const TABLE_CELL_LABEL = &str =
    "text-xs text-muted-foreground sm:hidden"; // Show label on mobile

const TABLE_CELL_VALUE = &str =
    "sm:table-cell";
```

---

## Navigation Patterns

### Bottom Navigation Bar

```rust
const BOTTOM_NAV = &str =
    "fixed bottom-0 left-0 right-0 z-50 \
     h-16 border-t bg-background \
     flex items-center justify-around \
     pb-safe sm:hidden";

const BOTTOM_NAV_ITEM = &str =
    "flex flex-col items-center justify-center \
     h-full w-full gap-1";

const BOTTOM_NAV_ICON = &str =
    "h-6 w-6";

const BOTTOM_NAV_LABEL = &str =
    "text-xs font-medium";
```

### Hamburger Menu

```rust
const MENU_BUTTON = &str =
    "inline-flex items-center justify-center \
     h-10 w-10 rounded-md \
     sm:hidden";

const MOBILE_MENU = &str =
    "fixed inset-0 z-50 bg-background \
     flex flex-col pt-20 px-4 \
     sm:hidden";

const MENU_ITEM = &str =
    "flex items-center justify-between \
     py-4 border-b text-lg";
```

### Responsive Header

```rust
const HEADER = &str =
    "sticky top-0 z-40 w-full border-b bg-background \
     px-4 py-3 sm:px-6 sm:py-4";

const HEADER_CONTENT = &str =
    "flex items-center justify-between";

const HEADER_LOGO = &str =
    "text-lg font-bold sm:text-xl";

const HEADER_ACTIONS = &str =
    "flex items-center gap-2";
```

---

## List Patterns

### Responsive List

```rust
const LIST = &str =
    "flex flex-col gap-3 sm:gap-2";

const LIST_ITEM = &str =
    "flex items-start gap-3 p-3 rounded-lg \
     hover:bg-accent \
     sm:items-center";
```

### Action List (with icons)

```rust
const ACTION_LIST_ITEM = &str =
    "flex items-center gap-3 p-4 rounded-lg \
     hover:bg-accent active:bg-accent/80";

const ACTION_LIST_ICON = &str =
    "h-10 w-10 flex-shrink-0";

const ACTION_LIST_CONTENT = &str =
    "flex-1 min-w-0"; // Allow truncation

const ACTION_LIST_TEXT = &str =
    "font-medium truncate";

const ACTION_LIST_SUBTEXT = &str =
    "text-sm text-muted-foreground truncate";
```

---

## Badge/Tag Patterns

```rust
const BADGE = &str =
    "inline-flex items-center rounded-full border \
     px-2.5 py-0.5 text-xs font-semibold";

const BADGE_SM = &str =
    "inline-flex items-center rounded-full border \
     px-2 py-0.5 text-xs";
```

---

## Avatar Patterns

```rust
const AVATAR = &str =
    "relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full";

const AVATAR_GROUP = &str =
    "flex -space-x-2 overflow-hidden p-1";

const AVATAR_STACKED = &str =
    "flex flex-col gap-2 sm:flex-row sm:gap-1";
```

---

## Skeleton Patterns

```rust
const SKELETON = &str =
    "animate-pulse rounded-md bg-muted";

const SKELETON_CARD = &str =
    "rounded-lg border p-4 space-y-3";

const SKELETON_TEXT = &str =
    "h-4 w-full bg-muted rounded";

const SKELETON_TITLE = &str =
    "h-6 w-3/4 bg-muted rounded";
```

---

## Tabs Patterns

### Scrollable Tabs (Mobile)

```rust
const TABS_LIST = &str =
    "inline-flex h-10 items-center justify-center \
     rounded-md bg-muted p-1 \
     w-full overflow-x-auto";

const TAB_TRIGGER = &str =
    "inline-flex items-center justify-center \
     whitespace-nowrap \
     rounded-sm px-3 py-1.5 text-sm font-medium \
     ring-offset-background";
```

### Icon Tabs

```rust
const TABS_ICON_ONLY = &str =
    "inline-flex h-9 w-9 items-center justify-center \
     rounded-md p-0";
```

---

## Alert/Toast Patterns

```rust
const ALERT = &str =
    "relative w-full rounded-lg border p-4";

const ALERT_MOBILE_FULL = &str =
    "fixed left-4 right-4 bottom-4 z-50 \
     sm:left-auto sm:right-4 sm:w-96";
```

---

## Dropdown/Menu Patterns

### Mobile Menu as Full Screen

```rust
const DROPDOWN_CONTENT = &str =
    "fixed left-0 right-0 top-0 z-50 \
     bg-background \
     sm:left-auto sm:right-0 sm:top-auto sm:w-56 sm:rounded-lg";
```

---

## Tooltip Patterns

### Use Tappable Info on Mobile

```rust
// Tooltips don't work well on mobile
// Use an icon that opens a popover or modal instead

const INFO_TRIGGER = &str =
    "inline-flex h-8 w-8 items-center justify-center \
     rounded-full hover:bg-accent";
```

---

## Pagination Patterns

```rust
const PAGINATION = &str =
    "flex flex-wrap items-center justify-center gap-2";

const PAGINATION_BUTTON = &str =
    "inline-flex items-center justify-center \
     h-10 w-10 rounded-md \
     hover:bg-accent";
```

---

## Breadcrumb Patterns

```rust
const BREADCRUMB = &str =
    "flex flex-wrap items-center gap-2 text-sm";

const BREADCRUMB_ITEM = &str =
    "inline-flex items-center gap-1";
```

---

## Progress Patterns

```rust
const PROGRESS = &str =
    "relative h-2 w-full overflow-hidden rounded-full bg-primary/20";

const PROGRESS_MOBILE_THICKER = &str =
    "relative h-4 w-full overflow-hidden rounded-full bg-primary/20";
```

---

## Separator/Divider Patterns

```rust
const SEPARATOR = &str =
    "shrink-0 bg-border h-[1px] w-full \
     sm:h-px sm:w-auto";

const SEPARATOR_VERTICAL = &str =
    "shrink-0 bg-border h-16 w-[1px] \
     sm:h-auto sm:w-px";
```

---

## Usage Examples

### Complete Mobile-First Card Component

```rust
#[component]
pub fn MobileCard(
    #[prop(into)] title: String,
    #[prop(into)] description: String,
    #[prop(into)] action_label: String,
) -> impl IntoView {
    view! {
        <div class="rounded-lg border bg-card p-4 sm:p-6 shadow-sm">
            <div class="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
                <div class="space-y-2 flex-1">
                    <h3 class="text-lg font-semibold leading-none tracking-tight">
                        {title}
                    </h3>
                    <p class="text-sm text-muted-foreground">
                        {description}
                    </p>
                </div>
                <button class="inline-flex items-center justify-center w-full sm:w-auto h-10 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90">
                    {action_label}
                </button>
            </div>
        </div>
    }
}
```

### Complete Mobile-First Form

```rust
#[component]
pub fn MobileForm() -> impl IntoView {
    view! {
        <form class="flex flex-col gap-6 px-4 py-6 sm:px-6 sm:py-8">
            // Name field
            <div class="flex flex-col gap-2 sm:grid sm:grid-cols-[140px_1fr] sm:items-center sm:gap-4">
                <label class="text-sm font-medium sm:text-right">
                    "Name"
                </label>
                <input
                    type="text"
                    class="flex h-12 sm:h-10 w-full rounded-md border px-3 py-2 text-sm"
                    placeholder="Enter your name"
                />
            </div>

            // Email field
            <div class="flex flex-col gap-2 sm:grid sm:grid-cols-[140px_1fr] sm:items-center sm:gap-4">
                <label class="text-sm font-medium sm:text-right">
                    "Email"
                </label>
                <input
                    type="email"
                    class="flex h-12 sm:h-10 w-full rounded-md border px-3 py-2 text-sm"
                    placeholder="Enter your email"
                />
            </div>

            // Actions
            <div class="flex flex-col gap-3 sm:flex-row sm:justify-end sm:pt-4">
                <button
                    type="button"
                    class="inline-flex items-center justify-center w-full sm:w-auto h-10 rounded-md border px-4 py-2 text-sm font-medium"
                >
                    "Cancel"
                </button>
                <button
                    type="submit"
                    class="inline-flex items-center justify-center w-full sm:w-auto h-10 rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
                >
                    "Submit"
                </button>
            </div>
        </form>
    }
}
```

---

## Testing Checklist

For each component pattern, verify:

- [ ] Touch targets are minimum 44px × 44px
- [ ] Full width on mobile where appropriate
- [ ] Adequate padding (no content touching edges)
- [ ] Text is readable without horizontal scroll
- [ ] Stacked layout on mobile, expands on desktop
- [ ] Safe areas respected (notched devices)
- [ ] Performance acceptable on mobile devices
