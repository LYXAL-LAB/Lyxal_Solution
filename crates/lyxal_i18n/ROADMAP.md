# Feuille de route — `lyxal_i18n`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme, ses
décisions (Q1 à Q7) et le détail des lots dans `implementation_plan.md` à la racine. Chaque lot
a son propre plan détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| 4 | Import et export JSON MF1 et XLIFF 2 ; commande de l'hôte qui liste les messages invalides (`Formatter::check_message` sur tous les textes) | `lyxal_i18n`, `apps/lyxal-server` |
| 5 | Bascule de `lyxal_base` (libellés des unités) et de `lyxal_notification` (gabarits) vers les clés | `lyxal_base`, `lyxal_notification` |
| 6 | Clôture : audit, documentation | docs |
| Plus tard | Suppression d'un espace de noms vide ; traduction des contenus métiers (libellés du catalogue et de l'ingestion, décision Q7) ; glossaire et mémoire de traduction ; passage à MessageFormat 2 quand un formateur Rust sera mûr | modules métiers |

Montée de version de CLDR : relancer `scripts/i18n/generate_locales.py` (version fixée dans le
script) ; les langues existantes ne sont pas modifiées par le seed rejoué.
