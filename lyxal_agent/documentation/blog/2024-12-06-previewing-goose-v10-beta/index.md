---
draft: false
title: "Previewing lyxal v1.0 Beta"
description: "lyxal v1.0 Beta is here! Learn about the latest features and improvements."
date: 2024-12-06
authors:
  - adewale
---

![lyxal v1.0 Beta](lyxal-v1.0-beta.png)
We are excited to share a preview of the new updates coming to lyxal with lyxal v1.0 Beta!

This major update comes with a bunch of new features and improvements that make lyxal more powerful and user-friendly. Here are some of the key highlights.

<!-- truncate -->


## Exciting Features of lyxal 1.0 Beta

### 1. Transition to Rust

The core of lyxal has been rewritten in Rust. Why does this matter? Rust allows for a more portable and stable experience. This change means that lyxal can run smoothly on different systems without the need for Python to be installed, making it easier for anyone to start using it.

### 2. Contextual Memory

lyxal will remember previous interactions to better understand ongoing projects. This means you won’t have to keep repeating yourself. Imagine having a conversation with someone who remembers every detail—this is the kind of support lyxal aims to offer.

### 3. Improved Plugin System

In lyxal v1.0, the lyxal toolkit system is being replaced with Extensions. Extensions are modular daemons that lyxal can interact with dynamically. As a result, lyxal will be able to support more complex plugins and integrations. This will make it easier to extend lyxal with new features and functionality.

### 4. Headless mode

You can now run lyxal in headless mode - this is useful for running lyxal on servers or in environments where a graphical interface is not available.

```sh
cargo run --bin lyxal -- run -i instructions.md
```

### 5. lyxal now has a GUI

lyxal now has an electron-based GUI macOS application that provides and alternative to the CLI to interact with lyxal and manage your projects.

![lyxal GUI](lyxal-gui.png)

### 6. lyxal alignment with open protocols

lyxal v1.0 Beta now uses a custom protocol, that is designed in parallel with [Anthropic’s Model Context Protocol](https://www.anthropic.com/news/model-context-protocol) (MCP) to communicate with Systems. This makes it possible for developers to create their own systems (e.g Jira, ) that Lyxal can integrate with. 

Excited for many more feature updates and improvements? Stay tuned for more updates on Lyxal! Check out the [lyxal repo](https://github.com/block/lyxal) and join our [Discord community](https://discord.gg/lyxal-oss).


<head>
  <meta property="og:title" content="Previewing Lyxal v1.0 Beta" />
  <meta property="og:type" content="article" />
  <meta property="og:url" content="https://block.github.io/lyxal/blog/2024/12/06/previewing-lyxal-v10-beta" />
  <meta property="og:description" content="AI Agent uses screenshots to assist in styling." />
  <meta property="og:image" content="https://block.github.io/lyxal/assets/images/lyxal-v1.0-beta-5d469fa73edea37cfccfe8a8ca0b47e2.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta property="twitter:domain" content="block.github.io/lyxal" />
  <meta name="twitter:title" content="Screenshot-Driven Development" />
  <meta name="twitter:description" content="AI Agent uses screenshots to assist in styling." />
  <meta name="twitter:image" content="https://block.github.io/lyxal/assets/images/lyxal-v1.0-beta-5d469fa73edea37cfccfe8a8ca0b47e2.png" />
</head>