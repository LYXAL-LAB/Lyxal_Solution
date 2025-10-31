DEFINE INDEX ticket_seq_idx ON ticket FIELDS ticketSeq UNIQUE;
DEFINE INDEX ticket_subject_idx ON ticket FIELDS subject;
DEFINE INDEX ticket_status_idx ON ticket FIELDS ticketStatus;
DEFINE INDEX ticket_created_idx ON ticket FIELDS createdAt;
DEFINE INDEX ticket_user_idx ON ticket FIELDS assignedToUser, responsibleUser;