import { describe, it, beforeAll } from "bun:test";
import ICAL from "../../src/index";
import { testSupport } from "../support/helper";

describe('performance: ICAL parse/stringify', () => {

    let icsData: string;
    let parsed: any;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('parserv2.ics');
        parsed = ICAL.parse(icsData);
    });

    it('#parse', () => {
        ICAL.parse(icsData);
    });

    it('#stringify', () => {
        ICAL.stringify(parsed);
    });
});
