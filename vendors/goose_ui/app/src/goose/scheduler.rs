use leptos::prelude::*;
use crate::components::ui::button::{Button, ButtonSize, ButtonVariant};
use icons::{Play, Pause, Plus, RefreshCw, Square, Trash, Settings}; // Using standard icons

#[derive(Clone, Debug, PartialEq)]
pub struct ScheduledJob {
    pub id: String,
    pub cron: String,
    pub last_run: Option<String>,
    pub next_run: Option<String>,
    pub running: bool,
    pub paused: bool,
}

#[component]
pub fn SchedulerView() -> impl IntoView {
    // Mock data
    let jobs = vec![
        ScheduledJob {
            id: "daily-summary".into(),
            cron: "0 9 * * 1-5".into(),
            last_run: Some("2023-10-27 09:00".into()),
            next_run: Some("2023-10-30 09:00".into()),
            running: false,
            paused: false,
        },
        ScheduledJob {
            id: "hourly-cleanup".into(),
            cron: "0 * * * *".into(),
            last_run: Some("2023-10-27 14:00".into()),
            next_run: Some("2023-10-27 15:00".into()),
            running: true,
            paused: false,
        },
        ScheduledJob {
            id: "weekly-report".into(),
            cron: "0 9 * * 1".into(),
            last_run: Some("2023-10-23 09:00".into()),
            next_run: Some("2023-10-30 09:00".into()),
            running: false,
            paused: true,
        },
    ];

    view! {
        <div class="flex flex-1 flex-col h-full bg-background-default">
             <div class="bg-background px-8 pb-8 pt-16 border-b">
                <div class="flex flex-col page-transition">
                  <div class="flex justify-between items-center mb-1">
                    <h1 class="text-4xl font-light">"Scheduler"</h1>
                    <div class="flex gap-2">
                      <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="flex items-center gap-2">
                        <RefreshCw class="size-4" />
                        "Refresh"
                      </Button>
                      <Button size=ButtonSize::Sm class="flex items-center gap-2">
                        <Plus class="size-4" />
                        "Create Schedule"
                      </Button>
                    </div>
                  </div>
                  <p class="text-sm text-text-muted mb-1 text-muted-foreground">
                    "Create and manage scheduled tasks to run recipes automatically at specified times."
                  </p>
                </div>
            </div>

            <div class="flex-1 min-h-0 relative px-8 py-4">
                 <div class="space-y-2">
                    <For each=move || jobs.clone() key=|j| j.id.clone() children=move |job| {
                         let is_running = job.running;
                         let is_paused = job.paused;
                         
                        view! {
                            <div class="flex flex-col p-4 border rounded-lg bg-card hover:bg-muted/50 transition-colors">
                                <div class="flex justify-between items-start gap-4">
                                    <div class="min-w-0 flex-1">
                                         <div class="flex items-center gap-2 mb-1">
                                             <h3 class="text-base font-medium truncate">{job.id}</h3>
                                             <Show when=move || is_running>
                                                 <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900/30 dark:text-green-300">
                                                     <span class="inline-block w-2 h-2 bg-green-500 rounded-full mr-1 animate-pulse"></span>
                                                     "Running"
                                                 </span>
                                             </Show>
                                             <Show when=move || is_paused>
                                                 <span class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-orange-100 text-orange-800 dark:bg-orange-900/30 dark:text-orange-300">
                                                     <Pause class="size-3 mr-1" />
                                                     "Paused"
                                                 </span>
                                             </Show>
                                         </div>
                                         <p class="text-sm text-muted-foreground mb-2 font-mono bg-muted/50 w-fit px-1 rounded">{job.cron}</p>
                                         <div class="flex items-center text-xs text-muted-foreground gap-4">
                                            <span>"Last run: " {job.last_run.unwrap_or("Never".into())}</span>
                                            <span>"Next run: " {job.next_run.unwrap_or("Unknown".into())}</span>
                                         </div>
                                    </div>
                                    
                                    <div class="flex items-center gap-2 shrink-0">
                                         <Show when=move || is_running>
                                            <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="h-8">
                                                <Settings class="size-4 mr-1" />
                                                "Inspect"
                                            </Button>
                                            <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="h-8">
                                                <Square class="size-4 mr-1" />
                                                "Kill"
                                            </Button>
                                         </Show>
                                         <Show when=move || !is_running>
                                            <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="h-8">
                                                <Settings class="size-4 mr-1" /> // Edit icon replacement
                                                "Edit"
                                            </Button>
                                            <Show when=move || is_paused>
                                                <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="h-8">
                                                    <Play class="size-4 mr-1" />
                                                    "Resume"
                                                </Button>
                                            </Show>
                                            <Show when=move || !is_paused>
                                                <Button variant=ButtonVariant::Outline size=ButtonSize::Sm class="h-8">
                                                    <Pause class="size-4 mr-1" />
                                                    "Pause"
                                                </Button>
                                            </Show>
                                         </Show>
                                         <Button variant=ButtonVariant::Ghost size=ButtonSize::Sm class="h-8 text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-900/20">
                                             <Trash class="size-4" />
                                         </Button>
                                    </div>
                                </div>
                            </div>
                        }
                    } />
                 </div>
            </div>
        </div>
    }
}
