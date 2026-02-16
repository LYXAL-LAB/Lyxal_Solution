# Tutorial: Form Components Deep Dive

**Video Length**: ~25 minutes | **Difficulty**: Intermediate | **Series**: Component Series

## Overview

A comprehensive guide to form components in leptos-shadcn-ui. Learn advanced patterns, composition techniques, and best practices for building robust forms.

## What You'll Learn

- Advanced input patterns (masked, formatted, validated)
- Building custom form controls
- Form validation architecture
- Composing complex forms
- Accessible form layouts
- Integrating with backend APIs

## Prerequisites

- Completed Getting Started series
- Understanding of signals and reactivity
- Familiarity with basic forms

## Video Outline

**[0:00]** Introduction to form components ecosystem
**[2:00]** Input component deep dive
**[5:00]** Textarea and rich text inputs
**[7:30]** Select and combobox patterns
**[10:00]** Checkbox and radio groups
**[12:30]** Switch and toggle controls
**[14:30]** Date and time pickers
**[17:00]** Form validation architecture
**[19:30]** Building a multi-step form
**[22:00]** Form accessibility patterns
**[24:00]** Summary and resources

## Component Library

### Input Component

The Input component supports various types and configurations:

```rust
use leptos::*;
use lyx_ui_shadcn_input::Input;
use lyx_ui_shadcn_label::Label;

#[component]
pub fn InputExamples() -> impl IntoView {
    let (text_value, set_text_value) = create_signal(String::new());
    let (email_value, set_email_value) = create_signal(String::new());
    let (password_value, set_password_value) = create_signal(String::new());
    let (number_value, set_number_value) = create_signal(0);

    view! {
        <div class="space-y-6">
            // Text input with icon
            <div class="space-y-2">
                <Label for="search">"Search"</Label>
                <div class="relative">
                    <span class="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground">
                        "🔍"
                    </span>
                    <Input
                        id="search"
                        class="pl-10"
                        placeholder="Search..."
                        value=text_value
                        on_change=move |ev| {
                            set_text_value.set(event_target_value(&ev));
                        }
                    />
                </div>
            </div>

            // Email input with validation
            <div class="space-y-2">
                <Label for="email">"Email"</Label>
                <Input
                    id="email"
                    type="email"
                    placeholder="you@example.com"
                    value=email_value
                    on_change=move |ev| {
                        set_email_value.set(event_target_value(&ev));
                    }
                />
            </div>

            // Password input with visibility toggle
            <div class="space-y-2">
                <Label for="password">"Password"</Label>
                <PasswordInput
                    id="password"
                    value=password_value
                    on_change=set_password_value
                />
            </div>

            // Number input
            <div class="space-y-2">
                <Label for="quantity">"Quantity"</Label>
                <Input
                    id="quantity"
                    type="number"
                    min="0"
                    max="100"
                    step="1"
                    value=number_value
                    on_change=move |ev| {
                        set_number_value.set(event_target_value(&ev).parse().unwrap_or(0));
                    }
                />
            </div>
        </div>
    }
}
```

### Custom Password Input Component

```rust
#[component]
pub fn PasswordInput(
    id: String,
    value: ReadSignal<String>,
    on_change: WriteSignal<String>,
    #[prop(default = false)]
    required: bool,
) -> impl IntoView {
    let (show_password, set_show_password) = create_signal(false);

    view! {
        <div class="relative">
            <Input
                id=id.clone()
                type=move || if show_password.get() { "text" } else { "password" }
                value=value
                on_change=move |ev| {
                    on_change.set(event_target_value(&ev));
                }
                required=required
            />
            <button
                type="button"
                class="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
                on_click=move |_| set_show_password.update(|b| *b = !*b)
                aria_label=move || if show_password.get() {
                    "Hide password"
                } else {
                    "Show password"
                }
            >
                {move || if show_password.get() {
                    "🙈"
                } else {
                    "👁️"
                }}
            </button>
        </div>
    }
}
```

### Textarea Component

```rust
use lyx_ui_shadcn_textarea::Textarea;

#[component]
pub fn TextareaExamples() -> impl IntoView {
    let (message, set_message) = create_signal(String::new());
    let char_count = move || message.get().chars().count();

    view! {
        <div class="space-y-4">
            // Basic textarea
            <div class="space-y-2">
                <Label for="message">"Message"</Label>
                <Textarea
                    id="message"
                    placeholder="Enter your message..."
                    rows=4
                    value=message
                    on_change=move |ev| {
                        set_message.set(event_target_value(&ev));
                    }
                />
                <div class="flex justify-between text-sm text-muted-foreground">
                    <span>"Optional"</span>
                    <span>{char_count()}"/500"</span>
                </div>
            </div>

            // Auto-resizing textarea
            <div class="space-y-2">
                <Label for="auto-resize">"Auto-resizing Textarea"</Label>
                <AutoResizeTextarea
                    id="auto-resize".to_string()
                    placeholder="This grows as you type..."
                    min_rows=2
                    max_rows=8
                />
            </div>
        </div>
    }
}
```

### Select Component

```rust
use lyx_ui_shadcn_select::{Select, SelectContent, SelectItem, SelectTrigger, SelectValue, SelectLabel, SelectSeparator};

#[component]
pub fn SelectExamples() -> impl IntoView {
    let (role, set_role) = create_signal(String::new());
    let (status, set_status) = create_signal("active".to_string());
    let (categories, set_categories) = create_signal(Vec::<String>::new());

    view! {
        <div class="space-y-6">
            // Basic select
            <div class="space-y-2">
                <Label for="role">"Role"</Label>
                <Select value=role on_change=set_role>
                    <SelectTrigger id="role">
                        <SelectValue placeholder="Select a role"/>
                    </SelectTrigger>
                    <SelectContent>
                        <SelectLabel>"User Roles"</SelectLabel>
                        <SelectItem value="user">"User"</SelectItem>
                        <SelectItem value="admin">"Administrator"</SelectItem>
                        <SelectItem value="moderator">"Moderator"</SelectItem>
                        <SelectSeparator/>
                        <SelectLabel>"System Roles"</SelectLabel>
                        <SelectItem value="system">"System"</SelectItem>
                        <SelectItem value="bot">"Bot"</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            // Select with groups
            <div class="space-y-2">
                <Label for="status">"Status"</Label>
                <Select value=status on_change=set_status>
                    <SelectTrigger id="status">
                        <SelectValue/>
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="active">"🟢 Active"</SelectItem>
                        <SelectItem value="busy">"🔴 Busy"</SelectItem>
                        <SelectItem value="away">"🟡 Away"</SelectItem>
                        <SelectItem value="offline">"⚫ Offline"</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            // Multi-select (checkbox group)
            <div class="space-y-2">
                <Label>"Categories (Multi-select)"</Label>
                <MultiSelect
                    options=vec![
                        ("tech".to_string(), "Technology".to_string()),
                        ("design".to_string(), "Design".to_string()),
                        ("business".to_string(), "Business".to_string()),
                        ("marketing".to_string(), "Marketing".to_string()),
                    ]
                    selected=categories
                    on_change=set_categories
                />
            </div>
        </div>
    }
}
```

### Checkbox and Radio Components

```rust
use lyx_ui_shadcn_checkbox::Checkbox;
use lyx_ui_shadcn_radio_group::{RadioGroup, RadioGroupItem};

#[component]
pub fn CheckboxRadioExamples() -> impl IntoView {
    let (terms, set_terms) = create_signal(false);
    let (newsletter, set_newsletter) = create_signal(true);
    let (plan, set_plan) = create_signal("pro".to_string());
    let (preferences, set_preferences) = create_signal(Vec::<String>::new());

    view! {
        <div class="space-y-6">
            // Single checkbox
            <div class="flex items-center space-x-2">
                <Checkbox
                    id="terms"
                    checked=terms
                    on_change=set_terms
                />
                <Label for="terms" class="font-normal">
                    "I accept the terms and conditions"
                </Label>
            </div>

            // Checkbox list
            <div class="space-y-2">
                <Label>"Notifications"</Label>
                {["Email", "SMS", "Push", "In-app"].iter().map(|&notif| {
                    let notif_string = notif.to_string();
                    let is_checked = create_memo(move |_| {
                        preferences.get().contains(&notif_string)
                    });

                    view! {
                        <div class="flex items-center space-x-2">
                            <Checkbox
                                id=format!("notif-{}", notif.to_lowercase())
                                checked=is_checked
                                on_change=move |checked| {
                                    set_preferences.update(|prefs| {
                                        if checked {
                                            prefs.push(notif_string.clone());
                                        } else {
                                            prefs.retain(|p| p != &notif_string);
                                        }
                                    });
                                }
                            />
                            <Label
                                for=format!("notif-{}", notif.to_lowercase())
                                class="font-normal"
                            >
                                {notif}
                            </Label>
                        </div>
                    }
                }).collect_view()}
            </div>

            // Radio group
            <div class="space-y-2">
                <Label>"Select a plan"</Label>
                <RadioGroup value=plan on_change=set_plan>
                    {[
                        ("free".to_string(), "Free - $0/month".to_string()),
                        ("pro".to_string(), "Pro - $29/month".to_string()),
                        ("enterprise".to_string(), "Enterprise - Custom".to_string()),
                    ].into_iter().map(|(value, label)| {
                        view! {
                            <div class="flex items-center space-x-2">
                                <RadioGroupItem value=value.clone() id=value.clone()/>
                                <Label for=value class="font-normal cursor-pointer">
                                    {label}
                                </Label>
                            </div>
                        }
                    }).collect_view()}
                </RadioGroup>
            </div>
        </div>
    }
}
```

### Switch Component

```rust
use lyx_ui_shadcn_switch::Switch;

#[component]
pub fn SwitchExamples() -> impl IntoView {
    let (notifications, set_notifications) = create_signal(true);
    let (auto_save, set_auto_save) = create_signal(false);
    let (public_profile, set_public_profile) = create_signal(false);

    view! {
        <div class="space-y-4">
            // Switch with label
            <div class="flex items-center justify-between">
                <div class="space-y-0.5">
                    <Label for="notifications">"Notifications"</Label>
                    <p class="text-sm text-muted-foreground">
                        "Receive push notifications"
                    </p>
                </div>
                <Switch
                    id="notifications"
                    checked=notifications
                    on_change=set_notifications
                />
            </div>

            // Switch list
            <div class="space-y-4">
                <div class="flex items-center justify-between">
                    <div>
                        <Label>"Auto-save"</Label>
                        <p class="text-xs text-muted-foreground">
                            "Save changes automatically"
                        </p>
                    </div>
                    <Switch
                        checked=auto_save
                        on_change=set_auto_save
                    />
                </div>

                <div class="flex items-center justify-between">
                    <div>
                        <Label>"Public profile"</Label>
                        <p class="text-xs text-muted-foreground">
                            "Make your profile visible to everyone"
                        </p>
                    </div>
                    <Switch
                        checked=public_profile
                        on_change=set_public_profile
                    />
                </div>
            </div>
        </div>
    }
}
```

## Form Validation Architecture

### Validation Schema

```rust
use std::collections::HashMap;

pub type ValidationResult = Result<(), String>;
pub type Validator = fn(&str) -> ValidationResult;

pub struct ValidationSchema {
    rules: HashMap<String, Vec<Validator>>,
}

impl ValidationSchema {
    pub fn new() -> Self {
        Self {
            rules: HashMap::new(),
        }
    }

    pub fn add_rule(mut self, field: &str, validator: Validator) -> Self {
        self.rules
            .entry(field.to_string())
            .or_insert_with(Vec::new)
            .push(validator);
        self
    }

    pub fn validate_field(&self, field: &str, value: &str) -> ValidationResult {
        if let Some(validators) = self.rules.get(field) {
            for validator in validators {
                validator(value)?;
            }
        }
        Ok(())
    }

    pub fn validate_form(&self, data: &HashMap<String, String>) -> HashMap<String, String> {
        let mut errors = HashMap::new();

        for (field, validators) in &self.rules {
            if let Some(value) = data.get(field) {
                for validator in validators {
                    if let Err(error) = validator(value) {
                        errors.insert(field.clone(), error);
                        break;
                    }
                }
            } else {
                errors.insert(field.clone(), "This field is required".to_string());
            }
        }

        errors
    }
}

// Common validators
pub fn required(value: &str) -> ValidationResult {
    if value.trim().is_empty() {
        Err("This field is required".to_string())
    } else {
        Ok(())
    }
}

pub fn min_length(min: usize) -> impl Fn(&str) -> ValidationResult {
    move |value: &str| {
        if value.len() < min {
            Err(format!("Must be at least {} characters", min))
        } else {
            Ok(())
        }
    }
}

pub fn email_format(value: &str) -> ValidationResult {
    if value.contains('@') && value.contains('.') {
        Ok(())
    } else {
        Err("Must be a valid email address".to_string())
    }
}

pub fn matches_pattern(pattern: &str) -> impl Fn(&str) -> ValidationResult + '_ {
    move |value: &str| {
        // Simple pattern matching - use regex crate for complex patterns
        if value.is_empty() {
            return Err("Value cannot be empty".to_string());
        }
        Ok(())
    }
}
```

### Form Component with Validation

```rust
#[component]
pub fn ValidatedForm() -> impl IntoView {
    // Form state
    let (name, set_name) = create_signal(String::new());
    let (email, set_email) = create_signal(String::new());
    let (password, set_password) = create_signal(String::new());

    // Validation state
    let (errors, set_errors) = create_signal(HashMap::new());
    let (touched, set_touched) = create_signal(HashSet::new());

    // Create validation schema
    let schema = ValidationSchema::new()
        .add_rule("name", required)
        .add_rule("name", min_length(2))
        .add_rule("email", required)
        .add_rule("email", email_format)
        .add_rule("password", required)
        .add_rule("password", min_length(8));

    // Validate a single field
    let validate_field = move |field: String, value: String| {
        if touched.get().contains(&field) {
            let mut new_errors = errors.get();
            match schema.validate_field(&field, &value) {
                Ok(_) => {
                    new_errors.remove(&field);
                }
                Err(error) => {
                    new_errors.insert(field, error);
                }
            }
            set_errors.set(new_errors);
        }
    };

    // Handle field blur
    let handle_blur = move |field: String| {
        set_touched.update(|t| t.insert(field));
    };

    // Handle submit
    let handle_submit = move |ev: SubmitEvent| {
        ev.prevent_default();

        let mut form_data = HashMap::new();
        form_data.insert("name".to_string(), name.get());
        form_data.insert("email".to_string(), email.get());
        form_data.insert("password".to_string(), password.get());

        let validation_errors = schema.validate_form(&form_data);

        if validation_errors.is_empty() {
            // Submit form
            log!("Form submitted: {:?}", form_data);
        } else {
            set_errors.set(validation_errors);
        }
    };

    view! {
        <form on_submit=handle_submit class="space-y-4">
            // Name field
            <div class="space-y-2">
                <Label for="name">"Name"</Label>
                <Input
                    id="name"
                    value=name
                    on_change=move |ev| {
                        let value = event_target_value(&ev);
                        set_name.set(value.clone());
                        validate_field("name".to_string(), value);
                    }
                    on_focus_out=move |_| handle_blur("name".to_string())
                    class=move || errors.get().get("name").is_some().then_some("border-destructive")
                />
                {move || {
                    errors.get().get("name").map(|error| {
                        view! {
                            <p class="text-sm text-destructive">{error.clone()}</p>
                        }
                    })
                }}
            </div>

            // Email field
            <div class="space-y-2">
                <Label for="email">"Email"</Label>
                <Input
                    id="email"
                    type="email"
                    value=email
                    on_change=move |ev| {
                        let value = event_target_value(&ev);
                        set_email.set(value.clone());
                        validate_field("email".to_string(), value);
                    }
                    on_focus_out=move |_| handle_blur("email".to_string())
                />
                {move || {
                    errors.get().get("email").map(|error| {
                        view! {
                            <p class="text-sm text-destructive">{error.clone()}</p>
                        }
                    })
                }}
            </div>

            // Password field
            <div class="space-y-2">
                <Label for="password">"Password"</Label>
                <Input
                    id="password"
                    type="password"
                    value=password
                    on_change=move |ev| {
                        let value = event_target_value(&ev);
                        set_password.set(value.clone());
                        validate_field("password".to_string(), value);
                    }
                    on_focus_out=move |_| handle_blur("password".to_string())
                />
                {move || {
                    errors.get().get("password").map(|error| {
                        view! {
                            <p class="text-sm text-destructive">{error.clone()}</p>
                        }
                    })
                }}
            </div>

            <Button type="submit" class="w-full">
                "Submit"
            </Button>
        </form>
    }
}
```

## Complete Example: Multi-Step Registration Form

```rust
#[derive(Clone, Copy, PartialEq)]
pub enum FormStep {
    Account,
    Profile,
    Preferences,
    Review,
}

#[component]
pub fn MultiStepForm() -> impl IntoView {
    let (current_step, set_current_step) = create_signal(FormStep::Account);
    let (is_submitting, set_is_submitting) = create_signal(false);

    // Form data
    let form_data = create_rw_signal(RegistrationData {
        email: String::new(),
        password: String::new(),
        name: String::new(),
        bio: String::new(),
        notifications: true,
        newsletter: false,
    });

    // Step validation
    let can_proceed = create_memo(move |_| {
        match current_step.get() {
            FormStep::Account => {
                let data = form_data.get();
                !data.email.is_empty() && data.password.len() >= 8
            }
            FormStep::Profile => {
                let data = form_data.get();
                !data.name.is_empty()
            }
            _ => true,
        }
    });

    let handle_next = move |_| {
        if can_proceed.get() {
            match current_step.get() {
                FormStep::Account => set_current_step(FormStep::Profile),
                FormStep::Profile => set_current_step(FormStep::Preferences),
                FormStep::Preferences => set_current_step(FormStep::Review),
                FormStep::Review => {
                    set_is_submitting.set(true);
                    // Submit to API
                }
            }
        }
    };

    let handle_back = move |_| {
        match current_step.get() {
            FormStep::Profile => set_current_step(FormStep::Account),
            FormStep::Preferences => set_current_step(FormStep::Profile),
            FormStep::Review => set_current_step(FormStep::Preferences),
            _ => {}
        }
    };

    view! {
        <Card class="w-full max-w-2xl mx-auto p-8">
            // Progress indicator
            <div class="mb-8">
                <div class="flex justify-between mb-4">
                    {["Account", "Profile", "Preferences", "Review"]
                        .iter()
                        .enumerate()
                        .map(|(i, label)| {
                            let step_num = i + 1;
                            let is_active = match current_step.get() {
                                FormStep::Account => i == 0,
                                FormStep::Profile => i == 1,
                                FormStep::Preferences => i == 2,
                                FormStep::Review => i == 3,
                            };
                            view! {
                                <div class=format!("flex items-center {}", if i > 0 { "ml-4" } else { "" })>
                                    <div class=format!(
                                        "flex items-center justify-center w-10 h-10 rounded-full {} {}",
                                        if is_active { "bg-primary text-primary-foreground" } else { "bg-muted" },
                                        "transition-colors"
                                    )>
                                        {step_num}
                                    </div>
                                    <span class="ml-2 font-medium">{label}</span>
                                </div>
                            }
                        })
                        .collect_view()}
                </div>
                <div class="h-2 bg-muted rounded-full overflow-hidden">
                    <div
                        class="h-full bg-primary transition-all"
                        style=move || format!("width: {}%", match current_step.get() {
                            FormStep::Account => "25",
                            FormStep::Profile => "50",
                            FormStep::Preferences => "75",
                            FormStep::Review => "100",
                        })
                    ></div>
                </div>
            </div>

            // Step content
            <div class="min-h-[300px]">
                {move || match current_step.get() {
                    FormStep::Account => view! { <AccountStep data=form_data/> }.into_any(),
                    FormStep::Profile => view! { <ProfileStep data=form_data/> }.into_any(),
                    FormStep::Preferences => view! { <PreferencesStep data=form_data/> }.into_any(),
                    FormStep::Review => view! { <ReviewStep data=form_data/> }.into_any(),
                }}
            </div>

            // Navigation buttons
            <div class="flex justify-between mt-8">
                <Button
                    variant="outline"
                    on_click=handle_back
                    disabled=move || current_step.get() == FormStep::Account
                >
                    "Back"
                </Button>
                <Button
                    on_click=handle_next
                    disabled=move || !can_proceed.get()
                >
                    {move || match current_step.get() {
                        FormStep::Review => "Submit".to_string(),
                        _ => "Next".to_string(),
                    }}
                </Button>
            </div>
        </Card>
    }
}

#[derive(Clone, Debug)]
pub struct RegistrationData {
    email: String,
    password: String,
    name: String,
    bio: String,
    notifications: bool,
    newsletter: bool,
}

#[component]
fn AccountStep(data: RwSignal<RegistrationData>) -> impl IntoView {
    view! {
        <div class="space-y-4">
            <h2 class="text-2xl font-bold">"Create Account"</h2>
            <div class="space-y-2">
                <Label for="email">"Email"</Label>
                <Input
                    id="email"
                    type="email"
                    value=move || data.get().email.clone()
                    on_change=move |ev| {
                        data.update(|d| d.email = event_target_value(&ev));
                    }
                />
            </div>
            <div class="space-y-2">
                <Label for="password">"Password"</Label>
                <Input
                    id="password"
                    type="password"
                    value=move || data.get().password.clone()
                    on_change=move |ev| {
                        data.update(|d| d.password = event_target_value(&ev));
                    }
                />
                <p class="text-sm text-muted-foreground">
                    "Must be at least 8 characters"
                </p>
            </div>
        </div>
    }
}
```

## Exercise

1. Create a form with all component types (input, textarea, select, checkbox, radio, switch)
2. Implement a reusable validation system
3. Add form state persistence to localStorage
4. Create a custom form component that composes multiple inputs
5. Add accessibility features (ARIA labels, keyboard navigation)

## What's Next?

- [Layout Components](02-layout-components.md) - Cards, tabs, and accordions
- [Advanced Form Patterns](../../advanced/02-form-validation.md) - Complex validation scenarios
- [Form Component API](../../components/forms.md) - Complete component reference

---

**Previous**: [Getting Started](../getting-started/04-styling-theming.md) | **Next**: [Layout Components](02-layout-components.md)
