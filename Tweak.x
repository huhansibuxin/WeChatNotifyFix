#import <AudioToolbox/AudioToolbox.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

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
    %orig;
}
- (void)applicationDidEnterBackground:(id)application {
    g_resignTime = 0;
    %orig;
}
%end

// ---- 微信新消息内部方法 ----
%hook CMessageMgr
- (void)newMessageByContact:(id)contact msgWrapToAdd:(id)msgWrap animated:(BOOL)animated {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook CContactMgr
- (void)newMessageByContact:(id)contact msgWrapToAdd:(id)msgWrap animated:(BOOL)animated {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook MessageMgr
- (void)newMessageByContact:(id)contact msgWrapToAdd:(id)msgWrap animated:(BOOL)animated {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook MMMessageMgr
- (void)newMessageByContact:(id)contact msgWrapToAdd:(id)msgWrap animated:(BOOL)animated {
    if (inWindow()) playAlert();
    %orig;
}
%end

%hook WCNewMessageMgr
- (void)newMessageByContact:(id)contact msgWrapToAdd:(id)msgWrap animated:(BOOL)animated {
    if (inWindow()) playAlert();
    %orig;
}
%end
