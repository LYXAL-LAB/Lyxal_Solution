-- -----------------------------------------------------------------------------
-- LYXAL PHOTO ENGINE (Brain Layer)
-- Version: M8 (Observability)
-- -----------------------------------------------------------------------------

-- 1. CONFIGURATION
DEFINE TABLE asset SCHEMAFULL;
DEFINE FIELD hash        ON TABLE asset TYPE string;
DEFINE FIELD size        ON TABLE asset TYPE int;
DEFINE FIELD mime        ON TABLE asset TYPE string;
DEFINE FIELD storage_key ON TABLE asset TYPE string;

DEFINE TABLE photo SCHEMAFULL;
DEFINE FIELD uid             ON TABLE photo TYPE string;
DEFINE FIELD type            ON TABLE photo TYPE string ASSERT $value IN ['image', 'video', 'live'];
DEFINE FIELD title           ON TABLE photo TYPE string;
DEFINE FIELD caption         ON TABLE photo TYPE string;
DEFINE FIELD taken_at        ON TABLE photo TYPE datetime;
DEFINE FIELD taken_at_local  ON TABLE photo TYPE datetime;
DEFINE FIELD quality         ON TABLE photo TYPE int ASSERT $value >= 0 AND $value <= 7;
DEFINE FIELD resolution      ON TABLE photo TYPE int;
DEFINE FIELD latlng          ON TABLE photo TYPE option<point>;
DEFINE FIELD details         ON TABLE photo TYPE object;
DEFINE FIELD details.keywords ON TABLE photo TYPE array<string> DEFAULT [];
DEFINE FIELD place           ON TABLE photo TYPE option<record<place>>;
DEFINE FIELD place_status    ON TABLE photo TYPE string ASSERT $value IN ['pending', 'resolved', 'failed', 'disabled'];

-- VIDEO METADATA (Lyxal Video Engine)
DEFINE FIELD duration_ms ON TABLE photo TYPE option<int>;
DEFINE FIELD fps         ON TABLE photo TYPE option<float>;
DEFINE FIELD video_codec ON TABLE photo TYPE option<string>;
DEFINE FIELD audio_codec ON TABLE photo TYPE option<string>;
DEFINE FIELD has_audio   ON TABLE photo TYPE bool DEFAULT false;

DEFINE FIELD created_at      ON TABLE photo TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at      ON TABLE photo TYPE datetime DEFAULT time::now();
DEFINE FIELD edited_at       ON TABLE photo TYPE option<datetime>;
DEFINE FIELD indexed_at      ON TABLE photo TYPE option<datetime>;
DEFINE FIELD deleted_at      ON TABLE photo TYPE option<datetime>;

-- LIBRARY REFERENCE
DEFINE TABLE file SCHEMAFULL;
DEFINE FIELD uid         ON TABLE file TYPE string;
DEFINE FIELD asset       ON TABLE file TYPE record<asset>;
DEFINE FIELD photo       ON TABLE file TYPE option<record<photo>>;
DEFINE FIELD path        ON TABLE file TYPE string;
DEFINE FIELD name        ON TABLE file TYPE string;
DEFINE FIELD origin      ON TABLE file TYPE string;
DEFINE FIELD is_primary  ON TABLE file TYPE bool DEFAULT false;
DEFINE FIELD is_sidecar  ON TABLE file TYPE bool DEFAULT false;

-- BIOMETRIC DETECTION (Marker on a specific rendition/file)
DEFINE TABLE marker SCHEMAFULL;
DEFINE FIELD uid          ON TABLE marker TYPE string;
DEFINE FIELD file         ON TABLE marker TYPE record<file>;
DEFINE FIELD type         ON TABLE marker TYPE string ASSERT $value IN ['face', 'label', 'manual'];
DEFINE FIELD src          ON TABLE marker TYPE string ASSERT $value IN ['ai', 'manual'];
DEFINE FIELD x            ON TABLE marker TYPE float;
DEFINE FIELD y            ON TABLE marker TYPE float;
DEFINE FIELD w            ON TABLE marker TYPE float;
DEFINE FIELD h            ON TABLE marker TYPE float;
DEFINE FIELD start_ms     ON TABLE marker TYPE option<int>; -- Video start
DEFINE FIELD end_ms       ON TABLE marker TYPE option<int>; -- Video end
DEFINE FIELD uncertainty  ON TABLE marker TYPE float;

-- BIOMETRIC SIGNATURE
DEFINE TABLE face SCHEMAFULL;
DEFINE FIELD marker     ON TABLE face TYPE record<marker>;
DEFINE FIELD embedding  ON TABLE face TYPE array<float> ASSERT array::len($value) = 512;
DEFINE FIELD cluster_id ON TABLE face TYPE option<uuid>;

-- IDENTITY & SUBJECTS
DEFINE TABLE person SCHEMAFULL;
DEFINE FIELD uid   ON TABLE person TYPE string;
DEFINE FIELD name  ON TABLE person TYPE string;

DEFINE TABLE label SCHEMAFULL;
DEFINE FIELD uid   ON TABLE label TYPE string;
DEFINE FIELD name  ON TABLE label TYPE string;

-- ORGANIZATION
DEFINE TABLE album SCHEMAFULL;
DEFINE FIELD uid   ON TABLE album TYPE string;
DEFINE FIELD title ON TABLE album TYPE string;

-- GEOGRAPHY
DEFINE TABLE place SCHEMAFULL;
DEFINE FIELD provider    ON TABLE place TYPE string;
DEFINE FIELD provider_id ON TABLE place TYPE string;
DEFINE FIELD name        ON TABLE place TYPE string;
DEFINE FIELD label       ON TABLE place TYPE string;
DEFINE FIELD city        ON TABLE place TYPE option<string>;
DEFINE FIELD state       ON TABLE place TYPE option<string>;
DEFINE FIELD country     ON TABLE place TYPE string;
DEFINE FIELD country_code ON TABLE place TYPE string;
DEFINE FIELD post_code   ON TABLE place TYPE option<string>;
DEFINE FIELD road        ON TABLE place TYPE option<string>;
DEFINE FIELD latlng      ON TABLE place TYPE point;

DEFINE INDEX place_provider_uq ON TABLE place COLUMNS provider, provider_id UNIQUE;

-- SHARING & ACCESS
DEFINE TABLE link SCHEMAFULL;
DEFINE FIELD token       ON TABLE link TYPE string;
DEFINE FIELD target_type ON TABLE link TYPE string ASSERT $value IN ['photo', 'album'];
DEFINE FIELD target      ON TABLE link TYPE record;
DEFINE FIELD permissions ON TABLE link TYPE array<string>; -- viewer, editor, download
DEFINE FIELD expires_at  ON TABLE link TYPE option<datetime>;

-- DERIVATIVES
DEFINE TABLE rendition SCHEMAFULL;
DEFINE FIELD file            ON TABLE rendition TYPE record<file>;
DEFINE FIELD purpose         ON TABLE rendition TYPE string; -- thumb|preview|web|transcode
DEFINE FIELD format          ON TABLE rendition TYPE string;
DEFINE FIELD width           ON TABLE rendition TYPE int;
DEFINE FIELD height          ON TABLE rendition TYPE int;
DEFINE FIELD storage_pointer ON TABLE rendition TYPE string;
DEFINE FIELD status          ON TABLE rendition TYPE string ASSERT $value IN ['pending', 'completed', 'failed'];

-- -----------------------------------------------------------------------------
-- 3. INDEXES
-- -----------------------------------------------------------------------------

-- UNIQUENESS
DEFINE INDEX asset_hash_uq ON TABLE asset COLUMNS hash UNIQUE;
DEFINE INDEX photo_uid_uq  ON TABLE photo COLUMNS uid UNIQUE;
DEFINE INDEX file_uid_uq   ON TABLE file COLUMNS uid UNIQUE;
DEFINE INDEX link_token_uq ON TABLE link COLUMNS token UNIQUE;

-- PERFORMANCE INDEXES
DEFINE INDEX file_asset_idx ON TABLE file COLUMNS asset;
DEFINE INDEX file_photo_idx ON TABLE file COLUMNS photo;
DEFINE INDEX photo_taken_at_idx ON TABLE photo COLUMNS taken_at;
DEFINE INDEX face_cluster_idx ON TABLE face COLUMNS cluster_id;

-- FULLTEXT SEARCH
DEFINE INDEX photo_title_ft   ON TABLE photo COLUMNS title   FULLTEXT ANALYZER lyxal_fr BM25;
DEFINE INDEX photo_caption_ft ON TABLE photo COLUMNS caption FULLTEXT ANALYZER lyxal_fr BM25;

-- GEOSPATIAL
DEFINE INDEX photo_geo ON TABLE photo COLUMNS latlng GEO;

-- VECTOR SEARCH (HNSW)
DEFINE INDEX face_vec ON TABLE face COLUMNS embedding HNSW DIMENSION 512;

-- -----------------------------------------------------------------------------
-- 4. FUNCTIONS (Brain Layer)
-- -----------------------------------------------------------------------------

-- ROOT INGESTION PRIMITIVE
DEFINE FUNCTION fn::photo::import(
    $binary_hash: string,
    $mime: string,
    $size: int,
    $storage_key: string,
    $filename: string,
    $path: string,
    $origin: string,
    $taken_at: datetime,
    $taken_at_local: datetime,
    $width: int,
    $height: int
) {
    -- 1. Asset Layer (Atomic Dedup via UPSERT)
    UPSERT asset SET 
        hash = $binary_hash, 
        size = $size, 
        mime = $mime, 
        storage_key = $storage_key 
    WHERE hash = $binary_hash;

    -- Récupération de l'ID par SELECT (Règle CTO)
    LET $assets = (SELECT id FROM asset WHERE hash = $binary_hash LIMIT 1);
    LET $asset = $assets[0].id;

    -- 2. Photo Pairing Logic
    LET $photo_type = IF string::contains($mime, 'video') THEN 'video' ELSE 'image' END;

    -- Recherche de photo candidate dans la fenêtre ±2s
    LET $candidates = (
        SELECT id FROM photo 
        WHERE type = $photo_type 
          AND taken_at >= $taken_at - 2s 
          AND taken_at <= $taken_at + 2s 
        LIMIT 1
    );
    LET $candidate = IF array::len($candidates) > 0 THEN $candidates[0].id ELSE NONE END;

    -- Vérification de la présence d'un fichier primaire
    LET $has_primary = IF $candidate != NONE THEN 
        (SELECT count() FROM file WHERE photo = $candidate AND is_primary = true GROUP ALL)[0].count OR 0
    ELSE 0 END;

    -- Pairing uniquement si pas de fichier primaire existant
    LET $photo_id = IF $candidate != NONE AND $has_primary = 0 THEN 
        $candidate 
    ELSE 
        (CREATE photo SET 
            uid = <string> rand::uuid(),
            type = $photo_type,
            title = string::split($filename, ".")[0],
            taken_at = $taken_at, 
            taken_at_local = $taken_at_local,
            quality = 0,
            resolution = $width * $height,
            place_status = 'pending'
        ).id
    END;
    
    LET $is_new_photo = ($photo_id != $candidate);

    -- 3. File Layer
    LET $file_id = (CREATE file SET 
        uid = <string> rand::uuid(), 
        asset = $asset, 
        photo = $photo_id, 
        name = $filename, 
        path = $path, 
        origin = $origin, 
        is_primary = true, 
        is_sidecar = false
    ).id;

    -- 4. Structured Return
    RETURN {
        asset_id: $asset,
        file_id: $file_id,
        photo_id: $photo_id,
        is_new_photo: $is_new_photo
    };
};

-- -----------------------------------------------------------------------------
-- 5. EVENTS (System Nervous)
-- -----------------------------------------------------------------------------

-- Auto-update photo timestamp
DEFINE EVENT update_photo_timestamp ON TABLE photo WHEN $event = "UPDATE" THEN ( 
    UPDATE photo SET updated_at = time::now() WHERE id = $after.id
);

-- Orchestration des rendus binaire (Renditions)
DEFINE EVENT on_file_created ON TABLE file WHEN $event = "CREATE" THEN {
    IF $after.is_primary = true THEN
        -- Le cerveau résout tout ici (v3 guarded)
        LET $assets = (SELECT storage_key FROM asset WHERE id = $after.asset LIMIT 1);
        
        IF array::len($assets) > 0 THEN {
            LET $asset = $assets[0];
            CREATE scheduler::task SET 
                name = "lyxal.photo.render.renditions",
                payload = { 
                    file_id: $after.id, 
                    asset_storage_key: $asset.storage_key,
                    targets: [
                        { purpose: "thumb", format: "webp", size: 400 },
                        { purpose: "preview", format: "webp", size: 1200 },
                        { purpose: "web", format: "avif", size: 2000 }
                    ]
                },
                enabled = true,
                next_run = time::now(),
                max_retries = 3,
                attempts = 0,
                cron = "";
        };
    END
};

-- Orchestration de l'intelligence et du contexte (AI/Geo)
DEFINE EVENT on_photo_created ON TABLE photo WHEN $event = "CREATE" THEN {
    -- Étape 1 : Récupérer le fichier primaire
    LET $primaries = (SELECT id, asset FROM file WHERE photo = $after.id AND is_primary = true LIMIT 1);
    
    IF array::len($primaries) > 0 THEN {
        LET $primary = $primaries[0];
        -- Étape 2 : Récupérer les champs de l'Asset lié (FETCH v3 safe)
        LET $assets_data = (SELECT mime, storage_key FROM asset WHERE id = $primary.asset LIMIT 1);
        
        IF array::len($assets_data) > 0 THEN {
            LET $asset_data = $assets_data[0];
            
            -- Job Analyse IA
            CREATE scheduler::task SET 
                name = "lyxal.photo.ai.analyze",
                payload = { 
                    task_name: "lyxal.photo.ai.analyze",
                    photo_id: $after.id, 
                    primary_file_id: $primary.id,
                    asset_storage_key: $asset_data.storage_key,
                    image_mime: $asset_data.mime,
                    analysis_targets: { faces: true, labels: true, nsfw: true },
                    version: "v1"
                },
                enabled = true,
                next_run = time::now(),
                max_retries = 3,
                attempts = 0,
                cron = "";
        };
    };

    -- Job Résolution Géo
    IF $after.place_status = "pending" AND $after.latlng != NONE THEN
        CREATE scheduler::task SET 
            name = "lyxal.photo.geo.resolve",
            payload = { 
                task_name: "lyxal.photo.geo.resolve",
                photo_id: $after.id, 
                latlng: $after.latlng 
            },
            enabled = true,
            next_run = time::now(),
            max_retries = 3,
            attempts = 0,
            cron = "";
    END
};

-- 5. Complétion Géo : Handler idempotent
DEFINE EVENT on_geo_resolved ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.photo.geo.resolve" AND $after.result.status = "completed" THEN {
    LET $res = $after.result;
    
    -- Si une place a été trouvée
    IF $res.place != NONE THEN {
        LET $p = $res.place;

        -- UPSERT de la place (déduplication stricte par provider_id)
        UPSERT place SET 
            provider = $p.provider,
            provider_id = $p.provider_id,
            name = $p.name,
            label = $p.display_name,
            city = $p.city,
            state = $p.state,
            country = $p.country,
            country_code = $p.country_code,
            post_code = $p.postcode,
            road = $p.road,
            latlng = <point> [$p.lon, $p.lat]
        WHERE provider = $p.provider AND provider_id = $p.provider_id;

        -- Récupération de l'ID (v3 safe)
        LET $place_id = (SELECT id FROM place WHERE provider = $p.provider AND provider_id = $p.provider_id LIMIT 1)[0].id;

        -- Mise à jour de la photo
        UPDATE photo SET 
            place = $place_id,
            place_status = 'resolved'
        WHERE id = $res.photo_id;
    } ELSE {
        -- Échec de résolution (ou lieu inconnu)
        UPDATE photo SET place_status = 'failed' WHERE id = $res.photo_id;
    };
};

-- Complétion AI : Handler idempotent et filtré
DEFINE EVENT on_ai_task_completed ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.photo.ai.analyze" AND $after.result.status = "completed" THEN {
    LET $res = $after.result;

    -- A. Traitement IDEMPOTENT des Visages
    LET $existing_markers = (SELECT count() FROM marker 
                             WHERE file = $res.primary_file_id 
                               AND src = "ai" AND type = "face" GROUP ALL);
    
    LET $marker_count = IF array::len($existing_markers) > 0 THEN $existing_markers[0].count ELSE 0 END;

    IF $marker_count = 0 THEN {
        FOR $f IN $res.faces {
            LET $marker_id = (CREATE marker SET 
                uid = <string> rand::uuid(),
                file = $res.primary_file_id,
                type = "face",
                src = "ai",
                x = $f.x, y = $f.y, w = $f.w, h = $f.h,
                uncertainty = $f.uncertainty
            ).id;

            CREATE face SET 
                marker = $marker_id,
                embedding = $f.embedding_512,
                cluster_id = $f.cluster_hint;
        };
    };

    -- B. Traitement IDEMPOTENT des Labels
    FOR $l IN $res.labels {
        -- Upsert déterministe (v3 safe order)
        UPSERT label SET name = $l.name WHERE name = $l.name;
        LET $label_recs = (SELECT id FROM label WHERE name = $l.name LIMIT 1);

        IF array::len($label_recs) > 0 THEN {
            LET $label_id = $label_recs[0].id;

            -- Delete-then-Relate (v3 sub-select safe)
            DELETE (SELECT id FROM tagged_as WHERE in = $res.photo_id AND out = $label_id);
            
            RELATE $res.photo_id->tagged_as->$label_id SET 
                uncertainty = $l.uncertainty,
                nsfw = $l.nsfw;
        };
    };

    -- C. Mise à jour statut Photo
    UPDATE photo SET indexed_at = time::now() WHERE id = $res.photo_id;
};

-- Le cerveau traite le résultat du muscle (Rust) - RENDITIONS
DEFINE EVENT on_render_task_completed ON TABLE scheduler::history 
WHEN $after.result.type = "lyxal.photo.render.output" THEN {
    -- Pour chaque rendu réussi envoyé par le muscle, le cerveau écrit en table
    FOR $r IN $after.result.renditions {
        CREATE rendition SET 
            file = $after.result.file_id,
            purpose = $r.purpose,
            format = $r.format,
            width = $r.width,
            height = $r.height,
            storage_pointer = $r.storage_pointer,
            status = 'completed';
    };
};

-- -----------------------------------------------------------------------------
-- FACIAL CLUSTERING ORCHESTRATION (Phase 3.D.1)
-- -----------------------------------------------------------------------------

-- 1. Déclenchement automatique après Analyse IA
-- On réagit à la complétion de l'analyse IA si des visages ont été détectés
DEFINE EVENT on_cluster_needed ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.photo.ai.analyze" 
 AND $after.result.status = "completed" 
 AND array::len($after.result.faces) > 0 THEN {
    
    LET $res = $after.result;
    
    -- Récupération des IDs des faces créées pour cette photo
    LET $new_faces = (SELECT id, embedding FROM face 
                      WHERE marker.file = $res.primary_file_id 
                        AND cluster_id = NONE);

    IF array::len($new_faces) > 0 THEN {
        CREATE scheduler::task SET 
            name = "lyxal.photo.faces.cluster",
            payload = { 
                task_name: "lyxal.photo.faces.cluster",
                photo_id: $res.photo_id,
                primary_file_id: $res.primary_file_id,
                faces: $new_faces,
                metric: "cosine",
                threshold: 0.32,
                min_cluster: 1,
                version: "v1"
            },
            enabled = true,
            next_run = time::now(),
            max_retries = 3,
            attempts = 0,
            cron = "";
    };
};

-- 2. Complétion : Application des clusters
DEFINE EVENT on_cluster_completed ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.photo.faces.cluster" AND $after.result.status = "completed" THEN {
    LET $res = $after.result;

    FOR $c IN $res.clusters {
        -- Mise à jour idempotente : on n'écrase pas si déjà clusterisé
        UPDATE face SET cluster_id = $c.cluster_id 
        WHERE id = $c.face_id AND cluster_id = NONE;
    };
};

-- -----------------------------------------------------------------------------
-- VIDEO ORCHESTRATION (Brain Layer)
-- -----------------------------------------------------------------------------

-- 1. Déclenchement du Transcodage
DEFINE EVENT on_video_file_created ON TABLE file WHEN $event = "CREATE" THEN {
    -- Safety check: Primary file attached to a logical photo
    IF $after.is_primary = true AND $after.photo != NONE THEN {
        LET $assets = (SELECT mime, storage_key FROM asset WHERE id = $after.asset LIMIT 1);
        
        IF array::len($assets) > 0 THEN {
            LET $asset = $assets[0];
            
            -- Only for video assets
            IF string::contains($asset.mime, "video") THEN {
                CREATE scheduler::task SET 
                    name = "lyxal.video.render.transcode",
                    payload = { 
                        task_name: "lyxal.video.render.transcode", -- Mandatory for filtering
                        file_id: $after.id, 
                        asset_storage_key: $asset.storage_key,
                        targets: [
                            { purpose: "preview", format: "mp4", codec: "h264", height: 720 },
                            { purpose: "stream", format: "mp4", codec: "h265", height: 1080 },
                            { purpose: "storyboard", format: "jpeg", grid: "5x5" },
                            { purpose: "animated_thumb", format: "webp", duration: 3 }
                        ]
                    },
                    enabled = true,
                    next_run = time::now(),
                    max_retries = 3,
                    attempts = 0,
                    cron = "";
            };
        };
    };
};

-- 2. Déclenchement de l'IA Vidéo
DEFINE EVENT on_video_created_ai ON TABLE photo WHEN $event = "CREATE" AND type = "video" THEN {
    LET $primaries = (SELECT id, asset FROM file WHERE photo = $after.id AND is_primary = true LIMIT 1);
    
    IF array::len($primaries) > 0 THEN {
        LET $primary = $primaries[0];
        LET $assets_data = (SELECT mime, storage_key FROM asset WHERE id = $primary.asset LIMIT 1);
        
        IF array::len($assets_data) > 0 THEN {
            LET $asset_data = $assets_data[0];
            
            CREATE scheduler::task SET 
                name = "lyxal.video.ai.analyze",
                payload = { 
                    task_name: "lyxal.video.ai.analyze",
                    photo_id: $after.id, 
                    primary_file_id: $primary.id,
                    asset_storage_key: $asset_data.storage_key,
                    analysis_targets: { faces: true, labels: true, nsfw: true },
                    sampling_rate_sec: 1.0, 
                    version: "v1"
                },
                enabled = true,
                next_run = time::now(),
                max_retries = 3,
                attempts = 0,
                cron = "";
        };
    };
};

-- 3. Complétion Transcodage (Filtered + Idempotent)
DEFINE EVENT on_video_transcode_completed ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.video.render.transcode" AND $after.result.status = "completed" THEN {
    LET $res = $after.result;

    -- Clean old renditions for this file to ensure idempotence
    DELETE (SELECT id FROM rendition WHERE file = $res.file_id AND purpose IN ["preview", "stream", "storyboard", "animated_thumb"]);

    FOR $r IN $res.renditions {
        CREATE rendition SET 
            file = $res.file_id,
            purpose = $r.purpose,
            format = $r.format,
            width = $r.width,
            height = $r.height,
            storage_pointer = $r.storage_pointer,
            status = 'completed';
    };
};

-- 4. Complétion IA Vidéo (Markers Temporels)
DEFINE EVENT on_video_ai_completed ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.video.ai.analyze" AND $after.result.status = "completed" THEN {
    LET $res = $after.result;

    -- Idempotence: Check if video markers already exist
    LET $existing_markers = (SELECT count() FROM marker 
                             WHERE file = $res.primary_file_id 
                               AND src = "ai" AND type = "face" GROUP ALL);
    
    LET $marker_count = IF array::len($existing_markers) > 0 THEN $existing_markers[0].count ELSE 0 END;

    IF $marker_count = 0 THEN {
        FOR $f IN $res.faces {
            LET $marker_id = (CREATE marker SET 
                uid = <string> rand::uuid(),
                file = $res.primary_file_id,
                type = "face",
                src = "ai",
                x = $f.x, y = $f.y, w = $f.w, h = $f.h,
                start_ms = $f.timestamp_ms, 
                end_ms = $f.timestamp_ms + 500,
                uncertainty = $f.uncertainty
            ).id;

            CREATE face SET 
                marker = $marker_id,
                embedding = $f.embedding_512,
                cluster_id = $f.cluster_hint;
        };
    };
};

-- 5. Hook Clustering pour la Vidéo
DEFINE EVENT on_cluster_needed_video ON TABLE scheduler::history 
WHEN $after.result.task_name = "lyxal.video.ai.analyze" 
 AND $after.result.status = "completed" 
 AND array::len($after.result.faces) > 0 THEN {
    
    LET $res = $after.result;
    
    -- Récupération des IDs des faces créées
    LET $new_faces = (SELECT id, embedding FROM face 
                      WHERE marker.file = $res.primary_file_id 
                        AND cluster_id = NONE);

    IF array::len($new_faces) > 0 THEN {
        CREATE scheduler::task SET 
            name = "lyxal.photo.faces.cluster", -- Same cluster worker as photo
            payload = { 
                task_name: "lyxal.photo.faces.cluster",
                photo_id: $res.photo_id,
                primary_file_id: $res.primary_file_id,
                faces: $new_faces,
                metric: "cosine",
                threshold: 0.32,
                min_cluster: 1,
                version: "v1"
            },
            enabled = true,
            next_run = time::now(),
            max_retries = 3,
            attempts = 0,
            cron = "";
    };
};

-- -----------------------------------------------------------------------------
-- 6. RELATIONSHIPS (Graph)
-- -----------------------------------------------------------------------------

-- Photo AI Tagging
DEFINE TABLE tagged_as TYPE RELATION IN photo OUT label;
DEFINE FIELD uncertainty ON TABLE tagged_as TYPE float;
DEFINE FIELD nsfw        ON TABLE tagged_as TYPE float;

-- Photo Collections
DEFINE TABLE in_album TYPE RELATION IN photo OUT album;
DEFINE FIELD order  ON TABLE in_album TYPE int;
DEFINE FIELD hidden ON TABLE in_album TYPE bool DEFAULT false;

-- Biometric Identity
DEFINE TABLE identified_as TYPE RELATION IN face OUT person;

-- -----------------------------------------------------------------------------
-- 7. IDENTIFICATION PRIMITIVES (Phase 3.D.2 - Social Truth)
-- -----------------------------------------------------------------------------

-- A. List anonymous clusters (Candidates for identification)
DEFINE FUNCTION fn::photo::clusters_unidentified($limit: int) {
    -- Select clusters having NO faces identified yet
    RETURN SELECT 
        cluster_id, 
        count() AS face_count, 
        math::mode(marker.file.photo) AS sample_photo,
        math::mode(marker.file) AS sample_file
    FROM face 
    WHERE cluster_id != NONE 
      AND count(->identified_as) = 0
    GROUP BY cluster_id
    ORDER BY face_count DESC
    LIMIT $limit;
};

-- B. Create Identity (Determinisitc)
DEFINE FUNCTION fn::photo::person_create($name: string) {
    LET $person = (UPSERT person SET name = $name WHERE name = $name);
    RETURN $person[0];
};

-- C. Assign Cluster to Person (The Authority Act)
DEFINE FUNCTION fn::photo::cluster_assign($cluster_id: uuid, $person_id: record<person>) {
    -- 1. Get all faces in this cluster
    LET $faces = (SELECT id FROM face WHERE cluster_id = $cluster_id);
    
    -- 2. Create identity links
    FOR $face IN $faces {
        -- Clear previous identity (One face = One person rule)
        DELETE (SELECT id FROM identified_as WHERE in = $face.id);
        
        -- Create authoritative link
        RELATE $face.id->identified_as->$person_id SET 
            src = 'manual', 
            confidence = 1.0, 
            assigned_at = time::now();
    };

    RETURN {
        cluster: $cluster_id,
        person: $person_id,
        faces_updated: array::len($faces)
    };
};

-- -----------------------------------------------------------------------------
-- 8. SEARCH & DISCOVERY (Phase 5 - Logic Layer)
-- -----------------------------------------------------------------------------

-- A. Timeline (Sorted by capture date, with pagination)
DEFINE FUNCTION fn::photo::timeline($limit: int, $offset: int) {
    RETURN SELECT *, 
           (SELECT id, purpose, format, storage_pointer FROM rendition WHERE file.photo = $parent.id AND purpose = 'thumb' LIMIT 1)[0] AS thumb
    FROM photo 
    WHERE deleted_at = NONE 
    ORDER BY taken_at DESC 
    LIMIT $limit 
    START $offset;
};

-- B. Hybrid Search (Fulltext + Score)
DEFINE FUNCTION fn::photo::search($q: string, $limit: int) {
    RETURN SELECT *, 
           score() AS relevance,
           (SELECT id, purpose, format, storage_pointer FROM rendition WHERE file.photo = $parent.id AND purpose = 'thumb' LIMIT 1)[0] AS thumb
    FROM photo 
    WHERE (title @1@ $q OR caption @1@ $q) 
      AND deleted_at = NONE 
    ORDER BY relevance DESC 
    LIMIT $limit;
};

-- C. Nearby (Geospatial search)
DEFINE FUNCTION fn::photo::nearby($lon: float, $lat: float, $radius_km: float, $limit: int) {
    LET $point = (<point> [$lon, $lat]);
    RETURN SELECT *, 
           (SELECT id, purpose, format, storage_pointer FROM rendition WHERE file.photo = $parent.id AND purpose = 'thumb' LIMIT 1)[0] AS thumb
    FROM photo 
    WHERE latlng INSIDE geometry::buffer($point, $radius_km, 'km')
      AND deleted_at = NONE 
    ORDER BY taken_at DESC 
    LIMIT $limit;
};

-- D. Photos of a Person (Graph traversal)
DEFINE FUNCTION fn::photo::by_person($person_id: record<person>, $limit: int) {
    RETURN SELECT *,
           (SELECT id, purpose, format, storage_pointer FROM rendition WHERE file.photo = $parent.id AND purpose = 'thumb' LIMIT 1)[0] AS thumb
    FROM photo 
    WHERE id IN (
        SELECT VALUE marker.file.photo 
        FROM face 
        WHERE ->identified_as->person CONTAINS $person_id
    )
    AND deleted_at = NONE
    ORDER BY taken_at DESC
    LIMIT $limit;
};

-- -----------------------------------------------------------------------------
-- 9. TELEMETRY & OBSERVABILITY (Phase M8)
-- -----------------------------------------------------------------------------

-- A. Task Execution Log (Raw history of muscles)
DEFINE TABLE telemetry_task_run SCHEMAFULL;
DEFINE FIELD task_name    ON TABLE telemetry_task_run TYPE string;
DEFINE FIELD status       ON TABLE telemetry_task_run TYPE string ASSERT $value IN ['completed', 'failed', 'skipped'];
DEFINE FIELD duration_ms  ON TABLE telemetry_task_run TYPE int;
DEFINE FIELD photo_id     ON TABLE telemetry_task_run TYPE option<record<photo>>;
DEFINE FIELD file_id      ON TABLE telemetry_task_run TYPE option<record<file>>;
DEFINE FIELD created_at   ON TABLE telemetry_task_run TYPE datetime DEFAULT time::now();
DEFINE FIELD error        ON TABLE telemetry_task_run TYPE option<string>;
DEFINE FIELD metrics      ON TABLE telemetry_task_run TYPE object; -- Flexible metrics bag

-- Index for quick analysis
DEFINE INDEX task_run_time_idx ON TABLE telemetry_task_run COLUMNS created_at;
DEFINE INDEX task_run_name_idx ON TABLE telemetry_task_run COLUMNS task_name;
DEFINE INDEX task_run_status_idx ON TABLE telemetry_task_run COLUMNS status;

-- B. Daily Aggregates (Fast dashboarding)
DEFINE TABLE telemetry_daily SCHEMAFULL;
DEFINE FIELD date            ON TABLE telemetry_daily TYPE string; -- YYYY-MM-DD
DEFINE FIELD task_name       ON TABLE telemetry_daily TYPE string;
DEFINE FIELD ok_count        ON TABLE telemetry_daily TYPE int DEFAULT 0;
DEFINE FIELD fail_count      ON TABLE telemetry_daily TYPE int DEFAULT 0;
DEFINE FIELD total_duration  ON TABLE telemetry_daily TYPE int DEFAULT 0;
DEFINE FIELD bytes_in        ON TABLE telemetry_daily TYPE int DEFAULT 0;
DEFINE FIELD bytes_out       ON TABLE telemetry_daily TYPE int DEFAULT 0;

DEFINE INDEX daily_uq ON TABLE telemetry_daily COLUMNS date, task_name UNIQUE;

-- C. Automatic Telemetry Handler (Listens to scheduler history)
-- This event populates telemetry tables automatically when a worker finishes
DEFINE EVENT on_task_finished_telemetry ON TABLE scheduler::history 
WHEN $event = "CREATE" THEN {
    LET $res = $after.result;
    LET $meta = $after; -- scheduler metadata
    
    -- 1. Log Run
    CREATE telemetry_task_run SET
        task_name = $res.task_name,
        status = $res.status,
        duration_ms = $res.duration_ms,
        photo_id = $res.photo_id,
        file_id = $res.file_id, -- or primary_file_id
        error = $res.error,
        metrics = {
            bytes_in: $res.bytes_in OR 0,
            bytes_out: $res.bytes_out OR 0,
            items_processed: $res.frames_processed OR array::len($res.renditions) OR array::len($res.faces) OR 0
        };

    -- 2. Update Daily Aggregates
    LET $today = time::format(time::now(), "%Y-%m-%d");
    
    UPSERT telemetry_daily SET
        date = $today,
        task_name = $res.task_name
    WHERE date = $today AND task_name = $res.task_name;

    UPDATE telemetry_daily SET
        ok_count += IF $res.status = 'completed' THEN 1 ELSE 0 END,
        fail_count += IF $res.status = 'failed' THEN 1 ELSE 0 END,
        total_duration += $res.duration_ms,
        bytes_in += ($res.bytes_in OR 0),
        bytes_out += ($res.bytes_out OR 0)
    WHERE date = $today AND task_name = $res.task_name;
};

-- -----------------------------------------------------------------------------
-- 10. HEALTH & AUDIT (Phase M8.3)
-- -----------------------------------------------------------------------------

-- A. Global Health Dashboard
-- Returns the vital signs of the engine
DEFINE FUNCTION fn::photo::health_summary() {
    LET $today = time::format(time::now(), "%Y-%m-%d");
    
    -- 1. Scheduler Backlog
    LET $queue_depth = (SELECT count() FROM scheduler::task WHERE status = 'pending' GROUP ALL)[0].count OR 0;
    LET $active_jobs = (SELECT count() FROM scheduler::task WHERE status = 'running' GROUP ALL)[0].count OR 0;
    LET $failed_jobs = (SELECT count() FROM scheduler::task WHERE status = 'failed' GROUP ALL)[0].count OR 0;

    -- 2. Daily Metrics (from Telemetry)
    LET $daily_stats = (SELECT * FROM telemetry_daily WHERE date = $today);
    
    -- 3. Storage Usage (Estimated)
    LET $bytes_processed = (SELECT math::sum(bytes_in) AS total_in, math::sum(bytes_out) AS total_out FROM telemetry_daily WHERE date = $today GROUP ALL)[0];

    RETURN {
        status: IF $failed_jobs > 10 THEN 'degraded' ELSE 'healthy' END,
        queue: {
            pending: $queue_depth,
            running: $active_jobs,
            failed: $failed_jobs
        },
        activity_today: $daily_stats,
        throughput: {
            bytes_in: $bytes_processed.total_in OR 0,
            bytes_out: $bytes_processed.total_out OR 0
        },
        timestamp: time::now()
    };
};

-- B. Detect Stuck Pipelines
-- Finds photos that are stuck in ingestion or processing
DEFINE FUNCTION fn::photo::stuck_items($limit: int) {
    -- 1. Photos pending indexing for too long (> 5 min)
    LET $stuck_indexing = (
        SELECT id, created_at, place_status 
        FROM photo 
        WHERE indexed_at = NONE 
          AND created_at < time::now() - 5m
        LIMIT $limit
    );

    -- 2. Failed Tasks recently
    LET $failed_tasks = (
        SELECT id, name, payload.photo_id AS photo_id, error 
        FROM scheduler::task 
        WHERE status = 'failed' 
        ORDER BY next_run DESC
        LIMIT $limit
    );

    RETURN {
        stuck_indexing: $stuck_indexing,
        failed_tasks: $failed_tasks
    };
};

-- C. Deep Integrity Audit (Single Item)
-- Checks if a photo is technically valid and complete
DEFINE FUNCTION fn::photo::integrity_audit($photo_id: record<photo>) {
    LET $photo = (SELECT * FROM $photo_id);
    
    -- 1. Check Files
    LET $files = (SELECT * FROM file WHERE photo = $photo_id);
    LET $primary = (SELECT * FROM $files WHERE is_primary = true);
    
    -- 2. Check Renditions
    LET $renditions = (SELECT purpose, format, width, height, status FROM rendition WHERE file.photo = $photo_id);
    LET $has_thumb = array::len(SELECT * FROM $renditions WHERE purpose = 'thumb') > 0;
    LET $has_preview = array::len(SELECT * FROM $renditions WHERE purpose = 'preview') > 0;

    -- 3. Check AI/Metadata
    LET $faces = (SELECT count() FROM face WHERE marker.file.photo = $photo_id GROUP ALL)[0].count OR 0;
    LET $labels = (SELECT count() FROM tagged_as WHERE in = $photo_id GROUP ALL)[0].count OR 0;
    
    -- 4. Verdict
    LET $is_valid = (
        array::len($primary) > 0 AND 
        $has_thumb AND 
        $has_preview
    );

    RETURN {
        photo: $photo,
        files_count: array::len($files),
        has_primary: array::len($primary) > 0,
        renditions_status: {
            total: array::len($renditions),
            has_thumb: $has_thumb,
            has_preview: $has_preview
        },
        ai_status: {
            faces_detected: $faces,
            labels_attached: $labels,
            is_indexed: $photo.indexed_at != NONE
        },
        geo_status: $photo.place_status,
        integrity_pass: $is_valid
    };
};
