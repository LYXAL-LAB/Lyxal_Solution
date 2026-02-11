// Types TypeScript
import { brotliCompress, constants } from "zlib";
import { promises as fs } from "fs";
import path from "path";

interface FileReport {
  file: string;
  selector: number;
  var: number;
  raw: number;
  brotli: number;
  "%": number;
}

interface ReportData {
  timestamp: string;
  data: FileReport[];
}

const checkVariableWarnings = (variables: string[], filename: string): void => {
  const twVariables: string[] = variables.filter(
    (variable: string) => variable.startsWith("--container") && variable !== "--tw-content",
  );
  const spacingVariables: string[] = variables.filter((variable: string) => variable.startsWith("var(--spacing)"));

  if (
    twVariables.length > 0 &&
    !["typography.css", "properties.css", "states.css", "responsive.css", "lyxalui.css"].includes(filename)
  ) {
    console.log(`Warning: unnecessary --tw variables in ${filename}:`, twVariables);
  }
  if (spacingVariables.length > 0 && !["spacing.css", "grid.css"].includes(filename)) {
    console.log(`Warning: dangerous var(--spacing) variables in ${filename}:`, spacingVariables);
  }
};

const compressFile = (content: Buffer, compressFunc: typeof brotliCompress, compressionLevel: number = 11): Promise<number> => {
  return new Promise((resolve, reject) => {
    compressFunc(
      content,
      { params: { [constants.BROTLI_PARAM_QUALITY]: compressionLevel } },
      (err: any, result: Buffer) => {
        if (err) reject(err);
        else resolve(result.length);
      },
    );
  });
};

const processFile = async (filePath: string): Promise<FileReport> => {
  const fileContent: string = await fs.readFile(filePath, "utf8");
  const stats: any = await fs.stat(filePath);
  const brotliSize: number = await compressFile(Buffer.from(fileContent), brotliCompress);
  const allCssVariables: string[] = fileContent.match(/--[\w-]+/g) || [];

  checkVariableWarnings(allCssVariables, path.basename(filePath));

  return {
    file: filePath,
    selector: (fileContent.match(/(?:[^}]+{|@\w+\s*[^;{}]+(?:;|\{))/g) || []).length,
    var: allCssVariables.length,
    raw: stats.size / 1000,
    brotli: brotliSize / 1000,
    "%": Math.round((1 - brotliSize / stats.size) * 100),
  };
};

const processDirectory = async (dir: string): Promise<FileReport[]> => {
  const files: string[] = await fs.readdir(dir);
  const cssFiles: string[] = files.filter((file: string) => file.endsWith(".css"));
  return Promise.all(cssFiles.map((file: string) => processFile(path.join(dir, file))));
};

const normalizeData = (data: FileReport[]): FileReport[] => {
  return data.map((item: FileReport) => ({
    ...item,
    file: path.basename(item.file),
    raw: Number(item.raw.toFixed(3)),
    brotli: Number(item.brotli.toFixed(3)),
    "%": Number(item["%"]),
  }));
};

const shouldSaveNewReport = async (lastReportPath: string, currentData: FileReport[]): Promise<boolean> => {
  try {
    const lastReportContent: string = await fs.readFile(lastReportPath, "utf8");
    const lastReport: ReportData = JSON.parse(lastReportContent);

    const currentNormalized: FileReport[] = normalizeData(currentData);
    const lastNormalized: FileReport[] = normalizeData(lastReport.data);

    return JSON.stringify(currentNormalized) !== JSON.stringify(lastNormalized);
  } catch (error) {
    console.log(error);
    return true;
  }
};

export const report = async (directories: string[]): Promise<void> => {
  try {
    const results: (FileReport[] | FileReport)[] = await Promise.all(
      directories.map(async (item: string) => {
        const stats: any = await fs.stat(item);
        return stats.isDirectory() ? processDirectory(item) : processFile(item);
      }),
    );

    const flatReport: FileReport[] = results.flat().filter(Boolean) as FileReport[];
    if (flatReport.length === 0) throw new Error("No files were successfully processed.");

    console.table(flatReport, ["file", "selector", "var", "raw", "brotli", "%"]);

    const reportData: ReportData = {
      timestamp: new Date().toISOString().replace(/:/g, "-"),
      data: flatReport,
    };

    const reportsDir: string = path.join(process.cwd(), "../logs");
    await fs.mkdir(reportsDir, { recursive: true });

    const files: string[] = await fs.readdir(reportsDir);
    const jsonFiles: string[] = files
      .filter((file: string) => file.endsWith(".json") && file !== "package.json")
      .sort((a: string, b: string) => b.localeCompare(a));

    const shouldSave: boolean =
      jsonFiles.length === 0 ||
      (jsonFiles.length > 0 && await shouldSaveNewReport(path.join(reportsDir, jsonFiles[0]!), flatReport));

    if (shouldSave) {
      const reportPath: string = path.join(reportsDir, `${reportData.timestamp}.json`);
      await fs.writeFile(reportPath, JSON.stringify(reportData, null, 0));

      const updatedFiles: string[] = (await fs.readdir(reportsDir)).filter(
        (file: string) => file.endsWith(".json") && file !== "package.json",
      );
      await fs.writeFile(
        path.join(reportsDir, "index.ts"),
        `export const reportFiles = ${JSON.stringify(updatedFiles, null, 0)};`,
      );

      console.log(`Report saved: ${reportPath}`);
    }
  } catch (error: any) {
    console.error(`Error: ${error.message}`);
    throw error;
  }
};
