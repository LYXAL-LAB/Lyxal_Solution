import { describe, it, expect, beforeAll } from "bun:test";
import ICAL, { Event } from "../../src/index";
import { testSupport } from "../support/helper";

describe('google birthday events', () => {
    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('google_birthday.ics');
    });

    it('expanding malformatted recurring event', async () => {
        return new Promise<void>((resolve) => {
            let parser = new ICAL.ComponentParser();
            let primary: Event | undefined;
            let exceptions: Event[] = [];

            let expectedDates = [
                new Date(2012, 11, 10),
                new Date(2013, 11, 10),
                new Date(2014, 11, 10)
            ];

            parser.onevent = function (event: Event) {
                if (event.isRecurrenceException()) {
                    exceptions.push(event);
                } else {
                    primary = event;
                }
            };

            parser.oncomplete = function () {
                exceptions.forEach(function (item) {
                    primary!.relateException(item);
                });

                let iter = primary!.iterator();
                let next;
                let dates: Date[] = [];
                while ((next = iter.next())) {
                    dates.push(next.toJSDate());
                }

                expect(dates).toEqual(expectedDates);

                resolve();
            };

            parser.process(icsData);
        });
    });
});
