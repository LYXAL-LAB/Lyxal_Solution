-- lyxal-test: assertions
-- Contrat des fonctions de persistance du runtime en session système : modules, releases
-- (empreinte comprise), migrations et leur reprise, baux, santé, workers et journal. Chaque
-- fonction est appelée dans un cas nominal et avec des paramètres refusés.
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).

-- ---------------------------------------------------------------------------
-- Modules
-- ---------------------------------------------------------------------------

-- test: un module est enregistré
RETURN fn::runtime_module_upsert({ module_id: "lyxal_essai", name: "Essai", description: "Module d'essai" }).data.name == "Essai";

-- test: un module se lit, un module inconnu vaut NONE
RETURN fn::runtime_module_get({ module_id: "lyxal_essai" }).data.description == "Module d'essai"
    AND fn::runtime_module_get({ module_id: "lyxal_absent" }).data == NONE;

-- test: les modules se listent par identifiant
RETURN fn::runtime_module_upsert({ module_id: "lyxal_autre", name: "Autre" }).ok
    AND fn::runtime_module_list({}).data.map(|$m| $m.module_id) == ["lyxal_autre", "lyxal_essai"];

-- test: un module sans nom ou sans identifiant est refusé
RETURN fn::runtime_module_upsert({ module_id: "lyxal_essai" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_module_get({}).error.code == "RUNTIME_INVALID_PARAMETERS";

-- ---------------------------------------------------------------------------
-- Releases
-- ---------------------------------------------------------------------------

-- test: une release est enregistrée avec son empreinte
RETURN fn::runtime_release_register({ module_id: "lyxal_essai", version: "0.1.0", manifest_version: 1, status: "Installing", checksum: string::repeat("a", 64), installation_phase: "Registration" }).data.checksum == string::repeat("a", 64);

-- test: le passage à Installed date l'installation et garde l'empreinte
RETURN fn::runtime_release_status_update({ module_id: "lyxal_essai", version: "0.1.0", status: "Installed", phase: "Complete" }).data.installed_at != NONE
    AND fn::runtime_release_get({ module_id: "lyxal_essai", version: "0.1.0" }).data.status == "Installed"
    AND fn::runtime_release_get({ module_id: "lyxal_essai", version: "0.1.0" }).data.checksum == string::repeat("a", 64);

-- test: les releases d'un module se listent, une release inconnue vaut NONE
RETURN fn::runtime_release_list({ module_id: "lyxal_essai" }).data.map(|$r| $r.version) == ["0.1.0"]
    AND fn::runtime_release_get({ module_id: "lyxal_essai", version: "9.9.9" }).data == NONE;

-- test: changer le statut d'une release inconnue est refusé
RETURN fn::runtime_release_status_update({ module_id: "lyxal_essai", version: "9.9.9", status: "Installed" }).error.code == "RUNTIME_RELEASE_NOT_FOUND";

-- test: une version ou un statut invalides sont refusés
RETURN fn::runtime_release_register({ module_id: "lyxal_essai", version: "un", manifest_version: 1, status: "Installing" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_release_register({ module_id: "lyxal_essai", version: "0.2.0", manifest_version: 1, status: "Inconnu" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_release_list({}).error.code == "RUNTIME_INVALID_PARAMETERS";

-- ---------------------------------------------------------------------------
-- Baux
-- ---------------------------------------------------------------------------

-- test: un bail libre est pris
RETURN fn::runtime_lease_acquire({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n1", ttl_seconds: 600 }).data.outcome == "acquired";

-- test: le même nœud le détient déjà, un autre nœud en est écarté
RETURN fn::runtime_lease_acquire({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n1", ttl_seconds: 600 }).data.outcome == "already_owned"
    AND fn::runtime_lease_acquire({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n2", ttl_seconds: 600 }).data.outcome == "held_by_other";

-- test: le bail actif se lit, se prolonge pour son détenteur seulement
RETURN fn::runtime_lease_get({ kind: "installation", key: "lyxal_essai:0.1.0" }).data.owner_node_id == "n1"
    AND fn::runtime_lease_renew({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n1", generation: 1, ttl_seconds: 600 }).data.renewed == true
    AND fn::runtime_lease_renew({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n2", generation: 1, ttl_seconds: 600 }).data.renewed == false;

-- test: un bail d'une nature inconnue est refusé
RETURN fn::runtime_lease_acquire({ kind: "autre", key: "k", node_id: "n1", ttl_seconds: 600 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_lease_get({ kind: "installation" }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- ---------------------------------------------------------------------------
-- Migrations et reprise
-- ---------------------------------------------------------------------------

-- test: une migration appliquée est enregistrée
RETURN fn::runtime_migration_record({ module_id: "lyxal_essai", migration_id: "0001_initial", module_version: "0.1.0", checksum: string::repeat("b", 64), status: "Applied", applied_at: 1, duration_ms: 2, script: "migrations/0001_initial.surql", node_id: "n1" }).data.status == "Applied";

-- test: une migration se lit et se liste
RETURN fn::runtime_migration_get({ module_id: "lyxal_essai", migration_id: "0001_initial" }).data.checksum == string::repeat("b", 64)
    AND fn::runtime_migration_get({ module_id: "lyxal_essai", migration_id: "0009_absente" }).data == NONE
    AND fn::runtime_migration_list({ module_id: "lyxal_essai" }).data.map(|$m| $m.migration_id) == ["0001_initial"];

-- test: une empreinte de migration trop courte est refusée
RETURN fn::runtime_migration_record({ module_id: "lyxal_essai", migration_id: "0002_x", module_version: "0.1.0", checksum: "abc", status: "Applied", applied_at: 1, duration_ms: 2 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: une écriture sous un bail de migration non détenu est annulée
-- attendu-erreur: RUNTIME_LEASE_FENCED
RETURN fn::runtime_migration_record({ module_id: "lyxal_essai", migration_id: "0002_x", module_version: "0.1.0", checksum: string::repeat("b", 64), status: "Applying", applied_at: 0, duration_ms: 0, lease_key: "lyxal_essai:0002_x", node_id: "n1", generation: 1 });

-- préparation: une migration restée « en cours » après l'arrêt de son nœud
fn::runtime_migration_record({ module_id: "lyxal_essai", migration_id: "0002_suite", module_version: "0.1.0", checksum: string::repeat("c", 64), status: "Applying", applied_at: 0, duration_ms: 0, script: "migrations/0002_suite.surql", node_id: "n-arrete" });

-- test: la migration interrompue est listée, pour tous les modules ou un seul
RETURN fn::runtime_migration_interrupted_list({}).data.map(|$m| [$m.module, $m.migration, $m.state]) == [["lyxal_essai", "0002_suite", "interrupted"]]
    AND fn::runtime_migration_interrupted_list({ module: "lyxal_autre" }).data == [];

-- test: une décision sans le bail d'installation de la release est refusée
RETURN fn::runtime_migration_resolve({ module: "lyxal_essai", migration: "0002_suite", action: "retry", reason: "essai", actor: "cli:test", node_id: "n2", generation: 1 }).error.code == "RUNTIME_LEASE_FENCED";

-- test: le détenteur du bail d'installation décide de rejouer la migration
RETURN fn::runtime_migration_resolve({ module: "lyxal_essai", migration: "0002_suite", action: "retry", reason: "essai", actor: "cli:test", node_id: "n1", generation: 1 }).data.status == "RetryRequested";

-- test: une migration qui n'est plus interrompue n'accepte plus de décision
RETURN fn::runtime_migration_resolve({ module: "lyxal_essai", migration: "0002_suite", action: "abandon", reason: "essai", actor: "cli:test", node_id: "n1", generation: 1 }).error.code == "RUNTIME_MIGRATION_NOT_INTERRUPTED"
    AND fn::runtime_migration_resolve({ module: "lyxal_essai", migration: "0002_suite", action: "autre", reason: "essai", actor: "cli:test", node_id: "n1", generation: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_migration_interrupted_list({ inconnu: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: le bail se libère pour son détenteur, puis n'est plus actif
RETURN fn::runtime_lease_release({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n2", generation: 1 }).data.released == false
    AND fn::runtime_lease_release({ kind: "installation", key: "lyxal_essai:0.1.0", node_id: "n1", generation: 1 }).data.released == true
    AND fn::runtime_lease_get({ kind: "installation", key: "lyxal_essai:0.1.0" }).data == NONE;

-- ---------------------------------------------------------------------------
-- Santé et workers par nœud
-- ---------------------------------------------------------------------------

-- test: l'état de santé d'un module sur un nœud est enregistré puis listé
RETURN fn::runtime_health_record({ node_id: "n1", module_id: "lyxal_essai", status: "degraded", latency_ms: 3, message: "essai" }).data.status == "degraded"
    AND fn::runtime_health_list({ node_id: "n1" }).data.map(|$h| [$h.module_id, $h.status]) == [["lyxal_essai", "degraded"]]
    AND fn::runtime_health_list({ node_id: "n2" }).data == [];

-- test: un statut de santé inconnu est refusé
RETURN fn::runtime_health_record({ node_id: "n1", module_id: "lyxal_essai", status: "parfait" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_health_list({}).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: l'état d'un worker sur un nœud est enregistré, lu et listé
RETURN fn::runtime_worker_upsert({ node_id: "n1", worker_id: "lyxal_essai:w", module_id: "lyxal_essai", state: "running", criticality: "optional", restart_count: 1, failure_count: 0 }).data.state == "running"
    AND fn::runtime_worker_get({ node_id: "n1", worker_id: "lyxal_essai:w" }).data.restart_count == 1
    AND fn::runtime_worker_get({ node_id: "n2", worker_id: "lyxal_essai:w" }).data == NONE
    AND fn::runtime_worker_list({ node_id: "n1" }).data.map(|$w| $w.worker_id) == ["lyxal_essai:w"];

-- test: un état de worker inconnu est refusé
RETURN fn::runtime_worker_upsert({ node_id: "n1", worker_id: "lyxal_essai:w", module_id: "lyxal_essai", state: "endormi", criticality: "optional", restart_count: 0, failure_count: 0 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_worker_get({ node_id: "n1" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_worker_list({}).error.code == "RUNTIME_INVALID_PARAMETERS";

-- ---------------------------------------------------------------------------
-- Journal des événements techniques
-- ---------------------------------------------------------------------------

-- test: un événement est ajouté au journal, et le rejouer ne crée pas de doublon
RETURN fn::runtime_event_append({ event_id: "e1", sequence: 1, node_id: "n1", timestamp: 10, kind: "module", module_id: "lyxal_essai", payload: { type: "registered" } }).data.event_id == "e1"
    AND fn::runtime_event_append({ event_id: "e1", sequence: 1, node_id: "n1", timestamp: 10, kind: "module", module_id: "lyxal_essai", payload: { type: "registered" } }).ok
    AND count(SELECT * FROM runtime_event_journal) == 1;

-- test: le journal se lit du plus récent au plus ancien, filtré par module au besoin
RETURN fn::runtime_event_append({ event_id: "e2", sequence: 2, node_id: "n1", timestamp: 20, kind: "lifecycle", payload: {} }).ok
    AND fn::runtime_event_list({ limit: 10 }).data.map(|$e| $e.event_id) == ["e2", "e1"]
    AND fn::runtime_event_list({ limit: 10, module_id: "lyxal_essai" }).data.map(|$e| $e.event_id) == ["e1"];

-- test: un événement sans charge utile ou une limite nulle sont refusés
RETURN fn::runtime_event_append({ event_id: "e3", sequence: 3, node_id: "n1", timestamp: 30, kind: "module" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_event_list({ limit: 0 }).error.code == "RUNTIME_INVALID_PARAMETERS";
