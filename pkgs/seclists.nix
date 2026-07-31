{ fetchFromGitHub }:
let
  pname = "seclists";
  version = "2026.1";
in
fetchFromGitHub {
  owner = "danielmiessler";
  repo = "SecLists";
  rev = "refs/tags/${version}";
  hash = "sha256-mJgCzp8iKzSWf4Tud5xDpnuY4aNJmnEo/hTcuGTaOWM=";
}
