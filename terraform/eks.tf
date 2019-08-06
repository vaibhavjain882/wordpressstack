resource "aws_eks_cluster" "cluster" {
    name      = "${lookup(var.vpc, "name")}"
    role_arn  = "${aws_iam_role.cluster.arn}"
    version   = "1.12"

    vpc_config {
        subnet_ids = [ "${aws_subnet.pub1.id}", "${aws_subnet.pub2.id}", "${aws_subnet.pub3.id}", "${aws_subnet.prv1.id}", "${aws_subnet.prv2.id}", "${aws_subnet.prv3.id}" ]
        security_group_ids = [ "${aws_security_group.clusterSG.id}" ]
    }

    depends_on = [
        "aws_iam_role_policy_attachment.eksCluster",
        "aws_iam_role_policy_attachment.eksService",
        "aws_iam_role_policy_attachment.eksSvcLnkdRolePolicy"
    ]
}
