#!/usr/bin/env node

const fs = require('fs');

const invalidCharacter = [' ', '.']

function checkSpacesInJSON(jsonData, checkKeys = false) {
    function checkObject(obj, path = '') {
        for (const key in obj) {
            if (checkKeys) {
                if (invalidCharacter.some(char => key.includes(char))) {
                    console.log(`Key with space found: "${key}" at path: ${path}`);
                }
            }

            const value = obj[key];

            if (typeof value === 'string' && invalidCharacter.some(char => value.includes(char))) {
                console.log(`Value with space found: "${value}" at path: ${path}${key}`);
            } else if (typeof value === 'object' && value !== null) {
                checkObject(value, `${path}${key}.`);
            }
        }
    }

    try {
        const parsedData = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;
        checkObject(parsedData);
    } catch (error) {
        console.error("Invalid JSON data:", error);
    }
}

// Read JSON file from command line argument
if (process.argv.length < 3) {
    console.error("Usage: node checkSpaces.js <path-to-json-file>");
    process.exit(1);
}

const filePath = process.argv[2];

const checkKeys = process.argv[3] === '--keys';

fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) {
        console.error(`Error reading file: ${err.message}`);
        process.exit(1);
    }

    checkSpacesInJSON(data);
});