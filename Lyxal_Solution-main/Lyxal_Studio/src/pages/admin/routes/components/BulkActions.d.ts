interface BulkActionsProps {
    selectedRoutes: string[];
    onStatusChange: (routeIds: string[], status: 'active' | 'inactive' | 'draft' | 'deprecated') => void;
    onDelete: (routeIds: string[]) => void;
    onClearSelection: () => void;
    isLoading?: boolean;
    className?: string;
}
export declare const BulkActions: ({ selectedRoutes, onStatusChange, onDelete, onClearSelection, isLoading, className }: BulkActionsProps) => import("react/jsx-runtime").JSX.Element | null;
export {};
