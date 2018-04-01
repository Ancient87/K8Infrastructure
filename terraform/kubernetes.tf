output "cluster_name" {
  value = "sev.k8s.local"
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-sev-k8s-local.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-sev-k8s-local.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-sev-k8s-local.name}"
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-sev-k8s-local.id}"]
}

output "node_subnet_ids" {
  value = ["${aws_subnet.eu-west-1b-sev-k8s-local.id}"]
}

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-sev-k8s-local.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-sev-k8s-local.name}"
}

output "region" {
  value = "eu-west-1"
}

output "vpc_id" {
  value = "${aws_vpc.sev-k8s-local.id}"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_autoscaling_attachment" "master-eu-west-1b-masters-sev-k8s-local" {
  elb                    = "${aws_elb.api-sev-k8s-local.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-eu-west-1b-masters-sev-k8s-local.id}"
}

resource "aws_autoscaling_group" "master-eu-west-1b-masters-sev-k8s-local" {
  name                 = "master-eu-west-1b.masters.sev.k8s.local"
  launch_configuration = "${aws_launch_configuration.master-eu-west-1b-masters-sev-k8s-local.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1b-sev-k8s-local.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "sev.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-eu-west-1b.masters.sev.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-eu-west-1b"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nodes-sev-k8s-local" {
  name                 = "nodes.sev.k8s.local"
  launch_configuration = "${aws_launch_configuration.nodes-sev-k8s-local.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${aws_subnet.eu-west-1b-sev-k8s-local.id}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "sev.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.sev.k8s.local"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_ebs_volume" "b-etcd-events-sev-k8s-local" {
  availability_zone = "eu-west-1b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "sev.k8s.local"
    Name                 = "b.etcd-events.sev.k8s.local"
    "k8s.io/etcd/events" = "b/b"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "b-etcd-main-sev-k8s-local" {
  availability_zone = "eu-west-1b"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "sev.k8s.local"
    Name                 = "b.etcd-main.sev.k8s.local"
    "k8s.io/etcd/main"   = "b/b"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_elb" "api-sev-k8s-local" {
  name = "api-sev-k8s-local-95o548"

  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-sev-k8s-local.id}"]
  subnets         = ["${aws_subnet.eu-west-1b-sev-k8s-local.id}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "api.sev.k8s.local"
  }
}

resource "aws_iam_instance_profile" "masters-sev-k8s-local" {
  name = "masters.sev.k8s.local"
  role = "${aws_iam_role.masters-sev-k8s-local.name}"
}

resource "aws_iam_instance_profile" "nodes-sev-k8s-local" {
  name = "nodes.sev.k8s.local"
  role = "${aws_iam_role.nodes-sev-k8s-local.name}"
}

resource "aws_iam_role" "masters-sev-k8s-local" {
  name               = "masters.sev.k8s.local"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.sev.k8s.local_policy")}"
}

resource "aws_iam_role" "nodes-sev-k8s-local" {
  name               = "nodes.sev.k8s.local"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.sev.k8s.local_policy")}"
}

resource "aws_iam_role_policy" "masters-sev-k8s-local" {
  name   = "masters.sev.k8s.local"
  role   = "${aws_iam_role.masters-sev-k8s-local.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.sev.k8s.local_policy")}"
}

resource "aws_iam_role_policy" "nodes-sev-k8s-local" {
  name   = "nodes.sev.k8s.local"
  role   = "${aws_iam_role.nodes-sev-k8s-local.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.sev.k8s.local_policy")}"
}

resource "aws_internet_gateway" "sev-k8s-local" {
  vpc_id = "${aws_vpc.sev-k8s-local.id}"

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "sev.k8s.local"
  }
}

resource "aws_key_pair" "kubernetes-sev-k8s-local-7e2e7406d87f664116c3aa320a622344" {
  key_name   = "kubernetes.sev.k8s.local-7e:2e:74:06:d8:7f:66:41:16:c3:aa:32:0a:62:23:44"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.sev.k8s.local-7e2e7406d87f664116c3aa320a622344_public_key")}"
}

resource "aws_launch_configuration" "master-eu-west-1b-masters-sev-k8s-local" {
  name_prefix                 = "master-eu-west-1b.masters.sev.k8s.local-"
  image_id                    = "ami-33c9a24a"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-sev-k8s-local-7e2e7406d87f664116c3aa320a622344.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-sev-k8s-local.id}"
  security_groups             = ["${aws_security_group.masters-sev-k8s-local.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-eu-west-1b.masters.sev.k8s.local_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "nodes-sev-k8s-local" {
  name_prefix                 = "nodes.sev.k8s.local-"
  image_id                    = "ami-33c9a24a"
  instance_type               = "t2.medium"
  key_name                    = "${aws_key_pair.kubernetes-sev-k8s-local-7e2e7406d87f664116c3aa320a622344.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-sev-k8s-local.id}"
  security_groups             = ["${aws_security_group.nodes-sev-k8s-local.id}"]
  associate_public_ip_address = true
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.sev.k8s.local_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_route" "0-0-0-0--0" {
  route_table_id         = "${aws_route_table.sev-k8s-local.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.sev-k8s-local.id}"
}

resource "aws_route_table" "sev-k8s-local" {
  vpc_id = "${aws_vpc.sev-k8s-local.id}"

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "sev.k8s.local"
  }
}

resource "aws_route_table_association" "eu-west-1b-sev-k8s-local" {
  subnet_id      = "${aws_subnet.eu-west-1b-sev-k8s-local.id}"
  route_table_id = "${aws_route_table.sev-k8s-local.id}"
}

resource "aws_security_group" "api-elb-sev-k8s-local" {
  name        = "api-elb.sev.k8s.local"
  vpc_id      = "${aws_vpc.sev-k8s-local.id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "api-elb.sev.k8s.local"
  }
}

resource "aws_security_group" "masters-sev-k8s-local" {
  name        = "masters.sev.k8s.local"
  vpc_id      = "${aws_vpc.sev-k8s-local.id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "masters.sev.k8s.local"
  }
}

resource "aws_security_group" "nodes-sev-k8s-local" {
  name        = "nodes.sev.k8s.local"
  vpc_id      = "${aws_vpc.sev-k8s-local.id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "nodes.sev.k8s.local"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.masters-sev-k8s-local.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.masters-sev-k8s-local.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-sev-k8s-local.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-sev-k8s-local.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.api-elb-sev-k8s-local.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-sev-k8s-local.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-sev-k8s-local.id}"
  source_security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-sev-k8s-local.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-sev-k8s-local.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_subnet" "eu-west-1b-sev-k8s-local" {
  vpc_id            = "${aws_vpc.sev-k8s-local.id}"
  cidr_block        = "172.20.32.0/19"
  availability_zone = "eu-west-1b"

  tags = {
    KubernetesCluster                     = "sev.k8s.local"
    Name                                  = "eu-west-1b.sev.k8s.local"
    "kubernetes.io/cluster/sev.k8s.local" = "owned"
    "kubernetes.io/role/elb"              = "1"
  }
}

resource "aws_vpc" "sev-k8s-local" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    KubernetesCluster                     = "sev.k8s.local"
    Name                                  = "sev.k8s.local"
    "kubernetes.io/cluster/sev.k8s.local" = "owned"
  }
}

resource "aws_vpc_dhcp_options" "sev-k8s-local" {
  domain_name         = "eu-west-1.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster = "sev.k8s.local"
    Name              = "sev.k8s.local"
  }
}

resource "aws_vpc_dhcp_options_association" "sev-k8s-local" {
  vpc_id          = "${aws_vpc.sev-k8s-local.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.sev-k8s-local.id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
