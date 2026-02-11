import Time from "./time";
import Component from "./component";
import ICALParse from "./parse";
import { clone, binsearchInsert } from "./helpers";
import type { TimeData } from "./types";

export interface TimezoneOptions {
    component?: Component | string;
    tzid?: string;
    location?: string;
    tznames?: string;
    latitude?: number;
    longitude?: number;
    [key: string]: any;
}

export interface TimezoneChange extends TimeData {
    utcOffset: number;
    prevUtcOffset: number;
    is_daylight?: boolean;
    isDate?: boolean;
}

const OPTIONS = ["tzid", "location", "tznames", "latitude", "longitude"];

/**
 * Timezone representation.
 */
export class Timezone {
    static _compare_change_fn(a: TimeData, b: TimeData): number {
        if (a.year != null && b.year != null) {
            if (a.year !== b.year) return a.year - b.year;
        }

        if (a.month != null && b.month != null) {
            if (a.month !== b.month) return a.month - b.month;
        }

        if (a.day != null && b.day != null) {
            if (a.day !== b.day) return a.day - b.day;
        }

        if (a.hour != null && b.hour != null) {
            if (a.hour !== b.hour) return a.hour - b.hour;
        }

        if (a.minute != null && b.minute != null) {
            if (a.minute !== b.minute) return a.minute - b.minute;
        }

        if (a.second != null && b.second != null) {
            if (a.second !== b.second) return a.second - b.second;
        }

        return 0;
    }
    /**
     * Convert the date/time from one zone to the next.
     *
     * @param tt                  The time to convert
     * @param from_zone       The source zone to convert from
     * @param to_zone         The target zone to convert to
     * @return                    The converted date/time object
     */
    static convert_time(tt: Time, from_zone: Timezone, to_zone: Timezone): Time | null {
        if (tt.isDate ||
            from_zone.tzid == to_zone.tzid ||
            from_zone == Timezone.localTimezone ||
            to_zone == Timezone.localTimezone) {
            tt.zone = to_zone;
            return tt;
        }

        let utcOffset = from_zone.utcOffset(tt);
        tt.adjust(0, 0, 0, - utcOffset);

        utcOffset = to_zone.utcOffset(tt);
        tt.adjust(0, 0, 0, utcOffset);

        return null;
    }

    /**
     * Creates a new ICAL.Timezone instance from the passed data object.
     *
     * @param aData options for class
     */
    static fromData(aData: TimezoneOptions | Component): Timezone {
        let tt = new Timezone(aData);
        return tt;
    }

    /**
     * The instance describing the UTC timezone
     */
    static #utcTimezone: Timezone | null = null;
    static get utcTimezone(): Timezone {
        if (!this.#utcTimezone) {
            this.#utcTimezone = new Timezone({
                tzid: "UTC"
            });
        }
        return this.#utcTimezone;
    }

    /**
     * The instance describing the local timezone
     */
    static #localTimezone: Timezone | null = null;
    static get localTimezone(): Timezone {
        if (!this.#localTimezone) {
            this.#localTimezone = new Timezone({
                tzid: "floating"
            });
        }
        return this.#localTimezone;
    }

    /**
     * Adjust a timezone change object.
     * @private
     * @param change     The timezone change object
     * @param days       The extra amount of days
     * @param hours      The extra amount of hours
     * @param minutes    The extra amount of minutes
     * @param seconds    The extra amount of seconds
     */
    static adjust_change(change: TimeData, days: number, hours: number, minutes: number, seconds: number): void {
        Time.prototype.adjust.call(
            change as any,
            days,
            hours,
            minutes,
            seconds,
            change as any
        );
    }

    static _minimumExpansionYear = -1;
    static EXTRA_COVERAGE = 5;

    wrappedJSObject: Timezone;
    tzid: string = "";
    location: string = "";
    tznames: string = "";
    latitude: number = 0.0;
    longitude: number = 0.0;
    component: Component | null = null;
    expandedUntilYear: number = 0;
    icalclass: string = "icaltimezone";
    changes: TimezoneChange[] = [];

    /**
     * Creates a new ICAL.Timezone instance, by passing in a tzid and component.
     *
     * @param data options for class
     */
    constructor(data?: TimezoneOptions | Component) {
        this.wrappedJSObject = this;
        if (data) {
            this.fromData(data);
        }
    }

    /**
     * Sets up the current instance using members from the passed data object.
     *
     * @param aData options for class
     */
    fromData(aData: TimezoneOptions | Component): Timezone {
        this.expandedUntilYear = 0;
        this.changes = [];

        if (aData instanceof Component) {
            // Either a component is passed directly
            this.component = aData;
        } else {
            // Otherwise the component may be in the data object
            if (aData && "component" in aData) {
                if (typeof aData.component == "string") {
                    // If a string was passed, parse it as a component
                    let jCal = ICALParse(aData.component);
                    this.component = new Component(jCal);
                } else if (aData.component instanceof Component) {
                    // If it was a component already, then just set it
                    this.component = aData.component;
                }
            }

            if (aData) {
                for (const option of OPTIONS) {
                    if (option in aData) {
                        (this as any)[option] = aData[option];
                    }
                }
            }
        }

        if (this.component instanceof Component && !this.tzid) {
            this.tzid = this.component.getFirstPropertyValue('tzid') as string;
        }

        return this;
    }

    /**
     * Finds the utcOffset the given time would occur in this timezone.
     *
     * @param tt         The time to check for
     * @return         utc offset in seconds
     */
    utcOffset(tt: Time): number {
        if (this == Timezone.utcTimezone || this == Timezone.localTimezone) {
            return 0;
        }

        this._ensureCoverage(tt.year);

        if (!this.changes.length) {
            return 0;
        }

        let tt_change: TimeData = {
            year: tt.year,
            month: tt.month,
            day: tt.day,
            hour: tt.hour,
            minute: tt.minute,
            second: tt.second
        };

        let change_num = this._findNearbyChange(tt_change);
        let change_num_to_use = -1;
        let step = 1;

        // TODO: replace with bin search?
        for (; ;) {
            let change = clone(this.changes[change_num], true);
            if (change.utcOffset < change.prevUtcOffset) {
                Timezone.adjust_change(change, 0, 0, 0, change.utcOffset);
            } else {
                Timezone.adjust_change(change, 0, 0, 0,
                    change.prevUtcOffset);
            }

            let cmp = Timezone._compare_change_fn(tt_change, change);

            if (cmp >= 0) {
                change_num_to_use = change_num;
            } else {
                step = -1;
            }

            if (step == -1 && change_num_to_use != -1) {
                break;
            }

            change_num += step;

            if (change_num < 0) {
                return 0;
            }

            if (change_num >= this.changes.length) {
                break;
            }
        }

        let zone_change = this.changes[change_num_to_use];
        let utcOffset_change = zone_change.utcOffset - zone_change.prevUtcOffset;

        if (utcOffset_change < 0 && change_num_to_use > 0) {
            let tmp_change = clone(zone_change, true);
            Timezone.adjust_change(tmp_change, 0, 0, 0, tmp_change.prevUtcOffset);

            if (Timezone._compare_change_fn(tt_change, tmp_change) < 0) {
                let prev_zone_change = this.changes[change_num_to_use - 1];

                let want_daylight = false; // TODO

                if (zone_change.is_daylight != want_daylight &&
                    prev_zone_change.is_daylight == want_daylight) {
                    zone_change = prev_zone_change;
                }
            }
        }

        // TODO return is_daylight?
        return zone_change.utcOffset;
    }

    _findNearbyChange(change: TimeData): number {
        // find the closest match
        let idx = binsearchInsert(
            this.changes,
            change,
            Timezone._compare_change_fn
        );

        if (idx >= this.changes.length) {
            return this.changes.length - 1;
        }

        return idx;
    }

    _ensureCoverage(aYear: number): void {
        if (Timezone._minimumExpansionYear == -1) {
            let today = Time.now();
            Timezone._minimumExpansionYear = today.year;
        }

        let changesEndYear = aYear;
        if (changesEndYear < Timezone._minimumExpansionYear) {
            changesEndYear = Timezone._minimumExpansionYear;
        }

        changesEndYear += Timezone.EXTRA_COVERAGE;

        if (!this.changes.length || this.expandedUntilYear < aYear) {
            let subcomps = this.component!.getAllSubcomponents();
            let compLen = subcomps.length;
            let compIdx = 0;

            for (; compIdx < compLen; compIdx++) {
                this._expandComponent(
                    subcomps[compIdx], changesEndYear, this.changes
                );
            }

            this.changes.sort(Timezone._compare_change_fn);
            this.expandedUntilYear = changesEndYear;
        }
    }

    _expandComponent(aComponent: Component, aYear: number, changes: TimezoneChange[]): TimezoneChange[] | null {
        if (!aComponent.hasProperty("dtstart") ||
            !aComponent.hasProperty("tzoffsetto") ||
            !aComponent.hasProperty("tzoffsetfrom")) {
            return null;
        }

        let dtstart = aComponent.getFirstProperty("dtstart")!.getFirstValue() as Time;
        let change: TimezoneChange;

        function convert_tzoffset(offset: any): number {
            return offset.factor * (offset.hours * 3600 + offset.minutes * 60);
        }

        function init_changes(): TimezoneChange {
            let changebase: Partial<TimezoneChange> = {};
            changebase.is_daylight = (aComponent.name == "daylight");
            changebase.utcOffset = convert_tzoffset(
                aComponent.getFirstProperty("tzoffsetto")!.getFirstValue()
            );

            changebase.prevUtcOffset = convert_tzoffset(
                aComponent.getFirstProperty("tzoffsetfrom")!.getFirstValue()
            );

            return changebase as TimezoneChange;
        }

        if (!aComponent.hasProperty("rrule") && !aComponent.hasProperty("rdate")) {
            change = init_changes();
            change.year = dtstart.year;
            change.month = dtstart.month;
            change.day = dtstart.day;
            change.hour = dtstart.hour;
            change.minute = dtstart.minute;
            change.second = dtstart.second;

            Timezone.adjust_change(change, 0, 0, 0, -change.prevUtcOffset);
            changes.push(change);
        } else {
            let props = aComponent.getAllProperties("rdate");
            for (let rdate of props) {
                let time = rdate.getFirstValue() as Time;
                change = init_changes();

                change.year = time.year;
                change.month = time.month;
                change.day = time.day;

                if (time.isDate) {
                    change.hour = dtstart.hour;
                    change.minute = dtstart.minute;
                    change.second = dtstart.second;

                    if (dtstart.zone != Timezone.utcTimezone) {
                        Timezone.adjust_change(change, 0, 0, 0, -change.prevUtcOffset);
                    }
                } else {
                    change.hour = time.hour;
                    change.minute = time.minute;
                    change.second = time.second;

                    if (time.zone != Timezone.utcTimezone) {
                        Timezone.adjust_change(change, 0, 0, 0, -change.prevUtcOffset);
                    }
                }

                changes.push(change);
            }

            let rrule = aComponent.getFirstProperty("rrule");

            if (rrule) {
                let rruleVal = rrule.getFirstValue() as any;
                change = init_changes();

                if (rruleVal.until && rruleVal.until.zone == Timezone.utcTimezone) {
                    rruleVal.until.adjust(0, 0, 0, change.prevUtcOffset);
                    rruleVal.until.zone = Timezone.localTimezone;
                }

                let iterator = rruleVal.iterator(dtstart);

                let occ;
                while ((occ = iterator.next())) {
                    change = init_changes();
                    if (occ.year > aYear || !occ) {
                        break;
                    }

                    change.year = occ.year;
                    change.month = occ.month;
                    change.day = occ.day;
                    change.hour = occ.hour;
                    change.minute = occ.minute;
                    change.second = occ.second;
                    change.isDate = occ.isDate;

                    Timezone.adjust_change(change, 0, 0, 0, -change.prevUtcOffset);
                    changes.push(change);
                }
            }
        }

        return changes;
    }

    /**
     * The string representation of this timezone.
     * @return
     */
    toString(): string {
        return (this.tznames ? this.tznames : this.tzid);
    }
}

export default Timezone;
