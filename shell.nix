with import <nixpkgs> {}; mkShell { 
  nativeBuildInputs = [ 
    fswatch
    hugo
    nodePackages.autoprefixer
    nodePackages.postcss
    nodePackages.postcss-cli
    opam
    pkgconfig 
  ];
}
