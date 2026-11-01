# Lyxal OS — Instructions chargées automatiquement (Claude Code)

Ce fichier est lu au démarrage de chaque session Claude Code. Il importe les règles
permanentes du dossier `.agents/`, qui reste la **source unique** : ne rien recopier ici,
modifier directement les fichiers de `.agents/`.

## Règles permanentes (toujours appliquées)

@.agents/AGENTS.md
@.agents/rules/lyxal_standards_and_checklist.md

## Constitution d'architecture

La constitution de référence est `LYXAL_ARCHITECTURE.md` (à lire quand une règle de
`.agents/AGENTS.md` y renvoie ou en cas de doute d'interprétation).

## Skills Lyxal

Les skills sont dans `.agents/skills/` et exposés à Claude Code via `.claude/skills/`
(liens symboliques). Les activer selon la tâche :

| Skill | Quand l'utiliser |
| :--- | :--- |
| `lyxal-audit` | Audit / revue de conformité d'un module |
| `lyxal-new-module` | Conception ou création d'un module, rédaction d'`implementation_plan.md` |
| `lyxal-module-integration` | Changement touchant plusieurs modules, dépendances, contrats publics |
| `lyxal-runtime-integration` | `LyxalModule`, workers, événements, baux, sondes de santé |
| `lyxal-surrealdb` | Écriture / revue de fichiers `.surql`, compatibilité SurrealDB 3.2.0 |

Si les liens de `.claude/skills/` ne sont pas disponibles (ex. Windows sans support des
liens symboliques Git), lire directement `.agents/skills/<nom>/SKILL.md`.

## Rappel du verrou CTO

Aucune modification de code applicatif sans `implementation_plan.md` validé explicitement
par le CTO (§3 de `.agents/AGENTS.md`). Les audits sont en lecture seule.
