-- =============================================================================================
-- |
-- | Fichier     : i18n_date_pattern_i18n_key_seeds.surql
-- | Module      : i18n
-- | Description : Peuple la table `i18n_key` avec les clés pour les formats de date.
-- |
-- =============================================================================================

CREATE i18n_key:'i18n.date_pattern.iso_short.name' SET description = "Nom pour le format de date ISO (yyyy-MM-dd)";
CREATE i18n_key:'i18n.date_pattern.eu_short.name' SET description = "Nom pour le format de date court européen (dd/MM/yyyy)";
CREATE i18n_key:'i18n.date_pattern.us_short.name' SET description = "Nom pour le format de date court américain (MM/dd/yyyy)";
CREATE i18n_key:'i18n.date_pattern.text_short.name' SET description = "Nom pour le format de date textuel court (d MMM yyyy)";
CREATE i18n_key:'i18n.date_pattern.text_medium.name' SET description = "Nom pour le format de date textuel moyen (MMMM d, yyyy)";
CREATE i18n_key:'i18n.date_pattern.text_long.name' SET description = "Nom pour le format de date textuel long (EEEE, MMMM d, yyyy)";
CREATE i18n_key:'i18n.date_pattern.iso_datetime.name' SET description = "Nom pour le format date et heure ISO (yyyy-MM-dd HH:mm:ss)";
CREATE i18n_key:'i18n.date_pattern.eu_datetime.name' SET description = "Nom pour le format date et heure européen (dd/MM/yyyy HH:mm)";
