import { describe, it, beforeAll } from "bun:test";
import ICAL, { Component, Recur, Time } from "../../src/index";
import { testSupport } from "../support/helper";

describe('performance: iterator', () => {

    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('parserv2.ics');
    });

    let parsed: any;
    let comp: Component;
    let tz: Component;
    let std: Component;
    let rrule: Recur;

    beforeAll(() => {
        parsed = ICAL.parse(icsData);
        comp = new ICAL.Component(parsed);
        tz = comp.getFirstSubcomponent('vtimezone')!;
        std = tz.getFirstSubcomponent('standard')!;
        rrule = std.getFirstPropertyValue('rrule') as Recur;
    });

    it('timezone iterator & first iteration', () => {
        let iterator = rrule.iterator(std.getFirstPropertyValue('dtstart') as Time);
        iterator.next();
    });

});
