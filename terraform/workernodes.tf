locals {
    worker-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.cluster.endpoint}' --b64-cluster-ca '${aws_eks_cluster.cluster.certificate_authority.0.data}' --kubelet-extra-args --node-labels=stack=${lookup(var.worker_nodes, "label")} '${lookup(var.vpc, "name")}'
USERDATA
}

resource "aws_launch_configuration" "workerNodes" {
    iam_instance_profile        = "${aws_iam_instance_profile.workerNodes.name}"
    image_id                    = "${lookup(var.worker_nodes, "ami")}"
    instance_type               = "${lookup(var.worker_nodes, "instance_type")}"
    name_prefix                 = "${lookup(var.vpc, "name")}-general-"
    security_groups             = ["${aws_security_group.workerNodesSG.id}"]
    user_data_base64            = "${base64encode(local.worker-node-userdata)}"
    key_name                    = "${lookup(var.worker_nodes, "key_name")}"

    root_block_device {
        volume_size = "${lookup(var.worker_nodes, "root_vol_size")}"
        volume_type = "gp2"
        delete_on_termination = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "workerNodes" {
    desired_capacity     = "${lookup(var.worker_nodes, "capacity")}"
    launch_configuration = "${aws_launch_configuration.workerNodes.name}"
    max_size             = "${lookup(var.worker_nodes, "capacity")}"
    min_size             = 1
    name                 = "${lookup(var.vpc, "name")}"
    vpc_zone_identifier  = [ "${aws_subnet.prv1.id}", "${aws_subnet.prv2.id}", "${aws_subnet.prv3.id}" ]

    tag {
        key                 = "Name"
        value               = "${lookup(var.vpc, "name")}-general"
        propagate_at_launch = true
    }

    tag {
        key                 = "kubernetes.io/cluster/${lookup(var.vpc, "name")}"
        value               = "owned"
        propagate_at_launch = true
    }
}
