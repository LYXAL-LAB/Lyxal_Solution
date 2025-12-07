import Timezone from "./timezone";
import Component from "./component";

let zones: Record<string, Timezone> | null = null;

/**
 * Singleton class to contain timezones.  Right now it is all manual registry in
 * the future we may use this class to download timezone information or handle
 * loading pre-expanded timezones.
 */
const TimezoneService = {
    get count(): number {
        if (zones === null) {
            return 0;
        }

        return Object.keys(zones).length;
    },

    reset: function (): void {
        zones = Object.create(null);
        let utc = Timezone.utcTimezone;

        zones!.Z = utc;
        zones!.UTC = utc;
        zones!.GMT = utc;
    },
    _hard_reset: function (): void {
        zones = null;
    },

    /**
     * Checks if timezone id has been registered.
     *
     * @param tzid     Timezone identifier (e.g. America/Los_Angeles)
     * @return        False, when not present
     */
    has: function (tzid: string): boolean {
        if (zones === null) {
            return false;
        }

        return !!zones[tzid];
    },

    /**
     * Returns a timezone by its tzid if present.
     *
     * @param tzid               Timezone identifier (e.g. America/Los_Angeles)
     * @return     The timezone, or undefined if not found
     */
    get: function (tzid: string): Timezone | undefined {
        if (zones === null) {
            this.reset();
        }

        return zones![tzid];
    },

    /**
     * Registers a timezone object or component.
     *
     * @param timezone
     *        The initialized zone or vtimezone.
     *
     * @param name
     *        The name of the timezone. Defaults to the component's TZID if not
     *        passed.
     */
    register: function (timezone: Timezone | Component | string, name?: string | Timezone): void {
        if (zones === null) {
            this.reset();
        }

        // This avoids a breaking change by the change of argument order
        // TODO remove in v3
        if (typeof timezone === "string" && name instanceof Timezone) {
            [timezone, name] = [name, timezone];
        }

        if (!name || typeof name !== 'string') {
            if (timezone instanceof Timezone) {
                name = timezone.tzid;
            } else {
                if ((timezone as Component).name === 'vtimezone') {
                    timezone = new Timezone(timezone as Component);
                    name = (timezone as Timezone).tzid;
                }
            }
        }

        if (!name) {
            throw new TypeError("Neither a timezone nor a name was passed");
        }

        if (timezone instanceof Timezone) {
            zones![name as string] = timezone;
        } else {
            throw new TypeError('timezone must be ICAL.Timezone or ICAL.Component');
        }
    },

    /**
     * Removes a timezone by its tzid from the list.
     *
     * @param tzid     Timezone identifier (e.g. America/Los_Angeles)
     * @return      The removed timezone, or null if not registered
     */
    remove: function (tzid: string): boolean | null {
        if (zones === null) {
            return null;
        }

        return (delete zones[tzid]);
    }
};

export default TimezoneService;
