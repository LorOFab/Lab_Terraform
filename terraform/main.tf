
# Groupe de ressources principal

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


# Réseau virtuel principal

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vm_name}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Sous-réseau associé

resource "azurerm_subnet" "subnet" {
  name                 = "${var.vm_name}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefix
  location             = var.location
  resource_group_name  = var.resource_group_name
}


# Adresse IP publique pour accéder à la VM

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vm_name}-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}




# Groupe de sécurité réseau ( NSG )

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow_SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_All_Outbound"
    priority                   = 1004
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


# Interface réseau

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}


# Association du NSG avec la carte réseau

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}



# Machine virtuelle Linux

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = var.admin_username

  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }


  provisioner "remote-exec" {
    inline = [
      "echo 'Première VM provisionnée avec Terraform !' > /home/${var.admin_username}/bienvenue.txt",
      "chmod 644 /home/${var.admin_username}/bienvenue.txt",
      "sudo apt-get update -y",
      "sudo apt-get install -y curl unzip",
      "curl -fsSL https://releases.hashicorp.com/terraform/1.16.0/terraform_1.16.0_linux_amd64.zip -o terraform.zip",
      "unzip terraform.zip",
      "sudo mv terraform /usr/local/bin/",
      "terraform --version"
    ]

    connection {
      type        = "ssh"
      user        = var.admin_username
      private_key = var.ssh_private_key
      host        = azurerm_public_ip.public_ip.ip_address
    }
  


  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  tags = {
    environment = var.environment_tag
  }

  depends_on = [
    azurerm_network_interface.nic,
    azurerm_network_security_group.nsg
  ]
}
