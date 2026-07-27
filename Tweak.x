#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

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
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    %orig;
}
%end

%hook CMessageMgr
// 每个方法触发时设不同角标，一眼看出哪个命中了
- (void)AsyncOnAddMsgForSession:(id)arg1 MsgWrap:(id)arg2 NewMsgArriveNotify:(BOOL)arg3 {
    if (inWindow()) [UIApplication sharedApplication].applicationIconBadgeNumber = 777;
    %orig;
}
- (void)AsyncOnAddMsg:(id)arg1 MsgWrap:(id)arg2 {
    if (inWindow()) [UIApplication sharedApplication].applicationIconBadgeNumber = 666;
    %orig;
}
- (void)AddMsg:(id)arg1 MsgWrap:(id)arg2 {
    if (inWindow()) [UIApplication sharedApplication].applicationIconBadgeNumber = 555;
    %orig;
}
- (void)AsyncOnPreAddMsg:(id)arg1 MsgWrap:(id)arg2 {
    if (inWindow()) [UIApplication sharedApplication].applicationIconBadgeNumber = 444;
    %orig;
}
- (void)MainThreadNotifyToExt:(id)arg1 {
    if (inWindow()) [UIApplication sharedApplication].applicationIconBadgeNumber = 333;
    %orig;
}
- (void)AsyncOnUnReadChange:(id)arg1 {
    if (inWindow()) [UIApplication sharedApplication].applicationIconBadgeNumber = 222;
    %orig;
}
%end
