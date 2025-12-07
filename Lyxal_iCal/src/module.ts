import { Binary } from "./binary";
import { Component } from "./component";
import { Duration } from "./duration";
import { Period } from "./period";
import { Property } from "./property";
import { UtcOffset } from "./utc_offset";
import * as helpers from "./helpers";
import ComponentParser from "./component_parser";
import design from "./design";
import Event from "./event";
import parse from "./parse";
import Recur from "./recur";
import RecurExpansion from "./recur_expansion";
import RecurIterator from "./recur_iterator";
import stringify from "./stringify";
import Time from "./time";
import Timezone from "./timezone";
import TimezoneService from "./timezone_service";
import VCardTime from "./vcard_time";

/**
 * The main ICAL module. Provides access to everything else.
 */
const ICAL = {
    /**
     * The number of characters before iCalendar line folding should occur
     */
    foldLength: 75,

    debug: false,

    /**
     * The character(s) to be used for a newline.
     */
    newLineChar: '\r\n',

    // Core classes
    Binary,
    Component,
    Duration,
    Period,
    Property,
    UtcOffset,

    // Lazy loaded classes (getters)
    get ComponentParser() {
        return ComponentParser;
    },

    get Event() {
        return Event;
    },

    get Recur() {
        return Recur;
    },

    get RecurExpansion() {
        return RecurExpansion;
    },

    get RecurIterator() {
        return RecurIterator;
    },

    get Time() {
        return Time;
    },

    get Timezone() {
        return Timezone;
    },

    get TimezoneService() {
        return TimezoneService;
    },

    get VCardTime() {
        return VCardTime;
    },

    // Parse and stringify
    get parse() {
        return parse;
    },

    get stringify() {
        return stringify;
    },

    // Design
    get design() {
        return design;
    },

    // Helpers
    helpers
};

export default ICAL;
export { Binary, Component, Duration, Period, Property, UtcOffset, helpers };
