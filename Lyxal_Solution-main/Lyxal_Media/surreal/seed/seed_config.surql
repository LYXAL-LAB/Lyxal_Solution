-- Configuration initiale (Singleton)
-- ID fixe : svg_config:main

-- Note: En production, utilisez UPDATE si l'enregistrement existe déjà pour ne pas écraser
-- Ici on utilise CREATE pour l'initialisation propre.

CREATE svg_config:main CONTENT {
    bunny: {
        storage_zone: 'lyxalsolution',
        api_key: '2e89ed19-65af-4d73-a27fe83cb3b1-3655-4974',
        region: 'storage.bunnycdn.com',
        pull_zone_url: 'https://lyxalsolution.b-cdn.net'
    },
    github: {
        token: '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', -- Remplacer par votre vrai token
        user_agent: 'Lyxal-Importer/1.0'
    }
};
