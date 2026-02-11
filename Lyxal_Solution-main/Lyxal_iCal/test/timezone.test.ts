import { describe, it, expect, beforeEach } from 'bun:test';
import ICAL from '../src/index';
import { Time } from '../src/time';
import { Timezone } from '../src/timezone';
import { testSupport } from './support/helper';

describe('timezone', function () {
    let timezone: Timezone;

    function timezoneTest(tzid: string, name: string | Function, testCb?: any) {
        if (typeof (name) === 'function') {
            testCb = name;
            name = 'parse';
        }

        describe(tzid, function () {
            if (tzid == "UTC") {
                beforeEach(function () {
                    timezone = ICAL.Timezone.utcTimezone;
                });
            } else if (tzid == "floating") {
                beforeEach(function () {
                    timezone = ICAL.Timezone.localTimezone;
                });
            } else {
                beforeEach(async function () {
                    let icsData = await testSupport.loadSample('timezones/' + tzid + '.ics');

                    let parsed = ICAL.parse(icsData);
                    let vcalendar = new ICAL.Component(parsed);
                    let comp = vcalendar.getFirstSubcomponent('vtimezone');

                    timezone = new ICAL.Timezone(comp!);
                });
            }

            it(name as string, testCb);
        });
    }

    function utcHours(time: any) {
        let seconds = timezone.utcOffset(
            new ICAL.Time(time)
        );

        // in hours
        return (seconds / 3600);
    }

    function sanityCheckSuite(options: any) {
        let runner = options.only ? describe.only : describe;
        let title = 'time: ' + JSON.stringify(options.time);

        runner(title, function () {
            for (let tzid in options.offsets) {
                timezoneTest(tzid, tzid + " offset " + options.offsets[tzid], function (this: any) {
                    expect(utcHours(options.time)).toEqual(options.offsets[tzid]);
                });
            }
        });
    }
    // sanityCheckSuite.only = function(options: any) {
    //   options.only = true;
    //   sanityCheckSuite(options);
    // };


    // just before US DST
    sanityCheckSuite({
        time: { year: 2012, month: 3, day: 11, hour: 1, minute: 59 },
        offsets: {
            'America/Los_Angeles': -8,
            'America/New_York': -5,
            'America/Denver': -7,
            'America/Atikokan': -5, // single tz
            'UTC': 0,
            'floating': 0
        }
    });

    // just after US DST
    sanityCheckSuite({
        time: { year: 2012, month: 3, day: 11, hour: 2 },
        offsets: {
            'America/Los_Angeles': -7,
            'America/Denver': -6,
            'America/New_York': -4,
            'America/Atikokan': -5,
            'UTC': 0,
            'floating': 0
        }
    });

    sanityCheckSuite({
        time: { year: 2004, month: 10, day: 31, hour: 0, minute: 59, second: 59 },
        offsets: {
            'America/Denver': -6
        }
    });

    sanityCheckSuite({
        time: { year: 2004, month: 10, day: 31, hour: 1 },
        offsets: {
            'America/Denver': -7
        }
    });


    // Edge case timezone that defines an RDATE with VALUE=DATE
    sanityCheckSuite({
        // just before DST
        time: { year: 1980, month: 1, day: 1, hour: 0, minute: 59 },
        offsets: {
            'Makebelieve/RDATE_test': -4,
            'Makebelieve/RDATE_utc_test': -5
        }
    });

    sanityCheckSuite({
        // just after DST
        time: { year: 1980, month: 1, day: 1, hour: 1 },
        offsets: {
            'Makebelieve/RDATE_test': -5,
            'Makebelieve/RDATE_utc_test': -5
        }
    });

    // Edge case where RDATE is defined in UTC
    sanityCheckSuite({
        // just before DST
        time: { year: 1990, month: 1, day: 1, hour: 0, minute: 59 },
        offsets: {
            'Makebelieve/RDATE_test': -4,
            'Makebelieve/RDATE_utc_test': -4
        }
    });

    sanityCheckSuite({
        // just after DST
        time: { year: 1990, month: 1, day: 1, hour: 2 },
        offsets: {
            'Makebelieve/RDATE_test': -5,
            'Makebelieve/RDATE_utc_test': -5
        }
    });

    // Edge case timezone where an RRULE with UNTIL in UTC is specified
    sanityCheckSuite({
        // Just before DST
        time: { year: 1975, month: 1, day: 1, hour: 1, minute: 0, second: 0 },
        offsets: {
            'Makebelieve/RRULE_UNTIL_test': -5
        }
    });

    sanityCheckSuite({
        // Just after DST
        time: { year: 1975, month: 1, day: 1, hour: 3, minute: 0, second: 0 },
        offsets: {
            'Makebelieve/RRULE_UNTIL_test': -4
        }
    });

    sanityCheckSuite({
        // After the RRULE ends
        time: { year: 1985, month: 1, day: 1, hour: 3, minute: 0, second: 0 },
        offsets: {
            'Makebelieve/RRULE_UNTIL_test': -4
        }
    });

    timezoneTest('America/Los_Angeles', '#expandedUntilYear', function () {

        function calcYear(yr: number) {
            return Math.max(ICAL.Timezone._minimumExpansionYear, yr) +
                ICAL.Timezone.EXTRA_COVERAGE;
        }

        let time = new ICAL.Time({
            year: 2032,
            zone: timezone
        });
        let expectedCoverage = calcYear(time.year);

        time.utcOffset();
        expect(timezone.expandedUntilYear).toEqual(expectedCoverage);

        time = new ICAL.Time({
            year: 2034,
            zone: timezone
        });

        time.utcOffset();
        expect(timezone.expandedUntilYear).toEqual(expectedCoverage);

        time = new ICAL.Time({
            year: 1997,
            zone: timezone
        });
        time.utcOffset();
        expect(timezone.expandedUntilYear).toEqual(expectedCoverage);

        time = new ICAL.Time({
            year: expectedCoverage + 3,
            zone: timezone
        });
        expectedCoverage = calcYear(time.year);
        time.utcOffset();
        expect(timezone.expandedUntilYear).toEqual(expectedCoverage);
    });

    describe('#convertTime', function () {
        timezoneTest('America/Los_Angeles', 'convert date-time from utc', function () {
            let subject = ICAL.Time.fromString('2012-03-11T01:59:00Z');
            let subject2 = subject.convertToZone(timezone);
            expect(subject2.zone!.tzid).toEqual(timezone.tzid);
            expect(subject2.toString()).toEqual('2012-03-10T17:59:00');
        });

        timezoneTest('America/Los_Angeles', 'convert date from utc', function () {
            let subject = ICAL.Time.fromString('2012-03-11');
            let subject2 = subject.convertToZone(timezone);
            expect(subject2.zone!.tzid).toEqual(timezone.tzid);
            expect(subject2.toString()).toEqual('2012-03-11');
        });
        timezoneTest('America/Los_Angeles', 'convert local time to zone', function () {
            let subject = ICAL.Time.fromString('2012-03-11T01:59:00');
            subject.zone = ICAL.Timezone.localTimezone;
            expect(subject.toString()).toEqual('2012-03-11T01:59:00');

            let subject2 = subject.convertToZone(timezone);
            expect(subject2.toString()).toEqual('2012-03-11T01:59:00');

            let subject3 = subject2.convertToZone(ICAL.Timezone.localTimezone);
            expect(subject3.toString()).toEqual('2012-03-11T01:59:00');
        });
    });

    describe('#fromData', function () {
        timezoneTest('America/Los_Angeles', 'string component', function () {
            let subject = new ICAL.Timezone({
                component: timezone.component!.toString(),
                tzid: 'Makebelieve/Different'
            });

            expect(subject.expandedUntilYear).toEqual(0);
            expect(subject.tzid).toEqual('Makebelieve/Different');
            expect(subject.component!.getFirstPropertyValue('tzid')).toEqual('America/Los_Angeles');
        });

        timezoneTest('America/Los_Angeles', 'component in data', function () {
            let subject = new ICAL.Timezone({
                component: timezone.component!,
            });

            expect(subject.tzid).toEqual('America/Los_Angeles');
            expect(subject.component).toEqual(timezone.component);
        });

        timezoneTest('America/Los_Angeles', 'with strange component', function () {
            let subject = new ICAL.Timezone({
                component: 123 as any
            });

            expect(subject.component).toBeNull();
        });
    });

    describe('#utcOffset', function () {
        it('empty vtimezone', function () {
            let subject = new ICAL.Timezone({
                component: new ICAL.Component('vtimezone')
            });

            expect(subject.utcOffset(ICAL.Time.fromString('2012-01-01'))).toEqual(0);
        });

        it('empty STANDARD/DAYLIGHT', function () {
            let subject = new ICAL.Timezone({
                component: new ICAL.Component(['vtimezone', [], [
                    ['standard', [], []],
                    ['daylight', [], []]
                ]])
            });

            expect(subject.utcOffset(ICAL.Time.fromString('2012-01-01'))).toEqual(0);
        });
    });

    describe('#toString', function () {
        timezoneTest('America/Los_Angeles', 'toString', function () {
            expect(timezone.toString()).toEqual("America/Los_Angeles");
            expect(timezone.tzid).toEqual("America/Los_Angeles");
            expect(timezone.tznames).toEqual("");

            timezone.tznames = "test";
            expect(timezone.toString()).toEqual("test");
            expect(timezone.tzid).toEqual("America/Los_Angeles");
            expect(timezone.tznames).toEqual("test");
        });
    });

    it('#_compare_change_fn', function () {
        let subject = ICAL.Timezone._compare_change_fn;

        let a = new ICAL.Time({
            year: 2015,
            month: 6,
            day: 15,
            hour: 12,
            minute: 30,
            second: 30
        });

        function vary(prop: string) {
            let b = a.clone();
            expect(subject(a, b)).toEqual(0);
            (b as any)[prop] += 1;
            expect(subject(a, b)).toEqual(-1);
            (b as any)[prop] -= 2;
            expect(subject(a, b)).toEqual(1);
        }

        ['year', 'month', 'day', 'hour', 'minute', 'second'].forEach(vary);
    });
});
