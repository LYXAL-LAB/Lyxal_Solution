# Feuille de route — `lyxal_i18n`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md), les sources et les
décisions de conception par [`MODELE_SOURCES.md`](MODELE_SOURCES.md). Aucune évolution ne démarre
sans ordre du CTO et `implementation_plan.md` validé (`.agents/AGENTS.md` §3).

| Évolution | Touche |
| :--- | :--- |
| Clés propres à une organisation : une organisation traduit les e-mails de ses propres parcours `lyxal_notification` | `lyxal_i18n`, `lyxal_notification` |
| Traduction des contenus métiers (libellés du catalogue et de l'ingestion) | modules métiers |
| Éléments en ligne de XLIFF, formats PO et Fluent, import et export depuis la console | `lyxal_i18n`, console |
| Glossaire et mémoire de traduction | `lyxal_i18n` |
| Suppression d'un espace de noms vide | `lyxal_i18n` |
| Passage à MessageFormat 2 quand un formateur Rust sera mûr | `lyxal_i18n` |

Montée de version de CLDR : relancer `scripts/i18n/generate_locales.py` (version fixée dans le
script) ; les langues existantes ne sont pas modifiées par le seed rejoué.
