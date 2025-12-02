export interface OperatorExample {
    title?: string;
    description?: string;
    ui?: any;        // example payload for UI engine
    backend?: any;   // example payload for backend engine
    expected?: any;  // optional expected output for docs/tests
  }
  