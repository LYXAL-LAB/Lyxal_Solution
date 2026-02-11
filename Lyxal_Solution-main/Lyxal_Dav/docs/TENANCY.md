# Modèle de Tenancy Lyxal_Dav (D9)

## Principe de Base
Le serveur Lyxal_Dav supporte le multi-tenancy par isolation logique basée sur le chemin d'accès (Path-based Tenancy).
Chaque tenant dispose de son propre espace de noms totalement isolé pour :
- Utilisateurs (Principals)
- Calendriers & Événements
- Carnets d'adresses & Contacts
- Fichiers WebDAV
- Verrous (Locks)

## Routing
Le tenant est le premier segment du chemin après la racine DAV.

Format : `/dav/{tenant}/{resource}...`

### Exemples
- Tenant `acme` :
  - Calendrier : `/dav/acme/calendars/alice/work/`
  - Contact : `/dav/acme/addressbooks/bob/personal/card.vcf`
  - Principal : `/dav/acme/principals/alice`
  
- Tenant `lyxal` :
  - Calendrier : `/dav/lyxal/calendars/admin/prod/`

## Isolation des Données
### Backend SQLite
L'isolation est garantie par :
1. **Partitionnement par Path** : Toutes les ressources (collections, objets) sont stockées avec leur chemin complet. Comme chaque chemin commence par `/dav/{tenant}/`, il n'y a pas de collision possible entre tenants.
2. **Table Principals** : Ajout d'une colonne `tenant`. Un utilisateur est identifié par le couple `(tenant, username)`.
3. **ACL & Auth** : L'authentification se fait toujours dans le contexte d'un tenant. `alice` sur `acme` est distinct de `alice` sur `lyxal`.

### Backend SurrealDB (D10 Preview)
L'isolation sera native via les Namespaces (`NS`) ou Databases (`DB`) de SurrealDB, ou par préfixe de path similaire à SQLite.

## Impacts Protocolaires
- **Auth** : Le client ne spécifie pas le tenant dans le login (Basic Auth standard `user:pass`). Le serveur déduit le tenant du chemin de la requête HTTP (`/dav/acme/...` -> tenant `acme`) avant de valider les credentials.
- **Sync** : Le `sync-token` est propre à une collection. Comme les collections sont isolées par chemin, les tokens le sont aussi.
- **Scheduling** : L'Inbox et l'Outbox sont situées sous `/dav/{tenant}/calendars/{user}/`, garantissant que les messages iTIP ne croisent pas les frontières des tenants.

## Migration D8 -> D9
Les données existantes (racine `/`) sont considérées comme appartenant au tenant par défaut (`default` ou vide), ou doivent être migrées vers `/dav/default/`.
La convention v1.0.0 utilisait des chemins comme `/calendars/user/`.
En v1.1.0 (D9), ces chemins deviennent `/dav/default/calendars/user/` (par exemple) ou le serveur supporte le mode "legacy" à la racine pour la rétrocompatibilité (configuré comme "single-tenant mode").

