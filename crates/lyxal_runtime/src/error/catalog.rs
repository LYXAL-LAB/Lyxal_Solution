//! Catalogue des erreurs du runtime : une entrée par code, identique à sa définition dans
//! `error/runtime.surql` (vérifié par test).

/// Description d'une erreur du runtime.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct RuntimeErrorInfo {
    pub code: &'static str,
    pub category: &'static str,
    pub http_status: u16,
    pub retryable: bool,
    /// Message technique (anglais), champ `message` de la définition.
    pub message: &'static str,
    /// Libellé français, champ `translations.fr.label` de la définition.
    pub label: &'static str,
}

pub const DUPLICATE_MODULE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_DUPLICATE_MODULE",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Module is already registered in the runtime",
    label: "Module déjà enregistré",
};

pub const UNKNOWN_MODULE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_UNKNOWN_MODULE",
    category: "not_found",
    http_status: 404,
    retryable: false,
    message: "Module is not registered in the runtime",
    label: "Module inconnu",
};

pub const MISSING_DEPENDENCY: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MISSING_DEPENDENCY",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "A required module dependency is not registered",
    label: "Dépendance manquante",
};

pub const DEPENDENCY_CYCLE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_DEPENDENCY_CYCLE",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Module dependencies form a cycle",
    label: "Cycle de dépendances",
};

pub const INVALID_STATE_TRANSITION: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_STATE_TRANSITION",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Module state transition is not allowed",
    label: "Transition d'état invalide",
};

pub const INSTALL_FAILURE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INSTALL_FAILURE",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Module install hook failed",
    label: "Échec du hook d'installation",
};

pub const START_FAILURE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_START_FAILURE",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Module start hook failed",
    label: "Échec du démarrage du module",
};

pub const STOP_FAILURE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_STOP_FAILURE",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Module stop hook failed",
    label: "Échec de l'arrêt du module",
};

pub const OPERATION_TIMEOUT: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_OPERATION_TIMEOUT",
    category: "timeout",
    http_status: 504,
    retryable: true,
    message: "Module operation timed out",
    label: "Délai dépassé",
};

pub const INVALID_MANIFEST: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_MANIFEST",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Module manifest is invalid",
    label: "Manifeste invalide",
};

pub const UNSUPPORTED_MANIFEST_VERSION: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_UNSUPPORTED_MANIFEST_VERSION",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Manifest version is not supported",
    label: "Version de manifeste non supportée",
};

pub const INVALID_MODULE_VERSION: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_MODULE_VERSION",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Module version is not a valid semantic version",
    label: "Version de module invalide",
};

pub const SELF_DEPENDENCY: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_SELF_DEPENDENCY",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Module declares a dependency on itself",
    label: "Dépendance à soi-même",
};

pub const DUPLICATE_DEPENDENCY: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_DUPLICATE_DEPENDENCY",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Manifest declares the same dependency more than once",
    label: "Dépendance en double",
};

pub const MANIFEST_PARSE_ERROR: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MANIFEST_PARSE_ERROR",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Manifest could not be parsed",
    label: "Manifeste illisible",
};

pub const INVALID_MIGRATION_ID: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_MIGRATION_ID",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Migration identifier is invalid",
    label: "Identifiant de migration invalide",
};

pub const INVALID_CHECKSUM: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_CHECKSUM",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Migration checksum is invalid",
    label: "Empreinte de migration invalide",
};

pub const RESOURCE_NOT_FOUND: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_RESOURCE_NOT_FOUND",
    category: "not_found",
    http_status: 404,
    retryable: false,
    message: "Module resource was not found",
    label: "Ressource introuvable",
};

pub const SCHEMA_IMPORT_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_SCHEMA_IMPORT_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "SurrealQL resource could not be imported",
    label: "Import SurrealQL en échec",
};

pub const MIGRATION_CHECKSUM_MISMATCH: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_CHECKSUM_MISMATCH",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Applied migration was modified",
    label: "Migration appliquée modifiée",
};

pub const MIGRATION_INTERRUPTED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_INTERRUPTED",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "A previous run left the migration in Applying state",
    label: "Migration interrompue",
};

pub const MIGRATION_EXECUTION_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_EXECUTION_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Migration execution failed",
    label: "Échec d'exécution de migration",
};

pub const MIGRATION_LOCK_ACQUIRE_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_LOCK_ACQUIRE_FAILED",
    category: "dependency",
    http_status: 503,
    retryable: true,
    message: "Migration lease could not be acquired",
    label: "Prise du bail de migration impossible",
};

pub const MIGRATION_LOCK_TIMEOUT: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_LOCK_TIMEOUT",
    category: "timeout",
    http_status: 504,
    retryable: true,
    message: "Timed out waiting for the migration lease",
    label: "Attente du bail de migration dépassée",
};

pub const MIGRATION_LEASE_LOST: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_LEASE_LOST",
    category: "conflict",
    http_status: 409,
    retryable: true,
    message: "Migration lease was lost",
    label: "Bail de migration perdu",
};

pub const LEASE_FENCED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_LEASE_FENCED",
    category: "conflict",
    http_status: 412,
    retryable: false,
    message: "Write refused: the lease is no longer held by this node",
    label: "Écriture refusée : bail perdu",
};

pub const MIGRATION_LOCK_NOT_OWNER: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_LOCK_NOT_OWNER",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Node does not own the migration lease",
    label: "Bail de migration non détenu",
};

pub const MIGRATION_RECOVERY_REQUIRED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MIGRATION_RECOVERY_REQUIRED",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Interrupted migration requires manual recovery",
    label: "Reprise manuelle requise",
};

pub const MODULE_IMPLEMENTATION_MISSING: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MODULE_IMPLEMENTATION_MISSING",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Package has no LyxalModule implementation",
    label: "Implémentation de module manquante",
};

pub const VERSION_INCOMPATIBLE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_VERSION_INCOMPATIBLE",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Module requires another runtime version",
    label: "Version du runtime incompatible",
};

pub const DEPENDENCY_VERSION_INCOMPATIBLE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_DEPENDENCY_VERSION_INCOMPATIBLE",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Dependency version does not satisfy the constraint",
    label: "Version de dépendance incompatible",
};

pub const BATCH_DUPLICATE_MODULE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_BATCH_DUPLICATE_MODULE",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Batch contains conflicting versions of a module",
    label: "Module en double dans le lot",
};

pub const PACKAGE_MISSING: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_PACKAGE_MISSING",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Package to install was not provided",
    label: "Package absent",
};

pub const MODULE_INSTALL_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_MODULE_INSTALL_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Module installation failed",
    label: "Échec d'installation du module",
};

pub const INSTALLATION_LEASE_ACQUIRE_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INSTALLATION_LEASE_ACQUIRE_FAILED",
    category: "dependency",
    http_status: 503,
    retryable: true,
    message: "Installation lease operation failed",
    label: "Bail d'installation en échec",
};

pub const INSTALLATION_LEASE_TIMEOUT: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INSTALLATION_LEASE_TIMEOUT",
    category: "timeout",
    http_status: 504,
    retryable: true,
    message: "Timed out waiting for the installation lease",
    label: "Attente du bail d'installation dépassée",
};

pub const DESIRED_STATE_CONFLICT: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_DESIRED_STATE_CONFLICT",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Desired state conflicts with the installed state",
    label: "Conflit d'état désiré",
};

pub const DESIRED_DUPLICATE_MODULE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_DESIRED_DUPLICATE_MODULE",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Desired state declares a module twice",
    label: "Module en double dans l'état désiré",
};

pub const RECONCILIATION_PASS_RUNNING: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_RECONCILIATION_PASS_RUNNING",
    category: "conflict",
    http_status: 409,
    retryable: true,
    message: "A reconciliation pass is already running",
    label: "Réconciliation déjà en cours",
};

pub const WORKER_DUPLICATE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_DUPLICATE",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Worker is already registered",
    label: "Worker déjà enregistré",
};

pub const WORKER_NOT_FOUND: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_NOT_FOUND",
    category: "not_found",
    http_status: 404,
    retryable: false,
    message: "Worker is not registered",
    label: "Worker introuvable",
};

pub const WORKER_INVALID_ID: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_INVALID_ID",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Worker identifier is invalid",
    label: "Identifiant de worker invalide",
};

pub const WORKER_INVALID_TRANSITION: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_INVALID_TRANSITION",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "Worker state transition is not allowed",
    label: "Transition de worker invalide",
};

pub const WORKER_START_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_START_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Worker could not be started",
    label: "Démarrage du worker impossible",
};

pub const WORKER_STOP_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_STOP_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Worker could not be stopped",
    label: "Arrêt du worker impossible",
};

pub const WORKER_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_FAILED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Worker failed",
    label: "Échec du worker",
};

pub const WORKER_STORE_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_WORKER_STORE_FAILED",
    category: "dependency",
    http_status: 503,
    retryable: true,
    message: "Worker state could not be persisted",
    label: "Persistance du worker impossible",
};

pub const STORE_FAILED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_STORE_FAILED",
    category: "dependency",
    http_status: 503,
    retryable: true,
    message: "Runtime persistence call failed",
    label: "Appel de persistance en échec",
};

pub const STORE_MISSING: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_STORE_MISSING",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "A required runtime component is not configured",
    label: "Composant du runtime non configuré",
};

pub const CONFIG_INVALID: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_CONFIG_INVALID",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Runtime configuration is invalid",
    label: "Configuration invalide",
};

pub const LOCK_POISONED: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_LOCK_POISONED",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "An in-memory lock was poisoned by a panic",
    label: "Verrou mémoire empoisonné",
};

pub const HEALTH_CHECKER_DUPLICATE: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_HEALTH_CHECKER_DUPLICATE",
    category: "conflict",
    http_status: 409,
    retryable: false,
    message: "A health check is already registered for this module",
    label: "Sonde de santé déjà enregistrée",
};

pub const INVALID_RELEASE_STATUS: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_RELEASE_STATUS",
    category: "validation",
    http_status: 422,
    retryable: false,
    message: "Stored release status is unknown",
    label: "Statut de release inconnu",
};

pub const EVENT_ENGINE_ERROR: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_EVENT_ENGINE_ERROR",
    category: "internal",
    http_status: 500,
    retryable: false,
    message: "Event engine operation failed",
    label: "Erreur du moteur d'événements",
};

pub const INVALID_PARAMETERS: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_INVALID_PARAMETERS",
    category: "validation",
    http_status: 400,
    retryable: false,
    message: "One or more runtime function parameters are missing or invalid",
    label: "Paramètres du runtime invalides",
};

pub const RELEASE_NOT_FOUND: RuntimeErrorInfo = RuntimeErrorInfo {
    code: "RUNTIME_RELEASE_NOT_FOUND",
    category: "not_found",
    http_status: 404,
    retryable: false,
    message: "Module release was not found",
    label: "Release introuvable",
};

/// Toutes les erreurs du runtime, y compris celles émises seulement par le SurrealQL.
pub const RUNTIME_ERROR_CATALOG: &[RuntimeErrorInfo] = &[
    DUPLICATE_MODULE,
    UNKNOWN_MODULE,
    MISSING_DEPENDENCY,
    DEPENDENCY_CYCLE,
    INVALID_STATE_TRANSITION,
    INSTALL_FAILURE,
    START_FAILURE,
    STOP_FAILURE,
    OPERATION_TIMEOUT,
    INVALID_MANIFEST,
    UNSUPPORTED_MANIFEST_VERSION,
    INVALID_MODULE_VERSION,
    SELF_DEPENDENCY,
    DUPLICATE_DEPENDENCY,
    MANIFEST_PARSE_ERROR,
    INVALID_MIGRATION_ID,
    INVALID_CHECKSUM,
    RESOURCE_NOT_FOUND,
    SCHEMA_IMPORT_FAILED,
    MIGRATION_CHECKSUM_MISMATCH,
    MIGRATION_INTERRUPTED,
    MIGRATION_EXECUTION_FAILED,
    MIGRATION_LOCK_ACQUIRE_FAILED,
    MIGRATION_LOCK_TIMEOUT,
    MIGRATION_LEASE_LOST,
    LEASE_FENCED,
    MIGRATION_LOCK_NOT_OWNER,
    MIGRATION_RECOVERY_REQUIRED,
    MODULE_IMPLEMENTATION_MISSING,
    VERSION_INCOMPATIBLE,
    DEPENDENCY_VERSION_INCOMPATIBLE,
    BATCH_DUPLICATE_MODULE,
    PACKAGE_MISSING,
    MODULE_INSTALL_FAILED,
    INSTALLATION_LEASE_ACQUIRE_FAILED,
    INSTALLATION_LEASE_TIMEOUT,
    DESIRED_STATE_CONFLICT,
    DESIRED_DUPLICATE_MODULE,
    RECONCILIATION_PASS_RUNNING,
    WORKER_DUPLICATE,
    WORKER_NOT_FOUND,
    WORKER_INVALID_ID,
    WORKER_INVALID_TRANSITION,
    WORKER_START_FAILED,
    WORKER_STOP_FAILED,
    WORKER_FAILED,
    WORKER_STORE_FAILED,
    STORE_FAILED,
    STORE_MISSING,
    CONFIG_INVALID,
    LOCK_POISONED,
    HEALTH_CHECKER_DUPLICATE,
    INVALID_RELEASE_STATUS,
    EVENT_ENGINE_ERROR,
    INVALID_PARAMETERS,
    RELEASE_NOT_FOUND,
];

#[cfg(test)]
mod tests {
    use super::*;

    /// Chaque entrée du catalogue est définie dans `error/runtime.surql` avec la même catégorie,
    /// le même statut HTTP, le même caractère réessayable, le même message et le même libellé ;
    /// le fichier ne définit aucun autre code.
    #[test]
    fn test_catalog_matches_master_data() {
        let definitions = include_str!("../../error/runtime.surql");
        for info in RUNTIME_ERROR_CATALOG {
            let start = definitions
                .find(&format!("CREATE error_definition:{} CONTENT", info.code))
                .unwrap_or_else(|| panic!("{} absent des définitions", info.code));
            let block = &definitions[start..];
            let block = &block[..block.find(") END;").expect("fin de bloc")];
            assert!(block.contains(&format!("code: \"{}\"", info.code)));
            assert!(block.contains(&format!("category: \"{}\"", info.category)));
            assert!(block.contains(&format!("http_status: {}", info.http_status)));
            assert!(block.contains(&format!("retryable: {}", info.retryable)));
            assert!(block.contains(&format!("message: \"{}\"", info.message)));
            assert!(block.contains(&format!("label: \"{}\"", info.label)));
        }
        assert_eq!(
            definitions.matches("CREATE error_definition:").count(),
            RUNTIME_ERROR_CATALOG.len()
        );
        let mut codes: Vec<_> = RUNTIME_ERROR_CATALOG.iter().map(|i| i.code).collect();
        codes.sort_unstable();
        codes.dedup();
        assert_eq!(codes.len(), RUNTIME_ERROR_CATALOG.len(), "code en double");
    }
}
