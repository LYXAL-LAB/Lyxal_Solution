import { describe, it, beforeAll } from "bun:test";
import ICAL from "../../src/index";
import { testSupport } from "../support/helper";

describe('ics - blank description', () => {
    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('blank_description.ics');
    });

    it('parses blank lines', () => {
        // just verify it can parse blank lines
        ICAL.parse(icsData);
    });
});
