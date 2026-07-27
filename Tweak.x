#import <AudioToolbox/AudioToolbox.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;
static BOOL g_alerted = NO;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

%ctor {
    AudioServicesPlaySystemSound(1057);
}

%hook UIApplication
- (void)applicationWillResignActive:(id)application {
    g_resignTime = [[NSDate date] timeIntervalSince1970];
    g_alerted = NO;
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    %orig;
}
%end

%hook MMBadgeView
- (void)setValue:(NSUInteger)value {
    if (inWindow() && value > 0 && !g_alerted) {
        g_alerted = YES;
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1057);
    }
    %orig;
}
%end
