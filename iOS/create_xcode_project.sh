#!/bin/bash

# HomeDesign AI - Xcode Project Generator
# This script creates a complete Xcode project with all source files

PROJECT_NAME="HomeDesignAI"
PROJECT_DIR="/Users/elianajimenez/HomeDesignAI/iOS"
BUNDLE_ID="com.homedesign.ai"

cd "$PROJECT_DIR"

echo "🎨 Creating Xcode project for $PROJECT_NAME..."

# Create project structure
mkdir -p "${PROJECT_NAME}.xcodeproj"

# Create Assets.xcassets structure
mkdir -p "${PROJECT_NAME}/Assets.xcassets/AppIcon.appiconset"
mkdir -p "${PROJECT_NAME}/Assets.xcassets/AccentColor.colorset"

# Create AppIcon Contents.json
cat > "${PROJECT_NAME}/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create AccentColor
cat > "${PROJECT_NAME}/Assets.xcassets/AccentColor.colorset/Contents.json" << 'EOF'
{
  "colors" : [
    {
      "color" : {
        "color-space" : "srgb",
        "components" : {
          "alpha" : "1.000",
          "blue" : "0x37",
          "green" : "0xAF",
          "red" : "0xD4"
        }
      },
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Assets.xcassets Contents.json
cat > "${PROJECT_NAME}/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Preview Content
mkdir -p "${PROJECT_NAME}/Preview Content/Preview Assets.xcassets"
cat > "${PROJECT_NAME}/Preview Content/Preview Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ Created Assets.xcassets structure"

# Generate unique IDs for project.pbxproj
generate_uuid() {
    uuidgen | tr -d '-' | cut -c1-24
}

# Create project.pbxproj
cat > "${PROJECT_NAME}.xcodeproj/project.pbxproj" << 'PBXPROJ'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		AA0001 /* HomeDesignAIApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0001 /* HomeDesignAIApp.swift */; };
		AA0002 /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0002 /* ContentView.swift */; };
		AA0003 /* DecorStyle.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0003 /* DecorStyle.swift */; };
		AA0004 /* SceneType.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0004 /* SceneType.swift */; };
		AA0005 /* AffiliateProduct.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0005 /* AffiliateProduct.swift */; };
		AA0006 /* GenerateRequest.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0006 /* GenerateRequest.swift */; };
		AA0007 /* GenerateResponse.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0007 /* GenerateResponse.swift */; };
		AA0008 /* APIService.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0008 /* APIService.swift */; };
		AA0009 /* ImageProcessor.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0009 /* ImageProcessor.swift */; };
		AA0010 /* AnalyticsService.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0010 /* AnalyticsService.swift */; };
		AA0011 /* Constants.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0011 /* Constants.swift */; };
		AA0012 /* Extensions.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0012 /* Extensions.swift */; };
		AA0013 /* HomeDesignViewModel.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0013 /* HomeDesignViewModel.swift */; };
		AA0014 /* WelcomeView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0014 /* WelcomeView.swift */; };
		AA0015 /* UploadPhotoView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0015 /* UploadPhotoView.swift */; };
		AA0016 /* SceneSelectionView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0016 /* SceneSelectionView.swift */; };
		AA0017 /* StyleSelectionView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0017 /* StyleSelectionView.swift */; };
		AA0018 /* GeneratingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0018 /* GeneratingView.swift */; };
		AA0019 /* ResultView.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0019 /* ResultView.swift */; };
		AA0020 /* BeforeAfterSlider.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0020 /* BeforeAfterSlider.swift */; };
		AA0021 /* ProductCard.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0021 /* ProductCard.swift */; };
		AA0022 /* StylePresetCard.swift in Sources */ = {isa = PBXBuildFile; fileRef = BB0022 /* StylePresetCard.swift */; };
		AA0023 /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = BB0023 /* Assets.xcassets */; };
		AA0024 /* Preview Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = BB0024 /* Preview Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		CC0001 /* HomeDesignAI.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = HomeDesignAI.app; sourceTree = BUILT_PRODUCTS_DIR; };
		BB0001 /* HomeDesignAIApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeDesignAIApp.swift; sourceTree = "<group>"; };
		BB0002 /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		BB0003 /* DecorStyle.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DecorStyle.swift; sourceTree = "<group>"; };
		BB0004 /* SceneType.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SceneType.swift; sourceTree = "<group>"; };
		BB0005 /* AffiliateProduct.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AffiliateProduct.swift; sourceTree = "<group>"; };
		BB0006 /* GenerateRequest.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GenerateRequest.swift; sourceTree = "<group>"; };
		BB0007 /* GenerateResponse.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GenerateResponse.swift; sourceTree = "<group>"; };
		BB0008 /* APIService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = APIService.swift; sourceTree = "<group>"; };
		BB0009 /* ImageProcessor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ImageProcessor.swift; sourceTree = "<group>"; };
		BB0010 /* AnalyticsService.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AnalyticsService.swift; sourceTree = "<group>"; };
		BB0011 /* Constants.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Constants.swift; sourceTree = "<group>"; };
		BB0012 /* Extensions.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Extensions.swift; sourceTree = "<group>"; };
		BB0013 /* HomeDesignViewModel.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = HomeDesignViewModel.swift; sourceTree = "<group>"; };
		BB0014 /* WelcomeView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = WelcomeView.swift; sourceTree = "<group>"; };
		BB0015 /* UploadPhotoView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = UploadPhotoView.swift; sourceTree = "<group>"; };
		BB0016 /* SceneSelectionView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SceneSelectionView.swift; sourceTree = "<group>"; };
		BB0017 /* StyleSelectionView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StyleSelectionView.swift; sourceTree = "<group>"; };
		BB0018 /* GeneratingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GeneratingView.swift; sourceTree = "<group>"; };
		BB0019 /* ResultView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ResultView.swift; sourceTree = "<group>"; };
		BB0020 /* BeforeAfterSlider.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BeforeAfterSlider.swift; sourceTree = "<group>"; };
		BB0021 /* ProductCard.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ProductCard.swift; sourceTree = "<group>"; };
		BB0022 /* StylePresetCard.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = StylePresetCard.swift; sourceTree = "<group>"; };
		BB0023 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		BB0024 /* Preview Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "Preview Assets.xcassets"; sourceTree = "<group>"; };
		BB0025 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		DD0001 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		EE0001 = {
			isa = PBXGroup;
			children = (
				EE0002 /* HomeDesignAI */,
				EE0003 /* Products */,
			);
			sourceTree = "<group>";
		};
		EE0002 /* HomeDesignAI */ = {
			isa = PBXGroup;
			children = (
				BB0025 /* Info.plist */,
				EE0010 /* App */,
				EE0011 /* Models */,
				EE0012 /* Views */,
				EE0013 /* ViewModels */,
				EE0014 /* Services */,
				EE0015 /* Utilities */,
				EE0016 /* Resources */,
				EE0017 /* Preview Content */,
			);
			path = HomeDesignAI;
			sourceTree = "<group>";
		};
		EE0003 /* Products */ = {
			isa = PBXGroup;
			children = (
				CC0001 /* HomeDesignAI.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		EE0010 /* App */ = {
			isa = PBXGroup;
			children = (
				BB0001 /* HomeDesignAIApp.swift */,
				BB0002 /* ContentView.swift */,
			);
			path = App;
			sourceTree = "<group>";
		};
		EE0011 /* Models */ = {
			isa = PBXGroup;
			children = (
				BB0003 /* DecorStyle.swift */,
				BB0004 /* SceneType.swift */,
				BB0005 /* AffiliateProduct.swift */,
				BB0006 /* GenerateRequest.swift */,
				BB0007 /* GenerateResponse.swift */,
			);
			path = Models;
			sourceTree = "<group>";
		};
		EE0012 /* Views */ = {
			isa = PBXGroup;
			children = (
				BB0014 /* WelcomeView.swift */,
				BB0015 /* UploadPhotoView.swift */,
				BB0016 /* SceneSelectionView.swift */,
				BB0017 /* StyleSelectionView.swift */,
				BB0018 /* GeneratingView.swift */,
				BB0019 /* ResultView.swift */,
				EE0018 /* Components */,
			);
			path = Views;
			sourceTree = "<group>";
		};
		EE0013 /* ViewModels */ = {
			isa = PBXGroup;
			children = (
				BB0013 /* HomeDesignViewModel.swift */,
			);
			path = ViewModels;
			sourceTree = "<group>";
		};
		EE0014 /* Services */ = {
			isa = PBXGroup;
			children = (
				BB0008 /* APIService.swift */,
				BB0009 /* ImageProcessor.swift */,
				BB0010 /* AnalyticsService.swift */,
			);
			path = Services;
			sourceTree = "<group>";
		};
		EE0015 /* Utilities */ = {
			isa = PBXGroup;
			children = (
				BB0011 /* Constants.swift */,
				BB0012 /* Extensions.swift */,
			);
			path = Utilities;
			sourceTree = "<group>";
		};
		EE0016 /* Resources */ = {
			isa = PBXGroup;
			children = (
				BB0023 /* Assets.xcassets */,
			);
			path = Resources;
			sourceTree = "<group>";
		};
		EE0017 /* Preview Content */ = {
			isa = PBXGroup;
			children = (
				BB0024 /* Preview Assets.xcassets */,
			);
			path = "Preview Content";
			sourceTree = "<group>";
		};
		EE0018 /* Components */ = {
			isa = PBXGroup;
			children = (
				BB0020 /* BeforeAfterSlider.swift */,
				BB0021 /* ProductCard.swift */,
				BB0022 /* StylePresetCard.swift */,
			);
			path = Components;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		FF0001 /* HomeDesignAI */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = FF0002 /* Build configuration list for PBXNativeTarget "HomeDesignAI" */;
			buildPhases = (
				FF0003 /* Sources */,
				DD0001 /* Frameworks */,
				FF0004 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = HomeDesignAI;
			productName = HomeDesignAI;
			productReference = CC0001 /* HomeDesignAI.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		GG0001 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					FF0001 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = GG0002 /* Build configuration list for PBXProject "HomeDesignAI" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = EE0001;
			productRefGroup = EE0003 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				FF0001 /* HomeDesignAI */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		FF0004 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AA0024 /* Preview Assets.xcassets in Resources */,
				AA0023 /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		FF0003 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				AA0001 /* HomeDesignAIApp.swift in Sources */,
				AA0002 /* ContentView.swift in Sources */,
				AA0003 /* DecorStyle.swift in Sources */,
				AA0004 /* SceneType.swift in Sources */,
				AA0005 /* AffiliateProduct.swift in Sources */,
				AA0006 /* GenerateRequest.swift in Sources */,
				AA0007 /* GenerateResponse.swift in Sources */,
				AA0008 /* APIService.swift in Sources */,
				AA0009 /* ImageProcessor.swift in Sources */,
				AA0010 /* AnalyticsService.swift in Sources */,
				AA0011 /* Constants.swift in Sources */,
				AA0012 /* Extensions.swift in Sources */,
				AA0013 /* HomeDesignViewModel.swift in Sources */,
				AA0014 /* WelcomeView.swift in Sources */,
				AA0015 /* UploadPhotoView.swift in Sources */,
				AA0016 /* SceneSelectionView.swift in Sources */,
				AA0017 /* StyleSelectionView.swift in Sources */,
				AA0018 /* GeneratingView.swift in Sources */,
				AA0019 /* ResultView.swift in Sources */,
				AA0020 /* BeforeAfterSlider.swift in Sources */,
				AA0021 /* ProductCard.swift in Sources */,
				AA0022 /* StylePresetCard.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		HH0001 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		HH0002 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		HH0003 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"HomeDesignAI/Preview Content\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = HomeDesignAI/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.homedesign.ai;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		HH0004 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "\"HomeDesignAI/Preview Content\"";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = HomeDesignAI/Info.plist;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.homedesign.ai;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		GG0002 /* Build configuration list for PBXProject "HomeDesignAI" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				HH0001 /* Debug */,
				HH0002 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		FF0002 /* Build configuration list for PBXNativeTarget "HomeDesignAI" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				HH0003 /* Debug */,
				HH0004 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = GG0001 /* Project object */;
}
PBXPROJ

echo "✅ Created project.pbxproj"

# Move Resources folder if needed
if [ ! -d "${PROJECT_NAME}/Resources" ]; then
    mkdir -p "${PROJECT_NAME}/Resources"
    mv "${PROJECT_NAME}/Assets.xcassets" "${PROJECT_NAME}/Resources/" 2>/dev/null || true
fi

echo ""
echo "✅ Xcode project created successfully!"
echo ""
echo "📂 Project location: ${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"
echo ""
echo "🎯 Next steps:"
echo "   1. Open the project:"
echo "      open ${PROJECT_NAME}.xcodeproj"
echo ""
echo "   2. Make sure backend is running:"
echo "      cd ../Backend && npm start"
echo ""
echo "   3. Build and run (Cmd+R) in Xcode"
echo ""
echo "🎄 Happy coding!"
