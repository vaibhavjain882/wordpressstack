resource "aws_db_subnet_group" "sgtest" {
  name       = "${lookup(var.vpc, "name")}"
  subnet_ids = [ "${aws_subnet.prv1.id}", "${aws_subnet.prv2.id}", "${aws_subnet.prv3.id}" ]

  tags = {
    Name = "${lookup(var.vpc, "name")}"
  }
}

resource "aws_rds_cluster_instance" "sgtest_cluster_instances" {
  count              = 2
  identifier         = "${lookup(var.vpc, "name")}-aurora-cluster-${count.index}"
  cluster_identifier = "${aws_rds_cluster.sgtest.id}"
  instance_class     = "db.r5.large"
  engine             = "aurora-mysql"
  engine_version     = "5.7.12"
}

resource "aws_rds_cluster" "sgtest" {
  cluster_identifier     = "${lookup(var.vpc, "name")}-aurora-cluster"
  database_name          = "${lookup(var.vpc, "name")}"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.12"
  db_subnet_group_name   = "${aws_db_subnet_group.sgtest.id}"
  vpc_security_group_ids = [ "${aws_security_group.RDSAuroraSG.id}" ]
  master_username        = "admin"
  master_password        = "adminpassword"
  skip_final_snapshot    = true
}
