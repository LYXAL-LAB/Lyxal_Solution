# Table Component API

A table component for displaying structured data in rows and columns.

---

## Installation

```toml
# Cargo.toml
[dependencies]
shadcn-ui-leptos-table = "0.7"
```

```rust
use shadcn_ui_leptos_table::Table;
```

---

## Import

```rust
use shadcn_ui_leptos_table::{
    Table,
    TableHeader,
    TableBody,
    TableFooter,
    TableRow,
    TableHead,
    TableCell,
    TableCaption
};
```

---

## Component API

### Table

Root table container.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Table content |

### TableHeader

Header section containing column headings.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Header content |

### TableBody

Main body containing data rows.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Body content |

### TableFooter

Footer section for summaries or pagination.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Footer content |

### TableRow

Single row in the table.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Row content |

### TableHead

Column header cell.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Header text |

### TableCell

Data cell.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Cell content |

### TableCaption

Table caption/title.

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `class` | `MaybeProp<String>` | `None` | Additional CSS classes |
| `children` | `Option<Children>` | `None` | Caption text |

---

## Usage Examples

### Basic Table

```rust
use leptos::prelude::*;
use shadcn_ui_leptos_table::*;

#[component]
pub fn MyComponent() -> impl IntoView {
    view! {
        <Table>
            <TableCaption>"A list of your recent invoices."</TableCaption>
            <TableHeader>
                <TableRow>
                    <TableHead>"Invoice"</TableHead>
                    <TableHead>"Status"</TableHead>
                    <TableHead>"Amount"</TableHead>
                </TableRow>
            </TableHeader>
            <TableBody>
                <TableRow>
                    <TableCell>"INV001"</TableCell>
                    <TableCell>"Paid"</TableCell>
                    <TableCell>"$250.00"</TableCell>
                </TableRow>
                <TableRow>
                    <TableCell>"INV002"</TableCell>
                    <TableCell>"Pending"</TableCell>
                    <TableCell>"$150.00"</TableCell>
                </TableRow>
            </TableBody>
        </Table>
    }
}
```

---

## CSS Classes

```css
.table {
    w-full caption-bottom text-sm
}

.table-header {
    border-b
}

.table-body {
    &[data-truncate=true] tr {
        @apply last:border-b;
    }
}

.table-footer {
    border-t bg-muted/50 font-medium
}

.table-row {
    border-b transition-colors hover:bg-muted/50
}

.table-head {
    h-10 px-2 text-left align-middle font-medium
    text-muted-foreground [&:has([role=checkbox])]:pr-0
}

.table-cell {
    p-2 align-middle [&:has([role=checkbox])]:pr-0
}

.table-caption {
    mt-4 text-sm text-muted-foreground
}
```

---

## Accessibility

### ARIA Attributes

- `role="table"` - Table role
- `role="row"` - Row role
- `role="columnheader"` - Header cell role
- `role="cell"` - Data cell role
- Scope attributes for headers

---

## TypeScript API

```typescript
interface TableProps {
  className?: string;
  children?: React.ReactNode;
}

export const Table: React.FC<TableProps>;
export const TableHeader: React.FC<ComponentProps>;
export const TableBody: React.FC<ComponentProps>;
export const TableFooter: React.FC<ComponentProps>;
export const TableRow: React.FC<ComponentProps>;
export const TableHead: React.FC<ComponentProps>;
export const TableCell: React.FC<ComponentProps>;
export const TableCaption: React.FC<ComponentProps>;
```

---

*Source: [packages/leptos/table/src/default.rs](https://github.com/yourusername/leptos-shadcn-ui/blob/main/packages/leptos/table/src/default.rs)*
