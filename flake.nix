{
  description = "Zen Browser";

  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    runtimeLibs = with pkgs;
      [
        libGL
        libGLU
        libevent
        libffi
        libjpeg
        libpng
        libstartup_notification
        libvpx
        libwebp
        stdenv.cc.cc
        fontconfig
        libxkbcommon
        zlib
        freetype
        gtk3
        libxml2
        dbus
        xcb-util-cursor
        alsa-lib
        libpulseaudio
        pango
        atk
        cairo
        gdk-pixbuf
        glib
        udev
        libva
        mesa
        libnotify
        cups
        pciutils
        ffmpeg
        libglvnd
        pipewire
      ]
      ++ (with pkgs.xorg; [
        libxcb
        libX11
        libXcursor
        libXrandr
        libXi
        libXext
        libXcomposite
        libXdamage
        libXfixes
        libXScrnSaver
      ]);
  in {
    packages."${system}" = {
      zen-browser = pkgs.stdenv.mkDerivation {
        pname = "zen-browser";
        version = "1.8t";

        src = builtins.fetchTarball {
          url = "https://github.com/zen-browser/desktop/releases/download/twilight/zen.linux-x86_64.tar.xz";
          sha256 = "1awd9iwg7mrkz18wlnb83pay6i7jx6g0qlqvdiqidzm32bc38ynd";
        };

        desktopSrc = ./.;

        phases = ["installPhase" "fixupPhase"];

        nativeBuildInputs = [pkgs.makeWrapper pkgs.copyDesktopItems pkgs.wrapGAppsHook];

        installPhase = ''
          mkdir $out/
          mkdir -p $out/lib
          cp -r $src/* $out/lib/
          mkdir -p $out/share/applications/
          cp $desktopSrc/zen.desktop $out/share/applications/zen.desktop

          mkdir -p $out/share/icons/hicolor/128x128/apps $out/share/icons/hicolor/64x64/apps $out/share/icons/hicolor/48x48/apps $out/share/icons/hicolor/32x32/apps $out/share/icons/hicolor/16x16/apps
          ln -s $out/lib/browser/chrome/icons/default/default128.png $out/share/icons/hicolor/128x128/apps/zen.png
          ln -s $out/lib/browser/chrome/icons/default/default64.png $out/share/icons/hicolor/64x64/apps/zen.png
          ln -s $out/lib/browser/chrome/icons/default/default48.png $out/share/icons/hicolor/48x48/apps/zen.png
          ln -s $out/lib/browser/chrome/icons/default/default32.png $out/share/icons/hicolor/32x32/apps/zen.png
          ln -s $out/lib/browser/chrome/icons/default/default16.png $out/share/icons/hicolor/16x16/apps/zen.png

          mkdir -p $out/share/fonts
          ln -s $out/lib/fonts/*.ttf $out/share/fonts/

          mkdir -p $out/bin
          ln -s $out/lib/zen $out/bin/zen
          ln -s $out/lib/zen $out/bin/zen-bin
        '';

        fixupPhase = ''
          chmod 755 $out/lib/zen $out/lib/zen-bin $out/lib/glxtest $out/lib/pingsender $out/lib/updater $out/lib/vaapitest
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/lib/zen
          wrapProgram $out/lib/zen --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}" --set MOZ_LEGACY_PROFILES 1 --set MOZ_ALLOW_DOWNGRADE 1 --set MOZ_APP_LAUNCHER zen --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/lib/glxtest
          wrapProgram $out/lib/glxtest --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/lib/updater
          wrapProgram $out/lib/updater --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
          patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/lib/vaapitest
          wrapProgram $out/lib/vaapitest --set LD_LIBRARY_PATH "${pkgs.lib.makeLibraryPath runtimeLibs}"
        '';
      };
      default = self.packages."${system}".zen-browser;
    };
  };
}
