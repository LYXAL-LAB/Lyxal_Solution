-- =============================================================================================
-- |
-- | Fichier     : i18n_time_pattern_i18n_key_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_key` avec les clés pour les formats d'heure.
-- |
-- =============================================================================================

CREATE i18n_key:'i18n.time_pattern.24h_short.name' SET description = "Nom pour le format d'heure 24h court (HH:mm)";
CREATE i18n_key:'i18n.time_pattern.24h_long.name' SET description = "Nom pour le format d'heure 24h long avec secondes (HH:mm:ss)";
CREATE i18n_key:'i18n.time_pattern.12h_short.name' SET description = "Nom pour le format d'heure 12h court (h:mm a)";
CREATE i18n_key:'i18n.time_pattern.12h_long.name' SET description = "Nom pour le format d'heure 12h long avec secondes (h:mm:ss a)";
