-- lyxal-test: assertions
-- Présence des nœuds (fn::runtime_node_*) et socle installé (fn::runtime_foundation_*) : cas
-- nominaux, paramètres refusés, et identité sans droit (les tables du runtime sont en
-- PERMISSIONS NONE : une session autre que la session système n'écrit et ne lit rien).
-- Exécuté par scripts/ci/test_lyxal_modules.py (format en tête du script).
--
-- identité utilisateur: { "id": "user:tester", "sub": "user:tester", "iss": "lyxal-os" }

-- ---------------------------------------------------------------------------
-- Battement
-- ---------------------------------------------------------------------------

-- test: le premier battement crée la ligne du nœud
RETURN fn::runtime_node_upsert({ node_id: "n1", host: "lyxal_server", modules: ["lyxal_auth", "lyxal_core"], foundation_checksum: string::repeat("a", 64) }).data.host == "lyxal_server";

-- test: la ligne porte l'hôte, les modules et l'empreinte du socle du nœud
RETURN runtime_node:n1.node_id == "n1"
    AND runtime_node:n1.modules == ["lyxal_auth", "lyxal_core"]
    AND runtime_node:n1.foundation_checksum == string::repeat("a", 64)
    AND runtime_node:n1.seen_at >= runtime_node:n1.started_at;

-- préparation: date de démarrage du nœud gardée pour comparaison
CREATE essai_presence:n1 SET started_at = runtime_node:n1.started_at, seen_at = runtime_node:n1.seen_at;

-- test: un battement suivant rafraîchit la ligne et garde la date de démarrage
RETURN fn::runtime_node_upsert({ node_id: "n1", host: "lyxal_server", modules: ["lyxal_core"] }).data.started_at == essai_presence:n1.started_at
    AND runtime_node:n1.seen_at >= essai_presence:n1.seen_at
    AND runtime_node:n1.modules == ["lyxal_core"]
    AND runtime_node:n1.foundation_checksum == NONE
    AND count(SELECT * FROM runtime_node) == 1;

-- test: un nœud sans module est accepté
RETURN fn::runtime_node_upsert({ node_id: "n2", host: "lyxal_groupware", modules: [] }).data.modules == [];

-- test: un nom d'hôte hors format est refusé, champ par champ
RETURN fn::runtime_node_upsert({ node_id: "n9", host: "Lyxal-Server", modules: [] }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_upsert({ node_id: "n9", host: "Lyxal-Server", modules: [] }).error.details.fields.host != NONE;

-- test: un nom d'hôte de plus de 64 caractères est refusé
RETURN fn::runtime_node_upsert({ node_id: "n9", host: string::repeat("a", 65), modules: [] }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: nœud, modules ou empreinte invalides sont refusés
RETURN fn::runtime_node_upsert({ host: "lyxal_server", modules: [] }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_upsert({ node_id: "n9", host: "lyxal_server" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_upsert({ node_id: "n9", host: "lyxal_server", modules: [""] }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_upsert({ node_id: "n9", host: "lyxal_server", modules: "lyxal_core" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_upsert({ node_id: "n9", host: "lyxal_server", modules: [], foundation_checksum: "abc" }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: une clé inconnue est refusée
RETURN fn::runtime_node_upsert({ node_id: "n9", host: "lyxal_server", modules: [], inconnu: true }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: aucun nœud refusé n'a été écrit
RETURN record::exists(runtime_node:n9) == false;

-- test: une identité sans droit n'écrit pas de battement
-- en tant que: utilisateur
RETURN fn::runtime_node_upsert({ node_id: "pirate", host: "lyxal_server", modules: [] }).error.code == "RUNTIME_WRITE_FORBIDDEN";

-- test: rien n'a été écrit par l'identité sans droit
RETURN record::exists(runtime_node:pirate) == false;

-- ---------------------------------------------------------------------------
-- Liste
-- ---------------------------------------------------------------------------

-- préparation: le nœud n2 n'a plus battu depuis dix minutes
UPDATE runtime_node:n2 SET seen_at = time::now() - 10m;

-- test: la liste donne les nœuds du battement le plus récent au plus ancien, avec leur état
RETURN fn::runtime_node_list({}).data.map(|$n| [$n.node_id, $n.host, $n.alive]) == [["n1", "lyxal_server", true], ["n2", "lyxal_groupware", false]];

-- test: alive suit le délai demandé
RETURN fn::runtime_node_list({ alive_within: 1h }).data.map(|$n| $n.alive) == [true, true];

-- test: un délai hors bornes ou d'un autre type est refusé
RETURN fn::runtime_node_list({ alive_within: 0s }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_list({ alive_within: 2d }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_list({ alive_within: "bientôt" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_list({ inconnu: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: une identité sans droit ne voit aucun nœud
-- en tant que: utilisateur
RETURN fn::runtime_node_list({}).data == [];

-- ---------------------------------------------------------------------------
-- Retrait à l'arrêt
-- ---------------------------------------------------------------------------

-- préparation: lignes de worker et de santé des nœuds n1 et n2
{
    FOR $node IN ["n1", "n2"] {
        fn::runtime_worker_upsert({ node_id: $node, worker_id: "lyxal_essai:w", module_id: "lyxal_essai", state: "running", criticality: "required", restart_count: 0, failure_count: 0 });
        fn::runtime_health_record({ node_id: $node, module_id: "lyxal_essai", status: "healthy" });
    };
};

-- test: une identité sans droit ne retire aucun nœud, et le retrait est refusé
-- en tant que: utilisateur
RETURN fn::runtime_node_remove({ node_id: "n2" }).error.code == "RUNTIME_WRITE_FORBIDDEN";

-- test: le nœud et ses lignes sont toujours là
RETURN record::exists(runtime_node:n2)
    AND count(SELECT * FROM runtime_worker WHERE node_id = "n2") == 1
    AND count(SELECT * FROM runtime_health WHERE node_id = "n2") == 1;

-- test: le retrait supprime la ligne du nœud et ses lignes de worker et de santé
RETURN fn::runtime_node_remove({ node_id: "n2" }).data == { node_id: "n2", removed: true, workers: 1, health: 1 };

-- test: seul le nœud retiré a disparu
RETURN record::exists(runtime_node:n2) == false
    AND count(SELECT * FROM runtime_worker WHERE node_id = "n2") == 0
    AND count(SELECT * FROM runtime_health WHERE node_id = "n2") == 0
    AND record::exists(runtime_node:n1)
    AND count(SELECT * FROM runtime_worker WHERE node_id = "n1") == 1
    AND count(SELECT * FROM runtime_health WHERE node_id = "n1") == 1;

-- test: retirer un nœud inconnu ne supprime rien
RETURN fn::runtime_node_remove({ node_id: "n2" }).data == { node_id: "n2", removed: false, workers: 0, health: 0 };

-- test: un retrait sans nœud est refusé
RETURN fn::runtime_node_remove({}).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_remove({ node_id: "n1", inconnu: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- ---------------------------------------------------------------------------
-- Purge des nœuds disparus
-- ---------------------------------------------------------------------------

-- préparation: nœud n3 disparu depuis huit jours avec ses lignes (récentes), lignes anciennes d'un nœud n4 sans ligne de présence
{
    fn::runtime_node_upsert({ node_id: "n3", host: "lyxal_groupware", modules: ["lyxal_mail"] });
    FOR $node IN ["n3", "n4"] {
        fn::runtime_worker_upsert({ node_id: $node, worker_id: "lyxal_essai:w", module_id: "lyxal_essai", state: "running", criticality: "required", restart_count: 0, failure_count: 0 });
        fn::runtime_health_record({ node_id: $node, module_id: "lyxal_essai", status: "healthy" });
    };
    UPDATE runtime_node:n3 SET seen_at = time::now() - 8d;
    UPDATE runtime_worker SET updated_at = time::now() - 8d WHERE node_id = "n4";
    UPDATE runtime_health SET updated_at = time::now() - 8d WHERE node_id = "n4";
};

-- test: une identité sans droit ne purge rien, et la purge est refusée
-- en tant que: utilisateur
RETURN fn::runtime_node_purge({}).error.code == "RUNTIME_WRITE_FORBIDDEN";

-- test: la purge refusée n'a rien supprimé
RETURN record::exists(runtime_node:n3)
    AND count(SELECT * FROM runtime_worker WHERE node_id = "n4") == 1
    AND count(SELECT * FROM runtime_health WHERE node_id = "n4") == 1;

-- test: un délai de moins d'une minute est refusé
RETURN fn::runtime_node_purge({ older_than: 10s }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_purge({ older_than: 7 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_node_purge({ inconnu: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: un délai plus long que l'absence du nœud ne purge rien
RETURN fn::runtime_node_purge({ older_than: 30d }).data == { nodes: 0, workers: 0, health: 0 };

-- test: la purge (sept jours par défaut) retire le nœud disparu, ses lignes et les lignes sans nœud
RETURN fn::runtime_node_purge({}).data == { nodes: 1, workers: 2, health: 2 };

-- test: le nœud vivant et ses lignes sont gardés
RETURN fn::runtime_node_list({}).data.map(|$n| $n.node_id) == ["n1"]
    AND count(SELECT * FROM runtime_worker) == 1
    AND count(SELECT * FROM runtime_health) == 1;

-- ---------------------------------------------------------------------------
-- Socle installé
-- ---------------------------------------------------------------------------

-- test: sans socle enregistré, la lecture renvoie NONE
RETURN fn::runtime_foundation_get({}).ok == true AND fn::runtime_foundation_get({}).data == NONE;

-- test: sans bail d'installation du socle, l'enregistrement est refusé
RETURN fn::runtime_foundation_record({ checksum: string::repeat("a", 64), host: "lyxal_server", node_id: "n1", generation: 1 }).error.code == "RUNTIME_LEASE_FENCED";

-- test: le nœud n1 prend le bail d'installation du socle
RETURN fn::runtime_lease_acquire({ kind: "installation", key: "foundation", node_id: "n1", ttl_seconds: 600 }).data.lease.generation == 1;

-- test: un autre nœud, ou une autre génération, ne peut pas enregistrer le socle
RETURN fn::runtime_foundation_record({ checksum: string::repeat("b", 64), host: "lyxal_groupware", node_id: "n2", generation: 1 }).error.code == "RUNTIME_LEASE_FENCED"
    AND fn::runtime_foundation_record({ checksum: string::repeat("b", 64), host: "lyxal_server", node_id: "n1", generation: 2 }).error.code == "RUNTIME_LEASE_FENCED";

-- test: une identité sans droit ne peut pas enregistrer le socle
-- en tant que: utilisateur
RETURN fn::runtime_foundation_record({ checksum: string::repeat("b", 64), host: "lyxal_server", node_id: "n1", generation: 1 }).ok == false;

-- test: aucun socle n'a été enregistré par les appels refusés
RETURN fn::runtime_foundation_get({}).data == NONE;

-- test: le détenteur du bail enregistre le socle
RETURN fn::runtime_foundation_record({ checksum: string::repeat("a", 64), host: "lyxal_server", node_id: "n1", generation: 1 }).data.checksum == string::repeat("a", 64);

-- test: la lecture renvoie l'empreinte, l'hôte et le nœud qui a installé
RETURN fn::runtime_foundation_get({}).data.checksum == string::repeat("a", 64)
    AND fn::runtime_foundation_get({}).data.host == "lyxal_server"
    AND fn::runtime_foundation_get({}).data.node_id == "n1"
    AND fn::runtime_foundation_get({}).data.installed_at <= time::now();

-- test: un nouvel enregistrement remplace le précédent (un seul socle)
RETURN fn::runtime_foundation_record({ checksum: string::repeat("c", 64), host: "lyxal_server", node_id: "n1", generation: 1 }).data.checksum == string::repeat("c", 64)
    AND count(SELECT * FROM runtime_foundation) == 1;

-- test: une empreinte, un hôte ou une génération invalides sont refusés
RETURN fn::runtime_foundation_record({ checksum: "abc", host: "lyxal_server", node_id: "n1", generation: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_foundation_record({ checksum: string::repeat("a", 64), host: "Lyxal", node_id: "n1", generation: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_foundation_record({ checksum: string::repeat("a", 64), host: "lyxal_server", node_id: "n1", generation: 0 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_foundation_record({ checksum: string::repeat("a", 64), host: "lyxal_server", node_id: "n1" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_foundation_get({ inconnu: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: une identité sans droit ne lit pas le socle
-- en tant que: utilisateur
RETURN fn::runtime_foundation_get({}).data == NONE;

-- test: une identité sans droit ne peut pas effacer l'empreinte du socle
-- en tant que: utilisateur
RETURN fn::runtime_foundation_clear({ node_id: "n1", generation: 1 }).error.code == "RUNTIME_WRITE_FORBIDDEN";

-- test: un autre nœud, ou une autre génération, ne peut pas effacer l'empreinte du socle
RETURN fn::runtime_foundation_clear({ node_id: "n2", generation: 1 }).error.code == "RUNTIME_LEASE_FENCED"
    AND fn::runtime_foundation_clear({ node_id: "n1", generation: 2 }).error.code == "RUNTIME_LEASE_FENCED"
    AND fn::runtime_foundation_get({}).data.checksum == string::repeat("c", 64);

-- test: des paramètres invalides sont refusés
RETURN fn::runtime_foundation_clear({ node_id: "n1" }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_foundation_clear({ node_id: "n1", generation: 0 }).error.code == "RUNTIME_INVALID_PARAMETERS"
    AND fn::runtime_foundation_clear({ node_id: "n1", generation: 1, inconnu: 1 }).error.code == "RUNTIME_INVALID_PARAMETERS";

-- test: le détenteur du bail efface l'empreinte, puis l'efface sans erreur une seconde fois
RETURN fn::runtime_foundation_clear({ node_id: "n1", generation: 1 }).data == { cleared: true }
    AND fn::runtime_foundation_get({}).data == NONE
    AND fn::runtime_foundation_clear({ node_id: "n1", generation: 1 }).data == { cleared: false };

-- préparation: le détenteur du bail réenregistre le socle
RETURN fn::runtime_foundation_record({ checksum: string::repeat("c", 64), host: "lyxal_server", node_id: "n1", generation: 1 });

-- test: après la libération du bail, l'enregistrement est de nouveau refusé
RETURN fn::runtime_lease_release({ kind: "installation", key: "foundation", node_id: "n1", generation: 1 }).data.released == true
    AND fn::runtime_foundation_record({ checksum: string::repeat("d", 64), host: "lyxal_server", node_id: "n1", generation: 1 }).error.code == "RUNTIME_LEASE_FENCED"
    AND fn::runtime_foundation_get({}).data.checksum == string::repeat("c", 64);
