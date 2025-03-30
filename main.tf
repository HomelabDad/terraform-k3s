module "monitoring" {
  source         = "./modules/monitoring"
  namespace      = "monitoring"
  traefik_module = module.traefik
}

module "metallb" {
  source           = "./modules/metallb"
  ip_address_range = var.metallb_ip_range
}

module "traefik" {
  source           = "./modules/traefik"
  load_balancer_ip = var.traefik_load_balancer_ip
}

module "portainer" {
  source = "./modules/portainer"
}