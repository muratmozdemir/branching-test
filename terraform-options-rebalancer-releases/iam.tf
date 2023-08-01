data "aws_iam_policy_document" "github_actions_assume_role_policy_data" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_org}/${var.github_repo}:ref:refs/heads/${var.github_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = "GithubActionsRole"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role_policy_data.json
}

data "aws_iam_policy_document" "options_rebalancer_releases_s3_policy_data" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:HeadBucket"
    ]

    resources = [
      aws_s3_bucket.options_rebalancer_releases.arn,
      "${aws_s3_bucket.options_rebalancer_releases.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "options_rebalancer_releases_s3_policy" {
  name   = "GitHubActionsS3Policy"
  role   = aws_iam_role.github_actions_role.id
  policy = data.aws_iam_policy_document.options_rebalancer_releases_s3_policy_data.json
}

resource "aws_iam_role_policy_attachment" "github_actions_role_s3_policy_attach" {
  role       = aws_iam_role.options_rebalancer_github_actions_role.name
  policy_arn = aws_iam_policy.options_rebalancer_releases_s3_policy.arn
}
