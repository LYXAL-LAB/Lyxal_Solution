# Feuille de route — `lyxal-server`

Évolutions prévues de l'hôte de processus. L'état actuel (démarrage, modules embarqués,
configuration, routes système, erreurs `SERVER_*`, image) est décrit dans le
[`README.md`](README.md). L'hôte ne contient aucune logique métier (`.agents/AGENTS.md` §5.8.5).
Aucune étape ne démarre sans ordre du CTO et `implementation_plan.md` validé
(`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Authentification des clients | `lyxal_auth` |
| 2 | API des modules | étape 1 |
| 3 | Hébergement des crates du noyau à venir | `lyxal_i18n`, `lyxal_storage`, `lyxal_secrets`, `lyxal_scheduler`, `lyxal_notification` |

---

## 1. Authentification des clients

Les routes actuelles sont des routes système sans identité. Aucun client authentifié n'appelle
le serveur.

Critères d'acceptation :

- [ ] identité du client établie par `lyxal_auth` et transmise à SurrealDB (session ou jeton),
      sans logique d'authentification dans l'hôte ;
- [ ] requête non authentifiée refusée par une erreur `SERVER_*` au contrat `LyxalResult` ;
- [ ] tests : identité valide, absente, expirée.

## 2. API des modules

La console et les clients appellent les fonctions publiques `fn::<module>_*` des modules hébergés.

Critères d'acceptation :

- [ ] exposition des fonctions publiques sous l'identité du client, les permissions SurrealQL
      restant seules juges ;
- [ ] réponse au contrat `{ ok, data, error }`, sans détail interne ;
- [ ] tests : appel autorisé, refusé par les permissions, fonction inconnue.

## 3. Hébergement des crates du noyau à venir

Chaque crate du noyau technique créé est embarqué par `build.rs` et, s'il a du code Rust, déclaré
dans `src/modules/` (workers, sondes, consommateurs d'événements).

Critères d'acceptation :

- [ ] module inscrit dans `MODULES` dans l'ordre des dépendances ;
- [ ] installation et rejeu vérifiés par les tests de l'hôte ;
- [ ] `README.md` §2 à jour.
