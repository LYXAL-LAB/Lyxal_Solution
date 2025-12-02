export type PrimitiveType =
  | 'string'
  | 'number'
  | 'boolean'
  | 'object'
  | 'array'
  | 'date'
  | 'record'
  | 'any'
  | 'null';

export interface OperatorArg {
  name: string;                    // arg name, e.g. "days"
  type: PrimitiveType | PrimitiveType[]; // expected type(s)
  required?: boolean;              // default false
  description?: string;
  default?: any;
  // For Studio form-building:
  ui?: {
    label?: string;
    placeholder?: string;
    widget?: 'text' | 'textarea' | 'number' | 'switch' | 'select' | 'json' | 'date' | 'code' | 'autocomplete';
    options?: Array<{ label: string; value: any }>;
    example?: any;
  };
}
