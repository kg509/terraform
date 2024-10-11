locals {
  prometheus_settings = {
    # Prometheus custom alert rule 설정
    "additionalPrometheusRulesMap.rule-name.groups[0].name"                             = "cpu-usage"
    "additionalPrometheusRulesMap.rule-name.groups[0].rules[0].alert"                   = "HighPodCPUUsage"
    "additionalPrometheusRulesMap.rule-name.groups[0].rules[0].expr"                    = "rate(container_cpu_usage_seconds_total{container!=\"\",pod!=\"\",namespace!=\"\"}[5m]) > 0.4"
    "additionalPrometheusRulesMap.rule-name.groups[0].rules[0].for"                     = "5m"
    "additionalPrometheusRulesMap.rule-name.groups[0].rules[0].labels.severity"         = "critical"
    "additionalPrometheusRulesMap.rule-name.groups[0].rules[0].annotations.description" = "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} is using high CPU. Current usage is {{ $value }}."
    "additionalPrometheusRulesMap.rule-name.groups[0].rules[0].annotations.summary"     = "High CPU usage detected for Pod {{ $labels.pod }}."

    # Alertmanager 설정
    "alertmanager.config.global.smtp_smarthost"            = "smtp.gmail.com:587"
    "alertmanager.config.global.smtp_from"                 = "mail@gmail.com"
    "alertmanager.config.global.smtp_auth_username"        = "mail@gmail.com"
    "alertmanager.config.global.smtp_auth_password"        = "your-google-app-password"
    "alertmanager.config.global.smtp_require_tls"          = "true"
    "alertmanager.config.global.resolve_timeout"           = "5m"
    "alertmanager.config.route.group_by[0]"                = "namespace"
    "alertmanager.config.route.group_by[1]"                = "pod"
    "alertmanager.config.route.group_wait"                 = "30s"
    "alertmanager.config.route.group_interval"             = "5m"
    "alertmanager.config.route.repeat_interval"            = "30m"
    "alertmanager.config.route.receiver"                   = "email-notifications"
    "alertmanager.config.receivers[0].name"                = "email-notifications"
    "alertmanager.config.receivers[0].email_configs[0].to" = "receiver-email@example.com"

    # Grafana 추가 데이터소스 설정
    "grafana.additionalDataSources[0].name"                  = "Loki"
    "grafana.additionalDataSources[0].type"                  = "loki"
    "grafana.additionalDataSources[0].access"                = "proxy"
    "grafana.additionalDataSources[0].isDefault"             = "false"
    "grafana.additionalDataSources[0].url"                   = "http://loki-stack.${module.vars.loki_namespace}:3100/"
    "grafana.additionalDataSources[0].jsonData.timeInterval" = "30s"
  }
}
