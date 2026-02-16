# Tutorial 1: Installation & Setup

**Video Length**: ~12 minutes | **Difficulty**: Beginner | **Series**: Getting Started

## Overview

This tutorial walks you through setting up a new Leptos project with shadcn-ui components from scratch. You'll learn how to install the necessary tools, initialize a project, and configure your development environment.

## What You'll Learn

- Installing Rust and Trunk toolchain
- Creating a new Leptos project
- Adding shadcn-ui components to your project
- Verifying your setup with a test component
- Understanding the project structure

## Prerequisites

No prior Leptos experience required. You should have:
- Basic familiarity with command line tools
- A code editor (VS Code recommended)
- Administrative access to install packages

## Video Outline

**[0:00]** Introduction to leptos-shadcn-ui
**[0:45]** Installing Rust and Cargo
**[2:30]** Installing Trunk (the Leptos build tool)
**[4:00]** Creating a new Leptos project
**[6:00]** Adding shadcn-ui component packages
**[8:30]** Configuring styles and themes
**[10:00]** Running the development server
**[11:00]** Verifying the setup

## Step-by-Step Guide

### Step 1: Install Rust and Cargo

First, install Rust using rustup:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

This will install:
- `rustc` - the Rust compiler
- `cargo` - the Rust package manager
- `rustup` - the Rust toolchain manager

Verify your installation:

```bash
rustc --version
cargo --version
```

Expected output: `rustc 1.70.0` or higher

### Step 2: Install Trunk

Trunk is the build tool for Leptos applications. Install it with:

```bash
cargo install trunk
```

Install additional WASM dependencies:

```bash
# Linux
sudo apt install binaryen

# macOS
brew install binaryen

# Windows (PowerShell)
winget install Binaryen

# Verify installation
wasm-opt --version
```

### Step 3: Create a New Leptos Project

Use cargo-leptos to scaffold a new project:

```bash
cargo install cargo-leptos

# Create a new project
cargo leptos new my-shadcn-app
cd my-shadcn-app
```

Project structure:
```
my-shadcn-app/
├── Cargo.toml
├── index.html
├── src/
│   ├── app.rs
│   └── main.rs
└── style/
    └── main.css
```

### Step 4: Add shadcn-ui Components

Add the base components to your `Cargo.toml`:

```toml
[dependencies]
leptos = { version = "0.6", features = ["csr"] }
leptos-shadcn-components = "0.9"
```

Add commonly used components:

```bash
# Add specific components you need
cargo add leptos-shadcn-button
cargo add leptos-shadcn-input
cargo add leptos-shadcn-card
```

### Step 5: Configure Styles

Add Tailwind CSS configuration to your `style/main.css`:

```css
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;
    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;
    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;
    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
```

### Step 6: Create Your First Component

Update `src/app.rs`:

```rust
use leptos::*;
use lyx_ui_shadcn_button::Button;

#[component]
pub fn App() -> impl IntoView {
    view! {
        <div class="container mx-auto p-8">
            <h1 class="text-3xl font-bold mb-4">"Welcome to leptos-shadcn-ui!"</h1>
            <p class="text-muted-foreground mb-6">
                "Your first component is ready!"
            </p>
            <Button variant="default">
                "Get Started"
            </Button>
        </div>
    }
}
```

### Step 7: Run the Development Server

Start the development server:

```bash
trunk serve --open
```

Your application will open at `http://localhost:8080`

## Common Issues & Solutions

### Issue: `trunk: command not found`
**Solution**: Make sure Cargo bin directory is in your PATH:
```bash
export PATH="$HOME/.cargo/bin:$PATH"
```

### Issue: WASM compilation errors
**Solution**: Install the wasm32 target:
```bash
rustup target add wasm32-unknown-unknown
```

### Issue: Styles not applying
**Solution**: Ensure your `index.html` includes the CSS link:
```html
<link rel="stylesheet" href="/style/main.css">
```

## What's Next?

Now that you have your environment set up, continue to:

- [Tutorial 2: Your First Component](02-first-component.md) - Build interactive components
- [Component Documentation](../../components/README.md) - Explore available components
- [Examples](../../../examples/README.md) - View working examples

## Exercise

1. Create a new Leptos project from scratch
2. Add at least 3 shadcn-ui components
3. Customize the color scheme in your CSS
4. Deploy your app and share the URL

## Transcript

[Full video transcript will be added here with timestamps for easy navigation]

## Related Resources

- [Leptos Documentation](https://leptos.dev/)
- [Trunk Documentation](https://trunkrs.dev/)
- [Installation Guide](../../getting-started/installation.md)
- [Project Setup Checklist](../../getting-started/checklist.md)

---

**Previous**: [Tutorials Overview](../../README.md) | **Next**: [Your First Component](02-first-component.md)
