import { describe, it, expect, beforeAll } from "bun:test";
import ICAL from "../../src/index";
import { Time } from "../../src/time";
import { testSupport } from "../support/helper";

describe('ics - forced types', () => {
    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('forced_types.ics');
    });

    it('parses forced types correctly', () => {
        let result = ICAL.parse(icsData);
        let component = new ICAL.Component(result);
        let vevent = component.getFirstSubcomponent('vevent')!;

        let start = vevent.getFirstPropertyValue('dtstart') as Time;

        expect(start.isDate).toBeTrue();
    });
});
