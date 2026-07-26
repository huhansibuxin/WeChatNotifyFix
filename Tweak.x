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

// ---- 鐘舵€佹崟鑾?----
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

// ---- 閫氱煡鎷︽埅閫昏緫锛堝鐢ㄥ埌澶氫釜绫诲悕锛?---
%group NotifyHook
- (void)userNotificationCenter:(id)center
       willPresentNotification:(id)notif
         withCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
- (void)application:(id)app
didReceiveRemoteNotification:(id)userInfo
fetchCompletionHandler:(void (^)(NSUInteger))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end

// ---- 鍙兘绫诲悕鍏ㄨ鐩?----
%hook AppDelegate
%group NotifyHook
%end

%hook MicroMessengerAppDelegate
%group NotifyHook
%end

%hook WAAppDelegate
%group NotifyHook
%end

%hook MMAppDelegate
%group NotifyHook
%end

%hook WeChatAppDelegate
%group NotifyHook
%end

%hook WXAppDelegate
%group NotifyHook
%end
