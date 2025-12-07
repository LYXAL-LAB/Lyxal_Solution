import ICALParse from "./parse";
import Component from "./component";
import Event from "./event";
import Timezone from "./timezone";

export interface ComponentParserOptions {
    parseEvent?: boolean;
    parseTimezone?: boolean;
    [key: string]: any;
}

/**
 * The ComponentParser is used to process a String or jCal Object,
 * firing callbacks for various found components, as well as completion.
 */
export class ComponentParser {
    /**
     * When true, parse events
     */
    parseEvent: boolean = true;

    /**
     * When true, parse timezones
     */
    parseTimezone: boolean = true;

    /**
     * Creates a new ICAL.ComponentParser instance.
     *
     * @param options                   Component parser options
     */
    constructor(options?: ComponentParserOptions) {
        if (typeof (options) === 'undefined') {
            options = {};
        }

        for (let [key, value] of Object.entries(options)) {
            (this as any)[key] = value;
        }
    }

    /* SAX like events here for reference */

    /**
     * Fired when parsing is complete
     */
    oncomplete: () => void = /* c8 ignore next */ function () { };

    /**
     * Fired if an error occurs during parsing.
     *
     * @param err details of error
     */
    onerror: (err: Error) => void = /* c8 ignore next */ function (err) { };

    /**
     * Fired when a top level component (VTIMEZONE) is found
     *
     * @param component     Timezone object
     */
    ontimezone: (component: Timezone) => void = /* c8 ignore next */ function (component) { };

    /**
     * Fired when a top level component (VEVENT) is found.
     *
     * @param component    Top level component
     */
    onevent: (component: Event) => void = /* c8 ignore next */ function (component) { };

    /**
     * Fired when a recurrence exception is found.
     *
     * @param component    The exception event
     */
    onrecurrenceexception: (component: Event) => void = /* c8 ignore next */ function (component) { };

    /**
     * Process a string or parse ical object.  This function itself will return
     * nothing but will start the parsing process.
     *
     * Events must be registered prior to calling this method.
     *
     * @param ical      The component to process,
     *        either in its final form, as a jCal Object, or string representation
     */
    process(ical: Component | string | any): void {
        //TODO: this is sync now in the future we will have a incremental parser.
        if (typeof (ical) === 'string') {
            ical = ICALParse(ical);
        }

        if (!(ical instanceof Component)) {
            ical = new Component(ical);
        }

        let components = ical.getAllSubcomponents();
        let i = 0;
        let len = components.length;
        let component;

        for (; i < len; i++) {
            component = components[i];

            switch (component.name) {
                case 'vtimezone':
                    if (this.parseTimezone) {
                        let tzid = component.getFirstPropertyValue('tzid');
                        if (tzid) {
                            this.ontimezone(new Timezone({
                                tzid: tzid,
                                component: component
                            }));
                        }
                    }
                    break;
                case 'vevent':
                    if (this.parseEvent) {
                        this.onevent(new Event(component));
                    }
                    break;
                default:
                    continue;
            }
        }

        //XXX: ideally we should do a "nextTick" here
        //     so in all cases this is actually async.
        this.oncomplete();
    }
}

export default ComponentParser;
