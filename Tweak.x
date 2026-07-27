#import <AudioToolbox/AudioToolbox.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

%ctor {
    AudioServicesPlaySystemSound(1057);
    NSLog(@"[WNF] tweak loaded");
}

%hook UIApplication
- (void)applicationWillResignActive:(id)application {
    g_resignTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"[WNF] window start at %f", g_resignTime);
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    NSLog(@"[WNF] window end");
    %orig;
}
%end

// 诊断：窗口期内收到任何 NSNotification 就打印
%hook NSNotificationCenter
- (void)postNotification:(NSNotification *)notification {
    if (inWindow()) {
        NSLog(@"[WNF] NSNotification: %@ | object: %@ | userInfo: %@",
              notification.name, notification.object, notification.userInfo);
    }
    %orig;
}
- (void)postNotificationName:(NSString *)name object:(id)object {
    if (inWindow()) {
        NSLog(@"[WNF] NSNotification: %@ | object: %@", name, object);
    }
    %orig;
}
- (void)postNotificationName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo {
    if (inWindow()) {
        NSLog(@"[WNF] NSNotification: %@ | object: %@ | userInfo: %@", name, object, userInfo);
    }
    %orig;
}
%end
