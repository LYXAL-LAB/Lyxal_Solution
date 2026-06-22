use lyxal_types::prop::Action;
use lyxal_state::LyxalState;
use leptos::*;

pub struct ActionHandler;

impl ActionHandler {
    pub async fn execute_actions(actions: &[Action], state: LyxalState) {
        for action in actions {
            match action.r#type.as_str() {
                "execute" => {
                    // Ici, on utilise Lyxal pour exÃ©cuter le code de l'action
                    let _ = state.query(&action.code).await;
                }
                _ => {}
            }
        }
    }
}

#[component]
pub fn ActionTrigger<F>(on_trigger: F, children: Children) -> impl IntoView 
where 
    F: Fn() + 'static 
{
    view! {
        <div on:click=move |_| on_trigger()>
            {children()}
        </div>
    }
}
