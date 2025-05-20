import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
	appId: 'com.wordseekr.app',
	appName: 'WordSeekr',
	webDir: 'build',
	server: {
		url: 'http://192.168.1.207:5173',
		cleartext: true,
		androidScheme: 'https'
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
		}
	}
};

export default config;
