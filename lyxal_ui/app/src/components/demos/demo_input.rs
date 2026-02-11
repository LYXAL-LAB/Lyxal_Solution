use leptos::prelude::*;

use crate::components::ui::input::Input;

// TODO Fix: Input type="number" can take "e" as a valid input

#[component]
pub fn DemoInput() -> impl IntoView {
    let name_signal = RwSignal::new(String::new());

    view! {
        <div class="space-y-4 w-full max-w-lg">
            <h2 class="text-2xl font-bold">Input Demo</h2>

            <Input placeholder="Default input" />
            <Input r#type="email" placeholder="Email input" />
            <Input r#type="password" placeholder="Password input" />
            <Input class="border-2 border-purple-500 focus:border-purple-700" placeholder="Custom styled input" />
            <Input r#type="number" placeholder="Number input" />

            // Two-way binding example
            <div class="pt-4 border-t">
                <p class="mb-2 text-sm text-muted-foreground">Two-way binding:</p>
                <Input placeholder="Type here..." bind_value=name_signal />
                <p class="mt-2 text-sm">"Value: " {move || name_signal.get()}</p>
            </div>
        </div>
    }
}