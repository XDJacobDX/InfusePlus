TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = InfusePlus

InfusePlus_FILES = Tweak.x
InfusePlus_CFLAGS = -fobjc-arc
InfusePlus_FRAMEWORKS = UIKit Foundation AVFoundation AVKit
InfusePlus_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS_MAKE_PATH)/tweak.mk
