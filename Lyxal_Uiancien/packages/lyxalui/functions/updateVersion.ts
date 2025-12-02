// Import des dépendances
import { readFileSync, writeFileSync } from "fs";

const readPackageVersion = (packageJsonPath: string): string => {
  const packageJson: any = JSON.parse(readFileSync(packageJsonPath, "utf-8"));
  return packageJson.version;
};

const updateIndexJsVersion = (indexJsPath: string, version: string): void => {
  let indexJsContent: string = readFileSync(indexJsPath, "utf-8");
  indexJsContent = indexJsContent.replace(/const version = ".*"/, `const version = "${version}"`);
  writeFileSync(indexJsPath, indexJsContent, "utf-8");
};

export const updateVersion = (): Promise<void> => {
  const packageJsonPath: string = "packages/lyxalui/package.json";
  const indexJsPath: string = "packages/lyxalui/index.ts";

  try {
    const version: string = readPackageVersion(packageJsonPath);
    updateIndexJsVersion(indexJsPath, version);
    return Promise.resolve();
  } catch (error) {
    return Promise.reject(error);
  }
};
