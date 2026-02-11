import { describe, it, expect, beforeEach, beforeAll, afterAll } from "bun:test";
import ICAL, { Timezone } from "../src/index";
import { testSupport, assertHasProperties } from "./support/helper";

describe('design', () => {

    let timezone: Timezone;
    beforeAll(async () => {
        let data = await testSupport.loadSample('timezones/America/New_York.ics');
        let parsed = ICAL.parse(data);
        let vcalendar = new ICAL.Component(parsed);
        let vtimezone = vcalendar.getFirstSubcomponent('vtimezone');

        timezone = new ICAL.Timezone(vtimezone!);
        ICAL.TimezoneService.register('test', timezone);
    });

    afterAll(() => {
        ICAL.TimezoneService.reset();
    });

    let subject: any;
    beforeEach(() => {
        subject = ICAL.design.defaultSet;
    });

    describe('types', () => {

        describe('binary', () => {
            beforeEach(() => {
                subject = subject.value.binary;
            });

            it('#(un)decorate', () => {
                let expectedDecode = 'The quick brown fox jumps over the lazy dog.';
                let undecorated = 'VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcy' +
                    'BvdmVyIHRoZSBsYXp5IGRvZy4=';

                let decorated = subject.decorate(undecorated);
                let decoded = decorated.decodeValue();

                expect(decoded).toEqual(expectedDecode);

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe('date', () => {
            beforeEach(() => {
                subject = subject.value.date;
            });

            it('#fromICAL', () => {
                let value = subject.fromICAL(
                    '20121010'
                );

                expect(value).toEqual('2012-10-10');
            });

            it('#toICAL', () => {
                let value = subject.toICAL(
                    '2012-10-10'
                );

                expect(value).toEqual('20121010');
            });

            it('#to/fromICAL (lenient)', () => {
                let value = '20120901T130000';
                let expected = '2012-09-01T13:00:00';

                ICAL.design.strict = false;
                expect(subject.fromICAL(value)).toEqual(expected);

                expect(subject.toICAL(expected)).toEqual(value);
                ICAL.design.strict = true;
            });

            it('#toICAL invalid', () => {
                let value = subject.toICAL(
                    'wheeeeeeeeeeeeee'
                );

                expect(value).toEqual('wheeeeeeeeeeeeee');
            });


            it('#fromICAL somewhat invalid', () => {
                // Strict mode is not completely strict, it takes a lot of shortcuts in the name of
                // performance. The functions in ICAL.design don't actually throw errors, given there is no
                // error collector. With a working error collector we should make lenient mode the default
                // and have strict mode be more pedantic.
                let value = subject.fromICAL('20131210Z');
                expect(value).toEqual('2013-12-10');
            });

            it('#(un)decorate (lenient)', () => {
                let value = '2012-10-10T11:12:13';
                let prop = new ICAL.Property(['date', { tzid: 'test' }, 'date']);

                ICAL.design.strict = false;

                let time = subject.decorate(
                    value,
                    prop
                );

                assertHasProperties(
                    time,
                    { year: 2012, month: 10, day: 10, hour: 11, minute: 12, second: 13, isDate: false }
                );

                expect(subject.undecorate(time)).toEqual(value);
                ICAL.design.strict = true;

            });

            it('#(un)decorate (custom timezone)', () => {
                let value = '2012-10-10';
                let prop = new ICAL.Property(['date', { tzid: 'test' }, 'date']);

                let time = subject.decorate(
                    value,
                    prop
                );

                assertHasProperties(
                    time,
                    { year: 2012, month: 10, day: 10, isDate: true }
                );

                expect(subject.undecorate(time)).toEqual(value);
            });
        });

        describe('date-time', () => {
            beforeEach(() => {
                subject = subject.value['date-time'];
            });

            it('#(from|to)ICAL', () => {
                let value = '20120901T130000';
                let expected = '2012-09-01T13:00:00';

                expect(subject.fromICAL(value)).toEqual(expected);

                expect(subject.toICAL(expected)).toEqual(value);
            });
            it('#toICAL invalid', () => {
                let value = subject.toICAL(
                    'wheeeeeeeeeeeeee'
                );

                expect(value).toEqual('wheeeeeeeeeeeeee');
            });

            it('#from/toICAL (lenient)', () => {
                let value = '20190102';
                let expected = '2019-01-02';

                ICAL.design.strict = false;
                expect(subject.fromICAL(value)).toEqual(expected);

                expect(subject.toICAL(expected)).toEqual(value);
                ICAL.design.strict = true;
            });
            it('#(un)decorate (lenient)', () => {
                ICAL.design.strict = false;
                let undecorated = '2012-09-01';
                let prop = new ICAL.Property(['date-time', {}, 'date-time']);

                let decorated = subject.decorate(undecorated, prop);

                assertHasProperties(
                    decorated,
                    {
                        year: 2012,
                        month: 9,
                        day: 1,
                        isDate: true
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);
                ICAL.design.strict = true;
            });

            it('#(un)decorate (utc)', () => {
                let undecorated = '2012-09-01T13:05:11Z';
                let prop = new ICAL.Property(['date-time', {}, 'date-time']);

                let decorated = subject.decorate(undecorated, prop);

                assertHasProperties(
                    decorated,
                    {
                        year: 2012,
                        month: 9,
                        day: 1,
                        hour: 13,
                        minute: 5,
                        second: 11,
                        isDate: false,
                        zone: ICAL.Timezone.utcTimezone
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });

            it('#(un)decorate (custom timezone)', () => {
                let prop = new ICAL.Property(
                    ['date-time', { tzid: 'test' }, 'date-time']
                );
                expect(prop.getParameter('tzid')).toEqual('test');

                ICAL.TimezoneService.register(
                    'America/Los_Angeles',
                    ICAL.Timezone.utcTimezone
                );

                let undecorated = '2012-09-01T13:05:11';
                let decorated = subject.decorate(undecorated, prop);
                expect(decorated.zone).toEqual(timezone);

                assertHasProperties(
                    decorated,
                    {
                        year: 2012,
                        month: 9,
                        day: 1,
                        hour: 13,
                        minute: 5,
                        second: 11,
                        isDate: false
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe('time', () => {
            beforeEach(() => {
                subject = subject.value.time;
            });

            it('#fromICAL', () => {
                let value = subject.fromICAL(
                    '232050'
                );

                expect(value).toEqual('23:20:50');
            });
            it('#fromICAL invalid', () => {
                let value = subject.fromICAL(
                    'whoop'
                );

                expect(value).toEqual('whoop');
            });

            it('#toICAL', () => {
                let value = subject.toICAL(
                    '23:20:50'
                );

                expect(value).toEqual('232050');
            });
            it('#toICAL invalid', () => {
                let value = subject.toICAL(
                    'whoop'
                );

                expect(value).toEqual('whoop');
            });
        });

        describe('vcard date/time types', () => {
            function testRoundtrip(jcal: string, ical: string, props: any, only?: boolean) {
                function testForType(type: string, valuePrefix?: string, valueSuffix?: string, zone?: string) {
                    let valueType = (ICAL.design as any).vcard.value[type];
                    let prefix = valuePrefix || '';
                    let suffix = valueSuffix || '';
                    let jcalvalue = prefix + jcal + suffix;
                    let icalvalue = prefix + ical + suffix.replace(':', '');
                    let zoneName = zone || valueSuffix || "floating";

                    it(type + ' ' + zoneName + ' fromICAL/toICAL', () => {
                        expect(valueType.fromICAL(icalvalue)).toEqual(jcalvalue);
                        expect(valueType.toICAL(jcalvalue)).toEqual(icalvalue);
                    });

                    it(type + ' ' + zoneName + ' decorated/undecorated', () => {
                        let prop = new ICAL.Property(['anniversary', {}, type]);
                        let decorated = valueType.decorate(jcalvalue, prop);
                        let undecorated = valueType.undecorate(decorated);

                        assertHasProperties(decorated._time, props);
                        expect(zoneName).toEqual(decorated.zone.toString());
                        expect(undecorated).toEqual(jcalvalue);
                        expect(decorated.toICALString()).toEqual(icalvalue);
                    });
                }
                describe(jcal, () => {

                    if (props.year || props.month || props.day) {
                        testForType('date-and-or-time');
                        if (!props.hour && !props.minute && !props.second) {
                            testForType('date');
                        } else {
                            testForType('date-time');
                        }
                    } else if (props.hour || props.minute || props.second) {
                        if (!props.year && !props.month && !props.day) {
                            testForType('date-and-or-time', 'T');
                            testForType('date-and-or-time', 'T', 'Z', 'UTC');
                            testForType('date-and-or-time', 'T', '-08:00');
                            testForType('date-and-or-time', 'T', '+08:00');
                            testForType('time');
                            testForType('time', undefined, 'Z', 'UTC');
                            testForType('time', undefined, '-08:00');
                            testForType('time', undefined, '+08:00');
                        } else {
                            testForType('date-and-or-time', undefined);
                            testForType('date-and-or-time', undefined, 'Z', 'UTC');
                            testForType('date-and-or-time', undefined, '-08:00');
                            testForType('date-and-or-time', undefined, '+08:00');
                        }
                    }
                });
            }

            // dates
            testRoundtrip('1985-04-12', '19850412', {
                year: 1985,
                month: 4,
                day: 12,
                hour: null,
                minute: null,
                second: null
            });
            testRoundtrip('1985-04', '1985-04', {
                year: 1985,
                month: 4,
                day: null,
                hour: null,
                minute: null,
                second: null
            });
            testRoundtrip('1985', '1985', {
                year: 1985,
                month: null,
                day: null,
                hour: null,
                minute: null,
                second: null
            });
            testRoundtrip('--04-12', '--0412', {
                year: null,
                month: 4,
                day: 12,
                hour: null,
                minute: null,
                second: null
            });
            testRoundtrip('--04', '--04', {
                year: null,
                month: 4,
                day: null,
                hour: null,
                minute: null,
                second: null
            });
            testRoundtrip('---12', '---12', {
                year: null,
                month: null,
                day: 12,
                hour: null,
                minute: null,
                second: null
            });

            // times
            testRoundtrip('23:20:50', '232050', {
                year: null,
                month: null,
                day: null,
                hour: 23,
                minute: 20,
                second: 50,
            });
            testRoundtrip('23:20', '2320', {
                year: null,
                month: null,
                day: null,
                hour: 23,
                minute: 20,
                second: null,
            });
            testRoundtrip('23', '23', {
                year: null,
                month: null,
                day: null,
                hour: 23,
                minute: null,
                second: null,
            });
            testRoundtrip('-20:50', '-2050', {
                year: null,
                month: null,
                day: null,
                hour: null,
                minute: 20,
                second: 50,
            });
            testRoundtrip('-20', '-20', {
                year: null,
                month: null,
                day: null,
                hour: null,
                minute: 20,
                second: null,
            });
            testRoundtrip('--50', '--50', {
                year: null,
                month: null,
                day: null,
                hour: null,
                minute: null,
                second: 50,
            });

            // date-times
            testRoundtrip('1985-04-12T23:20:50', '19850412T232050', {
                year: 1985,
                month: 4,
                day: 12,
                hour: 23,
                minute: 20,
                second: 50
            });
            testRoundtrip('1985-04-12T23:20', '19850412T2320', {
                year: 1985,
                month: 4,
                day: 12,
                hour: 23,
                minute: 20,
                second: null
            });
            testRoundtrip('1985-04-12T23', '19850412T23', {
                year: 1985,
                month: 4,
                day: 12,
                hour: 23,
                minute: null,
                second: null
            });
            testRoundtrip('--04-12T23:20', '--0412T2320', {
                year: null,
                month: 4,
                day: 12,
                hour: 23,
                minute: 20,
                second: null
            });
            testRoundtrip('--04T23:20', '--04T2320', {
                year: null,
                month: 4,
                day: null,
                hour: 23,
                minute: 20,
                second: null
            });
            testRoundtrip('---12T23:20', '---12T2320', {
                year: null,
                month: null,
                day: 12,
                hour: 23,
                minute: 20,
                second: null
            });
            testRoundtrip('--04T23', '--04T23', {
                year: null,
                month: 4,
                day: null,
                hour: 23,
                minute: null,
                second: null
            });
        });

        describe('duration', () => {
            beforeEach(() => {
                subject = subject.value.duration;
            });

            it('#(un)decorate', () => {
                let undecorated = 'P15DT5H5M20S';
                let decorated = subject.decorate(undecorated);
                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe('float', () => {
            beforeEach(() => {
                subject = subject.value.float;
            });

            it('#(from|to)ICAL', () => {
                let original = '1.5';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual(1.5);
                expect(subject.toICAL(fromICAL)).toEqual(original);
            });
        });

        describe('integer', () => {
            beforeEach(() => {
                subject = subject.value.integer;
            });

            it('#(from|to)ICAL', () => {
                let original = '105';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual(105);
                expect(subject.toICAL(fromICAL)).toEqual(original);
            });
        });

        describe('period', () => {
            beforeEach(() => {
                subject = subject.value.period;
            });
            it('#(to|from)ICAL date/date (lenient)', () => {
                let original = '19970101/19970102';
                ICAL.design.strict = false;

                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual(['1997-01-01', '1997-01-02']);

                expect(subject.toICAL(fromICAL)).toEqual(original);

                ICAL.design.strict = true;
            });

            it('#(to|from)ICAL date/date', () => {
                let original = '19970101T180000Z/19970102T070000Z';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual(['1997-01-01T18:00:00Z', '1997-01-02T07:00:00Z']);

                expect(subject.toICAL(fromICAL)).toEqual(original);
            });

            it('#(un)decorate (date-time/duration)', () => {
                let prop = new ICAL.Property(['date', { tzid: 'test' }, 'date']);

                let undecorated = ['1997-01-01T18:00:00', 'PT5H30M'];
                let decorated = subject.decorate(
                    undecorated,
                    prop
                );

                assertHasProperties(
                    decorated.start,
                    {
                        year: 1997,
                        day: 1,
                        month: 1,
                        hour: 18
                    }
                );

                expect(decorated.start.zone).toEqual(timezone);

                assertHasProperties(
                    decorated.duration,
                    {
                        hours: 5,
                        minutes: 30
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });

            it('#(un)decorate (date-time/date-time)', () => {
                let prop = new ICAL.Property(['date', { tzid: 'test' }, 'date']);

                let undecorated = ['1997-01-01T18:00:00', '1998-01-01T17:00:00'];
                let decorated = subject.decorate(
                    undecorated,
                    prop
                );

                assertHasProperties(
                    decorated.start,
                    {
                        year: 1997,
                        day: 1,
                        month: 1,
                        hour: 18
                    }
                );

                assertHasProperties(
                    decorated.end,
                    {
                        year: 1998,
                        day: 1,
                        month: 1,
                        hour: 17
                    }
                );


                expect(decorated.start.zone).toEqual(timezone);
                expect(decorated.end.zone).toEqual(timezone);

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });

            it('#(un)decorate (lenient, date/date)', () => {
                ICAL.design.strict = false;

                let prop = new ICAL.Property(['date', { tzid: 'test' }, 'date']);

                let undecorated = ['1997-01-01', '1998-01-01'];
                let decorated = subject.decorate(
                    undecorated,
                    prop
                );

                assertHasProperties(
                    decorated.start,
                    {
                        year: 1997,
                        day: 1,
                        month: 1,
                        isDate: true
                    }
                );

                assertHasProperties(
                    decorated.end,
                    {
                        year: 1998,
                        day: 1,
                        month: 1,
                        isDate: true
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);

                ICAL.design.strict = true;
            });

            it('#(un)decorate (date-time/duration) 2', () => {
                let prop = new ICAL.Property(['date', { tzid: 'test' }, 'date']);

                let undecorated = ['1997-01-01T18:00:00', 'PT5H30M'];
                let decorated = subject.decorate(
                    undecorated,
                    prop
                );

                assertHasProperties(
                    decorated.start,
                    {
                        year: 1997,
                        day: 1,
                        month: 1,
                        hour: 18
                    }
                );

                expect(decorated.start.zone).toEqual(timezone);

                assertHasProperties(
                    decorated.duration,
                    {
                        hours: 5,
                        minutes: 30
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe('recur', () => {
            beforeEach(() => {
                subject = subject.value.recur;
            });

            it('#(to|from)ICAL', () => {
                let original = 'FREQ=MONTHLY;UNTIL=20121112T131415;COUNT=1';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual({
                    freq: 'MONTHLY',
                    until: '2012-11-12T13:14:15',
                    count: 1
                });

                expect(subject.toICAL(fromICAL)).toEqual(original);
            });

            it('#(un)decorate', () => {
                let undecorated = { freq: "MONTHLY", byday: ["MO", "TU", "WE", "TH", "FR"], until: "2012-10-12" };
                let decorated = subject.decorate(undecorated);

                expect(decorated instanceof ICAL.Recur).toBeTrue();

                assertHasProperties(
                    decorated,
                    {
                        freq: 'MONTHLY',
                        parts: {
                            BYDAY: ['MO', 'TU', 'WE', 'TH', 'FR']
                        }
                    }
                );

                assertHasProperties(
                    decorated.until,
                    {
                        year: 2012,
                        month: 10,
                        day: 12
                    }
                );

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe('utc-offset', () => {
            beforeEach(() => {
                subject = subject.value['utc-offset'];
            });

            it('#(to|from)ICAL without seconds', () => {
                let original = '-0500';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual('-05:00');
                expect(subject.toICAL(fromICAL)).toEqual(original);
            });

            it('#(to|from)ICAL with seconds', () => {
                let original = '+054515';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual('+05:45:15');
                expect(subject.toICAL(fromICAL)).toEqual(original);
            });

            it('#(un)decorate', () => {
                let undecorated = '-05:00';
                let decorated = subject.decorate(undecorated);

                expect(decorated.hours).toEqual(5);
                expect(decorated.factor).toEqual(-1);

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe('utc-offset (vcard3)', () => {
            beforeEach(() => {
                subject = (ICAL.design as any).vcard3.value['utc-offset'];
            });

            it('#(to|from)ICAL', () => {
                let original = '-05:00';
                let fromICAL = subject.fromICAL(original);

                expect(fromICAL).toEqual('-05:00');
                expect(subject.toICAL(fromICAL)).toEqual(original);
            });

            it('#(un)decorate', () => {
                let undecorated = '-05:00';
                let decorated = subject.decorate(undecorated);

                expect(decorated.hours).toEqual(5);
                expect(decorated.factor).toEqual(-1);

                expect(subject.undecorate(decorated)).toEqual(undecorated);
            });
        });

        describe("unknown and default values", () => {
            it("unknown x-prop", () => {
                let prop = new ICAL.Property("x-wr-calname");
                expect(prop.type).toEqual("unknown");

                prop = ICAL.Property.fromString("X-WR-CALNAME:value");
                expect(prop.type).toEqual("unknown");
            });

            it("unknown iana prop", () => {
                let prop = new ICAL.Property("standardized");
                expect(prop.type).toEqual("unknown");

                prop = ICAL.Property.fromString("STANDARDIZED:value");
                expect(prop.type).toEqual("unknown");
            });

            it("known text type", () => {
                let prop = new ICAL.Property("description");
                expect(prop.type).toEqual("text");

                prop = ICAL.Property.fromString("DESCRIPTION:value");
                expect(prop.type).toEqual("text");
            });

            it("encoded text value roundtrip", () => {
                let prop = new ICAL.Property("description");
                prop.setValue("hello, world");
                let propVal = prop.toICALString();
                expect(propVal).toEqual("DESCRIPTION:hello\\, world");

                prop = ICAL.Property.fromString(propVal);
                expect(prop.getFirstValue()).toEqual("hello, world");
            });

            it("encoded unknown value roundtrip", () => {
                let prop = new ICAL.Property("x-wr-calname");
                prop.setValue("hello, world");
                let propVal = prop.toICALString();
                expect(propVal).toEqual("X-WR-CALNAME:hello, world");

                prop = ICAL.Property.fromString(propVal);
                expect(prop.getFirstValue()).toEqual("hello, world");
            });

            it("encoded unknown value from string", () => {
                let prop = ICAL.Property.fromString("X-WR-CALNAME:hello\\, world");
                expect(prop.getFirstValue()).toEqual("hello\\, world");
            });

            describe("registration", () => {
                it("newly registered property", () => {
                    let prop = new ICAL.Property("nonstandard");
                    expect(prop.type).toEqual("unknown");

                    (ICAL.design.defaultSet.property as any).nonstandard = {
                        defaultType: "date-time"
                    };

                    prop = new ICAL.Property("nonstandard");
                    expect(prop.type).toEqual("date-time");

                    delete (ICAL.design.defaultSet.property as any).nonstandard;
                });

                it("unknown value type", () => {
                    let prop = ICAL.Property.fromString("X-PROP;VALUE=FUZZY:WARM");
                    expect(prop.name).toEqual("x-prop");
                    expect(prop.type).toEqual("fuzzy");
                    expect(prop.getFirstValue()).toEqual("WARM");
                    prop.setValue("FREEZING");
                    expect(prop.getFirstValue()).toEqual("FREEZING");
                });

                it("newly registered value type", () => {
                    (ICAL.design.defaultSet.value as any).fuzzy = {
                        fromICAL: function (aValue: string) {
                            return aValue.toLowerCase();
                        },
                        toICAL: function (aValue: string) {
                            return aValue.toUpperCase();
                        }
                    };

                    let prop = ICAL.Property.fromString("X-PROP;VALUE=FUZZY:WARM");
                    expect(prop.name).toEqual("x-prop");
                    expect(prop.getFirstValue()).toEqual("warm");
                    expect(prop.toICALString()).toMatch(/WARM/);

                    delete (ICAL.design.defaultSet.value as any).fuzzy;
                });

                it("newly registered parameter", () => {
                    let prop = ICAL.Property.fromString("X-PROP;VALS=a,b,c:def");
                    let param = prop.getParameter("vals");
                    expect(param).toEqual("a,b,c");

                    (ICAL.design.defaultSet.param as any).vals = { multiValue: "," };

                    prop = ICAL.Property.fromString("X-PROP;VALS=a,b,c:def");
                    param = prop.getParameter("vals");
                    expect(param).toEqual(["a", "b", "c"]);

                    delete (ICAL.design.defaultSet.param as any).vals;
                });
            });
        });
    });

    describe('design sets', () => {
        it('detection', () => {
            let component = new ICAL.Component(ICAL.parse(
                'BEGIN:VCARD\n' +
                'VERSION:4.0\n' +
                'FN:Fun Name\n' +
                'BDAY:--0203\n' +
                'END:VCARD'
            ));
            expect((component as any)._designSet?.name).toEqual('vcard4');
            expect((component.getFirstProperty('fn') as any)._designSet?.name).toEqual('vcard4');

            component = new ICAL.Component(ICAL.parse(
                'BEGIN:VCARD\n' +
                'VERSION:3.0\n' +
                'FN:Fun Name\n' +
                'TEL;TYPE=VOICE,MSG,WORK:+1-555-937-3419\n' +
                'TEL;TYPE=FAX,WORK:+1-555-528-4164\n' +
                'EMAIL;TYPE=INTERNET:user@example.com\n' +
                'END:VCARD'
            ));
            expect((component as any)._designSet?.name).toEqual('vcard3');
            expect((component.getFirstProperty('fn') as any)._designSet?.name).toEqual('vcard3');

            component = new ICAL.Component(ICAL.parse(
                'BEGIN:VCALENDAR\n' +
                'PRODID:-//Google Inc//Google Calendar 70.9054//EN\n' +
                'VERSION:2.0\n' +
                'END:VCALENDAR'
            ));
            expect((component as any)._designSet?.name).toEqual('ical');
            expect((component.getFirstProperty('version') as any)._designSet?.name).toEqual('ical');
        });
    });
});
