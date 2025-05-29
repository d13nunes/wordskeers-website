import { CapacitorConfig } from '@capacitor/cli';

const isLocal = process.env.CAPACITOR_IS_LOCAL === 'true';
const isDev = process.env.CAPACITOR_IS_DEV === 'true';
const address = isLocal ? 'localhost' : '192.168.1.207';

const server: {
	url?: string;
	cleartext?: boolean;
	androidScheme: string;
} = {
	androidScheme: 'https'
};

if (isDev) {
	server.url = `http://${address}:5173/?isDev=true`;
	server.cleartext = true;
}

const config: CapacitorConfig = {
	appId: 'com.wordseekr.app',
	appName: 'WordSeekr',
	webDir: 'build',
	server: server,
	plugins: {
		SQLite: {
			iosDatabaseLocation: 'Library/WordSeekrDatabase',
			iosIsEncryption: false,
			iosBiometric: {
				biometricAuth: false,
				biometricTitle: 'Biometric login for WordSeekr'
			},
			androidIsEncryption: false,
			androidBiometric: {
				biometricAuth: false,
				biometricTitle: 'Biometric login for WordSeekr',
				biometricSubTitle: 'Log in using your biometric'
			}
		},
		SafeArea: {
			enabled: true,
			customColorsForSystemBars: true,
			statusBarColor: '#000000',
			statusBarContent: 'light',
			navigationBarColor: '#000000',
			navigationBarContent: 'light',
			offset: 0
		}
	}
};

export default config;
