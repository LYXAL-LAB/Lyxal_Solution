/**
 * Action de soumission de formulaire vers SurrealDB
 *
 * Crée ou met à jour un enregistrement dans SurrealDB
 */
export interface SubmitParams {
    table: string;
    data: any;
    operation?: 'create' | 'update';
    id?: string;
}
export interface SubmitContext {
    config?: any;
}
export declare const submitAction: (params: SubmitParams, context?: SubmitContext) => Promise<{
    success: boolean;
    error?: any;
    result?: any;
}>;
