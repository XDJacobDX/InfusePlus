#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

%hook UIPresentationController
- (void)transitionDidFinish:(BOOL)finished {
    @try {
        %orig(finished);
    } @catch (NSException *e) {
        NSLog(@"[InfusePlus] Caught exception in transitionDidFinish: %@", e);
    }
}
%end

%hook AVPlayerViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig(animated);
    @try {
        if (self.view) {
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

%ctor { NSLog(@"[InfusePlus] Safe minimal tweak loaded."); }
