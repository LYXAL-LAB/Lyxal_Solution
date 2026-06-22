-- Seed for bridge_auth_methods
-- Covers all common and advanced authentication methods for APIs

CREATE bridge_auth_methods:api_key CONTENT {
    identity: { name: 'api_key' },
    description: 'Authentification par clé API (Header, Query ou Cookie)',
    affichage: { display_name: 'API Key' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:bearer_token CONTENT {
    identity: { name: 'bearer_token' },
    description: 'Authentification par jeton porteur (Authorization: Bearer <token>)',
    affichage: { display_name: 'Bearer Token' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:basic_auth CONTENT {
    identity: { name: 'basic_auth' },
    description: 'Authentification HTTP Basic (Base64 user:password)',
    affichage: { display_name: 'Basic Auth' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:oauth2 CONTENT {
    identity: { name: 'oauth2' },
    description: 'Authentification OAuth 2.0 (Authorization Code, Client Credentials, etc.)',
    affichage: { display_name: 'OAuth 2.0' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:digest_auth CONTENT {
    identity: { name: 'digest_auth' },
    description: 'Authentification HTTP Digest (plus sécurisé que Basic)',
    affichage: { display_name: 'Digest Auth' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:hmac CONTENT {
    identity: { name: 'hmac' },
    description: 'Authentification par signature HMAC (Hash-based Message Authentication Code)',
    affichage: { display_name: 'HMAC Signature' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:aws_sigv4 CONTENT {
    identity: { name: 'aws_sigv4' },
    description: 'Authentification AWS Signature Version 4',
    affichage: { display_name: 'AWS Signature V4' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:jwt CONTENT {
    identity: { name: 'jwt' },
    description: 'Authentification par JSON Web Token personnalisé',
    affichage: { display_name: 'JWT' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:ntlm CONTENT {
    identity: { name: 'ntlm' },
    description: 'Authentification Windows NTLM',
    affichage: { display_name: 'NTLM' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};

CREATE bridge_auth_methods:none CONTENT {
    identity: { name: 'none' },
    description: 'Aucune authentification requise (API publique)',
    affichage: { display_name: 'No Auth' },
    status: {
        status: bridge_status:active,
        version: '1.0.0'
    }
};