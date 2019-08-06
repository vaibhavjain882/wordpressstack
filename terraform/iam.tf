resource "aws_iam_role" "cluster" {
    name = "${lookup(var.vpc, "name")}-eksCluster"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "eksSvcLnkdRolePolicy" {
    name        = "${lookup(var.vpc, "name")}-EKSServiceLinkedRolePolicy"
    path        = "/"
    description = "Policy for managing service linked role by EKS"

    policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement" : [{
        "Effect" : "Allow",
        "Action" : "iam:CreateServiceLinkedRole",
        "Resource" : "arn:aws:iam::*:role/aws-service-role/*"
    },
    {
        "Effect" : "Allow",
        "Action" : "ec2:DescribeAccountAttributes",
        "Resource" : "*"
    }]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eksCluster" {
    role       = "${aws_iam_role.cluster.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eksService" {
    role       = "${aws_iam_role.cluster.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

resource "aws_iam_role_policy_attachment" "eksSvcLnkdRolePolicy" {
    role       = "${aws_iam_role.cluster.name}"
    policy_arn = "${aws_iam_policy.eksSvcLnkdRolePolicy.arn}"
}

resource "aws_iam_role" "workerNodes" {
    name = "${lookup(var.vpc, "name")}-workerNodes"
    path = "/"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "workerNodes" {
  name = "${lookup(var.vpc, "name")}-workerNodes"
  role = "${aws_iam_role.workerNodes.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    role       = "${aws_iam_role.workerNodes.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
    role       = "${aws_iam_role.workerNodes.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    role       = "${aws_iam_role.workerNodes.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
