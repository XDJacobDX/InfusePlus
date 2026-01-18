// Tweak.x — safe/minimal (reduces global hooking risk)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <objc/runtime.h>

%hook UIPresentationController
// Protect transitionDidFinish: with try/catch to avoid exceptions in newer iOS versions
- (void)transitionDidFinish:(BOOL)finished {
    @try {
        %orig(finished);
    } @catch (NSException *e) {
        NSLog(@"[InfusePlus] Caught exception in transitionDidFinish: %@", e);
    }
}
%end

// Ensure player view is visible when the AVPlayerViewController appears
%hook AVPlayerViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    @try {
        if (self.view) {
            // only modify the player view — be conservative
            self.view.hidden = NO;
            self.view.alpha = 1.0;
            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        }
    } @catch (NSException *e) {
        NSLog(@"[InfusePlus] Exception while ensuring AVPlayerViewController view visible: %@", e);
    }
}

%end

// Minimal constructor for logging
%ctor {
    @autoreleasepool {
        NSLog(@"[InfusePlus] Safe minimal tweak loaded.");
    }
}
