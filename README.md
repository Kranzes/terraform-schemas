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
