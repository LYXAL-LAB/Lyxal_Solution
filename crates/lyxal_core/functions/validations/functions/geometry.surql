-- ============================================================================
-- LYXAL OS — CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/geometry.surql
-- Fonction     : fn::validation_geometry
-- Domaine      : Core / Validation
-- Version      : 1.0.0
-- Statut       : Stable
--
-- Description
-- -----------
-- Vérifie qu'une valeur obligatoire est strictement de type geometry
-- SurrealDB.
--
-- Cette fonction permet également :
--
--   - d'autoriser tous les sous-types géométriques ;
--   - de limiter la valeur à un ou plusieurs sous-types précis ;
--   - de vérifier facultativement la validité géographique de la valeur ;
--   - de retourner la géométrie d'origine sans transformation.
--
-- SurrealDB prend en charge les sous-types géométriques suivants :
--
--   - point ;
--   - line ;
--   - polygon ;
--   - multipoint ;
--   - multiline ;
--   - multipolygon ;
--   - collection.
--
-- Correspondance avec GeoJSON
-- ---------------------------
-- Les noms techniques utilisés par cette fonction correspondent aux types
-- internes SurrealDB :
--
--   point
--     GeoJSON : Point
--
--   line
--     GeoJSON : LineString
--
--   polygon
--     GeoJSON : Polygon
--
--   multipoint
--     GeoJSON : MultiPoint
--
--   multiline
--     GeoJSON : MultiLineString
--
--   multipolygon
--     GeoJSON : MultiPolygon
--
--   collection
--     GeoJSON : GeometryCollection
--
-- Exemples de valeurs
-- -------------------
-- Point sous forme de tuple :
--
--   (2.3522, 48.8566)
--
-- Point sous forme GeoJSON :
--
--   {
--       type: "Point",
--       coordinates: [2.3522, 48.8566]
--   }
--
-- LineString :
--
--   {
--       type: "LineString",
--       coordinates: [
--           [2.3522, 48.8566],
--           [4.8357, 45.7640]
--       ]
--   }
--
-- Polygon :
--
--   {
--       type: "Polygon",
--       coordinates: [[
--           [2.0, 48.0],
--           [3.0, 48.0],
--           [3.0, 49.0],
--           [2.0, 49.0],
--           [2.0, 48.0]
--       ]]
--   }
--
-- Ordre des coordonnées
-- ----------------------
-- Les coordonnées GeoJSON utilisent l'ordre :
--
--   longitude, latitude
--
-- Exemple pour Paris :
--
--   longitude : 2.3522
--   latitude  : 48.8566
--
-- La valeur correcte est donc :
--
--   (2.3522, 48.8566)
--
-- et non :
--
--   (48.8566, 2.3522)
--
-- Cette fonction vérifie le type géométrique, mais elle ne peut pas deviner si
-- l'appelant a inversé une longitude et une latitude lorsque les deux nombres
-- restent dans des plages techniquement acceptables.
--
-- Validation stricte
-- ------------------
-- Cette fonction accepte uniquement une véritable valeur geometry SurrealDB.
--
-- Exemples acceptés :
--
--   (2.3522, 48.8566)
--
--   {
--       type: "Point",
--       coordinates: [2.3522, 48.8566]
--   }
--
-- Exemples refusés :
--
--   [2.3522, 48.8566]
--     tableau ordinaire et non point géométrique.
--
--   "2.3522,48.8566"
--     chaîne.
--
--   {
--       longitude: 2.3522,
--       latitude: 48.8566
--   }
--     objet ordinaire.
--
--   NONE
--     absence de valeur.
--
--   NULL
--     valeur explicitement vide.
--
-- La fonction n'effectue aucune conversion automatique.
--
-- Conversion explicite
-- --------------------
-- Un tableau représentant un point peut être converti explicitement avec :
--
--   type::point([2.3522, 48.8566])
--
-- Exemple :
--
--   LET $point = type::point(
--       [2.3522, 48.8566]
--   );
--
--   LET $point = fn::validation_geometry(
--       $point,
--       "LOCATION",
--       ["point"],
--       true
--   );
--
-- Sous-types autorisés
-- ---------------------
-- Le paramètre $allowed_types permet de limiter les géométries acceptées.
--
-- Exemple pour autoriser uniquement un point :
--
--   ["point"]
--
-- Exemple pour autoriser un polygone ou un multipolygone :
--
--   ["polygon", "multipolygon"]
--
-- Exemple pour autoriser tous les types :
--
--   NONE
--
-- Un tableau vide est refusé, car il n'autoriserait aucun sous-type :
--
--   VALIDATION_EMPTY_GEOMETRY_TYPES
--
-- Les noms sont nettoyés avec string::trim() et convertis en minuscules.
--
-- Ainsi :
--
--   [" POINT ", "POLYGON"]
--
-- devient logiquement :
--
--   ["point", "polygon"]
--
-- Type réel de la géométrie
-- --------------------------
-- Le type précis est déterminé avec :
--
--   type::of($value)
--
-- Exemples de résultats :
--
--   geometry<point>
--   geometry<line>
--   geometry<polygon>
--   geometry<multipoint>
--   geometry<multiline>
--   geometry<multipolygon>
--   geometry<collection>
--
-- La fonction transforme ensuite ce résultat en nom court :
--
--   point
--   line
--   polygon
--   multipoint
--   multiline
--   multipolygon
--   collection
--
-- Validité géographique
-- ----------------------
-- Lorsque $require_valid vaut true, la fonction utilise :
--
--   geo::is_valid($value)
--
-- Cette fonction vérifie que la géométrie représente une géographie valide.
--
-- Une géométrie invalide produit :
--
--   <FIELD>_INVALID_GEOMETRY
--
-- Lorsque $require_valid vaut false, seule la reconnaissance du type geometry
-- et du sous-type autorisé est imposée.
--
-- Objet GeoJSON
-- --------------
-- Une géométrie créée depuis un objet GeoJSON doit respecter exactement la
-- structure attendue.
--
-- Pour les géométries classiques, l'objet doit notamment contenir :
--
--   - type ;
--   - coordinates.
--
-- Un objet incomplet ou contenant des données incompatibles ne sera pas
-- reconnu comme geometry par type::is_geometry().
--
-- Exemple valide :
--
--   {
--       type: "Point",
--       coordinates: [2.3522, 48.8566]
--   }
--
-- Exemple invalide :
--
--   {
--       coordinates: [2.3522, 48.8566]
--   }
--
-- Exemple invalide :
--
--   {
--       type: "Point",
--       coordinates: [2.3522, 48.8566],
--       name: "Paris"
--   }
--
-- Les métadonnées métier doivent être stockées à côté de la géométrie, et non
-- ajoutées directement dans l'objet géométrique.
--
-- Limites de la validation
-- ------------------------
-- Cette fonction ne vérifie pas :
--
--   - qu'un point correspond à une adresse réelle ;
--   - qu'une longitude et une latitude n'ont pas été inversées ;
--   - qu'une géométrie se trouve dans un pays déterminé ;
--   - qu'un point appartient à une zone autorisée ;
--   - qu'un polygone correspond à une parcelle cadastrale ;
--   - qu'une géométrie ne se croise pas elle-même au-delà du contrôle natif ;
--   - les permissions liées à une zone géographique ;
--   - la distance par rapport à une autre géométrie ;
--   - la surface minimale ou maximale ;
--   - le nombre maximal de coordonnées ;
--   - la complexité géométrique ;
--   - le système de coordonnées utilisé par une source externe.
--
-- Ces contrôles devront être réalisés par des fonctions spécialisées ou par
-- les fonctions métier.
--
-- Des fonctions complémentaires pourront être créées :
--
--   fn::validation_point()
--   fn::validation_polygon()
--   fn::validation_coordinates()
--   fn::validation_latitude()
--   fn::validation_longitude()
--   fn::validation_geometry_area()
--   fn::validation_geometry_in_bounds()
--
-- Cas d'utilisation
-- -----------------
-- Cette fonction peut notamment valider :
--
--   - une position de chantier ;
--   - une adresse géocodée ;
--   - une zone d'intervention ;
--   - un itinéraire ;
--   - une parcelle ;
--   - une zone de livraison ;
--   - une emprise de bâtiment ;
--   - une position de véhicule ;
--   - une zone de couverture ;
--   - une limite géographique.
--
-- Règles appliquées
-- -----------------
--   1. Le nom technique du champ doit être renseigné ;
--   2. Les sous-types autorisés sont nettoyés lorsqu'ils sont fournis ;
--   3. Le tableau des sous-types autorisés ne doit pas être vide ;
--   4. Chaque sous-type configuré doit être reconnu ;
--   5. La valeur doit être présente ;
--   6. La valeur ne doit pas être NULL ;
--   7. La valeur doit être strictement de type geometry ;
--   8. Le sous-type réel est déterminé ;
--   9. Le sous-type doit appartenir à la liste autorisée lorsqu'elle existe ;
--  10. La validité géographique est contrôlée lorsque demandée ;
--  11. La géométrie d'origine est retournée lorsqu'elle est valide.
--
-- Paramètres
-- ----------
-- $value:
--   Type : option<any>
--
--   Géométrie obligatoire à contrôler.
--
--   Le type option<any> permet de produire des codes d'erreur explicites pour :
--
--     - une valeur absente ;
--     - une valeur NULL ;
--     - une valeur d'un type incorrect ;
--     - un sous-type interdit ;
--     - une géométrie invalide.
--
-- $field:
--   Type : string
--
--   Nom technique utilisé pour construire les codes d'erreur.
--
--   Convention recommandée :
--
--     - LOCATION
--     - POSITION
--     - COORDINATES
--     - BOUNDARY
--     - SERVICE_AREA
--     - ROUTE
--     - GEOMETRY
--     - WORKSITE_LOCATION
--
-- $allowed_types:
--   Type : option<array<string>>
--
--   Liste facultative des sous-types autorisés.
--
--   Valeurs possibles :
--
--     - point ;
--     - line ;
--     - polygon ;
--     - multipoint ;
--     - multiline ;
--     - multipolygon ;
--     - collection.
--
--   Utiliser NONE pour accepter tous les sous-types géométriques.
--
-- $require_valid:
--   Type : bool
--
--   false :
--     Vérifie uniquement le type geometry et le sous-type autorisé.
--
--   true :
--     Vérifie également la géographie avec geo::is_valid().
--
-- Valeur retournée
-- ----------------
-- Type : geometry
--
-- Retourne la géométrie d'origine sans transformation.
--
-- Exemple :
--
--   fn::validation_geometry(
--       (2.3522, 48.8566),
--       "LOCATION",
--       ["point"],
--       true
--   )
--
-- retourne :
--
--   (2.3522, 48.8566)
--
-- Erreurs générées
-- ----------------
-- <FIELD>_REQUIRED
--   La valeur est absente ou égale à NONE.
--
-- <FIELD>_NULL_NOT_ALLOWED
--   La valeur est explicitement égale à NULL.
--
-- <FIELD>_INVALID_TYPE
--   La valeur fournie n'est pas strictement de type geometry.
--
-- <FIELD>_INVALID_GEOMETRY_TYPE
--   La géométrie appartient à un sous-type non autorisé.
--
-- <FIELD>_INVALID_GEOMETRY
--   La géométrie échoue au contrôle geo::is_valid().
--
-- VALIDATION_INVALID_FIELD_NAME
--   Le nom technique du champ est vide ou composé uniquement d'espaces.
--
-- VALIDATION_EMPTY_GEOMETRY_TYPES
--   Le tableau des sous-types autorisés est vide.
--
-- VALIDATION_INVALID_GEOMETRY_TYPE
--   Au moins un sous-type configuré n'est pas reconnu.
--
-- Permissions
-- -----------
-- PERMISSIONS FULL
--
-- Cette fonction est une primitive sans accès aux données persistantes :
--
--   - elle ne consulte aucune table ;
--   - elle ne crée aucune donnée ;
--   - elle ne modifie aucune donnée ;
--   - elle ne supprime aucune donnée ;
--   - elle ne contacte aucun service de géocodage ;
--   - elle ne contacte aucun service cartographique ;
--   - elle ne dépend pas du contexte d'authentification ;
--   - elle agit uniquement sur les paramètres transmis ;
--   - elle ne possède aucun effet secondaire.
--
-- Elle peut donc être appelée par toutes les fonctions métier autorisées.
--
-- Dépendances natives SurrealDB
-- -----------------------------
--   - string::trim()
--   - string::lowercase()
--   - string::concat()
--   - type::is_null()
--   - type::is_geometry()
--   - type::of()
--   - geo::is_valid()
--   - array::len()
--   - array::map()
--   - array::all()
--   - array::contains()
--
-- Dépendances Lyxal
-- -----------------
-- Aucune.
--
-- Ordre de chargement
-- -------------------
-- Cette fonction est autonome et peut être importée indépendamment.
--
-- Elle est toutefois logiquement liée aux futures fonctions :
--
--   - fn::validation_latitude()
--   - fn::validation_longitude()
--   - fn::validation_coordinates()
--   - fn::validation_point()
--   - fn::validation_polygon()
--
-- Exemples d'utilisation
-- ----------------------
-- Accepter toute géométrie :
--
-- LET $geometry = fn::validation_geometry(
--     $geometry,
--     "GEOMETRY",
--     NONE,
--     true
-- );
--
-- Accepter uniquement un point :
--
-- LET $location = fn::validation_geometry(
--     $location,
--     "LOCATION",
--     ["point"],
--     true
-- );
--
-- Accepter un polygone ou un multipolygone :
--
-- LET $service_area = fn::validation_geometry(
--     $service_area,
--     "SERVICE_AREA",
--     ["polygon", "multipolygon"],
--     true
-- );
--
-- Accepter un itinéraire simple ou multiple :
--
-- LET $route = fn::validation_geometry(
--     $route,
--     "ROUTE",
--     ["line", "multiline"],
--     true
-- );
--
-- Conversion explicite d'un tableau en point :
--
-- LET $location = type::point(
--     [2.3522, 48.8566]
-- );
--
-- LET $location = fn::validation_geometry(
--     $location,
--     "LOCATION",
--     ["point"],
--     true
-- );
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::validation_geometry(
    $value: option<any>,
    $field: string,
    $allowed_types: option<array<string>>,
    $require_valid: bool
) -> geometry {

    -- ------------------------------------------------------------------------
    -- 1. Validation du nom technique du champ
    -- ------------------------------------------------------------------------

    LET $clean_field = string::trim($field);

    IF $clean_field = "" {
        THROW "VALIDATION_INVALID_FIELD_NAME";
    };

    -- ------------------------------------------------------------------------
    -- 2. Préparation des sous-types autorisés
    -- ------------------------------------------------------------------------
    -- Les valeurs sont nettoyées et converties en minuscules afin d'accepter
    -- des configurations comme :
    --
    --   [" POINT ", "POLYGON"]
    --
    -- qui deviennent :
    --
    --   ["point", "polygon"]

    LET $clean_allowed_types = IF $allowed_types IS NONE {
        NONE
    } ELSE {
        array::map(
            $allowed_types,
            |$geometry_type| string::lowercase(
                string::trim($geometry_type)
            )
        )
    };

    -- ------------------------------------------------------------------------
    -- 3. Refus d'une liste vide
    -- ------------------------------------------------------------------------

    IF $clean_allowed_types IS NOT NONE
        AND array::len($clean_allowed_types) = 0
    {
        THROW "VALIDATION_EMPTY_GEOMETRY_TYPES";
    };

    -- ------------------------------------------------------------------------
    -- 4. Validation des sous-types configurés
    -- ------------------------------------------------------------------------

    IF $clean_allowed_types IS NOT NONE {

        LET $allowed_geometry_type_names = [
            "point",
            "line",
            "polygon",
            "multipoint",
            "multiline",
            "multipolygon",
            "collection"
        ];

        LET $all_configured_types_are_valid = array::all(
            $clean_allowed_types,
            |$geometry_type| array::contains(
                $allowed_geometry_type_names,
                $geometry_type
            )
        );

        IF !$all_configured_types_are_valid {
            THROW "VALIDATION_INVALID_GEOMETRY_TYPE";
        };
    };

    -- ------------------------------------------------------------------------
    -- 5. Vérification de la présence de la valeur
    -- ------------------------------------------------------------------------

    IF $value IS NONE {
        THROW string::concat(
            $clean_field,
            "_REQUIRED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 6. Refus explicite de NULL
    -- ------------------------------------------------------------------------

    IF type::is_null($value) {
        THROW string::concat(
            $clean_field,
            "_NULL_NOT_ALLOWED"
        );
    };

    -- ------------------------------------------------------------------------
    -- 7. Vérification stricte du type geometry
    -- ------------------------------------------------------------------------

    IF !type::is_geometry($value) {
        THROW string::concat(
            $clean_field,
            "_INVALID_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 8. Détermination du sous-type géométrique
    -- ------------------------------------------------------------------------
    -- type::of() retourne notamment :
    --
    --   geometry<point>
    --   geometry<line>
    --   geometry<polygon>
    --   geometry<multipoint>
    --   geometry<multiline>
    --   geometry<multipolygon>
    --   geometry<collection>

    LET $geometry_type = type::of($value);

    LET $short_geometry_type = IF $geometry_type = "geometry<point>" {
        "point"
    } ELSE IF $geometry_type = "geometry<line>" {
        "line"
    } ELSE IF $geometry_type = "geometry<polygon>" {
        "polygon"
    } ELSE IF $geometry_type = "geometry<multipoint>" {
        "multipoint"
    } ELSE IF $geometry_type = "geometry<multiline>" {
        "multiline"
    } ELSE IF $geometry_type = "geometry<multipolygon>" {
        "multipolygon"
    } ELSE IF $geometry_type = "geometry<collection>" {
        "collection"
    } ELSE {
        "unknown"
    };

    -- ------------------------------------------------------------------------
    -- 9. Vérification défensive du sous-type détecté
    -- ------------------------------------------------------------------------

    IF $short_geometry_type = "unknown" {
        THROW string::concat(
            $clean_field,
            "_INVALID_GEOMETRY_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 10. Vérification du sous-type autorisé
    -- ------------------------------------------------------------------------

    IF $clean_allowed_types IS NOT NONE
        AND !array::contains(
            $clean_allowed_types,
            $short_geometry_type
        )
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_GEOMETRY_TYPE"
        );
    };

    -- ------------------------------------------------------------------------
    -- 11. Vérification de la validité géographique
    -- ------------------------------------------------------------------------

    IF $require_valid
        AND !geo::is_valid($value)
    {
        THROW string::concat(
            $clean_field,
            "_INVALID_GEOMETRY"
        );
    };

    -- ------------------------------------------------------------------------
    -- 12. Retour de la géométrie validée
    -- ------------------------------------------------------------------------

    RETURN $value;
}
COMMENT "
Valide qu'une valeur obligatoire est strictement de type geometry SurrealDB.
Permet de limiter les sous-types autorisés à point, line, polygon, multipoint,
multiline, multipolygon ou collection, et de vérifier facultativement la
validité géographique avec geo::is_valid(). Retourne la géométrie d'origine
sans conversion ni transformation.
"
PERMISSIONS FULL;