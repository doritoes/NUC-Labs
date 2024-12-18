terraform {
  required_version = ">= 0.13.0"
  required_providers {
    xenorchestra = {
      source = "vatesfr/xenorchestra"
      version = "~> 0.9"
    }
  }
}
variable "xo_host" {
  type = string
}
variable "xo_pool" {
  type = string
}
variable "xo_username" {
  type = string
}
variable "xo_password" {
  type = string
  sensitive = true
}
provider "xenorchestra" {
  url      = "wss://${var.xo_host}"
  username = "${var.xo_username}"
  password = "${var.xo_password}"
  insecure = true
}
