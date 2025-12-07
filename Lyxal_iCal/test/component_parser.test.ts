import { describe, it, expect, beforeEach, beforeAll } from "bun:test";
import ICAL, { ComponentParser, Event, Component, Timezone, ComponentParserOptions } from "../src/index";
import { testSupport, assertHasProperties } from "./support/helper";

describe('component_parser', () => {
    let subject: ComponentParser;
    let icsData: string;

    beforeAll(async () => {
        icsData = await testSupport.loadSample('recur_instances.ics');
    });

    describe('#process', () => {
        let events: Event[] = [];
        let exceptions: Event[] = [];
        let timezones: Timezone[] = [];

        function eventEquals(a: Event | Component | null, b: Event | Component | null, msg?: string) {
            if (!a)
                throw new Error('actual is falsy');

            if (!b)
                throw new Error('expected is falsy');

            let aComp: Component;
            let bComp: Component;

            if (a instanceof ICAL.Event) {
                aComp = a.component;
            } else {
                aComp = a;
            }

            if (b instanceof ICAL.Event) {
                bComp = b.component;
            } else {
                bComp = b;
            }

            expect(aComp.toJSON()).toEqual(bComp.toJSON());
        }

        function setupProcess(options?: ComponentParserOptions) {
            beforeEach(async () => {
                events.length = 0;
                exceptions.length = 0;
                timezones.length = 0;

                return new Promise<void>((resolve) => {
                    subject = new ComponentParser(options);

                    subject.onrecurrenceexception = function (item: Event) {
                        exceptions.push(item);
                    };

                    subject.onevent = function (event: Event) {
                        events.push(event);
                    };

                    subject.ontimezone = function (tz: Timezone) {
                        timezones.push(tz);
                    };

                    subject.oncomplete = function () {
                        resolve();
                    };

                    subject.process(ICAL.parse(icsData));
                });
            });
        }

        describe('without events', () => {
            setupProcess({ parseEvent: false });

            it('parse result', () => {
                expect(events.length).toBe(0);
                expect(timezones.length).toBe(1);

                let tz = timezones[0];
                expect(tz instanceof Timezone).toBeTrue();
                expect(tz.tzid).toEqual('America/Los_Angeles');
            });
        });

        describe('with events', () => {
            setupProcess();

            it('parse result', () => {
                let component = new Component(ICAL.parse(icsData));
                let list = component.getAllSubcomponents('vevent');

                let expectedEvents: Event[] = [];

                list.forEach(function (item: Component) {
                    expectedEvents.push(new Event(item));
                });

                expect(expectedEvents[0] instanceof Event).toBeTrue();

                eventEquals(events[0], expectedEvents[0]);
                eventEquals(events[1], expectedEvents[1]);
                eventEquals(events[2], expectedEvents[2]);
            });
        });

        describe('without parsing timezones', () => {
            setupProcess({ parseTimezone: false });

            it('parse result', () => {
                expect(timezones.length).toBe(0);
                expect(events.length).toBe(3);
            });
        });

        describe('alternate input', () => {
            it('parsing component from string', async () => {
                return new Promise<void>((resolve) => {
                    events.length = 0;
                    subject = new ComponentParser();
                    subject.onevent = (event: Event) => events.push(event);
                    subject.oncomplete = function () {
                        expect(events.length).toBe(3);
                        resolve();
                    };
                    subject.process(icsData);
                });
            });

            it('parsing component from component', async () => {
                return new Promise<void>((resolve) => {
                    events.length = 0;
                    subject = new ComponentParser();
                    subject.onevent = (event: Event) => events.push(event);
                    subject.oncomplete = function () {
                        expect(events.length).toBe(3);
                        resolve();
                    };
                    let comp = new Component(ICAL.parse(icsData));
                    subject.process(comp);
                });
            });
        });
    });
});
