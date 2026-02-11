// Import des dépendances
import fs from "fs";
import path from "path";
import { transform } from "lightningcss";

export const minify = async (filePath: string): Promise<void> => {
  if (!fs.existsSync(filePath)) {
    return;
  }
  const css: string = await fs.promises.readFile(filePath, "utf8");
  try {
    const { code } = transform({
      filename: filePath,
      code: Buffer.from(css),
      minify: true,
    });
    const packageJson: any = JSON.parse(fs.readFileSync("package.json", "utf8"));
    const modifiedCode: string =
      `${atob("Lyoh")} ${decodeURIComponent("%F0%9F%8C%BC")} ${atob("THl4YWwgVUk=")} ${packageJson.version} ${atob("LSBQUk9QUklFVEFSWSBMSUNFTlNFICov")}` +
      code;
    await fs.promises.writeFile(filePath, modifiedCode);
  } catch (error: any) {
    throw new Error(`${filePath}:${error?.loc?.line}: ${error.message}`);
  }
};

export const minifyCssInDirectory = async (directories: string[]): Promise<void> => {
  await Promise.all(
    directories.map(async (dir: string): Promise<void> => {
      const directory: string = path.join(dir);
      const files: string[] = fs
        .readdirSync(directory)
        .filter((file: string) => path.extname(file).toLowerCase() === ".css")
        .map((file: string) => path.join(directory, file));

      await Promise.all(files.map(minify));
    }),
  );
};
