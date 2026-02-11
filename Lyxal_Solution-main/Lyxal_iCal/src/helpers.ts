import TimezoneService from "./timezone_service";
import type { Component } from "./component";
import ICAL from "./module";

/**
 * Helper functions used in various places within ical.js
 * @module ICAL.helpers
 */

/**
 * Compiles a list of all referenced TZIDs in all subcomponents and
 * removes any extra VTIMEZONE subcomponents. In addition, if any TZIDs
 * are referenced by a component, but a VTIMEZONE does not exist,
 * an attempt will be made to generate a VTIMEZONE using ICAL.TimezoneService.
 */
export function updateTimezones(vcal: Component): Component {
    if (!vcal || vcal.name !== "vcalendar") {
        return vcal;
    }

    const allsubs = vcal.getAllSubcomponents();
    let properties: any[] = [];
    const vtimezones: Record<string, Component> = {};

    for (let i = 0; i < allsubs.length; i++) {
        if (allsubs[i].name === "vtimezone") {
            const tzid = allsubs[i].getFirstProperty("tzid")?.getFirstValue() as string;
            if (tzid) {
                vtimezones[tzid] = allsubs[i];
            }
        } else {
            properties = properties.concat(allsubs[i].getAllProperties());
        }
    }

    const reqTzid: Record<string, boolean> = {};
    for (let i = 0; i < properties.length; i++) {
        const tzid = properties[i].getParameter("tzid") as string;
        if (tzid) {
            reqTzid[tzid] = true;
        }
    }

    for (const [tzid, comp] of Object.entries(vtimezones)) {
        if (!reqTzid[tzid]) {
            vcal.removeSubcomponent(comp);
        }
    }

    for (const tzid of Object.keys(reqTzid)) {
        const tz = TimezoneService.get(tzid);
        if (!vtimezones[tzid] && tz && tz.component) {
            vcal.addSubcomponent(tz.component);
        }
    }

    return vcal;
}

/**
 * Checks if the given type is of the number type and also NaN.
 */
export function isStrictlyNaN(number: unknown): boolean {
    return typeof number === 'number' && isNaN(number);
}

/**
 * Parses a string value that is expected to be an integer, when the valid is
 * not an integer throws a decoration error.
 */
export function strictParseInt(string: string): number {
    const result = parseInt(string, 10);

    if (isStrictlyNaN(result)) {
        throw new Error(
            'Could not extract integer from "' + string + '"'
        );
    }

    return result;
}

/**
 * Creates or returns a class instance of a given type with the initialization
 * data if the data is not already an instance of the given type.
 */
export function formatClassType<T>(data: T | undefined, type: new (data: any) => T): T | undefined {
    if (typeof data === 'undefined') {
        return undefined;
    }

    if (data instanceof type) {
        return data;
    }
    return new type(data);
}

/**
 * Identical to indexOf but will only match values when they are not preceded
 * by a backslash character.
 */
export function unescapedIndexOf(buffer: string, search: string, pos: number): number {
    while ((pos = buffer.indexOf(search, pos)) !== -1) {
        if (pos > 0 && buffer[pos - 1] === '\\') {
            pos += 1;
        } else {
            return pos;
        }
    }
    return -1;
}

/**
 * Find the index for insertion using binary search.
 */
export function binsearchInsert<T>(list: T[], seekVal: T, cmpfunc: (a: T, b: T) => number): number {
    if (!list.length)
        return 0;

    let low = 0, high = list.length - 1;
    let mid: number, cmpval: number = 0;

    while (low <= high) {
        mid = low + Math.floor((high - low) / 2);
        cmpval = cmpfunc(seekVal, list[mid]);

        if (cmpval < 0)
            high = mid - 1;
        else if (cmpval > 0)
            low = mid + 1;
        else
            break;
    }

    if (cmpval < 0)
        return mid!;
    else if (cmpval > 0)
        return mid! + 1;
    else
        return mid!;
}

interface Cloneable {
    clone(): unknown;
}

/**
 * Clone the passed object or primitive. By default a shallow clone will be
 * executed.
 */
export function clone<T>(aSrc: T, aDeep?: boolean): T {
    if (!aSrc || typeof aSrc != "object") {
        return aSrc;
    } else if (aSrc instanceof Date) {
        return new Date(aSrc.getTime()) as unknown as T;
    } else if ("clone" in (aSrc as object)) {
        return (aSrc as unknown as Cloneable).clone() as T;
    } else if (Array.isArray(aSrc)) {
        const arr: unknown[] = [];
        for (let i = 0; i < aSrc.length; i++) {
            arr.push(aDeep ? clone(aSrc[i], true) : aSrc[i]);
        }
        return arr as unknown as T;
    } else {
        const obj: Record<string, unknown> = {};
        for (const [name, value] of Object.entries(aSrc as object)) {
            if (aDeep) {
                obj[name] = clone(value, true);
            } else {
                obj[name] = value;
            }
        }
        return obj as T;
    }
}

/**
 * Performs iCalendar line folding. A line ending character is inserted and
 * the next line begins with a whitespace.
 */
export function foldline(aLine: string): string {
    let result = "";
    let line = aLine || "", pos = 0, line_length = 0;

    while (line.length) {
        const cp = line.codePointAt(pos);
        if (!cp) break;

        if (cp < 128) ++line_length;
        else if (cp < 2048) line_length += 2;
        else if (cp < 65536) line_length += 3;
        else line_length += 4;

        if (line_length < ICAL.foldLength + 1)
            pos += cp > 65535 ? 2 : 1;
        else {
            result += ICAL.newLineChar + " " + line.slice(0, Math.max(0, pos));
            line = line.slice(Math.max(0, pos));
            pos = line_length = 0;
        }
    }
    result += ICAL.newLineChar + " " + line;
    return result.slice(ICAL.newLineChar.length + 1);
}

/**
 * Pads the given string or number with zeros so it will have at least two
 * characters.
 */
export function pad2(data: string | number): string {
    if (typeof data !== 'string') {
        if (typeof data === 'number') {
            data = parseInt(String(data));
        }
        data = String(data);
    }

    const len = data.length;

    switch (len) {
        case 0:
            return '00';
        case 1:
            return '0' + data;
        default:
            return data;
    }
}

/**
 * Truncates the given number, correctly handling negative numbers.
 */
export function trunc(number: number): number {
    return (number < 0 ? Math.ceil(number) : Math.floor(number));
}

/**
 * Poor-man's cross-browser object extension.
 */
export function extend<T extends object, U extends object>(source: T, target: U): T & U {
    for (const key in source) {
        const descr = Object.getOwnPropertyDescriptor(source, key);
        if (descr && !Object.getOwnPropertyDescriptor(target, key)) {
            Object.defineProperty(target, key, descr);
        }
    }
    return target as T & U;
}
