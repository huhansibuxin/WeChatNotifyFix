#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;
static NSInteger g_lastBadge = 0;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

static void playAlert(void) {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1057);
}

%ctor {
    g_lastBadge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    AudioServicesPlaySystemSound(1057);
}

%hook UIApplication
- (void)applicationWillResignActive:(id)application {
    g_resignTime = [[NSDate date] timeIntervalSince1970];
    g_lastBadge = self.applicationIconBadgeNumber;  // 窗口开始时记录角标基准
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    %orig;
}
- (void)setApplicationIconBadgeNumber:(NSInteger)badgeNumber {
    if (inWindow() && badgeNumber > g_lastBadge) {
        playAlert();
        g_lastBadge = badgeNumber;
    }
    %orig;
}
%end
