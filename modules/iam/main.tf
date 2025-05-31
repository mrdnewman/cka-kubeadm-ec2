

# Master Role
resource "aws_iam_role" "master" {
  name = var.master_role_name
  assume_role_policy = data.aws_iam_policy_document.master_trust.json
}

data "aws_iam_policy_document" "master_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "master_write_secrets" {
  name   = "MasterWriteSecrets"
  role   = aws_iam_role.master.id
  policy = data.aws_iam_policy_document.master_write_secrets.json
}

data "aws_iam_policy_document" "master_write_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:PutSecretValue"
    ]
    resources = [var.kubeadm_secret_arn]
  }
}

# Worker Role
resource "aws_iam_role" "worker" {
  name = var.worker_role_name
  assume_role_policy = data.aws_iam_policy_document.worker_trust.json
}

data "aws_iam_policy_document" "worker_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "worker_read_secrets" {
  name   = "WorkerReadSecrets"
  role   = aws_iam_role.worker.id
  policy = data.aws_iam_policy_document.worker_read_secrets.json
}

data "aws_iam_policy_document" "worker_read_secrets" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [var.kubeadm_secret_arn]
  }
}

resource "aws_iam_instance_profile" "master" {
  name = "${var.master_role_name}-profile"
  role = aws_iam_role.master.name
}

resource "aws_iam_instance_profile" "worker" {
  name = "${var.worker_role_name}-profile"
  role = aws_iam_role.worker.name
}

