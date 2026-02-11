export const DatabaseQueryAssistant = {
    name: "database_query_assistant",
    description: "A helpful assistant for writing and optimizing SurrealQL queries",
    arguments: [
        {
            name: "query_type",
            description: "The type of query (SELECT, CREATE, UPDATE, DELETE, etc.)",
            required: true,
        },
        {
            name: "table_name",
            description: "The table name to query",
            required: false,
        },
        {
            name: "requirements",
            description: "Specific requirements or constraints for the query",
            required: false,
        },
    ],
    messages: (args) => {
        const queryType = args.query_type || "SELECT";
        const tableName = args.table_name || "your_table";
        const requirements = args.requirements
            ? `Requirements: ${args.requirements}`
            : "";
        return [
            {
                role: "user",
                content: {
                    type: "text",
                    text: `You are a SurrealQL expert assistant. Help me write a ${queryType} query for the '${tableName}' table. ${requirements}`,
                },
            },
            {
                role: "assistant",
                content: {
                    type: "text",
                    text: "I'll help you write an optimized SurrealQL query. Let me break this down step by step and provide you with the best approach for your use case.",
                },
            },
        ];
    },
};
export const DataModelingExpert = {
    name: "data_modeling_expert",
    description: "An expert assistant for designing and optimizing SurrealDB data models",
    arguments: [
        {
            name: "use_case",
            description: "The use case or application domain",
            required: true,
        },
        {
            name: "data_types",
            description: "The types of data to be stored",
            required: false,
        },
        {
            name: "scale_requirements",
            description: "Scale requirements",
            required: false,
        },
    ],
    messages: (args) => {
        const useCase = args.use_case || "general application";
        const dataTypes = args.data_types || "users and content";
        const scale = args.scale_requirements || "medium";
        return [
            {
                role: "user",
                content: {
                    type: "text",
                    text: `You are a SurrealDB data modeling expert. Help me design an optimal data model for a ${useCase} application that needs to handle ${dataTypes}. The scale requirements are: ${scale}.`,
                },
            },
            {
                role: "assistant",
                content: {
                    type: "text",
                    text: "I'll help you design an optimal SurrealDB data model. Let me analyze your requirements and provide a comprehensive solution with proper table structures, relationships, and indexing strategies.",
                },
            },
        ];
    },
};
export const SurrealQlGuide = {
    name: "surrealql_guide",
    description: "A prompt that provides best practices and examples for writing correct and efficient SurrealQL",
    arguments: [
        {
            name: "task",
            description: "Brief description of what you need to do in SurrealQL",
            required: false,
        },
        {
            name: "schema",
            description: "Optional schema or table context relevant to the task",
            required: false,
        },
    ],
    messages: (args) => {
        const task = args.task || "Write SurrealQL for my task";
        const schema = args.schema || "";
        const userText = schema ? `${task}\n\nSchema/context:\n${schema}` : task;
        const systemGuide = `You are a SurrealDB expert. Produce correct, safe, and efficient SurrealQL.

Best practices:
- Prefer parameterized queries with $name variables; avoid string concatenation.
- Use explicit WHERE filters; never update/delete entire tables unless user explicitly asks.
- For CREATE/UPSERT/UPDATE use CONTENT/MERGE/REPLACE appropriately.
- Use SPLIT ON for arrays, GROUP BY for aggregations, and ORDER BY with explicit direction.
- For relations, use RELATE a->edge->b, and optionally CONTENT for edge properties.
- Keep queries idempotent when possible; explain assumptions.
- Return only necessary fields using SELECT field projection when asked to optimize.

Examples:
-- Parameterized select
SELECT id, name FROM user WHERE age > $min_age AND name CONTAINS $name ORDER BY age DESC LIMIT 10;

-- Create with content
CREATE user CONTENT { id: user:alice, name: $name, age: $age };

-- Update merge vs replace
UPDATE user:alice MERGE { preferences: { theme: "dark" } };
UPDATE user:alice REPLACE { name: "Alice", age: 30 };

-- Relate with properties
RELATE user:alice->follows->user:bob CONTENT { since: time::now() };

-- Upsert pattern
UPSERT user:alice CONTENT { name: $name, age: $age };

If details are missing, ask concise clarifying questions before executing risky operations. Provide the final SurrealQL first, then a brief explanation.`;
        return [
            {
                role: "assistant",
                content: {
                    type: "text",
                    text: systemGuide,
                },
            },
            {
                role: "user",
                content: {
                    type: "text",
                    text: userText,
                },
            },
        ];
    },
};
