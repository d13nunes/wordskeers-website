import { readFileSync, writeFileSync } from 'fs';
import { execSync } from 'child_process';

// Parse command line arguments
const args = process.argv.slice(2);
const bumpMajor = args.includes('--major');
const bumpMinor = args.includes('--minor');
const bumpPatch = args.includes('--patch');

// Read package.json
const packageJson = JSON.parse(readFileSync('./package.json', 'utf8'));
let [major, minor, patch] = packageJson.version.split('.').map(Number);
let buildCounter = packageJson.build ?? 0

// Apply version bumps
if (bumpMajor) {
    major++;
    minor = 0;
    patch = 0;
    buildCounter = 0; // Reset counter on major version
} else if (bumpMinor) {
    minor++;
    patch = 0;
    buildCounter = 0; // Reset counter on minor version
} else if (bumpPatch) {
    patch++;
    buildCounter = 0; // Reset counter on patch version
}

// Increment build counter
buildCounter++;
console.log(buildCounter);


// Create new version string
const version = `${major}.${minor}.${patch}`;

// Generate build number (format: MMmmppbb)
// For version 2.1.3 with counter 1, it will be 02010301
const buildNumber = `${major.toString().padStart(2, '0')}${minor.toString().padStart(2, '0')}${patch.toString().padStart(2, '0')}${buildCounter.toString().padStart(2, '0')}`;

console.log(`Updating version to ${version} (buildNumber ${buildNumber}) `);

// Update package.json with new version
packageJson.version = version;
packageJson.build = buildCounter;
writeFileSync('./package.json', JSON.stringify(packageJson, null, 2) + '\n');
console.log('✅ package.json version updated');

// Update iOS version
const iosInfoPlistPath = './ios/App/App/Info.plist';
try {
    // Update CFBundleShortVersionString (version)
    execSync(`/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${version}" "${iosInfoPlistPath}"`);
    // Update CFBundleVersion (build number)
    execSync(`/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${buildNumber}" "${iosInfoPlistPath}"`);
    console.log('✅ iOS version updated successfully');
} catch (error) {
    console.error('❌ Failed to update iOS version:', error.message);
}

// Update Android version
const androidBuildGradlePath = './android/app/build.gradle';
try {
    let buildGradle = readFileSync(androidBuildGradlePath, 'utf8');
    
    // Update versionName
    buildGradle = buildGradle.replace(
        /versionName\s+"[^"]+"/,
        `versionName "${version}"`
    );
    
    // Update versionCode
    buildGradle = buildGradle.replace(
        /versionCode\s+\d+/,
        `versionCode ${parseInt(buildNumber)}`
    );
    
    writeFileSync(androidBuildGradlePath, buildGradle);
    console.log('✅ Android version updated successfully');
} catch (error) {
    console.error('❌ Failed to update Android version:', error.message);
}

console.log('Version update complete!'); 