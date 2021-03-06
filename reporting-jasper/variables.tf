variable "region" {
  type        = "string"
  description = "AWS Region"
  default     = "ap-south-1"
}

variable "ami" {
  type        = "string"
  description = "Ubuntu Server 18.04 LTS (HVM), SSD Volume Type"
  default     = "ami-0b44050b2d893d5f7"
}

variable "default_ami_user" {
  type    = "string"
  default = "ubuntu"
}

variable "instance_type" {
  type        = "string"
  description = "ECS Instance Type"
  default     = "t2.small"
}

variable "disk_size" {
  description = "Size of the disks for EC2 Instances"
  default     = 20
}

variable "ssh_public_key" {
  description = "Public Key used to ssh into the instances"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCCn43kM4aumjyp/PuQFJrIiENhBXiwVdkje0SNmMFllvyy6LZQoZ86yi4KrnePGAw0aJLY9oViFsR/Ib8qzULYKSM1M5D7tPsdhb/1Tyv5DYFZxpDQTsrW134xQfB01E53n65KItjyQ2H9nh1Xyop2wDHZUDIdBAUWDj4Bb3uqVUfwiMBn/Jk2eACl42pbeD7zVOJgUZYiJx8/DlYhiPRofwtnn1DUKjPjYosnwBbvUfuIhfYEk1TsTAW49MJI163TBAZqj8bylo/WqSI/U2D1N0Njh1WiXrHywGJHWrN8SNUvZL50D87dq3iUWkz5RPcrvVi5eJBhHHk6ieGExmZH"
}

variable "key_name" {
  description = "Key Name"
  default     = "openchs-infra"
}

variable "instance_count" {
  description = "Jasper Server instance count"
  default     = 1
}

variable "jasper_server_version" {
  description = "Jasper Server Community Edition version"
  default     = "7.5.0"
}
