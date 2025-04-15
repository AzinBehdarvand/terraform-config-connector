package validate.gcp.storage

deny[msg] if {
  input.kind.kind == "StorageBucket"
  not input.spec.location
  msg := "Bucket location must be set"
}

deny[msg] if {
  input.kind.kind == "StorageBucket"
  input.spec.location != "EU"
  msg := "Bucket location must be 'EU'"
}
