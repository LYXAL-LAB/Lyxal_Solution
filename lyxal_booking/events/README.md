# Événements & Triggers SurrealDB (`lyxal_booking/events`)

Ce dossier centralise la définition et la documentation de tous les **Events & Triggers natifs (`DEFINE EVENT ... ON TABLE ...`)** de l'architecture SurrealDB pour **Lyxal Booking**.

---

## 🎯 Pourquoi utiliser les Events / Triggers SurrealDB ?

Dans l'application originale `cal.rs` (basée sur SQLite), aucun trigger n'existait. Toute la cohérence (mise à jour des dates, nettoyages en cascade, synchronisation des membres) était gérée par du code applicatif Rust.

En basculant sur SurrealDB, nous utilisons les **Events réactifs natifs** pour garantir l'intégrité de la base de données :
- **Intégrité Automatique** : Même en cas de modification directe via **Surrealist** ou via une API REST, la base exécute les règles métier.
- **Réduction du Code Backend** : Élimine le besoin de code d'entretien/nettoyage manuel.
- **Transactions Réactives** : Exécution immédiate lors d'un `CREATE`, `UPDATE` ou `DELETE`.

---

## 📋 Catalogue des Events Natifs

| Fichier `.surql` | Table Cible | Type d'Événement | Description Synthétique |
| :--- | :--- | :--- | :--- |
| `events_account_updated_at.surql` | `booking_account` | `UPDATE` | Met à jour automatiquement le champ `updated_at` lors de toute modification de profil. |
| `events_team_on_delete.surql` | `booking_team` | `DELETE` | Nettoie en cascade les membres d'équipe, les liaisons de groupes et détache les types d'événements. |
| `events_team_group_sync.surql` | `team_group` | `CREATE` / `DELETE` | Synchronise automatiquement les membres de l'équipe lors de la liaison ou suppression d'un groupe OIDC. |
| `events_booking_cancellation.surql` | `booking` | `UPDATE` | Réinitialise les créneaux et ressources allouées en cas d'annulation de réservation. |

---

## 📄 Spécifications Détaillées des Triggers

### 1. `events_account_updated_at.surql`
```surrealql
-- Horodatage automatique de dernière mise à jour des comptes hôtes
DEFINE EVENT update_account_timestamp ON TABLE booking_account 
WHEN $before != $after THEN {
    UPDATE $after.id SET updated_at = time::now();
};
```

---

### 2. `events_team_on_delete.surql`
```surrealql
-- Nettoyage en cascade lors de la suppression d'une équipe
DEFINE EVENT on_team_deleted ON TABLE booking_team 
WHEN $event = "DELETE" THEN {
    -- 1. Supprime les associations membres de l'équipe
    DELETE booking_team_member WHERE team = $before.id;
    -- 2. Supprime les liaisons de groupes OIDC
    DELETE team_group WHERE team_id = $before.id;
    -- 3. Dissocie l'équipe des types d'événements sans les supprimer
    UPDATE booking_event_type SET team_id = NONE WHERE team_id = $before.id;
};
```

---

### 3. `events_team_group_sync.surql`
```surrealql
-- Synchronisation automatique des membres OIDC lors de l'ajout d'un groupe à une équipe
DEFINE EVENT on_team_group_created ON TABLE team_group 
WHEN $event = "CREATE" THEN {
    LET $gid = $value.group_id;
    LET $tid = $value.team_id;
    FOR $uid IN (SELECT VALUE user_id FROM user_group WHERE group_id = $gid) {
        LET $existing = SELECT VALUE id FROM booking_team_member WHERE team = $tid AND user = $uid;
        IF array::len($existing) == 0 {
            CREATE booking_team_member CONTENT {
                team: $tid,
                user: $uid,
                role: 'member',
                source: 'group',
                created_at: time::now()
            };
        };
    };
};

-- Suppression automatique des membres synchronisés par le groupe lors du déliage
DEFINE EVENT on_team_group_deleted ON TABLE team_group 
WHEN $event = "DELETE" THEN {
    LET $gid = $before.group_id;
    LET $tid = $before.team_id;
    LET $gusers = SELECT VALUE user_id FROM user_group WHERE group_id = $gid;
    DELETE booking_team_member WHERE team = $tid AND source = 'group' AND user IN $gusers;
};
```

---

### 4. `events_booking_cancellation.surql`
```surrealql
-- Libération automatique des ressources lors de l'annulation d'un rendez-vous
DEFINE EVENT on_booking_cancelled ON TABLE booking 
WHEN $before.status != 'cancelled' AND $after.status == 'cancelled' THEN {
    -- Supprime les allocations de ressources physiques (salles, matériels)
    DELETE booking_resource_allocation WHERE booking = $after.id;
};
```
