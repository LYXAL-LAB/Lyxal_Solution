# Tutorial 3: Basic Form Patterns

**Video Length**: ~20 minutes | **Difficulty**: Beginner | **Series**: Getting Started

## Overview

Learn how to build user-friendly forms with validation using leptos-shadcn-ui form components. We'll create a registration form that demonstrates common patterns like controlled inputs, validation feedback, and form submission.

## What You'll Learn

- Creating controlled form inputs with signals
- Building form layouts with proper structure
- Implementing client-side validation
- Displaying validation errors and success messages
- Handling form submission
- Using form components: Input, Label, Button, Checkbox, Select

## Prerequisites

- Completed [Tutorial 2: Your First Component](02-first-component.md)
- Understanding of signals and event handlers

## Video Outline

**[0:00]** Introduction to form patterns
**[1:30]** Form component overview
**[3:00]** Creating controlled inputs
**[5:30]** Building a form layout
**[8:00]** Adding validation rules
**[11:00]** Displaying error messages
**[13:30]** Handling form submission
**[16:00]** Form accessibility best practices
**[18:00]** Complete example walkthrough
**[19:30]** Summary and next steps

## Step-by-Step Guide

### Understanding Controlled Inputs

In Leptos, form inputs are "controlled" by signals:

```rust
use leptos::*;
use lyx_ui_shadcn_input::Input;
use lyx_ui_shadcn_label::Label;

#[component]
pub fn ControlledInput() -> impl IntoView {
    let (value, set_value) = create_signal(String::new());

    view! {
        <div class="space-y-2">
            <Label for="name">"Name:"</Label>
            <Input
                id="name"
                value=value
                on_change=move |ev| {
                    set_value.set(event_target_value(&ev));
                }
                placeholder="Enter your name"
            />
            <p class="text-sm text-muted-foreground">
                "You entered: " {value}
            </p>
        </div>
    }
}
```

### Building a Registration Form

Let's create a complete registration form:

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;
use lyx_ui_shadcn_input::Input;
use lyx_ui_shadcn_label::Label;
use lyx_ui_shadcn_card::Card;
use lyx_ui_shadcn_checkbox::Checkbox;

#[component]
pub fn RegistrationForm() -> impl IntoView {
    // Form state
    let (name, set_name) = create_signal(String::new());
    let (email, set_email) = create_signal(String::new());
    let (password, set_password) = create_signal(String::new());
    let (terms, set_terms) = create_signal(false);
    let (is_submitting, set_is_submitting) = create_signal(false);

    // Validation state
    let (errors, set_errors) = create_signal(Vec::new());
    let (success_message, set_success_message) = create_signal(Option::<String>::None);

    // Validate form
    let validate = move || {
        let mut new_errors = Vec::new();

        if name.get().trim().is_empty() {
            new_errors.push("Name is required".to_string());
        } else if name.get().len() < 2 {
            new_errors.push("Name must be at least 2 characters".to_string());
        }

        if email.get().trim().is_empty() {
            new_errors.push("Email is required".to_string());
        } else if !email.get().contains('@') {
            new_errors.push("Email must be valid".to_string());
        }

        if password.get().len() < 8 {
            new_errors.push("Password must be at least 8 characters".to_string());
        }

        if !terms.get() {
            new_errors.push("You must accept the terms".to_string());
        }

        set_errors.set(new_errors);
        new_errors.is_empty()
    };

    // Handle submission
    let on_submit = move |ev: leptos::ev::SubmitEvent| {
        ev.prevent_default();

        if !validate() {
            return;
        }

        set_is_submitting.set(true);

        // Simulate API call
        set_timeout(
            move || {
                set_is_submitting.set(false);
                set_success_message.set(Some(
                    "Registration successful! Check your email.".to_string()
                ));
            },
            std::time::Duration::from_secs(1),
        );
    };

    view! {
        <Card class="w-full max-w-md mx-auto p-6">
            <div class="space-y-6">
                <div>
                    <h2 class="text-2xl font-bold">"Create Account"</h2>
                    <p class="text-sm text-muted-foreground">
                        "Enter your information to get started"
                    </p>
                </div>

                <form on_submit=on_submit class="space-y-4">
                    // Name field
                    <div class="space-y-2">
                        <Label for="name">"Name"</Label>
                        <Input
                            id="name"
                            value=name
                            on_change=move |ev| {
                                set_name.set(event_target_value(&ev));
                                set_success_message.set(None);
                            }
                            placeholder="John Doe"
                            required=true
                        />
                    </div>

                    // Email field
                    <div class="space-y-2">
                        <Label for="email">"Email"</Label>
                        <Input
                            id="email"
                            type="email"
                            value=email
                            on_change=move |ev| {
                                set_email.set(event_target_value(&ev));
                                set_success_message.set(None);
                            }
                            placeholder="john@example.com"
                            required=true
                        />
                    </div>

                    // Password field
                    <div class="space-y-2">
                        <Label for="password">"Password"</Label>
                        <Input
                            id="password"
                            type="password"
                            value=password
                            on_change=move |ev| {
                                set_password.set(event_target_value(&ev));
                                set_success_message.set(None);
                            }
                            placeholder="••••••••"
                            required=true
                        />
                        <p class="text-xs text-muted-foreground">
                            "Must be at least 8 characters"
                        </p>
                    </div>

                    // Terms checkbox
                    <div class="flex items-center space-x-2">
                        <Checkbox
                            id="terms"
                            checked=terms
                            on_change=move |checked| {
                                set_terms.set(checked);
                            }
                        />
                        <Label for="terms" class="text-sm font-normal">
                            "I accept the terms and conditions"
                        </Label>
                    </div>

                    // Error messages
                    {move || {
                        errors.get().is_empty().then_some(()).map(|_| view! {})
                    }}

                    <ul class="space-y-1">
                        {move || {
                            errors.get().into_iter().map(|error| {
                                view! {
                                    <li class="text-sm text-destructive">
                                        {error}
                                    </li>
                                }
                            }).collect_view()
                        }}
                    </ul>

                    // Success message
                    {move || {
                        success_message.get().map(|msg| {
                            view! {
                                <div class="p-3 text-sm text-green-700 bg-green-50 rounded-md border border-green-200">
                                    {msg}
                                </div>
                            }
                        })
                    }}

                    // Submit button
                    <Button
                        type="submit"
                        class="w-full"
                        disabled=is_submitting
                    >
                        {move || if is_submitting.get() {
                            "Creating account..."
                        } else {
                            "Create Account"
                        }}
                    </Button>
                </form>
            </div>
        </Card>
    }
}
```

### Creating Reusable Form Components

Extract common form patterns into reusable components:

```rust
#[component]
pub fn FormField(
    label: String,
    id: String,
    #[prop(default = String::new())]
    error: String,
    help_text: Option<String>,
    children: Children,
) -> impl IntoView {
    view! {
        <div class="space-y-2">
            <Label for=id.clone()>{label}</Label>
            {children()}
            {move || {
                help_text.as_ref().map(|text| {
                    view! {
                        <p class="text-xs text-muted-foreground">{text.clone()}</p>
                    }
                })
            }}
            {move || {
                (!error.is_empty()).then(|| {
                    view! {
                        <p class="text-sm text-destructive">{error.clone()}</p>
                    }
                })
            }}
        </div>
    }
}
```

Usage:

```rust
view! {
    <FormField
        label="Email".to_string()
        id="email".to_string()
        error=move || email_error.get().clone()
        help_text=Some("We'll never share your email.".to_string())
    >
        <Input
            id="email"
            type="email"
            value=email
            on_change=move |ev| set_email.set(event_target_value(&ev))
        />
    </FormField>
}
```

### Form with Select Component

Add a select dropdown to your form:

```rust
use lyx_ui_shadcn_select::{Select, SelectContent, SelectItem, SelectTrigger, SelectValue};

#[component]
pub fn ProfileForm() -> impl IntoView {
    let (role, set_role) = create_signal("user".to_string());
    let (country, set_country) = create_signal(String::new());

    view! {
        <form class="space-y-4">
            // Role selection
            <div class="space-y-2">
                <Label for="role">"Role"</Label>
                <Select value=role on_change=set_role>
                    <SelectTrigger id="role">
                        <SelectValue placeholder="Select a role"/>
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="user">"User"</SelectItem>
                        <SelectItem value="admin">"Admin"</SelectItem>
                        <SelectItem value="moderator">"Moderator"</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            // Country selection
            <div class="space-y-2">
                <Label for="country">"Country"</Label>
                <Select value=country on_change=set_country>
                    <SelectTrigger id="country">
                        <SelectValue placeholder="Select your country"/>
                    </SelectTrigger>
                    <SelectContent>
                        <SelectItem value="us">"United States"</SelectItem>
                        <SelectItem value="uk">"United Kingdom"</SelectItem>
                        <SelectItem value="ca">"Canada"</SelectItem>
                        <SelectItem value="au">"Australia"</SelectItem>
                    </SelectContent>
                </Select>
            </div>

            <Button type="submit">"Save Profile"</Button>
        </form>
    }
}
```

### Real-time Validation with Debouncing

Add validation that runs as the user types:

```rust
use std::time::Duration;
use web_sys::HtmlInputElement;

#[component]
pub fn ValidatedInput() -> impl IntoView {
    let (value, set_value) = create_signal(String::new());
    let (error, set_error) = create_signal(Option::<String>::None);
    let (is_validating, set_is_validating) = create_signal(false);

    // Debounced validation
    let validate_value = move |val: String| {
        set_is_validating.set(true);

        set_timeout(
            move || {
                let error = if val.len() < 3 {
                    Some("Must be at least 3 characters".to_string())
                } else if !val.chars().all(|c| c.is_alphanumeric()) {
                    Some("Must be alphanumeric only".to_string())
                } else {
                    None
                };
                set_error.set(error);
                set_is_validating.set(false);
            },
            Duration::from_millis(300),
        );
    };

    view! {
        <div class="space-y-2">
            <Label for="username">"Username"</Label>
            <Input
                id="username"
                value=value
                on_change=move |ev| {
                    let new_value = event_target_value(&ev);
                    set_value.set(new_value.clone());
                    validate_value(new_value);
                }
            />
            <div class="flex items-center gap-2">
                {move || {
                    is_validating.get().then(|| {
                        view! {
                            <span class="text-sm text-muted-foreground">"Validating..."</span>
                        }
                    })
                }}
                {move || {
                    error.get().map(|err| {
                        view! {
                            <span class="text-sm text-destructive">{err}</span>
                        }
                    })
                }}
                {move || {
                    (value.get().len() >= 3 && error.get().is_none()).then(|| {
                        view! {
                            <span class="text-sm text-green-600">"✓ Available"</span>
                        }
                    })
                }}
            </div>
        </div>
    }
}
```

## Form Validation Patterns

### Pattern 1: Required Field Validation
```rust
let validate_required = move |value: String| {
    if value.trim().is_empty() {
        Err("This field is required".to_string())
    } else {
        Ok(())
    }
};
```

### Pattern 2: Email Validation
```rust
let validate_email = move |value: String| {
    if value.contains('@') && value.contains('.') {
        Ok(())
    } else {
        Err("Please enter a valid email".to_string())
    }
};
```

### Pattern 3: Length Validation
```rust
let validate_length = move |value: String, min: usize, max: usize| {
    if value.len() < min {
        Err(format!("Must be at least {} characters", min))
    } else if value.len() > max {
        Err(format!("Must be at most {} characters", max))
    } else {
        Ok(())
    }
};
```

### Pattern 4: Pattern Matching
```rust
let validate_pattern = move |value: String, pattern: &str| {
    let regex = regex::Regex::new(pattern).unwrap();
    if regex.is_match(&value) {
        Ok(())
    } else {
        Err("Invalid format".to_string())
    }
};
```

## Accessibility Best Practices

1. **Always associate labels with inputs** using `for` and `id` attributes
2. **Use appropriate input types** (`email`, `password`, `tel`, etc.)
3. **Provide error descriptions** with `aria-describedby`
4. **Mark required fields** with `required` attribute
5. **Use semantic HTML** (`<form>`, `<label>`, `<button>`)

## Complete Example: Login Form

```rust
#[component]
pub fn LoginForm() -> impl IntoView {
    let (email, set_email) = create_signal(String::new());
    let (password, set_password) = create_signal(String::new());
    let (remember, set_remember) = create_signal(false);
    let (errors, set_errors) = create_signal(Vec::new());
    let (show_success, set_show_success) = create_signal(false);

    let handle_login = move |ev: SubmitEvent| {
        ev.prevent_default();

        let mut validation_errors = Vec::new();

        if email.get().is_empty() {
            validation_errors.push("Email is required".to_string());
        }
        if password.get().is_empty() {
            validation_errors.push("Password is required".to_string());
        }

        if validation_errors.is_empty() {
            // Simulate login
            set_show_success(true);
            set_errors.set(Vec::new());
        } else {
            set_errors.set(validation_errors);
        }
    };

    view! {
        <Card class="w-full max-w-md mx-auto p-6">
            <div class="space-y-6">
                <div class="text-center">
                    <h2 class="text-2xl font-bold">"Welcome Back"</h2>
                    <p class="text-sm text-muted-foreground">
                        "Sign in to your account"
                    </p>
                </div>

                <form on_submit=handle_login class="space-y-4">
                    <div class="space-y-2">
                        <Label for="email">"Email"</Label>
                        <Input
                            id="email"
                            type="email"
                            value=email
                            on_change=move |ev| set_email.set(event_target_value(&ev))
                            placeholder="you@example.com"
                            required=true
                        />
                    </div>

                    <div class="space-y-2">
                        <Label for="password">"Password"</Label>
                        <Input
                            id="password"
                            type="password"
                            value=password
                            on_change=move |ev| set_password.set(event_target_value(&ev))
                            placeholder="••••••••"
                            required=true
                        />
                    </div>

                    <div class="flex items-center justify-between">
                        <div class="flex items-center space-x-2">
                            <Checkbox
                                id="remember"
                                checked=remember
                                on_change=set_remember
                            />
                            <Label for="remember" class="text-sm font-normal">
                                "Remember me"
                            </Label>
                        </div>
                        <a href="#" class="text-sm text-primary hover:underline">
                            "Forgot password?"
                        </a>
                    </div>

                    {move || {
                        (!errors.get().is_empty()).then(|| {
                            view! {
                                <div class="p-3 text-sm text-destructive bg-destructive/10 rounded-md">
                                    <ul class="list-disc list-inside space-y-1">
                                        {errors.get().into_iter().map(|error| {
                                            view! { <li>{error}</li> }
                                        }).collect_view()}
                                    </ul>
                                </div>
                            }
                        })
                    }}

                    {move || {
                        show_success.then(|| {
                            view! {
                                <div class="p-3 text-sm text-green-700 bg-green-50 rounded-md border border-green-200">
                                    "Login successful! Redirecting..."
                                </div>
                            }
                        })
                    }}

                    <Button type="submit" class="w-full">
                        "Sign In"
                    </Button>
                </form>

                <div class="text-center text-sm">
                    <span class="text-muted-foreground">"Don't have an account? "</span>
                    <a href="#" class="text-primary hover:underline">
                        "Sign up"
                    </a>
                </div>
            </div>
        </Card>
    }
}
```

## Exercise

1. Create a contact form with: name, email, subject (select), and message (textarea)
2. Add validation for all fields
3. Show inline validation messages as the user types
4. Add a character counter to the message field
5. Style the form to match your app's theme

## What's Next?

- [Tutorial 4: Styling & Theming](04-styling-theming.md) - Customize component appearance
- [Form Component Reference](../../components/form-components.md) - All form components
- [Advanced Form Patterns](../components/02-advanced-forms.md) - Complex form scenarios

---

**Previous**: [Your First Component](02-first-component.md) | **Next**: [Styling & Theming](04-styling-theming.md)
