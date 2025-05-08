output "avs_azapi" {
  description = "The ID of the Azure VMware Solution (AVS) private cloud."
  value       = azapi_resource.avs
}


output "avs_data" {
  description = "The data of the Azure VMware Solution (AVS) private cloud."
  value       = data.azurerm_vmware_private_cloud.avs
}