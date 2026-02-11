
  CREATE partner_link_type SET
    name = 'Contact',
    typeSelect = 'contact_of',
    link1Name = 'Contact of',
    link2Name = 'Has contact';


  CREATE partner_link_type SET
    name = 'Affiliated company',
    typeSelect = 'affiliated_company',
    link1Name = 'Affiliated with',
    link2Name = 'Affiliated with';


  CREATE partner_link_type SET
    name = 'Reports',
    typeSelect = 'reports_to',
    link1Name = 'Reports to',
    link2Name = 'Manages';
