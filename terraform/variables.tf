# Identifiants d'authentification Azure

variable "ARM_SUBSCRIPTION_ID" {
  type = string
}

variable "ARM_CLIENT_ID" {
  type = string
}

variable "ARM_CLIENT_SECRET" {
  type      = string
  sensitive = true
}

variable "ARM_TENANT_ID" {
  type = string
}


# Groupe de ressources et emplacement
variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure"
  type        = string
}

variable "location" {
  description = "Région Azure dans laquelle déployer les ressources"
  type        = string
  default     = "eastus"
}

# Paramètres réseau
variable "vnet_address_space" {
  description = "Plage d'adresses IP pour le vNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Préfixe IP pour le sous-réseau principal"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Machine virtuelle
variable "vm_name" {
  description = "Nom de la machine virtuelle"
  type        = string
}

variable "vm_size" {
  description = "Taille de la machine virtuelle"
  type        = string
  default     = "Standard_B1s"
}

variable "os_disk_size_gb" {
  description = "Taille du disque système en Go"
  type        = number
  default     = 30
}

# Image Ubuntu 24.04 LTS (x64 Gen2)
variable "image_publisher" {
  type    = string
  default = "Canonical"
}

variable "image_offer" {
  type    = string
  default = "0001-com-ubuntu-server-noble"
}

variable "image_sku" {
  type    = string
  default = "24_04-lts-gen2"
}

variable "image_version" {
  type    = string
  default = "latest"
}

# Accès SSH
variable "admin_username" {
  description = "Nom d'utilisateur pour se connecter à la VM"
  type        = string
  default     = "adminuser"
}

variable "ssh_public_key" {
  description = "Clé publique SSH"
  type        = string
  sensitive   = true
}

# Tag environnement
variable "environment_tag" {
  description = "Indique l'environnement de déploiement (dev, test, prod)"
  type        = string
  default     = "dev"
}

# Accès SSH pour remote-exec 
variable "ssh_private_key" {
  description = "Clé privée SSH pour se connecter à la VM"
  type        = string
  sensitive   = true
}
