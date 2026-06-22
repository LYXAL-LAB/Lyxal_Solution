-- Seed data for bridge_operations_methods
-- Inclut Standard HTTP, WebDAV et méthodes spécifiques

CREATE bridge_operations_methods:get CONTENT {
    identity: { name: 'GET' },
    description: "Récupère une ressource. Sans effet secondaire.",
    affichage: { display_name: 'GET' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:post CONTENT {
    identity: { name: 'POST' },
    description: "Envoie des données pour créer une ressource ou traiter une action.",
    affichage: { display_name: 'POST' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:put CONTENT {
    identity: { name: 'PUT' },
    description: "Remplace intégralement une ressource par les données envoyées.",
    affichage: { display_name: 'PUT' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:patch CONTENT {
    identity: { name: 'PATCH' },
    description: "Applique des modifications partielles à une ressource.",
    affichage: { display_name: 'PATCH' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:delete CONTENT {
    identity: { name: 'DELETE' },
    description: "Supprime la ressource spécifiée.",
    affichage: { display_name: 'DELETE' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:head CONTENT {
    identity: { name: 'HEAD' },
    description: "Identique à GET mais ne retourne pas le corps (utile pour les métadonnées).",
    affichage: { display_name: 'HEAD' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:options CONTENT {
    identity: { name: 'OPTIONS' },
    description: "Renvoie les méthodes HTTP supportées par le serveur pour une URL.",
    affichage: { display_name: 'OPTIONS' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:trace CONTENT {
    identity: { name: 'TRACE' },
    description: "Effectue un test de boucle de message le long du chemin vers la ressource.",
    affichage: { display_name: 'TRACE' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:connect CONTENT {
    identity: { name: 'CONNECT' },
    description: "Établit un tunnel vers le serveur identifié par la ressource cible.",
    affichage: { display_name: 'CONNECT' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:propfind CONTENT {
    identity: { name: 'PROPFIND' },
    description: "Récupère les propriétés (XML) d’une ressource ou collection.",
    affichage: { display_name: 'PROPFIND' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:proppatch CONTENT {
    identity: { name: 'PROPPATCH' },
    description: "Définit ou modifie les propriétés d’une ressource.",
    affichage: { display_name: 'PROPPATCH' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:mkcol CONTENT {
    identity: { name: 'MKCOL' },
    description: "Crée une nouvelle collection (dossier).",
    affichage: { display_name: 'MKCOL' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:copy CONTENT {
    identity: { name: 'COPY' },
    description: "Copie une ressource vers une autre destination.",
    affichage: { display_name: 'COPY' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:move CONTENT {
    identity: { name: 'MOVE' },
    description: "Déplace ou renomme une ressource.",
    affichage: { display_name: 'MOVE' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:lock CONTENT {
    identity: { name: 'LOCK' },
    description: "Verrouille une ressource pour empêcher les modifications concurrentes.",
    affichage: { display_name: 'LOCK' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:unlock CONTENT {
    identity: { name: 'UNLOCK' },
    description: "Déverrouille une ressource précédemment verrouillée.",
    affichage: { display_name: 'UNLOCK' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:purge CONTENT {
    identity: { name: 'PURGE' },
    description: "Invalide le cache pour une ressource spécifique (Varnish/Squid).",
    affichage: { display_name: 'PURGE' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:link CONTENT {
    identity: { name: 'LINK' },
    description: "Établit une relation entre la ressource actuelle et d’autres.",
    affichage: { display_name: 'LINK' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:unlink CONTENT {
    identity: { name: 'UNLINK' },
    description: "Supprime une relation entre ressources.",
    affichage: { display_name: 'UNLINK' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_operations_methods:search CONTENT {
    identity: { name: 'SEARCH' },
    description: "Effectue une recherche sur une collection de ressources (WebDAV/Exchange).",
    affichage: { display_name: 'SEARCH' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

