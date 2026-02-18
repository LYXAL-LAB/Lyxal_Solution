// This example demonstrates mobile-first design patterns
// following the guidelines in docs/components/mobile-design-guidelines.md

use leptos::*;
use lyx_ui_shadcn::*;

#[component]
pub fn MobileFirstExample() -> impl IntoView {
view! {
// Example 1: Responsive Grid
// Single column on mobile, 2 on tablet, 3-4 on desktop
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
<Card class="p-4">
<CardContent>
<h3 class="font-semibold">Card 1</h3>
<p class="text-sm text-muted-foreground">Content here</p>
</CardContent>
</Card>
<Card class="p-4">
<CardContent>
<h3 class="font-semibold">Card 2</h3>
<p class="text-sm text-muted-foreground">Content here</p>
</CardContent>
</Card>
<Card class="p-4">
<CardContent>
<h3 class="font-semibold">Card 3</h3>
<p class="text-sm text-muted-foreground">Content here</p>
</CardContent>
</Card>
<Card class="p-4">
<CardContent>
<h3 class="font-semibold">Card 4</h3>
<p class="text-sm text-muted-foreground">Content here</p>
</CardContent>
</Card>
</div>

// Example 2: Responsive Typography
<div class="mt-8">
<h1 class="text-2xl font-bold md:text-4xl lg:text-5xl">
Responsive Heading
</h1>
<p class="mt-2 text-sm md:text-base lg:text-lg text-muted-foreground">
This text scales appropriately across device sizes.
</p>
</div>

// Example 3: Responsive Spacing
<div class="px-4 py-6 sm:px-6 sm:py-8 lg:px-8 lg:py-12">
<p>Container with responsive padding</p>
</div>

// Example 4: Touch-Friendly Buttons
// 48px height on mobile (meets minimum touch target)
<div class="flex gap-4 mt-8">
<Button class="h-12 px-6 md:h-10 md:px-4">
Primary Action
</Button>
<Button variant="outline" class="h-12 px-6 md:h-10 md:px-4">
Secondary
</Button>
</div>

// Example 5: Responsive Form
<form class="mt-8 space-y-4 md:space-y-6">
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
<div>
<label class="text-sm font-medium">First Name</label>
<Input class="mt-1 w-full" placeholder="John" />
</div>
<div>
<label class="text-sm font-medium">Last Name</label>
<Input class="mt-1 w-full" placeholder="Doe" />
</div>
</div>
<Button type="submit" class="w-full md:w-auto">
Submit
</Button>
</form>

// Example 6: Responsive Dialog
// Full width on mobile, constrained on desktop
<div class="mt-8">
<Button on_click=move |_| {
// Open dialog logic here
}>
Open Dialog
</Button>
</div>
}
}
