--
-- Données de référence pour les permissions de base
-- Permissions système nécessaires au fonctionnement des routes
--

-- Permissions d'accès générales
CREATE route_permissions:guest SET
    code = "guest",
    name_i18n = "permission.guest.name",
    description_i18n = "permission.guest.description",
    category = "access",
    is_system = true;

CREATE route_permissions:authenticated SET
    code = "authenticated",
    name_i18n = "permission.authenticated.name",
    description_i18n = "permission.authenticated.description",
    category = "access",
    is_system = true;

-- Permissions administratives
CREATE route_permissions:admin SET
    code = "admin",
    name_i18n = "permission.admin.name",
    description_i18n = "permission.admin.description",
    category = "administration",
    is_system = true;

CREATE route_permissions:manager SET
    code = "manager",
    name_i18n = "permission.manager.name",
    description_i18n = "permission.manager.description",
    category = "administration",
    is_system = true;
