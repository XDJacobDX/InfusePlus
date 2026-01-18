// InfusePlus - Minimal iOS 26.2 Compatible Version
// Fixes: transitionDidFinish crash + Premium unlock

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Premium Unlock

@class NSObject; @class AVPlayerViewController; @class UIPresentationController; @class AVAudioSession; @class UIView;
// Ensure required system headers are available for types and properties used by the tweak
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <objc/runtime.h>

// Forward declarations (kept for logos/macros) - actual type info comes from the imports above.
@class NSObject; @class AVPlayerViewController; @class UIPresentationController; @class AVAudioSession; @class UIView;


%hook NSObject

- (BOOL)isPremiumUser {
    return YES;
}

- (BOOL)isPremium {
    return YES;
}

- (BOOL)hasActiveSubscription {
    return YES;
}

- (BOOL)isSubscribed {
    return YES;
}

- (void)showAd {
    // Block ads
}

- (void)presentAd {
    // Block ads
}

- (void)loadAd {
    // Block ads
}

- (BOOL)shouldShowAds {
    return NO;
}

- (BOOL)adsEnabled {
    return NO;
}

%end

#pragma mark - UI Transition Fix (Fixes the Crash)

%hook UIPresentationController

- (void)transitionDidFinish:(BOOL)finished {
    @try {
        if ([self.superclass instancesRespondToSelector:@selector(transitionDidFinish:)]) {
            %orig;
        }
    } @catch (NSException *exception) {
        NSLog(@"[InfusePlus] Safely caught exception: %@", exception);
    }
}

%end

#pragma mark - Video Player Visibility Fix

%hook UIView

- (void)setHidden:(BOOL)hidden {
    NSString *className = NSStringFromClass([self class]);
    if ([className containsString:@"Player"] || 
        [className containsString:@"Video"] ||
        [className containsString:@"AVPlayer"]) {
        %orig(NO);
        return;
    }
    %orig(hidden);
}

%end

#pragma mark - Initialization

%ctor {
    NSLog(@"[InfusePlus] iOS 26.2 Compatible Version Loaded!");
}
