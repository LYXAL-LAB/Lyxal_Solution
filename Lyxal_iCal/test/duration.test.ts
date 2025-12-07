import { describe, it, expect, beforeAll } from 'bun:test';
import ICAL from '../src/index';
import { Duration } from '../src/duration';
import { testSupport } from './support/helper';

describe('ical/duration', function () {
    it('#clone', function () {
        let subject = ICAL.Duration.fromData({
            weeks: 1,
            days: 2,
            hours: 3,
            minutes: 4,
            seconds: 5,
            isNegative: true
        });

        let expected = {
            weeks: 1,
            days: 2,
            hours: 3,
            minutes: 4,
            seconds: 5,
            isNegative: true
        };

        let expected2 = {
            weeks: 6,
            days: 7,
            hours: 8,
            minutes: 9,
            seconds: 10,
            isNegative: true
        };

        let subject2 = subject.clone();
        testSupport.assertHasProperties(subject, expected, 'base object unchanged');
        testSupport.assertHasProperties(subject2, expected, 'cloned object unchanged');

        for (let k in expected2) {
            (subject2 as any)[k] = (expected2 as any)[k];
        }

        testSupport.assertHasProperties(subject, expected, 'base object unchanged');
        testSupport.assertHasProperties(subject2, expected2, 'cloned object changed');
    });

    it('#reset', function () {
        let expected = {
            weeks: 1,
            days: 2,
            hours: 3,
            minutes: 4,
            seconds: 5,
            isNegative: true
        };
        let subject = new ICAL.Duration(expected);
        testSupport.assertHasProperties(subject, expected);

        subject.reset();

        testSupport.assertHasProperties(subject, {
            weeks: 0,
            days: 0,
            hours: 0,
            minutes: 0,
            seconds: 0,
            isNegative: false
        });

        expect(subject.toString()).toEqual("PT0S");
    });

    describe('#normalize', function () {
        function verify(name: string, str: string, data: any) {
            it(name, function () {
                let subject = new ICAL.Duration();
                for (let k in data) {
                    (subject as any)[k] = data[k];
                }
                subject.normalize();
                expect(subject.toString()).toEqual(str);
                expect(subject.toICALString()).toEqual(str);
            });
        }

        verify('weeks and day => days', 'P50D', {
            weeks: 7,
            days: 1
        });
        verify('days => week', 'P2W', {
            days: 14
        });
        verify('days and weeks => week', 'P4W', {
            weeks: 2,
            days: 14
        });
        verify('seconds => everything', 'P1DT1H1M1S', {
            seconds: 86400 + 3600 + 60 + 1
        });
    });

    describe("#compare", function () {
        function verify(str: string, a: string, b: string, cmp: number) {
            it(str, function () {
                let dur_a = ICAL.Duration.fromString(a);
                let dur_b = ICAL.Duration.fromString(b);
                expect(dur_a.compare(dur_b)).toEqual(cmp);
            });
        }

        verify('a>b', 'PT3H', 'PT1S', 1);
        verify('a<b', 'PT2M', 'P1W', -1);
        verify('a=b', 'P1W', 'P7D', 0);
        verify('negative/positive', 'P2H', '-P2H', 1);
    });

    describe('#fromString', function () {
        let base = {
            weeks: 0,
            days: 0,
            minutes: 0,
            seconds: 0,
            isNegative: false
        };

        function verify(string: string, data: any, verifystring?: string) {
            let expected: any = {};
            let key: string;

            for (key in base) {
                expected[key] = (base as any)[key];
            }

            for (key in data) {
                expected[key] = data[key];
            }

            it('parse: "' + string + '"', function () {
                let subject = ICAL.Duration.fromString(string);
                testSupport.assertHasProperties(subject, expected);
                expect(subject.toString()).toEqual(verifystring || string);
            });
        }

        function verifyFail(string: string, errorParam: RegExp) {
            it('expected failure: ' + string, function () {
                expect(() => {
                    ICAL.Duration.fromString(string);
                }).toThrow(errorParam);
            });
        }

        verify('P7W', {
            weeks: 7
        });

        verify('PT1H0M0S', {
            hours: 1
        }, "PT1H");

        verify('PT15M', {
            minutes: 15
        });

        verify('P15DT5H0M20S', {
            days: 15,
            hours: 5,
            seconds: 20
        }, "P15DT5H20S");

        verify('-P0DT0H30M0S', {
            isNegative: true,
            weeks: 0,
            days: 0,
            minutes: 30,
            seconds: 0
        }, "-PT30M");

        verifyFail('PT1WH', /Missing number before "H"/);
        verifyFail('PT1WsomeH', /Invalid number "some" before "H"/);
    });
});
