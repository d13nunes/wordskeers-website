import { execSync } from 'child_process';
import { readFileSync } from 'fs';



let apiKey;
let apiIssuer;

// check if credentials where passed as arguments
if (process.argv.length === 5) {
    apiKey = process.argv[3];
    apiIssuer = process.argv[4];
} else if (process.argv.length === 4) {
    // load from file
    const credentialsPath = process.argv[3];
    const credentials = JSON.parse(readFileSync(credentialsPath, 'utf8'));
    apiKey = credentials.apiKey;
    apiIssuer = credentials.apiIssuer;
} else {
    console.error('Usage: node upload-ios.js <apiKey> <apiIssuer> or node upload-ios.js <credentials.json>');
    process.exit(1);
}

const ipaPath = process.argv[2];
console.log(`Uploading app to App Store Connect with apiKey: ${apiKey} and apiIssuer: ${apiIssuer} and ipaPath: ${ipaPath}`);
try {
    const result = execSync(`xcrun altool --upload-app --file ${ipaPath} --type ios --apiKey ${apiKey} --apiIssuer ${apiIssuer}`);
    console.log(result);
} catch (error) {
    console.error('Error uploading app to App Store Connect:', error);
    process.exit(1);
}