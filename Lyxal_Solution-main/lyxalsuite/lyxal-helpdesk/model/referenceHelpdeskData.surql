CREATE ticket_status:1 SET name = 'New', sequence = 1, priority = 1;
CREATE ticket_status:2 SET name = 'In Progress', sequence = 2, priority = 2;
CREATE ticket_status:3 SET name = 'Resolved', sequence = 3, priority = 3;
CREATE ticket_status:4 SET name = 'Closed', sequence = 4, priority = 4;

CREATE ticket_type:1 SET name = 'Bug';
CREATE ticket_type:2 SET name = 'Feature Request';
CREATE ticket_type:3 SET name = 'Incident';

CREATE sla:1 SET name = 'SLA 24h', ticketType = ticket_type:1, reachStageTicketStatus = ticket_status:3, days = 1;