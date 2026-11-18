# Plan d'implémentation — programme courrier, agendas et contacts, lot 0 : cadre

Premier lot du programme (`implementation_plan.md` à la racine, décisions P1 à P15 validées le
18 novembre 2026). Ce lot n'écrit **aucun code applicatif** : il pose le suivi des sources et des
licences, prépare les sources de travail, mesure SurrealDB à l'échelle d'une boîte aux lettres et
tranche la question du chiffrement des boîtes (étude Proton, P15). Aucune action avant la
validation du CTO (`.agents/AGENTS.md` §3).

## 1. Décisions du CTO

À valider par le CTO.

| N° | Question | Proposition |
| :- | :--- | :--- |
| **C1** | Dossiers créés | Cinq dossiers `crates/lyxal_mail_proto`, `lyxal_mail`, `lyxal_dav`, `lyxal_calendar`, `lyxal_contacts`, **sans code ni `Cargo.toml`** (comme `crates/lyxal_connect` aujourd'hui) : `README.md` (objet du crate, état « à créer »), `SOURCES.md` (tableau vide prêt : élément porté, projet, commit, licence, fichier d'origine), `ROADMAP.md` (lots du programme qui le concernent, tableau « Essais réels à faire »). Les trois études du 18 novembre sont versées en `RECHERCHE_SOURCES.md` : courrier et Proton dans `lyxal_mail`, agendas et contacts dans `lyxal_calendar`. Inscription des cinq crates « à créer » dans `AGENTS.md` §6 et `docs/14-roadmap/ROADMAP_NOYAU.md`. |
| **C2** | Sources figées | Commits de travail : Stalwart `3adead9` (v1.1.1), Mox `b32f0de`, RustiCal `0698bb6`, sabre/dav `be1d58d` ; bibliothèques : `mail-parser` 1.0.1, `mail-builder` 2.0.1, `mail-send` 0.7.0, `mail-auth` 0.15.1. Les sources **ne sont pas versées dans le dépôt** : un script `scripts/sources/fetch_sources.sh` les clone à ces commits dans un dossier local ignoré par Git (`.sources/`). |
| **C3** | Tri du code propriétaire de Stalwart | Script `scripts/sources/strip_sel.py`, lancé après le clone : supprime les fichiers sous `LicenseRef-SEL` seule et retire les extraits marqués SEL des fichiers à double licence, puis écrit un rapport (fichiers supprimés, extraits retirés, par crate). Le script de Stalwart `resources/scripts/ossify.py` est lu d'abord : s'il fait déjà ce tri, il sert de référence de contrôle. Un test du script vérifie qu'aucune mention `LicenseRef-SEL` ne reste dans la copie de travail. Seule cette copie triée sert aux lots suivants. |
| **C4** | Contrôle des licences des dépendances | Ajout de `cargo-deny` (contrôle des **licences** seulement) avec un `deny.toml` : liste des licences admises pour les crates existants (permissives), exceptions nommées pour les six éléments AGPL du programme. Lancé par `scripts/ci/ci_local.sh` et par la CI. Les alertes de sécurité des dépendances restent suivies comme aujourd'hui (elles ne sont pas ajoutées à ce contrôle dans ce lot). |
| **C5** | Mesures de SurrealDB 3.3.4 (décision P4) | Banc `scripts/bench/mailbox/` (SurrealQL et Python, hors workspace, non lancé en CI) : boîtes de 100 000 puis 1 000 000 de messages (métadonnées, drapeaux, dossiers, numéros de modification), en mémoire et sur disque. Mesures : page de 50 messages d'un dossier triée par date ; changements depuis un numéro de modification ; changement de drapeau ; compte des non-lus par dossier ; recherche sur l'expéditeur et le sujet ; débit d'insertion. **Seuils proposés** pour garder la voie B (modèle SurrealQL) : page et synchronisation en moins de 100 ms à 1 000 000 de messages, changement de drapeau en moins de 20 ms, insertion d'au moins 300 messages par seconde. Résultats et requêtes dans `crates/lyxal_mail/RECHERCHE_SOURCES.md`. Si un seuil n'est pas tenu : compte rendu au CTO avec les variantes essayées (index, découpage des tables) avant toute décision sur P4. |
| **C6** | Deux hôtes sur une même base (décision P3) | Essai : un second runtime installe et démarre un jeu de modules différent sur la base d'un premier (installation, baux, réconciliation, arrêt de l'un sans effet sur l'autre). Écrit comme test d'intégration de `lyxal_runtime` (le seul code de ce lot, dans un crate existant, sans source AGPL). Si l'essai échoue, le correctif du runtime fait l'objet de son propre plan avant le lot 3. |
| **C7** | Chiffrement des boîtes (étude Proton, P15) | **Niveau A dans le programme** : contenu des messages et des pièces jointes chiffré au repos avec des clés de la plateforme par organisation (modèle de `lyxal_secrets`), dès le lot 4 ; il demande une extension de `lyxal_crypto` (chiffrement de fichiers en flux : la primitive actuelle plafonne à 1 Mio), détaillée et validée avec le lot 2. **Niveau B en lot optionnel** après le lot 12 : chiffrement à la remise par la clé publique OpenPGP de l'utilisateur (le serveur ne peut plus relire le message ; les logiciels classiques déchiffrent), avec la bibliothèque `rpgp` (MIT / Apache, celle que Proton utilise) ; les lots 4 et 5 réservent dès maintenant le drapeau « chiffré » et l'ordre antivirus → anti-spam → filtres → index → chiffrement. **Niveau C hors programme** : le bout en bout complet de Proton exige nos propres logiciels clients et retire au serveur la recherche, les filtres et l'anti-spam sur le contenu ; il ferait l'objet d'un autre programme. Agendas et contacts : niveau A seulement (aucun logiciel CalDAV / CardDAV classique ne déchiffre). |
| **C8** | Ce que Proton apporte d'autre | Consigné en feuille de route, sans lot dans ce programme : liste des fonctions des logiciels de Proton à reprendre dans le futur webmail (conversations, libellés, envoi différé, annulation d'envoi, mise en attente, groupes de contacts) ; alias d'adresses à la SimpleLogin, à instruire avec le lot 13. |

## 2. Contenu du lot

| Élément | Fichiers |
| :--- | :--- |
| Dossiers des cinq crates (C1) | `crates/lyxal_{mail_proto,mail,dav,calendar,contacts}/{README,SOURCES,ROADMAP}.md`, `RECHERCHE_SOURCES.md` |
| Inscription (C1) | `.agents/AGENTS.md` §6, `docs/14-roadmap/ROADMAP_NOYAU.md`, `docs/14-roadmap/README.md` |
| Sources (C2, C3) | `scripts/sources/fetch_sources.sh`, `scripts/sources/strip_sel.py` et son test, `.gitignore` (`.sources/`) |
| Licences (C4) | `deny.toml`, `scripts/ci/ci_local.sh`, `.github/workflows/ci.yml` |
| Mesures (C5) | `scripts/bench/mailbox/` ; résultats dans `crates/lyxal_mail/RECHERCHE_SOURCES.md` |
| Deux hôtes (C6) | test d'intégration dans `crates/lyxal_runtime/tests/it/` |
| Chiffrement (C7, C8) | programme (`implementation_plan.md` racine) mis à jour : niveau A aux lots 2 et 4, lot optionnel B, §9 ; feuilles de route |

Aucune fonction SurrealQL, aucun `XxxParams`, aucun code d'erreur, aucune fonction du Core dans
ce lot.

## 3. Vérification

* Test du tri SEL (C3) ; `cargo deny check licenses` sans erreur (C4) ; test des deux hôtes (C6).
* Mesures (C5) rejouables par une commande documentée ; chiffres, machine et version notés.
* `scripts/ci/ci_local.sh` complet avant la demande de fusion.

## 4. Compte rendu attendu en fin de lot

Rapport du tri SEL par crate ; tableau des mesures face aux seuils et conclusion sur P4 ;
résultat de l'essai des deux hôtes et conclusion sur P3 ; licences trouvées dans l'arbre des
dépendances. Ce plan est supprimé une fois le lot fusionné.
