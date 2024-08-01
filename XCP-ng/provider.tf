terraform {
  required_version = ">= 0.13.0"
  required_providers {
    xenorchestra = {
      #source = "terra-farm/xenorchestra"
      source = "vatesfr/xenorchestra"
    }
  }
}
variable "xo_host" {
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
  url      = "ws://{{ xo_host }}"
  username = "{{ xo_username }}"
  password = "{{ xo_password }}"
  insecure = true
}
