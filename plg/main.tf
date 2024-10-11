module "vars" {
  source = "../vars"
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "62.6.0"
  namespace        = "monitoring"
  create_namespace = true
  values           = [file("./values/prometheus.yaml")]

  dynamic "set" {
    for_each = local.prometheus_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  lower   = true
  numeric = true
}

locals {
  bucket_name = "loki-bucket-${random_string.random.result}"
}

resource "aws_s3_bucket" "loki_bucket" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "helm_release" "loki_stack" {
  name             = "loki-stack"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  version          = "2.10.2"
  namespace        = module.vars.loki_namespace
  create_namespace = true
  values           = [file("./values/loki.yaml")]

  dynamic "set" {
    for_each = local.loki_settings
    content {
      name  = set.key
      value = set.value
    }
  }
}
