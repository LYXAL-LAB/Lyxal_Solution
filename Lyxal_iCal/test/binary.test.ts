import { describe, it, expect, beforeEach } from "bun:test";
import ICAL, { Binary } from "../src/index";

describe('ICAL.Binary', () => {
    let subject: Binary;

    beforeEach(() => {
        subject = new ICAL.Binary('');
    });

    it('setEncodedValue', () => {
        subject.setEncodedValue('bananas');
        expect(subject.decodeValue()).toEqual('bananas');
        expect(subject.value).toEqual('YmFuYW5hcw==');

        subject.setEncodedValue('apples');
        expect(subject.decodeValue()).toEqual('apples');
        expect(subject.value).toEqual('YXBwbGVz');
    });

    it('null values', () => {
        subject.setEncodedValue(null);
        expect(subject.decodeValue()).toEqual(null);
        expect(subject.value).toEqual(null);
    });
});
