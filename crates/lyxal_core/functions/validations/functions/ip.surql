-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/ip.surql
-- Fonction     : fn::validation_ip
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est une adresse IP syntaxiquement valide.
--
-- La fonction permet de choisir le type d'adresse attendu :
--
--   - any  : accepte IPv4 ou IPv6 ;
--   - ipv4 : accepte uniquement IPv4 ;
--   - ipv6 : accepte uniquement IPv6.
--
-- Exemples d'adresses IPv4 valides :
--
--   192.168.1.1
--   127.0.0.1
--   8.8.8.8
--   255.255.255.255
--
-- Exemples d'adresses IPv6 valides :
--
--   2001:db8::1
--   ::1
--   fe80::1
--   2001:0db8:85a3:0000:0000:8a2e:0370:7334
--
-- Cette fonction utilise les validateurs natifs SurrealDB :
--
--   - string::is_ip()
--   - string::is_ipv4()
--   - string::is_ipv6()
--
-- Elle ne repose donc pas sur une expression régulière personnalisée.
--
-- Cas d'utilisation
-- -----------------
-- Cette fonction peut être utilisée pour valider :
--
--   - une adresse IP cliente ;
--   - une adresse IP de serveur ;
--   - une adresse IP autorisée ;
--   - une adresse IP bloquée ;
--   - une adresse IP de proxy ;
--   - une adresse IP de webhook ;
--   - une adresse IP d'infrastructure ;
--   - une adresse IP enregistrée dans un journal d'audit ;
--   - une adresse IP utilisée dans une règle réseau.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une valeur de type string.
--
-- Exemples acceptés :
--
--   "192.168.1.1"
--   "2001:db8::1"
--
-- Exemples refusés :
--
--   NONE
--   NULL
--   19216811
--   true
--   ["192.168.1.1"]
--
-- Nettoyage
-- ----------
-- Les espaces périphériques sont supprimés avec string::trim().
--
-- Exemple :
--
--   "   192.168.1.1   "
--
-- devient :
--
--   "192.168.1.1"
--
-- Les espaces internes restent interdits.
--
-- Cette fonction ne transforme pas :
--
--   - une IPv4 en IPv6 ;
--   - une IPv6 longue en forme compressée ;
--   - une IPv6 compressée en forme complète ;
--   - une adresse contenant un port ;
--   - une notation CIDR.
--
-- Les valeurs suivantes ne sont donc pas des adresses IP simples :
--
--   192.168.1.1:8080
--   [2001:db8::1]:443
--   192.168.1.0/24
--   2001:db8::/32
--
-- Des fonctions distinctes pourront être créées pour :
--
--   - fn::validation_cidr()
--   - fn::validation_socket_address()
--   - fn::validation_ip_range()
--
-- Limites de la validation
-- ------------------------
-- Cette fonction vérifie uniquement la syntaxe de l'adresse.
--
-- Elle ne vérifie pas :
--
--   - que l'adresse est joignable ;
--   - que l'adresse est publique ou privée ;
--   - que l'adresse est réservée ;
--   - que l'adresse est une adresse de boucle locale ;
--   - que l'adresse appartient à un réseau autorisé ;
--   - que l'adresse correspond réellement au client connecté ;
--   - que l'adresse n'est pas une adresse de multicast ;
--   - que l'adresse n'est pas une adresse de broadcast ;
--   - que l'adresse est autorisée par les règles de sécurité.
--
-- Ces contrôles relèvent des fonctions métier ou du domaine core/security.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Adresse IP obligatoire à contrôler.
--
--   Le type option<any> permet de produire des codes d'erreur explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - un type incorrect ;
--     - une chaîne vide ;
--     - une adresse au format invalide.
--
-- $field:
--   Type : string
--
--   Nom technique du champ utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - IP_ADDRESS
--     - CLIENT_IP
--     - SERVER_IP
--     - PROXY_IP
--     - ALLOWED_IP
--     - BLOCKED_IP
--     - SOURCE_IP
--
-- $version:
--   Type : option<string>
--
--   Version d'adresse IP attendue.
--
--   Valeurs autorisées :
--
--     "any"
--       Accepte une adresse IPv4 ou IPv6.
--
--     "ipv4"
--       Accepte uniquement une adresse IPv4.
--
--     "ipv6"
--       Accepte uniquement une adresse IPv6.
--
--   Lorsque la valeur est NONE, le mode "any" est utilisé.
--
--   La valeur est nettoyée et convertie en minuscules avant validation.
--
-- Valeur retournée
-- ----------------
-- Type : string
--
-- Retourne l'adresse IP nettoyée sans autre transformation.
--
-- Exemple :
--
--   fn::validation_ip(
--       "  192.168.1.1  ",
--       "CLIENT_IP",
--       "ipv4"
--   )
--
-- retourne :
--
--   "192.168.1.1"
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente, égale à NONE ou vide après nettoyage.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas de type string.
--
-- <FIELD>_INVALID_FORMAT
--   La chaîne ne correspond pas au type d'adresse IP attendu.
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_INVALID_IP_VERSION
--   La version demandée n'est ni any, ni ipv4, ni ipv6.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive pure :
--
--   - elle ne consulte aucune table ;
--   - elle ne contacte aucune adresse distante ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur ses paramètres ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Attention :
--
-- Une adresse syntaxiquement valide ne doit jamais être considérée comme sûre
-- uniquement parce qu'elle a passé cette validation.
--
-- Les contrôles relatifs aux réseaux privés, aux interfaces locales, aux
-- adresses réservées et aux risques SSRF doivent être appliqués séparément.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::lowercase()
--   - string::concat()
--   - string::is_ip()
--   - string::is_ipv4()
--   - string::is_ipv6()
--   - type::is_string()
--   - type::is_null()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment des autres
-- fonctions de validation.
--
-- Exemples d'utilisation
-- ----------------------
-- Accepter IPv4 ou IPv6 :
--
-- LET $client_ip = fn::validation_ip(
--     $client_ip,
--     "CLIENT_IP",
--     "any"
-- );
--
-- Accepter uniquement IPv4 :
--
-- LET $server_ip = fn::validation_ip(
--     $server_ip,
--     "SERVER_IP",
--     "ipv4"
-- );
--
-- Accepter uniquement IPv6 :
--
-- LET $server_ip = fn::validation_ip(
--     $server_ip,
--     "SERVER_IP",
--     "ipv6"
-- );
--
-- Utiliser le mode par défaut :
--
-- LET $source_ip = fn::validation_ip(
--     $source_ip,
--     "SOURCE_IP",
--     NONE
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_ip(
    $value: option<any>,
    $field: string,
    $version: option<string>
) -> string {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Préparation de la version attendue
    -- ------------------------------------------------------------------------
    -- Lorsque la version n'est pas fournie, la fonction accepte IPv4 ou IPv6.

    LET $clean_version = IF $version IS NONE {
        "any"
    } ELSE {
        string::lowercase(
            string::trim($version)
        )
    };

    -- ------------------------------------------------------------------------
    -- 3. Validation de la configuration
    -- ------------------------------------------------------------------------

    IF $clean_version NOT IN [
        "any",
        "ipv4",
        "ipv6"
    ] {
        THROW "VALIDATION_INVALID_IP_VERSION";
    };

    -- ------------------------------------------------------------------------
    -- 4. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 5. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Vérification stricte du type string
    -- ------------------------------------------------------------------------

    IF !type::is_string($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Suppression des espaces périphériques
    -- ------------------------------------------------------------------------

    LET $clean_value = string::trim($value);

    IF $clean_value = "" {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Validation d'une adresse IPv4 ou IPv6
    -- ------------------------------------------------------------------------

    IF $clean_version = "any"
        AND !string::is_ip($clean_value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 9. Validation d'une adresse IPv4 uniquement
    -- ------------------------------------------------------------------------

    IF $clean_version = "ipv4"
        AND !string::is_ipv4($clean_value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 10. Validation d'une adresse IPv6 uniquement
    -- ------------------------------------------------------------------------

    IF $clean_version = "ipv6"
        AND !string::is_ipv6($clean_value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_FORMAT"
        );
    };

    -- ------------------------------------------------------------------------
    -- 11. Retour de l'adresse IP validée
    -- ------------------------------------------------------------------------

    RETURN $clean_value;
}
COMMENT "
Valide qu'une valeur obligatoire est une adresse IP syntaxiquement valide.
Permet d'accepter IPv4 et IPv6, uniquement IPv4 ou uniquement IPv6. Supprime
les espaces périphériques et retourne l'adresse nettoyée sans transformation.
"
PERMISSIONS FULL;