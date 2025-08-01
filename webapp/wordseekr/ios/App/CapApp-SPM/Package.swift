// swift-tools-version: 5.9
import PackageDescription

// DO NOT MODIFY THIS FILE - managed by Capacitor CLI commands
let package = Package(
    name: "CapApp-SPM",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CapApp-SPM",
            targets: ["CapApp-SPM"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", exact: "7.4.2"),
        .package(name: "AdplorgCapacitorInAppPurchase", path: "../../../node_modules/@adplorg/capacitor-in-app-purchase"),
        .package(name: "CapacitorCommunityAdmob", path: "../../../../../../../oss/admob"),
        .package(name: "CapacitorCommunitySafeArea", path: "../../../../../../../forks/safe-area"),
        .package(name: "CapacitorCommunitySqlite", path: "../../../../../../../forks/sqlite"),
        .package(name: "CapacitorFirebaseAnalytics", path: "../../../node_modules/@capacitor-firebase/analytics"),
        .package(name: "CapacitorFirebaseCrashlytics", path: "../../../node_modules/@capacitor-firebase/crashlytics"),
        .package(name: "CapacitorFirebaseFirestore", path: "../../../node_modules/@capacitor-firebase/firestore"),
        .package(name: "CapacitorFirebasePerformance", path: "../../../node_modules/@capacitor-firebase/performance"),
        .package(name: "CapacitorApp", path: "../../../node_modules/@capacitor/app"),
        .package(name: "CapacitorHaptics", path: "../../../node_modules/@capacitor/haptics"),
        .package(name: "CapacitorLocalNotifications", path: "../../../../../../../capacitor-plugins/local-notifications"),
        .package(name: "CapacitorPreferences", path: "../../../node_modules/@capacitor/preferences"),
        .package(name: "AptoideAppcoinssdk", path: "../../../../../../../aptoide/aptoide-appcoinssdk")
    ],
    targets: [
        .target(
            name: "CapApp-SPM",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                .product(name: "AdplorgCapacitorInAppPurchase", package: "AdplorgCapacitorInAppPurchase"),
                .product(name: "CapacitorCommunityAdmob", package: "CapacitorCommunityAdmob"),
                .product(name: "CapacitorCommunitySafeArea", package: "CapacitorCommunitySafeArea"),
                .product(name: "CapacitorCommunitySqlite", package: "CapacitorCommunitySqlite"),
                .product(name: "CapacitorFirebaseAnalytics", package: "CapacitorFirebaseAnalytics"),
                .product(name: "CapacitorFirebaseCrashlytics", package: "CapacitorFirebaseCrashlytics"),
                .product(name: "CapacitorFirebaseFirestore", package: "CapacitorFirebaseFirestore"),
                .product(name: "CapacitorFirebasePerformance", package: "CapacitorFirebasePerformance"),
                .product(name: "CapacitorApp", package: "CapacitorApp"),
                .product(name: "CapacitorHaptics", package: "CapacitorHaptics"),
                .product(name: "CapacitorLocalNotifications", package: "CapacitorLocalNotifications"),
                .product(name: "CapacitorPreferences", package: "CapacitorPreferences"),
                .product(name: "AptoideAppcoinssdk", package: "AptoideAppcoinssdk")
            ]
        )
    ]
)
