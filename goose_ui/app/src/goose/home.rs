use leptos::prelude::*;
use icons::{Bot, Code, Terminal, BookOpen, Puzzle};

#[component]
pub fn HomeView() -> impl IntoView {
    view! {
        <div class="h-full flex flex-col items-center justify-center p-6 bg-transparent">
            <div class="max-w-2xl w-full text-center space-y-10">
                <div class="flex flex-col items-center gap-6">
                    <div class="size-16 bg-primary/10 rounded-3xl flex items-center justify-center shadow-inner">
                        <Bot class="size-10 text-primary" />
                    </div>
                    <div class="space-y-2">
                        <h1 class="text-3xl font-bold tracking-tight text-foreground">
                            "What can I help you build?"
                        </h1>
                        <p class="text-muted-foreground text-base max-w-md mx-auto">
                            "Goose is your open-source AI agent for software engineering. Ask a question or start a project."
                        </p>
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <HomeAction 
                        icon=move || view! { <Code class="size-5 text-muted-foreground group-hover:text-primary" /> }
                        title="Analyze Code" 
                        desc="Explain complex logic or find bugs."
                    />
                    <HomeAction 
                        icon=move || view! { <Terminal class="size-5 text-muted-foreground group-hover:text-primary" /> }
                        title="New Feature" 
                        desc="Scaffold new components or routes."
                    />
                    <HomeAction 
                        icon=move || view! { <BookOpen class="size-5 text-muted-foreground group-hover:text-primary" /> }
                        title="Documentation" 
                        desc="Ask about APIs or best practices."
                    />
                    <HomeAction 
                        icon=move || view! { <Puzzle class="size-5 text-muted-foreground group-hover:text-primary" /> }
                        title="Extensions" 
                        desc="Explore and manage your tools."
                    />
                </div>
            </div>
        </div>
    }
}

#[component]
fn HomeAction<F, IV>(icon: F, title: &'static str, desc: &'static str) -> impl IntoView 
where F: Fn() -> IV + Send + 'static, IV: IntoView
{
    view! {
        <button class="flex items-start gap-4 p-4 rounded-2xl border bg-card hover:bg-accent/50 transition-all text-left group shadow-sm">
            <div class="size-10 rounded-xl bg-muted flex items-center justify-center shrink-0 group-hover:bg-primary/10 transition-colors">
                {icon()}
            </div>
            <div class="space-y-1">
                <h3 class="font-bold text-sm text-foreground">{title}</h3>
                <p class="text-xs text-muted-foreground leading-relaxed">{desc}</p>
            </div>
        </button>
    }
}
