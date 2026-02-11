CREATE ticket SET 
  subject = "Connexion impossible",
  ticketType = ticket_type:3,
  ticketStatus = ticket_status:1,
  slaPolicy = sla:1,
  prioritySelect = 1;

-- Assign user
RELATE ticket:1->assigned_to->user:1;

-- Changer de statut
UPDATE ticket:1 SET ticketStatus = ticket_status:2, statusComment = "Pris en charge par support";

-- Générer suggestion IA
CREATE agent_suggestion SET 
  ticket = ticket:1, 
  suggestionType = 'next_status', 
  content = 'Passer à Resolved si réponse positive du client',
  score = 0.92;