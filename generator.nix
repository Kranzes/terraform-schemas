providers:
{ lib, runCommand, formats, terraform }:
let
  required_providers = providers: lib.mapAttrs
    (_: p: {
      inherit (p) version;
      source = lib.toLower p.provider-source-address;
    })
    providers;

  retrieveProviderSchema = name: provider:
    let
      mainJson = (formats.json { }).generate "main.tf.json" {
        terraform.required_providers = required_providers { "${name}" = provider; };
      };

      terraform-with-plugins = terraform.withPlugins (_: [ provider ]);
    in
    runCommand "${name}.json" { } ''
      cp ${mainJson} main.tf.json
      ${terraform-with-plugins}/bin/terraform init
      ${terraform-with-plugins}/bin/terraform providers schema -json >$out
    '';
in
runCommand "schemas" { } ''
  mkdir "$out"
  ${lib.concatLines (lib.mapAttrsToList (name: provider: 
  "ln -s ${retrieveProviderSchema name provider} $out/${name}.json") 
  providers)}
''
