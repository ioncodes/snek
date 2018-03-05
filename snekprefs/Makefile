include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = snekprefs
snekprefs_FILES = XXXRootListController.m
snekprefs_INSTALL_PATH = /Library/PreferenceBundles
snekprefs_FRAMEWORKS = UIKit
snekprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/snekprefs.plist$(ECHO_END)
