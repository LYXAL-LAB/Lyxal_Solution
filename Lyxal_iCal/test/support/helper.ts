import { expect, beforeAll, afterAll } from "bun:test";
import ICAL from "../../src/index";

export const testSupport = {
    _timezones: {} as Record<string, string>,

    loadSample: async (path: string) => {
        const file = Bun.file(`./test/samples/${path}`);
        return await file.text();
    },

    load: async (path: string) => {
        const file = Bun.file(`./${path}`);
        return await file.text();
    },


    registerTimezone: async function (zoneName: string) {
        const register = (icsData: string) => {
            let parsed = ICAL.parse(icsData);
            let calendar = new ICAL.Component(parsed);
            let vtimezone = calendar.getFirstSubcomponent('vtimezone');

            if (vtimezone) {
                ICAL.TimezoneService.register(vtimezone);
            }
            return icsData;
        }

        if (this._timezones[zoneName]) {
            return register(this._timezones[zoneName]);
        } else {
            let path = 'timezones/' + zoneName + '.ics';
            let data = await this.loadSample(path);
            this._timezones[zoneName] = data;
            return register(data);
        }
    },

    useTimezones: function (...zones: string[]) {
        afterAll(() => {
            ICAL.TimezoneService.reset();
        });

        beforeAll(async () => {
            if (ICAL.TimezoneService.count > 3) {
                throw new Error("Can only register zones once");
            }
            await Promise.all(zones.map(zone => this.registerTimezone(zone)));
        });
    },

    assertHasProperties: (given: any, props: any, msg?: string) => {
        msg = (typeof (msg) === 'undefined') ? '' : msg + ': ';

        if (Array.isArray(props)) {
            props.forEach(function (prop) {
                expect(prop in given).toBeTrue();
            });
        } else {
            for (let key in props) {
                expect(given[key]).toEqual(props[key]);
            }
        }
    }
};

// Custom assertion for checking properties
export const assertHasProperties = (given: any, props: any, msg?: string) => {
    msg = (typeof (msg) === 'undefined') ? '' : msg + ': ';

    if (Array.isArray(props)) {
        props.forEach(function (prop) {
            expect(prop in given).toBeTrue();
        });
    } else {
        for (let key in props) {
            expect(given[key]).toEqual(props[key]);
        }
    }
};
