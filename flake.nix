{
  description = "An example project using flutter";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-compat = {
    url = "github:edolstra/flake-compat";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };
      in
      {
        devShells.default =
          let android = pkgs.androidenv.composeAndroidPackages {
            toolsVersion = "26.1.1";
            platformToolsVersion = "33.0.3";
            buildToolsVersions = [ "30.0.3" ];
            includeEmulator = false;
            emulatorVersion = "30.3.4";
            platformVersions = [ "28" "29" "30" "31" ];
            includeSources = false;
            includeSystemImages = false;
            systemImageTypes = [ "google_apis_playstore" ];
            abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
            cmakeVersions = [ "3.10.2" ];
            includeNDK = true;
            ndkVersions = [ "22.0.7026061" ];
            useGoogleAPIs = false;
            useGoogleTVAddOns = false;
          };
          in
          pkgs.mkShell {
            buildInputs = [
              pkgs.flutter
              pkgs.jdk11
              android.androidsdk # adds `emulator` to path
              android.platform-tools
            ];

            ANDROID_HOME = "${android.androidsdk}/libexec/android-sdk";
            JAVA_HOME = pkgs.jdk11;
            ANDROID_AVD_HOME = (toString ./.) + "/.android/avd";
          };
      });
}
