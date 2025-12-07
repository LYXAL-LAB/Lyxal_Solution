import type { Component } from "./component";
import type { Event } from "./event";
import type { Time } from "./time";
import type { Timezone } from "./timezone";

/**
 * The weekday, 1 = SUNDAY, 7 = SATURDAY
 */
export type WeekDay = 1 | 2 | 3 | 4 | 5 | 6 | 7;

/**
 * Time initialization options
 */
export interface TimeInit {
    year?: number | null;
    month?: number | null;
    day?: number | null;
    hour?: number | null;
    minute?: number | null;
    second?: number | null;
    isDate?: boolean;
    timezone?: string;
    zone?: Timezone | null;
}

/**
 * Possible frequency values for the FREQ part
 */
export type FrequencyValue =
    | "YEARLY"
    | "MONTHLY"
    | "WEEKLY"
    | "DAILY"
    | "HOURLY"
    | "MINUTELY"
    | "SECONDLY";

/**
 * Occurrence details returned by Event.getOccurrenceDetails
 */
export interface OccurrenceDetails {
    recurrenceId: Time;
    item: Event;
    startDate: Time;
    endDate: Time;
}

/**
 * The state for parsing content lines from an iCalendar/vCard string.
 */
export interface ParserState {
    designSet: DesignSet;
    stack: Component[];
    component: Component;
}

/**
 * A jCal component array
 */
export type JCalComponent = [
    string,           // Component name
    JCalProperty[],   // Properties
    JCalComponent[]   // Subcomponents
];

/**
 * A jCal property array
 */
export type JCalProperty = [
    string,                    // Property name
    Record<string, unknown>,   // Parameters
    string,                    // Value type
    ...unknown[]               // Values
];

/**
 * Value type definition
 */
export interface ValueTypeDefinition {
    matches?: RegExp;
    values?: string[];
    fromICAL?: (value: string, structuredEscape?: string) => unknown;
    toICAL?: (value: unknown, structuredEscape?: string) => string;
    decorate?: (value: unknown, prop?: unknown) => unknown;
    undecorate?: (value: unknown) => unknown;
    [key: string]: any;
}

/**
 * Parameter definition
 */
export interface ParamDefinition {
    valueType?: string;
    multiValue?: string;
    multiValueSeparateDQuote?: boolean;
    values?: string[];
    allowXName?: boolean;
    allowIanaToken?: boolean;
    matches?: RegExp;
}

/**
 * Property definition
 */
export interface PropertyDefinition {
    defaultType: string;
    allowedTypes?: string[];
    multiValue?: string;
    structuredValue?: string;
    detectType?: (value: string) => string;
}

/**
 * A designSet describes value, parameter and property data
 */
export interface DesignSet {
    name?: string;
    value: Record<string, ValueTypeDefinition>;
    param: Record<string, ParamDefinition>;
    property: Record<string, PropertyDefinition>;
    propertyGroups: boolean;
}

/**
 * Duration initialization options
 */
export interface DurationInit {
    weeks?: number;
    days?: number;
    hours?: number;
    minutes?: number;
    seconds?: number;
    isNegative?: boolean;
}

/**
 * Recurrence rule data
 */
export interface RecurData {
    freq?: FrequencyValue;
    interval?: number;
    count?: number;
    until?: Time | string;
    wkst?: WeekDay | string;
    bysecond?: number[];
    byminute?: number[];
    byhour?: number[];
    byday?: (string | number)[];
    bymonthday?: number[];
    byyearday?: number[];
    byweekno?: number[];
    bymonth?: number[];
    bysetpos?: number[];
    parts?: Record<string, (string | number)[]>;
}

/**
 * Geo location tuple [latitude, longitude]
 */
export type Geo = [number, number];

/**
 * Period data
 */
export interface PeriodData {
    start: Time | null;
    end?: Time | null;
    duration?: unknown;
}

// Placeholder export to ensure module is not empty
export const _ = {};

export type weekDay = WeekDay;
export type frequencyValues = FrequencyValue;
export type designSet = DesignSet;
export type timeInit = TimeInit;

export interface TimeData {
    year?: number | null;
    month?: number | null;
    day?: number | null;
    hour?: number | null;
    minute?: number | null;
    second?: number | null;
    isDate?: boolean;
    timezone?: string;
    zone?: Timezone | null;
}

export type byParts = Record<string, (number | string)[]>;
