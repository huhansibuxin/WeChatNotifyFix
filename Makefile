TARGET := iphone:clang:latest:16.0
INSTALL_TARGET_PROCESSES = WeChat
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatNotifyFix
WeChatNotifyFix_FILES = Tweak.x
WeChatNotifyFix_FRAMEWORKS = UIKit AudioToolbox UserNotifications

include $(THEOS_MAKE_PATH)/tweak.mk
