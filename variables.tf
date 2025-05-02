variable "subscription_id" {
  description = "The ID of the Azure subscription where the resources will be created."
  type        = string
}

variable "prefix" {
  description = "A unique prefix for the resources."
  type        = string
  default     = "rcheney"
}

// Azure VMware Solution (AVS) variables

variable "avs_address_space" {
  description = "The address space for the virtual network."
  type        = string
  default     = "10.76.0.0/22"
}

// Hub variables

variable "hub_address_space" {
  description = "The address space for the hub virtual network."
  type        = string
  default     = "10.72.0.0/22"
}

// Additional defaults

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "UK South"
}
