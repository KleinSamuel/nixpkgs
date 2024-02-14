{ lib, buildGoModule, fetchFromGitHub, yt-dlp, ffmpeg, mpv }:

buildGoModule rec {
  pname = "invidtui";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "darkhz";
    repo = "invidtui";
    rev = "refs/tags/v${version}";
    hash = "sha256-/HsoV8HdMffD7dzRblSSBMv7kBPRpxUarM5WZoYVxvQ=";
  };

  vendorHash = "sha256-T/muFaQQp/joOCehNZQc5CWmyGakoRaGAsO2mTOODJA=";

  doCheck = true;

  postPatch = ''
        substituteInPlace cmd/flags.go \
          --replace "\"ffmpeg\"" "\"${lib.getBin ffmpeg}/bin/ffmpeg\"" \
          --replace "\"mpv\"" "\"${lib.getBin mpv}/bin/mpv\"" \
          --replace "\"yt-dlp\"" "\"${lib.getBin yt-dlp}/bin/yt-dlp\""
  '';

  meta = with lib; {
    homepage = "https://darkhz.github.io/invidtui/";
    description = "An invidious TUI client";
    license = licenses.mit;
    maintainers = with maintainers; [ rettetdemdativ ];
    mainProgram = "invidtui";
  };
}
