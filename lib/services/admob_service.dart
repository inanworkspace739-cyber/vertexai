import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AD UNIT IDS  (iOS only)
// Replace the placeholder values below with your real AdMob iOS IDs.
// ─────────────────────────────────────────────────────────────────────────────
class AdIds {
  // App Open Ad
  static String get appOpen => 'ca-app-pub-9283129936552011/5975720400';

  // Interstitial
  static String get interstitial => 'ca-app-pub-9283129936552011/6388556470';

  // Rewarded
  static String get rewarded => 'ca-app-pub-9283129936552011/8197655108';
}

// ─────────────────────────────────────────────────────────────────────────────
// APP OPEN AD MANAGER
// • App Open Ad  : loaded at startup, shown only on cold launch.
// • Interstitial : pre-loaded at startup, shown on download & Start Quiz.
//                  Reloads itself after every show so it's always ready.
// • Rewarded     : pre-loaded at startup, shown in the generation popup.
//                  Reloads itself after every show.
// ─────────────────────────────────────────────────────────────────────────────
class AppOpenAdManager {
  // ── App Open Ad ─────────────────────────────────────────────────────────
  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenAdLoadTime;

  static const Duration _adExpiry = Duration(hours: 4);

  bool get _isAppOpenAdAvailable =>
      _appOpenAd != null &&
      _appOpenAdLoadTime != null &&
      DateTime.now().difference(_appOpenAdLoadTime!) < _adExpiry;

  // ── Interstitial Ad ─────────────────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _interstitialLoading = false;

  // ── Rewarded Ad ─────────────────────────────────────────────────────────
  RewardedAd? _rewardedAd;
  bool _rewardedLoading = false;

  // ─────────────────────────────────────────────────────────────────────────
  // STARTUP: call once after MobileAds.instance.initialize()
  // Preloads all three ad types so they are ready to show immediately.
  // ─────────────────────────────────────────────────────────────────────────
  void preloadAll() {
    _loadAppOpenAd();
    _loadInterstitial();
    _loadRewarded();
  }

  // ── App Open Ad Loading ──────────────────────────────────────────────────

  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdMob] App Open Ad loaded.');
          _appOpenAd = ad;
          _appOpenAdLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] App Open Ad failed to load: $error');
          _appOpenAd = null;
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Show the App Open Ad on COLD LAUNCH only.
  // Calls [onComplete] immediately if no ad is ready, so the app always
  // continues. After the ad is dismissed, reloads a fresh one.
  // ─────────────────────────────────────────────────────────────────────────
  void showOnLaunch({required VoidCallback onComplete}) {
    if (!_isAppOpenAdAvailable || _isShowingAppOpenAd) {
      debugPrint('[AdMob] No App Open Ad ready — proceeding directly.');
      onComplete();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
        debugPrint('[AdMob] App Open Ad showing on launch.');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] App Open Ad failed to show: $error');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd(); // reload for next launch
        onComplete();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMob] App Open Ad dismissed.');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        _loadAppOpenAd(); // reload for next launch
        onComplete();
      },
    );

    _appOpenAd!.show();
  }

  // ── Interstitial Loading & Showing ───────────────────────────────────────

  void _loadInterstitial() {
    if (_interstitialLoading) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdMob] Interstitial preloaded and ready.');
          _interstitialAd = ad;
          _interstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Interstitial failed to preload: $error');
          _interstitialAd = null;
          _interstitialLoading = false;
          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), _loadInterstitial);
        },
      ),
    );
  }

  /// Shows the pre-loaded interstitial immediately. Reloads after dismiss.
  /// If no ad is ready, calls [onComplete] straight away.
  void loadInterstitialAndShow({required VoidCallback onComplete}) {
    if (_interstitialAd == null) {
      debugPrint('[AdMob] Interstitial not ready yet — proceeding.');
      onComplete();
      _loadInterstitial(); // ensure one is loading
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null; // detach so we can reload immediately
    _loadInterstitial(); // start reloading the next one

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMob] Interstitial dismissed.');
        ad.dispose();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] Interstitial failed to show: $error');
        ad.dispose();
        onComplete();
      },
    );

    ad.show();
  }

  // ── Rewarded Loading & Showing ───────────────────────────────────────────

  void _loadRewarded() {
    if (_rewardedLoading) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdMob] Rewarded Ad preloaded and ready.');
          _rewardedAd = ad;
          _rewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] Rewarded Ad failed to preload: $error');
          _rewardedAd = null;
          _rewardedLoading = false;
          // Retry after 60 seconds
          Future.delayed(const Duration(seconds: 60), _loadRewarded);
        },
      ),
    );
  }

  /// Shows the pre-loaded rewarded ad. Reloads after dismiss.
  /// [onRewarded] fires only when user earns the reward.
  /// [onComplete] fires when the ad is fully dismissed (rewarded or not).
  void loadRewardedAndShow({
    required VoidCallback onComplete,
    VoidCallback? onRewarded,
  }) {
    if (_rewardedAd == null) {
      debugPrint('[AdMob] Rewarded Ad not ready yet — completing without ad.');
      onComplete();
      _loadRewarded(); // ensure one is loading
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null; // detach so we can reload immediately
    _loadRewarded(); // start reloading the next one

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMob] Rewarded Ad dismissed.');
        ad.dispose();
        onComplete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] Rewarded Ad failed to show: $error');
        ad.dispose();
        onComplete();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint(
          '[AdMob] User earned reward: ${reward.amount} ${reward.type}',
        );
        onRewarded?.call();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NOTE: AppOpenAdLifecycleObserver has been intentionally removed.
// The App Open Ad is shown ONLY on cold launch via showOnLaunch().
// It does NOT fire when the user returns from an interstitial or rewarded ad.
// ─────────────────────────────────────────────────────────────────────────────
