/*
 * Function: fn::register_signature
 * Description: Enregistre une nouvelle signature de manière atomique avec chaînage (Blockchain-like).
 * 
 * Arguments:
 * $doc_id: string - L'ID du document signé
 * $user_sub: string - L'identifiant unique de l'utilisateur (Subject)
 * $user_email: string - L'email de l'utilisateur
 * $user_name: string - Le nom de l'utilisateur (optionnel)
 * $signature: string - La signature cryptographique (Ed25519) en base64
 * $payload_hash: string - Le hash SHA-256 du payload signé
 * $nonce: string - Le nonce utilisé pour la signature
 * $doc_checksum: string - Le checksum du document au moment de la signature (optionnel)
 * $referer: string - L'URL de provenance (optionnel)
 *
 * Retourne:
 * L'enregistrement de la signature créée.
 */

DEFINE FUNCTION fn::register_signature(
    $doc_id: string, 
    $user_sub: string, 
    $user_email: string, 
    $user_name: string, 
    $signature: string, 
    $payload_hash: string, 
    $nonce: string,
    $doc_checksum: string,
    $referer: string
) {
    -- 1. Vérifier si l'utilisateur a déjà signé ce document
    -- Règle métier : Un utilisateur ne peut signer qu'une seule fois un document donné
    LET $existing = SELECT id FROM signatures WHERE doc_id = $doc_id AND user_sub = $user_sub LIMIT 1;
    
    IF array::len($existing) > 0 {
        THROW "ALREADY_SIGNED: User has already signed this document";
    };

    -- 2. Récupérer le hash de la dernière signature pour ce document (Chaînage)
    -- On trie par date de création décroissante pour avoir le dernier bloc
    LET $last_sig = SELECT payload_hash FROM signatures WHERE doc_id = $doc_id ORDER BY created_at DESC LIMIT 1;
    
    -- Si c'est la première signature (Genesis), prev_hash est NONE
    -- Sinon, prev_hash est le payload_hash de la signature précédente
    LET $prev_hash = IF array::len($last_sig) > 0 { 
        $last_sig[0].payload_hash 
    } ELSE { 
        NONE 
    };

    -- 3. Insérer la nouvelle signature
    -- L'utilisation de RETURN AFTER permet de renvoyer l'objet créé
    RETURN CREATE signatures CONTENT {
        doc_id: $doc_id,
        user_sub: $user_sub,
        user_email: $user_email,
        user_name: $user_name,
        signature: $signature,
        payload_hash: $payload_hash,
        nonce: $nonce,
        doc_checksum: $doc_checksum,
        referer: $referer,
        prev_hash: $prev_hash,
        
        -- Les champs automatiques (gérés par le schéma mais explicites ici pour clarté)
        signed_at: time::now(),
        created_at: time::now()
    };
};
