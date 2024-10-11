########################################
# Loki-S3-policy
########################################

resource "aws_iam_role" "loki_s3_role" {
  name = "LokiS3Role-${module.vars.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(data.aws_iam_openid_connect_provider.oidc.url, "https://", "")}:sub" = "system:serviceaccount:${module.vars.loki_namespace}:loki-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "loki_s3_policy" {
  name = "LokiS3Policy-${module.vars.cluster_name}"
  role = aws_iam_role.loki_s3_role.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Sid" : "LokiStorage",
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      }
    ]
  })
}
