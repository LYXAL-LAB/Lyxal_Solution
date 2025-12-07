

import { describe, it, expect, beforeEach } from 'bun:test';
import ICAL, { RecurExpansion, Event, ComponentParser, Time, Component } from '../src/index';
import { testSupport } from './support/helper';

describe('recur_expansion', function () {
    let subject: RecurExpansion;
    let primary: Event;

    async function createSubject(file: string) {
        let icsData = await testSupport.loadSample(file);
        let exceptions: Event[] = [];

        await new Promise<void>((resolve) => {
            let parse = new ComponentParser();

            parse.onevent = function (event) {
                if (event.isRecurrenceException()) {
                    exceptions.push(event);
                } else {
                    primary = event;
                }
            };

            parse.oncomplete = function () {
                exceptions.forEach(primary.relateException, primary);
                subject = new RecurExpansion({
                    component: primary.component,
                    dtstart: primary.startDate
                });

                resolve();
            };
            parse.process(icsData);
        });
    }

    describe('initialization', function () {
        // We need to create subject before each test in this suite manually or via beforeAll?
        // The original used `setup(async function() { ... })` inside `createSubject` function wrapper.
        // We can replicate that pattern or just call it.
        // But `createSubject` sets `subject` variable.
        // Let's use `beforeEach`.

        beforeEach(async () => {
            await createSubject('recur_instances.ics');
        });

        it('successful', function () {
            expect(
                subject.last.toJSDate()
            ).toEqual(new Date('2012-10-02T17:00:00Z'));

            expect(subject.ruleIterators).toBeInstanceOf(Array);
            expect(subject.exDates).toBeTruthy();
        });

        it('invalid', function () {
            // @ts-ignore
            expect(() => new RecurExpansion({})).toThrow(".dtstart (ICAL.Time) must be given");
            expect(() => {
                return new RecurExpansion({
                    dtstart: Time.now()
                });
            }).toThrow(".ruleIterators or .component must be given");
        });

        it('default', function () {
            let dtstart = Time.fromData({
                year: 2012,
                month: 2,
                day: 2
            });
            let expansion = new RecurExpansion({
                dtstart: dtstart,
                ruleIterators: []
            });

            expect(expansion.ruleDates.length).toBe(0);
            expect(expansion.exDates.length).toBe(0);
            expect(expansion.complete).toBeFalse();

            expect(expansion.toJSON()).toEqual({
                ruleIterators: [],
                ruleDates: [],
                exDates: [],
                ruleDateInc: 0,
                exDateInc: 0,
                dtstart: dtstart.toJSON(),
                last: dtstart.toJSON(),
                complete: false
            } as any);
        });
    });

    describe('#_ensureRules', function () {
        beforeEach(async () => {
            await createSubject('recur_instances.ics');
        });

        it('.ruleDates', function () {
            let expected = [
                new Date('2012-11-05T18:00:00.000Z'),
                new Date('2012-11-10T18:00:00.000Z'),
                new Date('2012-11-30T18:00:00.000Z'),

                // RDATEs
                new Date('2023-11-23T09:00:00.000Z'),
                new Date('2023-11-25T09:00:00.000Z')
            ];

            let dates = subject.ruleDates.map(function (time: Time) {
                // We have a period in here, take the start date
                // @ts-ignore
                return (time.start || time).toJSDate();
            });

            expect(dates).toEqual(expected);
        });

        it('.exDates', function () {
            let expected = [
                new Date('2012-12-04T18:00:00.000Z'),
                new Date('2013-02-05T18:00:00.000Z'),
                new Date('2013-04-02T17:00:00.000Z')
            ];

            let dates = subject.exDates.map(function (time: Time) {
                return time.toJSDate();
            });

            expect(dates).toEqual(expected);
        });
    });

    describe('#_nextRecurrenceIter', function () {
        let component: Component;

        beforeEach(async () => {
            await createSubject('recur_instances.ics');
            // setup a clean component with no rules
            // @ts-ignore
            let json = primary.component.toJSON();
            component = new Component(json);

            // Simulate a more complicated event by using
            // the original as a base and adding more complex rrule's
            component.removeProperty('rrule');
        });

        it('when rule ends', function () {
            let start = {
                year: 2012,
                month: 1,
                day: 1
            };

            component.removeAllProperties('rdate');
            component.removeAllProperties('exdate');
            component.addPropertyWithValue('rrule', { freq: "WEEKLY", count: 3, byday: ["SU"] });

            let expansion = new RecurExpansion({
                component: component,
                dtstart: Time.fromData(start) // TS expects Time object likely, checking constructor signature
            });

            let expected = [
                new Date(2012, 0, 1),
                new Date(2012, 0, 8),
                new Date(2012, 0, 15)
            ];

            let max = 10;
            let i = 0;
            let next;
            let dates = [];

            while (i++ <= max && (next = expansion.next())) {
                dates.push(next.toJSDate());
            }

            expect(dates).toEqual(expected);
        });

        it('multiple rules', function () {
            component.addPropertyWithValue('rrule', { freq: "MONTHLY", bymonthday: [13] });
            component.addPropertyWithValue('rrule', { freq: "WEEKLY", byday: ["TH"] });

            let start = Time.fromData({
                year: 2012,
                month: 2,
                day: 2
            });

            let expansion = new RecurExpansion({
                component: component,
                dtstart: start
            });

            let expected = [
                new Date(2012, 1, 2),
                new Date(2012, 1, 9),
                new Date(2012, 1, 13),
                new Date(2012, 1, 16),
                new Date(2012, 1, 23)
            ];

            let inc = 0;
            let max = expected.length;
            let next;
            let dates = [];

            while (inc++ < max) {
                // @ts-ignore
                next = expansion._nextRecurrenceIter();
                // @ts-ignore
                dates.push(next.last.toJSDate());
                // @ts-ignore
                next.next();
            }

            expect(dates).toEqual(expected);
        });

    });

    describe('#next', function () {
        beforeEach(async () => {
            await createSubject('recur_instances.ics');
        });

        // I use JS dates widely because it is much easier
        // to compare them via chai's deepEquals function
        let expected = [
            new Date('2012-10-02T17:00:00.000Z'),
            new Date('2012-11-05T18:00:00.000Z'),
            new Date('2012-11-06T18:00:00.000Z'),
            new Date('2012-11-10T18:00:00.000Z'),
            new Date('2012-11-30T18:00:00.000Z'),
            new Date('2013-01-01T18:00:00.000Z')
        ];

        it('6 items', function () {
            let dates = [];
            let max = 6;
            let inc = 0;
            let next;

            while (inc++ < max && (next = subject.next())) {
                dates.push(next.toJSDate());
            }

            expect(dates).toEqual(expected);
        });
    });

    describe('#next - finite', function () {
        beforeEach(async () => {
            await createSubject('recur_instances_finite.ics');
        });

        it('until complete', function () {
            let max = 100;
            let inc = 0;
            let next;

            let dates = [];
            let expected = [
                new Date('2012-10-02T17:00:00.000Z'),
                new Date('2012-11-05T18:00:00.000Z'),
                new Date('2012-11-06T18:00:00.000Z'),
                new Date('2012-11-10T18:00:00.000Z'),
                new Date('2012-12-04T18:00:00.000Z')
            ];

            while (inc++ < max && (next = subject.next())) {
                dates.push(next.toJSDate());
            }

            // round trip
            subject = new RecurExpansion(subject.toJSON());

            while (inc++ < max && (next = subject.next())) {
                dates.push(next.toJSDate());
            }

            expect(dates).toEqual(expected);
            expect(subject.complete).toBeTrue();
        });
    });

    describe('#toJSON', function () {
        testSupport.useTimezones('America/Los_Angeles');

        beforeEach(async () => {
            await createSubject('recur_instances.ics');
        });

        it('from start', function () {
            let json = subject.toJSON();
            let newIter = new RecurExpansion(json);
            let cur = 0;

            while (cur++ < 10) {
                let n1 = subject.next();
                let n2 = newIter.next();
                if (!n1 || !n2) break;

                expect(n1.toJSDate()).toEqual(n2.toJSDate());
            }
        });

        it('from two iterations', function () {
            subject.next();
            subject.next();

            let json = subject.toJSON();
            let newIter = new RecurExpansion(json);
            let cur = 0;

            while (cur++ < 10) {
                let n1 = subject.next();
                let n2 = newIter.next();
                if (!n1 || !n2) break;

                expect(n1.toJSDate()).toEqual(n2.toJSDate());
            }
        });
    });

    describe('event without recurrences', function () {
        beforeEach(async () => {
            await createSubject('minimal.ics');
        });

        it('iterate', function () {
            let dates = [];
            let next;

            let expected = primary.startDate.toJSDate();

            while ((next = subject.next())) {
                dates.push(next.toJSDate());
            }

            expect(dates[0]).toEqual(expected);
            expect(dates.length).toBe(1);
            expect(subject.complete).toBeTrue();

            // json check
            subject = new RecurExpansion(
                subject.toJSON()
            );

            expect(subject.complete).toBeTrue();
            expect(subject.next()).toBeFalsy();
        });

    });

    describe('EXDATE and DTSTART have different value type', function () {
        beforeEach(async () => {
            await createSubject('rdate_exdate.ics');
        });

        it('Compare EXDATE;VALUE=DATE and DTSTART;VALUE=DATE-TIME', function () {
            let dates: Date[] = [], next;
            while ((next = subject.next()))
                dates.push(next.toJSDate());

            expect(dates).toEqual([
                new Date('2024-06-09T03:00:00.000Z'),
                new Date('2024-06-10T03:00:00.000Z'),
                new Date('2024-06-12T03:00:00.000Z')
            ]);
        });
    });
});
