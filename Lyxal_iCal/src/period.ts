import { Time } from "./time";
import { Duration } from "./duration";
import type { Property } from "./property";
import type { PeriodData } from "./types";

/**
 * This class represents the "period" value type, with various calculation
 * and manipulation methods.
 */
export class Period {
    /**
     * The start of the period
     */
    start: Time | null = null;

    /**
     * The end of the period
     */
    end: Time | null = null;

    /**
     * The duration of the period
     */
    duration: Duration | null = null;

    /**
     * The class identifier.
     */
    readonly icalclass = "icalperiod";

    /**
     * The type name, to be used in the jCal object.
     */
    readonly icaltype = "period";

    /**
     * For wrapping in jCal
     */
    wrappedJSObject: Period;

    /**
     * Creates a new Period instance from the passed string.
     */
    static fromString(str: string, prop?: Property): Period {
        const parts = str.split('/');

        if (parts.length !== 2) {
            throw new Error(
                'Invalid string value: "' + str + '" must contain a "/" char.'
            );
        }

        const options: Partial<PeriodData> = {
            start: Time.fromDateTimeString(parts[0], prop)
        };

        const end = parts[1];

        if (Duration.isValueString(end)) {
            options.duration = Duration.fromString(end);
        } else {
            options.end = Time.fromDateTimeString(end, prop);
        }

        return new Period(options as PeriodData);
    }

    /**
     * Creates a new Period instance from the given data object.
     */
    static fromData(aData?: PeriodData): Period {
        return new Period(aData);
    }

    /**
     * Returns a new period instance from the given jCal data array.
     */
    static fromJSON(aData: [string, string], aProp?: Property, aLenient?: boolean): Period {
        function fromDateOrDateTimeString(aValue: string, dateProp?: Property): Time {
            if (aLenient) {
                return Time.fromString(aValue, dateProp);
            } else {
                return Time.fromDateTimeString(aValue, dateProp);
            }
        }

        if (Duration.isValueString(aData[1])) {
            return Period.fromData({
                start: fromDateOrDateTimeString(aData[0], aProp),
                duration: Duration.fromString(aData[1])
            });
        } else {
            return Period.fromData({
                start: fromDateOrDateTimeString(aData[0], aProp),
                end: fromDateOrDateTimeString(aData[1], aProp)
            });
        }
    }

    /**
     * Creates a new Period instance.
     */
    constructor(aData?: PeriodData) {
        this.wrappedJSObject = this;

        if (aData && 'start' in aData) {
            if (aData.start && !(aData.start instanceof Time)) {
                throw new TypeError('.start must be an instance of ICAL.Time');
            }
            this.start = aData.start;
        }

        if (aData && aData.end && aData.duration) {
            throw new Error('cannot accept both end and duration');
        }

        if (aData && 'end' in aData) {
            if (aData.end && !(aData.end instanceof Time)) {
                throw new TypeError('.end must be an instance of ICAL.Time');
            }
            this.end = aData.end || null;
        }

        if (aData && 'duration' in aData) {
            if (aData.duration && !(aData.duration instanceof Duration)) {
                throw new TypeError('.duration must be an instance of ICAL.Duration');
            }
            this.duration = (aData.duration as Duration) || null;
        }
    }

    /**
     * Returns a clone of the duration object.
     */
    clone(): Period {
        return Period.fromData({
            start: this.start ? this.start.clone() : null as any,
            end: this.end ? this.end.clone() : undefined,
            duration: this.duration ? this.duration.clone() : undefined
        });
    }

    /**
     * Calculates the duration of the period.
     */
    getDuration(): Duration {
        if (this.duration) {
            return this.duration;
        } else {
            return this.end!.subtractDate(this.start!);
        }
    }

    /**
     * Calculates the end date of the period.
     */
    getEnd(): Time {
        if (this.end) {
            return this.end;
        } else {
            const end = this.start!.clone();
            end.addDuration(this.duration!);
            return end;
        }
    }

    /**
     * Compare this period with a date or other period.
     */
    compare(dt: Time | Period): number {
        if (dt.compare(this.start!) < 0) {
            return 1;
        } else if (dt.compare(this.getEnd()) > 0) {
            return -1;
        } else {
            return 0;
        }
    }

    /**
     * The string representation of this period.
     */
    toString(): string {
        return this.start + "/" + (this.end || this.duration);
    }

    /**
     * The jCal representation of this period type.
     */
    toJSON(): [string, string] {
        return [this.start!.toString(), (this.end || this.duration)!.toString()];
    }

    /**
     * The iCalendar string representation of this period.
     */
    toICALString(): string {
        return this.start!.toICALString() + "/" +
            (this.end || this.duration)!.toICALString();
    }
}

export default Period;
