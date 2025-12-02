--
-- Exemples de routes pour le système de routes dynamiques
-- Routes de démonstration pour tester le système
--

-- Route publique d'accueil
CREATE studio_route:home SET
    identity: {
        value: "/home",
        slug: "home",
        code: "home"
    },
    page: NONE,
    permissions: ["guest"],
    guards: [],
    metadata: {
        title_i18n: "page.home.title",
        description_i18n: "page.home.description",
        icon: "home",
        order: 1
    },
    status: "active";

-- Route du tableau de bord (nécessite authentification)
CREATE studio_route:dashboard SET
    identity: {
        value: "/dashboard",
        slug: "dashboard",
        code: "dashboard"
    },
    page: NONE,
    permissions: ["authenticated"],
    guards: [
        {
            type: "auth",
            condition: {}
        }
    ],
    metadata: {
        title_i18n: "page.dashboard.title",
        description_i18n: "page.dashboard.description",
        icon: "dashboard",
        order: 2,
        group: "main"
    },
    status: "active";

-- Route d'administration (nécessite admin)
CREATE studio_route:admin SET
    identity: {
        value: "/admin",
        slug: "admin",
        code: "admin"
    },
    page: NONE,
    permissions: ["admin"],
    guards: [
        {
            type: "auth",
            condition: {}
        },
        {
            type: "role",
            condition: {
                role: "admin"
            }
        }
    ],
    metadata: {
        title_i18n: "page.admin.title",
        description_i18n: "page.admin.description",
        icon: "settings",
        order: 100,
        group: "administration"
    },
    status: "active";

-- Route des paramètres utilisateur
CREATE studio_route:settings SET
    identity: {
        value: "/settings",
        slug: "settings",
        code: "settings"
    },
    page: NONE,
    permissions: ["authenticated"],
    guards: [
        {
            type: "auth",
            condition: {}
        }
    ],
    metadata: {
        title_i18n: "page.settings.title",
        description_i18n: "page.settings.description",
        icon: "settings",
        order: 50,
        group: "user"
    },
    status: "active";

-- Route de connexion (accès public)
CREATE studio_route:signin SET
    identity: {
        value: "/signin",
        slug: "signin",
        code: "signin"
    },
    page: NONE,
    permissions: ["guest"],
    guards: [],
    metadata: {
        title_i18n: "page.signin.title",
        description_i18n: "page.signin.description",
        icon: "login",
        order: 0,
        group: "auth"
    },
    status: "active";
