use leptos::prelude::*;
use leptos_router::components::Outlet;
use crate::goose::sidebar::GooseSidebar;
use icons::{AppWindow, PanelLeft}; // Assuming PanelLeft for SidebarTrigger
use tw_merge::tw_merge;

#[component]
pub fn AppLayout() -> impl IntoView {
    // We'll simulate the macOS check or just use a default padding
    let is_macos = true; 
    let header_padding = if is_macos { "pl-20" } else { "pl-4" };

    view! {
        <div class="flex h-screen w-full bg-background overflow-hidden font-sans text-foreground">
            // Sidebar Trigger and New Window button (Top Left)
            <div class=move || tw_merge!("absolute top-3 z-50 flex items-center gap-2", header_padding)>
                <button class="p-1.5 hover:bg-muted rounded-md transition-colors text-muted-foreground hover:text-foreground">
                    <PanelLeft class="size-4" />
                </button>
                <button class="p-1.5 hover:bg-muted rounded-md transition-colors text-muted-foreground hover:text-foreground" title="Start a new session in a new window">
                    <AppWindow class="size-4" />
                </button>
            </div>

            <GooseSidebar />
            
            <main class="flex-1 flex flex-col min-w-0 relative bg-background">
                // SidebarInset effect is often a slightly different background or shadow
                <div class="flex-1 flex flex-col min-h-0">
                    <Outlet />
                </div>
            </main>
        </div>
    }
}
