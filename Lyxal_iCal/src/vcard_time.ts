import UtcOffset from "./utc_offset";
import Time from "./time";
import Timezone from "./timezone";
import design from "./design";
import { pad2, strictParseInt } from "./helpers";
import type { TimeData } from "./types";

/**
 * Describes a vCard time, which has slight differences to the ICAL.Time.
 * Properties can be null if not specified, for example for dates with
 * reduced accuracy or truncation.
 *
 * Note that currently not all methods are correctly re-implemented for
 * VCardTime. For example, comparison will have undefined results when some
 * members are null.
 *
 * Also, normalization is not yet implemented for this class!
 */
export class VCardTime extends Time {
    _icaltype: string;
    icalclass: string = "vcardtime";

    /**
     * Returns a new ICAL.VCardTime instance from a date and/or time string.
     *
     * @param aValue     The string to create from
     * @param aIcalType  The type for this instance, e.g. date-and-or-time
     * @return        The date/time instance
     */
    static fromDateAndOrTimeString(aValue: string, aIcalType?: string): VCardTime {
        function part(v: string | null, s: number, e: number): number | null {
            return v ? strictParseInt(v.slice(s, s + e)) : null;
        }
        let parts = aValue.split('T');
        let dt = parts[0], tmz = parts[1];
        let splitzone = tmz ? design.vcard.value.time._splitZone!(tmz) : [];
        let zone = splitzone[0], tm = splitzone[1];

        let dtlen = dt ? dt.length : 0;
        let tmlen = tm ? tm.length : 0;

        let hasDashDate = dt && dt[0] == '-' && dt[1] == '-';
        let hasDashTime = tm && tm[0] == '-';

        let o: TimeData = {
            year: hasDashDate ? null : part(dt, 0, 4),
            month: hasDashDate && (dtlen == 4 || dtlen == 7) ? part(dt, 2, 2) : dtlen == 7 ? part(dt, 5, 2) : dtlen == 10 ? part(dt, 5, 2) : null,
            day: dtlen == 5 ? part(dt, 3, 2) : dtlen == 7 && hasDashDate ? part(dt, 5, 2) : dtlen == 10 ? part(dt, 8, 2) : null,

            hour: hasDashTime ? null : part(tm, 0, 2),
            minute: hasDashTime && tmlen == 3 ? part(tm, 1, 2) : tmlen > 4 ? hasDashTime ? part(tm, 1, 2) : part(tm, 3, 2) : null,
            second: tmlen == 4 ? part(tm, 2, 2) : tmlen == 6 ? part(tm, 4, 2) : tmlen == 8 ? part(tm, 6, 2) : null
        };

        let zoneObj: Timezone | UtcOffset | null;
        if (zone == 'Z') {
            zoneObj = Timezone.utcTimezone;
        } else if (zone && zone[3] == ':') {
            zoneObj = UtcOffset.fromString(zone);
        } else {
            zoneObj = null;
        }

        return new VCardTime(o, zoneObj, aIcalType);
    }


    /**
     * Creates a new ICAL.VCardTime instance.
     *
     * @param data                           The data for the time instance
     * @param zone               The timezone to use
     * @param icaltype                       The type for this date/time object
     */
    constructor(data?: Partial<TimeData>, zone?: Timezone | UtcOffset | null, icaltype?: string) {
        super(data, zone as Timezone); // Cast to Timezone to satisfy super constructor, though it accepts UtcOffset in logic
        this._icaltype = icaltype || "date-and-or-time";
    }

    /**
     * The type name, to be used in the jCal object.
     * @default "date-and-or-time"
     */
    get icaltype(): string {
        return this._icaltype;
    }

    /**
     * Returns a clone of the vcard date/time object.
     *
     * @return     The cloned object
     */
    clone(): VCardTime {
        return new VCardTime(this._time, this.zone, this.icaltype);
    }

    _normalize(): VCardTime {
        return this;
    }

    /**
     * @inheritdoc
     */
    utcOffset(): number {
        if (this.zone instanceof UtcOffset) {
            return this.zone.toSeconds();
        } else {
            return super.utcOffset();
        }
    }

    /**
     * Returns an RFC 6350 compliant representation of this object.
     *
     * @return         vcard date/time string
     */
    toICALString(): string {
        return design.vcard.value[this.icaltype].toICAL!(this.toString());
    }

    /**
     * The string representation of this date/time, in jCard form
     * (including : and - separators).
     * @return
     */
    toString(): string {
        let y = this.year, m = this.month, d = this.day;
        let h = this.hour, mm = this.minute, s = this.second;

        let hasYear = y !== null && y !== undefined, hasMonth = m !== null && m !== undefined, hasDay = d !== null && d !== undefined;
        let hasHour = h !== null && h !== undefined, hasMinute = mm !== null && mm !== undefined, hasSecond = s !== null && s !== undefined;

        let datepart = (hasYear ? pad2(y) + (hasMonth || hasDay ? '-' : '') : (hasMonth || hasDay ? '--' : '')) +
            (hasMonth ? pad2(m) : '') +
            (hasDay ? '-' + pad2(d) : '');
        let timepart = (hasHour ? pad2(h) : '-') + (hasHour && hasMinute ? ':' : '') +
            (hasMinute ? pad2(mm) : '') + (!hasHour && !hasMinute ? '-' : '') +
            (hasMinute && hasSecond ? ':' : '') +
            (hasSecond ? pad2(s) : '');

        let zone;
        if (this.zone === Timezone.utcTimezone) {
            zone = 'Z';
        } else if (this.zone instanceof UtcOffset) {
            zone = this.zone.toString();
        } else if (this.zone === Timezone.localTimezone) {
            zone = '';
        } else if (this.zone instanceof Timezone) {
            let offset = UtcOffset.fromSeconds(this.zone.utcOffset(this));
            zone = offset.toString();
        } else {
            zone = '';
        }

        switch (this.icaltype) {
            case "time":
                return timepart + zone;
            case "date-and-or-time":
            case "date-time":
                return datepart + (timepart == '--' ? '' : 'T' + timepart + zone);
            case "date":
                return datepart;
        }
        return null as unknown as string;
    }
}

export default VCardTime;
