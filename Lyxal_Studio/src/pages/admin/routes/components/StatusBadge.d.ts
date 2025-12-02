interface StatusBadgeProps {
    status: 'active' | 'inactive' | 'draft' | 'deprecated';
    className?: string;
}
export declare const StatusBadge: ({ status, className }: StatusBadgeProps) => import("react/jsx-runtime").JSX.Element;
export {};
