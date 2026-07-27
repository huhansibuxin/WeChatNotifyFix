#import <AudioToolbox/AudioToolbox.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;
static BOOL g_alerted = NO;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

static void playAlert(void) {
    if (g_alerted) return;
    g_alerted = YES;
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(1057);
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

// 核心：新消息到达，含通知开关
%hook CMessageMgr
- (void)AsyncOnAddMsgForSession:(id)arg1 MsgWrap:(id)arg2 NewMsgArriveNotify:(BOOL)arg3 {
    if (inWindow()) playAlert();
    %orig;
}
- (void)MainThreadNotifyToExt:(id)arg1 {
    if (inWindow()) playAlert();
    %orig;
}
- (void)AsyncOnUnReadChange:(id)arg1 {
    if (inWindow()) playAlert();
    %orig;
}
%end
