//  Type de création d'une requête RGPD
export type CreateGdprRequestInput = {
    typeSelect: 0 | 1;
    modelId: number;
    modelSelect: string;
    requestComment?: string;
    gdprRequestOrigin: string; // ID ex: gdpr_request_origin:1
    requestDateT: Date;
    dueSendingDateT: Date;
    statusSelect: number;
    label?: string;
  };
  
  //  Type de mise à jour d'une requête RGPD
  export type UpdateGdprRequestInput = {
    statusSelect?: '0' | '1' | '2' | '3';
    requestComment?: string;
  };
  
  //  Type de création d'une réponse RGPD
  export type CreateGdprResponseInput = {
    responseEmailAddress: string;
    anonymizationResult?: string;
    messageId?: string; // ID ex: message:1
    fileId?: string;    // ID ex: meta_file:1
  };
  
  //  Données d'une requête RGPD
  export type GdprRequest = {
    id: string;
    typeSelect: 0 | 1;
    modelId: number;
    modelSelect: string;
    statusSelect: '0' | '1' | '2' | '3';
    requestDateT: string;
    dueSendingDateT?: string;
    requestComment?: string;
    gdprResponse?: string;
    label?: string;
  };
  
  //  Données d'une réponse RGPD
  export type GdprResponse = {
    id: string;
    typeSelect: 0 | 1;
    sendingDateT: string;
    responseEmailAddress: string;
    anonymizationResult?: string;
  };
  
  //  Log RGPD
  export type GdprLog = {
    id: string;
    modelLog: string;
    numberOfrecords: number;
    gdprResponse: string;
  };
  