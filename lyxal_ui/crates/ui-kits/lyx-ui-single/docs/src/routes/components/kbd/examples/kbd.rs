use leptos::prelude::*;
use singlestage::kbd::*;

#[component]
pub fn KbdExample() -> impl IntoView {
view! {
<div class="flex flex-col items-center gap-4">
<KbdGroup>
<Kbd>"âŒ˜"</Kbd>
<Kbd>"â‡§"</Kbd>
<Kbd>"âŒ¥"</Kbd>
<Kbd>"âŒƒ"</Kbd>
</KbdGroup>
<KbdGroup>
<Kbd>"Ctrl"</Kbd>
<span>"+"</span>
<Kbd>"B"</Kbd>
</KbdGroup>
</div>
}
}
