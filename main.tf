provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "alicloud_instance_types" "2c4g" {
  instance_type_family = "ecs.n1"
  cpu_core_count = 2
  memory_size    = 4
}

data "alicloud_images" "ubuntu" {
  owners     = "system"
  name_regex = "^centos_7_02"
}

resource "alicloud_vpc" "vpc" {
  name       = "tf_kube_vpc"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "172.16.1.0/24"
  availability_zone = "cn-shanghai-b"
}

resource "alicloud_security_group" "group" {
  name   = "sg-for-kube"
  vpc_id = "${alicloud_vpc.vpc.id}"
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_kube_api" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "8080/8080"
  priority          = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "k8s" {
  availability_zone     = "${alicloud_vswitch.vsw.availability_zone}"
  image_id              = "${data.alicloud_images.ubuntu.images.0.id}"
  instance_type         = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  io_optimized          = "optimized"
  system_disk_category  = "cloud_efficiency"
  security_groups       = ["${alicloud_security_group.group.id}"]
  instance_name         = "kubernetes-node${count.index}"
  vswitch_id            = "${alicloud_vswitch.vsw.id}"
  password              = "${var.ecs_password}"
  host_name             = "kubernetes-node${count.index}"
  count                 = "${var.count}"
  user_data             = "${data.template_file.shell.rendered}"
}

data "template_file" "shell" {
  template = "${file("userdata.sh")}"
  vars {
      access_key = "${var.access_key}"
      secret_key = "${var.secret_key}"
  }
}
