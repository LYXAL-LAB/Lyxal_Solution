# Feuille de route — `lyxal_contacts`

Évolutions à venir du crate (à créer). Son objet est décrit par le [`README.md`](README.md), la
provenance de ses sources par [`SOURCES.md`](SOURCES.md). Le programme est décrit par
`implementation_plan.md` à la racine du dépôt ; chaque lot a son propre plan, validé par le CTO
avant toute ligne de code (`.agents/AGENTS.md` §3).

## Lots du programme, dans l'ordre

| Lot | Contenu pour ce crate | Sources principales | Prérequis |
| :- | :--- | :--- | :--- |
| 19 — CardDAV | Création du module (`Cargo.toml` sous `AGPL-3.0-only`, exception nommée dans `deny.toml`) : carnets, contacts, recherche, synchronisation, partage ; chiffrement au repos (niveau A) | Stalwart `dav/card`, `groupware/contact` ; RustiCal `carddav` ; sabre/dav `CardDAV` | lot 15 |
| 20 — JMAP agendas et contacts | JSContact, méthodes JMAP | Stalwart `jmap` (contacts) | lots 12, 18, 19 |
| 21 — Durcissement et conformité | Suites de conformité, corrections | Tests de sabre/dav et de RustiCal transposés | lots 12, 20 |
| 22 — Essais réels et clôture | Essais ci-dessous, audit `lyxal-audit`, documents définitifs | — | lot 21, moyens P11 |

## Chiffrement (décision C7)

Contacts : **niveau A seulement** (chiffrement au repos avec les clés de la plateforme par
organisation). Aucun logiciel CardDAV classique ne sait déchiffrer une fiche : les niveaux B
et C ne s'appliquent pas aux contacts dans ce programme.

## Après le programme

Groupes de contacts dans le futur webmail (liste des fonctions à reprendre de Proton :
[`crates/lyxal_mail/ROADMAP.md`](../lyxal_mail/ROADMAP.md)) ; clé de chiffrement et préférences
par contact (champ `KEY`), utiles au niveau B du courrier ; lien avec un futur `lyxal_crm` ;
lecture de carnets externes : proposition `lyxal_connect`.

## Essais réels à faire

Les tests automatiques n'appellent aucun service réel. Les essais réels se font sur ordre du
CTO, avec les moyens qu'il fournit (décision P11) ; secrets rangés dans `lyxal_secrets`, jamais
dans le dépôt ni dans une conversation. Chaque lot ajoute ici ses essais ; un essai réussi est
retiré de la liste et noté dans le `README.md`.

Moyens à fournir par le CTO (décision P11) : un nom de domaine et la main sur son DNS
(enregistrements SRV de découverte), un hôte joignable en HTTPS, des appareils et logiciels
réels (iPhone, Mac, Android avec DAVx⁵, Thunderbird, Outlook).

| Lot | Préalable | Action | Résultat attendu |
| :- | :--- | :--- | :--- |
| 19 | Domaine, HTTPS, mot de passe d'application ; iPhone et Mac (Contacts), DAVx⁵, Thunderbird | Ajouter le compte ; créer, modifier, supprimer des contacts et des groupes sur chaque logiciel | Synchronisation juste dans les deux sens ; photos, champs multiples et propriétés propres à chaque logiciel gardés |
| 19 | Idem | Importer un carnet réel de plusieurs milliers de fiches en vCard 3 et 4 mêlées | Aucune fiche perdue ; recherche et complétion des adresses rapides |
| 19 | Deux comptes | Partager un carnet en lecture puis en écriture | Droits respectés sur chaque logiciel |
| 20 | Client JMAP | Lire et modifier un carnet par JMAP | Même état que par CardDAV |
