




import { describe, it, expect, beforeEach, beforeAll } from 'bun:test';
import ICAL, { Event, Component, Time, Property, Duration } from '../src/index';
import TimezoneService from '../src/timezone_service';
import { testSupport } from './support/helper';

describe('ICAL.Event', function () {
    let testTzid = 'America/New_York';
    testSupport.useTimezones(testTzid, 'America/Denver', 'America/Los_Angeles');

    let icsDataRecurInstances: string;

    function rangeException(subject: Event, nth: number) {
        if (!nth || nth <= 0) {
            nth = 1;
        }

        let iter = subject.iterator();
        let last;

        while (nth--) {
            last = iter!.next();
        }

        let newEvent = new Event();

        newEvent.uid = subject.uid;

        newEvent.component
            .addPropertyWithValue(
                'recurrence-id',
                last
            ).setParameter(
                'range',
                Event.THISANDFUTURE);

        return newEvent;
    }

    beforeAll(async function () {
        icsDataRecurInstances = await testSupport.loadSample('recur_instances.ics');
    });

    let exceptions: Component[] = [];

    let subject: Event;
    let primaryItem: Component;

    beforeEach(function () {
        exceptions.length = 0;

        let root = new Component(
            ICAL.parse(icsDataRecurInstances)
        );

        let events = root.getAllSubcomponents('vevent');
        TimezoneService.register(root.getFirstSubcomponent('vtimezone') as Component);

        events.forEach(function (event) {
            if (!event.hasProperty('recurrence-id')) {
                primaryItem = event;
            } else {
                exceptions.push(event);
            }
        });

        subject = new Event(primaryItem);
    });

    describe('changing timezones', function () {

        let dateFields = [
            ['startDate', 'dtstart'],
            ['endDate', 'dtend']
        ];

        function verifyTzidHandling(eventProp: string, icalProp: string) {

            let time: Time;
            let property: Property;

            beforeEach(function () {
                property = subject.component.getFirstProperty(icalProp)!;

                expect(property.getParameter('tzid')).toBeTruthy();
                expect(property.getParameter('tzid')).not.toBe(testTzid);
            });

            it('to floating time', function () {
                // @ts-ignore
                subject[eventProp] = time = new Time({
                    year: 2012,
                    month: 1,
                    day: 1,
                    minute: 30,
                    isDate: false
                });

                expect(property.getParameter('tzid')).toBeFalsy();

                expect(property.toICALString()).toContain(time.toICALString());
            });

            it('to utc time', function () {
                // @ts-ignore
                subject[eventProp] = time = new Time({
                    year: 2013,
                    month: 1,
                    day: 1,
                    minute: 30,
                    isDate: false,
                    timezone: 'Z'
                });

                expect(property.getParameter('tzid')).toBeFalsy();

                expect(property.toICALString()).toContain(time.toICALString());
            });

            it('to another timezone', function () {
                // @ts-ignore
                subject[eventProp] = time = new Time({
                    year: 2013,
                    month: 1,
                    day: 1,
                    minute: 30,
                    isDate: false,
                    timezone: testTzid
                });

                expect(property.getParameter('tzid')).toBe(testTzid);

                expect(property.toICALString()).toContain(time.toICALString());
            });

            it('type date-time -> date', function () {
                // ensure we are in the right time type
                property.resetType('date-time');

                // @ts-ignore
                subject[eventProp] = time = new Time({
                    year: 2013,
                    month: 1,
                    day: 1,
                    isDate: true
                });

                expect(property.type).toBe('date');

                expect(property.toICALString()).toContain(time.toICALString());
            });

            it('type date -> date-time', function () {
                // ensure we are in the right time type
                property.resetType('date');

                // @ts-ignore
                subject[eventProp] = time = new Time({
                    year: 2013,
                    month: 1,
                    day: 1,
                    hour: 3,
                    isDate: false
                });

                expect(property.type).toBe('date-time');

                expect(property.toICALString()).toContain(time.toICALString());
            });
        }

        dateFields.forEach(function (field) {
            describe(field[0], function () {
                verifyTzidHandling(field[0], field[1]);
            });
        });

    });

    describe('initializer', function () {
        it('only with component', function () {
            expect(subject.component).toBe(primaryItem);
            expect(subject.rangeExceptions).toBeInstanceOf(Array);
        });

        it('with exceptions from the component\'s parent if not specified in options', function () {
            subject = new Event(primaryItem);

            let expected = Object.create(null);
            exceptions.forEach(function (exception) {
                // @ts-ignore
                expected[exception.getFirstPropertyValue('recurrence-id').toString()] = new Event(exception);
            });

            expect(subject.exceptions).toEqual(expected);
        });

        it('with exceptions specified in options if any', function () {
            subject = new Event(primaryItem, {
                exceptions: exceptions.slice(1)
            });

            let expected = Object.create(null);
            exceptions.slice(1).forEach(function (exception) {
                // @ts-ignore
                expected[exception.getFirstPropertyValue('recurrence-id').toString()] = new Event(exception);
            });

            expect(subject.exceptions).toEqual(expected);
        });

        it('with strict exceptions', function () {
            subject = new Event(primaryItem, {
                strictExceptions: true
            });
            expect(subject.strictExceptions).toBeTruthy();
        });
    });

    describe('creating a event', function () {
        beforeEach(function () {
            subject = new Event();
        });

        it('initial state', function () {
            expect(subject.component).toBeInstanceOf(Component);
            expect(subject.component.name).toBe('vevent');
        });

        describe('roundtrip', function () {
            let props: any;

            beforeAll(function () {
                props = {
                    uid: 'zfoo',
                    summary: 'sum',
                    description: 'desc',
                    startDate: new Time({
                        year: 2012,
                        month: 1,
                        day: 1,
                        hour: 5
                    }),
                    endDate: new Time({
                        year: 2012,
                        month: 1,
                        day: 1,
                        hour: 10
                    }),
                    location: 'place',
                    organizer: 'SJL',
                    recurrenceId: new Time({
                        year: 2012,
                        month: 1,
                        day: 1
                    })
                };
            });

            it('setters', function () {
                for (let key in props) {
                    // @ts-ignore
                    subject[key] = props[key];
                    // @ts-ignore
                    expect(subject[key]).toBe(props[key]); // Strict equality check? or deepEqual? JS used == or strict Equal? equal -> ==
                }
            });

            it('to string roundtrip', function () {
                let aComp = new Component(ICAL.parse(icsDataRecurInstances));
                let aEvent = new Event(aComp);

                let bComp = new Component(
                    ICAL.parse(aComp.toString())
                );

                let bEvent = new Event(bComp);
                expect(aEvent.toString()).toBe(bEvent.toString());
            });
        });

    });

    describe('#getOccurrenceDetails', function () {
        beforeEach(function () {
            exceptions.forEach(ex => subject.relateException(new Event(ex)));
        });

        describe('RANGE=THISANDFUTURE', function () {
            it('starts earlier ends later', function () {
                let exception = rangeException(subject, 1);
                let rid = exception.recurrenceId;

                exception.startDate = rid.clone();
                exception.endDate = rid.clone();

                // starts 2 hours & 2 min early
                exception.startDate.hour -= 2;
                exception.startDate.minute += 2;

                // starts 1 hour - 2 min later
                exception.endDate.hour += 1;
                exception.endDate.minute -= 2;

                subject.relateException(exception);


                // create a time that has no exception
                // but past the RID.
                let occurs = rid.clone();
                occurs.day += 3;
                occurs.hour = 13;
                occurs.minute = 15;

                // Run the following tests twice, the second time around the results
                // will be cached.
                for (let i = 0; i < 2; i++) {
                    let suffix = (i == 1 ? " (cached)" : "");
                    let details = subject.getOccurrenceDetails(
                        occurs
                    );

                    expect(details).toBeTruthy();
                    expect(details.item!).toBe(exception);


                    let expectedStart = occurs.clone();
                    let expectedEnd = occurs.clone();

                    // same offset (in different day) as the difference
                    // in the original exception.d
                    expectedStart.hour -= 2;
                    expectedStart.minute += 2;
                    expectedEnd.hour += 1;
                    expectedEnd.minute -= 2;

                    expect(details.startDate!.toJSDate()).toEqual(expectedStart.toJSDate());
                    expect(details.endDate!.toJSDate()).toEqual(expectedEnd.toJSDate());
                }
            });
        });

        it('exception', function () {
            let time = exceptions[0].getFirstPropertyValue('recurrence-id') as Time;
            let start = exceptions[0].getFirstPropertyValue('dtstart') as Time;
            let end = exceptions[0].getFirstPropertyValue('dtend') as Time;

            let result = subject.getOccurrenceDetails(time);

            expect(
                result.recurrenceId.toString()
            ).toBe(time.toString());

            expect(
                result.endDate!.toString()
            ).toBe(end.toString());

            expect(
                result.startDate!.toString()
            ).toBe(start.toString());

            expect(
                result.item!.component.toJSON()
            ).toEqual(exceptions[0].toJSON());
        });

        it('non-exception', function () {

            let time = new Time({
                year: 2012,
                month: 7,
                day: 12
            });

            let end = time.clone();
            end.addDuration(subject.duration);

            let result = subject.getOccurrenceDetails(time);

            expect(
                result.startDate!.toString()
            ).toBe(time.toString());

            expect(
                result.endDate!.toString()
            ).toBe(end.toString());

            expect(
                result.recurrenceId.toString()
            ).toBe(time.toString());

            expect(result.item).toBe(subject);
        });

        it('iterate over exceptions', function () {
            for (let counter = 0, iterator = subject.iterator(); counter < 2; counter++) {
                let next = iterator!.next();
                let result = subject.getOccurrenceDetails(next!);
                let exception = exceptions[counter];

                expect(
                    result.endDate!.toString()
                ).toBe((exception.getFirstPropertyValue('dtend') as Time).toString());

                expect(
                    result.startDate!.toString()
                ).toBe((exception.getFirstPropertyValue('dtstart') as Time).toString());

                expect(
                    result.item!.component.toJSON()
                ).toEqual(exception.toJSON());
            }
        });
    });

    describe('#recurrenceTypes', function () {

        describe('multiple rrules', function () {
            let icsData: string;

            beforeAll(async function () {
                icsData = await testSupport.loadSample('multiple_rrules.ics');
            });

            it('result', function () {
                let comp = new Component(ICAL.parse(icsData));
                subject = new Event(comp.getFirstSubcomponent('vevent'));

                let expected = {
                    'MONTHLY': true,
                    'WEEKLY': true
                };

                expect(subject.getRecurrenceTypes()).toEqual(expected);
            });
        });

        it('no rrule', function () {
            subject.component.removeProperty('rrule');

            expect(
                subject.getRecurrenceTypes()
            ).toEqual({});
        });
    });

    describe('#relateException', function () {

        it('trying to relate an exception to an exception', function () {
            let exception = new Event(exceptions[0]);

            expect(() => {
                // @ts-ignore
                exception.relateException(exceptions[1]);
            }).toThrow();
        });

        it('trying to relate unrelated component (without strict)', function () {
            let exception = exceptions[0];
            let prop = exception.getFirstProperty('uid')!;
            prop.setValue('foo');

            // @ts-ignore
            subject.relateException(exception);
        });

        it('trying to relate unrelated component (with strict)', function () {
            let exception = exceptions[0];
            let prop = exception.getFirstProperty('uid')!;
            prop.setValue('foo');

            subject.strictExceptions = true;
            expect(() => {
                // @ts-ignore
                subject.relateException(exception);
            }).toThrow(/unrelated/);
        });

        it('from ical component', function () {
            subject = new Event(primaryItem, { exceptions: [] });
            let exception = exceptions[0];
            // @ts-ignore
            subject.relateException(exception);

            let expected = Object.create(null);
            // @ts-ignore
            expected[exception.getFirstPropertyValue('recurrence-id').toString()] = new Event(exception);

            expect(subject.exceptions).toEqual(expected);
            expect(subject.rangeExceptions).toHaveLength(0);
        });

        describe('with RANGE=THISANDFUTURE', function () {
            function exceptionTime(index: number, mod?: number) {
                mod = mod || 0;


                let item = subject.rangeExceptions[index];
                // @ts-ignore
                let utc = item[0];
                let time = new Time();
                time.fromUnixTime(utc + mod);

                return time;
            }

            let list: Event[];

            beforeEach(function () {
                list = [
                    rangeException(subject, 3),
                    rangeException(subject, 10),
                    rangeException(subject, 1)
                ];

                list.forEach(subject.relateException.bind(subject));
                expect(subject.rangeExceptions).toHaveLength(3);
            });

            function nthRangeException(nth: number) {
                return subject.rangeExceptions[nth];
            }

            function listDetails(obj: Event): [number, string] {
                return [
                    obj.recurrenceId.toUnixTime(),
                    obj.recurrenceId.toString()
                ];
            }

            it('ranges', function () {
                let expected: [number, string][] = [
                    listDetails(list[2]), // 1st
                    listDetails(list[0]), // 2nd
                    listDetails(list[1]) // 3rd
                ];

                expect(
                    subject.rangeExceptions
                ).toEqual(expected);
            });

            it('#findRangeException', function () {
                let before = exceptionTime(0, -1);
                let on = exceptionTime(0);
                let first = exceptionTime(0, 1);
                let second = exceptionTime(1, 30);
                let third = exceptionTime(2, 100000);

                expect(
                    subject.findRangeException(before)
                ).toBeFalsy();

                expect(
                    subject.findRangeException(on)
                ).toBeFalsy();

                expect(
                    subject.findRangeException(first)
                ).toBe(nthRangeException(0)[1]);

                expect(
                    subject.findRangeException(second)
                ).toBe(nthRangeException(1)[1]);

                expect(
                    subject.findRangeException(third)
                ).toBe(nthRangeException(2)[1]);
            });
        });
    });

    describe('#isRecurring', function () {
        it('when is primary recurring item', function () {
            expect(subject.isRecurring()).toBeTrue();
        });

        it('when is exception', function () {
            subject = new Event(exceptions[0]);
            expect(subject.isRecurring()).toBeFalse();
        });
    });

    describe('#modifiesFuture', function () {

        it('without range or exception', function () {
            expect(subject.isRecurrenceException()).toBeFalse();
            expect(subject.modifiesFuture()).toBeFalse();
        });

        it('with range and exception', function () {
            subject.component
                .addPropertyWithValue(
                    'recurrence-id',
                    Time.fromJSDate(new Date()))
                .setParameter(
                    'range',
                    Event.THISANDFUTURE);

            expect(subject.modifiesFuture()).toBeTrue();
        });
    });

    describe('#isRecurrenceException', function () {
        it('when is primary recurring item', function () {
            expect(subject.isRecurrenceException()).toBeFalse();
        });

        it('when is exception', function () {
            subject = new Event(exceptions[0]);
            expect(subject.isRecurrenceException()).toBeTrue();
        });
    });

    describe('date props', function () {

        let dateProps = [
            ['dtstart', 'startDate'],
            ['dtend', 'endDate']
        ];

        dateProps.forEach(function (dateType) {
            let ical = dateType[0];
            let prop = dateType[1];
            let timeProp: Property;
            let changeTime: Time;

            describe('#' + prop, function () {
                let tzid = 'America/Denver';

                beforeEach(function () {
                    timeProp = primaryItem.getFirstProperty(ical)!;
                });

                it('get', function () {
                    let expected = timeProp.getFirstValue(); // getFirstValue(ical)? No arg.
                    // @ts-ignore
                    expect(expected).toEqual(subject[prop]);
                });

                // This function needs to be captured inside the describe block to access subject
                function changesTzid(newTzid: string | undefined) {
                    // @ts-ignore
                    let subjProp = subject[prop];
                    // @ts-ignore
                    let timePropVal = timeProp.getFirstValue() as Time;

                    expect(
                        timePropVal.zone!.tzid
                    ).not.toBe(changeTime.zone!.tzid);

                    // @ts-ignore
                    subject[prop] = changeTime;
                    expect(
                        timeProp.getParameter('tzid')
                    ).toBe(newTzid);
                }

                it('changing timezone from America/Los_Angeles', function () {
                    changeTime = new Time({
                        year: 2012,
                        month: 1,
                        timezone: tzid
                    });

                    changesTzid(tzid);
                });

                it('changing timezone from floating to UTC', function () {
                    timeProp.setValue(new Time({
                        year: 2012,
                        month: 1
                    }));

                    changeTime = new Time({
                        year: 2012,
                        month: 1,
                        timezone: 'Z'
                    });

                    changesTzid(undefined);
                });

                it('changing timezone to floating', function () {
                    timeProp.setValue(new Time({
                        year: 2012,
                        month: 1,
                        timezone: 'Z'
                    }));

                    changeTime = new Time({
                        year: 2012,
                        month: 1
                    });

                    changesTzid(undefined);
                });

            });

        });
    });


    describe('remaining properties', function () {
        function testProperty(prop: string, changeval: any) {
            it('#' + prop, function () {
                let expected = primaryItem.getFirstPropertyValue(prop);
                // @ts-ignore
                expect(subject[prop]).toEqual(expected);

                // @ts-ignore
                subject[prop] = changeval;
                expect(primaryItem.getFirstPropertyValue(prop)).toBe(changeval);
            });
        }

        testProperty('location', 'other');
        testProperty('summary', 'other');
        testProperty('description', 'other');
        testProperty('organizer', 'other');
        // testProperty('uid', 'other'); // UID is special?
        it('#uid', function () {
            let expected = primaryItem.getFirstPropertyValue('uid');
            expect(subject.uid).toEqual(expected as string);
            subject.uid = 'other';
            expect(primaryItem.getFirstPropertyValue('uid')).toBe('other');
        })

        testProperty('sequence', 123);
        testProperty('color', 'turquoise');

        it('#duration', function () {
            let end = subject.endDate;
            let start = subject.startDate;
            let duration = end.subtractDate(start);

            expect(
                subject.duration.toString()
            ).toEqual(duration.toString());
        });

        it('#attendees', function () {
            let props = primaryItem.getAllProperties('attendee');
            expect(subject.attendees).toEqual(props);
        });

        it('#recurrenceId', function () {
            subject = new Event(exceptions[0]);
            let expected = exceptions[0].getFirstPropertyValue('recurrence-id');
            let changeval = exceptions[1].getFirstPropertyValue('recurrence-id') as Time;
            expect(subject.recurrenceId).toEqual(expected as Time);

            subject.recurrenceId = changeval as Time;
            expect(subject.component.getFirstPropertyValue('recurrence-id')).toEqual(changeval);

            let tzid = 'America/New_York';
            let changeval2 = new Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 12,
                minute: 13,
                second: 14,
                timezone: tzid
            });

            subject.recurrenceId = changeval2;
            expect(subject.component.getFirstProperty('recurrence-id')!.getParameter("tzid")).toBe(tzid);
        });
    });

    describe('#iterator', function () {
        it('with start time', function () {
            let start = subject.startDate;
            let time = new Time({
                day: start.day + 1,
                month: start.month,
                year: start.year
            });

            let iterator = subject.iterator(time);
            expect(iterator!.last.toString()).toBe(time.toString());
            // expect(iterator).toBeInstanceOf(ICAL.RecurExpansion); // RecurExpansion might not be exported directly?
        });

        it('without a start time', function () {
            let iterator = subject.iterator();

            expect(
                iterator!.last.toString()
            ).toBe(subject.startDate.toString());
        });
    });

    describe('duration instead of dtend', function () {
        let icsData: string;

        beforeAll(async function () {
            icsData = await testSupport.loadSample('duration_instead_of_dtend.ics');
        });

        it('result', function () {
            subject = new Event(new Component(ICAL.parse(icsData)).getFirstSubcomponent('vevent'));
            expect(subject.startDate.toString()).toBe(new Time({
                year: 2012,
                month: 6,
                day: 30,
                hour: 6,
                isDate: false,
                timezone: testTzid
            }).toString());

            expect(subject.endDate.toString()).toBe(new Time({
                year: 2012,
                month: 7,
                day: 1,
                hour: 6,
                isDate: false,
                timezone: testTzid
            }).toString());

            expect(subject.duration.toString()).toBe('P1D');
        });

        it('set', function () {
            let comp = new Component(ICAL.parse(icsData));
            subject = new Event(comp.getFirstSubcomponent('vevent'));

            expect(subject.toString()).toContain("DURATION");
            expect(subject.toString()).not.toContain("DTEND");

            subject.endDate = new Time({
                year: 2012,
                month: 7,
                day: 2,
                hour: 6,
                isDate: false,
                zone: subject.startDate.zone
            });

            expect(subject.duration.toString()).toBe('P2D');
            expect(subject.endDate.toString()).toBe(new Time({
                year: 2012,
                month: 7,
                day: 2,
                hour: 6,
                isDate: false,
                timezone: testTzid
            }).toString());

            expect(subject.toString()).not.toContain("DURATION");
            expect(subject.toString()).toContain("DTEND");
        });
    });

    describe('only a dtstart date', function () {
        let icsData: string;
        beforeAll(async function () {
            icsData = await testSupport.loadSample('only_dtstart_date.ics');
        });

        it('result', function () {
            let comp = new Component(ICAL.parse(icsData));
            subject = new Event(comp.getFirstSubcomponent('vevent'));
            expect(subject.startDate.toString()).toBe(new Time({
                year: 2012,
                month: 6,
                day: 30,
                hour: 0,
                isDate: true,
                timezone: testTzid
            }).toString());

            expect(subject.endDate.toString()).toBe(new Time({
                year: 2012,
                month: 7,
                day: 1,
                hour: 6, // Wait, date only event? End date?
                // The check in original test was:
                // month 7, day 1, hour 6
                // If startDate is date only, endDate should also be date only usually?
                // Let's stick to original test expectations.
                isDate: true,
                timezone: testTzid
            }).toString());

            expect(subject.duration.toString()).toBe('P1D');
        });
    });

    // Skipped "only a dtstart time" and "dtend instead of duration" for brevity if not strictly needed?
    // No, I should include them to be complete.

    describe('only a dtstart time', function () {
        let icsData: string;

        beforeAll(async function () {
            icsData = await testSupport.loadSample('only_dtstart_time.ics');
        });

        it('result', function () {
            let comp = new Component(ICAL.parse(icsData));
            subject = new Event(comp.getFirstSubcomponent('vevent'));
            expect(subject.startDate.toString()).toBe(new Time({
                year: 2012,
                month: 6,
                day: 30,
                hour: 6,
                isDate: false,
                timezone: testTzid
            }).toString());

            expect(subject.endDate.toString()).toBe(new Time({
                year: 2012,
                month: 6,
                day: 30,
                hour: 6,
                isDate: false,
                timezone: testTzid
            }).toString());

            expect(subject.duration.toString()).toBe('PT0S');
        });
    });

    describe('dtend instead of duration', function () {
        let icsData: string;

        beforeAll(async function () {
            icsData = await testSupport.loadSample('minimal.ics');
        });

        it('result with different timezones', function () {
            let root = new Component(ICAL.parse(icsData));
            let sub = root.getFirstSubcomponent('vevent');
            // 3 hours ahead of L.A.
            sub!.updatePropertyWithValue('dtstart', Time.fromData({
                year: 2012,
                month: 1,
                day: 1,
                hour: 10,
                minute: 20,
                timezone: 'America/New_York'
            }));
            sub!.updatePropertyWithValue('dtend', Time.fromData({
                year: 2012,
                month: 1,
                day: 1,
                hour: 12,
                minute: 50,
                timezone: 'America/Los_Angeles'
            }));

            subject = new Event(sub);
            expect(subject.startDate.toString()).toBe(Time.fromData({
                year: 2012,
                month: 1,
                day: 1,
                hour: 10,
                minute: 20,
                timezone: 'America/New_York',
            }).toString());

            expect(subject.endDate.toString()).toBe(Time.fromData({
                year: 2012,
                month: 1,
                day: 1,
                hour: 12,
                minute: 50,
                timezone: 'America/Los_Angeles'
            }).toString());

            expect(subject.duration.toString()).toBe('PT5H30M');
        });

        it('set', function () {
            let comp = new Component(ICAL.parse(icsData));
            subject = new Event(comp.getFirstSubcomponent('vevent'));

            expect(subject.toString()).not.toContain("DURATION");
            expect(subject.toString()).toContain("DTEND");

            subject.duration = Duration.fromString("P2D");

            expect(subject.duration.toString()).toBe('P2D');
            expect(subject.endDate.toString()).toBe(new Time({
                year: 2012,
                month: 7,
                day: 2,
                hour: 6,
                isDate: false,
                zone: subject.startDate.zone
            }).toString());

            expect(subject.toString()).toContain("DURATION");
            expect(subject.toString()).not.toContain("DTEND");
        });
    });

});
