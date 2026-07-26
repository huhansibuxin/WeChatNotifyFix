#include <AudioToolbox/AudioToolbox.h>
#include <substrate.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

static void (*orig_PlaySystemSound)(SystemSoundID);
static void repl_PlaySystemSound(SystemSoundID soundID) {
    if (inWindow()) soundID = 1057;
    orig_PlaySystemSound(soundID);
}

static void (*orig_PlayAlertSound)(SystemSoundID);
static void repl_PlayAlertSound(SystemSoundID soundID) {
    orig_PlayAlertSound(soundID);
}

%ctor {
    AudioServicesPlaySystemSound(1057);
    MSHookFunction((void *)AudioServicesPlaySystemSound, (void *)repl_PlaySystemSound, (void **)&orig_PlaySystemSound);
    MSHookFunction((void *)AudioServicesPlayAlertSound, (void *)repl_PlayAlertSound, (void **)&orig_PlayAlertSound);
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
