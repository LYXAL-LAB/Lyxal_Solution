import { describe, it, expect, beforeEach, beforeAll, afterAll } from "bun:test";
import { testSupport, assertHasProperties } from "./support/helper";
import ICAL from "../src/index";

describe('icaltime', function () {
    let Time = ICAL.Time;
    let Timezone = ICAL.Timezone;

    it('round trip', function () {
        let f = new Time({
            second: 1,
            minute: 2,
            hour: 3,
            day: 4,
            month: 5,
            year: 6007
        });

        let g = f.clone();
        g.fromJSDate(f.toJSDate());
        expect(f.toString()).toEqual(g.toString());
        // TODO also check UTC dates

        g.reset();
        expect(g.toString()).toEqual(Time.epochTime.toString());
    });

    describe('initialize', function () {
        let icsData: string;
        beforeAll(async function () {
            icsData = await testSupport.loadSample('timezones/America/New_York.ics');
        });

        it('with timezone', function () {
            let parsed = ICAL.parse(icsData);
            let vcalendar = new ICAL.Component(parsed);
            let vtimezone = vcalendar.getFirstSubcomponent('vtimezone');
            let tzid = vtimezone!.getFirstPropertyValue('tzid');

            ICAL.TimezoneService.register(vtimezone!);

            // utc -5
            let time = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 10,
                timezone: tzid as string
            });

            // -5
            expect(time.utcOffset() / 3600).toEqual(-5);

            expect(time.toUnixTime()).toEqual(Date.UTC(2012, 0, 1, 15) / 1000);

            ICAL.TimezoneService.reset();
        });
    });

    describe('.icaltime', function () {
        function verify(time: any, type: string) {
            it('convert time ' + JSON.stringify(time), function () {
                expect((new ICAL.Time(time)).icaltype).toEqual(type);
            });
        }

        verify({ year: 2013, month: 1, day: 1 }, 'date');
        verify(
            { year: 2013, month: 1, day: 1, hour: 3, isDate: true },
            'date'
        );

        verify(
            { year: 2013, month: 1, day: 1, hour: 22 },
            'date-time'
        );

        verify(
            { year: 2013, isDate: false },
            'date-time'
        );

        it('converting types during runtime', function () {
            let time = new ICAL.Time({
                year: 2013, isDate: false
            });

            time.isDate = true;
            expect(time.icaltype).toEqual('date');
        });
    });

    describe('setters', function () {
        let subject: any;

        beforeEach(function () {
            subject = new ICAL.Time({
                year: 2012,
                month: 12,
                day: 31,
                // needed otherwise this object
                // is treated as a date rather then
                // date-time and hour/minute/second will
                // not be normalized/adjusted.
                hour: 0
            });

            // subject.debug = true; // debug property doesn't seem to exist on Time type
        });

        function movedToNextYear() {
            expect(subject.day).toEqual(1);
            expect(subject.month).toEqual(1);
            expect(subject.year).toEqual(2013);
        }

        it('.month / .day beyond the year', function () {
            subject.day++;
            subject.month++;

            expect(subject.day).toEqual(1);
            expect(subject.month).toEqual(2);
            expect(subject.year).toEqual(2013);
        });

        it('.hour', function () {
            subject.hour = 23;
            subject.hour++;

            movedToNextYear();
            expect(subject.hour).toEqual(0);
        });

        it('.minute', function () {
            subject.minute = 59;
            subject.hour = 23;
            subject.minute++;

            movedToNextYear();
            expect(subject.hour).toEqual(0);
            expect(subject.minute).toEqual(0);
        });

        it('.second', function () {
            subject.hour = 23;
            subject.minute = 59;
            subject.second = 59;

            subject.second++;

            movedToNextYear();
            expect(subject.minute).toEqual(0);
            expect(subject.second).toEqual(0);
        });

    });

    describe('#subtractDate and #subtractDateTz', function () {
        testSupport.useTimezones('America/Los_Angeles', 'America/New_York');

        it('diff between two times in different timezones', function () {
            // 3 hours ahead of west
            let east = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 10,
                minute: 20,
                timezone: 'America/New_York'
            });


            let west = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 12,
                minute: 50,
                timezone: 'America/Los_Angeles'
            });

            let diff1 = west.subtractDate(east);
            assertHasProperties(diff1, {
                hours: 2,
                minutes: 30,
                isNegative: false
            });
            let diff2 = west.subtractDateTz(east);
            assertHasProperties(diff2, {
                hours: 5,
                minutes: 30,
                isNegative: false
            });
        });

        it('diff between two times in same timezone', function () {
            let t1 = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 21,
                minute: 50,
                timezone: 'America/Los_Angeles'
            });
            let t2 = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 8,
                minute: 30,
                timezone: 'America/Los_Angeles'
            });

            let diff1 = t1.subtractDate(t2);
            assertHasProperties(diff1, {
                hours: 13,
                minutes: 20,
                isNegative: false
            });

            let diff2 = t1.subtractDateTz(t2);
            assertHasProperties(diff2, {
                hours: 13,
                minutes: 20,
                isNegative: false
            });
        });
        it('negative absolute difference', function () {
            let t1 = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 8,
                minute: 30,
                timezone: 'America/Los_Angeles'
            });
            let t2 = new ICAL.Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 21,
                minute: 50,
                timezone: 'America/Los_Angeles'
            });

            let diff = t1.subtractDate(t2);

            assertHasProperties(diff, {
                hours: 13,
                minutes: 20,
                isNegative: true
            });
        });
    });

    describe('#fromDateTimeString', function () {
        it('utc without decimals', function () {
            let date = "2012-01-01T00:00:00Z";
            let expected = date;
            let subject = Time.fromDateTimeString(date);
            expect(subject.toString()).toEqual(expected);
        });
        it('utc with decimals', function () {
            let date = "2012-01-01T00:00:00.000Z";
            let expected = new Date(date);
            let subject = Time.fromDateTimeString(date);
            expect(subject.toJSDate()).toEqual(expected);
        });
        it('local time with decimals', function () {
            let date = "2012-01-01T00:00:00.000";
            let expected = new Date(date);
            let subject = Time.fromDateTimeString(date);
            expect(subject.toJSDate()).toEqual(expected);
        });
    });

    describe('#fromJSDate', function () {

        it('utc', function () {
            let date = new Date(2012, 0, 1);
            let expected = {
                year: date.getUTCFullYear(),
                // + 1 ICAL.js is not zero based...
                month: date.getUTCMonth() + 1,
                day: date.getUTCDate(),
                hour: date.getUTCHours(),
                minute: date.getUTCMinutes(),
                second: date.getUTCSeconds()
            };

            let subject = Time.fromJSDate(date, true);

            assertHasProperties(
                subject, expected
            );
        });

        it('floating', function () {
            let date = new Date(2012, 0, 1);
            let subject = Time.fromJSDate(date);

            expect(subject.toJSDate()).toEqual(date);
        });

        it('reset', function () {
            let subject = Time.fromJSDate(null);
            let expected = {
                year: 1970,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0,
                isDate: false,
                timezone: "Z"
            };

            assertHasProperties(
                subject, expected
            );
        });
    });

    describe('#fromData', function () {
        it('empty object', function () {
            let subject = Time.fromData(undefined as any);
            let expected = {
                year: 0,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0
            };

            assertHasProperties(subject, expected, 'starts at begining of time');
        });

        it('with year, month', function () {
            let subject = Time.fromData({
                year: 2012,
                month: 1
            });

            assertHasProperties(subject, {
                year: 2012,
                month: 1
            });
        });

        it('utc timezone', function () {
            let subject = Time.fromData({
                year: 2012,
                timezone: 'Z'
            });

            assertHasProperties(subject, {
                year: 2012,
                zone: Timezone.utcTimezone
            });
        });

        it('floating timezone', function () {
            let subject = Time.fromData({
                year: 2012,
                timezone: 'floating'
            });

            assertHasProperties(subject, {
                year: 2012,
                zone: Timezone.localTimezone
            });
        });

        it('setting icaltype', function () {
            let subject = Time.fromData({
                icaltype: 'date-time',
                year: 2012,
                month: 1
            } as any);

            assertHasProperties(subject, {
                icaltype: 'date',
                year: 2012,
                month: 1
            });
        });
    });

    describe('#dayOfWeek', function () {

        // format for dayOfWeek assertion
        // is [dayNumber, dateObject]
        let assertions: [number, Date][] = [
            [Time.SUNDAY, new Date(2012, 0, 1)],
            [Time.MONDAY, new Date(2012, 0, 2)],
            [Time.TUESDAY, new Date(2012, 0, 3)],
            [Time.WEDNESDAY, new Date(2012, 0, 4)],
            [Time.THURSDAY, new Date(2012, 0, 5)],
            [Time.FRIDAY, new Date(2012, 0, 6)],
            [Time.SATURDAY, new Date(2012, 0, 7)]
        ];

        assertions.forEach(function (item) {
            let dayOfWeek = item[0];
            let date = item[1];
            let human = date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate();
            let msg = human + ' should be #' + dayOfWeek + ' day';

            it(msg, function () {
                let subject = ICAL.Time.fromJSDate(
                    date
                );

                expect(subject.dayOfWeek()).toEqual(dayOfWeek as any);
            });
        });

        let assertionsWithWkst: [number, number, Date][] = [
            //wkst, expectedDayofWeek, date
            [Time.SUNDAY, 1, new Date(2012, 0, 1)],
            [Time.SUNDAY, 2, new Date(2012, 0, 2)],
            [Time.SUNDAY, 3, new Date(2012, 0, 3)],
            [Time.SUNDAY, 4, new Date(2012, 0, 4)],
            [Time.SUNDAY, 5, new Date(2012, 0, 5)],
            [Time.SUNDAY, 6, new Date(2012, 0, 6)],
            [Time.SUNDAY, 7, new Date(2012, 0, 7)],
            [Time.MONDAY, 7, new Date(2012, 0, 1)],
            [Time.MONDAY, 1, new Date(2012, 0, 2)],
            [Time.MONDAY, 2, new Date(2012, 0, 3)],
            [Time.MONDAY, 3, new Date(2012, 0, 4)],
            [Time.MONDAY, 4, new Date(2012, 0, 5)],
            [Time.MONDAY, 5, new Date(2012, 0, 6)],
            [Time.MONDAY, 6, new Date(2012, 0, 7)],
            [Time.TUESDAY, 6, new Date(2012, 0, 1)],
            [Time.TUESDAY, 7, new Date(2012, 0, 2)],
            [Time.TUESDAY, 1, new Date(2012, 0, 3)],
            [Time.TUESDAY, 2, new Date(2012, 0, 4)],
            [Time.TUESDAY, 3, new Date(2012, 0, 5)],
            [Time.TUESDAY, 4, new Date(2012, 0, 6)],
            [Time.TUESDAY, 5, new Date(2012, 0, 7)],
            [Time.WEDNESDAY, 5, new Date(2012, 0, 1)],
            [Time.WEDNESDAY, 6, new Date(2012, 0, 2)],
            [Time.WEDNESDAY, 7, new Date(2012, 0, 3)],
            [Time.WEDNESDAY, 1, new Date(2012, 0, 4)],
            [Time.WEDNESDAY, 2, new Date(2012, 0, 5)],
            [Time.WEDNESDAY, 3, new Date(2012, 0, 6)],
            [Time.WEDNESDAY, 4, new Date(2012, 0, 7)],
            [Time.THURSDAY, 4, new Date(2012, 0, 1)],
            [Time.THURSDAY, 5, new Date(2012, 0, 2)],
            [Time.THURSDAY, 6, new Date(2012, 0, 3)],
            [Time.THURSDAY, 7, new Date(2012, 0, 4)],
            [Time.THURSDAY, 1, new Date(2012, 0, 5)],
            [Time.THURSDAY, 2, new Date(2012, 0, 6)],
            [Time.THURSDAY, 3, new Date(2012, 0, 7)],
            [Time.FRIDAY, 3, new Date(2012, 0, 1)],
            [Time.FRIDAY, 4, new Date(2012, 0, 2)],
            [Time.FRIDAY, 5, new Date(2012, 0, 3)],
            [Time.FRIDAY, 6, new Date(2012, 0, 4)],
            [Time.FRIDAY, 7, new Date(2012, 0, 5)],
            [Time.FRIDAY, 1, new Date(2012, 0, 6)],
            [Time.FRIDAY, 2, new Date(2012, 0, 7)],
            [Time.SATURDAY, 2, new Date(2012, 0, 1)],
            [Time.SATURDAY, 3, new Date(2012, 0, 2)],
            [Time.SATURDAY, 4, new Date(2012, 0, 3)],
            [Time.SATURDAY, 5, new Date(2012, 0, 4)],
            [Time.SATURDAY, 6, new Date(2012, 0, 5)],
            [Time.SATURDAY, 7, new Date(2012, 0, 6)],
            [Time.SATURDAY, 1, new Date(2012, 0, 7)]
        ];

        assertionsWithWkst.forEach(function (item) {
            let wkst = item[0];
            let dayOfWeek = item[1];
            let date = item[2];
            let human = date.getFullYear() + '-' + date.getMonth() + '-' + date.getDate();
            let msg = human + ' should be #' + dayOfWeek + ' day';

            it(msg, function () {
                let subject = ICAL.Time.fromJSDate(
                    date
                );

                expect(subject.dayOfWeek(wkst as any)).toEqual(dayOfWeek as any);
            });
        });
    });

    describe('#dayOfYear', function () {
        let inc: number;

        function testYear(start: Date) {
            let end = new Date(
                start.getFullYear() + 1,
                start.getMonth(),
                start.getDate()
            );

            let max = 400;
            let cur = start;
            inc = 1;
            let time = Time.fromJSDate(cur);

            end = new Date(
                end.getFullYear(),
                end.getMonth(),
                0
            );

            while (end.valueOf() >= cur.valueOf()) {
                if (inc > max) {
                    throw new Error('test error inf loop');
                }

                expect(time.dayOfYear()).toEqual(inc);

                cur = new Date(
                    start.getFullYear(),
                    0,
                    start.getDate() + inc
                );
                time = Time.fromJSDate(cur);
                inc++;
            }
        }

        it('full year (2011/no leap)', function () {
            testYear(new Date(2011, 0, 1));
            expect(inc - 1).toEqual(365);
        });

        it('full year (2012 + leap)', function () {
            testYear(new Date(2012, 0, 1));
            expect(inc - 1).toEqual(366);
        });
    });

    describe('#startOfWeek', function () {
        let start = new Date(2012, 1, 1);
        let subject: any;
        let expected: any;

        beforeAll(function () {
            let time = Time.fromJSDate(new Date(
                2012, 0, 29
            ));

            expected = {
                year: time.year,
                month: time.month,
                day: time.day,
                minute: time.minute,
                second: time.second
            };

        });

        [0, 1, 2, 3].forEach((day) => {
            let date = new Date(
                start.getFullYear(),
                start.getMonth(),
                start.getDate() + day
            );

            let msg = 'convert: "' + date.toString() + '" to first day of week';

            it(msg, function () {
                subject = Time.fromJSDate(date);
                assertHasProperties(
                    subject.startOfWeek(),
                    expected
                );
            });
        });

    });

    describe('#getDominicalLetter', function () {
        it('instance', function () {
            let subject = function (yr: number) {
                return (new ICAL.Time({ year: yr })).getDominicalLetter();
            };
            expect(subject(1989)).toEqual("A");
            expect(subject(1990)).toEqual("G");
            expect(subject(1991)).toEqual("F");
            expect(subject(1993)).toEqual("C");
            expect(subject(1994)).toEqual("B");
            expect(subject(1997)).toEqual("E");
            expect(subject(1998)).toEqual("D");

            expect(subject(2000)).toEqual("BA");
            expect(subject(2004)).toEqual("DC");
            expect(subject(2008)).toEqual("FE");
            expect(subject(2012)).toEqual("AG");
            expect(subject(2016)).toEqual("CB");
            expect(subject(2020)).toEqual("ED");
            expect(subject(2024)).toEqual("GF");

        });
        it('static', function () {
            let subject = ICAL.Time.getDominicalLetter;
            expect(subject(1989)).toEqual("A");
            expect(subject(1990)).toEqual("G");
            expect(subject(1991)).toEqual("F");
            expect(subject(1993)).toEqual("C");
            expect(subject(1994)).toEqual("B");
            expect(subject(1997)).toEqual("E");
            expect(subject(1998)).toEqual("D");

            expect(subject(2000)).toEqual("BA");
            expect(subject(2004)).toEqual("DC");
            expect(subject(2008)).toEqual("FE");
            expect(subject(2012)).toEqual("AG");
            expect(subject(2016)).toEqual("CB");
            expect(subject(2020)).toEqual("ED");
            expect(subject(2024)).toEqual("GF");
        });
    });

    describe('#nthWeekDay', function () {
        describe('negative', function () {
            it('last saturday in Sept 2012 (before current day)', function () {
                let time = Time.fromData({ year: 2012, month: 9, day: 1 });

                let day = time.nthWeekDay(Time.SATURDAY, -1);
                let date = new Date(2012, 8, day);

                expect(date).toEqual(new Date(2012, 8, 29));
            });

            it('last Monday in Jan 2012 (target after current day)', function () {
                let time = Time.fromData({ year: 2012, month: 1, day: 1 });

                let day = time.nthWeekDay(Time.MONDAY, -1);
                let date = new Date(2012, 0, day);

                expect(new Date(2012, 0, 30)).toEqual(date);
            });

            it('2nd to last friday after May 15th 2012 (multiple weeks)', function () {
                let time = Time.fromData({ year: 2012, month: 5, day: 15 });

                let day = time.nthWeekDay(Time.FRIDAY, -2);
                let date = new Date(2012, 4, day);

                expect(date).toEqual(new Date(2012, 4, 18));
            });

            it('third to last Tuesday in April 2012 (tuesday)', function () {
                let time = Time.fromData({ year: 2012, month: 4, day: 5 });

                let day = time.nthWeekDay(Time.TUESDAY, -3);
                let date = new Date(2012, 3, day);

                expect(date).toEqual(new Date(2012, 3, 10));
            });

        });

        describe('positive', function () {

            it('1st wed in Feb 2012 (start is day)', function () {
                let time = Time.fromData({ year: 2012, month: 2, day: 1 });
                let day = time.nthWeekDay(Time.WEDNESDAY, 0);

                let date = new Date(2012, 1, day);
                expect(date).toEqual(new Date(2012, 1, 1));
            });

            it('1st monday in Feb 2012 (start is after day)', function () {
                let time = Time.fromData({ year: 2012, month: 2, day: 1 });
                let day = time.nthWeekDay(Time.MONDAY, 0);

                let date = new Date(2012, 1, day);

                expect(date).toEqual(new Date(2012, 1, 6));
            });

            it('20th monday of year (multiple months)', function () {
                let time = Time.fromData({ year: 2012, month: 1, day: 1 });

                let day = time.nthWeekDay(Time.MONDAY, 20);
                let date = new Date(2012, 0, day);

                expect(date).toEqual(new Date(2012, 4, 14));
            });

            it('3rd monday (multiple)', function () {
                let time = Time.fromData({ year: 2012, month: 1, day: 1 });

                let day = time.nthWeekDay(Time.MONDAY, 3);
                let date = new Date(2012, 0, day);

                expect(date).toEqual(new Date(2012, 0, 16));
            });
        });
    });

    describe('#isNthWeekDay', function () {

        it('each day of the week', function () {
            // Remember 1 === SUNDAY not MONDAY
            let start = new Date(2012, 3, 8);
            let time;

            for (let dow = 1; dow <= 7; dow++) {
                time = Time.fromJSDate(new Date(
                    start.getFullYear(),
                    start.getMonth(),
                    7 + dow //8, 9, etc..
                ));

                expect(time.isNthWeekDay(dow as any, 2)).toBeTrue();
            }
        });

        it('on any weekday', function () {
            let dt = Time.fromString('2013-01-08');
            expect(dt.isNthWeekDay(Time.TUESDAY, 0)).toBeTrue();
        });
        it('not weekday at all', function () {
            let dt = Time.fromString('2013-01-08');
            expect(dt.isNthWeekDay(Time.WEDNESDAY, 0)).toBeFalse();
        });
        it('not nth weekday', function () {
            let dt = Time.fromString('2013-01-08');
            expect(dt.isNthWeekDay(Time.TUESDAY, 3)).toBeFalse();
        });

    });

    describe('#toUnixTime', function () {
        it('without timezone', function () {
            let date = new Date(2012, 0, 22, 1, 7, 39);
            let time = new ICAL.Time({
                year: date.getUTCFullYear(),
                month: date.getUTCMonth() + 1,
                day: date.getUTCDate(),
                hour: date.getUTCHours(),
                minute: date.getUTCMinutes(),
                second: date.getUTCSeconds()
            });

            expect(time.toUnixTime()).toEqual(date.valueOf() / 1000);
        });

        describe('with timezone', function () {
            let icsData: string;
            beforeAll(async function () {
                icsData = await testSupport.loadSample('timezones/America/Los_Angeles.ics');
            });

            let subject: any;
            let zone: any;

            beforeEach(function () {
                let parsed = ICAL.parse(icsData);
                let vcalendar = new ICAL.Component(parsed);
                let comp = vcalendar.getFirstSubcomponent('vtimezone');

                zone = new ICAL.Timezone({
                    tzid: comp!.getFirstPropertyValue('tzid') as string,
                    component: comp!
                });

                subject = new ICAL.Time({
                    year: 2012,
                    month: 1,
                    day: 1,
                    hour: 10
                }, zone);
            });

            it('result', function () {
                // we know that subject is -8
                let expectedTime = Date.UTC(
                    2012,
                    0,
                    1,
                    18
                ) / 1000;

                expect(subject.toUnixTime()).toEqual(expectedTime);
            });
        });
    });

    it('#fromUnixTime', function () {
        let time = new ICAL.Time({
            year: 2012,
            month: 1,
            day: 5,
            hour: 8,
            minute: 4,
            second: 13,
            timezone: 'Z'
        });

        let otherTime = new ICAL.Time();
        otherTime.fromUnixTime(time.toUnixTime());

        expect(time.toJSDate()).toEqual(otherTime.toJSDate());

        otherTime.fromUnixTime(time.toUnixTime() + 0.123);

        expect(time.toUnixTime()).toEqual(otherTime.toUnixTime());
        expect(time.toJSDate()).toEqual(otherTime.toJSDate());
        expect(time.second).toEqual(otherTime.second);

        let date = new ICAL.Time({
            year: 2012,
            month: 1,
            day: 5
        });

        date.fromUnixTime(date.toUnixTime());
        expect(date.hour).toEqual(0);
        expect(date.minute).toEqual(0);
        expect(date.second).toEqual(0);
    });

    describe('#adjust', function () {
        let date = new Date(2012, 0, 25);

        it('overflow days - negative', function () {
            let time = Time.fromJSDate(date);
            time.adjust(-35, 0, 0, 0);

            expect(time.toJSDate()).toEqual(new Date(2011, 11, 21));
        });

        it('overflow days - positive', function () {
            let time = Time.fromJSDate(date);

            time.adjust(20, 0, 0, 0);

            expect(time.toJSDate()).toEqual(new Date(2012, 1, 14));
        });

        it('overflow years normalization  - negative', function () {
            let time = Time.fromJSDate(date);

            time.month = 0;
            time.adjust(0, 0, 0, 0);

            expect(time.toJSDate()).toEqual(new Date(2011, 11, 25));
        });

        it('overflow years normalization  - positive', function () {
            let time = Time.fromJSDate(date);

            time.month = 13;
            time.adjust(0, 0, 0, 0);

            expect(time.toJSDate()).toEqual(new Date(2013, 0, 25));
        });

    });

    describe('#startDoyWeek', function () {

        it('forward (using defaults)', function () {
            let subject = Time.fromData({ year: 2012, month: 1, day: 20 });
            let result = subject.startDoyWeek();
            expect(result).toEqual(15);
        });
        it('with different wkst', function () {
            let subject = Time.fromData({ year: 2012, month: 1, day: 1 });
            let result = subject.startDoyWeek(ICAL.Time.MONDAY);
            expect(result).toEqual(-5);
        });
        it('falls on zero', function () {
            let subject = Time.fromData({ year: 2013, month: 1, day: 1 });
            let result = subject.startDoyWeek(ICAL.Time.MONDAY);
            expect(result).toEqual(0);
        });
    });

    describe('#toString', function () {
        it('from fractional seconds', function () {
            let subject = new ICAL.Time({
                year: 2012,
                month: 10,
                day: 10,
                minute: 50,
                // I found this while testing in gaia
                second: 8.3,
                isDate: false
            });

            expect(subject.toString()).toEqual('2012-10-10T00:50:08');
        });
    });

    describe('#toICALString', function () {
        it('date', function () {
            let subject = ICAL.Time.fromString('2012-10-12');
            expect(subject.toICALString()).toEqual('20121012');
        });

        it('date-time', function () {
            let subject = ICAL.Time.fromString('2012-10-12T07:08:09');
            expect(subject.toICALString()).toEqual('20121012T070809');
        });
    });

    describe('#toJSON', function () {
        it('with utc time', function () {
            let time = new Time({
                year: 2012,
                day: 1,
                month: 1,
                hour: 3,
                zone: Timezone.utcTimezone
            });

            let after = new Time(time.toJSON());
            expect(after.zone).toEqual(Timezone.utcTimezone);

            expect(after.toJSDate()).toEqual(time.toJSDate());
        });

        it('with floating time', function () {
            let time = new Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 2,
                minute: 15,
                second: 1,
                isDate: false,
                zone: Timezone.localTimezone
            });

            let expected = {
                year: 2012,
                month: 1,
                day: 1,
                hour: 2,
                minute: 15,
                second: 1,
                isDate: false,
                timezone: 'floating'
            };

            expect(time.toJSON()).toEqual(expected);

            let after = new Time(time.toJSON());
            expect(after.zone).toEqual(Timezone.localTimezone);

            expect(time.toJSDate()).toEqual(after.toJSDate());
        });

        it('with null timezone', function () {
            let time = new Time({
                year: 2012,
                month: 1,
                day: 1,
                hour: 2,
                minute: 15,
                second: 1,
                isDate: false,
            });
            time.zone = null as any;

            let expected = {
                year: 2012,
                month: 1,
                day: 1,
                hour: 2,
                minute: 15,
                second: 1,
                isDate: false,
            };

            expect(time.toJSON()).toEqual(expected);
        });
    });

    it('calculations', function () {

        let test_data: any[] = [{
            str: '2012-01-01T00:00:00',
            expect_unixtime: 1325376000,
            expect_1s: '2012-01-01T00:00:01',
            expect_1m: '2012-01-01T00:01:00',
            expect_1h: '2012-01-01T01:00:00',
            expect_1d: '2012-01-02T00:00:00',
            expect_1w: '2012-01-08T00:00:00'
        }];

        for (let datakey in test_data) {
            let data = test_data[datakey];
            let dt = Time.fromString(data.str);
            let cp = dt.clone();

            expect(dt.toUnixTime()).toEqual(data.expect_unixtime);
            let dur = dt.subtractDate(Time.epochTime);
            expect(dur.toSeconds()).toEqual(data.expect_unixtime);

            cp = dt.clone();
            cp.year += 1;

            let diff = cp.subtractDate(dt);
            let yearseconds = (365 + (Time.isLeapYear(dt.year) ? 1 : 0)) * 86400;
            expect(diff.toSeconds()).toEqual(yearseconds);

            cp = dt.clone();
            cp.year += 2;
            diff = cp.subtractDate(dt);
            yearseconds = (365 + (Time.isLeapYear(dt.year) ? 1 : 0) + 365 + (Time.isLeapYear(dt.year + 1) ? 1 : 0)) * 86400;
            expect(diff.toSeconds()).toEqual(yearseconds);

            cp = dt.clone();
            cp.year -= 1;
            diff = cp.subtractDate(dt);
            yearseconds = (365 + (Time.isLeapYear(cp.year) ? 1 : 0)) * 86400;
            expect(diff.toSeconds()).toEqual(-yearseconds);

            cp = dt.clone();
            cp.second += 3;
            diff = cp.subtractDate(dt);
            expect(diff.toSeconds()).toEqual(3);

            cp = dt.clone();
            cp.addDuration(ICAL.Duration.fromString('PT1S'));
            expect(cp.toString()).toEqual(data.expect_1s);
            cp.addDuration(ICAL.Duration.fromString('-PT1S'));
            expect(cp.toString()).toEqual(dt.toString());

            cp.addDuration(ICAL.Duration.fromString('PT1M'));
            expect(cp.toString()).toEqual(data.expect_1m);
            cp.addDuration(ICAL.Duration.fromString('-PT1M'));
            expect(cp.toString()).toEqual(dt.toString());

            cp.addDuration(ICAL.Duration.fromString('PT1H'));
            expect(cp.toString()).toEqual(data.expect_1h);
            cp.addDuration(ICAL.Duration.fromString('-PT1H'));
            expect(cp.toString()).toEqual(dt.toString());

            cp.addDuration(ICAL.Duration.fromString('P1D'));
            expect(cp.toString()).toEqual(data.expect_1d);
            cp.addDuration(ICAL.Duration.fromString('-P1D'));
            expect(cp.toString()).toEqual(dt.toString());

            cp.addDuration(ICAL.Duration.fromString('P1W'));
            expect(cp.toString()).toEqual(data.expect_1w);
            cp.addDuration(ICAL.Duration.fromString('-P1W'));
            expect(cp.toString()).toEqual(dt.toString());


            cp = dt.clone();
            cp.addDuration(ICAL.Duration.fromString('PT24H'));
            cp.isDate = true;

            // force normalize
            // eslint-disable-next-line no-unused-expressions
            // cp.isDate; // accessing getter for side effect?

            cp.isDate = false;
            expect(cp.toString()).toEqual(data.expect_1d);
        }
    });

    it('#normalize', function () {
        let test_data: any[] = [{
            str: '2012-12-31T23:59:59',
            add_seconds: 1,
            expect: '2013-01-01T00:00:00'
        }, {
            str: '2011-01-01T00:00:00',
            add_seconds: -1,
            expect: '2010-12-31T23:59:59'
        }];

        for (let datakey in test_data) {
            let data = test_data[datakey];
            let dt = Time.fromString(data.str);
            let add_seconds = data.add_seconds || 0;

            dt.second += add_seconds;
            expect(dt.toString()).toEqual(data.expect);
        }
    });

    describe('date properites', function () {
        function testDateProperties(str: string, data: any, only?: boolean) {
            (only ? it.only : it)(str, function () {
                let dt = Time.fromString(str);
                expect(dt.isDate).toEqual(data.isDate);
                expect(dt.year).toEqual(data.year);
                expect(dt.month).toEqual(data.month);
                expect(dt.day).toEqual(data.day);
                expect(dt.hour).toEqual(data.hour);
                expect(dt.minute).toEqual(data.minute);
                expect(dt.second).toEqual(data.second);
                expect(Time.isLeapYear(dt.year)).toEqual(data.leap_year);
                expect(dt.dayOfWeek().toString()).toEqual(data.dayOfWeek.toString());
                expect(dt.dayOfYear().toString()).toEqual(data.dayOfYear.toString());
                expect(dt.startOfWeek().toString()).toEqual(data.startOfWeek.toString());
                expect(dt.endOfWeek().toString()).toEqual(data.endOfWeek.toString());
                expect(dt.startOfMonth().toString()).toEqual(data.startOfMonth.toString());
                expect(dt.endOfMonth().toString()).toEqual(data.endOfMonth.toString());
                expect(dt.startOfYear().toString()).toEqual(data.startOfYear.toString());
                expect(dt.endOfYear().toString()).toEqual(data.endOfYear.toString());
                expect(dt.startDoyWeek(Time.SUNDAY)).toEqual(data.startDoyWeek);
                expect(dt.weekNumber(Time.SUNDAY)).toEqual(data.weekNumber);
                expect(dt.getDominicalLetter()).toEqual(data.getDominicalLetter);
                // TODO nthWeekDay

                dt = new Time();
                dt.resetTo(data.year, data.month, data.day, data.hour, data.minute,
                    data.second, Timezone.utcTimezone);
                expect(dt.year).toEqual(data.year);
                expect(dt.month).toEqual(data.month);
                expect(dt.day).toEqual(data.day);
                expect(dt.hour).toEqual(data.hour);
                expect(dt.minute).toEqual(data.minute);
                expect(dt.second).toEqual(data.second);
            });
        }
        // testDateProperties.only = function(str, data) {
        //   testDateProperties(str, data, true);
        // };

        // A date where the year starts on sunday
        testDateProperties('2012-01-01T00:00:00', {
            isDate: false,
            year: 2012,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            leap_year: true,
            dayOfWeek: Time.SUNDAY,
            dayOfYear: 1,
            startOfWeek: '2012-01-01',
            endOfWeek: '2012-01-07',
            startOfMonth: '2012-01-01',
            endOfMonth: '2012-01-31',
            startOfYear: '2012-01-01',
            endOfYear: '2012-12-31',
            startDoyWeek: 1,
            weekNumber: 1,
            getDominicalLetter: 'AG'
        });
        // A date in week number 53
        testDateProperties('2005-01-01T00:00:00', {
            isDate: false,
            year: 2005,
            month: 1,
            day: 1,
            hour: 0,
            minute: 0,
            second: 0,
            leap_year: false,
            dayOfWeek: Time.SATURDAY,
            dayOfYear: 1,
            startOfWeek: '2004-12-26',
            endOfWeek: '2005-01-01',
            startOfMonth: '2005-01-01',
            endOfMonth: '2005-01-31',
            startOfYear: '2005-01-01',
            endOfYear: '2005-12-31',
            getDominicalLetter: 'B',
            startDoyWeek: -5,
            weekNumber: 53
        });
        // A time in week number 28
        testDateProperties('2015-07-08T01:02:03', {
            isDate: false,
            year: 2015,
            month: 7,
            day: 8,
            hour: 1,
            minute: 2,
            second: 3,
            leap_year: false,
            dayOfWeek: Time.WEDNESDAY,
            dayOfYear: 189,
            startOfWeek: '2015-07-05',
            endOfWeek: '2015-07-11',
            startOfMonth: '2015-07-01',
            endOfMonth: '2015-07-31',
            startOfYear: '2015-01-01',
            endOfYear: '2015-12-31',
            startDoyWeek: 186,
            getDominicalLetter: 'D',
            weekNumber: 28
        });
    });

    it('startOfWeek with different first day of week', function () {
        let test_data: any[] = [{ /* A Sunday */
            str: '2012-01-01T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2011-12-26',
                TUESDAY: '2011-12-27',
                WEDNESDAY: '2011-12-28',
                THURSDAY: '2011-12-29',
                FRIDAY: '2011-12-30',
                SATURDAY: '2011-12-31'
            }
        }, { /* A Monday */
            str: '2012-01-02T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2012-01-02',
                TUESDAY: '2011-12-27',
                WEDNESDAY: '2011-12-28',
                THURSDAY: '2011-12-29',
                FRIDAY: '2011-12-30',
                SATURDAY: '2011-12-31'
            }
        }, { /* A Tuesday */
            str: '2012-01-03T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2012-01-02',
                TUESDAY: '2012-01-03',
                WEDNESDAY: '2011-12-28',
                THURSDAY: '2011-12-29',
                FRIDAY: '2011-12-30',
                SATURDAY: '2011-12-31'
            }
        }, { /* A Wednesday */
            str: '2012-01-04T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2012-01-02',
                TUESDAY: '2012-01-03',
                WEDNESDAY: '2012-01-04',
                THURSDAY: '2011-12-29',
                FRIDAY: '2011-12-30',
                SATURDAY: '2011-12-31'
            }
        }, { /* A Thursday */
            str: '2012-01-05T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2012-01-02',
                TUESDAY: '2012-01-03',
                WEDNESDAY: '2012-01-04',
                THURSDAY: '2012-01-05',
                FRIDAY: '2011-12-30',
                SATURDAY: '2011-12-31'
            }
        }, { /* A Friday */
            str: '2012-01-06T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2012-01-02',
                TUESDAY: '2012-01-03',
                WEDNESDAY: '2012-01-04',
                THURSDAY: '2012-01-05',
                FRIDAY: '2012-01-06',
                SATURDAY: '2011-12-31'
            }
        }, { /* A Saturday */
            str: '2012-01-07T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-01',
                MONDAY: '2012-01-02',
                TUESDAY: '2012-01-03',
                WEDNESDAY: '2012-01-04',
                THURSDAY: '2012-01-05',
                FRIDAY: '2012-01-06',
                SATURDAY: '2012-01-07'
            }
        }];

        for (let datakey in test_data) {
            let data = test_data[datakey];
            let dt = Time.fromString(data.str);
            for (let day in data.firstDayOfWeek) {
                expect(dt.startOfWeek((ICAL.Time as any)[day]).toString()).toEqual(data.firstDayOfWeek[day]);
            }
        }
    });

    it('endOfWeek with different first day of week', function () {
        let test_data: any[] = [{ /* A Sunday */
            str: '2012-01-01T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-01',
                TUESDAY: '2012-01-02',
                WEDNESDAY: '2012-01-03',
                THURSDAY: '2012-01-04',
                FRIDAY: '2012-01-05',
                SATURDAY: '2012-01-06'
            }
        }, { /* A Monday */
            str: '2012-01-02T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-08',
                TUESDAY: '2012-01-02',
                WEDNESDAY: '2012-01-03',
                THURSDAY: '2012-01-04',
                FRIDAY: '2012-01-05',
                SATURDAY: '2012-01-06'
            }
        }, { /* A Tuesday */
            str: '2012-01-03T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-08',
                TUESDAY: '2012-01-09',
                WEDNESDAY: '2012-01-03',
                THURSDAY: '2012-01-04',
                FRIDAY: '2012-01-05',
                SATURDAY: '2012-01-06'
            }
        }, { /* A Wednesday */
            str: '2012-01-04T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-08',
                TUESDAY: '2012-01-09',
                WEDNESDAY: '2012-01-10',
                THURSDAY: '2012-01-04',
                FRIDAY: '2012-01-05',
                SATURDAY: '2012-01-06'
            }
        }, { /* A Thursday */
            str: '2012-01-05T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-08',
                TUESDAY: '2012-01-09',
                WEDNESDAY: '2012-01-10',
                THURSDAY: '2012-01-11',
                FRIDAY: '2012-01-05',
                SATURDAY: '2012-01-06'
            }
        }, { /* A Friday */
            str: '2012-01-06T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-08',
                TUESDAY: '2012-01-09',
                WEDNESDAY: '2012-01-10',
                THURSDAY: '2012-01-11',
                FRIDAY: '2012-01-12',
                SATURDAY: '2012-01-06'
            }
        }, { /* A Saturday */
            str: '2012-01-07T12:01:00',
            firstDayOfWeek: {
                SUNDAY: '2012-01-07',
                MONDAY: '2012-01-08',
                TUESDAY: '2012-01-09',
                WEDNESDAY: '2012-01-10',
                THURSDAY: '2012-01-11',
                FRIDAY: '2012-01-12',
                SATURDAY: '2012-01-13'
            }
        }];

        for (let datakey in test_data) {
            let data = test_data[datakey];
            let dt = Time.fromString(data.str);
            for (let day in data.firstDayOfWeek) {
                expect(dt.endOfWeek((ICAL.Time as any)[day]).toString()).toEqual(data.firstDayOfWeek[day]);
            }
        }
    });

    describe('#compare', function () {
        testSupport.useTimezones('America/New_York', 'America/Los_Angeles');

        it('simple comparison', function () {
            let a = Time.fromString('2001-01-01T00:00:00');
            let b = Time.fromString('2001-01-01T00:00:00');
            expect(a.compare(b)).toEqual(0);

            b = Time.fromString('2002-01-01T00:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-02-01T00:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-02T00:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-01T01:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-01T00:01:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-01T00:00:01');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);
        });

        it('simple comparison one with a timezone, one without', function () {
            // Floating timezone is effectively UTC. New York is 5 hours behind.
            let a = Time.fromString('2001-01-01T00:00:00');
            a.zone = ICAL.TimezoneService.get('America/New_York')!;
            let b = Time.fromString('2001-01-01T05:00:00');
            b.zone = Timezone.localTimezone;
            expect(a.compare(b)).toEqual(0);

            b = Time.fromString('2002-01-01T05:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-02-01T05:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-02T05:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-01T06:00:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-01T05:01:00');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);

            b = Time.fromString('2001-01-01T05:00:01');
            expect(a.compare(b)).toEqual(-1);
            expect(b.compare(a)).toEqual(1);
        });

        it('date-only comparison', function () {
            let a = Time.fromString('2001-01-01');
            let b = Time.fromString('2001-01-01');
            expect(a.compareDateOnlyTz(b, Timezone.localTimezone)).toEqual(0);

            b = Time.fromString('2002-01-01');
            expect(a.compareDateOnlyTz(b, Timezone.localTimezone)).toEqual(-1);
            expect(b.compareDateOnlyTz(a, Timezone.localTimezone)).toEqual(1);

            b = Time.fromString('2001-02-01');
            expect(a.compareDateOnlyTz(b, Timezone.localTimezone)).toEqual(-1);
            expect(b.compareDateOnlyTz(a, Timezone.localTimezone)).toEqual(1);

            b = Time.fromString('2001-01-02');
            expect(a.compareDateOnlyTz(b, Timezone.localTimezone)).toEqual(-1);
            expect(b.compareDateOnlyTz(a, Timezone.localTimezone)).toEqual(1);
        });

        it('both are dates', function () {
            let a = Time.fromString('2014-07-20');
            a.zone = ICAL.TimezoneService.get('America/New_York')!;
            let b = Time.fromString('2014-07-20');
            b.zone = Timezone.localTimezone;

            expect(a.isDate).toBeTruthy();
            expect(b.isDate).toBeTruthy();

            expect(a.compareDateOnlyTz(b, a.zone)).toEqual(0);
            expect(a.compareDateOnlyTz(b, b.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, a.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, b.zone)).toEqual(0);

            // Midnight in New York is after midnight UTC.
            expect(a.compare(b)).toEqual(1);
            expect(b.compare(a)).toEqual(-1);
        });

        it('one is date, one isnt', function () {
            let a = Time.fromString('2014-07-20T12:00:00.000');
            a.zone = ICAL.TimezoneService.get('America/New_York')!;
            let b = Time.fromString('2014-07-20');
            b.zone = Timezone.localTimezone;

            expect(!a.isDate).toBeTruthy();
            expect(b.isDate).toBeTruthy();

            expect(a.compareDateOnlyTz(b, a.zone)).toEqual(0);
            expect(a.compareDateOnlyTz(b, b.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, a.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, b.zone)).toEqual(0);

            // Midday in New York is after midnight UTC.
            expect(a.compare(b)).toEqual(1);
            expect(b.compare(a)).toEqual(-1);
        });

        it('one is date, one isnt', function () {
            let a = Time.fromString('2014-07-20T12:00:00.000');
            a.zone = Timezone.localTimezone;
            let b = Time.fromString('2014-07-20');
            b.zone = ICAL.TimezoneService.get('America/New_York')!;

            expect(!a.isDate).toBeTruthy();
            expect(b.isDate).toBeTruthy();

            expect(a.compareDateOnlyTz(b, a.zone)).toEqual(0);
            expect(a.compareDateOnlyTz(b, b.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, a.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, b.zone)).toEqual(0);

            // Midday UTC is after midnight in New York.
            expect(a.compare(b)).toEqual(1);
            expect(b.compare(a)).toEqual(-1);
        });

        it('both are not dates', function () {
            let a = Time.fromString('2014-07-20T12:00:00.000');
            a.zone = ICAL.TimezoneService.get('America/New_York')!;
            let b = Time.fromString('2014-07-20T12:00:00.000');
            b.zone = Timezone.localTimezone;

            expect(!a.isDate).toBeTruthy();
            expect(!b.isDate).toBeTruthy();

            expect(a.compareDateOnlyTz(b, a.zone)).toEqual(0);
            expect(a.compareDateOnlyTz(b, b.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, a.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, b.zone)).toEqual(0);

            // Midday in New York is after midday UTC.
            expect(a.compare(b)).toEqual(1);
            expect(b.compare(a)).toEqual(-1);
        });

        it('two timezones', function () {
            let a = Time.fromString('2014-07-20T02:00:00.000');
            a.zone = ICAL.TimezoneService.get('America/New_York')!;
            let b = Time.fromString('2014-07-19T23:00:00.000');
            b.zone = ICAL.TimezoneService.get('America/Los_Angeles')!;

            expect(!a.isDate).toBeTruthy();
            expect(!b.isDate).toBeTruthy();

            expect(a.compareDateOnlyTz(b, a.zone)).toEqual(0);
            expect(a.compareDateOnlyTz(b, b.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, a.zone)).toEqual(0);
            expect(b.compareDateOnlyTz(a, b.zone)).toEqual(0);
            expect(a.compare(b)).toEqual(0);
            expect(b.compare(a)).toEqual(0);

            a.isDate = true;
            b.isDate = true;

            expect(a.compareDateOnlyTz(b, a.zone)).toEqual(1);
            expect(a.compareDateOnlyTz(b, b.zone)).toEqual(1);
            expect(b.compareDateOnlyTz(a, a.zone)).toEqual(-1);
            expect(b.compareDateOnlyTz(a, b.zone)).toEqual(-1);
            expect(a.compare(b)).toEqual(1);
            expect(b.compare(a)).toEqual(-1);
        });

        it("compare with period", function () {
            let periodbefore = ICAL.Period.fromData({
                start: Time.fromString("1970-01-02T03:04:03Z"),
                end: Time.fromString("1970-01-02T03:04:04Z")
            });
            let periodat = ICAL.Period.fromData({
                start: Time.fromString("1970-01-02T03:04:05Z"),
                end: Time.fromString("1970-01-02T03:04:05Z")
            });
            let periodafter = ICAL.Period.fromData({
                start: Time.fromString("1970-01-02T03:04:06Z"),
                end: Time.fromString("1970-01-02T03:04:07Z")
            });

            let dt = Time.fromString('1970-01-02T03:04:05Z');

            expect(dt.compare(periodbefore)).toEqual(1);
            expect(dt.compare(periodat)).toEqual(0);
            expect(dt.compare(periodafter)).toEqual(-1);
        });
    });

    it('cache cleared', function () {
        // This test ensures the cached Unix time is cleared whenever the time is changed.
        let time = new Time({
            year: 2015,
            month: 4,
            day: 3,
            hour: 12,
            minute: 34,
            second: 56,
            zone: Timezone.utcTimezone
        });

        expect(time.toUnixTime()).toEqual(1428064496);
        time.year++;
        expect(time.toUnixTime()).toEqual(1459686896);
        time.month++;
        expect(time.toUnixTime()).toEqual(1462278896);
        time.day++;
        expect(time.toUnixTime()).toEqual(1462365296);
        time.hour++;
        expect(time.toUnixTime()).toEqual(1462368896);
        time.minute++;
        expect(time.toUnixTime()).toEqual(1462368956);
        time.second++;
        expect(time.toUnixTime()).toEqual(1462368957);

        time.adjust(-397, -1, -1, -1);
        expect(time.toUnixTime()).toEqual(1428064496);

        time.resetTo(2016, 5, 4, 13, 35, 57);
        expect(time.toUnixTime()).toEqual(1462368957);

        // time.fromString('2015-04-03T12:34:56Z');
        // expect(time.toUnixTime()).toEqual(1428064496);

        time.fromJSDate(new Date(Date.UTC(2015, 0, 1)), true);
        expect(time.toUnixTime()).toEqual(1420070400);

        time.fromData({
            year: 2015,
            month: 4,
            day: 3,
            hour: 12,
            minute: 34,
            second: 56,
            zone: Timezone.utcTimezone
        });
        expect(time.toUnixTime()).toEqual(1428064496);

        time.addDuration(ICAL.Duration.fromString('P1D'));
        expect(time.toUnixTime()).toEqual(1428150896);

        time.fromUnixTime(1234567890);
        expect(time.toUnixTime()).toEqual(1234567890);
    });

    describe("static functions", function () {
        it('daysInMonth', function () {
            expect(Time.daysInMonth(0, 2011)).toEqual(30);
            expect(Time.daysInMonth(2, 2012)).toEqual(29);
            expect(Time.daysInMonth(2, 2013)).toEqual(28);
            expect(Time.daysInMonth(13, 2014)).toEqual(30);
        });

        it('isLeapYear', function () {
            expect(Time.isLeapYear(1752)).toBeTrue();
            expect(Time.isLeapYear(2000)).toBeTrue();
            expect(Time.isLeapYear(2004)).toBeTrue();
            expect(Time.isLeapYear(2100)).toBeFalse();
        });

        it('fromDayOfYear', function () {
            expect(Time.fromDayOfYear(-730, 2001).toICALString()).toEqual("19990101");
            expect(Time.fromDayOfYear(-366, 2001).toICALString()).toEqual("19991231");
            expect(Time.fromDayOfYear(-365, 2001).toICALString()).toEqual("20000101");
            expect(Time.fromDayOfYear(0, 2001).toICALString()).toEqual("20001231");
            expect(Time.fromDayOfYear(365, 2001).toICALString()).toEqual("20011231");
            expect(Time.fromDayOfYear(366, 2001).toICALString()).toEqual("20020101");
            expect(Time.fromDayOfYear(730, 2001).toICALString()).toEqual("20021231");
            expect(Time.fromDayOfYear(731, 2001).toICALString()).toEqual("20030101");
            expect(Time.fromDayOfYear(1095, 2001).toICALString()).toEqual("20031231");
            expect(Time.fromDayOfYear(1096, 2001).toICALString()).toEqual("20040101");
            expect(Time.fromDayOfYear(1461, 2001).toICALString()).toEqual("20041231");
            expect(Time.fromDayOfYear(1826, 2001).toICALString()).toEqual("20051231");
        });

        it('fromStringv2', function () {
            let subject = Time.fromStringv2("2015-01-01");
            let expected = {
                year: 2015,
                month: 1,
                day: 1,
                hour: 0,
                minute: 0,
                second: 0,
                isDate: true,
                timezone: "floating"
            };

            expect(subject.toJSON()).toEqual(expected);
        });

        describe("weekOneStarts", function () {
            function testWeekOne(year: number, dates: any, only?: boolean) {
                let dom = ICAL.Time.getDominicalLetter(year);
                (only ? it.only : it)(year + " (" + dom + ")", function () {
                    for (let wkday in dates) {
                        let icalwkday = (ICAL.Time as any)[wkday];
                        let w1st = Time.weekOneStarts(year, icalwkday);
                        expect(w1st.toString()).toEqual(dates[wkday]);

                        let startOfWeek = ICAL.Time.fromString(dates[wkday]);
                        expect(startOfWeek.weekNumber(icalwkday)).toEqual(1);
                        startOfWeek.day--;
                        // expect(startOfWeek.weekNumber(icalwkday)).toBeGreaterThan(51); // Bun doesn't have toBeGreaterThan?
                        // Using toSatisfy or just standard comparison
                        expect(startOfWeek.weekNumber(icalwkday) > 51).toBeTrue();
                    }
                });
            }
            // testWeekOne.only = function(year, dates) {
            //   testWeekOne(year, dates, true);
            // };

            it('default week start', function () {
                let w1st = Time.weekOneStarts(1989);
                expect(w1st.toString()).toEqual('1989-01-02');
            });

            testWeekOne(1989, { // A and AG
                SUNDAY: '1989-01-01',
                MONDAY: '1989-01-02',
                TUESDAY: '1989-01-03',
                WEDNESDAY: '1989-01-04',
                THURSDAY: '1989-01-05',
                FRIDAY: '1988-12-30',
                SATURDAY: '1988-12-31'
            });
            testWeekOne(1994, { // B and BA
                SUNDAY: '1994-01-02',
                MONDAY: '1994-01-03',
                TUESDAY: '1994-01-04',
                WEDNESDAY: '1994-01-05',
                THURSDAY: '1994-01-06',
                FRIDAY: '1993-12-31',
                SATURDAY: '1994-01-01'
            });
            testWeekOne(1993, { // C and CB
                SUNDAY: '1993-01-03',
                MONDAY: '1993-01-04',
                TUESDAY: '1993-01-05',
                WEDNESDAY: '1993-01-06',
                THURSDAY: '1993-01-07',
                FRIDAY: '1993-01-01',
                SATURDAY: '1993-01-02'
            });
            testWeekOne(1998, { // D and DC
                SUNDAY: '1997-12-28',
                MONDAY: '1997-12-29',
                TUESDAY: '1997-12-30',
                WEDNESDAY: '1997-12-31',
                THURSDAY: '1998-01-01',
                FRIDAY: '1997-12-26',
                SATURDAY: '1997-12-27'
            });
            testWeekOne(1997, { // E and ED
                SUNDAY: '1996-12-29',
                MONDAY: '1996-12-30',
                TUESDAY: '1996-12-31',
                WEDNESDAY: '1997-01-01',
                THURSDAY: '1997-01-02',
                FRIDAY: '1996-12-27',
                SATURDAY: '1996-12-28'
            });
            testWeekOne(1991, { // F and FE
                SUNDAY: '1990-12-30',
                MONDAY: '1990-12-31',
                TUESDAY: '1991-01-01',
                WEDNESDAY: '1991-01-02',
                THURSDAY: '1991-01-03',
                FRIDAY: '1990-12-28',
                SATURDAY: '1990-12-29'
            });
            testWeekOne(1990, { // G and GF
                SUNDAY: '1989-12-31',
                MONDAY: '1990-01-01',
                TUESDAY: '1990-01-02',
                WEDNESDAY: '1990-01-03',
                THURSDAY: '1990-01-04',
                FRIDAY: '1989-12-29',
                SATURDAY: '1989-12-30'
            });
        });
    });
});
