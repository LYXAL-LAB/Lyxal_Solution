use leptos::prelude::*;

use crate::components::ui::drawer::{
Drawer, DrawerBody, DrawerClose, DrawerContent, DrawerDescription, DrawerHandle, DrawerTitle, DrawerTrigger,
};

#[component]
pub fn DemoDrawer() -> impl IntoView {
view! {
<div class="text-center">
<h1 class="mb-4 text-4xl font-bold text-foreground">Vaul Drawer Demo</h1>
<p class="mb-8 text-muted-foreground">Click the button below to open the drawer</p>
<DrawerTrigger>Open Drawer</DrawerTrigger>
</div>

<Drawer>
<DrawerContent>
<DrawerHandle />
<DrawerBody class="justify-center items-center">
<DrawerTitle>Drawer Title</DrawerTitle>
<DrawerDescription>Drag down to close or click outside.</DrawerDescription>

<DrawerClose>Close</DrawerClose>
</DrawerBody>
</DrawerContent>
</Drawer>
}
}
