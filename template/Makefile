# THEOS_DEVICE_IP = 127.0.0.1 -p 2222 # install to device from pc
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

# 0 to treat warnings as errors, 1 otherwise.
IGNORE_WARNINGS = 1

# 0 to compile for rootful jailbreaks, 1 otherwise.
ROOTLESS = 0

ifeq ($(ROOTLESS), 1)
THEOS_PACKAGE_SCHEME = rootless
endif 

MOBILE_THEOS ?= 0
ifeq ($(MOBILE_THEOS), 1)
  SDK_PATH = $(THEOS)/sdks/iPhoneOS11.2.sdk/
  $(info ===> Setting SYSROOT to $(SDK_PATH)...)
  SYSROOT = $(SDK_PATH)
else
  TARGET = iphone:clang:latest:12.0
endif

## Common frameworks ##
PROJ_COMMON_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

## source files ##
KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)
SCLALERTVIEW_SRC = $(wildcard SCLAlertView/*.m)
MENU_SRC = Menu.mm

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FreeFireModMenu

FreeFireModMenu_CFLAGS = -fobjc-arc -w
FreeFireModMenu_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG -w

FreeFireModMenu_FILES = Tweak.xm $(MENU_SRC) $(KITTYMEMORY_SRC) $(SCLALERTVIEW_SRC)
FreeFireModMenu_LIBRARIES += substrate
FreeFireModMenu_FRAMEWORKS = $(PROJ_COMMON_FRAMEWORKS)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 FreeFire || :"
