import { assert } from 'chai';
import ICAL from "../src/index";
import type { JCalProperty } from "../src/types";
import { testSupport } from './support/helper';

describe('parserv2', function () {

  let subject: typeof ICAL.parse;
  beforeEach(function () {
    subject = ICAL.parse;
  });

  /**
   * Full parser tests fetch two resources
   * (one to parse, one is expected
   */
  describe('full parser tests', function () {
    let root = 'test/parser/';
    let list = [
      // icalendar tests
      'rfc.ics',
      'single_empty_vcalendar.ics',
      'property_params.ics',
      'newline_junk.ics',
      'unfold_properties.ics',
      'quoted_params.ics',
      'multivalue.ics',
      'values.ics',
      'recur.ics',
      'base64.ics',
      'dates.ics',
      'time.ics',
      'boolean.ics',
      'float.ics',
      'integer.ics',
      'period.ics',
      'utc_offset.ics',
      'component.ics',
      'tzid_with_gmt.ics',
      'multiple_root_components.ics',
      'grouped.ics',

      // vcard tests
      'vcard.vcf',
      'vcard_author.vcf',
      'vcard3.vcf',
      'vcard_grouped.vcf',
      'escape_semicolon.vcf'
    ];

    list.forEach(function (path) {
      describe(path.replace('_', ' '), function () {
        let input: string;
        let expected: any;

        // fetch ical
        beforeEach(async function () {
          input = await testSupport.load(root + path);
        });

        // fetch json
        beforeEach(async function () {
          let data = await testSupport.load(root + path.replace(/vcf|ics$/, 'json'));
          try {
            expected = JSON.parse(data.trim());
          } catch {
            throw new Error('expect json is invalid: \n\n' + data);
          }
        });

        function jsonEqual(jsonActual: any, jsonExpected: any) {
          assert.deepEqual(
            jsonActual,
            jsonExpected,
            'hint use: ' +
            'http://tlrobinson.net/projects/javascript-fun/jsondiff/\n\n' +
            '\nexpected:\n\n' +
            JSON.stringify(jsonActual, null, 2) +
            '\n\n to equal:\n\n ' +
            JSON.stringify(jsonExpected, null, 2) + '\n\n'
          );
        }

        it('round-trip', function () {
          let parsed = subject(input);
          let ical = ICAL.stringify(parsed);

          // NOTE: this is not an absolute test that serialization
          //       works as our parser should be error tolerant and
          //       it is remotely possible that we consistently produce
          //       ICAL that only we can parse.
          jsonEqual(
            subject(ical),
            expected
          );
        });

        it('compare', function () {
          let actual = subject(input);
          jsonEqual(actual, expected);
        });
      });
    });
  });

  describe('invalid ical', function () {

    it('invalid property', function () {
      let ical = 'BEGIN:VCALENDAR\n';
      // no param or value token
      ical += 'DTSTART\n';
      ical += 'DESCRIPTION:1\n';
      ical += 'END:VCALENDAR';

      assert.throws(function () {
        subject(ical);
      }, /invalid line/);
    });

    it('invalid quoted params', function () {
      let ical = 'BEGIN:VCALENDAR\n';
      ical += 'X-FOO;BAR="quoted\n';
      // an invalid newline inside quoted parameter
      ical += 'params";FOO=baz:realvalue\n';
      ical += 'END:VCALENDAR';

      assert.throws(function () {
        subject(ical);
      }, /invalid line/);
    });

    it('missing value with param delimiter', function () {
      let ical = 'BEGIN:VCALENDAR\n' +
        'X-FOO;\n';
      assert.throws(function () {
        subject(ical);
      }, "Invalid parameters in");
    });

    it('missing param name ', function () {
      let ical = 'BEGIN:VCALENDAR\n' +
        'X-FOO;=\n';
      assert.throws(function () {
        subject(ical);
      }, "Empty parameter name in");
    });

    it('missing param value', function () {
      let ical = 'BEGIN:VCALENDAR\n' +
        'X-FOO;BAR=\n';
      assert.throws(function () {
        subject(ical);
      }, "Missing parameter value in");
    });

    it('missing component end', function () {
      let ical = 'BEGIN:VCALENDAR\n';
      ical += 'BEGIN:VEVENT\n';
      ical += 'BEGIN:VALARM\n';
      ical += 'DESCRIPTION: foo\n';
      ical += 'END:VALARM';
      // ended calendar before event
      ical += 'END:VCALENDAR';

      assert.throws(function () {
        subject(ical);
      }, /invalid/);
    });

  });

  describe('#_parseParameters', function () {
    it('with processed text', function () {
      let input = ';FOO=x\\na';
      let expected = {
        'foo': 'x\na'
      };

      assert.deepEqual(
        subject._parseParameters(input, 0, ICAL.design.defaultSet)[0],
        expected
      );
    });

    it('with multiple vCard TYPE parameters', function () {
      let input = ';TYPE=work;TYPE=voice';
      let expected = {
        'type': ['work', 'voice']
      };

      assert.deepEqual(
        subject._parseParameters(input, 0, ICAL.design.components.vcard)[0],
        expected
      );
    });

    it('with multiple iCalendar MEMBER parameters', function () {
      let input = ';MEMBER="urn:one","urn:two";MEMBER="urn:three"';
      let expected = {
        'member': ['urn:one', 'urn:two', 'urn:three']
      };

      assert.deepEqual(
        subject._parseParameters(input, 0, ICAL.design.components.vevent)[0],
        expected
      );
    });

    it('with comma in singleValue parameter', function () {
      let input = ';LABEL="A, B"';
      let expected = {
        'label': 'A, B'
      };

      assert.deepEqual(
        subject._parseParameters(input, 0, ICAL.design.components.vcard)[0],
        expected
      );
    });

    it('with comma in singleValue parameter after multiValue parameter', function () {
      // TYPE allows multiple values, whereas LABEL doesn't.
      let input = ';TYPE=home;LABEL="A, B"';
      let expected = {
        'type': 'home',
        'label': 'A, B'
      };

      assert.deepEqual(
        subject._parseParameters(input, 0, ICAL.design.components.vcard)[0],
        expected
      );
    });

    it('with quoted multi-value parameter', function () {
      let attendee = ICAL.Property.fromString(
        'ATTENDEE;MEMBER=' +
        '"mailto:mygroup@localhost",' +
        '"mailto:mygroup2@localhost",' +
        '"mailto:mygroup3@localhost":' +
        'mailto:user2@localhost'
      );
      let expected: JCalProperty = [
        'attendee',
        {
          member: [
            'mailto:mygroup@localhost',
            'mailto:mygroup2@localhost',
            'mailto:mygroup3@localhost'
          ]
        },
        'cal-address',
        'mailto:user2@localhost'
      ];

      assert.deepEqual(attendee.toJSON(), expected);
    });

    it('with quoted value', function () {
      let input = ';FMTTYPE="text/html":Here is HTML with signs like =;';
      let expected = {
        'fmttype': 'text/html'
      };

      assert.deepEqual(
        subject._parseParameters(input, 0, ICAL.design.components.vevent)[0],
        expected
      );
    });
  });

  it('#_parseMultiValue', function () {
    let values = 'woot\\, category,foo,bar,baz';
    let result: string[] = [];
    assert.deepEqual(
      subject._parseMultiValue(values, ',', 'text', result, null, ICAL.design.defaultSet),
      ['woot, category', 'foo', 'bar', 'baz']
    );
  });

  describe('#_parseValue', function () {
    it('text', function () {
      let value = 'start \\n next';
      let expected = 'start \n next';

      assert.equal(
        subject._parseValue(value, 'text', ICAL.design.defaultSet),
        expected
      );
    });
  });

  describe('#_eachLine', function () {

    function unfold(input: string) {
      let result: (string | undefined)[] = [];

      subject._eachLine(input, function (err, line) {
        result.push(line);
      });

      return result;
    }

    it('unfold single with \\r\\n', function () {
      let input = 'foo\r\n bar';
      let expected = ['foobar'];

      assert.deepEqual(unfold(input), expected);
    });

    it('with \\n', function () {
      let input = 'foo\nbar\n  baz';
      let expected = [
        'foo',
        'bar baz'
      ];

      assert.deepEqual(unfold(input), expected);
    });
  });

  describe('embedded timezones', function () {
    let icsDataEmbeddedTimezones: string;
    beforeEach(async function () {
      icsDataEmbeddedTimezones = await testSupport.loadSample('timezone_from_file.ics');
    });

    it('used in event date', function () {
      const parsed = ICAL.parse(icsDataEmbeddedTimezones);
      const component = new ICAL.Component(parsed);

      const event = new ICAL.Event(component.getFirstSubcomponent('vevent'));
      const startDate = event.startDate.toJSDate();
      const endDate = event.endDate.toJSDate();

      assert.equal(startDate.getUTCDate(), 6);
      assert.equal(startDate.getUTCHours(), 21);
      assert.equal(startDate.getUTCMinutes(), 23);

      assert.equal(endDate.getUTCDate(), 6);
      assert.equal(endDate.getUTCHours(), 22);
      assert.equal(endDate.getUTCMinutes(), 23);
    });
  });
});
