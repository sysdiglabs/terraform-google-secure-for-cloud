#!/usr/bin/env bash
go install github.com/hashicorp/terraform-config-inspect@latest
terraform-config-inspect --json ./examples/organization | jq -r '
  [.required_providers[].aliases]
  | flatten
  | del(.[] | select(. == null))
  | reduce .[] as $entry (
    {};
    .provider[$entry.name] //= [] | .provider[$entry.name] += [{"alias": $entry.alias}]
  )
' | tee ./examples/organization/aliased-providers.tf.json
