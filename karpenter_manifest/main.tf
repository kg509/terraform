module "vars" {
  source = "../vars"
}

resource "kubernetes_manifest" "node_class" {
  manifest = yamldecode(templatefile("${path.module}/manifest/node-class.yaml.tpl", {
    cluster_name = module.vars.cluster_name
  }))
}

resource "kubernetes_manifest" "node_pool" {
  manifest = yamldecode(templatefile("${path.module}/manifest/node-pool.yaml.tpl", {}))

  depends_on = [kubernetes_manifest.node_class]
}
