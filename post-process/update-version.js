const fs = require('fs');
const path = require('path');

// Define the path to version.ts
const versionFilePath = path.join(__dirname, '../typescript/bots/FunLib/version.ts');

// Read the current date in the format "YYYY/MM/DD"
const currentDate = new Date().toISOString().split('T')[0].replace(/-/g, '/');

// Read the contents of version.ts
fs.readFile(versionFilePath, 'utf8', (err, data) => {
    if (err) {
        console.error(`Error reading file ${versionFilePath}:`, err);
        return;
    }

    // Use a regex to find and update the date in the file
    const updatedData = data.replace(/(\d{4}\/\d{2}\/\d{2})/, currentDate);

    // Write the updated content back to version.ts
    fs.writeFile(versionFilePath, updatedData, 'utf8', (err) => {
        if (err) {
            console.error(`Error writing file ${versionFilePath}:`, err);
        } else {
            console.log(`Version date updated to ${currentDate}`);
        }
    });
});
