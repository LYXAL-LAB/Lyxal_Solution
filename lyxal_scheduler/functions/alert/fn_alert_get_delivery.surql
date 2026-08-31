-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_get_delivery                                      │
-- │  Récupère une livraison d'alerte par son identifiant.                   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_get_delivery(
    $delivery_id: string
) {
    LET $d_id = type::record('scheduler_alert_delivery', $delivery_id);
    RETURN (SELECT * FROM $d_id)[0];
};
