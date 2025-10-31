DEFINE EVENT ticket_fullname ON TABLE ticket WHEN $before.subject != $after.subject OR $before.ticketSeq != $after.ticketSeq THEN {
  LET $fullName = ($after.ticketSeq != NONE ? $after.ticketSeq + " - " : "") + $after.subject;
  UPDATE $this SET fullName = $fullName;
};

DEFINE EVENT check_sla ON TABLE ticket WHEN $after.deadlineDateT != NONE AND $after.isSlaCompleted = false AND $after.deadlineDateT < time::now() THEN {
  UPDATE $this SET isSlaCompleted = true;
};

DEFINE EVENT track_transition ON TABLE ticket WHEN $before.ticketStatus != $after.ticketStatus THEN {
  RELATE $after.id->transitioned_to->$after.ticketStatus SET changedBy = $auth.id, comment = $after.statusComment;
};