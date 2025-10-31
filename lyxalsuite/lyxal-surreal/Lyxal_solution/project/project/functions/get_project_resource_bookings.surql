-- Fonction pour obtenir les réservations de ressources d'un projet
DEFINE FUNCTION fn::get_project_resource_bookings($project_id: record<project>) {
    RETURN SELECT rb.*, r.name as resource_name, rt.name as resource_type_name
           FROM resource_booking rb
           LEFT JOIN resource r ON r.id = rb.resource_id
           LEFT JOIN resource_type rt ON rt.id = r.resource_type_id
           WHERE rb.project_id = $project_id;
};