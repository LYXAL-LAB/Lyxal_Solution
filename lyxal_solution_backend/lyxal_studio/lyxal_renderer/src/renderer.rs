use leptos::*;
use crate::components::render_component;
use crate::props_normalization::PropsNormalizer;
use lyxal_types::LyxalStudioData;
use lyxal_types::instance::InstanceChild;
use std::collections::HashMap;

#[component]
pub fn LyxalCanvas(data: LyxalStudioData) -> impl IntoView {
    let (data_sig, _set_data) = create_signal(data);
    provide_context(data_sig);
    
    view! {
        <div class="lyxal-canvas">
            <InstanceRenderer id="root".to_string() />
        </div>
    }
}

#[component]
pub fn InstanceRenderer(id: String) -> impl IntoView {
    let data = use_context::<ReadSignal<LyxalStudioData>>().expect("Data context missing");
    
    move || {
        data.with(|d| {
            if let Some(instance) = d.instances.get(&id) {
                let normalizer = PropsNormalizer {
                    assets: &d.assets,
                    pages: &d.pages,
                    asset_base_url: "/assets/".to_string(),
                };
                
                // Use normalizer for props (conceptual)
                let mut _props_map = HashMap::new();
                for prop_id in &instance.props {
                    if let Some(prop) = d.props.get(prop_id) {
                        if let Some((name, val)) = normalizer.normalize(prop) {
                            _props_map.insert(name, val);
                        }
                    }
                }

                let children = instance.children.iter().map(|child| {
                    match child {
                        InstanceChild::Id { value } => view! { <InstanceRenderer id=value.clone() /> }.into_view(),
                        InstanceChild::Text { value, .. } => view! { <span>{value.clone()}</span> }.into_view(),
                        _ => view! {}.into_view(),
                    }
                }).collect_view();

                render_component(instance, String::new(), children)
            } else {
                view! {}.into_view()
            }
        })
    }
}


