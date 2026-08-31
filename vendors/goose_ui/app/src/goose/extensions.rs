use tw_merge::tw_merge;
use leptos::prelude::*;
use icons::{Plus, Search}; 

#[component]
pub fn ExtensionsView() -> impl IntoView {
    view! {
        <div class="h-full flex flex-col p-6 bg-background overflow-y-auto">
            <div class="max-w-4xl w-full mx-auto space-y-8">
                <div class="flex items-center justify-between">
                    <div>
                        <h1 class="text-2xl font-bold tracking-tight text-foreground">"Extensions"</h1>
                        <p class="text-sm text-muted-foreground">"Gérez les capacités de votre agent."</p>
                    </div>
                    <button class="flex items-center gap-2 px-4 py-2 bg-primary text-primary-foreground rounded-lg text-sm font-medium hover:opacity-90 transition-all">
                        <Plus class="size-4" />
                        <span>"Ajouter une extension"</span>
                    </button>
                </div>

                <div class="relative group max-w-md">
                    <Search class="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
                    <input 
                        type="text" 
                        placeholder="Rechercher des extensions..." 
                        class="w-full bg-muted/50 border border-border rounded-xl py-2 pl-10 pr-4 text-sm outline-none focus:ring-2 focus:ring-primary/20 transition-all"
                    />
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <ExtensionCard name="FileSystem" desc="Accès au système de fichiers local." active=true />
                    <ExtensionCard name="Shell" desc="Exécution de commandes shell sécurisées." active=true />
                    <ExtensionCard name="GitHub" desc="Interaction avec les dépôts GitHub." active=false />
                    <ExtensionCard name="Memory" desc="Mémoire persistante à long terme." active=false />
                </div>
            </div>
        </div>
    }
}

#[component]
fn ExtensionCard(name: &'static str, desc: &'static str, active: bool) -> impl IntoView {
    view! {
        <div class="p-5 bg-card border border-border rounded-2xl flex items-start justify-between group hover:border-primary/50 transition-colors">
            <div class="space-y-1">
                <h3 class="font-bold text-sm text-foreground">{name}</h3>
                <p class="text-xs text-muted-foreground leading-relaxed">{desc}</p>
            </div>
            <div class=move || tw_merge!(
                "px-2 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider",
                if active { "bg-green-500/10 text-green-500" } else { "bg-muted text-muted-foreground" }
            )>
                {if active { "Active" } else { "Inactive" }}
            </div>
        </div>
    }
}
