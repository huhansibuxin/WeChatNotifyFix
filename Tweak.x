#import <AudioToolbox/AudioToolbox.h>
#import <substrate.h>

static NSTimeInterval g_resignTime = 0;
static const NSTimeInterval kWindowDuration = 6.0;

static BOOL inWindow(void) {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    return (g_resignTime > 0 && (now - g_resignTime) < kWindowDuration);
}

// ---- Hook C functions ----
static void (*original_PlaySystemSound)(SystemSoundID);
static void replacement_PlaySystemSound(SystemSoundID soundID) {
    if (inWindow()) soundID = 1057;
    original_PlaySystemSound(soundID);
}

static void (*original_PlayAlertSound)(SystemSoundID);
static void replacement_PlayAlertSound(SystemSoundID soundID) {
    original_PlayAlertSound(soundID);  // vibrate pass-through
}

%ctor {
    MSHookFunction((void *)AudioServicesPlaySystemSound,
                   (void *)replacement_PlaySystemSound,
                   (void **)&original_PlaySystemSound);
    MSHookFunction((void *)AudioServicesPlayAlertSound,
                   (void *)replacement_PlayAlertSound,
                   (void **)&original_PlayAlertSound);
}

// ---- State tracking ----
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
