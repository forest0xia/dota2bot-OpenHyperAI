const fs = require('fs');
const path = require('path');

// Define the path to version.ts
const versionFilePath = path.join(__dirname, '../typescript/bots/FunLib/version.ts');

// Get the current date in UTC and subtract one day - to ensure all players around the globe won't see a date in future.
const currentDate = new Date();
currentDate.setUTCDate(currentDate.getUTCDate() - 1);

// Format the adjusted date as "YYYY/MM/DD" based on UTC time
const year = currentDate.getUTCFullYear();
const month = String(currentDate.getUTCMonth() + 1).padStart(2, '0'); // Months are 0-based
const day = String(currentDate.getUTCDate()).padStart(2, '0');

// Construct the formatted date string
const formattedDate = `${year}/${month}/${day}`;

// Read the contents of version.ts
fs.readFile(versionFilePath, 'utf8', (err, data) => {
    if (err) {
        console.error(`Error reading file ${versionFilePath}:`, err);
        return;
    }

    // Use a regex to find and update the date in the file
    const updatedData = data.replace(/(\d{4}\/\d{2}\/\d{2})/, formattedDate);

    // Write the updated content back to version.ts
    fs.writeFile(versionFilePath, updatedData, 'utf8', (err) => {
        if (err) {
            console.error(`Error writing file ${versionFilePath}:`, err);
        } else {
            console.log(`Version date updated to ${formattedDate}`);
        }
    });
});
