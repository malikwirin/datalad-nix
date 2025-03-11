# Datalad-Nix
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL_v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
This Project provides Datalad related packages, an overlay, and soon modules for the use of Datalad with Nix and on NixOS.
## Usage
### With flake
#### Add Input
``` nix
inputs = {
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";  
  datalad-nix = {
    url = "git+https://codeberg.org/malik/datalad-nix.git";
    inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
  };
};
```
#### Overlay
Now add the overlay to your lists of overlays.
``` nix
nixpkgs.overlays = [
  datalad-nix.overlay.default
];
```
The additional packages should now be available under `pkgs`.

## Contributing
Please read the [contributing guidelines](CONTRIBUTING.md) before contributing.
PRs and issues are always welcome. Needed tasks can be found in the [Agenda](./org/agenda), for example [adding additional modules](./org/agenda/modules/index.md).
