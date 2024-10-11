locals {
  loki_settings = {
    "loki.enabled"                            = "true"
    "loki.isDefault"                          = "true"
    "loki.url"                                = "http://loki-stack.${module.vars.loki_namespace}:3100/"
    "loki.readinessProbe.httpGet.path"        = "/ready"
    "loki.readinessProbe.httpGet.port"        = "http-metrics"
    "loki.readinessProbe.initialDelaySeconds" = "45"
    "loki.livenessProbe.httpGet.path"         = "/ready"
    "loki.livenessProbe.httpGet.port"         = "http-metrics"
    "loki.livenessProbe.initialDelaySeconds"  = "45"
    "loki.datasource.jsonData"                = "\"{}\""
    "loki.datasource.uid"                     = ""
    "loki.auth_enabled"                       = "false"
    "loki.commonConfig.path_prefix"           = "/var/loki"
    "loki.commonConfig.replication_factor"    = "1"

    # Compactor 설정
    "loki.compactor.apply_retention_interval"      = "1h"
    "loki.compactor.compaction_interval"           = "5m"
    "loki.compactor.retention_delete_worker_count" = "500"
    "loki.compactor.retention_enabled"             = "true"
    "loki.compactor.shared_store"                  = "s3"
    "loki.compactor.working_directory"             = "/data/compactor"

    # Schema config 설정
    "loki.config.schema_config.configs[0].from"         = "2020-05-15"
    "loki.config.schema_config.configs[0].store"        = "boltdb-shipper"
    "loki.config.schema_config.configs[0].object_store" = "s3"
    "loki.config.schema_config.configs[0].schema"       = "v11"
    "loki.config.schema_config.configs[0].index.period" = "24h"
    "loki.config.schema_config.configs[0].index.prefix" = "loki_index_"

    # Storage config
    "loki.config.storage_config.aws.region"                  = module.vars.aws_region
    "loki.config.storage_config.aws.bucketnames"             = local.bucket_name
    "loki.config.storage_config.aws.s3forcepathstyle"        = "false"
    "loki.config.storage_config.boltdb_shipper.shared_store" = "s3"
    "loki.config.storage_config.boltdb_shipper.cache_ttl"    = "24h"

    # ServiceAccount 설정
    "loki.serviceAccount.create"                                     = "true"
    "loki.serviceAccount.name"                                       = "loki-sa"
    "loki.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = aws_iam_role.loki_s3_role.arn

    # Write 및 Read replicas 설정
    "loki.write.replicas" = "2"
    "loki.read.replicas"  = "1"
  }
}
