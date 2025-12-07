import { describe, it } from "bun:test";
import ICAL from "../../src/index";

describe('performance: ICAL.Time', () => {

    it('subtract date', () => {
        let time = new ICAL.Time({
            year: 2012,
            month: 1,
            day: 1,
            hour: 10,
            minute: 3
        });

        let time2 = new ICAL.Time({
            year: 2012,
            month: 10,
            day: 1,
            hour: 1,
            minute: 55
        });

        time.subtractDate(time2);
    });

    let dur = new ICAL.Duration({
        days: 3,
        hours: 3,
        minutes: 3
    });

    it('add duration', () => {
        let time = new ICAL.Time({
            year: 2012,
            month: 1,
            day: 32,
            second: 1
        });

        time.addDuration(dur);

        // to trigger normalization
        time.year;
    });

    it('create and clone time', () => {
        let time = new ICAL.Time({
            year: 2012,
            month: 1,
            day: 32,
            second: 1
        });

        if (time.day !== 1) {
            throw new Error('test sanity fails for .day');
        }

        if (time.month !== 2) {
            throw new Error('test sanity fails for .month');
        }

        time.clone();
    });

    let _time = new ICAL.Time({
        year: 2012,
        month: 1,
        day: 32,
        second: 1
    });

    it('toUnixTime', () => {
        _time.toUnixTime();
    });

    it('fromUnixTime', () => {
        _time.fromUnixTime(1234567890);
    });

    it('dayOfWeek', () => {
        _time.dayOfWeek();
    });

    it('weekNumber', () => {
        _time.weekNumber();
    });
});
