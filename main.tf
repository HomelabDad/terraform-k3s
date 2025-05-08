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

module "minecraft" {
  source                 = "./modules/minecraft"
  namespace              = "minecraft"
  service_type           = var.minecraft_use_traefik ? "ClusterIP" : "LoadBalancer"
  load_balancer_ip       = var.minecraft_load_balancer_ip
  server_name            = var.minecraft_server_name
  memory                 = var.minecraft_memory
  max_players            = var.minecraft_max_players
  enable_traefik_ingress = var.minecraft_use_traefik
  minecraft_dns_name     = var.minecraft_domain_name

  depends_on = [module.metallb, module.traefik]
}