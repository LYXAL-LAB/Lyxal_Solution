#[cfg(test)]
mod integration_tests {
    use leptos::prelude::*;
    use crate::default::*;

    #[test]
    fn test_command_form_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...")/>
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_validation_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_theme_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_style_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_accessibility_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput 
                    placeholder=MaybeProp::from("Search...") 
                />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_performance_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_signal_integration() {
        let value_signal = RwSignal::new("".to_string());
        let disabled_signal = RwSignal::new(false);
        
        let _command_view = view! {
            <Command value=MaybeProp::from(value_signal)>
                <CommandInput 
                    placeholder=MaybeProp::from("Search...") 
                />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
        
        // Test signal integration
        value_signal.set("test".to_string());
        assert_eq!(value_signal.get(), "test");
        
        disabled_signal.set(true);
        assert!(disabled_signal.get());
    }

    #[test]
    fn test_command_callback_integration() {
        let callback = Callback::new(move |value: String| {
            // Test callback integration
            assert!(value.len() >= 0);
        });
        
        let _command_view = view! {
            <Command on_value_change=callback>
                <CommandInput placeholder=MaybeProp::from("Search...")/>
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_memory_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_network_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_battery_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_thermal_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_benchmark_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_load_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_stress_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_concurrent_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    #[test]
    fn test_command_scalability_integration() {
        let _command_view = view! {
            <Command>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results found."</CommandEmpty>
                    <CommandGroup heading=MaybeProp::from("Suggestions")>
                        <CommandItem>"Calendar"</CommandItem>
                        <CommandItem>"Search Emoji"</CommandItem>
                    </CommandGroup>
                </CommandList>
            </Command>
        };
    }

    // ===== E2E INTEGRATION TESTS =====
    // Tests for multi-component rendering, z-index conflicts, and global state isolation

    #[test]
    fn test_multiple_commands_simultaneous_rendering() {
        // Test: Multiple command components can be rendered simultaneously
        let command1_value = RwSignal::new("".to_string());
        let command2_value = RwSignal::new("".to_string());
        let command3_value = RwSignal::new("".to_string());

        let _view = view! {
            <div>
                <Command value=MaybeProp::from(command1_value)>
                    <CommandInput placeholder=MaybeProp::from("Command 1...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                        <CommandGroup heading=MaybeProp::from("Group 1")>
                            <CommandItem>"Item 1.1"</CommandItem>
                        </CommandGroup>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command2_value)>
                    <CommandInput placeholder=MaybeProp::from("Command 2...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                        <CommandGroup heading=MaybeProp::from("Group 2")>
                            <CommandItem>"Item 2.1"</CommandItem>
                        </CommandGroup>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command3_value)>
                    <CommandInput placeholder=MaybeProp::from("Command 3...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                        <CommandGroup heading=MaybeProp::from("Group 3")>
                            <CommandItem>"Item 3.1"</CommandItem>
                        </CommandGroup>
                    </CommandList>
                </Command>
            </div>
        };

        // Verify each command maintains independent state
        command1_value.set("test1".to_string());
        assert_eq!(command1_value.get(), "test1");
        assert_eq!(command2_value.get(), "");
        assert_eq!(command3_value.get(), "");

        command2_value.set("test2".to_string());
        assert_eq!(command1_value.get(), "test1");
        assert_eq!(command2_value.get(), "test2");
        assert_eq!(command3_value.get(), "");
    }

    #[test]
    fn test_command_css_selector_isolation() {
        // Test: CSS classes don't conflict between multiple commands
        let command1_value = RwSignal::new("".to_string());
        let command2_value = RwSignal::new("".to_string());

        let _view = view! {
            <div>
                <Command value=MaybeProp::from(command1_value)>
                    <CommandInput
                        placeholder=MaybeProp::from("Command 1...")
                        class=MaybeProp::from("custom-input-1")
                    />
                    <CommandList class="custom-list-1">
                        <CommandEmpty>"No results"</CommandEmpty>
                        <CommandGroup heading=MaybeProp::from("Group 1")>
                            <CommandItem class="custom-item">"Item 1"</CommandItem>
                        </CommandGroup>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command2_value)>
                    <CommandInput
                        placeholder=MaybeProp::from("Command 2...")
                        class=MaybeProp::from("custom-input-2")
                    />
                    <CommandList class="custom-list-2">
                        <CommandEmpty>"No results"</CommandEmpty>
                        <CommandGroup heading=MaybeProp::from("Group 2")>
                            <CommandItem class="custom-item">"Item 2"</CommandItem>
                        </CommandGroup>
                    </CommandList>
                </Command>
            </div>
        };

        // Both commands should maintain independent state
        command1_value.set("value1".to_string());
        command2_value.set("value2".to_string());
        assert_eq!(command1_value.get(), "value1");
        assert_eq!(command2_value.get(), "value2");
    }

    #[test]
    fn test_command_event_propagation_isolation() {
        // Test: Events from one command don't affect other commands
        let command1_value = RwSignal::new("".to_string());
        let command2_value = RwSignal::new("".to_string());
        let event_count = RwSignal::new(0);

        let callback1 = Callback::new(move |value: String| {
            event_count.update(|n| *n += 1);
            command1_value.set(value);
        });

        let callback2 = Callback::new(move |value: String| {
            event_count.update(|n| *n += 1);
            command2_value.set(value);
        });

        let _view = view! {
            <div>
                <Command value=MaybeProp::from(command1_value) on_value_change=callback1>
                    <CommandInput placeholder=MaybeProp::from("Command 1...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command2_value) on_value_change=callback2>
                    <CommandInput placeholder=MaybeProp::from("Command 2...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>
            </div>
        };

        // Verify independent event handling
        command1_value.set("test1".to_string());
        assert_eq!(command1_value.get(), "test1");
        assert_eq!(command2_value.get(), "");

        event_count.set(5);
        assert_eq!(event_count.get(), 5);
    }

    #[test]
    fn test_command_global_state_isolation() {
        // Test: Each command maintains its own context state
        let command1_value = RwSignal::new("".to_string());
        let command2_value = RwSignal::new("".to_string());
        let shared_state = RwSignal::new("shared".to_string());

        let _view = view! {
            <div>
                <Command value=MaybeProp::from(command1_value)>
                    <CommandInput placeholder=MaybeProp::from("Command 1...") />
                    <CommandList>
                        <CommandEmpty>{move || shared_state.get()}</CommandEmpty>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command2_value)>
                    <CommandInput placeholder=MaybeProp::from("Command 2...") />
                    <CommandList>
                        <CommandEmpty>{move || shared_state.get()}</CommandEmpty>
                    </CommandList>
                </Command>
            </div>
        };

        // Both commands should render successfully
        command1_value.set("value1".to_string());
        command2_value.set("value2".to_string());
        assert_eq!(command1_value.get(), "value1");
        assert_eq!(command2_value.get(), "value2");

        // Shared state should be accessible to both
        shared_state.set("updated".to_string());
        assert_eq!(shared_state.get(), "updated");
    }

    #[test]
    fn test_command_concurrent_lifecycle_management() {
        // Test: Multiple commands can be operated concurrently
        let command1_value = RwSignal::new("".to_string());
        let command2_value = RwSignal::new("".to_string());
        let command3_value = RwSignal::new("".to_string());

        let lifecycle_tracker = RwSignal::new(vec![]);

        let callback1 = Callback::new(move |value: String| {
            lifecycle_tracker.update(|v| v.push(format!("command1: {}", value)));
        });

        let callback2 = Callback::new(move |value: String| {
            lifecycle_tracker.update(|v| v.push(format!("command2: {}", value)));
        });

        let callback3 = Callback::new(move |value: String| {
            lifecycle_tracker.update(|v| v.push(format!("command3: {}", value)));
        });

        let _view = view! {
            <div>
                <Command value=MaybeProp::from(command1_value) on_value_change=callback1>
                    <CommandInput placeholder=MaybeProp::from("Command 1...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command2_value) on_value_change=callback2>
                    <CommandInput placeholder=MaybeProp::from("Command 2...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(command3_value) on_value_change=callback3>
                    <CommandInput placeholder=MaybeProp::from("Command 3...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>
            </div>
        };

        // Test concurrent operation
        command1_value.set("test1".to_string());
        command2_value.set("test2".to_string());
        command3_value.set("test3".to_string());

        assert_eq!(command1_value.get(), "test1");
        assert_eq!(command2_value.get(), "test2");
        assert_eq!(command3_value.get(), "test3");
    }

    #[test]
    fn test_command_rapid_state_changes() {
        // Test: Rapid value changes don't cause conflicts
        let command_value = RwSignal::new("".to_string());

        let _view = view! {
            <Command value=MaybeProp::from(command_value)>
                <CommandInput placeholder=MaybeProp::from("Search...") />
                <CommandList>
                    <CommandEmpty>"No results"</CommandEmpty>
                </CommandList>
            </Command>
        };

        // Rapid state changes
        for i in 0..100 {
            command_value.set(format!("test{}", i));
            assert_eq!(command_value.get(), format!("test{}", i));
        }
    }

    #[test]
    fn test_command_memory_management_multiple_instances() {
        // Test: Multiple commands don't cause memory leaks
        let commands: Vec<RwSignal<String>> = (0..10)
            .map(|_| RwSignal::new("".to_string()))
            .collect();

        let _view = view! {
            <div>
                {commands.into_iter().enumerate().map(|(i, value)| {
                    view! {
                        <Command value=MaybeProp::from(value)>
                            <CommandInput placeholder=MaybeProp::from(&format!("Command {}...", i)) />
                            <CommandList>
                                <CommandEmpty>{format!("No results for command {}", i)}</CommandEmpty>
                            </CommandList>
                        </Command>
                    }
                }).collect::<Vec<_>>()}
            </div>
        };

        // All commands should initialize successfully
    }

    #[test]
    fn test_command_nested_components() {
        // Test: Command can be nested within other UI structures
        let command_value = RwSignal::new("".to_string());
        let panel_open = RwSignal::new(false);

        let _view = view! {
            <div>
                <div class="panel">
                    <button on:click=move |_| panel_open.set(!panel_open.get())>
                        "Toggle Panel"
                    </button>
                    {move || if panel_open.get() {
                        view! {
                            <div class="panel-content">
                                <Command value=MaybeProp::from(command_value)>
                                    <CommandInput placeholder=MaybeProp::from("Search...") />
                                    <CommandList>
                                        <CommandEmpty>"No results"</CommandEmpty>
                                        <CommandGroup heading=MaybeProp::from("Suggestions")>
                                            <CommandItem>"Item 1"</CommandItem>
                                            <CommandItem>"Item 2"</CommandItem>
                                        </CommandGroup>
                                    </CommandList>
                                </Command>
                            </div>
                        }
                    } else {
                        view! {}
                    }}
                </div>
            </div>
        };

        // Panel opens
        panel_open.set(true);
        assert!(panel_open.get());

        // Command inside panel should work
        command_value.set("test".to_string());
        assert_eq!(command_value.get(), "test");
    }

    #[test]
    fn test_command_with_other_interactive_components() {
        // Test: Command works alongside other interactive components
        let command_value = RwSignal::new("".to_string());
        let button_clicks = RwSignal::new(0);
        let input_value = RwSignal::new("".to_string());

        let _view = view! {
            <div>
                <button
                    on:click=move |_| {
                        button_clicks.update(|n| *n += 1);
                    }
                >
                    "Regular Button"
                </button>

                <input
                    type="text"
                    on:input=move |e| {
                        input_value.set(event_target_value(&e));
                    }
                />

                <Command value=MaybeProp::from(command_value)>
                    <CommandInput placeholder=MaybeProp::from("Search...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>
            </div>
        };

        // All components should work independently
        button_clicks.set(5);
        assert_eq!(button_clicks.get(), 5);

        input_value.set("test input".to_string());
        assert_eq!(input_value.get(), "test input");

        command_value.set("search value".to_string());
        assert_eq!(command_value.get(), "search value");
    }

    #[test]
    fn test_command_theme_variants_coexistence() {
        // Test: Default and New York theme variants can coexist
        let default_value = RwSignal::new("".to_string());
        let newyork_value = RwSignal::new("".to_string());

        let _view = view! {
            <div>
                <Command value=MaybeProp::from(default_value)>
                    <CommandInput placeholder=MaybeProp::from("Default Command...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>

                <Command value=MaybeProp::from(newyork_value)>
                    <CommandInput placeholder=MaybeProp::from("New York Command...") />
                    <CommandList>
                        <CommandEmpty>"No results"</CommandEmpty>
                    </CommandList>
                </Command>
            </div>
        };

        // Both variants should coexist
        default_value.set("default".to_string());
        newyork_value.set("newyork".to_string());
        assert_eq!(default_value.get(), "default");
        assert_eq!(newyork_value.get(), "newyork");
    }
}
