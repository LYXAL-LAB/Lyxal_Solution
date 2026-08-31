-- ============================================================================
-- LYXAL OS — TESTS CORE VALIDATION
-- ============================================================================
-- Fichier      : core/validation/tests/geometry.test.surql
-- Fonction     : fn::validation_geometry
-- Domaine      : Core / Validation
-- Version      : 1.0.0
--
-- Important
-- ---------
-- Les tests provoquant volontairement un THROW interrompent l'exécution du
-- bloc.
--
-- Dans Surrealist, sélectionner uniquement le test concerné lorsqu'une erreur
-- est attendue.
-- ============================================================================


-- ============================================================================
-- TEST 1 — Point sous forme de tuple
-- Résultat attendu : (2.3522, 48.8566)
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 2 — Point sous forme GeoJSON
-- Résultat attendu : géométrie de type point
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "Point",
        coordinates: [2.3522, 48.8566]
    },
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 3 — Point accepté sans restriction de sous-type
-- Résultat attendu : (2.3522, 48.8566)
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    NONE,
    true
);


-- ============================================================================
-- TEST 4 — Point créé avec type::point()
-- Résultat attendu : géométrie de type point
-- ============================================================================

LET $point = type::point(
    [2.3522, 48.8566]
);

RETURN fn::validation_geometry(
    $point,
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 5 — Sous-type configuré avec espaces et majuscules
-- Résultat attendu : (2.3522, 48.8566)
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["   POINT   "],
    true
);


-- ============================================================================
-- TEST 6 — LineString valide
-- Résultat attendu : géométrie de type line
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "LineString",
        coordinates: [
            [2.3522, 48.8566],
            [4.8357, 45.7640]
        ]
    },
    "ROUTE",
    ["line"],
    true
);


-- ============================================================================
-- TEST 7 — LineString autorisé avec plusieurs sous-types
-- Résultat attendu : géométrie de type line
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "LineString",
        coordinates: [
            [2.3522, 48.8566],
            [4.8357, 45.7640]
        ]
    },
    "ROUTE",
    ["line", "multiline"],
    true
);


-- ============================================================================
-- TEST 8 — Polygon valide
-- Résultat attendu : géométrie de type polygon
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "Polygon",
        coordinates: [[
            [2.0, 48.0],
            [3.0, 48.0],
            [3.0, 49.0],
            [2.0, 49.0],
            [2.0, 48.0]
        ]]
    },
    "SERVICE_AREA",
    ["polygon"],
    true
);


-- ============================================================================
-- TEST 9 — MultiPoint valide
-- Résultat attendu : géométrie de type multipoint
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "MultiPoint",
        coordinates: [
            [2.3522, 48.8566],
            [4.8357, 45.7640]
        ]
    },
    "LOCATIONS",
    ["multipoint"],
    true
);


-- ============================================================================
-- TEST 10 — MultiLineString valide
-- Résultat attendu : géométrie de type multiline
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "MultiLineString",
        coordinates: [
            [
                [2.3522, 48.8566],
                [4.8357, 45.7640]
            ],
            [
                [1.4442, 43.6047],
                [5.3698, 43.2965]
            ]
        ]
    },
    "ROUTES",
    ["multiline"],
    true
);


-- ============================================================================
-- TEST 11 — MultiPolygon valide
-- Résultat attendu : géométrie de type multipolygon
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "MultiPolygon",
        coordinates: [
            [[
                [2.0, 48.0],
                [3.0, 48.0],
                [3.0, 49.0],
                [2.0, 49.0],
                [2.0, 48.0]
            ]],
            [[
                [4.0, 45.0],
                [5.0, 45.0],
                [5.0, 46.0],
                [4.0, 46.0],
                [4.0, 45.0]
            ]]
        ]
    },
    "SERVICE_AREAS",
    ["multipolygon"],
    true
);


-- ============================================================================
-- TEST 12 — GeometryCollection valide
-- Résultat attendu : géométrie de type collection
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "GeometryCollection",
        geometries: [
            {
                type: "Point",
                coordinates: [2.3522, 48.8566]
            },
            {
                type: "LineString",
                coordinates: [
                    [2.3522, 48.8566],
                    [4.8357, 45.7640]
                ]
            }
        ]
    },
    "GEOMETRIES",
    ["collection"],
    true
);


-- ============================================================================
-- TEST 13 — Polygon autorisé parmi plusieurs types
-- Résultat attendu : géométrie de type polygon
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "Polygon",
        coordinates: [[
            [2.0, 48.0],
            [3.0, 48.0],
            [3.0, 49.0],
            [2.0, 49.0],
            [2.0, 48.0]
        ]]
    },
    "SERVICE_AREA",
    ["polygon", "multipolygon"],
    true
);


-- ============================================================================
-- TEST 14 — Valeur absente
-- Erreur attendue : LOCATION_REQUIRED
-- ============================================================================

RETURN fn::validation_geometry(
    NONE,
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 15 — Valeur NULL
-- Erreur attendue : LOCATION_NULL_NOT_ALLOWED
-- ============================================================================

RETURN fn::validation_geometry(
    NULL,
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 16 — Tableau de coordonnées non converti
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    [2.3522, 48.8566],
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 17 — Chaîne contenant des coordonnées
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    "2.3522,48.8566",
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 18 — Objet longitude/latitude ordinaire
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    {
        longitude: 2.3522,
        latitude: 48.8566
    },
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 19 — Objet GeoJSON sans propriété type
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    {
        coordinates: [2.3522, 48.8566]
    },
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 20 — Objet GeoJSON avec propriété supplémentaire
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "Point",
        coordinates: [2.3522, 48.8566],
        name: "Paris"
    },
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 21 — Entier à la place d'une géométrie
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    42,
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 22 — Booléen à la place d'une géométrie
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    true,
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 23 — Record ID à la place d'une géométrie
-- Erreur attendue : LOCATION_INVALID_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    location:paris,
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 24 — Point fourni alors qu'un polygon est attendu
-- Erreur attendue : SERVICE_AREA_INVALID_GEOMETRY_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "SERVICE_AREA",
    ["polygon"],
    true
);


-- ============================================================================
-- TEST 25 — Polygon fourni alors qu'un point est attendu
-- Erreur attendue : LOCATION_INVALID_GEOMETRY_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    {
        type: "Polygon",
        coordinates: [[
            [2.0, 48.0],
            [3.0, 48.0],
            [3.0, 49.0],
            [2.0, 49.0],
            [2.0, 48.0]
        ]]
    },
    "LOCATION",
    ["point"],
    true
);


-- ============================================================================
-- TEST 26 — Liste vide de sous-types autorisés
-- Erreur attendue : VALIDATION_EMPTY_GEOMETRY_TYPES
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    [],
    true
);


-- ============================================================================
-- TEST 27 — Sous-type configuré inconnu
-- Erreur attendue : VALIDATION_INVALID_GEOMETRY_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["circle"],
    true
);


-- ============================================================================
-- TEST 28 — Liste contenant un type valide et un type inconnu
-- Erreur attendue : VALIDATION_INVALID_GEOMETRY_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["point", "circle"],
    true
);


-- ============================================================================
-- TEST 29 — Sous-type vide
-- Erreur attendue : VALIDATION_INVALID_GEOMETRY_TYPE
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["     "],
    true
);


-- ============================================================================
-- TEST 30 — Contrôle de validité désactivé
-- Résultat attendu : géométrie reçue si son type est reconnu
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["point"],
    false
);


-- ============================================================================
-- TEST 31 — Vérification du type avec type::of()
-- Résultat attendu : "geometry<point>"
-- ============================================================================

LET $geometry = fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["point"],
    true
);

RETURN type::of($geometry);


-- ============================================================================
-- TEST 32 — Vérification spécialisée type::is_point()
-- Résultat attendu : true
-- ============================================================================

LET $geometry = fn::validation_geometry(
    (2.3522, 48.8566),
    "LOCATION",
    ["point"],
    true
);

RETURN type::is_point($geometry);


-- ============================================================================
-- TEST 33 — Calcul de distance après validation de deux points
-- Résultat attendu : distance numérique entre Paris et Lyon
-- ============================================================================

LET $paris = fn::validation_geometry(
    (2.3522, 48.8566),
    "START_LOCATION",
    ["point"],
    true
);

LET $lyon = fn::validation_geometry(
    (4.8357, 45.7640),
    "END_LOCATION",
    ["point"],
    true
);

RETURN geo::distance(
    $paris,
    $lyon
);


-- ============================================================================
-- TEST 34 — Calcul du centroïde après validation d'un polygon
-- Résultat attendu : point représentant le centroïde
-- ============================================================================

LET $polygon = fn::validation_geometry(
    {
        type: "Polygon",
        coordinates: [[
            [2.0, 48.0],
            [3.0, 48.0],
            [3.0, 49.0],
            [2.0, 49.0],
            [2.0, 48.0]
        ]]
    },
    "SERVICE_AREA",
    ["polygon"],
    true
);

RETURN geo::centroid($polygon);


-- ============================================================================
-- TEST 35 — Calcul de surface après validation d'un polygon
-- Résultat attendu : surface numérique
-- ============================================================================

LET $polygon = fn::validation_geometry(
    {
        type: "Polygon",
        coordinates: [[
            [2.0, 48.0],
            [3.0, 48.0],
            [3.0, 49.0],
            [2.0, 49.0],
            [2.0, 48.0]
        ]]
    },
    "SERVICE_AREA",
    ["polygon"],
    true
);

RETURN geo::area($polygon);


-- ============================================================================
-- TEST 36 — Nom technique vide
-- Erreur attendue : VALIDATION_INVALID_FIELD_NAME
-- ============================================================================

RETURN fn::validation_geometry(
    (2.3522, 48.8566),
    "     ",
    ["point"],
    true
);