import { describe, it, expect, beforeEach } from "bun:test";
import ICAL from "../src/index";
import { testSupport, assertHasProperties } from "./support/helper";

describe('ICAL.stringify', () => {

    describe('round trip tests', () => {
        let root = 'test/samples/';
        let list = [
            'minimal',
            'blank_line_end',
            'forced_types',
            'parserv2',
            'utc_negative_zero'
        ];

        list.forEach((path) => {
            describe(path.replace('_', ' '), () => {
                let input: string;

                // fetch ical
                beforeEach(async () => {
                    input = await testSupport.load(root + path + '.ics');
                });

                function jsonEqual(actual: any, expected: any) {
                    expect(actual).toEqual(expected);
                }

                it('round-trip', () => {
                    let parsed = ICAL.parse(input);
                    let ical = ICAL.stringify(parsed);

                    // NOTE: this is not an absolute test that serialization
                    //       works as our parser should be error tolerant and
                    //       it is remotely possible that we consistently produce
                    //       ICAL that only we can parse.
                    jsonEqual(
                        ICAL.parse(ical),
                        parsed
                    );
                });

            });
        });
    });

    describe('stringify property', () => {
        it('no explicit default set', () => {
            let subject = new ICAL.Property('tz', new ICAL.Component('vcard'));
            subject.setValue(ICAL.UtcOffset.fromString('+0500'));

            let ical = ICAL.stringify.property(subject.toJSON());
            expect(ical).toEqual('TZ;VALUE=UTC-OFFSET:+0500');
        });
        it('custom property with no default type', () => {
            (ICAL.design.defaultSet.property as any).custom = {};
            let subject = new ICAL.Property('custom');
            subject.setValue('unescaped, right?');
            expect(subject.toICALString()).toEqual('CUSTOM:unescaped, right?');

            subject.resetType('integer');
            subject.setValue(123);
            expect(subject.toICALString()).toEqual('CUSTOM;VALUE=INTEGER:123');

            delete (ICAL.design.defaultSet.property as any).custom;
        });

        it('custom property not using default type', () => {
            (ICAL.design.defaultSet.property as any).custom = { defaultType: 'text' };
            let subject = new ICAL.Property('custom');
            subject.resetType('integer');
            subject.setValue(123);
            expect(subject.toICALString()).toEqual('CUSTOM;VALUE=INTEGER:123');
            delete (ICAL.design.defaultSet.property as any).custom;
        });

        it('property with multiple parameter values', () => {
            (ICAL.design.defaultSet.property as any).custom = { defaultType: 'text' };
            (ICAL.design.defaultSet.param as any).type = { multiValue: ',' };
            let subject = new ICAL.Property('custom');
            subject.setParameter('type', ['ABC', 'XYZ']);
            subject.setValue('some value');
            expect(subject.toICALString()).toEqual('CUSTOM;TYPE=ABC,XYZ:some value');
            delete (ICAL.design.defaultSet.property as any).custom;
            delete (ICAL.design.defaultSet.param as any).type;
        });

        it('property with multiple parameter values which must be escaped', () => {
            (ICAL.design.defaultSet.property as any).custom = { defaultType: 'text' };
            (ICAL.design.defaultSet.param as any).type = { multiValue: ',' };
            let subject = new ICAL.Property('custom');
            subject.setParameter('type', ['ABC', '--"XYZ"--']);
            subject.setValue('some value');
            expect(subject.toICALString()).toEqual("CUSTOM;TYPE=ABC,--^'XYZ^'--:some value");
            delete (ICAL.design.defaultSet.property as any).custom;
            delete (ICAL.design.defaultSet.param as any).type;
        });

        it('property with multiple parameter values with enabled quoting', () => {
            (ICAL.design.defaultSet.property as any).custom = { defaultType: 'text' };
            (ICAL.design.defaultSet.param as any).type = { multiValue: ',', multiValueSeparateDQuote: true };
            let subject = new ICAL.Property('custom');
            subject.setParameter('type', ['ABC', 'XYZ']);
            subject.setValue('some value');
            expect(subject.toICALString()).toEqual('CUSTOM;TYPE="ABC","XYZ":some value');
            delete (ICAL.design.defaultSet.property as any).custom;
            delete (ICAL.design.defaultSet.param as any).type;
        });

        it('stringify property value containing "escaped" semicolons, commas, colons', () => {
            let subject = new ICAL.Property('attendee');
            subject.setParameter('cn', 'X\\:');
            subject.setValue('mailto:id');
            expect(subject.toICALString()).toEqual('ATTENDEE;CN="X\\:":mailto:id');
        });

        it('rfc6868 roundtrip', () => {
            let subject = new ICAL.Property('attendee');
            let input = "caret ^ dquote \" newline \n end";
            let expected = "ATTENDEE;CN=caret ^^ dquote ^' newline ^n end:mailto:id";
            subject.setParameter('cn', input);
            subject.setValue('mailto:id');
            expect(subject.toICALString()).toEqual(expected);
            expect(ICAL.parse.property(expected)[1].cn).toEqual(input);
        });

        it('roundtrip for property with multiple parameters', () => {
            (ICAL.design.defaultSet.property as any).custom = { defaultType: 'text' };
            (ICAL.design.defaultSet.param as any).type = { multiValue: ',', multiValueSeparateDQuote: true };
            let subject = new ICAL.Property('custom');
            subject.setParameter('type', ['ABC', '--"123"--']);
            subject.setValue('some value');
            expect(ICAL.parse.property(subject.toICALString())[1].type.length).toBe(2);
            expect(ICAL.parse.property(subject.toICALString())[1].type).toContain('ABC');
            expect(ICAL.parse.property(subject.toICALString())[1].type).toContain('--"123"--');
            delete (ICAL.design.defaultSet.property as any).custom;
            delete (ICAL.design.defaultSet.param as any).type;
        });

        it('folding', () => {
            let oldLength = ICAL.foldLength;
            let subject = new ICAL.Property("description");
            let N = ICAL.newLineChar + " ";
            subject.setValue('foobar');

            ICAL.foldLength = 19;
            expect(subject.toICALString()).toEqual("DESCRIPTION:foobar");
            expect(ICAL.stringify.property(subject.toJSON(), ICAL.design.icalendar, false)).toEqual("DESCRIPTION:foobar");
            expect(ICAL.stringify.property(subject.toJSON(), ICAL.design.icalendar, true)).toEqual("DESCRIPTION:foobar");

            ICAL.foldLength = 15;
            expect(subject.toICALString()).toEqual("DESCRIPTION:foobar");
            expect(ICAL.stringify.property(subject.toJSON(), ICAL.design.icalendar, false)).toEqual("DESCRIPTION:foo" + N + "bar");
            expect(ICAL.stringify.property(subject.toJSON(), ICAL.design.icalendar, true)).toEqual("DESCRIPTION:foobar");

            let utf16_muscle = '\uD83D\uDCAA'; //in UTF-8 this is F0 DF 92 AA.  If space/new line is inserted between the surrogates, then the JS Engine substitutes each stand-alone surrogate with REPLACEMENT CHARACTER 0xEF 0xBF 0xBD
            subject.setValue(utf16_muscle);
            expect(ICAL.stringify.property(subject.toJSON(), ICAL.design.icalendar, false)).toEqual("DESCRIPTION:" + N + utf16_muscle);//verify new line is after ':', as otherwise the whole line is longer than ICAL.foldLength
            subject.setValue('aa' + utf16_muscle + utf16_muscle + 'a' + utf16_muscle + utf16_muscle);
            expect(ICAL.stringify.property(subject.toJSON(), ICAL.design.icalendar, false)).toEqual("DESCRIPTION:aa" + N + utf16_muscle + utf16_muscle + 'a' + utf16_muscle + N + utf16_muscle);//verify that the utf16_muscle is moved as whole to a new line as it is 4 UTF-8 bytes

            ICAL.foldLength = oldLength;
        });

        it('property groups', () => {
            // Make sure the GROUP param is stripped
            let subject: any = ["fn", { "group": "bff" }, "text", "coffee"];
            expect(ICAL.stringify.property(subject, ICAL.design.vcard, false)).toEqual("BFF.FN:coffee");
        });
    });

    describe('stringify component', () => {
        it('minimal jcal', () => {
            let subject: any = ["vcalendar", [["version", {}, "text", "2.0"]], [["vevent", [], []]]];
            let expected = "BEGIN:VCALENDAR\r\nVERSION:2.0\r\nBEGIN:VEVENT\r\nEND:VEVENT\r\nEND:VCALENDAR";

            expect(ICAL.stringify.component(subject)).toEqual(expected);
        });

        it('minimal jcard', () => {
            // related to issue #266
            let subject: any = ["vcard", [["version", {}, "text", "4.0"]]];
            let expected = "BEGIN:VCARD\r\nVERSION:4.0\r\nEND:VCARD";

            expect(ICAL.stringify.component(subject)).toEqual(expected);
        });

        it('minimal jcard with empty subcomponent', () => {
            let subject: any = ["vcard", [["version", {}, "text", "4.0"]], []];
            let expected = "BEGIN:VCARD\r\nVERSION:4.0\r\nEND:VCARD";

            expect(ICAL.stringify.component(subject)).toEqual(expected);
        });

        it('structured values', () => {
            let subject: any = [
                "vcard",
                [
                    [
                        "adr",
                        {},
                        "text",
                        [
                            "one",
                            "two",
                            "three\n\n",
                            "four\nfour\n",
                            [
                                "five",
                                "five\n\n",
                                "five\nfive\n"
                            ],
                            "six",
                            "seven"
                        ]
                    ]
                ]
            ];
            let expected = "BEGIN:VCARD\r\nADR:one;two;three\\n\\n;four\\nfour\\n;five,five\\n\\n,five\\nfive\\n;six;seven\r\nEND:VCARD";

            expect(ICAL.stringify.component(subject)).toEqual(expected);
        });
    });
});
