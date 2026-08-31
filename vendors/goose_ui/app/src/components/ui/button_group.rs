use leptos::prelude::*;
use tw_merge::*;

#[component]
pub fn ButtonGroup(
#[prop(into, optional)] orientation: Signal<ButtonGroupOrientation>,
#[prop(into, optional)] class: String,
children: Children,
) -> impl IntoView {
let merged_class = Memo::new(move |_| {
let orientation = orientation.get();
let button_group = ButtonGroupClass { orientation };
button_group.with_class(class.clone())
});

view! {
<div data-name="ButtonGroup" role="group" class=move || merged_class.get()>
{children()}
</div>
}
}

#[derive(TwClass, Default)]
#[tw(
class = "flex w-fit items-stretch [&>*]:focus-visible:z-10 [&>*]:focus-visible:relative [&>[data-slot=select-trigger]:not([class*='w-'])]:w-fit [&>input]:flex-1 has-[select[aria-hidden=true]:last-child]:[&>[data-slot=select-trigger]:last-of-type]:rounded-r-md has-[>[data-slot=button-group]]:gap-2"
)]
pub struct ButtonGroupClass {
pub orientation: ButtonGroupOrientation,
}

#[derive(TwVariant)]
pub enum ButtonGroupOrientation {
#[tw(
default,
class = "[&>*:not(:first-child)]:rounded-l-none [&>*:not(:first-child)]:border-l-0 [&>*:not(:last-child)]:rounded-r-none"
)]
Horizontal,
#[tw(
class = "flex-col [&>*:not(:first-child)]:rounded-t-none [&>*:not(:first-child)]:border-t-0 [&>*:not(:last-child)]:rounded-b-none"
)]
Vertical,
}
