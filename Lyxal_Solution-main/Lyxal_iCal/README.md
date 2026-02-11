# Lyxal iCal

A native TypeScript iCalendar parsing and generation library for the Lyxal ecosystem.

Forked from [ical.js](https://github.com/kewisch/ical.js) and rewritten in TypeScript for the Bun runtime.

## Installation

```bash
bun add @lyxal/ical
```

## Usage

```typescript
import ICAL, { Component, Property, Time } from "@lyxal/ical";

// Parse an iCalendar string
const calendar = Component.fromString(`BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
DTSTART:20231225T100000Z
DTEND:20231225T120000Z
SUMMARY:Christmas Party
END:VEVENT
END:VCALENDAR`);

// Access event data
const event = calendar.getFirstSubcomponent('vevent');
const summary = event?.getFirstPropertyValue('summary');
console.log(summary); // "Christmas Party"

// Create a new event
const newEvent = new Component('vevent');
newEvent.addPropertyWithValue('dtstart', Time.now());
newEvent.addPropertyWithValue('summary', 'New Event');

// Serialize back to iCalendar
console.log(newEvent.toString());
```

## Features

- **Full iCalendar RFC 5545 support** - Parse and generate iCalendar data
- **Recurrence rules (RRULE)** - Expand recurring events
- **Timezone support** - Handle VTIMEZONE components
- **vCard support** - Parse and generate vCard data
- **TypeScript-first** - Full type safety and IDE support
- **Bun-optimized** - Built for the Bun runtime

## API Overview

### Core Classes

- `Component` - Represents VCALENDAR, VEVENT, VTODO, etc.
- `Property` - Represents iCalendar properties like DTSTART, SUMMARY
- `Time` - Date and time handling
- `Duration` - Duration values (e.g., PT1H30M)
- `Recur` - Recurrence rule parsing and generation
- `Event` - High-level VEVENT wrapper

### Parsing and Serialization

```typescript
import ICAL from "@lyxal/ical";

// Parse
const jCal = ICAL.parse(icsString);
const component = new Component(jCal);

// Serialize
const icsOutput = component.toString();
```

### Working with Recurrence

```typescript
import { RecurExpansion, Component } from "@lyxal/ical";

const calendar = Component.fromString(icsString);
const event = calendar.getFirstSubcomponent('vevent');

const expansion = new RecurExpansion({
  component: event!,
  dtstart: event!.getFirstPropertyValue('dtstart') as Time
});

// Get next 10 occurrences
const occurrences = expansion.take(10);
```

## License

MPL-2.0 (Mozilla Public License 2.0)

Based on ical.js by Philipp Kewisch and contributors.
