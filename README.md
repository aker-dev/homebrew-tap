# aker-dev/tap

Homebrew tap for [aker-dev](https://github.com/aker-dev) projects.

## Installation

Recent Homebrew versions will not load a third-party tap until it is trusted, so
`brew trust` comes first:

```bash
brew trust aker-dev/tap
brew install aker-dev/tap/microfolio
```

## Formulae

### microfolio

Modern static portfolio generator for creatives (designers, architects, photographers).

Requires Node.js 22.13 or later and pnpm 11 — both are installed as dependencies
(`node@22`, `pnpm`), along with `git`.

```bash
microfolio new my-portfolio     # Create a new portfolio
cd my-portfolio
microfolio dev                  # Development server (http://localhost:5555)
microfolio build                # Build for production (optimizes images first)
microfolio preview              # Preview the built site (http://localhost:2001)
microfolio optimize-images      # Regenerate WEBP thumbnails on their own
microfolio clean-images         # Remove WEBP thumbnails
microfolio help                 # Show all commands
```

The dev and preview ports are the intent, not a guarantee: a busy port sends Vite
to the next one, and it prints where it actually landed.

Full documentation: <https://github.com/aker-dev/microfolio>

## Maintenance

```bash
brew update
brew upgrade microfolio
brew uninstall microfolio
brew untap aker-dev/tap
```

## License

[MIT](LICENSE)
