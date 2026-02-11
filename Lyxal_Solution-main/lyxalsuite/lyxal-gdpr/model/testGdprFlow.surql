-- 1️⃣ Création d'une requête GDPR (Access)
CREATE gdpr_request:1 SET
  typeSelect = 0,
  statusSelect = 0,
  requestDateT = time::now(),
  modelId = 10001,
  modelSelect = "contact",
  gdprRequestOrigin = gdpr_request_origin:1,
  requestComment = "User requested data access.";

-- 2️⃣ Vérifier que le label est bien généré automatiquement
SELECT label FROM gdpr_request WHERE id = gdpr_request:1.id;

-- 3️⃣ Vérifier la date de réponse calculée
SELECT dueSendingDateT FROM gdpr_request WHERE id = gdpr_request:1.id;

-- 4️⃣ Création de la réponse liée
CREATE gdpr_response:1 SET
  typeSelect = 0,
  sendingDateT = time::now(),
  responseEmailAddress = "user@example.com",
  responseMessage = message:1,
  dataFile = meta_file:1,
  anonymizationResult = "No anonymization needed.";

-- 5️⃣ Lier la réponse à la requête
UPDATE gdpr_request:1 SET gdprResponse = gdpr_response:1;

-- 6️⃣ Création d’un log d’effacement
CREATE gdpr_erasure_log:1 SET
  modelLog = meta_model:1,
  numberOfrecords = 3,
  gdprResponse = gdpr_response:1;

-- 7️⃣ Log de traitement
CREATE gdpr_processing_register:1 SET name = "Demo Registre", code = "DEMO1", retentionPeriod = 12, status = 1;
CREATE gdpr_processing_register_log:1 SET
  gdprProcessingRegister = gdpr_processing_register:1,
  processingDateT = time::now(),
  nbProcessed = 1;
