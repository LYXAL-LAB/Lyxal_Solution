import React from 'react';
/**
 * Props pour le composant AgentIA
 * @interface AgentIAProps
 */
interface AgentIAProps {
    /** Callback appelé pour fermer l'agent IA */
    onClose: () => void;
}
/**
 * Composant AgentIA - Assistant conversationnel IA
 * Version de base avec zone de messages et zone de saisie
 * @param props - Les propriétés du composant
 * @returns JSX.Element
 */
declare const AgentIA: React.FC<AgentIAProps>;
export default AgentIA;
