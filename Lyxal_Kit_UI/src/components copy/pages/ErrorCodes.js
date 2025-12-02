import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { memo, useState, useEffect, useMemo } from 'react';
import { useSystemConfig } from '../../hooks/useSystemConfig';
import { SurrealClient } from '../../services/SurrealClient';
const ErrorCodes = memo(() => {
    const { config, loading: configLoading } = useSystemConfig();
    const [errorCodes, setErrorCodes] = useState([]);
    const [severitiesList, setSeveritiesList] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [selectedCode, setSelectedCode] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterSeverity, setFilterSeverity] = useState('all');
    // Charger les sévérités depuis SurrealDB
    useEffect(() => {
        const loadSeverities = async () => {
            if (configLoading)
                return;
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
                const infoResult = await SurrealClient.query(config, infoQuery);
                console.log('[ErrorCodes] INFO FOR DB:', JSON.stringify(infoResult, null, 2));
                // Récupérer la langue par défaut depuis i18n_config
                const langQuery = `SELECT config.default_language FROM i18n_config LIMIT 1`;
                const langResult = await SurrealClient.query(config, langQuery);
                const defaultLanguageId = langResult?.[0]?.config?.default_language
                    ? String(langResult[0].config.default_language).split(':')[1]
                    : 'fr';
                // Appeler la fonction pour récupérer les sévérités
                // Utiliser SELECT * FROM pour appeler la fonction SurrealDB
                const query = `SELECT * FROM fn::get_error_severities(NONE, '${defaultLanguageId}', 'system')`;
                const result = await SurrealClient.query(config, query);
                console.log('[ErrorCodes] Résultat brut de la fonction:', result);
                console.log('[ErrorCodes] Type du résultat:', typeof result);
                console.log('[ErrorCodes] Est un tableau?:', Array.isArray(result));
                console.log('[ErrorCodes] Longueur du résultat:', Array.isArray(result) ? result.length : 'N/A');
                // SurrealDB retourne les résultats dans un tableau
                // Pour une fonction qui retourne un objet, on prend le premier élément du tableau
                let functionResult = null;
                if (Array.isArray(result)) {
                    if (result.length > 0) {
                        // Si le premier élément est un objet avec success/data, c'est le résultat de la fonction
                        if (result[0] && typeof result[0] === 'object' && 'success' in result[0]) {
                            functionResult = result[0];
                        }
                        else {
                            // Sinon, peut-être que c'est directement dans result[0]
                            functionResult = result[0];
                        }
                    }
                }
                else if (result && typeof result === 'object') {
                    // Si ce n'est pas un tableau, c'est peut-être directement l'objet
                    functionResult = result;
                }
                console.log('[ErrorCodes] Résultat de la fonction (traité):', functionResult);
                // Vérifier si c'est le format attendu avec success et data
                if (functionResult?.success && Array.isArray(functionResult.data)) {
                    console.log('[ErrorCodes] Données trouvées:', functionResult.data.length, 'sévérités');
                    setSeveritiesList(functionResult.data);
                }
                else if (Array.isArray(functionResult)) {
                    // Si functionResult est directement un tableau
                    console.log('[ErrorCodes] Données trouvées (format direct):', functionResult.length, 'sévérités');
                    setSeveritiesList(functionResult);
                }
                else {
                    console.warn('[ErrorCodes] Format de réponse inattendu:', functionResult);
                    setSeveritiesList([]);
                }
            }
            catch (err) {
                console.error('Erreur lors du chargement des sévérités:', err);
                setSeveritiesList([]);
            }
        };
        loadSeverities();
    }, [config, configLoading]);
    // Charger les codes d'erreur depuis SurrealDB
    useEffect(() => {
        const loadErrorCodes = async () => {
            if (configLoading)
                return;
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
                const result = await SurrealClient.query(config, query);
                if (Array.isArray(result)) {
                    setErrorCodes(result);
                }
                else {
                    setErrorCodes([]);
                }
            }
            catch (err) {
                console.error('Erreur lors du chargement des codes d\'erreur:', err);
                setError(err instanceof Error ? err.message : 'Erreur inconnue');
                setErrorCodes([]);
            }
            finally {
                setLoading(false);
            }
        };
        loadErrorCodes();
    }, [config, configLoading]);
    // Filtrer les codes d'erreur
    const filteredCodes = useMemo(() => {
        return errorCodes.filter(code => {
            const matchesSearch = code.identity.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
                code.content.message_source.toLowerCase().includes(searchTerm.toLowerCase()) ||
                (code.content.label_source?.toLowerCase().includes(searchTerm.toLowerCase()) ?? false);
            // Obtenir le code de sévérité
            let severityCode;
            if (code.severity && typeof code.severity === 'object') {
                severityCode = code.severity.identity?.code;
            }
            else if (code.content?.severity) {
                if (typeof code.content.severity === 'object') {
                    severityCode = code.content.severity.identity?.code;
                }
            }
            const matchesSeverity = filterSeverity === 'all' ||
                (severityCode && severityCode.toLowerCase() === filterSeverity.toLowerCase());
            return matchesSearch && matchesSeverity;
        });
    }, [errorCodes, searchTerm, filterSeverity]);
    // Obtenir la couleur de badge selon la sévérité
    const getSeverityBadgeClass = (severityCode) => {
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
        return (_jsx("div", { className: "flex items-center justify-center h-full", children: _jsx("span", { className: "loading loading-spinner loading-lg" }) }));
    }
    if (error) {
        return (_jsxs("div", { className: "alert alert-error", children: [_jsx("svg", { className: "w-6 h-6 shrink-0", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: _jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: "2", d: "M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" }) }), _jsxs("span", { children: ["Erreur lors du chargement: ", error] })] }));
    }
    return (_jsxs("div", { className: "w-full flex flex-col h-full", children: [_jsxs("div", { id: "error-codes-filters-container", className: "w-full space-y-6 mb-6", children: [_jsxs("div", { className: "flex flex-col md:flex-row md:items-center md:justify-between gap-4", children: [_jsxs("div", { children: [_jsx("h1", { className: "text-3xl font-bold mb-2", children: "Codes d'erreur" }), _jsx("p", { className: "text-base-content/70", children: "Gestion et consultation des codes d'erreur syst\u00E8me" })] }), _jsxs("div", { className: "badge badge-lg badge-primary", children: [filteredCodes.length, " ", filteredCodes.length > 1 ? 'codes' : 'code'] })] }), _jsxs("div", { className: "flex flex-col md:flex-row gap-4", children: [_jsx("div", { className: "flex-1", children: _jsx("input", { type: "text", placeholder: "Rechercher un code d'erreur...", className: "input input-bordered w-full", value: searchTerm, onChange: (e) => setSearchTerm(e.target.value) }) }), _jsx("div", { className: "w-full md:w-64", children: _jsxs("select", { className: "select select-bordered w-full", value: filterSeverity, onChange: (e) => setFilterSeverity(e.target.value), children: [_jsx("option", { value: "all", children: "Toutes les s\u00E9v\u00E9rit\u00E9s" }), severitiesList.length > 0 ? (severitiesList.map(severity => (_jsx("option", { value: severity.identity.code, children: severity.display.label }, severity.id)))) : (_jsx("option", { disabled: true, children: "Aucune s\u00E9v\u00E9rit\u00E9 disponible" }))] }) })] })] }), _jsx("div", { id: "error-codes-cards-container", className: "flex-1 overflow-auto", children: _jsx("div", { className: "grid grid-cols-1 lg:grid-cols-2 gap-4", children: filteredCodes.length === 0 ? (_jsx("div", { className: "col-span-2 text-center py-12", children: _jsx("p", { className: "text-base-content/70 text-lg", children: searchTerm || filterSeverity !== 'all'
                                ? 'Aucun code d\'erreur ne correspond aux critères de recherche'
                                : 'Aucun code d\'erreur disponible' }) })) : (filteredCodes.map((code) => (_jsx("div", { className: `card bg-base-100 shadow-lg cursor-pointer transition-all hover:shadow-xl ${selectedCode?.id === code.id ? 'ring-2 ring-primary' : ''}`, onClick: () => setSelectedCode(selectedCode?.id === code.id ? null : code), children: _jsxs("div", { className: "card-body", children: [_jsxs("div", { className: "flex items-start justify-between mb-2", children: [_jsx("h2", { className: "card-title text-lg", children: _jsx("code", { className: "text-primary font-mono", children: code.identity.code }) }), (() => {
                                            let severity = null;
                                            if (code.severity && typeof code.severity === 'object') {
                                                severity = code.severity;
                                            }
                                            else if (code.content?.severity && typeof code.content.severity === 'object') {
                                                severity = code.content.severity;
                                            }
                                            if (!severity)
                                                return null;
                                            return (_jsx("div", { className: `badge ${getSeverityBadgeClass(severity.identity.code)}`, children: severity.content.label_source }));
                                        })()] }), code.content.label_source && (_jsx("p", { className: "font-semibold text-base mb-2", children: code.content.label_source })), _jsx("p", { className: "text-sm text-base-content/70 line-clamp-2", children: code.content.message_source }), code.metadata.category && (_jsx("div", { className: "mt-2", children: _jsx("span", { className: "badge badge-outline badge-sm", children: code.metadata.category }) })), selectedCode?.id === code.id && (_jsxs("div", { className: "mt-4 pt-4 border-t border-base-300 space-y-2", children: [code.content.description_source && (_jsxs("div", { children: [_jsx("p", { className: "text-xs font-semibold text-base-content/50 mb-1", children: "Description" }), _jsx("p", { className: "text-sm", children: code.content.description_source })] })), code.metadata.recommended_action && (_jsxs("div", { children: [_jsx("p", { className: "text-xs font-semibold text-base-content/50 mb-1", children: "Action recommand\u00E9e" }), _jsx("p", { className: "text-sm", children: code.metadata.recommended_action })] })), _jsxs("div", { className: "flex gap-2 flex-wrap", children: [(() => {
                                                    let severity = null;
                                                    if (code.severity && typeof code.severity === 'object') {
                                                        severity = code.severity;
                                                    }
                                                    else if (code.content?.severity && typeof code.content.severity === 'object') {
                                                        severity = code.content.severity;
                                                    }
                                                    if (!severity)
                                                        return null;
                                                    return (_jsxs("div", { className: "badge badge-outline", children: ["S\u00E9v\u00E9rit\u00E9: ", severity.identity.code, " (rang ", severity.config.rank, ")"] }));
                                                })(), code.config.success_result && (_jsx("div", { className: "badge badge-success", children: "Succ\u00E8s" })), code.metadata.created_by && (_jsxs("div", { className: "badge badge-outline", children: ["Cr\u00E9\u00E9 par: ", code.metadata.created_by] }))] })] }))] }) }, code.id)))) }) })] }));
});
// Nom d'affichage pour le débogage
ErrorCodes.displayName = 'ErrorCodes';
export default ErrorCodes;
