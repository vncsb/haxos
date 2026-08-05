{ 
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonApplication (finalAttrs : rec {
  pname = "dirsearch";
  version = "0.4.3";
  pyproject = true;
  doCheck = true;

  src = fetchFromGitHub {
    owner = "maurosoria";
    repo = pname;
    rev = "refs/tags/v${version}";
    sha256 = "sha256-eXB103qUB3m7V/9hlq2xv3Y3bIz89/pGJsbPZQ+AZXs=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    chardet
    pysocks
    jinja2
    certifi
    defusedxml
    markupsafe
    pyopenssl
    charset-normalizer
    requests
    requests-ntlm
    colorama
    pyparsing
    beautifulsoup4
    mysql-connector
    psycopg
    requests-toolbelt
  ];

  pythonRelaxDeps = true;

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace "ntlm_auth>=1.5.0" ""
  '';
})
