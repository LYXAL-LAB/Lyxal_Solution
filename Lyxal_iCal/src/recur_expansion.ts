import Time from "./time";
import RecurIterator from "./recur_iterator";
import Recur from "./recur";
import Component from "./component";
import { formatClassType, binsearchInsert } from "./helpers";
import type { RecurIteratorOptions } from "./recur_iterator";

export interface RecurExpansionOptions {
    dtstart: Time | any;
    component?: Component;
    last?: Time | any;
    ruleIterators?: (RecurIterator | RecurIteratorOptions)[];
    ruleDateInc?: number;
    exDateInc?: number;
    ruleDates?: (Time | any)[];
    exDates?: (Time | any)[];
    complete?: boolean;
}

/**
 * Primary class for expanding recurring rules.  Can take multiple rrules, rdates, exdate(s) and
 * iterate (in order) over each next occurrence.
 *
 * Once initialized this class can also be serialized saved and continue iteration from the last
 * point.
 *
 * NOTE: it is intended that this class is to be used with {@link ICAL.Event} which handles recurrence
 * exceptions.
 */
export class RecurExpansion {
    /**
     * True when iteration is fully completed.
     */
    complete: boolean = false;

    /**
     * Array of rrule iterators.
     */
    ruleIterators: RecurIterator[] = [];

    /**
     * Array of rdate instances.
     */
    ruleDates: Time[] = [];

    /**
     * Array of exdate instances.
     */
    exDates: Time[] = [];

    /**
     * Current position in ruleDates array.
     */
    ruleDateInc: number = 0;

    /**
     * Current position in exDates array
     */
    exDateInc: number = 0;

    /**
     * Current negative date.
     */
    exDate: Time | null = null;

    /**
     * Current additional date.
     */
    ruleDate: Time | null = null;

    /**
     * Start date of recurring rules.
     */
    dtstart: Time;

    /**
     * Last expanded time
     */
    last: Time;

    /**
     * Creates a new ICAL.RecurExpansion instance.
     *
     * The options object can be filled with the specified initial values. It can also contain
     * additional members, as a result of serializing a previous expansion state, as shown in the
     * example.
     *
     * @param options        Recurrence expansion options
     */
    constructor(options: RecurExpansionOptions) {
        // Initialize to satisfy TS, will be overwritten by fromData
        this.dtstart = options.dtstart as Time;
        this.last = options.dtstart as Time;

        this.fromData(options);
    }

    /**
     * Initialize the recurrence expansion from the data object. The options
     * object may also contain additional members, see the
     * {@link ICAL.RecurExpansion constructor} for more details.
     *
     * @param options        Recurrence expansion options
     */
    fromData(options: RecurExpansionOptions): void {
        let start = formatClassType(options.dtstart, Time);

        if (!start) {
            throw new Error('.dtstart (ICAL.Time) must be given');
        } else {
            this.dtstart = start;
        }

        if (options.component) {
            this._init(options.component);
        } else {
            this.last = formatClassType(options.last, Time) || start.clone();

            if (!options.ruleIterators) {
                throw new Error('.ruleIterators or .component must be given');
            }

            this.ruleIterators = options.ruleIterators!.map(function (item) {
                return formatClassType(item as any, RecurIterator)!;
            });

            this.ruleDateInc = options.ruleDateInc || 0;
            this.exDateInc = options.exDateInc || 0;

            if (options.ruleDates) {
                this.ruleDates = options.ruleDates.map(item => formatClassType(item, Time)!);
                this.ruleDate = this.ruleDates[this.ruleDateInc];
            }

            if (options.exDates) {
                this.exDates = options.exDates.map(item => formatClassType(item, Time)!);
                this.exDate = this.exDates[this.exDateInc];
            }

            if (typeof (options.complete) !== 'undefined') {
                this.complete = options.complete;
            }
        }
    }

    /**
     * Compare two ICAL.Time objects.  When the second parameter is a DATE and the first parameter is
     * DATE-TIME, strip the time and compare only the days.
     *
     * @private
     * @param a   The one object to compare
     * @param b   The other object to compare
     */
    _compare_special(a: Time, b: Time): number {
        if (!a.isDate && b.isDate)
            return new Time({ year: a.year, month: a.month, day: a.day }).compare(b);
        return a.compare(b);
    }

    /**
     * Retrieve the next occurrence in the series.
     * @return {Time}
     */
    next(): Time | null {
        let iter: RecurIterator | null;
        let next: Time | null;
        let compare: number;

        let maxTries = 500;
        let currentTry = 0;

        while (true) {
            if (currentTry++ > maxTries) {
                throw new Error(
                    'max tries have occurred, rule may be impossible to fulfill.'
                );
            }

            next = this.ruleDate;
            iter = this._nextRecurrenceIter();

            // no more matches
            // because we increment the rule day or rule
            // _after_ we choose a value this should be
            // the only spot where we need to worry about the
            // end of events.
            if (!next && !iter) {
                // there are no more iterators or rdates
                this.complete = true;
                break;
            }

            // no next rule day or recurrence rule is first.
            if (!next || (iter && next.compare(iter.last) > 0)) {
                // must be cloned, recur will reuse the time element.
                next = iter!.last.clone();
                // move to next so we can continue
                iter!.next();
            }

            // if the ruleDate is still next increment it.
            if (this.ruleDate === next) {
                this._nextRuleDay();
            }

            this.last = next!;

            // check the negative rules
            if (this.exDate) {
                // EXDATE can be in DATE format, but DTSTART is in DATE-TIME format
                compare = this._compare_special(this.last, this.exDate);

                if (compare > 0) {
                    this._nextExDay();
                }

                // if the current rule is excluded skip it.
                if (compare === 0) {
                    this._nextExDay();
                    continue;
                }
            }

            //XXX: The spec states that after we resolve the final
            //     list of dates we execute exdate this seems somewhat counter
            //     intuitive to what I have seen most servers do so for now
            //     I exclude based on the original date not the one that may
            //     have been modified by the exception.
            return this.last;
        }
        return null;
    }

    /**
     * Converts object into a serialize-able format. This format can be passed
     * back into the expansion to resume iteration.
     * @return {Object}
     */
    toJSON(): RecurExpansionOptions {
        function toJSON(item: any) {
            return item.toJSON();
        }

        let result: RecurExpansionOptions = Object.create(null);
        result.ruleIterators = this.ruleIterators.map(toJSON);

        if (this.ruleDates) {
            result.ruleDates = this.ruleDates.map(toJSON);
        }

        if (this.exDates) {
            result.exDates = this.exDates.map(toJSON);
        }

        result.ruleDateInc = this.ruleDateInc;
        result.exDateInc = this.exDateInc;
        result.last = this.last.toJSON();
        result.dtstart = this.dtstart.toJSON();
        result.complete = this.complete;

        return result;
    }

    /**
     * Extract all dates from the properties in the given component. The
     * properties will be filtered by the property name.
     *
     * @private
     * @param component             The component to search in
     * @param propertyName             The property name to search for
     * @return                         The extracted dates.
     */
    _extractDates(component: Component, propertyName: string): Time[] {
        let result: Time[] = [];
        let props = component.getAllProperties(propertyName);

        for (let i = 0, len = props.length; i < len; i++) {
            for (let prop of props[i].getValues()) {
                let timeProp = prop as Time;
                let idx = binsearchInsert(
                    result,
                    timeProp,
                    (a, b) => a.compare(b)
                );

                // ordered insert
                result.splice(idx, 0, timeProp);
            }
        }

        return result;
    }

    /**
     * Initialize the recurrence expansion.
     *
     * @private
     * @param component    The component to initialize from.
     */
    _init(component: Component): void {
        this.ruleIterators = [];

        this.last = this.dtstart.clone();

        // to provide api consistency non-recurring
        // events can also use the iterator though it will
        // only return a single time.
        if (!component.hasProperty('rdate') &&
            !component.hasProperty('rrule') &&
            !component.hasProperty('recurrence-id')) {
            this.ruleDate = this.last.clone();
            this.complete = true;
            return;
        }

        if (component.hasProperty('rdate')) {
            this.ruleDates = this._extractDates(component, 'rdate');

            // special hack for cases where first rdate is prior
            // to the start date. We only check for the first rdate.
            // This is mostly for google's crazy recurring date logic
            // (contacts birthdays).
            if ((this.ruleDates[0]) &&
                (this.ruleDates[0].compare(this.dtstart) < 0)) {

                this.ruleDateInc = 0;
                this.last = this.ruleDates[0].clone();
            } else {
                this.ruleDateInc = binsearchInsert(
                    this.ruleDates,
                    this.last,
                    (a, b) => a.compare(b)
                );
            }

            this.ruleDate = this.ruleDates[this.ruleDateInc];
        }

        if (component.hasProperty('rrule')) {
            let rules = component.getAllProperties('rrule');
            let i = 0;
            let len = rules.length;

            let rule;
            let iter;

            for (; i < len; i++) {
                rule = rules[i].getFirstValue() as Recur;
                iter = rule.iterator(this.dtstart);
                this.ruleIterators.push(iter);

                // increment to the next occurrence so future
                // calls to next return times beyond the initial iteration.

                iter.next();
            }
        }

        if (component.hasProperty('exdate')) {
            this.exDates = this._extractDates(component, 'exdate');
            // if we have a .last day we increment the index to beyond it.
            // When DTSTART is in DATE-TIME format, EXDATE is in DATE format and EXDATE is
            // the date of DTSTART, _compare_special finds this out and compareTime fails.
            this.exDateInc = binsearchInsert(
                this.exDates,
                this.last,
                this._compare_special
            );

            this.exDate = this.exDates[this.exDateInc];
        }
    }

    /**
     * Advance to the next exdate
     * @private
     */
    _nextExDay(): void {
        this.exDate = this.exDates[++this.exDateInc];
    }

    /**
     * Advance to the next rule date
     * @private
     */
    _nextRuleDay(): void {
        this.ruleDate = this.ruleDates[++this.ruleDateInc];
    }

    /**
     * Find and return the recurrence rule with the most recent event and
     * return it.
     *
     * @private
     * @return    Found iterator.
     */
    _nextRecurrenceIter(): RecurIterator | null {
        let iters = this.ruleIterators;

        if (iters.length === 0) {
            return null;
        }

        let len = iters.length;
        let iter: RecurIterator;
        let iterTime: Time;
        let iterIdx = 0;
        let chosenIter: RecurIterator | null = null;

        // loop through each iterator
        for (; iterIdx < len; iterIdx++) {
            iter = iters[iterIdx];
            iterTime = iter.last;

            // if iteration is complete
            // then we must exclude it from
            // the search and remove it.
            if (iter.completed) {
                len--;
                if (iterIdx !== 0) {
                    iterIdx--;
                }
                iters.splice(iterIdx, 1);
                continue;
            }

            // find the most recent possible choice
            if (!chosenIter || chosenIter.last.compare(iterTime) > 0) {
                // that iterator is saved
                chosenIter = iter;
            }
        }

        // the chosen iterator is returned but not mutated
        // this iterator contains the most recent event.
        return chosenIter;
    }
}

export default RecurExpansion;
