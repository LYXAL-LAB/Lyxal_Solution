--
-- Données de référence pour les guards de sécurité
-- Guards système nécessaires à la protection des routes
--

-- Guard d'authentification
CREATE route_guards:auth_guard SET
    code = "auth_guard",
    name_i18n = "guard.auth.name",
    description_i18n = "guard.auth.description",
    type = "auth",
    config_schema = {},
    is_system = true;

-- Guard de rôle
CREATE route_guards:role_guard SET
    code = "role_guard",
    name_i18n = "guard.role.name",
    description_i18n = "guard.role.description",
    type = "role",
    config_schema = {
        "role": {
            "type": "string",
            "required": true,
            "description": "Role required to access"
        },
        "require_all": {
            "type": "boolean",
            "default": false,
            "description": "Require all specified roles"
        }
    },
    is_system = true;

-- Guard d'abonnement
CREATE route_guards:subscription_guard SET
    code = "subscription_guard",
    name_i18n = "guard.subscription.name",
    description_i18n = "guard.subscription.description",
    type = "subscription",
    config_schema = {
        "plan": {
            "type": "string",
            "required": true,
            "description": "Required subscription plan"
        },
        "feature": {
            "type": "string",
            "description": "Specific feature required"
        }
    },
    is_system = true;

-- Guard de fonctionnalité
CREATE route_guards:feature_guard SET
    code = "feature_guard",
    name_i18n = "guard.feature.name",
    description_i18n = "guard.feature.description",
    type = "feature",
    config_schema = {
        "feature": {
            "type": "string",
            "required": true,
            "description": "Required feature flag"
        },
        "version": {
            "type": "string",
            "description": "Minimum version required"
        }
    },
    is_system = true;
