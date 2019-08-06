resource "aws_security_group" "clusterSG" {
    name        = "clusterSG"
    description = "Kubernetes cluster SG"
    vpc_id      = "${aws_vpc.sgt.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${lookup(var.vpc, "name")}-clusterSG"
    }
}

resource "aws_security_group" "workerNodesSG" {
    name        = "workerNodesSG"
    description = "Worker Nodes SG"
    vpc_id      = "${aws_vpc.sgt.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${lookup(var.vpc, "name")}-workerNodesSG"
    }
}

resource "aws_security_group" "RDSAuroraSG" {
    name        = "RDSAuroraSG"
    description = "RDS Aurora SG"
    vpc_id      = "${aws_vpc.sgt.id}"

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${lookup(var.vpc, "name")}-RDSAuroraSG"
    }
}

resource "aws_security_group_rule" "wnSGtoCSG443ingress" {
    type            = "ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_group_id = "${aws_security_group.clusterSG.id}"
    source_security_group_id = "${aws_security_group.workerNodesSG.id}"
}

resource "aws_security_group_rule" "wnSGtoRASG3306ingress" {
    type            = "ingress"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_group_id = "${aws_security_group.RDSAuroraSG.id}"
    source_security_group_id = "${aws_security_group.workerNodesSG.id}"
}

resource "aws_security_group_rule" "CSGtownSG443ingress" {
    type            = "ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_group_id = "${aws_security_group.workerNodesSG.id}"
    source_security_group_id = "${aws_security_group.clusterSG.id}"
}

resource "aws_security_group_rule" "wnSGtoCSGingress" {
    type            = "ingress"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_group_id = "${aws_security_group.clusterSG.id}"
    source_security_group_id = "${aws_security_group.workerNodesSG.id}"
}

resource "aws_security_group_rule" "CSGtownSGingress" {
    type            = "ingress"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_group_id = "${aws_security_group.workerNodesSG.id}"
    source_security_group_id = "${aws_security_group.clusterSG.id}"
}

resource "aws_security_group_rule" "wnSGingress" {
    type            = "ingress"
    from_port       = 0
    to_port         = 65535
    protocol        = "-1"
    security_group_id = "${aws_security_group.workerNodesSG.id}"
    source_security_group_id = "${aws_security_group.workerNodesSG.id}"
}

resource "aws_security_group_rule" "CSGingress" {
    type            = "ingress"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_group_id = "${aws_security_group.clusterSG.id}"
    cidr_blocks     = ["0.0.0.0/0"]
}
