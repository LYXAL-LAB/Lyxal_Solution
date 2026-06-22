---- Table proxy_cluster_load_balancing : Algorithmes de load balancing ----

DEFINE TABLE IF NOT EXISTS proxy_cluster_load_balancing
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Algorithmes de répartition de charge (Load Balancing) acceptés par le proxy";

---- Fields ----

-- Identity --

DEFINE FIELD IF NOT EXISTS identity ON TABLE proxy_cluster_load_balancing
    TYPE object
    DEFAULT {}
    COMMENT "Identité de l'algorithme";

    DEFINE FIELD IF NOT EXISTS identity.name ON TABLE proxy_cluster_load_balancing
        TYPE string
        COMMENT "Nom technique de l'algorithme";

    DEFINE FIELD IF NOT EXISTS identity.description ON TABLE proxy_cluster_load_balancing
        TYPE string
        COMMENT "Description de la façon dont le trafic est distribué";

-- Status --

DEFINE FIELD IF NOT EXISTS status ON TABLE proxy_cluster_load_balancing
    TYPE object
    DEFAULT {}
    COMMENT "Statut de prise en charge";

    DEFINE FIELD IF NOT EXISTS status.enabled ON TABLE proxy_cluster_load_balancing
        TYPE boolean
        DEFAULT true
        COMMENT "Définit si cet algorithme est actuellement supporté par l'architecture";

---- Indexes ----

DEFINE INDEX IF NOT EXISTS idx_status ON TABLE proxy_cluster_load_balancing 
    FIELDS status.enabled
    COMMENT "Index de performance pour des dashboards rapides";

DEFINE INDEX IF NOT EXISTS idx_identity ON TABLE proxy_cluster_load_balancing 
    FIELDS identity.name
    UNIQUE
    COMMENT "Index de performance pour l'unicité du nom";

---- Valeurs par défaut à créer ----

CREATE proxy_cluster_load_balancing:round_robin CONTENT 
{
     identity.name = "round_robin", 
     identity.description = "Tourniquet, distribution séquentielle du trafic", 
     status.enabled = true 
};

CREATE proxy_cluster_load_balancing:least_conn CONTENT 
{
     identity.name = "least_conn", 
     identity.description = "Le trafic est envoyé vers le serveur ayant le moins de connexions actives", 
     status.enabled = true 
};

CREATE proxy_cluster_load_balancing:random CONTENT 
{
     identity.name = "random", 
     identity.description = "Le trafic est distribué aléatoirement", 
     status.enabled = true 
};
