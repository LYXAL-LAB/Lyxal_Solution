import design from "./design";
import { foldline } from "./helpers";
import type { designSet } from "./types";

const LINE_ENDING = '\r\n';
const DEFAULT_VALUE_TYPE = 'unknown';
const RFC6868_REPLACE_MAP: Record<string, string> = { '"': "^'", "\n": "^n", "^": "^^" };

/**
 * Interface describing the stringify function with its attached methods
 */
export interface StringifyFunction {
    (jCal: any[]): string;
    component: (component: any[], designSet?: designSet) => string;
    property: (property: any[], designSet?: designSet, noFold?: boolean) => string;
    paramPropertyValue: (value: string, force?: boolean) => string;
    multiValue: (values: any[], delim: string, type: string, innerMulti: string | null, designSet: designSet, structuredValue?: string | boolean) => string;
    value: (value: string | number, type: string, designSet: designSet, structuredValue?: string | boolean) => string;
    _rfc6868Unescape: (val: string) => string;
}

/**
 * Internal helper for rfc6868. Exposing this on ICAL.stringify so that
 * hackers can disable the rfc6868 parsing if the really need to.
 *
 * @param val        The value to unescape
 * @return           The escaped value
 */
function _rfc6868Unescape(val: string): string {
    return val.replace(/[\n^"]/g, function (x) {
        return RFC6868_REPLACE_MAP[x];
    });
}

/**
 * Handles escaping of property values that may contain:
 *
 *    COLON (:), SEMICOLON (;), or COMMA (,)
 *
 * If any of the above are present the result is wrapped
 * in double quotes.
 *
 * @param value      Raw property value
 * @param force     If value should be escaped even when unnecessary
 * @return           Given or escaped value when needed
 */
function paramPropertyValue(value: string, force?: boolean): string {
    if (!force &&
        (value.indexOf(',') === -1) &&
        (value.indexOf(':') === -1) &&
        (value.indexOf(';') === -1)) {

        return value;
    }

    return '"' + value + '"';
}

/**
 * Processes a single ical value runs the associated "toICAL" method from the
 * design set if available.
 *
 * @param value      The value to process
 * @param type       The type of value (e.g. boolean, date-time)
 * @param designSet  The design data to use
 * @param structuredValue If the value is structured
 * @return           The processed value
 */
function stringifyValue(value: string | number, type: string, designSet: designSet, structuredValue?: string | boolean): string {
    if (type in designSet.value) {
        const valueHandler = designSet.value[type];
        if (valueHandler && valueHandler.toICAL) {
            return valueHandler.toICAL(value, typeof structuredValue === 'string' ? structuredValue : undefined);
        }
    }
    return String(value);
}

/**
 * Converts an array of ical values into a single
 * string based on a type and a delimiter value (like ",").
 *
 * @param values      List of values to convert
 * @param delim      Used to join the values (",", ";", ":")
 * @param type       Lowecase ical value type
 *        (like boolean, date-time, etc..)
 * @param innerMulti If set, each value will again be processed
 *        Used for structured values
 * @param designSet   The design data
 * @param structuredValue If the value is structured
 * @return           The iCalendar/vCard string
 */
function multiValue(values: any[], delim: string, type: string, innerMulti: string | null, designSet: designSet, structuredValue?: string | boolean): string {
    let result = '';
    let len = values.length;
    for (let i = 0; i < len; i++) {
        if (innerMulti && Array.isArray(values[i])) {
            result += multiValue(values[i], innerMulti, type, null, designSet, structuredValue);
        } else {
            result += stringifyValue(values[i], type, designSet, structuredValue);
        }

        if (i < len - 1) {
            result += delim;
        }
    }

    return result;
}

/**
 * Converts a single jCal/jCard property to a iCalendar/vCard string.
 *
 * @param property
 *        jCal/jCard property array
 * @param designSet
 *        The design data to use for this property
 * @param noFold
 *        If true, the line is not folded
 * @return       The iCalendar/vCard string
 */
function stringifyProperty(property: any[], designSet?: designSet, noFold?: boolean): string {
    let name = property[0].toUpperCase();
    let jsName = property[0];
    let params = property[1];

    if (!designSet) {
        designSet = design.defaultSet;
    }

    let groupName = params.group;
    let line;
    if (designSet.propertyGroups && groupName) {
        line = groupName.toUpperCase() + "." + name;
    } else {
        line = name;
    }


    for (let [paramName, value] of Object.entries(params)) {
        if (designSet.propertyGroups && paramName == 'group') {
            continue;
        }

        let paramDesign = designSet.param[paramName];
        let multiValueParam = paramDesign && paramDesign.multiValue;
        if (multiValueParam && Array.isArray(value)) {
            value = (value as string[]).map(function (val) {
                val = _rfc6868Unescape(val);
                val = paramPropertyValue(val, paramDesign.multiValueSeparateDQuote);
                return val;
            });
            value = multiValue(value as string[], multiValueParam, "unknown", null, designSet);
        } else {
            value = _rfc6868Unescape(value as string);
            value = paramPropertyValue(value as string);
        }

        line += ';' + paramName.toUpperCase() + '=' + value;
    }

    if (property.length === 3) {
        // If there are no values, we must assume a blank value
        return line + ':';
    }

    let valueType = property[2];

    let propDetails;
    let multiValueProp: string | boolean = false;
    let structuredValue: string | boolean = false;
    let isDefault = false;

    if (jsName in designSet.property) {
        propDetails = designSet.property[jsName];

        if ('multiValue' in propDetails) {
            multiValueProp = propDetails.multiValue || false;
        }

        if (('structuredValue' in propDetails) && Array.isArray(property[3])) {
            structuredValue = propDetails.structuredValue || false;
        }

        if ('defaultType' in propDetails) {
            if (valueType === propDetails.defaultType) {
                isDefault = true;
            }
        } else {
            if (valueType === DEFAULT_VALUE_TYPE) {
                isDefault = true;
            }
        }
    } else {
        if (valueType === DEFAULT_VALUE_TYPE) {
            isDefault = true;
        }
    }

    // push the VALUE property if type is not the default
    // for the current property.
    if (!isDefault) {
        line += ';VALUE=' + valueType.toUpperCase();
    }

    line += ':';

    if (multiValueProp && structuredValue) {
        line += multiValue(
            property[3], structuredValue as string, valueType, multiValueProp as string, designSet, structuredValue as string
        );
    } else if (multiValueProp) {
        line += multiValue(
            property.slice(3), multiValueProp as string, valueType, null, designSet, false
        );
    } else if (structuredValue) {
        line += multiValue(
            property[3], structuredValue as string, valueType, null, designSet, structuredValue as string
        );
    } else {
        line += stringifyValue(property[3], valueType, designSet, false);
    }

    return noFold ? line : foldline(line);
}

/**
 * Converts an jCal component array into a ICAL string.
 * Recursive will resolve sub-components.
 *
 * Exact component/property order is not saved all
 * properties will come before subcomponents.
 *
 * @param component
 *        jCal/jCard fragment of a component
 * @param designSet
 *        The design data to use for this component
 * @return       The iCalendar/vCard string
 */
function stringifyComponent(component: any[], designSet?: designSet): string {
    let name = component[0].toUpperCase();
    let result = 'BEGIN:' + name + LINE_ENDING;

    let props = component[1];
    let propIdx = 0;
    let propLen = props.length;

    let designSetName = component[0];
    // rfc6350 requires that in vCard 4.0 the first component is the VERSION
    // component with as value 4.0, note that 3.0 does not have this requirement.
    if (designSetName === 'vcard' && component[1].length > 0 &&
        !(component[1][0][0] === "version" && component[1][0][3] === "4.0")) {
        designSetName = "vcard3";
    }
    designSet = designSet || design.getDesignSet(designSetName);

    for (; propIdx < propLen; propIdx++) {
        result += stringifyProperty(props[propIdx], designSet) + LINE_ENDING;
    }

    // Ignore subcomponents if none exist, e.g. in vCard.
    let comps = component[2] || [];
    let compIdx = 0;
    let compLen = comps.length;

    for (; compIdx < compLen; compIdx++) {
        result += stringifyComponent(comps[compIdx], designSet) + LINE_ENDING;
    }

    result += 'END:' + name;
    return result;
}


/**
 * Convert a full jCal/jCard array into a iCalendar/vCard string.
 *
 * @param jCal    The jCal/jCard document
 * @return       The stringified iCalendar/vCard document
 */
function stringifyMain(jCal: any[]): string {
    if (typeof jCal[0] == "string") {
        // This is a single component
        jCal = [jCal];
    }

    let i = 0;
    let len = jCal.length;
    let result = '';

    for (; i < len; i++) {
        result += stringifyComponent(jCal[i]) + LINE_ENDING;
    }

    return result;
}

// Create the stringify function with all its attached methods
const stringify = stringifyMain as StringifyFunction;
stringify.component = stringifyComponent;
stringify.property = stringifyProperty;
stringify.paramPropertyValue = paramPropertyValue;
stringify.multiValue = multiValue;
stringify.value = stringifyValue;
stringify._rfc6868Unescape = _rfc6868Unescape;

export default stringify;
