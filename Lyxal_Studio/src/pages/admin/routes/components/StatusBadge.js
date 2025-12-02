import { jsx as _jsx } from "react/jsx-runtime";
import { Badge } from '@/components/ui/badge';
const STATUS_CONFIG = {
    active: {
        label: 'Active',
        className: 'bg-green-100 text-green-800 border-green-200 hover:bg-green-200'
    },
    inactive: {
        label: 'Inactive',
        className: 'bg-gray-100 text-gray-800 border-gray-200 hover:bg-gray-200'
    },
    draft: {
        label: 'Draft',
        className: 'bg-yellow-100 text-yellow-800 border-yellow-200 hover:bg-yellow-200'
    },
    deprecated: {
        label: 'Deprecated',
        className: 'bg-red-100 text-red-800 border-red-200 hover:bg-red-200'
    }
};
export const StatusBadge = ({ status, className = '' }) => {
    const config = STATUS_CONFIG[status];
    return (_jsx(Badge, { variant: "outline", className: `${config.className} ${className}`, children: config.label }));
};
