import { describe, it, expect } from "bun:test";
import ICAL from "../src/index";
import { testSupport } from "./support/helper";

describe('vcard time', () => {
    // Lots of things are also covered in the design test

    describe('initialization', () => {
        it('default icaltype', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-01');
            expect(subject.icaltype).toEqual('date-and-or-time');
        });

        it('clone', () => {
            let orig = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-02T03:04:05-08:00', 'date-time');
            let subject = orig.clone();

            orig.day++;
            orig.month++;
            orig.year++;
            orig.hour++;
            orig.minute++;
            orig.second++;
            orig.zone = ICAL.Timezone.utcTimezone;

            expect(orig.toString()).toEqual('2016-02-03T04:05:06Z');
            expect(subject.toString()).toEqual('2015-01-02T03:04:05-08:00');
            expect(subject.icaltype).toEqual('date-time');
            expect(subject.zone!.toString()).toEqual('-08:00');
        });
    });

    describe('#utcOffset', () => {
        testSupport.useTimezones('America/New_York');

        it('floating and utc', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-02T03:04:05', 'date-time');
            subject.zone = ICAL.Timezone.utcTimezone;
            expect(subject.utcOffset()).toBe(0);

            subject.zone = ICAL.Timezone.localTimezone;
            expect(subject.utcOffset()).toBe(0);
        });
        it('ICAL.UtcOffset', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-02T03:04:05-08:00', 'date-time');
            expect(subject.utcOffset()).toBe(-28800);
        });
        it('Olson timezone', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-02T03:04:05');
            subject.zone = ICAL.TimezoneService.get('America/New_York')!;
            expect(subject.utcOffset()).toBe(-18000);
        });
    });

    describe('#toString', () => {
        testSupport.useTimezones('America/New_York');

        it('invalid icaltype', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-01', 'ballparkfigure' as any);
            expect(subject.toString()).toBeNull();
        });
        it('invalid timezone', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-01T01:01:01');
            subject.zone = null;
            expect(subject.toString()).toEqual('2015-01-01T01:01:01');
        });
        it('Olson timezone', () => {
            let subject = ICAL.VCardTime.fromDateAndOrTimeString('2015-01-02T03:04:05');
            subject.zone = ICAL.TimezoneService.get('America/New_York')!;
            expect(subject.toString()).toEqual('2015-01-02T03:04:05-05:00');
        });
    });
});
