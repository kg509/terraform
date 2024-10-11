apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: simple
spec:
  amiFamily: AL2023
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${cluster_name}"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${cluster_name}"
  role: "KarpenterNodeRole-${cluster_name}"
  amiSelectorTerms:
    - alias: al2023@v20240807
