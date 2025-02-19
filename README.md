# Zen Browser

This is a flake for the Zen browser.

Just add it to your NixOS `flake.nix` or home-manager:

```nix
inputs = {
  zen-browser.url = "github:MarceColl/zen-browser-flake";
  ...
}
```

## Packages

This flake exposes only one package named `zen-browser`

After adding the flake to your inputs, you can install the Zen browser by adding this line to your  `environment.systemPackages`:

```nix
inputs.zen-browser.packages."x86_64-linux".default
```

## 1Password

Zen has to be manually added to the list of browsers that 1Password will communicate with. See [this wiki article](https://nixos.wiki/wiki/1Password) for more information. To enable 1Password integration, you need to add the line `.zen-wrapped` to the file `/etc/1password/custom_allowed_browsers`.
