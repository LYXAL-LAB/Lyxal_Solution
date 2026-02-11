-- Fonction pour calculer la disponibilité des ressources
DEFINE FUNCTION fn::calculate_resource_availability($resource_id: record<resource>, $start_date: datetime, $end_date: datetime) {
    LET $bookings = (SELECT * FROM resource_booking 
                    WHERE resource_id = $resource_id 
                    AND from_date <= $end_date 
                    AND to_date >= $start_date);
    RETURN array::length($bookings) = 0;
};