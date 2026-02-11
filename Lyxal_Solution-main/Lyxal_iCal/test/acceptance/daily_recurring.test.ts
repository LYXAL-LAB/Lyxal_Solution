import { describe, it, beforeAll } from "bun:test";
import ICAL from "../../src/index";
import { Recur } from "../../src/recur";
import { Time } from "../../src/time";
import { testSupport } from "../support/helper";

describe('ics - daily recurring', () => {
    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('daily_recur.ics');
    });

    it('parses and iterates daily recurring events', () => {
        let result = ICAL.parse(icsData);
        let component = new ICAL.Component(result);
        let vevent = component.getFirstSubcomponent('vevent')!;

        let recur = vevent.getFirstPropertyValue('rrule') as Recur;
        let start = vevent.getFirstPropertyValue('dtstart') as Time;

        let iter = recur.iterator(start);
        let limit = 10;
        while (limit) {
            iter.next();
            limit--;
        }
    });
});
