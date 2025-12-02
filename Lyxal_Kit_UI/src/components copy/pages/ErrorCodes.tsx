import React, { memo, useState, useEffect, useMemo } from 'react';
import { useSystemConfig } from '../../hooks/useSystemConfig';
import { SurrealClient } from '../../services/SurrealClient';

/**
 * Interface pour un code d'erreur
 */
interface ErrorCode {
  id: string;
  identity: {
    code: string;
    slug: string;
    value: string;
  };
  content: {
    message_source: string;
    label_source?: string;
    description_source?: string;
    severity?: string | {
      id: string;
      identity: {
        code: string;
        value: string;
      };
      content: {
        label_source: string;
      };
      config: {
        rank: number;
      };
    };
    payload?: Record<string, any>;
  };
  presentation: {
    message_i18n?: {
      id: string;
    };
    label_i18n?: {
      id: string;
    };
    description_i18n?: {
      id: string;
    };
  };
  config: {
    success_result: boolean;
  };
  metadata: {
    category?: string;
    recommended_action?: string;
    created_by?: string;
  };
  severity?: string | {
    id: string;
    identity: {
      code: string;
      value: string;
    };
    content: {
      label_source: string;
    };
    config: {
      rank: number;
    };
  };
}

/**
 * Composant pour afficher et gérer les codes d'erreur
 */
interface ErrorSeverity {
  id: string;
  identity: {
    code: string;
    value: string;
  };
  display: {
    label: string;
    description?: string;
    message?: string;
  };
}

const ErrorCodes: React.FC = memo(() => {
  const { config, loading: configLoading } = useSystemConfig();
  const [errorCodes, setErrorCodes] = useState<ErrorCode[]>([]);
  const [severitiesList, setSeveritiesList] = useState<ErrorSeverity[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedCode, setSelectedCode] = useState<ErrorCode | null>(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterSeverity, setFilterSeverity] = useState<string>('all');

  // Charger les sévérités depuis SurrealDB
  useEffect(() => {
    const loadSeverities = async () => {
      if (configLoading) return;

      try {
        // Log de la configuration utilisée
        console.log('[ErrorCodes] Configuration SurrealDB utilisée:', {
          url: config.infrastructure.surrealDbUrl.value,
          namespace: config.infrastructure.surrealNamespace.value,
          database: config.infrastructure.surrealDatabase.value,
          username: config.infrastructure.surrealUsername.value
        });
        
        // Vérifier les fonctions disponibles dans la DB
        const infoQuery = `INFO FOR DB;`;
        const infoResult = await SurrealClient.query<any>(config, infoQuery);
        console.log('[ErrorCodes] INFO FOR DB:', JSON.stringify(infoResult, null, 2));
        
        // Récupérer la langue par défaut depuis i18n_config
        const langQuery = `SELECT config.default_language FROM i18n_config LIMIT 1`;
        const langResult = await SurrealClient.query<any[]>(config, langQuery);
        const defaultLanguageId = langResult?.[0]?.config?.default_language 
          ? String(langResult[0].config.default_language).split(':')[1] 
          : 'fr';

        // Appeler la fonction pour récupérer les sévérités
        // Utiliser SELECT * FROM pour appeler la fonction SurrealDB
        const query = `SELECT * FROM fn::get_error_severities(NONE, '${defaultLanguageId}', 'system')`;
        const result = await SurrealClient.query<any>(config, query);
        
        console.log('[ErrorCodes] Résultat brut de la fonction:', result);
        console.log('[ErrorCodes] Type du résultat:', typeof result);
        console.log('[ErrorCodes] Est un tableau?:', Array.isArray(result));
        console.log('[ErrorCodes] Longueur du résultat:', Array.isArray(result) ? result.length : 'N/A');
        
        // SurrealDB retourne les résultats dans un tableau
        // Pour une fonction qui retourne un objet, on prend le premier élément du tableau
        let functionResult: any = null;
        
        if (Array.isArray(result)) {
          if (result.length > 0) {
            // Si le premier élément est un objet avec success/data, c'est le résultat de la fonction
            if (result[0] && typeof result[0] === 'object' && 'success' in result[0]) {
              functionResult = result[0];
            } else {
              // Sinon, peut-être que c'est directement dans result[0]
              functionResult = result[0];
            }
          }
        } else if (result && typeof result === 'object') {
          // Si ce n'est pas un tableau, c'est peut-être directement l'objet
          functionResult = result;
        }
        
        console.log('[ErrorCodes] Résultat de la fonction (traité):', functionResult);
        
        // Vérifier si c'est le format attendu avec success et data
        if (functionResult?.success && Array.isArray(functionResult.data)) {
          console.log('[ErrorCodes] Données trouvées:', functionResult.data.length, 'sévérités');
          setSeveritiesList(functionResult.data);
        } else if (Array.isArray(functionResult)) {
          // Si functionResult est directement un tableau
          console.log('[ErrorCodes] Données trouvées (format direct):', functionResult.length, 'sévérités');
          setSeveritiesList(functionResult);
        } else {
          console.warn('[ErrorCodes] Format de réponse inattendu:', functionResult);
          setSeveritiesList([]);
        }
      } catch (err) {
        console.error('Erreur lors du chargement des sévérités:', err);
        setSeveritiesList([]);
      }
    };

    loadSeverities();
  }, [config, configLoading]);

  // Charger les codes d'erreur depuis SurrealDB
  useEffect(() => {
    const loadErrorCodes = async () => {
      if (configLoading) return;

      try {
        setLoading(true);
        setError(null);

        const query = `
          SELECT 
            *,
            content.severity.* AS severity
          FROM error_code
          ORDER BY identity.code ASC
        `;

        const result = await SurrealClient.query<ErrorCode[]>(config, query);
        
        if (Array.isArray(result)) {
          setErrorCodes(result);
        } else {
          setErrorCodes([]);
        }
      } catch (err) {
        console.error('Erreur lors du chargement des codes d\'erreur:', err);
        setError(err instanceof Error ? err.message : 'Erreur inconnue');
        setErrorCodes([]);
      } finally {
        setLoading(false);
      }
    };

    loadErrorCodes();
  }, [config, configLoading]);

  // Filtrer les codes d'erreur
  const filteredCodes = useMemo(() => {
    return errorCodes.filter(code => {
      const matchesSearch = 
        code.identity.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
        code.content.message_source.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (code.content.label_source?.toLowerCase().includes(searchTerm.toLowerCase()) ?? false);
      
      // Obtenir le code de sévérité
      let severityCode: string | undefined;
      if (code.severity && typeof code.severity === 'object') {
        severityCode = code.severity.identity?.code;
      } else if (code.content?.severity) {
        if (typeof code.content.severity === 'object') {
          severityCode = code.content.severity.identity?.code;
        }
      }
      const matchesSeverity = 
        filterSeverity === 'all' || 
        (severityCode && severityCode.toLowerCase() === filterSeverity.toLowerCase());
      
      return matchesSearch && matchesSeverity;
    });
  }, [errorCodes, searchTerm, filterSeverity]);


  // Obtenir la couleur de badge selon la sévérité
  const getSeverityBadgeClass = (severityCode: string): string => {
    const severityLower = severityCode.toLowerCase();
    if (severityLower.includes('critical') || severityLower.includes('error')) {
      return 'badge-error';
    }
    if (severityLower.includes('warning')) {
      return 'badge-warning';
    }
    if (severityLower.includes('info')) {
      return 'badge-info';
    }
    if (severityLower.includes('success')) {
      return 'badge-success';
    }
    return 'badge-neutral';
  };

  if (configLoading || loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <span className="loading loading-spinner loading-lg"></span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="alert alert-error">
        <svg className="w-6 h-6 shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>Erreur lors du chargement: {error}</span>
      </div>
    );
  }

  return (
    <div className="w-full flex flex-col h-full">
      {/* Container pour les filtres et la barre de recherche */}
      <div id="error-codes-filters-container" className="w-full space-y-6 mb-6">
        {/* En-tête */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold mb-2">Codes d'erreur</h1>
            <p className="text-base-content/70">
              Gestion et consultation des codes d'erreur système
            </p>
          </div>
          <div className="badge badge-lg badge-primary">
            {filteredCodes.length} {filteredCodes.length > 1 ? 'codes' : 'code'}
          </div>
        </div>

        {/* Barre de recherche et filtres */}
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <input
              type="text"
              placeholder="Rechercher un code d'erreur..."
              className="input input-bordered w-full"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div className="w-full md:w-64">
            <select
              className="select select-bordered w-full"
              value={filterSeverity}
              onChange={(e) => setFilterSeverity(e.target.value)}
            >
              <option value="all">Toutes les sévérités</option>
              {severitiesList.length > 0 ? (
                severitiesList.map(severity => (
                  <option key={severity.id} value={severity.identity.code}>
                    {severity.display.label}
                  </option>
                ))
              ) : (
                <option disabled>Aucune sévérité disponible</option>
              )}
            </select>
          </div>
        </div>
      </div>

      {/* Container pour les cards */}
      <div id="error-codes-cards-container" className="flex-1 overflow-auto">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {filteredCodes.length === 0 ? (
          <div className="col-span-2 text-center py-12">
            <p className="text-base-content/70 text-lg">
              {searchTerm || filterSeverity !== 'all' 
                ? 'Aucun code d\'erreur ne correspond aux critères de recherche'
                : 'Aucun code d\'erreur disponible'}
            </p>
          </div>
        ) : (
          filteredCodes.map((code) => (
            <div
              key={code.id}
              className={`card bg-base-100 shadow-lg cursor-pointer transition-all hover:shadow-xl ${
                selectedCode?.id === code.id ? 'ring-2 ring-primary' : ''
              }`}
              onClick={() => setSelectedCode(selectedCode?.id === code.id ? null : code)}
            >
              <div className="card-body">
                <div className="flex items-start justify-between mb-2">
                  <h2 className="card-title text-lg">
                    <code className="text-primary font-mono">{code.identity.code}</code>
                  </h2>
                  {(() => {
                    let severity: { identity: { code: string }; content: { label_source: string } } | null = null;
                    if (code.severity && typeof code.severity === 'object') {
                      severity = code.severity;
                    } else if (code.content?.severity && typeof code.content.severity === 'object') {
                      severity = code.content.severity;
                    }
                    if (!severity) return null;
                    return (
                      <div className={`badge ${getSeverityBadgeClass(severity.identity.code)}`}>
                        {severity.content.label_source}
                      </div>
                    );
                  })()}
                </div>
                
                {code.content.label_source && (
                  <p className="font-semibold text-base mb-2">
                    {code.content.label_source}
                  </p>
                )}
                
                <p className="text-sm text-base-content/70 line-clamp-2">
                  {code.content.message_source}
                </p>

                {code.metadata.category && (
                  <div className="mt-2">
                    <span className="badge badge-outline badge-sm">
                      {code.metadata.category}
                    </span>
                  </div>
                )}

                {selectedCode?.id === code.id && (
                  <div className="mt-4 pt-4 border-t border-base-300 space-y-2">
                    {code.content.description_source && (
                      <div>
                        <p className="text-xs font-semibold text-base-content/50 mb-1">Description</p>
                        <p className="text-sm">{code.content.description_source}</p>
                      </div>
                    )}
                    
                    {code.metadata.recommended_action && (
                      <div>
                        <p className="text-xs font-semibold text-base-content/50 mb-1">Action recommandée</p>
                        <p className="text-sm">{code.metadata.recommended_action}</p>
                      </div>
                    )}

                    <div className="flex gap-2 flex-wrap">
                      {(() => {
                        let severity: { identity: { code: string }; config: { rank: number } } | null = null;
                        if (code.severity && typeof code.severity === 'object') {
                          severity = code.severity;
                        } else if (code.content?.severity && typeof code.content.severity === 'object') {
                          severity = code.content.severity;
                        }
                        if (!severity) return null;
                        return (
                          <div className="badge badge-outline">
                            Sévérité: {severity.identity.code} (rang {severity.config.rank})
                          </div>
                        );
                      })()}
                      {code.config.success_result && (
                        <div className="badge badge-success">Succès</div>
                      )}
                      {code.metadata.created_by && (
                        <div className="badge badge-outline">
                          Créé par: {code.metadata.created_by}
                        </div>
                      )}
                    </div>
                  </div>
                )}
              </div>
            </div>
          ))
        )}
        </div>
      </div>
    </div>
  );
});

// Nom d'affichage pour le débogage
ErrorCodes.displayName = 'ErrorCodes';

export default ErrorCodes;

