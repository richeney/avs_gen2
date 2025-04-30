variable "subscription_id" {
  description = "The ID of the Azure subscription where the resources will be created."
  type        = string
}

variable "identifier" {
  description = "A unique identifier for the resources."
  type        = string
  default     = "rcheney-avs-gen2"
}

variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
  default     = "rcheney-avs-gen2"
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "UK South"
}

variable "address_space" {
  description = "The address space for the virtual network."
  type        = string
  default     = "10.76.0.0/22"
}