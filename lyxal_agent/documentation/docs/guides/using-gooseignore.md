---
title: Prevent lyxal from Accessing Files
sidebar_label: Using lyxalignore
sidebar_position: 80
---


`.lyxalignore` is a text file that defines patterns for files and directories that lyxal will not access. This means lyxal cannot read, modify, delete, or run shell commands on these files when using the Developer extension's tools.

:::info Developer extension only
The .lyxalignore feature currently only affects tools in the [Developer](/docs/mcp/developer-mcp) extension. Other extensions are not restricted by these rules.
:::

This guide will show you how to use `.lyxalignore` files to prevent lyxal from changing specific files and directories.

## Creating your `.lyxalignore` file

lyxal supports two types of `.lyxalignore` files:
- **Global ignore file** - Create a `.lyxalignore` file in `~/.config/lyxal`. These restrictions will apply to all your sessions with lyxal, regardless of directory.
- **Local ignore file** - Create a `.lyxalignore` file at the root of the directory you'd like it applied to. These restrictions will only apply when working in a specific directory.

:::tip
You can use both global and local `.lyxalignore` files simultaneously. When both exist, lyxal will apply patterns from both files, with local patterns able to override global ones using negation.
:::

## Example `.lyxalignore` file

In your `.lyxalignore` file, you can write patterns to match files you want lyxal to ignore. Here are some common patterns:

```plaintext
# Ignore specific files by name
settings.json         # Ignore only the file named "settings.json"

# Ignore files by extension
*.pdf                # Ignore all PDF files
*.config             # Ignore all files ending in .config

# Ignore directories and their contents
backup/              # Ignore everything in the "backup" directory
downloads/           # Ignore everything in the "downloads" directory

# Ignore all files with this name in any directory
**/credentials.json  # Ignore all files named "credentials.json" in any directory
```

## Negation Patterns

Use the `!` prefix to exclude files from ignore rules. This allows you to ignore broad patterns while allowing specific exceptions.

Within each `.lyxalignore` file, patterns are processed in order from top to bottom, so later patterns can override earlier ones. Negation patterns also work across files - you can use negation in your local `.lyxalignore` to allow access to files blocked by your global `.lyxalignore`.

```plaintext
# Ignore all environment files
**/.env*

# But allow the example file
!.env.example

# Ignore all log files
*.log

# But allow error logs
!error.log

# Ignore all JSON files in the config directory
config/*.json

# But allow the template
!config/template.json
```

:::tip Pattern Order Matters
Negation patterns must come after the patterns they're negating. The `!` pattern re-includes files that were previously ignored.
:::

## Ignore File Types and Priority

lyxal respects ignore rules from global and local `.lyxalignore` files, using a priority system where later patterns can override earlier ones.

### When You Have Ignore Files

When `.lyxalignore` files exist, patterns are applied in this order:

1. **Global `.lyxalignore`** (applied first)
   - Located at `~/.config/lyxal/.lyxalignore`
   - Affects all projects on your machine

2. **Local `.lyxalignore`** (applied second, can override global)
   - Located in the current working directory (the root of the directory you want these rules applied to)
   - Project-specific rules that can override global patterns

```
~/.config/lyxal/
└── .lyxalignore      ← Global patterns applied first

Project/
├── .lyxalignore      ← Local patterns applied second (can override global)
└── src/
```

Because patterns are processed in order, you can use negation patterns in your local `.lyxalignore` to allow access to files that were blocked by global patterns.

**Example: Override global restrictions in a specific project**

```plaintext
# In ~/.config/lyxal/.lyxalignore (global)
**/.env*              # Block all .env files everywhere

# In your-project/.lyxalignore (local)
!.env.example         # Allow .env.example in this project only
```

In this example, `.env` and `.env.local` remain blocked, but `.env.example` is accessible in this specific project.

### Default Patterns (No Ignore Files)

If you haven't created any `.lyxalignore` files (neither global nor local), lyxal automatically protects these sensitive files:

```plaintext
**/.env
**/.env.*
**/secrets.*
```

:::info
These default patterns are only active when **no** `.lyxalignore` files exist. Once you create either a global or local `.lyxalignore` file, you'll need to add these patterns yourself if you want to keep them.
:::

## Common use cases

Here are some typical scenarios where `.lyxalignore` is helpful:

- **Generated Files**: Prevent lyxal from modifying auto-generated code or build outputs
- **Third-Party Code**: Keep lyxal from changing external libraries or dependencies
- **Important Configurations**: Protect critical configuration files from accidental modifications
- **Version Control**: Prevent changes to version control files like `.git` directory
- **Custom Restrictions**: Create `.lyxalignore` files to define which files lyxal should not access 
