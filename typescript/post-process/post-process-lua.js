const fs = require("fs");
const path = require("path");

// Define the root directory containing the generated Lua files
const luaRootDirectory = path.join(__dirname, "../../bots");

// Function to replace paths in a Lua file
function replacePathsInFile(filePath) {
    fs.readFile(filePath, "utf8", (err, data) => {
        if (err) {
            console.error(`Error reading file ${filePath}:`, err);
            return;
        }

        // console.log(`Processing file: ${filePath}`);

        // Regex patterns to match require and dofile calls with paths starting with "bots." or "bots/"
        const patterns = [
            {
                regex: /require\("bots\.([^"]+)"\)/g,
                type: "require",
                style: "dots",
            },
            {
                regex: /require\("bots\/([^"]+)"\)/g,
                type: "require",
                style: "slashes",
            },
            {
                regex: /dofile\("bots\.([^"]+)"\)/g,
                type: "dofile",
                style: "dots",
            },
            {
                regex: /dofile\("bots\/([^"]+)"\)/g,
                type: "dofile",
                style: "slashes",
            },
        ];

        let updatedData = data;
        let hasChanges = false;

        // Apply transformations for each pattern
        patterns.forEach(({ regex, type, style }) => {
            updatedData = updatedData.replace(regex, (match, p1) => {
                let newPath;
                if (style === "dots") {
                    newPath = `GetScriptDirectory().."/${p1.replace(/\./g, "/")}"`;
                } else {
                    newPath = `GetScriptDirectory().."/${p1}"`;
                }
                console.log(`Transforming ${type} path (${style}): '${match}' to '${type}(${newPath})'`);
                hasChanges = true;
                return `${type}(${newPath})`;
            });
        });

        // Write the updated content back to the file if changes were made
        if (hasChanges) {
            fs.writeFile(filePath, updatedData, "utf8", err => {
                if (err) {
                    console.error(`Error writing file ${filePath}:`, err);
                } else {
                    // console.log(`Processed and updated file: ${filePath}`);
                }
            });
        } else {
            // console.log(`No matches found in file: ${filePath}`);
        }
    });
}

// Function to recursively read directories and process Lua files
function processDirectory(directory) {
    fs.readdir(directory, { withFileTypes: true }, (err, entries) => {
        if (err) {
            console.error(`Error reading directory ${directory}:`, err);
            return;
        }

        entries.forEach(entry => {
            const entryPath = path.join(directory, entry.name);

            if (entry.isDirectory()) {
                // Recursively process subdirectories
                processDirectory(entryPath);
            } else if (entry.isFile() && entry.name.endsWith(".lua")) {
                // Process Lua files
                replacePathsInFile(entryPath);
            }
        });
    });
}

// Start processing from the root Lua directory
console.log(`Started post-process lua`);
processDirectory(luaRootDirectory);
