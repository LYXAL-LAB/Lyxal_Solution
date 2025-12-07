import { describe, it, expect, beforeEach } from 'bun:test';
import ICAL from '../src/index';
import { Time } from '../src/time';
import { Duration } from '../src/duration';
import { Period } from '../src/period';
import { testSupport } from './support/helper';

describe('ical/period', function () {

    let start: Time, end: Time, duration: Duration;

    beforeEach(function () {
        start = ICAL.Time.fromString("1970-01-02T03:04:05Z");
        end = ICAL.Time.fromString("1970-01-02T03:04:05Z");
        duration = ICAL.Duration.fromString("PT3H2M1S");
    });

    describe('#fromString', function () {
        function verify(string: string, icalstring: string, data: any) {
            it('parse: "' + string + '"', function () {
                let subject = ICAL.Period.fromString(string);

                expect(subject.toICALString()).toEqual(icalstring);
                expect(subject.toString()).toEqual(string);

                if ('start' in data) {
                    expect(subject.start).toBeInstanceOf(ICAL.Time);
                    testSupport.assertHasProperties(
                        subject.start,
                        data.start,
                        'start property'
                    );
                }

                if ('end' in data) {
                    if (data.end) {
                        expect(subject.end).toBeInstanceOf(ICAL.Time);
                        testSupport.assertHasProperties(
                            subject.end,
                            data.end,
                            'end property'
                        );
                    } else {
                        expect(subject.end).toBeNull();
                    }
                }

                if ('duration' in data) {
                    if (data.duration) {
                        expect(subject.duration).toBeInstanceOf(ICAL.Duration);
                        testSupport.assertHasProperties(
                            subject.duration,
                            data.duration,
                            'duration property'
                        );
                    } else {
                        expect(subject.duration).toBeNull();
                    }
                }

                if ('calculatedDuration' in data) {
                    let dur = subject.getDuration();

                    if ('duration' in data && data.duration) {
                        testSupport.assertHasProperties(dur, data.duration, 'duration matches calculated');
                    }
                    testSupport.assertHasProperties(dur, data.calculatedDuration);
                }
                if ('calculatedEnd' in data) {
                    let subjectEnd = subject.getEnd();

                    if ('end' in data && data.end) {
                        testSupport.assertHasProperties(subjectEnd, data.end, 'duration matches calculated');
                    }
                    testSupport.assertHasProperties(subjectEnd, data.calculatedEnd);
                }
            });
        }

        function verifyFail(testname: string, string: string, errorParam: RegExp) {
            it('invalid input "' + string + '"', function () {
                expect(() => {
                    ICAL.Period.fromString(string);
                }).toThrow(errorParam);
            });
        }

        verifyFail('missing slash', '1997-01-01T18:30:20Z1997-01-02T07:00:00Z', /Invalid string value/);
        verifyFail('invalid start date', 'some time before/1997-01-02T07:00:00Z', /invalid date-time value/);
        verifyFail('invalid end param', '1997-01-02T07:00:00Z/some time after', /invalid date-time value/);
        verifyFail('invalid end param that might be a duration', '1997-01-02T07:00:00Z/Psome time after', /invalid duration value/);

        verify('1997-01-01T18:30:20Z/1997-01-02T07:00:00Z', '19970101T183020Z/19970102T070000Z', {
            start: {
                year: 1997,
                month: 1,
                day: 1,
                hour: 18,
                minute: 30,
                second: 20
            },

            end: {
                year: 1997,
                month: 1,
                day: 2,
                hour: 7
            },

            duration: null,
            calculatedDuration: {
                isNegative: false,
                hours: 12,
                minutes: 29,
                seconds: 40
            },
            calculatedEnd: {
                year: 1997,
                month: 1,
                day: 2,
                hour: 7
            },
        });

        verify('1997-01-01T18:00:00Z/PT5H30M', '19970101T180000Z/PT5H30M', {
            start: {
                year: 1997,
                month: 1,
                day: 1,
                hour: 18
            },
            duration: {
                isNegative: false,
                hours: 5,
                minutes: 30
            },
            end: null,
            calculatedDuration: {
                isNegative: false,
                hours: 5,
                minutes: 30
            },
            calculatedEnd: {
                year: 1997,
                month: 1,
                day: 1,
                hour: 23,
                minute: 30
            }
        });

    });

    describe('#fromData', function () {
        it('valid start,end', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                end: end
            });

            testSupport.assertHasProperties(subject.start, start, 'start date');
            testSupport.assertHasProperties(subject.end, end, 'end date');
            expect(subject.duration).toBeNull();
        });
        it('valid start,duration', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                duration: duration,
            });

            testSupport.assertHasProperties(subject.start, start, 'start date');
            expect(subject.end).toBeNull();
            testSupport.assertHasProperties(subject.duration, duration, 'duration');
        });

        it('end value exists but is null', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                end: null
            });
            testSupport.assertHasProperties(subject.start, start, 'start date');
            expect(subject.end).toBeNull();
            expect(subject.duration).toBeNull();
        });

        it('start value exists but is null', function () {
            let subject = ICAL.Period.fromData({
                start: null,
                duration: duration,
            });
            expect(subject.start).toBeNull();
            expect(subject.end).toBeNull();
            testSupport.assertHasProperties(subject.duration, duration, 'duration');
        });

        it('duration value exists but is null', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                duration: null,
            });
            testSupport.assertHasProperties(subject.start, start, 'start date');
            expect(subject.end).toBeNull();
            expect(subject.duration).toBeNull();
        });

        it('start,end and duration', function () {
            expect(() => {
                ICAL.Period.fromData({
                    start: start,
                    end: end,
                    duration: duration
                });
            }).toThrow(/cannot accept both end and duration/);
        });

        it('start,end and duration but one is null', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                end: null,
                duration: duration
            });
            testSupport.assertHasProperties(subject.start, start, 'start date');
            expect(subject.end).toBeNull();
            testSupport.assertHasProperties(subject.duration, duration, 'duration');
        });

        it('invalid start value', function () {
            expect(() => {
                ICAL.Period.fromData({
                    start: '1970-01-02T03:04:05Z' as any,
                    end: end
                });
            }).toThrow(/start must be an instance/);
        });
        it('invalid end value', function () {
            expect(() => {
                ICAL.Period.fromData({
                    start: start,
                    end: '1970-01-02T03:04:05Z' as any
                });
            }).toThrow(/end must be an instance/);
        });
        it('invalid duration value', function () {
            expect(() => {
                ICAL.Period.fromData({
                    start: start,
                    duration: 'PT1S' as any
                });
            }).toThrow(/duration must be an instance/);
        });
    });

    describe('#toString', function () {
        it('start,end', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                end: end
            });
            expect(subject.toString()).toEqual('1970-01-02T03:04:05Z/1970-01-02T03:04:05Z');
        });
        it('start,duration', function () {
            let subject = ICAL.Period.fromData({
                start: start,
                duration: duration
            });
            expect(subject.toString()).toEqual('1970-01-02T03:04:05Z/PT3H2M1S');
        });
    });

    describe("generating jCal", function () {
        it("jCal from parser", function () {
            let prop = ICAL.parse.property("FREEBUSY:20140401T010101/PT1H");
            let val = prop![3];
            expect(val).toEqual(["2014-04-01T01:01:01", "PT1H"]);
        });
        it("jCal from property", function () {
            let prop = ICAL.Property.fromString("FREEBUSY:20140401T010101/PT1H");
            let val = (prop.getFirstValue() as Period).toJSON();
            expect(val).toEqual(["2014-04-01T01:01:01", "PT1H"]);
        });
    });

    describe("#clone", function () {
        it('cloned start/duration', function () {
            let subjectstart = start.clone();
            let subjectduration = duration.clone();
            let subject1 = ICAL.Period.fromData({ start: subjectstart, duration: subjectduration });
            let subject2 = subject1.clone();
            subjectstart.hour++;
            subjectduration.hours++;

            expect(subject1.start!.hour).toEqual(4);
            expect(subject2.start!.hour).toEqual(3);

            expect(subject1.duration!.hours).toEqual(4);
            expect(subject2.duration!.hours).toEqual(3);
        });
        it('cloned start/end', function () {
            let subjectstart = start.clone();
            let subjectend = end.clone();
            let subject1 = ICAL.Period.fromData({ start: subjectstart, end: subjectend });
            let subject2 = subject1.clone();
            subjectstart.hour++;
            subjectend.hour++;

            expect(subject1.start!.hour).toEqual(4);
            expect(subject2.start!.hour).toEqual(3);

            expect(subject1.end!.hour).toEqual(4);
            expect(subject2.end!.hour).toEqual(3);
        });
        it('cloned empty object', function () {
            // most importantly, this shouldn't throw.
            let subject1 = ICAL.Period.fromData();
            let subject2 = subject1.clone();

            expect(subject1.start).toEqual(subject2.start);
            expect(subject1.end).toEqual(subject2.end);
            expect(subject1.duration).toEqual(subject2.duration);
        });
    });

    describe("#compare", function () {
        it("with date", function () {
            let subject = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:04Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:06Z")
            });

            let beforestart = ICAL.Time.fromString("1970-01-02T03:04:03Z");
            let between = ICAL.Time.fromString("1970-01-02T03:04:05Z");
            let afterend = ICAL.Time.fromString("1970-01-02T03:04:07Z");

            expect(subject.compare(beforestart)).toEqual(1);
            expect(subject.compare(subject.start!)).toEqual(0);
            expect(subject.compare(between)).toEqual(0);
            expect(subject.compare(subject.end!)).toEqual(0);
            expect(subject.compare(afterend)).toEqual(-1);
        });

        it("with other period", function () {
            let subject = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:04Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:06Z")
            });

            let beforestart = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:02Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:03Z")
            });
            let overlapstart = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:03Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:05Z")
            });
            let within = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:05Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:05Z")
            });
            let overlapend = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:05Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:07Z")
            });
            let afterend = ICAL.Period.fromData({
                start: ICAL.Time.fromString("1970-01-02T03:04:07Z"),
                end: ICAL.Time.fromString("1970-01-02T03:04:09Z")
            });

            expect(subject.compare(beforestart)).toEqual(1);
            expect(subject.compare(overlapstart)).toEqual(0);
            expect(subject.compare(within)).toEqual(0);
            expect(subject.compare(overlapend)).toEqual(0);
            expect(subject.compare(afterend)).toEqual(-1);
        });
    });
});
