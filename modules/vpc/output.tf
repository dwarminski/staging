output "subnet_ids" {
  value = {
    public  = azurerm_subnet.public_subnet.id
    private = azurerm_subnet.private_subnet.id
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}
