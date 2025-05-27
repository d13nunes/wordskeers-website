import { CapacitorConfig } from '@capacitor/cli';
const homeIp = '192.168.1.207';
const localhost = 'localhost';
const address = homeIp;
const config: CapacitorConfig = {
	appId: 'com.wordseekr.app',
	appName: 'WordSeekr',
	webDir: 'build',
	server: {
		url: `http://${address}:5173`,
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
