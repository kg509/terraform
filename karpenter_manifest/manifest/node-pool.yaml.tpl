apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: simple
spec:
  template:
    metadata:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: simple

      expireAfter: 720h # 노드 만료 시간 (30일)
      terminationGracePeriod: 48h # 노드가 삭제되기 전 Draining 상태에 있을 수 있는 시간

      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c", "m", "r", "t"]  # 비용 최적화를 위해 't'를 추가

        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["m5", "m5d", "c5", "c5d", "c4", "r4", "t3", "t3a"]
          
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"] 

        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt # Grater than; >
          values: ["2"] # 3세대 이상 인스턴스

        - key: "kubernetes.io/arch"
          operator: In
          values: ["arm64", "amd64"]

        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["on-demand"] # "spot" 을 위한 설정을 완료했다면, spot도 추가 가능

  disruption:
    consolidationPolicy: WhenEmpty # Node가 완전히 비어 있을 때만 삭제하도록 설정
    consolidateAfter: 1m 

    budgets:
    - nodes: 10%

  limits:
    cpu: "1000"
    memory: 1000Gi

  weight: 10