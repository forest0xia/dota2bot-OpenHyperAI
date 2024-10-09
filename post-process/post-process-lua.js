const fs = require('fs');
const path = require('path');

// Define the root directory containing the generated Lua files (update this if necessary)
const luaRootDirectory = path.join(__dirname, '../bots'); // Update this path if needed

// Function to replace paths in a Lua file
function replacePathsInFile(filePath) {
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err) {
            console.error(`Error reading file ${filePath}:`, err);
            return;
        }

        // Log the original content for debugging
        // console.log(`Processing file: ${filePath}`);
        // console.log("Original content snippet:\n", data.substring(0, 200));

        // Regex to match the require calls with paths starting with "bots."
        const regex = /require\("bots\.([^"]+)"\)/g;
        if (regex.test(data)) {
            // console.log("Match found in file:", filePath);

            const replacedData = data.replace(regex, (match, p1) => {
                // Replace dots with slashes and construct the new path
                const newPath = `GetScriptDirectory().."/${p1.replace(/\./g, '/')}"`;
                console.log(`Transforming path: '${match}' to 'require(${newPath})'`);
                return `require(${newPath})`;
            });

            fs.writeFile(filePath, replacedData, 'utf8', (err) => {
                if (err) {
                    console.error(`Error writing file ${filePath}:`, err);
                } else {
                    // console.log(`Processed and updated file: ${filePath}`);
                }
            });
        } else {
            // console.log("No match found in file:", filePath);
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

        entries.forEach((entry) => {
            const entryPath = path.join(directory, entry.name);

            if (entry.isDirectory()) {
                // Recursively process subdirectories
                processDirectory(entryPath);
            } else if (entry.isFile() && entry.name.endsWith('.lua')) {
                // Process Lua files
                replacePathsInFile(entryPath);
            }
        });
    });
}

// Start processing from the root Lua directory
console.log(`Started post-process lua`);
processDirectory(luaRootDirectory);
