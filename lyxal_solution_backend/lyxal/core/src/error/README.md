# lyxal_core_error

## Rôle
Crate centralisant **toutes les définitions d'erreurs** de la plateforme Lyxal Solution. En isolant les erreurs dans un crate dédié, on évite les dépendances circulaires entre `lyxal_db`, `lyxal_core_kvs`, `lyxal_proxy` et les autres composants.

## Ce qu'il contient
- **`mod.rs`** : L'enum `Error` (~100 variantes) couvrant tous les cas d'erreur possibles : erreurs SQL, erreurs de parsing, erreurs de permissions IAM, erreurs KVS, erreurs d'index, erreurs HTTP, erreurs de validation de schéma, etc.
- **`to_types.rs`** : Les conversions d'erreurs internes vers les types publics (`lyxal-types`).

## Architecture
L'enum `Error` utilise `#[derive(thiserror::Error)]` pour générer automatiquement les implémentations `Display` et `From`. Les erreurs sont catégorisées par domaine :
- **SQL** : `InvalidQuery`, `InvalidContent`, `InvalidMerge`, `InvalidPatch`
- **Permissions** : `NsNotAllowed`, `DbNotAllowed`, `ParamPermissions`, `FunctionPermissions`
- **Données** : `RecordExists`, `IndexExists`, `FieldValue`, `IdInvalid`
- **Système** : `Io`, `Http`, `Channel`, `Unreachable`
- **Authentification** : `InvalidAuth`, `InvalidPass`, `TokenMakingFailed`

## Dépendances clés
- `thiserror` : Génération automatique des traits d'erreur.
- `serde` : Sérialisation des erreurs pour les réponses API.

## Utilisé par
Tous les crates de la solution : `lyxal_db`, `lyxal_core_kvs`, `lyxal_server`, `lyxal_functions`, `lyxal_api`.
