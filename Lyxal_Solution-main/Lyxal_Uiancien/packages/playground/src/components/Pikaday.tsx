import React, { useEffect, useRef } from 'react';
import Pikaday from 'pikaday';

interface PikadayComponentProps {
  format?: string;
  options?: Partial<Pikaday.PikadayOptions>;
  onInput?: (date: string) => void;
}

const PikadayComponent: React.FC<PikadayComponentProps> = ({
  format = 'YYYY-MM-DD',
  options = {},
  onInput
}) => {
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (!inputRef.current) return;

    const picker = new Pikaday({
      field: inputRef.current,
      format: format,
      onSelect: () => {
        if (onInput) {
          onInput(picker.toString());
        }
      },
      ...options,
    });

    return () => {
      picker.destroy();
    };
  }, [format, options, onInput]);

  return (
    <input
      className="input input-bordered"
      type="text"
      ref={inputRef}
      defaultValue="Pikaday from React"
    />
  );
};

export default PikadayComponent;
