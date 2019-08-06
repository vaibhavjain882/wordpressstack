data "aws_subnet_ids" "public" {
    vpc_id = "${aws_vpc.sgt.id}"
    depends_on = [ "aws_subnet.pub1", "aws_subnet.pub2", "aws_subnet.pub3" ]

    tags = {
        Scope = "Public"
    }
}

output "public_subnet_ids" {
  value = "${data.aws_subnet_ids.public.ids}"
}

output "vpc_sgt_id" {
    value = "${aws_vpc.sgt.id}"
}

output "subnet_sgt_pub1_id" {
    value = "${aws_subnet.pub1.id}"
}

output "subnet_sgt_pub2_id" {
    value = "${aws_subnet.pub2.id}"
}

output "subnet_sgt_pub3_id" {
    value = "${aws_subnet.pub3.id}"
}

output "subnet_sgt_prv1_id" {
    value = "${aws_subnet.prv1.id}"
}

output "subnet_sgt_prv2_id" {
    value = "${aws_subnet.prv2.id}"
}

output "subnet_sgt_prv3_id" {
    value = "${aws_subnet.prv3.id}"
}

output "rds_db_endpoint" {
    value = "${aws_rds_cluster.sgtest.endpoint}"
}

output "config_map_aws_auth" {
  value = "${local.config_map_aws_auth}"
}

output "storage_class_custom_gp2" {
  value = "${local.storage_class_custom_gp2}"
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "albingcontroller" {
  value = "${local.albingcontroller}"
}

output "alb_ing_rbac" {
  value = "${local.alb_ing_rbac}"
}
