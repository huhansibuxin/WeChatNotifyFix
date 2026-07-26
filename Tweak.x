#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

static void playAlert(void) {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1057);
}

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

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

%hook MicroMessengerAppDelegate
- (void)userNotificationCenter:(id)center willPresentNotification:(id)notif withCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
- (void)application:(id)app didReceiveRemoteNotification:(id)userInfo fetchCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook MMAppDelegate
- (void)userNotificationCenter:(id)center willPresentNotification:(id)notif withCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
- (void)application:(id)app didReceiveRemoteNotification:(id)userInfo fetchCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook AppDelegate
- (void)userNotificationCenter:(id)center willPresentNotification:(id)notif withCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
- (void)application:(id)app didReceiveRemoteNotification:(id)userInfo fetchCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook WAAppDelegate
- (void)userNotificationCenter:(id)center willPresentNotification:(id)notif withCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
- (void)application:(id)app didReceiveRemoteNotification:(id)userInfo fetchCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook WeChatAppDelegate
- (void)userNotificationCenter:(id)center willPresentNotification:(id)notif withCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
- (void)application:(id)app didReceiveRemoteNotification:(id)userInfo fetchCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end
