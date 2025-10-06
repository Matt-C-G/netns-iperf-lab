{
  description = "netns-iperf-lab dev shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with pkgs; [ iperf3 jq python3Full python3Packages.matplotlib bpftrace shellcheck ];
      };
    };
}
