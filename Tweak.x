#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

%hook UIApplication

- (void)applicationWillResignActive:(id)application {
    g_resignTime = [[NSDate date] timeIntervalSince1970];
    %orig;
}

- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    %orig;
}

%end

%hook AppDelegate

- (void)userNotificationCenter:(id)center
       willPresentNotification:(id)notification
         withCompletionHandler:(void (^)(NSUInteger))completionHandler {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1007);
    }
    %orig;
}

%end
