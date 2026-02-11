use leptos::prelude::*;

use crate::components::ui::sheet::{
    Sheet, SheetBody, SheetClose, SheetContent, SheetDescription, SheetDirection, SheetTitle, SheetTrigger,
};

#[component]
pub fn DemoSheet() -> impl IntoView {
    view! {
        <Sheet>
            <SheetTrigger>"Open Sheet"</SheetTrigger>

            <SheetContent direction=SheetDirection::Right>
                <SheetBody>
                    <SheetTitle>"Sheet Title"</SheetTitle>
                    <SheetDescription>"This is the content inside the sheet."</SheetDescription>

                    <p class="mt-4 text-sm">
                        "This sheet demonstrates the new pattern without leptos_use dependency. "
                        "Click the backdrop or press ESC to close."
                    </p>

                    <div class="flex gap-2 mt-6">
                        <SheetClose>"Close"</SheetClose>
                    </div>
                </SheetBody>
            </SheetContent>
        </Sheet>
    }
}