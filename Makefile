TARGET := iphone:clang:7.0:6.0
INSTALL_TARGET_PROCESSES = Facebook


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FBCrashFix

FBCrashFix_FILES = Tweak.x
FBCrashFix_CFLAGS = -fobjc-arc -Wno-gcc-compat

include $(THEOS_MAKE_PATH)/tweak.mk
CFLAGS = -isystem /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/6.0/include
