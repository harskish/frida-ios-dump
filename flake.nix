{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: 
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ];
    in
    {      
      devShells = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [ "dcraw-9.28.0" ];
          };
        };
        lib = pkgs.lib;
        stdenv = pkgs.stdenv;
        pp = pkgs.python313Packages; # remove .venv after version change
      in
      {
          default = pkgs.mkShell {
            buildInputs = [
              pp.python
              pp.uv
              pp.venvShellHook
              pkgs.apple-sdk_13
              (pkgs.darwinMinVersionHook "12.0")
            ];
            
            venvDir = "./.venv";
            postShellHook = ''
              export LD_LIBRARY_PATH=${lib.makeLibraryPath [stdenv.cc.cc]}
              IPAD=$(ssh ipad "ipconfig getifaddr en0")
              echo $IPAD
              echo "Install with:"
              echo "  uv pip compile requirements.txt | uv pip sync -"
            '';
          };
        }
      );
    };
}