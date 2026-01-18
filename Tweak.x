// InfusePlus - Fixed for iOS 26.2 & Infuse 8.3.5
// Fixes: transitionDidFinish crash, black screen, premium features

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Premium Features Toggle
static BOOL premiumEnabled = YES;

#pragma mark - Premium Unlock

// Hook 1: Subscription Manager
%hook NSObject

// Generic premium check that works across different class names
- (BOOL)isPremiumUser {
    if (premiumEnabled) {
        return YES;
    }
    return %orig;
}

- (BOOL)isPremium {
    if (premiumEnabled) {
        return YES;
    }
    return %orig;
}

- (BOOL)hasActiveSubscription {
    if (premiumEnabled) {
        return YES;
    }
    return %orig;
}

- (BOOL)isSubscribed {
    if (premiumEnabled) {
        return YES;
    }
    return %orig;
}

%end

#pragma mark - UI Transition Fix (Fixes the Crash)

%hook UIPresentationController

// Safe implementation that checks if method exists before calling
- (void)transitionDidFinish:(BOOL)finished {
    @try {
        // Check if super class has this method
        if ([self.superclass instancesRespondToSelector:@selector(transitionDidFinish:)]) {
            %orig;
        }
    } @catch (NSException *exception) {
        NSLog(@"[InfusePlus] Safely caught exception in transitionDidFinish: %@", exception);
    }
}

%end

#pragma mark - Video Player Fix (Fixes Black Screen)

%hook UIView

// Ensure player views stay visible
- (void)setHidden:(BOOL)hidden {
    // Check if this is a player-related view
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"Player"] || 
        [className containsString:@"Video"] ||
        [className containsString:@"AVPlayer"]) {
        // Force player views to stay visible
        %orig(NO);
        return;
    }
    %orig(hidden);
}

%end

%hook AVPlayerViewController

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    
    // Ensure player is visible and ready
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.view.hidden = NO;
        self.view.alpha = 1.0;
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    // Double-check visibility
    self.view.hidden = NO;
    self.view.alpha = 1.0;
}

%end

#pragma mark - Background Playback

%hook AVAudioSession

- (BOOL)setCategory:(AVAudioSessionCategory)category error:(NSError **)outError {
    // Force background playback category
    return %orig(AVAudioSessionCategoryPlayback, outError);
}

- (BOOL)setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError {
    // Add background audio option
    options |= AVAudioSessionCategoryOptionMixWithOthers;
    return %orig(AVAudioSessionCategoryPlayback, options, outError);
}

%end

#pragma mark - Remove Ads

%hook NSObject

// Generic ad-related method blocking
- (void)showAd {
    // Block ad display
    NSLog(@"[InfusePlus] Blocked showAd");
}

- (void)presentAd {
    // Block ad presentation
    NSLog(@"[InfusePlus] Blocked presentAd");
}

- (void)loadAd {
    // Block ad loading
    NSLog(@"[InfusePlus] Blocked loadAd");
}

- (BOOL)shouldShowAds {
    return NO;
}

- (BOOL)adsEnabled {
    return NO;
}

%end

#pragma mark - Initialization

%ctor {
    NSLog(@"[InfusePlus] Loading iOS 26.2 compatible version...");
    
    // Load user preferences
    NSDictionary *prefs = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"com.infuseplus.prefs"];
    if (prefs) {
        premiumEnabled = [prefs[@"premiumEnabled"] boolValue];
    }
    
    NSLog(@"[InfusePlus] Premium features: %@", premiumEnabled ? @"ENABLED" : @"DISABLED");
    NSLog(@"[InfusePlus] Loaded successfully!");
}
