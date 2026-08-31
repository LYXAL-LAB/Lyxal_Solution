# Cross Platform Starter

## Requirements

You need to have Leptos (nightly), Tauri and Just on your machine.
If not already, you can refer to [PREREQUISITES.md](PREREQUISITES.md).

```bash
# Install just
cargo install just
```

## Run the project

```bash
# Install Tailwind CSS
pnpm install

# For Web
cargo leptos watch

# For desktop
cargo tauri dev

# For iOS
cargo tauri ios init
just run_ios

# For Android
cargo tauri android init
just run_android
```

## License

MIT License - see [LICENSE](LICENSE) for details.
