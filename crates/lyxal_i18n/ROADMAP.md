# Feuille de route — `lyxal_i18n`

Évolutions à venir. L'état actuel est décrit par le [`README.md`](README.md) ; le programme, ses
décisions (Q1 à Q7) et le détail des lots dans `implementation_plan.md` à la racine. Chaque lot
a son propre plan détaillé, validé par le CTO avant toute ligne de code (`.agents/AGENTS.md` §3).

| Lot | Contenu | Touche |
| :- | :--- | :--- |
| 6 | Clôture : audit, documentation | docs |
| Plus tard | Clés propres à une organisation (une organisation traduit les e-mails de ses propres parcours `lyxal_notification`, décision N2 du lot 5) ; suppression d'un espace de noms vide ; éléments en ligne de XLIFF, formats PO et Fluent, import et export depuis la console ; traduction des contenus métiers (libellés du catalogue et de l'ingestion, décision Q7) ; glossaire et mémoire de traduction ; passage à MessageFormat 2 quand un formateur Rust sera mûr | modules métiers |

Montée de version de CLDR : relancer `scripts/i18n/generate_locales.py` (version fixée dans le
script) ; les langues existantes ne sont pas modifiées par le seed rejoué.
