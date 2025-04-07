import {
	AdMob,
	AdmobConsentStatus,
	BannerAdPluginEvents,
	BannerAdPosition,
	BannerAdSize,
	type AdMobBannerSize,
	type BannerAdOptions
} from '@capacitor-community/admob';

export async function initialize(): Promise<void> {
	await AdMob.initialize();
	console.log('📺 AdMob initialized');
	return;
	const trackingInfo = await AdMob.trackingAuthorizationStatus();
	console.log('📺 AdMob trackingInfo', trackingInfo);
	try {
		const consentInfo = await AdMob.requestConsentInfo();
		console.log('📺 AdMob consentInfo', consentInfo);
	} catch (error) {
		console.error('📺 AdMob consentInfo error', error);
	}

	// const [trackingInfo, consentInfo] = await Promise.all([
	// 	AdMob.trackingAuthorizationStatus(),
	// 	AdMob.requestConsentInfo()
	// ]);

	console.log('📺 AdMob trackingInfo', trackingInfo);
	if (trackingInfo.status === 'notDetermined') {
		/**
		 * If you want to explain TrackingAuthorization before showing the iOS dialog,
		 * you can show the modal here.
		 * ex)
		 * const modal = await this.modalCtrl.create({
		 *   component: RequestTrackingPage,
		 * });
		 * await modal.present();
		 * await modal.onDidDismiss();  // Wait for close modal
		 **/
		// const modal = await this.modalCtrl.create({
		// component: RequestTrackingPage
		// });
		// await modal.present();
		// await modal.onDidDismiss(); // Wait for close modal

		await AdMob.requestTrackingAuthorization();
		console.log('📺 AdMob requestTrackingAuthorization');
	}

	const authorizationStatus = await AdMob.trackingAuthorizationStatus();
	console.log('📺 AdMob authorizationStatus', authorizationStatus);
	if (
		authorizationStatus.status === 'authorized' &&
		consentInfo.isConsentFormAvailable &&
		consentInfo.status === AdmobConsentStatus.REQUIRED
	) {
		console.log('📺 AdMob showing consent form');
		await AdMob.showConsentForm();
	}
}

interface AdmobAdIds {
	interstitial: string;
	rewardInterstitial: string;
	reward: string;
	banner: string;
}

const admobAdIdsDebug: AdmobAdIds = {
	interstitial: 'ca-app-pub-3940256099942544/4411468910',
	rewardInterstitial: 'ca-app-pub-3940256099942544/1712485313',
	reward: 'ca-app-pub-3940256099942544/1712485313',
	banner: 'ca-app-pub-3940256099942544/2934735716'
};
// const admobAdIdsProduction: AdmobAdIds = {
// 	interstitial: 'ca-app-pub-9539843520256562/2545593663',
// 	reward: 'ca-app-pub-9539843520256562/3226451648',
// 	banner: 'ca-app-pub-9539843520256562/1015855733',
// 	rewardInterstitial: 'ca-app-pub-9539843520256562/5270995200'
// };

const admobAdIds = admobAdIdsDebug;

export async function banner(): Promise<void> {
	AdMob.addListener(BannerAdPluginEvents.Loaded, () => {
		// Subscribe Banner Event Listener
		console.log('📺 AdMob banner loaded');
	});

	AdMob.addListener(BannerAdPluginEvents.SizeChanged, (size: AdMobBannerSize) => {
		// Subscribe Change Banner Size
		console.log('📺 AdMob banner size changed', size);
	});

	const options: BannerAdOptions = {
		adId: admobAdIds.banner,
		adSize: BannerAdSize.BANNER,
		position: BannerAdPosition.BOTTOM_CENTER,
		margin: 0,
		isTesting: true
		// npa: true
	};
	console.log('📺 AdMob showBanner', options);
	AdMob.showBanner(options);
}

enum AdType {
	Interstitial = 'interstitial',
	Rewarded = 'rewarded',
	RewardedInterstitial = 'rewardedInterstitial',
	Banner = 'banner'
}

type AdAvailabilityCallback = (adType: AdType, isAvailable: boolean) => void;

const availabilityCallbacks: AdAvailabilityCallback[] = [];
const adAvailability: Record<AdType, boolean> = {
	[AdType.Interstitial]: false,
	[AdType.Rewarded]: false,
	[AdType.RewardedInterstitial]: false,
	[AdType.Banner]: false
};

export function onAdAvailabilityChange(callback: AdAvailabilityCallback) {
	availabilityCallbacks.push(callback);
}

export function setAdAvailability(adType: AdType, isAvailable: boolean) {
	adAvailability[adType] = isAvailable;
	availabilityCallbacks.forEach((callback) => callback(adType, isAvailable));
}

export function isAdAvailable(adType: AdType): boolean {
	return adAvailability[adType];
}

export async function showAd(adType: AdType): Promise<boolean> {
	switch (adType) {
		case AdType.Interstitial:
			return showInterstitial();
		case AdType.Rewarded:
			return showRewarded();
		case AdType.RewardedInterstitial:
			return showRewardedInterstitial();
		case AdType.Banner:
			return showBanner();
		default:
			return false;
	}
}
async function showInterstitial(): Promise<boolean> {
	return true;
}
async function showRewarded(): Promise<boolean> {
	return true;
}
async function showRewardedInterstitial(): Promise<boolean> {
	return true;
}
async function showBanner(): Promise<boolean> {
	return true;
}
