import process from "node:process";
import { extract } from "regrafter";

function readStdin() {
  return new Promise((resolve, reject) => {
    let input = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", chunk => {
      input += chunk;
    });
    process.stdin.on("end", () => resolve(input));
    process.stdin.on("error", reject);
  });
}

function byteColumnToUtf16(content, lineNumber, byteColumn) {
  const line = content.split("\n")[lineNumber - 1] ?? "";
  const bytes = Buffer.from(line, "utf8");
  const safeColumn = Math.max(0, Math.min(byteColumn, bytes.length));
  return bytes.subarray(0, safeColumn).toString("utf8").length;
}

function makeSelector(request) {
  return {
    file: request.sourcePath,
    start: {
      line: request.range.start.line,
      column: byteColumnToUtf16(
        request.content,
        request.range.start.line,
        request.range.start.column
      ),
    },
    end: {
      line: request.range.end.line,
      column: byteColumnToUtf16(
        request.content,
        request.range.end.line,
        request.range.end.column
      ),
    },
  };
}

function errorDetails(error) {
  if (!error || typeof error !== "object") {
    return { message: String(error) };
  }

  return {
    message: error.message ?? error.details ?? "Regrafter could not extract this selection.",
    code: error.code,
    category: error.category,
    details: error.details,
    suggestions: error.suggestions,
  };
}

function validateRequest(request) {
  const requiredStrings = ["sourcePath", "content", "componentName"];
  for (const field of requiredStrings) {
    if (typeof request[field] !== "string") {
      throw new Error(`Missing string field: ${field}`);
    }
  }

  if (!request.range?.start || !request.range?.end) {
    throw new Error("Missing extraction range");
  }
}

async function main() {
  try {
    const request = JSON.parse(await readStdin());
    validateRequest(request);

    const options = {
      componentName: request.componentName,
      generateTypes: request.sourcePath.endsWith(".tsx"),
    };
    if (request.targetPath) {
      options.targetFile = request.targetPath;
    }

    const result = extract(
      [{ path: request.sourcePath, content: request.content }],
      makeSelector(request),
      options
    );

    if (!result.ok) {
      process.stdout.write(JSON.stringify({ ok: false, error: errorDetails(result.error) }));
      return;
    }

    process.stdout.write(JSON.stringify({ ok: true, value: result.value }));
  } catch (error) {
    process.stdout.write(JSON.stringify({ ok: false, error: errorDetails(error) }));
  }
}

await main();
