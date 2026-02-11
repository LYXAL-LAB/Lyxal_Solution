import { describe, it, expect, beforeAll } from "bun:test";
import ICAL, { UtcOffset } from "../../src/index";
import { testSupport } from "../support/helper";

describe('ics - negative zero', () => {
    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('utc_negative_zero.ics');
    });

    it('handles negative zero UTC offset', () => {
        let result = ICAL.parse(icsData);
        let component = new ICAL.Component(result);
        let vtimezone = component.getFirstSubcomponent('vtimezone')!;

        let standard = vtimezone.getFirstSubcomponent('standard')!;

        let props = standard.getAllProperties();
        let offset = props[1].getFirstValue() as UtcOffset;

        expect(offset.factor).toBe(-1);
    });
});
