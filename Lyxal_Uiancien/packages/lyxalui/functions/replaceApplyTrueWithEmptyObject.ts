// Types TypeScript
type CssObject = { [key: string]: any };

export const replaceApplyTrueWithEmptyObject = (obj: CssObject): void => {
  const stack: CssObject[] = [obj];

  while (stack.length > 0) {
    const currentObj: CssObject = stack.pop()!;

    for (const [key, value] of Object.entries(currentObj)) {
      if (typeof value === "object" && value !== null) {
        stack.push(value);
      }

      if (key.startsWith("@apply") && value === true) {
        currentObj[key] = {};
      }
    }
  }
};
