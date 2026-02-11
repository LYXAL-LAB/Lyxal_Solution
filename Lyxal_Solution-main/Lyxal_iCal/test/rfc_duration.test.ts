import { describe, it, expect } from "bun:test";
import ICAL from "../src/index";

describe("ical/duration - fromSeconds → toString", () => {
    it("pure weeks → P2W", () => {
        let Duration = new ICAL.Duration();
        let d = Duration.fromSeconds(2 * 7 * 86400);
        expect(d.toString()).toEqual("P2W");
    });

    it("pure days → P3D", () => {
        let Duration = new ICAL.Duration();
        let d = Duration.fromSeconds(3 * 86400);
        expect(d.toString()).toEqual("P3D");
    });

    it("pure time → PT5H30M5S", () => {
        let Duration = new ICAL.Duration();
        let d = Duration.fromSeconds(5 * 3600 + 30 * 60 + 5);
        expect(d.toString()).toEqual("PT5H30M5S");
    });

    it("1 day + 2 hours → P1DT2H", () => {
        let Duration = new ICAL.Duration();
        let d = Duration.fromSeconds(86400 + 2 * 3600);
        expect(d.toString()).toEqual("P1DT2H");
    });

    it("9 days → P9D", () => {
        let Duration = new ICAL.Duration();
        let d = Duration.fromSeconds(9 * 86400);
        expect(d.toString()).toEqual("P9D");
    });

    it("10 days + 2 hours → P10DT2H", () => {
        let Duration = new ICAL.Duration();
        let d = Duration.fromSeconds(10 * 86400 + 2 * 3600);
        expect(d.toString()).toEqual("P10DT2H");
    });
});
