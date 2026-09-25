# Lab_Terraform
Terraform et Microsoft Azure

# Déployer une VM Azure avec Terraform

Projet personnel d’Infrastructure as Code réalisé pour pratiquer Terraform sur Microsoft Azure. À partir du [module IT-Connect « Création et gestion d’un projet avec Terraform »](https://www.it-connect.fr/modules/terraform-creation-et-gestion-un-projet-azure/), j’ai adapté le déploiement aux contraintes d’une sandbox Azure KodeKloud.

L’objectif : décrire une infrastructure dans le code, examiner les changements avant leur application, puis pouvoir supprimer les ressources créées à la fin du lab.

## Infrastructure déployée

La configuration Terraform crée, dans un **groupe de ressources Azure préexistant** :

- un réseau virtuel et un sous-réseau ;
- une adresse IP publique statique ;
- un groupe de sécurité réseau (NSG) associé à l’interface réseau ;
- une machine virtuelle Linux accessible par clé SSH.

Le NSG autorise les connexions entrantes sur les ports **22 (SSH), 80 (HTTP) et 443 (HTTPS)**. La VM utilise par défaut la taille `Standard_B1s` et un disque système `Standard_LRS` de 30 Go. Un provisioner `remote-exec` crée un fichier de bienvenue et lance une mise à jour des paquets.

> Le port SSH est actuellement ouvert à toutes les adresses IP (`0.0.0.0/0`). Pour un déploiement durable, il faudrait limiter sa source aux adresses autorisées.

## Mes adaptations au tutoriel

J’ai travaillé dans une sandbox Azure fournie par KodeKloud. Elle mettait à ma disposition des identifiants IAM ainsi que des paramètres `CLIENT_ID`, `CLIENT_SECRET`, `SUBSCRIPTION_ID` et `TENANT_ID` pour l’authentification utilisée par Terraform. Je n’ai donc pas créé de nouveau Service Principal pour ce lab.

J’ai également réutilisé le groupe de ressources fourni par la sandbox, au lieu de le créer avec Terraform. **Un `terraform destroy` supprime les ressources gérées par ce projet, mais pas ce groupe de ressources préexistant.**

Enfin, j’ai ajusté le disque de la VM à **30 Go en `Standard_LRS`** pour respecter les restrictions de stockage rencontrées dans cet environnement.

## Organisation du dépôt

```text
.
├── .gitignore
├── README.md
└── terraform/
    ├── main.tf       # Réseau, sécurité, interface et VM
    ├── outputs.tf    # Nom, identifiant et adresses IP de la VM
    ├── provider.tf   # Provider AzureRM et authentification
    └── variables.tf  # Paramètres du déploiement
```

Le fichier `terraform.tfvars`, qui contient les valeurs propres à la sandbox, est ignoré par Git.

## Utilisation

Depuis le dossier `terraform/`, renseigner localement les variables attendues par `variables.tf` dans un fichier `terraform.tfvars`, notamment les paramètres Azure, le nom du groupe de ressources existant et les clés SSH. **Ne pas versionner ce fichier ni la clé privée.**

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Ressources ajoutées au groupe de ressources Azure préexistant

<img width="952" height="646" alt="image" src="https://github.com/user-attachments/assets/9957f638-6c8a-49a8-b5a3-322a95531765" />



Après le déploiement, afficher les valeurs de sortie et se connecter à la VM avec la clé privée correspondant à la clé publique configurée :

```bash
terraform output
ssh -i /chemin/vers/cle_privee adminuser@$(terraform output -raw vm_public_ip)
```

Pour supprimer les ressources créées par ce projet :

```bash
terraform destroy
```

## Ce que ce lab m’a permis de pratiquer

- Structurer un projet Terraform avec un provider, des variables, des ressources et des outputs.
- Déployer des ressources réseau et une VM sur Azure.
- Adapter une configuration IaC aux contraintes d’une sandbox.
- Utiliser Git pour versionner la configuration sans publier les variables sensibles.
- Suivre le cycle `init` → `plan` → `apply` → vérification → `destroy`.

## Référence

Projet réalisé à partir du [cours Terraform pour Azure d’IT-Connect](https://www.it-connect.fr/modules/terraform-creation-et-gestion-un-projet-azure/), avec les adaptations décrites ci-dessus.
