DEFINE TABLE purchased SCHEMAFULL TYPE RELATION FROM user TO product;
DEFINE FIELD subscriptionId ON purchased TYPE option<string>;
DEFINE FIELD customerId ON purchased TYPE option<string>;
DEFINE FIELD createdAt ON purchased TYPE datetime DEFAULT time::now();
