# Lyxal OS — Point d'entrée des agents IA

Ce fichier racine est lu automatiquement par les agents qui suivent la convention
`AGENTS.md` (Codex, Cursor, etc.). Les règles complètes vivent dans le dossier `.agents/`,
qui est la **source unique** :

1. **À lire intégralement avant toute tâche** :
   - [`.agents/AGENTS.md`](.agents/AGENTS.md) — Charte d'architecture (§1 à §9)
   - [`.agents/rules/lyxal_standards_and_checklist.md`](.agents/rules/lyxal_standards_and_checklist.md) — Standards & Checklist obligatoire (§10 à §15)
2. **Constitution** : [`LYXAL_ARCHITECTURE.md`](LYXAL_ARCHITECTURE.md)
3. **Skills spécialisés** : [`.agents/skills/`](.agents/skills/) — `lyxal-audit`, `lyxal-new-module`,
   `lyxal-module-integration`, `lyxal-runtime-integration`, `lyxal-surrealdb`.

> Aucune modification de code applicatif sans `implementation_plan.md` validé explicitement
> par le CTO. Ne pas recopier les règles ici : modifier directement les fichiers de `.agents/`.
