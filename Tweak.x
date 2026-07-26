#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>
#import <objc/runtime.h>

static NSTimeInterval g_resignTime = 0;

static void playAlert(void) {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1057);
}

%ctor {
    AudioServicesPlaySystemSound(1057);
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

static void (*original_willPresentNotification)(id, SEL, id, id, void (^)(NSUInteger));
static void replacement_willPresentNotification(id self, SEL _cmd, id center, id notif, void (^handler)(NSUInteger)) {
    playAlert();
    if (original_willPresentNotification) {
        original_willPresentNotification(self, _cmd, center, notif, handler);
    }
}

static BOOL g_delegateHooked = NO;

%hook UNUserNotificationCenter
- (void)setDelegate:(id)delegate {
    if (delegate && !g_delegateHooked) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        Method m = class_getInstanceMethod(object_getClass(delegate),
            @selector(userNotificationCenter:willPresentNotification:withCompletionHandler:));
        if (m) {
            original_willPresentNotification = (void (*)(id, SEL, id, id, void (^)(NSUInteger)))method_getImplementation(m);
            method_setImplementation(m, (IMP)replacement_willPresentNotification);
            g_delegateHooked = YES;
            AudioServicesPlaySystemSound(1057);
        }
    }
    %orig;
}
%end
