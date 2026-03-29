{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    kibana.url = "github:NixOS/nixpkgs/a71323f68d4377d12c04a5410e214495ec598d4c";
  };
  outputs = { self, nixpkgs, utils, kibana }: utils.lib.eachDefaultSystem (system:
    let
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      kibana-pkgs = import kibana {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "nodejs-16.20.2"
          ];
        };
        };
    in
    {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          gnumake
          docker-compose
          elasticsearch
          logstash
          nodejs_25
        ] ++ [kibana-pkgs.kibana];
        LS_JAVA_HOME = "${pkgs.jdk11}";
      };
    }
  );
}
