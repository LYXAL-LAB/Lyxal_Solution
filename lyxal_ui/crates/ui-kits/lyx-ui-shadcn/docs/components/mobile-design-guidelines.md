# Mobile Design Guidelines

This guide documents the mobile-first design patterns and responsive design principles used throughout the Leptos ShadCN UI component library.

## Table of Contents

- [Overview](#overview)
- [Design Philosophy](#design-philosophy)
- [Breakpoint System](#breakpoint-system)
- [Core Patterns](#core-patterns)
- [Component-Specific Guidelines](#component-specific-guidelines)
- [Layout Patterns](#layout-patterns)
- [Typography](#typography)
- [Spacing](#spacing)
- [Touch Targets](#touch-targets)
- [Performance Considerations](#performance-considerations)
- [Testing Responsive Designs](#testing-responsive-designs)
- [Examples](#examples)

## Overview

Leptos ShadCN UI follows a **mobile-first** approach using Tailwind CSS's responsive utility classes. All components are designed to work seamlessly on mobile devices (320px+) and progressively enhance for larger screens.

### Key Principles

1. **Mobile First**: Start with mobile layouts, enhance for larger screens
2. **Touch Friendly**: All interactive elements meet minimum touch target sizes
3. **Progressive Enhancement**: Add complexity only when screen real estate allows
4. **Performance First**: Optimize for mobile network conditions and device constraints
5. **Accessible**: Maintain WCAG 2.1 AA compliance across all viewport sizes

## Design Philosophy

### Mobile-First Approach

We design for the smallest screen first, then add complexity for larger screens. This ensures:

- Core functionality works on all devices
- Performance is optimized for mobile constraints
- Content is prioritized over decoration
- Progressive enhancement is natural

### Responsive Breakpoints

Our breakpoint system aligns with common device sizes:

| Breakpoint | Min Width | Target Devices | Use Case |
|------------|-----------|----------------|----------|
| (default)  | 0px       | Mobile phones  | Base styles, single column layouts |
| `sm:`      | 640px     | Large phones, landscape | Two-column grids, enhanced spacing |
| `md:`      | 768px     | Tablets        | Multi-column layouts, sidebars |
| `lg:`      | 1024px    | Laptops, small desktops | Full navigation, complex grids |
| `xl:`      | 1280px    | Desktops       | Maximum content width, 4+ columns |
| `2xl:`     | 1536px    | Large desktops | Maximum layout width |

## Breakpoint System

### Default Configuration

```javascript
// tailwind.config.js
theme: {
    screens: {
        'sm': '640px',
        'md': '768px',
        'lg': '1024px',
        'xl': '1280px',
        '2xl': '1536px',
    }
}
```

### Usage Pattern

Always write mobile styles first (no prefix), then enhance:

```rust
// ✅ CORRECT: Mobile-first
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">

// ❌ WRONG: Desktop-first thinking
<div class="grid grid-cols-3 md:grid-cols-2 lg:grid-cols-1 gap-4">
```

## Core Patterns

### 1. Responsive Grids

The most common pattern for responsive layouts:

```rust
// Single column mobile, 2 columns tablet, 3-4 columns desktop
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
```

#### Examples by Use Case

**Card Grids** (components/api/card.md:189):
```rust
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
    // Card components
</div>
```

**Feature Sections** (comprehensive_demo.rs:156):
```rust
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
    // Feature items
</div>
```

**Dashboard Layouts** (dashboard-demo/src/lib.rs:195):
```rust
<div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    // Stats cards
</div>
```

### 2. Responsive Spacing

Adjust padding and margins based on screen size:

```rust
// Minimal padding on mobile, more on larger screens
<div class="px-4 sm:px-6 lg:px-8">

// Spacing between sections
<div class="space-y-4 md:space-y-6 lg:space-y-8">
```

### 3. Responsive Typography

Scale text size appropriately:

```rust
// Headings
<h1 class="text-2xl md:text-4xl lg:text-5xl font-bold">
<h2 class="text-xl md:text-2xl lg:text-3xl font-semibold">

// Body text
<p class="text-sm md:text-base lg:text-lg">
```

### 4. Hiding/Showing Content

Conditionally display elements by screen size:

```rust
// Mobile-only elements
<div class="block md:hidden lg:hidden">

// Tablet and desktop only
<div class="hidden md:block">

// Desktop only
<div class="hidden lg:block">
```

### 5. Responsive Dialogs/Modals

Size dialogs appropriately for the viewport:

```rust
// Mobile: full width, Desktop: constrained width
<DialogContent class="sm:max-w-[425px]">
```

## Component-Specific Guidelines

### Navigation Components

#### Navigation Menu

- **Mobile**: Collapsed into hamburger menu
- **Tablet+**: Full horizontal navigation

```rust
// Mobile menu trigger
<button class="md:hidden" aria-label="Open menu">

// Desktop navigation
<nav class="hidden md:flex">
```

#### Breadcrumb

- **Mobile**: Truncate with ellipsis, show last item
- **Tablet+:** Show full path

```rust
<div class="flex items-center space-x-2 text-sm">
    <BreadcrumbItem class="hidden sm:inline-block">Home</BreadcrumbItem>
    <BreadcrumbItem class="hidden sm:inline-block">Products</BreadcrumbItem>
    <BreadcrumbItem>Current Page</BreadcrumbItem>
</div>
```

### Form Components

#### Forms

- **Mobile**: Single column, stacked labels
- **Tablet+**: Two-column grids for related fields
- **Desktop**: Can use 3-4 columns for complex forms

```rust
<form class="space-y-4 md:space-y-6">
    // Single column on mobile
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <FormField>
            <FormLabel>First Name</FormLabel>
            <Input />
        </FormField>
        <FormField>
            <FormLabel>Last Name</FormLabel>
            <Input />
        </FormField>
    </div>
</form>
```

#### Input Fields

- **Minimum width**: Never constrain on mobile
- **Maximum width**: Constrain on desktop for readability

```rust
<Input class="w-full md:max-w-md" />
```

#### Select/Dropdown

- **Mobile**: Native select or full-screen picker
- **Desktop**: Dropdown with constrained width

### Layout Components

#### Cards

- **Mobile**: Full width, stacked content
- **Tablet+**: Grid layouts (2-3 columns)
- **Desktop**: 4 columns maximum

```rust
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
    <Card>
        <CardHeader>
            <CardTitle>Title</CardTitle>
        </CardHeader>
        <CardContent>Content</CardContent>
    </Card>
    // More cards...
</div>
```

#### Sheet/Drawer

- **Mobile**: Full width from bottom
- **Tablet+:** Fixed width from side

```rust
<Sheet>
    <SheetContent class="w-full sm:max-w-sm">
        // Content
    </SheetContent>
</Sheet>
```

#### Dialog

- **Mobile**: Full viewport with margins
- **Tablet+**: Constrained max-width

```rust
<DialogContent class="sm:max-w-[425px]">
    // Dialog content
</DialogContent>
```

### Data Display

#### Tables

- **Mobile**: Stack rows or enable horizontal scroll
- **Tablet+**: Standard table layout

```rust
// Mobile: Card-based rows
<div class="md:hidden">
    // Repeated card layout for each row
</div>

// Desktop: Standard table
<div class="hidden md:block overflow-x-auto">
    <Table>
        // Table content
    </Table>
</div>
```

#### Tabs

- **Mobile**: Scrollable horizontal tabs
- **Desktop**: Full-width tabs

```rust
<TabsList class="w-full justify-start overflow-x-auto">
    <TabsTrigger>Tab 1</TabsTrigger>
    <TabsTrigger>Tab 2</TabsTrigger>
</TabsList>
```

### Feedback Components

#### Alerts/Toasts

- **Mobile**: Full width at bottom/top
- **Desktop**: Constrained width, positioned

```rust
<Alert class="mx-4 md:mx-0 md:max-w-md">
    <AlertDescription>Message</AlertDescription>
</Alert>
```

#### Progress Indicators

- **Mobile**: Full width
- **Desktop**: Constrained width or centered

```rust
<Progress class="w-full md:w-96" value={progress} />
```

## Layout Patterns

### Container Pattern

Center content with responsive max-width:

```rust
<div class="container mx-auto px-4 sm:px-6 lg:px-8">
    // Content
</div>
```

### Sidebar Layout

Responsive sidebar that collapses on mobile:

```rust
<div class="flex flex-col md:flex-row">
    <aside class="w-full md:w-64 mb-4 md:mb-0 md:mr-6">
        // Sidebar content
    </aside>
    <main class="flex-1">
        // Main content
    </main>
</div>
```

### Stacked to Side-by-Side

Move from stacked layout to side-by-side:

```rust
<div class="flex flex-col lg:flex-row gap-6">
    <div class="flex-1">
        // Primary content
    </div>
    <div class="w-full lg:w-80">
        // Secondary content
    </div>
</div>
```

## Typography

### Responsive Font Sizes

```rust
// Display headings
<h1 class="text-3xl md:text-5xl lg:text-7xl font-bold">

// Section headings
<h2 class="text-2xl md:text-3xl lg:text-4xl font-bold">

// Subsection headings
<h3 class="text-xl md:text-2xl font-semibold">

// Body text
<p class="text-sm md:text-base">

// Small text
<small class="text-xs md:text-sm">
```

### Line Height

Maintain readability across devices:

```rust
// Headings: tighter
<h1 class="leading-tight">

// Body: comfortable
<p class="leading-relaxed md:leading-normal">
```

### Text Truncation

Handle long text on mobile:

```rust
// Truncate with ellipsis
<p class="truncate">Long text that needs truncation</p>

// Line clamping
<p class="line-clamp-2 md:line-clamp-3">
    Long content that should be limited to specific lines
</p>
```

## Spacing

### Spacing Scale

Use consistent spacing units:

| Mobile | Tablet | Desktop | Use Case |
|--------|--------|---------|----------|
| `p-2`  | `p-3`  | `p-4`   | Tight spacing |
| `p-4`  | `p-6`  | `p-8`   | Comfortable spacing |
| `gap-2`| `gap-4`| `gap-6` | Grid gaps |

### Responsive Margins

```rust
// Section margins
<section class="my-8 md:my-12 lg:my-16">

// Element spacing
<div class="space-y-4 md:space-y-6 lg:space-y-8">
```

### Padding

```rust
// Container padding
<div class="p-4 sm:p-6 lg:p-8">

// Card padding
<Card class="p-4 md:p-6">
```

## Touch Targets

### Minimum Sizes

Ensure all interactive elements meet minimum touch targets:

- **Minimum size**: 44x44 pixels (iOS) / 48x48 pixels (Android)
- **Recommended**: 48x48 pixels for better accessibility

### Button Sizing

```rust
// Default buttons meet requirements
<Button class="h-10 px-4">Click</Button> // 40px height - acceptable

// Better: Larger touch targets
<Button class="h-12 px-6 md:h-10 md:px-4">Click</Button> // 48px on mobile
```

### Icon Buttons

```rust
// Add padding to meet minimum
<IconButton class="p-3 md:p-2">
    <Icon class="w-6 h-6" />
</IconButton>
```

### Spacing Between Targets

Maintain minimum 8px between touch targets:

```rust
<div class="flex gap-4 md:gap-2">
    <Button>Button 1</Button>
    <Button>Button 2</Button>
</div>
```

## Performance Considerations

### Image Optimization

```rust
// Use responsive images
<img
    class="w-full h-auto"
    src="image-small.jpg"
    srcset="image-small.jpg 640w, image-medium.jpg 1024w, image-large.jpg 1536w"
    sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
/>

// Or use aspect ratio containers
<AspectRatio ratio={16 / 9}>
    <img src="image.jpg" class="object-cover w-full h-full" />
</AspectRatio>
```

### Lazy Loading

```rust
// Load components only when needed
<Show when=move || is_large_screen()>
    <DesktopOnlyComponent />
</Show>
```

### CSS Optimization

```rust
// Prefer utility classes over inline styles
<div class="flex flex-col md:flex-row"> // ✅ Good

// Avoid heavy computations
<div style={move || format!("width: {}px", width.get())}> // ❌ Bad
```

### Reduce Bundle Size

```rust
// Only import what you need
use lyx_ui_shadcn_ui::{Button, Input}; // ✅ Good

use lyx_ui_shadcn_ui::prelude::*; // ❌ Bad - tree-shaking limited
```

## Testing Responsive Designs

### Browser DevTools

1. Open DevTools (F12)
2. Toggle device toolbar (Ctrl+Shift+M / Cmd+Shift+M)
3. Test common breakpoints:
   - 375px (iPhone SE)
   - 390px (iPhone 12/13)
   - 768px (iPad)
   - 1024px (iPad Pro, small laptop)
   - 1440px (desktop)

### Automated Testing

Use Playwright for responsive testing:

```typescript
// tests/e2e/responsive.spec.ts
test.describe('Responsive Design', () => {
    const sizes = [
        { width: 375, height: 667 },  // Mobile
        { width: 768, height: 1024 }, // Tablet
        { width: 1440, height: 900 }, // Desktop
    ];

    sizes.forEach(size => {
        test(`Layout at ${size.width}px`, async ({ page }) => {
            await page.setViewportSize(size);
            await page.goto('/');

            // Test mobile-specific behavior
            if (size.width < 768) {
                await expect(page.locator('.mobile-menu')).toBeVisible();
            } else {
                await expect(page.locator('.desktop-nav')).toBeVisible();
            }
        });
    });
});
```

### Accessibility Testing

Ensure touch targets are accessible:

```bash
# Use axe DevTools
npm run test:a11y

# Manual checklist
- [ ] All buttons >= 44x44px on mobile
- [ ] Touch targets have 8px spacing
- [ ] No horizontal scrolling on mobile (except intentional)
- [ ] Text is readable without zooming
- [ ] Forms are easy to complete on mobile
```

## Examples

### Complete Mobile-First Component

```rust
use leptos::*;
use lyx_ui_shadcn_ui::*;

#[component]
pub fn ResponsiveDashboard() -> impl IntoView {
    view! {
        <div class="min-h-screen bg-background">
            // Responsive header
            <header class="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur">
                <div class="container flex h-16 items-center px-4 sm:px-6 lg:px-8">
                    <div class="flex flex-1 items-center justify-between">
                        <Logo class="h-8 w-auto" />

                        // Desktop navigation
                        <nav class="hidden md:flex items-center space-x-6">
                            <a href="/" class="text-sm font-medium">Home</a>
                            <a href="/dashboard" class="text-sm font-medium">Dashboard</a>
                            <a href="/settings" class="text-sm font-medium">Settings</a>
                        </nav>

                        // Mobile menu trigger
                        <button class="md:hidden p-2" aria-label="Open menu">
                            <MenuIcon class="h-6 w-6" />
                        </button>
                    </div>
                </div>
            </header>

            // Main content area
            <main class="container px-4 py-6 sm:px-6 lg:px-8">
                // Page header
                <div class="mb-8">
                    <h1 class="text-2xl font-bold tracking-tight sm:text-3xl lg:text-4xl">
                        Dashboard
                    </h1>
                    <p class="mt-2 text-sm text-muted-foreground sm:text-base">
                        Welcome to your dashboard
                    </p>
                </div>

                // Stats grid - responsive columns
                <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-4 mb-8">
                    <Card class="p-6">
                        <CardHeader class="pb-2">
                            <CardTitle class="text-sm font-medium">Total Users</CardTitle>
                        </CardHeader>
                        <CardContent>
                            <div class="text-2xl font-bold">1,234</div>
                            <p class="text-xs text-muted-foreground">+12% from last month</p>
                        </CardContent>
                    </Card>
                    // More stat cards...
                </div>

                // Main content - stacked on mobile, side-by-side on desktop
                <div class="grid gap-6 lg:grid-cols-7">
                    // Primary content
                    <div class="lg:col-span-5 space-y-6">
                        <Card class="p-4 sm:p-6">
                            <CardHeader>
                                <CardTitle class="text-lg">Recent Activity</CardTitle>
                            </CardHeader>
                            <CardContent>
                                <div class="space-y-4">
                                    // Activity items
                                </div>
                            </CardContent>
                        </Card>
                    </div>

                    // Sidebar content
                    <div class="lg:col-span-2 space-y-6">
                        <Card class="p-4 sm:p-6">
                            <CardHeader>
                                <CardTitle class="text-lg">Quick Actions</CardTitle>
                            </CardHeader>
                            <CardContent class="space-y-2">
                                <Button class="w-full justify-start" size="sm">
                                    Create New
                                </Button>
                                <Button class="w-full justify-start" variant="outline" size="sm">
                                    Import Data
                                </Button>
                            </CardContent>
                        </Card>
                    </div>
                </div>
            </main>
        </div>
    }
}
```

### Responsive Form Example

```rust
#[component]
pub fn ResponsiveForm() -> impl IntoView {
    view! {
        <form class="space-y-6">
            <div>
                <h2 class="text-xl font-semibold mb-4 sm:text-2xl">User Information</h2>

                // Name fields - side-by-side on tablet and up
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <FormField>
                        <FormLabel>First Name</FormLabel>
                        <Input class="w-full" placeholder="John" />
                    </FormField>

                    <FormField>
                        <FormLabel>Last Name</FormLabel>
                        <Input class="w-full" placeholder="Doe" />
                    </FormField>
                </div>
            </div>

            // Contact section - responsive grid
            <div>
                <h3 class="text-lg font-semibold mb-4">Contact Information</h3>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <FormField>
                        <FormLabel>Email</FormLabel>
                        <Input type="email" class="w-full" placeholder="john@example.com" />
                    </FormField>

                    <FormField>
                        <FormLabel>Phone</FormLabel>
                        <Input type="tel" class="w-full" placeholder="+1 234 567 8900" />
                    </FormField>

                    <FormField class="md:col-span-2">
                        <FormLabel>Address</FormLabel>
                        <Input class="w-full" placeholder="123 Main St" />
                    </FormField>

                    <FormField>
                        <FormLabel>City</FormLabel>
                        <Input class="w-full" placeholder="New York" />
                    </FormField>

                    <FormField>
                        <FormLabel>State</FormLabel>
                        <Input class="w-full" placeholder="NY" />
                    </FormField>
                </div>
            </div>

            // Form actions - stacked on mobile, side-by-side on desktop
            <div class="flex flex-col-reverse sm:flex-row gap-3 sm:justify-end">
                <Button variant="outline" class="w-full sm:w-auto">
                    Cancel
                </Button>
                <Button class="w-full sm:w-auto">
                    Save Changes
                </Button>
            </div>
        </form>
    }
}
```

## Checklist for Mobile-First Development

Use this checklist when creating or modifying components:

### Layout
- [ ] Starts with single-column layout for mobile
- [ ] Uses responsive breakpoints correctly (md: not md:)
- [ ] Content doesn't overflow horizontally
- [ ] Vertical scrolling works naturally

### Typography
- [ ] Base font size is readable (16px minimum)
- [ ] Headings scale appropriately
- [ ] Line height is comfortable
- [ ] Text truncation handles long content

### Spacing
- [ ] Padding is appropriate for mobile (not too tight)
- [ ] Touch targets meet minimum size (44x44px)
- [ ] Spacing between interactive elements (8px minimum)

### Navigation
- [ ] Menu is accessible on mobile
- [ ] Breadcrumbs don't break layout
- [ ] Back/buttons are easily accessible

### Forms
- [ ] Input fields are full width on mobile
- [ ] Labels are positioned correctly
- [ ] Error messages are visible
- [ ] Submit buttons are prominent

### Performance
- [ ] Images are optimized
- [ ] No unnecessary re-renders
- [ ] Bundle size is minimized
- [ ] Lazy loading used appropriately

### Accessibility
- [ ] All interactive elements are keyboard accessible
- [ ] Touch targets meet WCAG guidelines
- [ ] Color contrast meets AA standards
- [ ] Screen reader announces content correctly

## Resources

- [Tailwind CSS Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [MDN: Responsive Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Mobile Design Patterns](https://mobilepatterns.com/)

---

*Last updated: January 2026*
