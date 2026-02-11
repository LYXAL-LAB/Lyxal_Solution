import { isStrictlyNaN, trunc } from "./helpers";
import type { DurationInit } from "./types";

const DURATION_LETTERS = /([PDWHMTS]{1,1})/;
const DATA_PROPS_TO_COPY = ["weeks", "days", "hours", "minutes", "seconds", "isNegative"] as const;

/**
 * This class represents the "duration" value type, with various calculation
 * and manipulation methods.
 */
export class Duration {
    /**
     * The weeks in this duration
     */
    weeks: number = 0;

    /**
     * The days in this duration
     */
    days: number = 0;

    /**
     * The hours in this duration
     */
    hours: number = 0;

    /**
     * The minutes in this duration
     */
    minutes: number = 0;

    /**
     * The seconds in this duration
     */
    seconds: number = 0;

    /**
     * Whether the duration is negative
     */
    isNegative: boolean = false;

    /**
     * The class identifier.
     */
    readonly icalclass = "icalduration";

    /**
     * The type name, to be used in the jCal object.
     */
    readonly icaltype = "duration";

    /**
     * For wrapping in jCal
     */
    wrappedJSObject: Duration;

    /**
     * Returns a new Duration instance from the passed seconds value.
     */
    static fromSeconds(aSeconds: number): Duration {
        return new Duration().fromSeconds(aSeconds);
    }

    /**
     * Checks if the given string is an iCalendar duration value.
     */
    static isValueString(string: string): boolean {
        return string[0] === 'P' || string[1] === 'P';
    }

    /**
     * Creates a new Duration instance from the passed string.
     */
    static fromString(aStr: string): Duration {
        let pos = 0;
        const dict: Partial<DurationInit> = Object.create(null);
        let chunks = 0;
        let str = aStr;

        while ((pos = str.search(DURATION_LETTERS)) !== -1) {
            const type = str[pos];
            const numeric = str.slice(0, Math.max(0, pos));
            str = str.slice(pos + 1);

            chunks += parseDurationChunk(type, numeric, dict);
        }

        if (chunks < 2) {
            throw new Error(
                'invalid duration value: Not enough duration components in "' + aStr + '"'
            );
        }

        return new Duration(dict);
    }

    /**
     * Creates a new Duration instance from the given data object.
     */
    static fromData(aData: DurationInit): Duration {
        return new Duration(aData);
    }

    /**
     * Creates a new Duration instance.
     */
    constructor(data?: DurationInit) {
        this.wrappedJSObject = this;
        this.fromData(data);
    }

    /**
     * Returns a clone of the duration object.
     */
    clone(): Duration {
        return Duration.fromData(this);
    }

    /**
     * The duration value expressed as a number of seconds.
     */
    toSeconds(): number {
        const seconds = this.seconds + 60 * this.minutes + 3600 * this.hours +
            86400 * this.days + 7 * 86400 * this.weeks;
        return this.isNegative ? -seconds : seconds;
    }

    /**
     * Reads the passed seconds value into this duration object.
     */
    fromSeconds(aSeconds: number): Duration {
        let secs = Math.abs(aSeconds);

        this.isNegative = aSeconds < 0;
        this.days = trunc(secs / 86400);

        if (this.days % 7 == 0) {
            this.weeks = this.days / 7;
            this.days = 0;
        } else {
            this.weeks = 0;
        }

        secs -= (this.days + 7 * this.weeks) * 86400;

        this.hours = trunc(secs / 3600);
        secs -= this.hours * 3600;

        this.minutes = trunc(secs / 60);
        secs -= this.minutes * 60;

        this.seconds = secs;
        return this;
    }

    /**
     * Sets up the current instance using members from the passed data object.
     */
    fromData(aData?: DurationInit): void {
        for (const prop of DATA_PROPS_TO_COPY) {
            if (aData && prop in aData) {
                (this as any)[prop] = (aData as any)[prop];
            } else {
                (this as any)[prop] = prop === 'isNegative' ? false : 0;
            }
        }
    }

    /**
     * Resets the duration instance to the default values, i.e. PT0S
     */
    reset(): void {
        this.isNegative = false;
        this.weeks = 0;
        this.days = 0;
        this.hours = 0;
        this.minutes = 0;
        this.seconds = 0;
    }

    /**
     * Compares the duration instance with another one.
     */
    compare(aOther: Duration): number {
        const thisSeconds = this.toSeconds();
        const otherSeconds = aOther.toSeconds();
        return (thisSeconds > otherSeconds ? 1 : 0) - (thisSeconds < otherSeconds ? 1 : 0);
    }

    /**
     * Normalizes the duration instance.
     */
    normalize(): void {
        this.fromSeconds(this.toSeconds());
    }

    /**
     * The string representation of this duration.
     */
    toString(): string {
        if (this.toSeconds() == 0) {
            return "PT0S";
        }

        let str = "";
        if (this.isNegative) str += "-";
        str += "P";
        let hasWeeks = false;

        if (this.weeks) {
            if (this.days || this.hours || this.minutes || this.seconds) {
                str += (this.weeks * 7 + this.days) + "D";
            } else {
                str += this.weeks + "W";
                hasWeeks = true;
            }
        } else if (this.days) {
            str += this.days + "D";
        }

        if (!hasWeeks) {
            if (this.hours || this.minutes || this.seconds) {
                str += "T";
                if (this.hours) str += this.hours + "H";
                if (this.minutes) str += this.minutes + "M";
                if (this.seconds) str += this.seconds + "S";
            }
        }

        return str;
    }

    /**
     * The iCalendar string representation of this duration.
     */
    toICALString(): string {
        return this.toString();
    }
}

/**
 * Internal helper function to handle a chunk of a duration.
 */
function parseDurationChunk(letter: string, number: string, object: Partial<DurationInit>): number {
    let type: keyof DurationInit | undefined;

    switch (letter) {
        case 'P':
            if (number && number === '-') {
                object.isNegative = true;
            } else {
                object.isNegative = false;
            }
            break;
        case 'D':
            type = 'days';
            break;
        case 'W':
            type = 'weeks';
            break;
        case 'H':
            type = 'hours';
            break;
        case 'M':
            type = 'minutes';
            break;
        case 'S':
            type = 'seconds';
            break;
        default:
            return 0;
    }

    if (type) {
        if (!number && number !== '0') {
            throw new Error(
                'invalid duration value: Missing number before "' + letter + '"'
            );
        }
        const num = parseInt(number, 10);
        if (isStrictlyNaN(num)) {
            throw new Error(
                'invalid duration value: Invalid number "' + number + '" before "' + letter + '"'
            );
        }
        (object as any)[type] = num;
    }

    return 1;
}

export default Duration;
