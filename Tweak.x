#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;
static NSUInteger g_baseNotifCount = 0;
static NSTimer *g_pollTimer = nil;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

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
    UNUserNotificationCenter *c = [UNUserNotificationCenter currentNotificationCenter];
    [c getDeliveredNotificationsWithCompletionHandler:^(NSArray *n) {
        g_baseNotifCount = n.count;
    }];
    g_pollTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 repeats:YES block:^(NSTimer *t) {
        [c getDeliveredNotificationsWithCompletionHandler:^(NSArray *n) {
            if (inWindow() && n.count > g_baseNotifCount) {
                playAlert();
                g_baseNotifCount = n.count;
            }
        }];
    }];
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    [g_pollTimer invalidate];
    g_pollTimer = nil;
    %orig;
}
%end

%hook UNUserNotificationCenter
- (void)addNotificationRequest:(UNNotificationRequest *)request withCompletionHandler:(void (^)(NSError *))handler {
    if (inWindow()) playAlert();
    %orig;
}
%end
