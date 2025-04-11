import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
	appId: 'com.rhenis.gridwords',
	appName: 'WordSeekr',
	webDir: 'build',
	server: {
		url: 'http://localhost:5173',
		cleartext: true
	}
};

export default config;
