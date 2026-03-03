# Makefile for SwiftUI_Mod_Menu
TWEAK_NAME = SwiftUI_Mod_Menu
TARGET := iphone:clang:15.5:15.5
ARCHS = arm64e
THEOS_PACKAGE_SCHEME = rootless
THEOS_DEVICE_IP=192.168.10.4

# Project-specific sources / プロジェクト固有ソース
$(TWEAK_NAME)_FILES = \
	src/main.xm \
	src/Main.swift
$(TWEAK_NAME)_CFLAGS += -I$(PWD)/headers
$(TWEAK_NAME)_OBJ_FILES += libs/libdobby.a
# $(TWEAK_NAME)_LDFLAGS += -Wl,-sectcreate,__DATA,__myfont,$(PWD)/resources/myfont.ttf

# Core build settings / 基本ビルド設定
$(TWEAK_NAME)_EXPORTED_SYMBOLS = YES
$(TWEAK_NAME)_SWIFT_MODULES = YES
$(TWEAK_NAME)_USE_SWIFT = 1
$(TWEAK_NAME)_SWIFT_OBJC_BRIDGING_HEADER = $(PWD)/SwiftUI_Mod_Menu-Bridging-Header.h
$(TWEAK_NAME)_CFLAGS += -I$(PWD)/libs/internal_do_not_delete/c/wkbridge
$(TWEAK_NAME)_FRAMEWORKS += UIKit Foundation SwiftUI IOKit
$(TWEAK_NAME)_FILES += \
	libs/internal_do_not_delete/main.mm \
	libs/internal_do_not_delete/c/wkbridge/wk_settings_bridge.xm \
	libs/internal_do_not_delete/swift/windowkit/WKFloatingButton.swift \
	libs/internal_do_not_delete/swift/windowkit/WKStack.swift \
	libs/internal_do_not_delete/swift/windowkit/WKControls.swift \
	libs/internal_do_not_delete/swift/windowkit/WKText.swift \
	libs/internal_do_not_delete/swift/windowkit/WKSettingsStore.swift \
	libs/internal_do_not_delete/swift/windowkit/WKFloatingOverlay.swift \
	libs/internal_do_not_delete/swift/windowkit/WKTheme.swift \
	libs/internal_do_not_delete/swift/windowkit/WKFloatingWindow.swift \
	libs/internal_do_not_delete/swift/windowkit/PassThroughView.swift \
	libs/internal_do_not_delete/swift/windowkit/ResizeHandle.swift \
	libs/internal_do_not_delete/swift/windowkit/WKPersistence.swift \
	libs/internal_do_not_delete/swift/Loader.swift

# Theos includes / Theos 共通設定
include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

# Extract dylib from built deb / 生成debからdylib抽出
extract-dylib:
	@if [ -f .theos/last_package ]; then \
		DEB_FILE=$$(cat .theos/last_package); \
		DEB_ABS=$$(cd $$(dirname $$DEB_FILE) && pwd)/$$(basename $$DEB_FILE); \
		PROJECT_ROOT=$$(pwd); \
		echo "Extracting dylib from $$DEB_FILE"; \
		TEMP_DIR=$$(mktemp -d); \
		EXTRACT_DIR=$$(mktemp -d); \
		cd $$TEMP_DIR; \
		ar x $$DEB_ABS; \
		if [ -f data.tar.xz ]; then \
			if command -v xz >/dev/null 2>&1; then \
				xz -dc data.tar.xz | tar -xf - -C $$EXTRACT_DIR; \
			elif command -v unxz >/dev/null 2>&1; then \
				unxz -c data.tar.xz | tar -xf - -C $$EXTRACT_DIR; \
			else \
				echo "Error: xz or unxz command not found. Please install xz."; \
				rm -rf $$TEMP_DIR $$EXTRACT_DIR; \
				exit 1; \
			fi; \
		elif [ -f data.tar.lzma ]; then \
			if command -v xz >/dev/null 2>&1; then \
				xz -dc data.tar.lzma | tar -xf - -C $$EXTRACT_DIR; \
			elif command -v unlzma >/dev/null 2>&1; then \
				unlzma -c data.tar.lzma | tar -xf - -C $$EXTRACT_DIR; \
			elif command -v lzma >/dev/null 2>&1; then \
				lzma -dc data.tar.lzma | tar -xf - -C $$EXTRACT_DIR; \
			else \
				echo "Error: xz, unlzma, or lzma command not found. Please install xz."; \
				rm -rf $$TEMP_DIR $$EXTRACT_DIR; \
				exit 1; \
			fi; \
		elif [ -f data.tar.gz ]; then \
			tar -xzf data.tar.gz -C $$EXTRACT_DIR; \
		elif [ -f data.tar ]; then \
			tar -xf data.tar -C $$EXTRACT_DIR; \
		else \
			echo "Error: data.tar not found in deb package"; \
			ls -la $$TEMP_DIR; \
			rm -rf $$TEMP_DIR $$EXTRACT_DIR; \
			exit 1; \
		fi; \
		if [ -f $$EXTRACT_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib ]; then \
			cp $$EXTRACT_DIR/var/jb/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib $$PROJECT_ROOT/$(TWEAK_NAME).dylib; \
			echo "Extracted: $$PROJECT_ROOT/$(TWEAK_NAME).dylib (rootless)"; \
		elif [ -f $$EXTRACT_DIR/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib ]; then \
			cp $$EXTRACT_DIR/Library/MobileSubstrate/DynamicLibraries/$(TWEAK_NAME).dylib $$PROJECT_ROOT/$(TWEAK_NAME).dylib; \
			echo "Extracted: $$PROJECT_ROOT/$(TWEAK_NAME).dylib (rootful)"; \
		else \
			echo "Error: dylib not found in deb package"; \
			find $$EXTRACT_DIR -name "*.dylib" -type f; \
			rm -rf $$TEMP_DIR $$EXTRACT_DIR; \
			exit 1; \
		fi; \
		rm -rf $$TEMP_DIR $$EXTRACT_DIR; \
	else \
		echo "Error: .theos/last_package not found. Please run 'make package' first."; \
		exit 1; \
	fi

# Run extraction after packaging / package後に抽出
after-package::
	@$(MAKE) extract-dylib
