{ stdenv, lib, qt5, makeWrapper, fetchurl, pkgs }:

stdenv.mkDerivation rec {

  name = "master-pdf-editor-${version}";
  version = "5.8.20";

  src = fetchurl {
    url = "https://code-industry.net/public/master-pdf-editor-${version}-qt5.x86_64.deb";
    hash = "sha256-Joidx2Zw3bTa6tZb38MfUN9awwLbOaaHlb3ic3WGeng=";
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    qt5.wrapQtAppsHook
  ];

  sourceRoot = ".";
  unpackCmd = "dpkg-deb -x master-pdf-editor-${version}-qt5.x86_64.deb .";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    
    cp -r root/usr/share root/opt $out/
    
    # fix the path in the desktop file
    substituteInPlace $out/share/applications/masterpdfeditor5.desktop --replace /opt/ $out/opt/

    # symlink the binary to bin
    ln -s $out/opt/master-pdf-editor-5/masterpdfeditor5 $out/bin/masterpdfeditor5

    runHook postInstall
  '';

  preFixup = let 
    # we prepare our library path in the let clause to avoid it become part of the input of mkDerivation
    libPath = lib.makeLibraryPath [
      pkgs.sane-backends # libsane.so.1
      qt5.qtsvg # libQt5Svg.so.5
      qt5.qtbase # libQt5PrintSupport.so.5,libQt5Widgets.so.5,libQt5Gui.so.5,libQt5Network.so.5,libQt5Core.so.5
      qt5.qtwayland
      #pkgs.xorg_sys_opengl # libGL.so.1
      pkgs.libGL
      stdenv.cc.cc.lib # libstdc++.so.6
    ];
  in ''
    patchelf \
     --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
     --set-rpath "${libPath}" \
     $out/opt/master-pdf-editor-5/masterpdfeditor5
  '';

  meta = with lib; {
    description = "Master PDF Editor is straightforward, easy to use application for working with PDF documents equipped with powerful multi-purpose functionality.";
    homepage = "https://code-industry.net/masterpdfeditor/";
    license = licenses.unfree;
    maintainers = [ "kleinsamuel" ];
    platforms = platforms.linux;
  };
}