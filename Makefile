include $(THEOS)/makefiles/common.mk

TWEAK_NAME = snek
snek_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += snekprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
