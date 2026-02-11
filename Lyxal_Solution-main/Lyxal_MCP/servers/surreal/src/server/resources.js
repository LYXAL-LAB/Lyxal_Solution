import fs from "fs/promises";
import path from "path";
export const InstructionsResource = {
    uri: "surrealmcp://instructions",
    name: "SurrealMCP Instructions",
    mimeType: "text/markdown",
    description: "Full instructions and guidelines for the SurrealDB MCP server",
    read: async () => {
        try {
            const filePath = path.join(process.cwd(), "instructions.md");
            const text = await fs.readFile(filePath, "utf-8");
            return {
                contents: [
                    {
                        uri: "surrealmcp://instructions",
                        mimeType: "text/markdown",
                        text,
                    },
                ],
            };
        }
        catch (err) {
            return {
                contents: [
                    {
                        uri: "surrealmcp://instructions",
                        mimeType: "text/markdown",
                        text: "Error: instructions.md not found.",
                    },
                ],
            };
        }
    },
};
export const Resources = [InstructionsResource];
