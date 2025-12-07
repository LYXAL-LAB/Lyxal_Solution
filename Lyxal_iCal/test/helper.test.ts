import { describe, it, expect, beforeAll, afterAll } from "bun:test";
import ICAL, { Component } from "../src/index";
import { testSupport } from "./support/helper";

describe('ICAL.helpers', () => {

    describe('#clone', () => {
        const subject = ICAL.helpers.clone;

        it('some primatives', () => {
            expect(subject(null, false)).toEqual(null);
            expect(subject(123, false)).toEqual(123);
            expect(subject(null, true)).toEqual(null);
            expect(subject(123, true)).toEqual(123);
        });

        it('a date', () => {
            let date = new Date(2015, 1, 1);
            let time = date.getTime();
            let copy = subject(date, false) as Date;

            copy.setFullYear(2016);
            expect(time).not.toEqual(copy.getTime());
        });

        it('clonable', () => {
            let obj = { clone: function () { return "test"; } };
            expect(subject(obj, false) as unknown).toEqual("test");
        });

        it('shallow array', () => {
            let obj = { v: 2 };
            let arr = [obj, 2, 3];

            let result = subject(arr, false) as any[];
            expect(result).toEqual([{ v: 2 }, 2, 3]);
            obj.v = 3;
            expect(result).toEqual([{ v: 3 }, 2, 3]);
        });

        it('deep array', () => {
            let obj = { v: 2 };
            let arr = [obj, 2, 3];

            let result = subject(arr, true) as any[];
            expect(result).toEqual([{ v: 2 }, 2, 3]);
            obj.v = 3;
            expect(result).toEqual([{ v: 2 }, 2, 3]);
        });

        it('shallow object', () => {
            let deepobj = { v: 2 };
            let obj = { a: deepobj, b: 2 };

            let result = subject(obj, false) as any;
            expect(result).toEqual({ a: { v: 2 }, b: 2 });
            deepobj.v = 3;
            expect(result).toEqual({ a: { v: 3 }, b: 2 });
        });

        it('deep object', () => {
            let deepobj = { v: 2 };
            let obj = { a: deepobj, b: 2 };

            let result = subject(obj, true) as any;
            expect(result).toEqual({ a: { v: 2 }, b: 2 });
            deepobj.v = 3;
            expect(result).toEqual({ a: { v: 2 }, b: 2 });
        });
    });

    describe('#pad2', () => {
        const subject = ICAL.helpers.pad2;

        it('with string', () => {
            expect(subject("")).toEqual("00");
            expect(subject("1")).toEqual("01");
            expect(subject("12")).toEqual("12");
            expect(subject("123")).toEqual("123");
        });

        it('with number', () => {
            expect(subject(0)).toEqual("00");
            expect(subject(1)).toEqual("01");
            expect(subject(12)).toEqual("12");
            expect(subject(123)).toEqual("123");
        });

        it('with boolean', () => {
            expect(subject(true as any)).toEqual("true");
        });
    });

    describe('#foldline', () => {
        const subject = ICAL.helpers.foldline;

        it('empty values', () => {
            expect(subject(null as any)).toEqual("");
            expect(subject("")).toEqual("");
        });

        // Most other cases are covered by other tests
    });

    describe('#updateTimezones', () => {
        const subject = ICAL.helpers.updateTimezones;
        let cal: Component;

        beforeAll(async () => {
            let data = await testSupport.loadSample('minimal.ics');
            cal = new ICAL.Component(ICAL.parse(data));

            data = await testSupport.loadSample('timezones/America/Atikokan.ics');
            ICAL.TimezoneService.register(
                (new ICAL.Component(ICAL.parse(data))).getFirstSubcomponent("vtimezone")!
            );
        });

        afterAll(() => {
            ICAL.TimezoneService.reset();
        });

        it('timezones already correct', () => {
            let vtimezones: Component[];
            vtimezones = cal.getAllSubcomponents("vtimezone");
            expect(vtimezones.length).toBe(1);
            expect(
                vtimezones[0].getFirstProperty("tzid")!.getFirstValue()
            ).toEqual("America/Los_Angeles");
        });

        it('remove extra timezones', () => {
            let vtimezones: Component[];
            cal.addSubcomponent(
                ICAL.TimezoneService.get("America/Atikokan")!.component!
            );
            vtimezones = cal.getAllSubcomponents("vtimezone");
            expect(vtimezones.length).toBe(2);

            vtimezones = subject(cal).getAllSubcomponents("vtimezone");
            expect(vtimezones.length).toBe(1);
            expect(
                vtimezones[0].getFirstProperty("tzid")!.getFirstValue()
            ).toEqual("America/Los_Angeles");
        });

        it('add missing timezones', () => {
            let vtimezones: Component[];
            cal.getFirstSubcomponent("vevent")!
                .getFirstProperty("dtend")!.setParameter("tzid", "America/Atikokan");
            vtimezones = cal.getAllSubcomponents("vtimezone");
            expect(vtimezones.length).toBe(1);

            vtimezones = subject(cal).getAllSubcomponents("vtimezone");
            expect(vtimezones.length).toBe(2);
        });

        it('return non-vcalendar components unchanged', () => {
            let vevent = cal.getFirstSubcomponent("vevent")!;
            expect(subject(vevent)).toEqual(vevent);
        });
    });
});
