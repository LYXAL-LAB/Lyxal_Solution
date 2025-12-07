import { describe, it, expect, beforeEach } from 'bun:test';
import ICAL, { Property, Component, Time } from '../src/index';
import { testSupport } from './support/helper';

describe('Property', function () {
    let fixtures: any;

    beforeEach(function () {
        fixtures = {
            component: ['vevent', [], []],
            vcardComponent: ['vcard', [], []],

            noValue: [
                'x-foo',
                { prop: 'prop' },
                'text'
            ],

            textProp: [
                'description',
                {},
                'text',
                'foo'
            ],

            withParams: [
                'x-foo',
                {
                    'rsvp': 'TRUE',
                    'meta': 'foo'
                },
                'date',
                '2012-10-01'
            ],

            decoratedMultiValue: [
                'rdate',
                {},
                'date',
                '2012-10-10',
                '2012-10-11'
            ],

            mutliTextValue: [
                'categories',
                {},
                'text',
                'one',
                'two',
                'three'
            ]
        };
    });

    describe('initialization', function () {

        it('undecorated', function () {
            let subject = new Property(
                fixtures.textProp,
                new Component(fixtures.component)
            );

            expect(subject.jCal).toBe(fixtures.textProp);
            expect(subject.name).toBe('description');
            expect(subject.type).toBe('text');

            expect(subject.isDecorated).toBe(false);
        });

        it('multi value', function () {
            let subject = new Property('categories');
            expect(subject.isMultiValue).toBe(true);

            subject = new Property('url');
            expect(subject.isMultiValue).toBe(false);
        });

        it('structured value', function () {
            let subject = new Property('request-status');
            expect(subject.isStructuredValue).toBe(true);

            subject = new Property('url');
            expect(subject.isStructuredValue).toBe(false);
        });

        it('decorated', function () {
            let subject = new Property(
                fixtures.withParams,
                new Component(fixtures.component)
            );

            expect(subject.isDecorated).toBe(true);
        });

        it('new property by name with type', function () {
            let subject = new Property('dtstart');
            expect(subject.type).toBe('date-time');
            expect(subject.jCal[2]).toBe('date-time');
            // @ts-ignore
            expect(subject._designSet).toBe(ICAL.design.icalendar);
        });

        it('new vcard property without parent (unknown type)', function () {
            let subject = new Property('anniversary');
            expect(subject.type).toBe('unknown');
            expect(subject.jCal[2]).toBe('unknown');
            // @ts-ignore
            expect(subject._designSet).toBe(ICAL.design.icalendar);
        });

        it('new vcard property with vcard parent (known type)', function () {
            let parent = new Component(fixtures.vcardComponent);
            let subject = new Property('anniversary', parent);
            expect(subject.type).toBe('date-and-or-time');
            expect(subject.jCal[2]).toBe('date-and-or-time');
            // @ts-ignore
            expect(subject._designSet).toBe(ICAL.design.vcard);
        });

        it('custom design value without defaultType', function () {
            // @ts-ignore
            ICAL.design.defaultSet.property.custom = {};
            let subject = new Property('custom');
            // @ts-ignore
            expect(subject.type).toBe(ICAL.design.defaultType);
            // @ts-ignore
            expect(subject.jCal[2]).toBe(ICAL.design.defaultType);
            // @ts-ignore
            delete ICAL.design.defaultSet.property.custom;
        });

        it('new property by name (typeless)', function () {
            let subject = new Property(
                'description'
            );

            expect(subject.name).toBe('description');

            expect(subject.type).toBe('text');
            expect(subject.jCal[2]).toBe('text');

            expect(subject.getFirstValue()).toBeFalsy();
        });

        it('types change when changing design set', function () {
            let property = new Property('fn');
            let component = new Component('vcard');

            // @ts-ignore
            expect(property._designSet).toBe(ICAL.design.defaultSet);
            expect(property.type).toBe('unknown');

            component.addProperty(property);
            // @ts-ignore
            expect(property._designSet).toBe(ICAL.design.vcard);
            expect(property.type).toBe('text');
        });

        describe('#fromString', function () {
            it('x-prop with known type', function () {
                let prop = Property.fromString("X-FOO;VALUE=BOOLEAN:TRUE");
                expect(prop.name).toBe("x-foo");
                expect(prop.type).toBe("boolean");
                expect(prop.getFirstValue()).toBe(true);
            });

            it("invalid prop", function () {
                expect(() => {
                    Property.fromString("BWAHAHAHAHA");
                }).toThrow(/invalid line/);
            });
        });
    });

    it('#getParameter', function () {
        let subject = new Property(
            fixtures.withParams
        );

        expect(subject.getParameter('rsvp')).toBe('TRUE');
        expect(subject.getParameter('wtf')).toBeUndefined();
    });

    describe('#getFirstParameter', function () {
        it('with multivalue parameter', function () {
            let subject = new Property('categories');

            subject.setParameter('categories', ['Home', 'Work']);

            expect(subject.getFirstParameter('categories')).toBe('Home');
        });

        it('with string parameter', function () {
            let subject = new Property(
                fixtures.withParams
            );

            expect(subject.getFirstParameter('rsvp')).toBe('TRUE');
        });
    });

    it('#removeParameter', function () {
        let subject = new Property(
            fixtures.withParams
        );

        subject.removeParameter('rsvp');
        expect(subject.getParameter('rsvp')).toBeFalsy();
    });

    it('#setParameter', function () {
        let subject = new Property(
            fixtures.textProp
        );

        subject.setParameter(
            'my-prop',
            'woot?'
        );

        expect(subject.getParameter('my-prop')).toBe('woot?');

        expect(subject.jCal[1]).toEqual({ 'my-prop': 'woot?' });
    });

    it('#setMultiValueParameterByString', function () {
        let subject = new Property(
            fixtures.withParams
        );

        subject.setParameter(
            'member',
            'mailto:users@example.net'
        );

        // @ts-ignore
        expect(subject.getParameter('member')[0]).toBe('mailto:users@example.net');
    });

    it('#setMultiValueParameter', function () {
        let subject = new Property(
            fixtures.withParams
        );

        subject.setParameter(
            'member',
            ['mailto:users@example.net']
        );

        // @ts-ignore
        expect(subject.getParameter('member')[0]).toBe('mailto:users@example.net');
    });

    describe('getFirstValue', function () {

        it('with no value', function () {
            let subject = new Property(
                fixtures.noValue
            );

            expect(subject.getFirstValue()).toBeFalsy();
        });

        it('with decorated type', function () {
            let subject = new Property(
                fixtures.withParams
            );

            let value = subject.getFirstValue();

            expect(value).toBeInstanceOf(Time);
            //2012-10-01
            testSupport.assertHasProperties(
                value,
                { year: 2012, month: 10, day: 1, isDate: true },
                'property correctness'
            );

            expect(subject.getFirstValue()).toBe(subject.getFirstValue());
        });

        it('without decorated type', function () {
            let subject = new Property(fixtures.textProp);
            let value = subject.getFirstValue();

            expect(value).toBe(subject.jCal[3]);
        });
    });

    it('#resetType', function () {
        let subject = new Property('dtstart');
        subject.setValue(new Time({ year: 2012, hour: 10, minute: 1 }));

        expect(subject.type).toBe('date-time');

        subject.resetType('date');
        expect(subject.type).toBe('date');

        expect(subject.getFirstValue()).toBeFalsy();
        subject.setValue(new Time({ year: 2012 }));
    });

    describe('#getDefaultType', function () {
        it('known type', function () {
            let subject = new Property('dtstart');
            subject.setValue(new Time({ year: 2012, hour: 20 }));

            expect(subject.type).toBe('date-time');
            expect(subject.getDefaultType()).toBe('date-time');

            subject.setValue(new Time({ year: 2012 }));

            expect(subject.type).toBe('date');
            expect(subject.getDefaultType()).toBe('date-time');
        });

        it('unknown type', function () {
            let subject = new Property('x-unknown');
            subject.setValue(new Time({ year: 2012, hour: 20 }));

            expect((subject.getFirstValue() as Time).icaltype).toBe('date-time');
            expect(subject.type).toBe('date-time');
            expect(subject.getDefaultType()).toBe('unknown');
        });

        it('vcard type', function () {
            let parent = new Component(fixtures.vcardComponent);
            let subject = new Property('anniversary', parent);
            subject.resetType('text');

            expect(subject.getDefaultType()).toBe('date-and-or-time');
        });
    });

    describe('#getFirstValue', function () {
        it('with value', function () {
            let subject = new Property('description');
            subject.setValue('foo');

            expect(subject.getFirstValue()).toBe('foo');
        });

        it('without value', function () {
            let subject = new Property('dtstart');
            expect(subject.getFirstValue()).toBeFalsy();
        });
    });

    describe('#getValues', function () {
        it('decorated', function () {
            let subject = new Property(
                fixtures.decoratedMultiValue
            );

            let result = subject.getValues();
            expect(result).toHaveLength(2);

            // 2012-10-10
            testSupport.assertHasProperties(
                result[0],
                {
                    year: 2012,
                    month: 10,
                    day: 10,
                    isDate: true
                }
            );

            //2012-10-11
            testSupport.assertHasProperties(
                result[1],
                {
                    year: 2012,
                    month: 10,
                    day: 11,
                    isDate: true
                }
            );
        });

        it('undecorated', function () {
            let subject = new Property(
                fixtures.mutliTextValue
            );

            let result = subject.getValues();
            expect(result).toHaveLength(3);
            expect(result).toEqual(
                ['one', 'two', 'three']
            );
        });

        it('single value', function () {
            let subject = new Property(
                fixtures.textProp
            );
            expect(subject.getValues()).toEqual(
                [subject.jCal[3]] // This might be undefined? No, slice(3) behaves differently
            );
        });

        it('no values', function () {
            let subject = new Property(fixtures.noValue);
            expect(subject.getValues()).toEqual([]);
            expect(subject.toICALString()).toBe("X-FOO;PROP=prop:");
        });

        it('foldable value', function () {
            let subject = new Property(fixtures.textProp);
            expect(subject.getValues()).toEqual(['foo']);
            expect(subject.toICALString()).toBe("DESCRIPTION:foo");
            // Fold length should not fold the property here
            // @ts-ignore
            let oldLength = ICAL.foldLength;
            // @ts-ignore
            ICAL.foldLength = 1;
            expect(subject.toICALString()).toBe("DESCRIPTION:foo");
            // @ts-ignore
            ICAL.foldLength = oldLength;
        });
    });

    describe('#setValues', function () {

        it('decorated value', function () {
            let subject = new Property('rdate');
            // @ts-ignore
            let undecorate = ICAL.design.icalendar.value['date-time'].undecorate!;

            let values = [
                new Time({ year: 2012, month: 1 }),
                new Time({ year: 2012, month: 1 })
            ];

            subject.setValues(values);

            expect(subject.jCal.slice(3)).toEqual(
                [undecorate(values[0]), undecorate(values[1])]
            );

            expect(subject.getFirstValue()).toBe(values[0]);
        });

        it('text', function () {
            let subject = new Property('categories');

            subject.setValues(['a', 'b', 'c']);

            expect(subject.getValues()).toEqual(
                ['a', 'b', 'c']
            );

            subject.setValues(['a']);
            expect(subject.getValues()).toEqual(['a']);
        });
    });

    describe('#setValue', function () {

        it('decorated value as string', function () {
            let subject = new Property(
                'dtstart'
            );

            // @ts-ignore
            subject.setValue('2012-09-01T13:00:00');
            let value = subject.getFirstValue();

            expect(subject.type).toBe('date-time');
            expect(value).toBeInstanceOf(Time);

            testSupport.assertHasProperties(value, {
                year: 2012,
                month: 9,
                day: 1,
                hour: 13
            });
        });

        it('decorated value as object', function () {
            let subject = new Property(
                'dtstart'
            );

            let time = new Time({
                year: 2012,
                month: 1,
                day: 5
            });

            subject.setValue(time);
            expect(subject.type).toBe('date');

            expect(subject.jCal[3]).toBe(
                // @ts-ignore
                ICAL.design.icalendar.value.date.undecorate(time)
            );

            expect(subject.getFirstValue()).toBe(time);
        });

        it('text', function () {
            let subject = new Property('description');
            expect(subject.getFirstValue()).toBeFalsy();
            subject.setValue('xxx');
            expect(subject.getFirstValue()).toBe('xxx');
        });

        it('multivalue property', function () {
            let subject = new Property("categories");
            subject.setValues(["work", "play"]);
            subject.setValue("home");
            expect(subject.getValues()).toEqual(["home"]);
            expect(subject.getFirstValue()).toBe("home");
        });

        it('single-value property setting multiple values', function () {
            let subject = new Property("location");
            expect(() => {
                // @ts-ignore
                subject.setValues(["foo", "bar"]);
            }).toThrow(/does not not support multiValue/);
        });
    });

    describe('#toJSON', function () {
        it('default', function () {
            let subject = new Property(['description', {}, 'text', 'foo']);

            expect(subject.toJSON()).toEqual(subject.jCal);

            let fromJSON = new Property(
                JSON.parse(JSON.stringify(subject))
            );

            expect(fromJSON.jCal).toEqual(subject.jCal);
        });
    });
});
