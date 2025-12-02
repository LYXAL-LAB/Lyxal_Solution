interface SearchFiltersProps {
    filters: {
        search: string;
        status: string;
        permission: string;
    };
    onFiltersChange: (filters: {
        search: string;
        status: string;
        permission: string;
    }) => void;
    totalResults: number;
    className?: string;
}
export declare const SearchFilters: ({ filters, onFiltersChange, totalResults, className }: SearchFiltersProps) => import("react/jsx-runtime").JSX.Element;
export {};
