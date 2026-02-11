/*
 * Function: fn::verify_checksum
 * Description: Vérifie l'intégrité d'un document en comparant le checksum calculé avec celui stocké.
 * Enregistre automatiquement le résultat dans la table `checksum_verifications`.
 * 
 * Arguments:
 * $doc_id: string - L'ID du document
 * $calculated_checksum: string - Le checksum calculé par l'API (SHA-256)
 * $verified_by: string - L'identifiant de celui qui vérifie (User ID ou "system")
 *
 * Retourne:
 * object - Le résultat de la vérification { valid: bool, message: string, ... }
 */

DEFINE FUNCTION fn::verify_checksum($doc_id: string, $calculated_checksum: string, $verified_by: string) {
    -- 1. Récupérer le document
    LET $doc = SELECT checksum, checksum_algorithm FROM documents WHERE id = $doc_id;
    
    IF array::len($doc) == 0 {
        THROW "DOCUMENT_NOT_FOUND: Document " + $doc_id + " does not exist";
    };

    LET $stored_checksum = $doc[0].checksum;
    LET $algorithm = IF $doc[0].checksum_algorithm { $doc[0].checksum_algorithm } ELSE { "SHA-256" };

    -- 2. Normalisation (minuscules, sans espaces)
    LET $norm_calc = string::lowercase(string::trim($calculated_checksum));
    LET $norm_stored = string::lowercase(string::trim($stored_checksum));

    -- 3. Comparaison
    LET $is_valid = ($norm_calc == $norm_stored);
    
    -- 4. Message de résultat
    LET $message = IF $is_valid { 
        "Checksums match - document integrity verified" 
    } ELSE { 
        "Checksums do not match - document may have been modified" 
    };

    -- 5. Enregistrement de l'audit (Audit Trail)
    CREATE checksum_verifications CONTENT {
        doc_id: $doc_id,
        verified_by: $verified_by,
        verified_at: time::now(),
        stored_checksum: $norm_stored,
        calculated_checksum: $norm_calc,
        algorithm: $algorithm,
        is_valid: $is_valid,
        error_message: IF $is_valid { NONE } ELSE { "Checksum mismatch" }
    };

    -- 6. Retourner le résultat
    RETURN {
        valid: $is_valid,
        stored_checksum: $norm_stored,
        calculated_checksum: $norm_calc,
        algorithm: $algorithm,
        message: $message
    };
};
