# 📜 ADR-003: Architecture du Module Users & Settings

## 1. Contexte & Décision
Dans l'architecture historique `calrs-main`, la gestion du profil utilisateur et des paramètres était disséminée entre du code HTML MiniJinja, des routes Axum directes (`/dashboard/settings`, `/dashboard/settings/timezone`, `/dashboard/settings/avatar`), et des requêtes SQL SQLite embarquées.

Conformément à la Charte Lyxal OS, nous formalisons le module **Users & Settings** en tant que composant d'infrastructure centralisé (Niveau 2 d'Architecture) avec :
1. Fonctions SurrealQL universelles recevant `$params: object` unique et retournant `fn::result_ok(...)`.
2. Encapsulation 1-ligne Rust `store.call_fn(...)` neutre.
3. Exposition API REST v1 canonisée sous `/api/v1/users/me` et `/api/v1/settings`.
4. Isolation de la distribution binaire sous `/avatar/{user_id}`.

## 2. Conséquences
- **Parité Totalement Garantie** : Le nom, l'email d'envoi et de réservation (`booking_email`) et le fuseau horaire sont conservés sans aucune perte.
- **Sécurité Renforcée** : `auth.user_id` est extrait exclusivement du middleware d'authentification JWT/Session, interdisant toute modification non autorisée sur un profil tiers.
- **Statut de Clôture** : **`v1.0.0 CLOSED`**.
