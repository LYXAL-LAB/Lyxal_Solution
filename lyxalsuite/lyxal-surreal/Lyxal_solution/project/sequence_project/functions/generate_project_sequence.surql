-- Fonction pour générer séquence projet
DEFINE FUNCTION fn::generate_project_sequence($sequence_id: record<sequence_project>) {
    LET $seq = (SELECT * FROM sequence_project WHERE id = $sequence_id);
    LET $next_value = string::concat(
        $seq.prefix ?? "",
        string::repeat("0", $seq.padding - string::length(string::from($seq.next_num))),
        string::from($seq.next_num),
        $seq.suffix ?? ""
    );
    UPDATE sequence_project SET next_num = next_num + increment WHERE id = $sequence_id;
    RETURN $next_value;
};