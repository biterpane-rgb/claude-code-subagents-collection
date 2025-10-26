#!/usr/bin/env node

/**
 * MCP Server for Local File Access
 *
 * This server provides access to local files and network shares,
 * specifically designed for video analysis and meeting recordings.
 *
 * Features:
 * - Read files from local filesystem (Windows, Linux, macOS)
 * - Access network shares and mapped drives
 * - Video file support with metadata extraction
 * - Directory listing and file search
 * - Safe path validation and access control
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import * as fs from "fs/promises";
import * as path from "path";
import { existsSync, statSync } from "fs";

/**
 * Configuration for allowed base paths
 * By default, allows common video/document directories
 */
const ALLOWED_BASE_PATHS = process.env.MCP_ALLOWED_PATHS
  ? process.env.MCP_ALLOWED_PATHS.split(path.delimiter)
  : [
      // Windows common paths
      "C:\\Users",
      "D:\\",
      "E:\\",
      // Linux/macOS common paths
      "/home",
      "/Users",
      "/mnt",
      "/media",
    ];

/**
 * Validate that a path is within allowed directories
 */
function isPathAllowed(filePath: string): boolean {
  const normalizedPath = path.normalize(filePath);
  return ALLOWED_BASE_PATHS.some((basePath) => {
    const normalizedBase = path.normalize(basePath);
    return normalizedPath.startsWith(normalizedBase);
  });
}

/**
 * Get file metadata
 */
async function getFileMetadata(filePath: string) {
  const stats = await fs.stat(filePath);
  return {
    path: filePath,
    size: stats.size,
    created: stats.birthtime.toISOString(),
    modified: stats.mtime.toISOString(),
    isDirectory: stats.isDirectory(),
    isFile: stats.isFile(),
    extension: path.extname(filePath),
  };
}

/**
 * List files in a directory
 */
async function listDirectory(dirPath: string, pattern?: string) {
  const entries = await fs.readdir(dirPath, { withFileTypes: true });

  let filtered = entries;
  if (pattern) {
    const regex = new RegExp(pattern, "i");
    filtered = entries.filter((entry) => regex.test(entry.name));
  }

  const files = await Promise.all(
    filtered.map(async (entry) => {
      const fullPath = path.join(dirPath, entry.name);
      try {
        return await getFileMetadata(fullPath);
      } catch (error) {
        return {
          path: fullPath,
          error: `Unable to read metadata: ${error}`,
        };
      }
    })
  );

  return files;
}

/**
 * Read file content (with size limit for safety)
 */
async function readFile(filePath: string, encoding: BufferEncoding = "utf-8") {
  const stats = await fs.stat(filePath);
  const MAX_SIZE = 100 * 1024 * 1024; // 100MB limit

  if (stats.size > MAX_SIZE) {
    throw new Error(
      `File too large (${stats.size} bytes). Maximum size is ${MAX_SIZE} bytes.`
    );
  }

  // For binary files (like videos), return base64
  const ext = path.extname(filePath).toLowerCase();
  const videoExtensions = [".mp4", ".avi", ".mov", ".mkv", ".webm", ".flv"];

  if (videoExtensions.includes(ext)) {
    const buffer = await fs.readFile(filePath);
    return {
      type: "video",
      encoding: "base64",
      content: buffer.toString("base64"),
      metadata: await getFileMetadata(filePath),
    };
  }

  // Text files
  const content = await fs.readFile(filePath, encoding);
  return {
    type: "text",
    encoding,
    content,
    metadata: await getFileMetadata(filePath),
  };
}

/**
 * Search for files matching a pattern
 */
async function searchFiles(
  basePath: string,
  pattern: string,
  recursive = false,
  maxResults = 100
): Promise<string[]> {
  const results: string[] = [];
  const regex = new RegExp(pattern, "i");

  async function search(dir: string, depth = 0) {
    if (results.length >= maxResults || (!recursive && depth > 0)) {
      return;
    }

    try {
      const entries = await fs.readdir(dir, { withFileTypes: true });

      for (const entry of entries) {
        if (results.length >= maxResults) break;

        const fullPath = path.join(dir, entry.name);

        if (regex.test(entry.name)) {
          results.push(fullPath);
        }

        if (entry.isDirectory() && recursive) {
          await search(fullPath, depth + 1);
        }
      }
    } catch (error) {
      // Skip directories we can't read
    }
  }

  await search(basePath);
  return results;
}

/**
 * Define available tools
 */
const tools: Tool[] = [
  {
    name: "read_local_file",
    description:
      "Read content from a local file or network share. Supports text files and video files (returned as base64). Use this to access meeting recordings, presentations, or documents from local storage.",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description:
            "Absolute path to the file (e.g., 'C:\\Users\\username\\Videos\\meeting.mp4' or '/home/user/videos/meeting.mp4')",
        },
        encoding: {
          type: "string",
          enum: ["utf-8", "ascii", "latin1"],
          description: "Text encoding (only for text files, ignored for videos)",
          default: "utf-8",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "list_directory",
    description:
      "List files and subdirectories in a directory. Optionally filter by pattern (regex).",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "Absolute path to the directory",
        },
        pattern: {
          type: "string",
          description:
            "Optional regex pattern to filter files (e.g., '.*\\.mp4$' for MP4 videos)",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "get_file_metadata",
    description:
      "Get metadata about a file (size, creation date, modification date, type)",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "Absolute path to the file",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "search_files",
    description:
      "Search for files matching a pattern in a directory tree",
    inputSchema: {
      type: "object",
      properties: {
        basePath: {
          type: "string",
          description: "Directory to start searching from",
        },
        pattern: {
          type: "string",
          description: "Regex pattern to match filenames",
        },
        recursive: {
          type: "boolean",
          description: "Search recursively in subdirectories",
          default: false,
        },
        maxResults: {
          type: "number",
          description: "Maximum number of results to return",
          default: 100,
        },
      },
      required: ["basePath", "pattern"],
    },
  },
];

/**
 * Create and start the MCP server
 */
async function main() {
  const server = new Server(
    {
      name: "mcp-local-files",
      version: "1.0.0",
    },
    {
      capabilities: {
        tools: {},
      },
    }
  );

  // Handle tool listing
  server.setRequestHandler(ListToolsRequestSchema, async () => {
    return { tools };
  });

  // Handle tool execution
  server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: args } = request.params;

    try {
      switch (name) {
        case "read_local_file": {
          const filePath = args.path as string;

          if (!isPathAllowed(filePath)) {
            return {
              content: [
                {
                  type: "text",
                  text: `Error: Access denied. Path '${filePath}' is not in allowed directories. Allowed paths: ${ALLOWED_BASE_PATHS.join(", ")}`,
                },
              ],
            };
          }

          if (!existsSync(filePath)) {
            return {
              content: [
                {
                  type: "text",
                  text: `Error: File not found at path '${filePath}'`,
                },
              ],
            };
          }

          const result = await readFile(
            filePath,
            (args.encoding as BufferEncoding) || "utf-8"
          );

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(result, null, 2),
              },
            ],
          };
        }

        case "list_directory": {
          const dirPath = args.path as string;

          if (!isPathAllowed(dirPath)) {
            return {
              content: [
                {
                  type: "text",
                  text: `Error: Access denied to directory '${dirPath}'`,
                },
              ],
            };
          }

          const files = await listDirectory(dirPath, args.pattern as string);

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(files, null, 2),
              },
            ],
          };
        }

        case "get_file_metadata": {
          const filePath = args.path as string;

          if (!isPathAllowed(filePath)) {
            return {
              content: [
                {
                  type: "text",
                  text: `Error: Access denied to file '${filePath}'`,
                },
              ],
            };
          }

          const metadata = await getFileMetadata(filePath);

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(metadata, null, 2),
              },
            ],
          };
        }

        case "search_files": {
          const basePath = args.basePath as string;

          if (!isPathAllowed(basePath)) {
            return {
              content: [
                {
                  type: "text",
                  text: `Error: Access denied to directory '${basePath}'`,
                },
              ],
            };
          }

          const results = await searchFiles(
            basePath,
            args.pattern as string,
            args.recursive as boolean,
            args.maxResults as number
          );

          return {
            content: [
              {
                type: "text",
                text: JSON.stringify(results, null, 2),
              },
            ],
          };
        }

        default:
          return {
            content: [
              {
                type: "text",
                text: `Error: Unknown tool '${name}'`,
              },
            ],
            isError: true,
          };
      }
    } catch (error) {
      return {
        content: [
          {
            type: "text",
            text: `Error: ${error instanceof Error ? error.message : String(error)}`,
          },
        ],
        isError: true,
      };
    }
  });

  // Start server with stdio transport
  const transport = new StdioServerTransport();
  await server.connect(transport);

  console.error("MCP Local Files Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
