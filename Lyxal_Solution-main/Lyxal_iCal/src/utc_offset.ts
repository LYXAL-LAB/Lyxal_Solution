import { strictParseInt, trunc, pad2 } from "./helpers";

export interface UtcOffsetData {
    hours?: number;
    minutes?: number;
    factor?: 1 | -1;
}

/**
 * This class represents the "utc-offset" value type, with various calculation
 * and manipulation methods.
 */
export class UtcOffset {
    /**
     * The hours in the utc-offset
     */
    hours: number = 0;

    /**
     * The minutes in the utc-offset
     */
    minutes: number = 0;

    /**
     * The sign of the utc offset, 1 for positive offset, -1 for negative offsets.
     */
    factor: 1 | -1 = 1;

    /**
     * The type name, to be used in the jCal object.
     */
    readonly icaltype = "utc-offset";

    /**
     * Creates a new UtcOffset instance from the passed string.
     */
    static fromString(aString: string): UtcOffset {
        const options: UtcOffsetData = {};
        options.factor = aString[0] === '+' ? 1 : -1;
        options.hours = strictParseInt(aString.slice(1, 3));
        options.minutes = strictParseInt(aString.slice(4, 6));

        return new UtcOffset(options);
    }

    /**
     * Creates a new UtcOffset instance from the passed seconds value.
     */
    static fromSeconds(aSeconds: number): UtcOffset {
        const instance = new UtcOffset();
        instance.fromSeconds(aSeconds);
        return instance;
    }

    /**
     * Creates a new UtcOffset instance.
     */
    constructor(aData?: UtcOffsetData) {
        this.fromData(aData);
    }

    /**
     * Returns a clone of the utc offset object.
     */
    clone(): UtcOffset {
        return UtcOffset.fromSeconds(this.toSeconds());
    }

    /**
     * Sets up the current instance using members from the passed data object.
     */
    fromData(aData?: UtcOffsetData): void {
        if (aData) {
            for (const [key, value] of Object.entries(aData)) {
                (this as any)[key] = value;
            }
        }
        this._normalize();
    }

    /**
     * Sets up the current instance from the given seconds value.
     */
    fromSeconds(aSeconds: number): UtcOffset {
        let secs = Math.abs(aSeconds);

        this.factor = aSeconds < 0 ? -1 : 1;
        this.hours = trunc(secs / 3600);

        secs -= this.hours * 3600;
        this.minutes = trunc(secs / 60);
        return this;
    }

    /**
     * Convert the current offset to a value in seconds
     */
    toSeconds(): number {
        return this.factor * (60 * this.minutes + 3600 * this.hours);
    }

    /**
     * Compare this utc offset with another one.
     */
    compare(other: UtcOffset): number {
        const a = this.toSeconds();
        const b = other.toSeconds();
        return (a > b ? 1 : 0) - (b > a ? 1 : 0);
    }

    private _normalize(): void {
        let secs = this.toSeconds();
        const factor = this.factor;

        while (secs < -43200) { // = UTC-12:00
            secs += 97200;
        }
        while (secs > 50400) { // = UTC+14:00
            secs -= 97200;
        }

        this.fromSeconds(secs);

        // Avoid changing the factor when on zero seconds
        if (secs == 0) {
            this.factor = factor;
        }
    }

    /**
     * The iCalendar string representation of this utc-offset.
     */
    toICALString(): string {
        // Simplified - remove dependency on design for now
        const str = this.toString();
        // -05:00 -> -0500
        return str.slice(0, 3) + str.slice(4, 6);
    }

    /**
     * The string representation of this utc-offset.
     */
    toString(): string {
        return (this.factor == 1 ? "+" : "-") + pad2(this.hours) + ':' + pad2(this.minutes);
    }
}

export default UtcOffset;
