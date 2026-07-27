#import <AudioToolbox/AudioToolbox.h>
#import <UserNotifications/UserNotifications.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;
static BOOL g_alerted = NO;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

%ctor {
    AudioServicesPlaySystemSound(1057);
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge) completionHandler:^(BOOL g, NSError *e) {}];
    NSLog(@"[WNF] tweak loaded v1.0.14");
}

%hook UIApplication
- (void)applicationWillResignActive:(id)application {
    g_resignTime = [[NSDate date] timeIntervalSince1970];
    g_alerted = NO;
    NSLog(@"[WNF] window start");
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    NSLog(@"[WNF] window end");
    %orig;
}
%end

%hook CMessageMgr
- (void)AsyncOnAddMsgForSession:(id)arg1 MsgWrap:(id)arg2 NewMsgArriveNotify:(BOOL)arg3 {
    if (inWindow() && !g_alerted) {
        g_alerted = YES;
        NSLog(@"[WNF] ASYNC ON ADD MSG FOR SESSION HIT! notify=%d", arg3);
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1057);
        UNMutableNotificationContent *c = [[UNMutableNotificationContent alloc] init];
        c.title = @"微信";
        c.body = @"收到新消息";
        c.sound = [UNNotificationSound defaultSound];
        UNNotificationRequest *r = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:c trigger:nil];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:r withCompletionHandler:^(NSError *e) {
            NSLog(@"[WNF] notification posted, error=%@", e);
        }];
    }
    %orig;
}
%end
