DEFINE FUNCTION IF NOT EXISTS fn::identity_create_namespace() {
    RETURN function() {
        const prefix = "identity";
        
        // UUID sans tirets, seulement alphanumerique
        const uuid = crypto.randomUUID().replace(/[^a-zA-Z0-9]/g, '');
        // Prendre seulement les 12 premiers caractères
        const short_id = uuid.substring(0, 12);
        const namespace = `${prefix}_${short_id}`;
        
        const query = new surrealdb.Query(`DEFINE NAMESPACE ${namespace}`);
        const result = await surrealdb.query(query);
        
        return { 
            namespace: namespace,
            result: result 
        };
    };
};
COMMENT 'Création du namespace pour l\'identité'
PERMISSIONS NONE;