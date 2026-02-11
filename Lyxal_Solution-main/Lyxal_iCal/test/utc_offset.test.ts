import { describe, it, expect } from "bun:test";
import ICAL from "../src/index";
import { assertHasProperties } from "./support/helper";

describe('ICAL.UtcOffset', () => {
    it('#clone', () => {
        let subject = new ICAL.UtcOffset({ hours: 5, minutes: 6 });
        expect(subject.toString()).toEqual("+05:06");

        let cloned = subject.clone();
        subject.hours = 6;

        expect(cloned.toString()).toEqual("+05:06");
        expect(subject.toString()).toEqual("+06:06");
    });

    it('#toICALString', () => {
        let subject = new ICAL.UtcOffset({ hours: 5, minutes: 6 });
        expect(subject.toString()).toEqual("+05:06");
        expect(subject.toICALString()).toEqual("+0506");
    });

    describe('#normalize', () => {
        it('minute overflow', () => {
            assertHasProperties(new ICAL.UtcOffset({
                minutes: 120
            }), {
                hours: 2, minutes: 0, factor: 1
            });
        });
        it('minutes underflow', () => {
            assertHasProperties(new ICAL.UtcOffset({
                minutes: -120
            }), {
                hours: 2, minutes: 0, factor: -1
            });
        });
        it('minutes underflow with hours', () => {
            assertHasProperties(new ICAL.UtcOffset({
                hours: 2,
                minutes: -120
            }), {
                hours: 0, minutes: 0, factor: 1
            });
        });
        it('hours overflow', () => {
            assertHasProperties(new ICAL.UtcOffset({
                hours: 15,
                minutes: 30
            }), {
                hours: 11, minutes: 30, factor: -1
            });
        });
        it('hours underflow', () => {
            assertHasProperties(new ICAL.UtcOffset({
                hours: 13,
                minutes: 30,
                factor: -1
            }), {
                hours: 13, minutes: 30, factor: 1
            });
        });
        it('hours double underflow', () => {
            assertHasProperties(new ICAL.UtcOffset({
                hours: 40,
                minutes: 30,
                factor: -1
            }), {
                hours: 13, minutes: 30, factor: 1
            });
        });
        it('negative zero utc offset', () => {
            assertHasProperties(new ICAL.UtcOffset({
                hours: 0,
                minutes: 0,
                factor: -1
            }), {
                hours: 0, minutes: 0, factor: -1
            });

        });
    });

    describe('#compare', () => {
        it('greater', () => {
            let a = new ICAL.UtcOffset({ hours: 5, minutes: 1 });
            let b = new ICAL.UtcOffset({ hours: 5, minutes: 0 });
            expect(a.compare(b)).toBe(1);
        });
        it('equal', () => {
            let a = new ICAL.UtcOffset({ hours: 15, minutes: 0 });
            let b = new ICAL.UtcOffset({ hours: -12, minutes: 0 });
            expect(a.compare(b)).toBe(0);
        });
        it('equal zero', () => {
            let a = new ICAL.UtcOffset({ hours: 0, minutes: 0, factor: -1 });
            let b = new ICAL.UtcOffset({ hours: 0, minutes: 0 });
            expect(a.compare(b)).toBe(0);
        });
        it('less than', () => {
            let a = new ICAL.UtcOffset({ hours: 5, minutes: 0 });
            let b = new ICAL.UtcOffset({ hours: 5, minutes: 1 });
            expect(a.compare(b)).toBe(-1);
        });
    });

    describe('from/toSeconds', () => {
        it('static', () => {
            let subject = ICAL.UtcOffset.fromSeconds(3661);
            expect(subject.toString()).toEqual('+01:01');
            expect(subject.toSeconds()).toBe(3660);
        });
        it('instance', () => {
            let subject = ICAL.UtcOffset.fromSeconds(3661);
            subject.fromSeconds(-7321);
            expect(subject.toString()).toEqual('-02:02');
            expect(subject.toSeconds()).toBe(-7320);
        });
    });
});
