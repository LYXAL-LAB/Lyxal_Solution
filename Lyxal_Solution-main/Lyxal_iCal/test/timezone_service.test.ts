import { describe, it, expect, beforeEach, beforeAll, afterEach } from "bun:test";
import ICAL from "../src/index";
import { testSupport } from "./support/helper";

describe('timezone_service', () => {
    let icsData: string;
    beforeAll(async () => {
        icsData = await testSupport.loadSample('timezones/America/Los_Angeles.ics');
    });

    let subject: typeof ICAL.TimezoneService;
    beforeEach(() => {
        subject = ICAL.TimezoneService;
        subject.reset();
    });

    afterEach(() => {
        subject.reset();
    });

    it('init', () => {
        // This tests the default behavior when the time zone service is first initialized
        subject._hard_reset();
        expect(subject.has('UTC')).toBeFalse();

        subject._hard_reset();
        expect(subject.count).toBe(0);
        expect(subject.has('UTC')).toBeFalse();

        subject._hard_reset();
        expect(subject.remove('bogus')).toBeNull();
        expect(subject.has('UTC')).toBeFalse();

        // Getting a timezone will initialize the service and set UTC
        subject._hard_reset();
        expect(subject.get('bogus')).toBeUndefined();
        expect(subject.has('UTC')).toBeTrue();
    });

    it('utc zones', () => {
        let zones = ['Z', 'UTC', 'GMT'];
        zones.forEach((tzid) => {
            expect(subject.has(tzid)).toBeTrue();
            expect(subject.get(tzid)).toEqual(ICAL.Timezone.utcTimezone);
        });
    });

    it('#reset', () => {
        let name = 'ZFOO';
        subject.register(name, ICAL.Timezone.utcTimezone);
        expect(subject.has(name)).toBeTrue();

        subject.reset();
        expect(subject.has(name)).toBeFalse();

        expect(subject.count).toBe(3);
    });

    describe('register zones', () => {
        it('when it does not exist', () => {
            let name = 'test';
            expect(subject.has(name)).toBeFalse();

            expect(subject.count).toBe(3);
            subject.register(name, ICAL.Timezone.localTimezone);
            expect(subject.count).toBe(4);
            expect(subject.has(name)).toBeTrue();
            expect(subject.get(name)).toEqual(ICAL.Timezone.localTimezone);

            subject.remove(name);
            expect(subject.has(name)).toBeFalse();
        });

        it('with invalid type', () => {
            expect(() => {
                subject.register('zzz', 'fff' as any);
            }).toThrow("timezone must be ICAL.Timezone");
        });
        it('with only invalid component', () => {
            expect(() => {
                let comp = new ICAL.Component('vtoaster');
                subject.register(comp as any);
            }).toThrow("Neither a timezone nor a name was passed");
        });

        it('override', () => {
            // don't do this but you can if you want to shoot
            // yourself in the foot.
            expect(subject.count).toBe(3);
            subject.register('Z', ICAL.Timezone.localTimezone);

            expect(subject.get('Z')).toEqual(ICAL.Timezone.localTimezone);
            expect(subject.count).toBe(3);
        });

        it('using a component', () => {
            let parsed = ICAL.parse(icsData);
            let comp = new ICAL.Component(parsed);
            let vtimezone = comp.getFirstSubcomponent('vtimezone')!;
            let tzid = vtimezone.getFirstPropertyValue('tzid') as string;

            expect(subject.count).toBe(3);
            subject.register(vtimezone);
            expect(subject.count).toBe(4);

            expect(subject.has(tzid)).toBeTrue();

            let zone = subject.get(tzid)!;

            expect(zone instanceof ICAL.Timezone).toBeTrue();
            expect(zone.tzid).toEqual(tzid);
        });
    });
});
