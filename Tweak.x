#import <UserNotifications/UserNotifications.h>
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
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL g, NSError *e) {}];
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
        UNMutableNotificationContent *c = [[UNMutableNotificationContent alloc] init];
        c.title = @"微信";
        c.body = @"收到新消息";
        c.sound = [UNNotificationSound defaultSound];
        // 用定时触发器替代即时通知，系统预注册不受 Inactive 状态限制
        UNTimeIntervalNotificationTrigger *t = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1.0 repeats:NO];
        UNNotificationRequest *r = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:c trigger:t];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:r withCompletionHandler:^(NSError *e) {}];
    }
    %orig;
}
%end
