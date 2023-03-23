# terraform-schemas
All Terraform providers' schemas generated to JSON

To get a schema for a specific provider run this:
```console
nix build github:kranzes/terraform-schemas#<provider-name>
```
If instead you want to get the schemas for all the providers available in nixpkgs run this:
```console
nix build github:kranzes/terraform-schemas#all-schemas
```
Tip:
If you don't want to get the JSON schemas via a `nix build` to avoid IFD you can also get them from the [schemas](https://github.com/Kranzes/terraform-schemas/tree/schemas) branch.
