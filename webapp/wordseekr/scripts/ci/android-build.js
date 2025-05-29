import { execSync } from 'child_process';
import { existsSync } from 'fs';
import fs from 'fs';

const isLocal = process.argv[3] !== 'gha';
console.log(process.argv[3], isLocal);
let config = {};
if (isLocal) {
    console.log('Local build');
    const KEYSTORE_CONFIG_PATH = '/Users/diogonunes/Documents/code/wordseekr/keys/android_keystore_config.json';

    console.log("!!", KEYSTORE_CONFIG_PATH);
    config = JSON.parse(fs.readFileSync(KEYSTORE_CONFIG_PATH, 'utf8'));    
} else {
    console.log('CI build');
}
const KEYSTORE_PATH = config.keyStorePath || process.env.ANDROID_KEYSTORE_PATH;
const KEYSTORE_PASSWORD = config.password || process.env.ANDROID_KEYSTORE_PASSWORD;
const KEY_ALIAS = config.alias || process.env.ANDROID_KEY_ALIAS;
const KEY_PASSWORD = config.aliasPassword ||process.env.ANDROID_KEY_PASSWORD;

if (!existsSync(KEYSTORE_PATH)) {
    console.error('Keystore not found at:', KEYSTORE_PATH);
    console.error('Please set ANDROID_KEYSTORE_PATH or place keystore.jks in android/app/');
    process.exit(1);
}

if (!KEYSTORE_PASSWORD || !KEY_ALIAS || !KEY_PASSWORD) {
    console.error('Missing required environment variables:');
    console.error('- ANDROID_KEYSTORE_PASSWORD');
    console.error('- ANDROID_KEY_ALIAS');
    console.error('- ANDROID_KEY_PASSWORD');
    process.exit(1);
}

try {
    // Sign the bundle
    const signCommand = `
    export ANDROID_KEYSTORE_PATH=${KEYSTORE_PATH}
    export ANDROID_KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
    export ANDROID_KEY_ALIAS=${KEY_ALIAS}
    export ANDROID_KEY_PASSWORD=${KEY_PASSWORD}
    cd android \
    && ./gradlew clean \
    && ./gradlew bundleRelease
    `;
    
    console.log('Signing bundle...', signCommand);
    execSync(signCommand, { stdio: 'inherit' });
    
    console.log('\nBundle signed successfully!');
    console.log('Output:', 'android/app/build/outputs/bundle/release/app-release.apks');
} catch (error) {
    console.error('Error signing bundle:', error.message);
    process.exit(1);
} 