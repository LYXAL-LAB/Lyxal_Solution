--
-- Index principal des schémas de base de données
-- Exporte tous les schémas pour l'initialisation de la DB
--

-- Schémas existants (studio_page, studio_component, etc.)
-- Ces schémas sont déjà définis dans les autres dossiers

-- Nouveaux schémas pour les routes dynamiques
OPTION IMPORT file://./routes/studio_route.surql;
OPTION IMPORT file://./routes/route_permissions.surql;
OPTION IMPORT file://./routes/route_guards.surql;
