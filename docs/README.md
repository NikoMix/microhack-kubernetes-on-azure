# `docs/` — Published curriculum site (Astro + Starlight)

The hybrid **published site** mirroring the curriculum, built with **Astro + Starlight**
(MIT) and deployed to GitHub Pages.

## Scope

- Landing + course overview + agenda.
- One page per module (M0–M6) summarising the lab, mapped to its Module B control.
- Trainer section (facilitation, scoring) and references (cheat sheets, primers).
- Diagrams via Mermaid; deep‑links into `challenges/`.

## Conventions

- Content in `src/content/docs/`; site config reads `ASTRO_SITE` env var.
- Build: `npm install && npm run build`; deployed by `.github/workflows`.
- Markdown/MDX passes lint + link‑check.

> Owned by workstream **WS3 (Curriculum)**.
