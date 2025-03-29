module "monitoring" {
  source    = "./modules/monitoring"
  namespace = "monitoring"
}

module "metallb" {
  source = "./modules/metallb"
}

module "traefik" {
  source = "./modules/traefik"
}

module "portainer" {
  source = "./modules/portainer"
}