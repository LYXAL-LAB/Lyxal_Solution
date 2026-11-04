-- ============================================================================
-- MASTER DATA : définitions d'erreurs du module lyxal_runtime
-- Rejouable : chaque définition est créée seulement si elle n'existe pas.
-- Les codes émis par le Rust (RuntimeError) sont vérifiés contre ce fichier par un test
-- (src/error/catalog.rs) ; RUNTIME_INVALID_PARAMETERS et RUNTIME_RELEASE_NOT_FOUND sont émis
-- par les fonctions fn::runtime_*.
-- ============================================================================

IF !record::exists(error_definition:RUNTIME_DUPLICATE_MODULE) THEN (
    CREATE error_definition:RUNTIME_DUPLICATE_MODULE CONTENT {
        code: "RUNTIME_DUPLICATE_MODULE",
        module: "runtime",
        domain: "registry",
        category: "conflict",
        severity: "error",
        message: "Module is already registered in the runtime",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Module déjà enregistré",
                description: "Un module portant cet identifiant est déjà enregistré dans le registre du runtime.",
                resolution: "Enregistrer chaque module une seule fois."
            },
            en: {
                label: "Module already registered",
                description: "Module is already registered in the runtime.",
                resolution: "Register each module only once."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_UNKNOWN_MODULE) THEN (
    CREATE error_definition:RUNTIME_UNKNOWN_MODULE CONTENT {
        code: "RUNTIME_UNKNOWN_MODULE",
        module: "runtime",
        domain: "registry",
        category: "not_found",
        severity: "error",
        message: "Module is not registered in the runtime",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Module inconnu",
                description: "Aucun module portant cet identifiant n'est enregistré dans le registre du runtime.",
                resolution: "Enregistrer le module avant de l'utiliser."
            },
            en: {
                label: "Unknown module",
                description: "Module is not registered in the runtime.",
                resolution: "Register the module before using it."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MISSING_DEPENDENCY) THEN (
    CREATE error_definition:RUNTIME_MISSING_DEPENDENCY CONTENT {
        code: "RUNTIME_MISSING_DEPENDENCY",
        module: "runtime",
        domain: "dependencies",
        category: "validation",
        severity: "error",
        message: "A required module dependency is not registered",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dépendance manquante",
                description: "Le module déclare une dépendance qui n'est pas enregistrée dans le runtime.",
                resolution: "Enregistrer ou installer la dépendance déclarée."
            },
            en: {
                label: "Missing dependency",
                description: "A required module dependency is not registered.",
                resolution: "Register or install the declared dependency."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_DEPENDENCY_CYCLE) THEN (
    CREATE error_definition:RUNTIME_DEPENDENCY_CYCLE CONTENT {
        code: "RUNTIME_DEPENDENCY_CYCLE",
        module: "runtime",
        domain: "dependencies",
        category: "validation",
        severity: "error",
        message: "Module dependencies form a cycle",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Cycle de dépendances",
                description: "Les dépendances déclarées entre modules forment un cycle.",
                resolution: "Supprimer la dépendance qui ferme le cycle."
            },
            en: {
                label: "Dependency cycle",
                description: "Module dependencies form a cycle.",
                resolution: "Remove the dependency that closes the cycle."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_STATE_TRANSITION) THEN (
    CREATE error_definition:RUNTIME_INVALID_STATE_TRANSITION CONTENT {
        code: "RUNTIME_INVALID_STATE_TRANSITION",
        module: "runtime",
        domain: "lifecycle",
        category: "conflict",
        severity: "error",
        message: "Module state transition is not allowed",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Transition d'état invalide",
                description: "Le module ne peut pas passer de son état actuel à l'état demandé.",
                resolution: "Vérifier l'état du module avant l'opération."
            },
            en: {
                label: "Invalid state transition",
                description: "Module state transition is not allowed.",
                resolution: "Check the module state before the operation."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INSTALL_FAILURE) THEN (
    CREATE error_definition:RUNTIME_INSTALL_FAILURE CONTENT {
        code: "RUNTIME_INSTALL_FAILURE",
        module: "runtime",
        domain: "lifecycle",
        category: "internal",
        severity: "error",
        message: "Module install hook failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec du hook d'installation",
                description: "Le hook install du module a renvoyé une erreur.",
                resolution: "Consulter le détail de l'erreur du module."
            },
            en: {
                label: "Install hook failed",
                description: "Module install hook failed.",
                resolution: "Check the module error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_START_FAILURE) THEN (
    CREATE error_definition:RUNTIME_START_FAILURE CONTENT {
        code: "RUNTIME_START_FAILURE",
        module: "runtime",
        domain: "lifecycle",
        category: "internal",
        severity: "error",
        message: "Module start hook failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec du démarrage du module",
                description: "Le hook start du module a renvoyé une erreur.",
                resolution: "Consulter le détail de l'erreur du module."
            },
            en: {
                label: "Module start failed",
                description: "Module start hook failed.",
                resolution: "Check the module error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_STOP_FAILURE) THEN (
    CREATE error_definition:RUNTIME_STOP_FAILURE CONTENT {
        code: "RUNTIME_STOP_FAILURE",
        module: "runtime",
        domain: "lifecycle",
        category: "internal",
        severity: "error",
        message: "Module stop hook failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec de l'arrêt du module",
                description: "Le hook stop du module a renvoyé une erreur.",
                resolution: "Consulter le détail de l'erreur du module."
            },
            en: {
                label: "Module stop failed",
                description: "Module stop hook failed.",
                resolution: "Check the module error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_OPERATION_TIMEOUT) THEN (
    CREATE error_definition:RUNTIME_OPERATION_TIMEOUT CONTENT {
        code: "RUNTIME_OPERATION_TIMEOUT",
        module: "runtime",
        domain: "lifecycle",
        category: "timeout",
        severity: "error",
        message: "Module operation timed out",
        default_language: "fr",
        http_status: 504,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Délai dépassé",
                description: "Une opération du cycle de vie du module a dépassé son délai.",
                resolution: "Réessayer ; si l'échec persiste, analyser la lenteur du module."
            },
            en: {
                label: "Operation timed out",
                description: "Module operation timed out.",
                resolution: "Retry; if it persists, investigate the module latency."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_MANIFEST) THEN (
    CREATE error_definition:RUNTIME_INVALID_MANIFEST CONTENT {
        code: "RUNTIME_INVALID_MANIFEST",
        module: "runtime",
        domain: "manifest",
        category: "validation",
        severity: "error",
        message: "Module manifest is invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Manifeste invalide",
                description: "Le manifeste du module ne respecte pas le contrat du runtime.",
                resolution: "Corriger manifest.toml selon le détail de validation."
            },
            en: {
                label: "Invalid manifest",
                description: "Module manifest is invalid.",
                resolution: "Fix manifest.toml according to the validation detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_UNSUPPORTED_MANIFEST_VERSION) THEN (
    CREATE error_definition:RUNTIME_UNSUPPORTED_MANIFEST_VERSION CONTENT {
        code: "RUNTIME_UNSUPPORTED_MANIFEST_VERSION",
        module: "runtime",
        domain: "manifest",
        category: "validation",
        severity: "error",
        message: "Manifest version is not supported",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version de manifeste non supportée",
                description: "La version du format de manifeste dépasse celle prise en charge par le runtime.",
                resolution: "Utiliser une version de manifeste prise en charge."
            },
            en: {
                label: "Unsupported manifest version",
                description: "Manifest version is not supported.",
                resolution: "Use a supported manifest version."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_MODULE_VERSION) THEN (
    CREATE error_definition:RUNTIME_INVALID_MODULE_VERSION CONTENT {
        code: "RUNTIME_INVALID_MODULE_VERSION",
        module: "runtime",
        domain: "manifest",
        category: "validation",
        severity: "error",
        message: "Module version is not a valid semantic version",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version de module invalide",
                description: "La version du module n'est pas une version sémantique valide.",
                resolution: "Déclarer une version au format MAJEUR.MINEUR.CORRECTIF."
            },
            en: {
                label: "Invalid module version",
                description: "Module version is not a valid semantic version.",
                resolution: "Declare a MAJOR.MINOR.PATCH version."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_SELF_DEPENDENCY) THEN (
    CREATE error_definition:RUNTIME_SELF_DEPENDENCY CONTENT {
        code: "RUNTIME_SELF_DEPENDENCY",
        module: "runtime",
        domain: "manifest",
        category: "validation",
        severity: "error",
        message: "Module declares a dependency on itself",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dépendance à soi-même",
                description: "Le manifeste déclare le module comme sa propre dépendance.",
                resolution: "Retirer cette dépendance du manifeste."
            },
            en: {
                label: "Self dependency",
                description: "Module declares a dependency on itself.",
                resolution: "Remove this dependency from the manifest."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_DUPLICATE_DEPENDENCY) THEN (
    CREATE error_definition:RUNTIME_DUPLICATE_DEPENDENCY CONTENT {
        code: "RUNTIME_DUPLICATE_DEPENDENCY",
        module: "runtime",
        domain: "manifest",
        category: "validation",
        severity: "error",
        message: "Manifest declares the same dependency more than once",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Dépendance en double",
                description: "Le manifeste déclare plusieurs fois la même dépendance.",
                resolution: "Ne déclarer chaque dépendance qu'une fois."
            },
            en: {
                label: "Duplicate dependency",
                description: "Manifest declares the same dependency more than once.",
                resolution: "Declare each dependency only once."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MANIFEST_PARSE_ERROR) THEN (
    CREATE error_definition:RUNTIME_MANIFEST_PARSE_ERROR CONTENT {
        code: "RUNTIME_MANIFEST_PARSE_ERROR",
        module: "runtime",
        domain: "manifest",
        category: "validation",
        severity: "error",
        message: "Manifest could not be parsed",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Manifeste illisible",
                description: "Le fichier manifest.toml n'a pas pu être lu ou contient une clé inconnue.",
                resolution: "Corriger la syntaxe TOML ou retirer la clé inconnue."
            },
            en: {
                label: "Unreadable manifest",
                description: "Manifest could not be parsed.",
                resolution: "Fix the TOML syntax or remove the unknown key."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_MIGRATION_ID) THEN (
    CREATE error_definition:RUNTIME_INVALID_MIGRATION_ID CONTENT {
        code: "RUNTIME_INVALID_MIGRATION_ID",
        module: "runtime",
        domain: "migration",
        category: "validation",
        severity: "error",
        message: "Migration identifier is invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiant de migration invalide",
                description: "L'identifiant de migration ne respecte pas le format attendu.",
                resolution: "Nommer la migration selon la convention (ex. 0001_initial)."
            },
            en: {
                label: "Invalid migration identifier",
                description: "Migration identifier is invalid.",
                resolution: "Name the migration by the convention (e.g. 0001_initial)."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_CHECKSUM) THEN (
    CREATE error_definition:RUNTIME_INVALID_CHECKSUM CONTENT {
        code: "RUNTIME_INVALID_CHECKSUM",
        module: "runtime",
        domain: "migration",
        category: "validation",
        severity: "error",
        message: "Migration checksum is invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Empreinte de migration invalide",
                description: "L'empreinte d'une migration n'est pas une empreinte SHA-256 hexadécimale valide.",
                resolution: "Recalculer l'empreinte à partir du fichier de migration."
            },
            en: {
                label: "Invalid migration checksum",
                description: "Migration checksum is invalid.",
                resolution: "Recompute the checksum from the migration file."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RESOURCE_NOT_FOUND) THEN (
    CREATE error_definition:RUNTIME_RESOURCE_NOT_FOUND CONTENT {
        code: "RUNTIME_RESOURCE_NOT_FOUND",
        module: "runtime",
        domain: "resource",
        category: "not_found",
        severity: "error",
        message: "Module resource was not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Ressource introuvable",
                description: "Un fichier déclaré par le manifeste est introuvable.",
                resolution: "Vérifier le chemin déclaré dans [resources]."
            },
            en: {
                label: "Resource not found",
                description: "Module resource was not found.",
                resolution: "Check the path declared in [resources]."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RESOURCE_INVALID_PATH) THEN (
    CREATE error_definition:RUNTIME_RESOURCE_INVALID_PATH CONTENT {
        code: "RUNTIME_RESOURCE_INVALID_PATH",
        module: "runtime",
        domain: "resource",
        category: "validation",
        severity: "error",
        message: "Resource path is invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Chemin de ressource invalide",
                description: "Le chemin d'une ressource est absolu, sort du module ou contient un segment interdit.",
                resolution: "Déclarer un chemin relatif à la racine du module."
            },
            en: {
                label: "Invalid resource path",
                description: "Resource path is invalid.",
                resolution: "Declare a path relative to the module root."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RESOURCE_TOO_LARGE) THEN (
    CREATE error_definition:RUNTIME_RESOURCE_TOO_LARGE CONTENT {
        code: "RUNTIME_RESOURCE_TOO_LARGE",
        module: "runtime",
        domain: "resource",
        category: "validation",
        severity: "error",
        message: "Resource exceeds the maximum allowed size",
        default_language: "fr",
        http_status: 413,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Ressource trop volumineuse",
                description: "Un fichier de ressource dépasse la taille maximale autorisée.",
                resolution: "Découper la ressource en plusieurs fichiers."
            },
            en: {
                label: "Resource too large",
                description: "Resource exceeds the maximum allowed size.",
                resolution: "Split the resource into several files."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RESOURCE_ENCODING_ERROR) THEN (
    CREATE error_definition:RUNTIME_RESOURCE_ENCODING_ERROR CONTENT {
        code: "RUNTIME_RESOURCE_ENCODING_ERROR",
        module: "runtime",
        domain: "resource",
        category: "validation",
        severity: "error",
        message: "Resource is not valid UTF-8",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Encodage de ressource invalide",
                description: "Un fichier de ressource n'est pas encodé en UTF-8 valide.",
                resolution: "Réenregistrer le fichier en UTF-8."
            },
            en: {
                label: "Invalid resource encoding",
                description: "Resource is not valid UTF-8.",
                resolution: "Save the file as UTF-8."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RESOURCE_READ_FAILED) THEN (
    CREATE error_definition:RUNTIME_RESOURCE_READ_FAILED CONTENT {
        code: "RUNTIME_RESOURCE_READ_FAILED",
        module: "runtime",
        domain: "resource",
        category: "internal",
        severity: "error",
        message: "Resource could not be read",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Lecture de ressource impossible",
                description: "Le système de fichiers a refusé la lecture d'une ressource.",
                resolution: "Vérifier les droits d'accès au fichier."
            },
            en: {
                label: "Resource read failed",
                description: "Resource could not be read.",
                resolution: "Check the file access rights."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_SCHEMA_IMPORT_FAILED) THEN (
    CREATE error_definition:RUNTIME_SCHEMA_IMPORT_FAILED CONTENT {
        code: "RUNTIME_SCHEMA_IMPORT_FAILED",
        module: "runtime",
        domain: "installation",
        category: "internal",
        severity: "error",
        message: "SurrealQL resource could not be imported",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Import SurrealQL en échec",
                description: "SurrealDB a refusé une ressource SurrealQL du module pendant l'installation.",
                resolution: "Corriger la ressource indiquée dans le détail."
            },
            en: {
                label: "Schema import failed",
                description: "SurrealQL resource could not be imported.",
                resolution: "Fix the resource named in the detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_CHECKSUM_MISMATCH) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_CHECKSUM_MISMATCH CONTENT {
        code: "RUNTIME_MIGRATION_CHECKSUM_MISMATCH",
        module: "runtime",
        domain: "migration",
        category: "conflict",
        severity: "error",
        message: "Applied migration was modified",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Migration appliquée modifiée",
                description: "Le contenu d'une migration déjà appliquée ne correspond plus à son empreinte enregistrée.",
                resolution: "En pré-production, recréer la base ; sinon ne jamais modifier une migration appliquée."
            },
            en: {
                label: "Applied migration modified",
                description: "Applied migration was modified.",
                resolution: "Before production, recreate the database; otherwise never modify an applied migration."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_INTERRUPTED) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_INTERRUPTED CONTENT {
        code: "RUNTIME_MIGRATION_INTERRUPTED",
        module: "runtime",
        domain: "migration",
        category: "conflict",
        severity: "error",
        message: "A previous run left the migration in Applying state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Migration interrompue",
                description: "Une exécution précédente a laissé la migration dans l'état Applying.",
                resolution: "Vérifier l'état de la base puis relancer selon la politique de reprise."
            },
            en: {
                label: "Interrupted migration",
                description: "A previous run left the migration in Applying state.",
                resolution: "Check the database state, then rerun according to the recovery policy."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_EXECUTION_FAILED) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_EXECUTION_FAILED CONTENT {
        code: "RUNTIME_MIGRATION_EXECUTION_FAILED",
        module: "runtime",
        domain: "migration",
        category: "internal",
        severity: "error",
        message: "Migration execution failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec d'exécution de migration",
                description: "SurrealDB a refusé une instruction de la migration.",
                resolution: "Corriger la migration selon le détail de l'erreur."
            },
            en: {
                label: "Migration execution failed",
                description: "Migration execution failed.",
                resolution: "Fix the migration according to the error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_LOCK_ACQUIRE_FAILED) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_LOCK_ACQUIRE_FAILED CONTENT {
        code: "RUNTIME_MIGRATION_LOCK_ACQUIRE_FAILED",
        module: "runtime",
        domain: "lease",
        category: "dependency",
        severity: "error",
        message: "Migration lease could not be acquired",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Prise du bail de migration impossible",
                description: "L'appel de prise du bail de migration a échoué.",
                resolution: "Vérifier la disponibilité de SurrealDB puis réessayer."
            },
            en: {
                label: "Migration lease acquisition failed",
                description: "Migration lease could not be acquired.",
                resolution: "Check SurrealDB availability, then retry."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_LOCK_TIMEOUT) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_LOCK_TIMEOUT CONTENT {
        code: "RUNTIME_MIGRATION_LOCK_TIMEOUT",
        module: "runtime",
        domain: "lease",
        category: "timeout",
        severity: "error",
        message: "Timed out waiting for the migration lease",
        default_language: "fr",
        http_status: 504,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Attente du bail de migration dépassée",
                description: "Un autre nœud a détenu le bail de migration au-delà du délai d'attente.",
                resolution: "Réessayer une fois la migration de l'autre nœud terminée."
            },
            en: {
                label: "Migration lease wait timed out",
                description: "Timed out waiting for the migration lease.",
                resolution: "Retry once the other node's migration has finished."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_LEASE_LOST) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_LEASE_LOST CONTENT {
        code: "RUNTIME_MIGRATION_LEASE_LOST",
        module: "runtime",
        domain: "lease",
        category: "conflict",
        severity: "error",
        message: "Migration lease was lost",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Bail de migration perdu",
                description: "Le bail de migration a expiré, a été libéré ou a été repris par un autre nœud.",
                resolution: "Relancer l'installation ; le nœud détenteur termine la migration."
            },
            en: {
                label: "Migration lease lost",
                description: "Migration lease was lost.",
                resolution: "Rerun the installation; the holding node finishes the migration."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_LEASE_FENCED) THEN (
    CREATE error_definition:RUNTIME_LEASE_FENCED CONTENT {
        code: "RUNTIME_LEASE_FENCED",
        module: "runtime",
        domain: "lease",
        category: "conflict",
        severity: "error",
        message: "Write refused: the lease is no longer held by this node",
        default_language: "fr",
        http_status: 412,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Écriture refusée : bail perdu",
                description: "La base a refusé une écriture faite sous un bail que ce nœud ne détient plus dans la même génération.",
                resolution: "Aucune action : le nœud qui détient le bail poursuit l'opération."
            },
            en: {
                label: "Write refused: lease lost",
                description: "Write refused: the lease is no longer held by this node.",
                resolution: "No action: the node holding the lease carries on."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_LOCK_NOT_OWNER) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_LOCK_NOT_OWNER CONTENT {
        code: "RUNTIME_MIGRATION_LOCK_NOT_OWNER",
        module: "runtime",
        domain: "lease",
        category: "conflict",
        severity: "error",
        message: "Node does not own the migration lease",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Bail de migration non détenu",
                description: "Le nœud tente de libérer un bail de migration qu'il ne détient plus.",
                resolution: "Aucune action : le bail expirera ou a déjà été repris."
            },
            en: {
                label: "Migration lease not owned",
                description: "Node does not own the migration lease.",
                resolution: "No action: the lease will expire or was already taken over."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MIGRATION_RECOVERY_REQUIRED) THEN (
    CREATE error_definition:RUNTIME_MIGRATION_RECOVERY_REQUIRED CONTENT {
        code: "RUNTIME_MIGRATION_RECOVERY_REQUIRED",
        module: "runtime",
        domain: "migration",
        category: "conflict",
        severity: "error",
        message: "Interrupted migration requires manual recovery",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Reprise manuelle requise",
                description: "Une migration interrompue doit être vérifiée avant d'être rejouée.",
                resolution: "Vérifier l'état de la base, puis corriger l'enregistrement de la migration."
            },
            en: {
                label: "Manual recovery required",
                description: "Interrupted migration requires manual recovery.",
                resolution: "Check the database state, then fix the migration record."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MODULE_IMPLEMENTATION_MISSING) THEN (
    CREATE error_definition:RUNTIME_MODULE_IMPLEMENTATION_MISSING CONTENT {
        code: "RUNTIME_MODULE_IMPLEMENTATION_MISSING",
        module: "runtime",
        domain: "installation",
        category: "validation",
        severity: "error",
        message: "Package has no LyxalModule implementation",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Implémentation de module manquante",
                description: "Le package installé ne fournit pas d'implémentation LyxalModule.",
                resolution: "Joindre l'implémentation du module au package."
            },
            en: {
                label: "Module implementation missing",
                description: "Package has no LyxalModule implementation.",
                resolution: "Attach the module implementation to the package."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_VERSION_INCOMPATIBLE) THEN (
    CREATE error_definition:RUNTIME_VERSION_INCOMPATIBLE CONTENT {
        code: "RUNTIME_VERSION_INCOMPATIBLE",
        module: "runtime",
        domain: "dependencies",
        category: "validation",
        severity: "error",
        message: "Module requires another runtime version",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version du runtime incompatible",
                description: "Le module exige une version du runtime que ce nœud ne fournit pas.",
                resolution: "Mettre à jour le runtime ou la contrainte du module."
            },
            en: {
                label: "Incompatible runtime version",
                description: "Module requires another runtime version.",
                resolution: "Update the runtime or the module constraint."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_DEPENDENCY_VERSION_INCOMPATIBLE) THEN (
    CREATE error_definition:RUNTIME_DEPENDENCY_VERSION_INCOMPATIBLE CONTENT {
        code: "RUNTIME_DEPENDENCY_VERSION_INCOMPATIBLE",
        module: "runtime",
        domain: "dependencies",
        category: "validation",
        severity: "error",
        message: "Dependency version does not satisfy the constraint",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Version de dépendance incompatible",
                description: "La version installée d'une dépendance ne satisfait pas la contrainte du manifeste.",
                resolution: "Installer une version compatible de la dépendance."
            },
            en: {
                label: "Incompatible dependency version",
                description: "Dependency version does not satisfy the constraint.",
                resolution: "Install a compatible version of the dependency."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_BATCH_DUPLICATE_MODULE) THEN (
    CREATE error_definition:RUNTIME_BATCH_DUPLICATE_MODULE CONTENT {
        code: "RUNTIME_BATCH_DUPLICATE_MODULE",
        module: "runtime",
        domain: "installation",
        category: "validation",
        severity: "error",
        message: "Batch contains conflicting versions of a module",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Module en double dans le lot",
                description: "Le lot d'installation contient plusieurs versions du même module.",
                resolution: "Ne garder qu'une version par module dans le lot."
            },
            en: {
                label: "Duplicate module in batch",
                description: "Batch contains conflicting versions of a module.",
                resolution: "Keep a single version per module in the batch."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_PACKAGE_MISSING) THEN (
    CREATE error_definition:RUNTIME_PACKAGE_MISSING CONTENT {
        code: "RUNTIME_PACKAGE_MISSING",
        module: "runtime",
        domain: "installation",
        category: "validation",
        severity: "error",
        message: "Package to install was not provided",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Package absent",
                description: "Le package d'un module à installer n'a pas été fourni.",
                resolution: "Fournir le package du module dans le lot ou l'état désiré."
            },
            en: {
                label: "Package missing",
                description: "Package to install was not provided.",
                resolution: "Provide the module package in the batch or desired state."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_MODULE_INSTALL_FAILED) THEN (
    CREATE error_definition:RUNTIME_MODULE_INSTALL_FAILED CONTENT {
        code: "RUNTIME_MODULE_INSTALL_FAILED",
        module: "runtime",
        domain: "installation",
        category: "internal",
        severity: "error",
        message: "Module installation failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec d'installation du module",
                description: "L'installation du module a échoué à la phase indiquée.",
                resolution: "Corriger la cause indiquée puis relancer l'installation."
            },
            en: {
                label: "Module installation failed",
                description: "Module installation failed.",
                resolution: "Fix the reported cause, then rerun the installation."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INSTALLATION_LEASE_ACQUIRE_FAILED) THEN (
    CREATE error_definition:RUNTIME_INSTALLATION_LEASE_ACQUIRE_FAILED CONTENT {
        code: "RUNTIME_INSTALLATION_LEASE_ACQUIRE_FAILED",
        module: "runtime",
        domain: "lease",
        category: "dependency",
        severity: "error",
        message: "Installation lease operation failed",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Bail d'installation en échec",
                description: "La prise, le renouvellement ou la libération du bail d'installation a échoué.",
                resolution: "Vérifier la disponibilité de SurrealDB puis réessayer."
            },
            en: {
                label: "Installation lease failed",
                description: "Installation lease operation failed.",
                resolution: "Check SurrealDB availability, then retry."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INSTALLATION_LEASE_TIMEOUT) THEN (
    CREATE error_definition:RUNTIME_INSTALLATION_LEASE_TIMEOUT CONTENT {
        code: "RUNTIME_INSTALLATION_LEASE_TIMEOUT",
        module: "runtime",
        domain: "lease",
        category: "timeout",
        severity: "error",
        message: "Timed out waiting for the installation lease",
        default_language: "fr",
        http_status: 504,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Attente du bail d'installation dépassée",
                description: "Un autre nœud a détenu le bail d'installation au-delà du délai d'attente.",
                resolution: "Réessayer une fois l'installation de l'autre nœud terminée."
            },
            en: {
                label: "Installation lease wait timed out",
                description: "Timed out waiting for the installation lease.",
                resolution: "Retry once the other node's installation has finished."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_DESIRED_STATE_CONFLICT) THEN (
    CREATE error_definition:RUNTIME_DESIRED_STATE_CONFLICT CONTENT {
        code: "RUNTIME_DESIRED_STATE_CONFLICT",
        module: "runtime",
        domain: "reconciliation",
        category: "conflict",
        severity: "error",
        message: "Desired state conflicts with the installed state",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Conflit d'état désiré",
                description: "L'état désiré du runtime est incompatible avec l'état installé.",
                resolution: "Corriger l'état désiré."
            },
            en: {
                label: "Desired state conflict",
                description: "Desired state conflicts with the installed state.",
                resolution: "Fix the desired state."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_DESIRED_DUPLICATE_MODULE) THEN (
    CREATE error_definition:RUNTIME_DESIRED_DUPLICATE_MODULE CONTENT {
        code: "RUNTIME_DESIRED_DUPLICATE_MODULE",
        module: "runtime",
        domain: "reconciliation",
        category: "validation",
        severity: "error",
        message: "Desired state declares a module twice",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Module en double dans l'état désiré",
                description: "L'état désiré du runtime déclare plusieurs fois le même module.",
                resolution: "Ne déclarer chaque module qu'une fois."
            },
            en: {
                label: "Duplicate module in desired state",
                description: "Desired state declares a module twice.",
                resolution: "Declare each module only once."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RECONCILIATION_PASS_RUNNING) THEN (
    CREATE error_definition:RUNTIME_RECONCILIATION_PASS_RUNNING CONTENT {
        code: "RUNTIME_RECONCILIATION_PASS_RUNNING",
        module: "runtime",
        domain: "reconciliation",
        category: "conflict",
        severity: "error",
        message: "A reconciliation pass is already running",
        default_language: "fr",
        http_status: 409,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Réconciliation déjà en cours",
                description: "Une passe de réconciliation est déjà en cours sur ce contrôleur.",
                resolution: "Attendre la fin de la passe en cours."
            },
            en: {
                label: "Reconciliation already running",
                description: "A reconciliation pass is already running.",
                resolution: "Wait for the current pass to finish."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_DUPLICATE) THEN (
    CREATE error_definition:RUNTIME_WORKER_DUPLICATE CONTENT {
        code: "RUNTIME_WORKER_DUPLICATE",
        module: "runtime",
        domain: "worker",
        category: "conflict",
        severity: "error",
        message: "Worker is already registered",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Worker déjà enregistré",
                description: "Un worker portant cet identifiant est déjà enregistré.",
                resolution: "Enregistrer chaque worker une seule fois."
            },
            en: {
                label: "Worker already registered",
                description: "Worker is already registered.",
                resolution: "Register each worker only once."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_NOT_FOUND) THEN (
    CREATE error_definition:RUNTIME_WORKER_NOT_FOUND CONTENT {
        code: "RUNTIME_WORKER_NOT_FOUND",
        module: "runtime",
        domain: "worker",
        category: "not_found",
        severity: "error",
        message: "Worker is not registered",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Worker introuvable",
                description: "Aucun worker portant cet identifiant n'est enregistré.",
                resolution: "Enregistrer le worker avant de l'utiliser."
            },
            en: {
                label: "Worker not found",
                description: "Worker is not registered.",
                resolution: "Register the worker before using it."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_INVALID_ID) THEN (
    CREATE error_definition:RUNTIME_WORKER_INVALID_ID CONTENT {
        code: "RUNTIME_WORKER_INVALID_ID",
        module: "runtime",
        domain: "worker",
        category: "validation",
        severity: "error",
        message: "Worker identifier is invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Identifiant de worker invalide",
                description: "L'identifiant du worker ne respecte pas le format module:nom.",
                resolution: "Nommer le worker selon le format module:nom."
            },
            en: {
                label: "Invalid worker identifier",
                description: "Worker identifier is invalid.",
                resolution: "Name the worker as module:name."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_INVALID_TRANSITION) THEN (
    CREATE error_definition:RUNTIME_WORKER_INVALID_TRANSITION CONTENT {
        code: "RUNTIME_WORKER_INVALID_TRANSITION",
        module: "runtime",
        domain: "worker",
        category: "conflict",
        severity: "error",
        message: "Worker state transition is not allowed",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Transition de worker invalide",
                description: "Le worker ne peut pas passer de son état actuel à l'état demandé.",
                resolution: "Vérifier l'état du worker avant l'opération."
            },
            en: {
                label: "Invalid worker transition",
                description: "Worker state transition is not allowed.",
                resolution: "Check the worker state before the operation."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_START_FAILED) THEN (
    CREATE error_definition:RUNTIME_WORKER_START_FAILED CONTENT {
        code: "RUNTIME_WORKER_START_FAILED",
        module: "runtime",
        domain: "worker",
        category: "internal",
        severity: "error",
        message: "Worker could not be started",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Démarrage du worker impossible",
                description: "Le superviseur n'a pas pu démarrer le worker.",
                resolution: "Consulter le détail de l'erreur."
            },
            en: {
                label: "Worker start failed",
                description: "Worker could not be started.",
                resolution: "Check the error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_STOP_FAILED) THEN (
    CREATE error_definition:RUNTIME_WORKER_STOP_FAILED CONTENT {
        code: "RUNTIME_WORKER_STOP_FAILED",
        module: "runtime",
        domain: "worker",
        category: "internal",
        severity: "error",
        message: "Worker could not be stopped",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Arrêt du worker impossible",
                description: "Le superviseur n'a pas pu arrêter le worker.",
                resolution: "Consulter le détail de l'erreur."
            },
            en: {
                label: "Worker stop failed",
                description: "Worker could not be stopped.",
                resolution: "Check the error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_FAILED) THEN (
    CREATE error_definition:RUNTIME_WORKER_FAILED CONTENT {
        code: "RUNTIME_WORKER_FAILED",
        module: "runtime",
        domain: "worker",
        category: "internal",
        severity: "error",
        message: "Worker failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Échec du worker",
                description: "Le worker s'est terminé sur une erreur.",
                resolution: "Consulter le détail de l'erreur du worker."
            },
            en: {
                label: "Worker failed",
                description: "Worker failed.",
                resolution: "Check the worker error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_WORKER_STORE_FAILED) THEN (
    CREATE error_definition:RUNTIME_WORKER_STORE_FAILED CONTENT {
        code: "RUNTIME_WORKER_STORE_FAILED",
        module: "runtime",
        domain: "worker",
        category: "dependency",
        severity: "error",
        message: "Worker state could not be persisted",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Persistance du worker impossible",
                description: "L'état du worker n'a pas pu être enregistré.",
                resolution: "Vérifier la disponibilité de SurrealDB."
            },
            en: {
                label: "Worker state not persisted",
                description: "Worker state could not be persisted.",
                resolution: "Check SurrealDB availability."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_STORE_FAILED) THEN (
    CREATE error_definition:RUNTIME_STORE_FAILED CONTENT {
        code: "RUNTIME_STORE_FAILED",
        module: "runtime",
        domain: "store",
        category: "dependency",
        severity: "error",
        message: "Runtime persistence call failed",
        default_language: "fr",
        http_status: 503,
        retryable: true,
        enabled: true,
        translations: {
            fr: {
                label: "Appel de persistance en échec",
                description: "Un appel à une fonction fn::runtime_* a échoué ou a renvoyé une donnée illisible.",
                resolution: "Vérifier la disponibilité de SurrealDB et l'installation du schéma du runtime."
            },
            en: {
                label: "Persistence call failed",
                description: "Runtime persistence call failed.",
                resolution: "Check SurrealDB availability and the runtime schema installation."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_STORE_MISSING) THEN (
    CREATE error_definition:RUNTIME_STORE_MISSING CONTENT {
        code: "RUNTIME_STORE_MISSING",
        module: "runtime",
        domain: "store",
        category: "internal",
        severity: "error",
        message: "A required runtime component is not configured",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Composant du runtime non configuré",
                description: "Le runtime n'a pas reçu le store, le client SurrealDB ou le store d'événements requis.",
                resolution: "Configurer le composant indiqué au démarrage du runtime."
            },
            en: {
                label: "Runtime component not configured",
                description: "A required runtime component is not configured.",
                resolution: "Configure the named component when starting the runtime."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_CONFIG_INVALID) THEN (
    CREATE error_definition:RUNTIME_CONFIG_INVALID CONTENT {
        code: "RUNTIME_CONFIG_INVALID",
        module: "runtime",
        domain: "config",
        category: "validation",
        severity: "error",
        message: "Runtime configuration is invalid",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Configuration invalide",
                description: "Une durée de la configuration du runtime est nulle ou incohérente.",
                resolution: "Corriger la configuration selon le détail."
            },
            en: {
                label: "Invalid configuration",
                description: "Runtime configuration is invalid.",
                resolution: "Fix the configuration according to the detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_LOCK_POISONED) THEN (
    CREATE error_definition:RUNTIME_LOCK_POISONED CONTENT {
        code: "RUNTIME_LOCK_POISONED",
        module: "runtime",
        domain: "memory",
        category: "internal",
        severity: "error",
        message: "An in-memory lock was poisoned by a panic",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Verrou mémoire empoisonné",
                description: "Une tâche a paniqué en détenant un verrou interne du runtime.",
                resolution: "Redémarrer le processus et analyser la panique d'origine."
            },
            en: {
                label: "In-memory lock poisoned",
                description: "An in-memory lock was poisoned by a panic.",
                resolution: "Restart the process and analyse the original panic."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_HEALTH_CHECKER_DUPLICATE) THEN (
    CREATE error_definition:RUNTIME_HEALTH_CHECKER_DUPLICATE CONTENT {
        code: "RUNTIME_HEALTH_CHECKER_DUPLICATE",
        module: "runtime",
        domain: "health",
        category: "conflict",
        severity: "error",
        message: "A health check is already registered for this module",
        default_language: "fr",
        http_status: 409,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Sonde de santé déjà enregistrée",
                description: "Une sonde de santé est déjà enregistrée pour ce module.",
                resolution: "Enregistrer une seule sonde par module."
            },
            en: {
                label: "Health check already registered",
                description: "A health check is already registered for this module.",
                resolution: "Register a single health check per module."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_RELEASE_STATUS) THEN (
    CREATE error_definition:RUNTIME_INVALID_RELEASE_STATUS CONTENT {
        code: "RUNTIME_INVALID_RELEASE_STATUS",
        module: "runtime",
        domain: "release",
        category: "validation",
        severity: "error",
        message: "Stored release status is unknown",
        default_language: "fr",
        http_status: 422,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Statut de release inconnu",
                description: "Le statut enregistré d'une release ne fait pas partie des statuts connus.",
                resolution: "Corriger l'enregistrement de la release."
            },
            en: {
                label: "Unknown release status",
                description: "Stored release status is unknown.",
                resolution: "Fix the release record."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_EVENT_ENGINE_ERROR) THEN (
    CREATE error_definition:RUNTIME_EVENT_ENGINE_ERROR CONTENT {
        code: "RUNTIME_EVENT_ENGINE_ERROR",
        module: "runtime",
        domain: "events",
        category: "internal",
        severity: "error",
        message: "Event engine operation failed",
        default_language: "fr",
        http_status: 500,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Erreur du moteur d'événements",
                description: "Le moteur lyxal_event a renvoyé une erreur (enregistrement des handlers, worker ou purge).",
                resolution: "Consulter le détail de l'erreur."
            },
            en: {
                label: "Event engine error",
                description: "Event engine operation failed.",
                resolution: "Check the error detail."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_INVALID_PARAMETERS) THEN (
    CREATE error_definition:RUNTIME_INVALID_PARAMETERS CONTENT {
        code: "RUNTIME_INVALID_PARAMETERS",
        module: "runtime",
        domain: "parameters",
        category: "validation",
        severity: "error",
        message: "One or more runtime function parameters are missing or invalid",
        default_language: "fr",
        http_status: 400,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Paramètres du runtime invalides",
                description: "Un ou plusieurs paramètres d'une fonction du runtime sont absents ou invalides (détail par champ dans details.fields).",
                resolution: "Corriger l'appel : les valeurs viennent du code du runtime, pas d'un utilisateur."
            },
            en: {
                label: "Invalid runtime parameters",
                description: "One or more runtime function parameters are missing or invalid.",
                resolution: "Fix the call: these values come from the runtime code, not from a user."
            }
        }
    }
) END;

IF !record::exists(error_definition:RUNTIME_RELEASE_NOT_FOUND) THEN (
    CREATE error_definition:RUNTIME_RELEASE_NOT_FOUND CONTENT {
        code: "RUNTIME_RELEASE_NOT_FOUND",
        module: "runtime",
        domain: "release",
        category: "not_found",
        severity: "error",
        message: "Module release was not found",
        default_language: "fr",
        http_status: 404,
        retryable: false,
        enabled: true,
        translations: {
            fr: {
                label: "Release introuvable",
                description: "Aucune release n'est enregistrée pour ce module et cette version.",
                resolution: "Enregistrer la release avant de modifier son statut."
            },
            en: {
                label: "Release not found",
                description: "Module release was not found.",
                resolution: "Register the release before updating its status."
            }
        }
    }
) END;
