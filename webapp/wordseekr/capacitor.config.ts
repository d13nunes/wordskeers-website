import { CapacitorConfig } from '@capacitor/cli';

const isLocal = process.env.VITE_CAPACITOR_IS_LOCAL === 'true';
const isDev = process.env.VITE_CAPACITOR_IS_DEV === 'true';
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
	android: {
		backgroundColor: '#F8FAFC'
	},
	ios: {
		backgroundColor: '#F8FAFC'
	},
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
			enabled: true
		}
	}
};

export default config;
