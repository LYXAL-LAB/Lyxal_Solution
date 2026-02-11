import React, { useState } from 'react';
import { DayPicker } from 'react-day-picker';

const ReactDayPicker: React.FC = () => {
  const [selected, setSelected] = useState<Date | undefined>();

  return (
    <>
      <button
        popoverTarget="rdp-popover"
        className="input input-bordered"
        style={{ anchorName: '--rdp' } as React.CSSProperties}
      >
        {selected ? `Selected: ${selected.toLocaleDateString()}` : 'react-day-picker'}
      </button>
      <div
        popover="auto"
        id="rdp-popover"
        className="dropdown"
        style={{ positionAnchor: '--rdp' } as React.CSSProperties}
      >
        <DayPicker
          className="react-day-picker"
          mode="single"
          selected={selected}
          onSelect={setSelected}
        />
      </div>
    </>
  );
};

export default ReactDayPicker;
