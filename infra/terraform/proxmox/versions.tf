terraform {
  required_version = ">= 1.10"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
  }

  # Backend à configurer selon l'infra (S3/GCS pour le tfstate — cf CLAUDE.md).
  # Le tfstate n'est JAMAIS commité (cf .gitignore : *.tfstate).
  # backend "s3" {
  #   bucket = "novapay-tfstate"
  #   key    = "proxmox/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}
