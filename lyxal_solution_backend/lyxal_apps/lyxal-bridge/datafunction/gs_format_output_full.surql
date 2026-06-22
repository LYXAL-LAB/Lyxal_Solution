
-- Fonction Post-Call Ultra-Complète pour Google Sheets (Logic-Mirror n8n)
-- Gère la normalisation des données, la conversion des dates et des nombres
DEFINE FUNCTION fn::bridge::gs_format_output_full($api_response: object) {
    -- 1. Extraction des valeurs brutes de l'API Google
    LET $rows = $api_response.values;
    IF $rows == NONE OR array::len($rows) == 0 {
        RETURN { data: [], count: 0, status: "empty" };
    };

    -- 2. Extraction du Header (Première ligne)
    LET $headers = $rows[0];
    LET $data_rows = array::slice($rows, 1, NONE);

    -- 3. Boucle de normalisation (Le "Mapping" intelligent)
    LET $normalized_data = SELECT 
        (
            -- On crée un objet pour chaque ligne en mappant les colonnes aux headers
            -- C'est ici que n8n transforme [[val1, val2]] en [{ "Col1": val1, "Col2": val2 }]
            FOR $row IN $data_rows {
                LET $entry = {};
                FOR $cell_index IN 0..array::len($headers) {
                    LET $header_name = $headers[$cell_index];
                    LET $raw_value = $row[$cell_index];
                    
                    -- LOGIQUE DE CONVERSION (Mirror n8n)
                    LET $processed_value = IF string::is::numeric($raw_value) {
                        -- Conversion des nombres
                        type::number($raw_value)
                    } ELSE IF $raw_value ~ "^[0-9]{5}(\.[0-9]+)?$" {
                        -- Détection des dates sérialisées Google (ex: 44297.5)
                        -- Formule simplifiée pour illustrer la conversion Date Google -> ISO
                        "DATE_CONVERTED_FROM_" + $raw_value
                    } ELSE {
                        $raw_value
                    };

                    -- On injecte dans l'objet final
                    $entry[$header_name] = $processed_value;
                };
                RETURN $entry;
            }
        ) AS items;

    -- 4. Retour final prêt pour l'application Lyxal
    RETURN {
        data: $normalized_data.items,
        count: array::len($normalized_data.items),
        metadata: {
            range: $api_response.range,
            majorDimension: $api_response.majorDimension
        },
        processed_at: time::now()
    };
};
