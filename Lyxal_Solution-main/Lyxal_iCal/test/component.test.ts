
import { describe, it, expect, beforeEach } from 'bun:test';
import ICAL, { Component, Property } from '../src/index';
import { testSupport } from './support/helper';

describe('Component', function () {
    let subject: Component;
    let fixtures: any;

    beforeEach(function () {
        fixtures = {
            components: [
                'vevent',
                [
                    ['description', {}, 'text', 'xfoo'],
                    ['description', {}, 'text', 'xfoo2'],
                    ['xfoo', {}, 'text', 'xfoo3']
                ],
                [
                    ['valarm', [], []],
                    ['vtodo', [], []],
                    ['valarm', [['description', {}, 'text', 'foo']], []]
                ]
            ]
        };

        subject = new ICAL.Component(fixtures.components);
    });

    describe("initialization", function () {
        it('initialize component', function () {
            let raw: any = ['description', {}, 'text', 'value'];
            subject = new ICAL.Component(raw);

            expect(subject.jCal).toEqual(raw);
            expect(subject.name).toBe('description');
        });

        it('new component without jCal', function () {
            let newComp = new ICAL.Component('vevent');

            expect(newComp.jCal[0]).toBe('vevent');
            expect(newComp.getAllSubcomponents()).toHaveLength(0);
            expect(newComp.getAllProperties()).toHaveLength(0);
        });

        it("#fromString", function () {
            let comp = ICAL.Component.fromString("BEGIN:VCALENDAR\nX-CALPROP:value\nEND:VCALENDAR");
            expect(comp.name).toBe("vcalendar");
            let prop = comp.getFirstProperty();
            expect(prop!.name).toBe("x-calprop");
            expect(prop!.getFirstValue()).toBe("value");
        });
    });

    describe('parenting', function () {
        // Today we hear a tale about Tom, Marge, Bernhard and Claire.
        let tom: Component, bernhard: Component, claire: Component, marge: Component, relationship: Component;
        let house: Property, otherhouse: Property;

        beforeEach(function () {
            tom = new ICAL.Component("tom");
            bernhard = new ICAL.Component("bernhard");
            claire = new ICAL.Component("claire");
            marge = new ICAL.Component("marge");
            relationship = new ICAL.Component("vrelationship");
            house = new ICAL.Property("house");
            otherhouse = new ICAL.Property("otherhouse");
        });

        it('basic', function () {
            // Tom and Bernhard are best friends. They are happy and single.
            expect(tom.parent).toBeNull();
            expect(bernhard.parent).toBeNull();

            // One day, they get to know Marge, who is also single.
            expect(marge.parent).toBeNull();

            // Tom and Bernhard play rock paper scissors on who gets a first shot at
            // Marge and Tom wins. After a few nice dates they get together.
            relationship.addSubcomponent(tom);
            relationship.addSubcomponent(marge);

            // Both are happy as can be and tell everyone about their love. Nothing
            // goes above their relationship!
            expect(relationship.parent).toBeNull();
            expect(tom.parent).toBe(relationship);
            expect(marge.parent).toBe(relationship);

            // Over the years, there are a few ups and downs.
            relationship.removeSubcomponent(tom);
            expect(relationship.parent).toBeNull();
            expect(tom.parent).toBeNull();
            expect(marge.parent).toBe(relationship);
            relationship.removeAllSubcomponents();
            expect(marge.parent).toBeNull();

            // But in the end they stay together.
            relationship.addSubcomponent(tom);
            relationship.addSubcomponent(marge);
        });

        it('multiple children', function () {
            // After some happy years Tom and Marge get married. Tom is going to be father
            // of his beautiful daughter Claire.
            tom.addSubcomponent(claire);

            // He has no doubt he is the father
            expect(claire.parent).toBe(tom);

            // One day, Tom catches his wife in bed with his best friend Bernhard.
            // Tom is very unhappy and requests a paternity test. It turns out that
            // Claire is actually Bernhard's daughter.
            bernhard.addSubcomponent(claire);

            // Bernhard is happy to hear about his daughter, while Tom goes about to
            // tell everyone he knows. Claire is devastated and would have rather
            // found out about this.
            expect(tom.removeSubcomponent(claire)).toBe(false);

            // Marge knew it all along. What a sad day. Claire is not Tom's daughter,
            // but instead Bernhard's. Tom has no children, and Bernhard is the happy
            // father of his daughter claire.
            expect(claire.parent).toBe(bernhard);
            expect(tom.getFirstSubcomponent()).toBeNull();
            expect(bernhard.getFirstSubcomponent()).toBe(claire);

            // Feeling depressed, Tom tries to find happyness with a pet, but all he
            // got was scratches and sadness. That didn't go so well.
            expect(() => {
                // @ts-ignore
                tom.addProperty("bird");
            }).toThrow('must be instance of ICAL.Property');
        });

        it('properties', function () {
            // Marge lives on a property near the Hamptons, she thinks it belongs to
            // her.
            marge.addProperty(house);
            expect(house.parent).toBe(marge);

            // It seems that Tom didn't always trust Marge, he had fooled her. The
            // house belongs to him.
            tom.addProperty(house);
            expect(house.parent).toBe(tom);
            expect(marge.getFirstProperty()).toBeNull();

            // Bernhard being an aggressive character, tries to throw Tom out of his
            // own house. A long visit in the hospital lets neighbors believe noone
            // lives there anymore.
            tom.removeProperty(house);
            expect(house.parent).toBeNull();

            // Marge spends a few nights there, but also lives in her other house.
            marge.addProperty(house);
            marge.addProperty(otherhouse);
            expect(house.parent).toBe(marge);
            expect(otherhouse.parent).toBe(marge);

            // Tom is back from the hospital and very mad. He throws marge out of his
            // house. Unfortunately marge can no longer pay the rent for her other
            // house either.
            marge.removeAllProperties();
            expect(house.parent).toBeNull();
            expect(otherhouse.parent).toBeNull();

            // What a mess. What do we learn from this testsuite? Infidelity is not a
            // good idea. Always be faithful!
        });
    });

    describe('#getFirstSubcomponent', function () {
        let jCal: any;
        beforeEach(function () {
            jCal = fixtures.components;
            subject = new ICAL.Component(jCal);
        });

        it('without name', function () {
            let component = subject.getFirstSubcomponent();
            expect(component!.parent).toBe(subject);
            expect(component!.name).toBe('valarm');

            // first sub component
            let expected = jCal[2][0];

            expect(component!.jCal).toBe(expected);
        });

        it('with name (when not first)', function () {
            let component = subject.getFirstSubcomponent(
                'vtodo'
            );

            expect(component!.parent).toBe(subject);

            expect(component!.name).toBe('vtodo');
            expect(component!.jCal).toBe(jCal[2][1]);
        });

        it('with name (when there are two)', function () {
            let component = subject.getFirstSubcomponent(
                'valarm'
            );
            expect(component!.name).toBe('valarm');
            expect(component!.jCal).toBe(jCal[2][0]);
        });

        it('equality between calls', function () {
            expect(subject.getFirstSubcomponent()).toBe(subject.getFirstSubcomponent());
        });
    });

    describe('#getAllSubcomponents', function () {
        it('with components', function () {
            // 2 is the component array
            let comps = fixtures.components[2];

            subject = new ICAL.Component(
                fixtures.components
            );

            let result = subject.getAllSubcomponents();
            expect(result).toHaveLength(comps.length);

            for (let i = 0; i < comps.length; i++) {
                expect(result[i]).toBeInstanceOf(ICAL.Component);
                expect(result[i].jCal).toBe(comps[i]);
            }
        });

        it('with name', function () {
            subject = new ICAL.Component(fixtures.components);

            let result = subject.getAllSubcomponents('valarm');
            expect(result).toHaveLength(2);

            result.forEach(function (item) {
                expect(item.name).toBe('valarm');
            });
        });

        it('without components', function () {
            // @ts-ignore
            subject = new ICAL.Component(['foo', [], []]);
            expect(subject.name).toBe('foo');
            expect(subject.getAllSubcomponents()).toHaveLength(0);
        });

        it('with name from end', function () {
            // We need our own subject for this test
            let oursubject = new ICAL.Component(fixtures.components);

            // Get one from the end first
            let comps = fixtures.components[2];
            oursubject.getAllSubcomponents(comps[comps.length - 1][0]);

            // Now get them all, they MUST be hydrated
            let results = oursubject.getAllSubcomponents();
            for (let i = 0; i < results.length; i++) {
                expect(results[i]).toBeDefined();
                expect(results[i].jCal).toBe(subject.jCal[2][i]);
            }
        });
    });

    it('#addSubcomponent', function () {
        let newComp = new ICAL.Component('xnew');

        subject.addSubcomponent(newComp);
        let all = subject.getAllSubcomponents();

        expect(all[all.length - 1]).toBe(newComp);
        expect(all.length).toBe(subject.jCal[2].length);
        expect(subject.jCal[2][all.length - 1]).toBe(newComp.jCal);
    });

    describe('#removeSubcomponent', function () {
        beforeEach(function () {
            subject = new ICAL.Component(fixtures.components);
        });

        it('by name', function () {
            subject.removeSubcomponent('vtodo');

            let all = subject.getAllSubcomponents();

            all.forEach(function (item) {
                expect(item.name).toBe('valarm');
            });
        });

        it('by component', function () {
            let first = subject.getFirstSubcomponent();

            subject.removeSubcomponent(first!);

            expect(subject.getFirstSubcomponent()).not.toBe(first);

            expect(subject.getFirstSubcomponent()!.name).toBe('vtodo');
        });

        it('remove non hydrated subcomponent should not shift hydrated property', function () {
            // @ts-ignore
            let component = new ICAL.Component([
                'vevent',
                [],
                [
                    ['a', [], []],
                    ['b', [], []],
                    ['c', [], []]
                ]
            ]);
            component.getFirstSubcomponent('b');
            component.removeSubcomponent('a');
            let cValue = component.getFirstSubcomponent('c')!.name;
            expect(cValue).toBe('c');
        });
    });

    describe('#removeAllSubcomponents', function () {
        beforeEach(function () {
            subject = new ICAL.Component(fixtures.components);
        });

        it('with name', function () {
            subject.removeAllSubcomponents('valarm');
            expect(subject.jCal[2]).toHaveLength(1);
            expect(subject.jCal[2][0][0]).toBe('vtodo');
            expect(subject.getAllSubcomponents()).toHaveLength(1);
        });

        it('all', function () {
            subject.removeAllSubcomponents();
            expect(subject.jCal[2]).toHaveLength(0);
            expect(subject.getAllSubcomponents()).toHaveLength(0);
        });
    });

    it('#hasProperty', function () {
        subject = new ICAL.Component(
            fixtures.components
        );

        expect(subject.hasProperty('description')).toBeTruthy();
        expect(subject.hasProperty('iknowitsnothere')).toBeFalsy();
    });

    describe('#getFirstProperty', function () {
        beforeEach(function () {
            subject = new ICAL.Component(fixtures.components);
        });

        it('name missing', function () {
            expect(subject.getFirstProperty('x-foo')).toBeNull();
        });

        it('name has multiple', function () {
            let first = subject.getFirstProperty('description');
            expect(first).toBe(subject.getFirstProperty());

            expect(first!.getFirstValue()).toBe('xfoo');
        });

        it('without name', function () {
            let first = subject.getFirstProperty();
            expect(first!.jCal).toBe(fixtures.components[1][0]);
        });

        it('without name empty', function () {
            // @ts-ignore
            subject = new ICAL.Component(['foo', [], []]);
            expect(subject.getFirstProperty()).toBeNull();
        });
    });

    it('#getFirstPropertyValue', function () {
        subject = new ICAL.Component(fixtures.components);
        expect(subject.getFirstPropertyValue()).toBe('xfoo');
    });

    describe('#getAllProperties', function () {
        beforeEach(function () {
            subject = new ICAL.Component(fixtures.components);
        });

        it('with name', function () {
            let results = subject.getAllProperties('description');
            expect(results).toHaveLength(2);

            results.forEach(function (item, i) {
                expect(item.jCal).toBe(subject.jCal[1][i]);
            });
        });

        it('with name empty', function () {
            let results = subject.getAllProperties('wtfmissing');
            expect(results).toEqual([]);
        });

        it('without name', function () {
            let results = subject.getAllProperties();
            results.forEach(function (item, i) {
                expect(item.jCal).toBe(subject.jCal[1][i]);
            });
        });

        it('with name from end', function () {
            // We need our own subject for this test
            let oursubject = new ICAL.Component(fixtures.components);

            // Get one from the end first
            let props = fixtures.components[1];
            oursubject.getAllProperties(props[props.length - 1][0]);

            // Now get them all, they MUST be hydrated
            let results = oursubject.getAllProperties();
            for (let i = 0; i < results.length; i++) {
                expect(results[i]).toBeDefined();
                expect(results[i].jCal).toBe(subject.jCal[1][i]);
            }
        });
    });

    it('#addProperty', function () {
        let prop = new ICAL.Property('description');

        subject.addProperty(prop);
        expect(subject.jCal[1][3]).toBe(prop.jCal);

        let all = subject.getAllProperties();
        let lastProp = all[all.length - 1];

        expect(lastProp).toBe(prop);
        expect(lastProp.parent).toBe(subject);
    });

    it('#addPropertyWithValue', function () {
        subject = new ICAL.Component('vevent');

        subject.addPropertyWithValue('description', 'value');

        let all = subject.getAllProperties();

        expect(all[0].name).toBe('description');
        expect(all[0].getFirstValue()).toBe('value');
    });

    it('#updatePropertyWithValue', function () {
        subject = new ICAL.Component('vevent');
        subject.addPropertyWithValue('description', 'foo');
        expect(subject.getAllProperties()).toHaveLength(1);

        subject.updatePropertyWithValue('description', 'xxx');

        expect(subject.getFirstPropertyValue('description')).toBe('xxx');
        subject.updatePropertyWithValue('x-foo', 'bar');

        let list = subject.getAllProperties();
        const mapped = list.map(prop => [prop.name, prop.getValues()]);
        expect(mapped).toHaveLength(2);
        expect(mapped).toContainEqual(["x-foo", ["bar"]]);
        expect(mapped).toContainEqual(["description", ["xxx"]]);
        expect(subject.getFirstPropertyValue('x-foo')).toBe('bar');
    });

    describe('#removeProperty', function () {
        beforeEach(function () {
            subject = new ICAL.Component(
                fixtures.components
            );
        });

        it('try to remove non-existent', function () {
            let result = subject.removeProperty('wtfbbq');
            expect(result).toBe(false);
        });

        it('remove by property', function () {
            let first = subject.getFirstProperty('description');

            let result = subject.removeProperty(first!);
            expect(result).toBe(true);

            expect(subject.getFirstProperty('description')).not.toBe(first);

            expect(subject.jCal[1]).toHaveLength(2);
        });

        it('remove by name', function () {
            // there are two descriptions
            let list = subject.getAllProperties();
            let first = subject.getFirstProperty('description');

            let result = subject.removeProperty('description');
            expect(result).toBe(true);

            expect(subject.getFirstProperty('description')).not.toBe(first);

            expect(list).toHaveLength(2);
        });

        it('remove non hydrated property should not shift hydrated property', function () {
            // @ts-ignore
            let component = new ICAL.Component([
                'vevent',
                [
                    ['a', {}, 'text', 'a'],
                    ['b', {}, 'text', 'b'],
                    ['c', {}, 'text', 'c']
                ],
                [] // Missing subcomponents array in test fixture causing TS error, but explicit empty array fixes it for constructor?
            ]);
            // Manually ensuring the structure matches what ICAL.Component expects
            // Actually constructor handles partial jCal if strict typing isn't enforced, but using full structure for safety

            component.getFirstPropertyValue('b');
            component.removeProperty('a');
            let cValue = component.getFirstPropertyValue('c');
            expect(cValue).toBe('c');
        });
    });

    describe('#removeAllProperties', function () {
        it('no name when empty', function () {
            subject = new ICAL.Component(
                fixtures.components
            );

            expect(subject.jCal[1]).toHaveLength(3);

            subject.removeAllProperties();

            expect(subject.jCal[1]).toHaveLength(0);
            expect(subject.getFirstProperty()).toBeNull();
        });

        it('no name when not empty', function () {
            // @ts-ignore
            subject = new ICAL.Component(['vevent', [], []]);
            subject.removeAllProperties();
            subject.removeAllProperties('xfoo');
        });

        it('with name', function () {
            subject = new ICAL.Component(
                fixtures.components
            );

            subject.removeAllProperties('description');
            expect(subject.jCal[1]).toHaveLength(1);

            let first = subject.getFirstProperty();

            expect(first!.name).toBe('xfoo');
            expect(subject.jCal[1][0][0]).toBe('xfoo');
        });
    });

    it('#toJSON', function () {
        let json = JSON.stringify(subject);
        let fromJSON = new ICAL.Component(JSON.parse(json));

        expect(fromJSON.jCal).toEqual(subject.jCal);
    });

    it('#toString', function () {
        let ical = subject.toString();
        console.log(ical);
        let parsed = ICAL.parse(ical);
        let fromICAL = new ICAL.Component(parsed);

        expect(fromICAL.jCal).toEqual(subject.jCal);
    });

    it('#getTimeZoneByID', async function () {
        let icsData = await testSupport.loadSample('timezone_from_file.ics');
        let vcalendar = new ICAL.Component(ICAL.parse(icsData));

        let zone = vcalendar.getTimeZoneByID("Nowhere/Middle");
        expect(zone!.tzid).toBe("Nowhere/Middle");

        // Zone remains in cache
        vcalendar.removeSubcomponent("vtimezone");
        zone = vcalendar.getTimeZoneByID("Nowhere/Middle");
        expect(zone!.tzid).toBe("Nowhere/Middle");

        // Lookup from child component
        zone = vcalendar.getFirstSubcomponent("vevent")!.getTimeZoneByID("Nowhere/Middle");
        expect(zone!.tzid).toBe("Nowhere/Middle");

        // Non vcalendar root component
        // @ts-ignore
        let vother = new ICAL.Component(["x-other", [], [["vtimezone", [], []]]]);
        zone = vother.getFirstSubcomponent()!.getTimeZoneByID("Nowhere/Middle");
        expect(zone).toBeNull();


        // Missing timezone definition
        vcalendar = new ICAL.Component(ICAL.parse(icsData));
        vcalendar.removeSubcomponent("vtimezone");
        zone = vcalendar.getTimeZoneByID("Nowhere/Middle");
        expect(zone).toBeNull();
    });
});
