module "vpc" {
  source   = "./modules/vpc"
  env_name = "production"
  subnets = [
    { zone = "ru-central1-a", cidr = "10.0.1.0/24" },
    { zone = "ru-central1-b", cidr = "10.0.2.0/24" }
  ]
}

module "sg_app" {
  source                 = "./modules/security_group"
  name                   = "app-sg"
  network_id             = module.vpc.subnet_info[0].network_id
  folder_id              = var.folder_id
  security_group_ingress = var.security_group_ingress_app
  security_group_egress  = var.security_group_egress_app
}

module "sg_db" {
  source     = "./modules/security_group"
  name       = "db-sg"
  network_id = module.vpc.subnet_info[0].network_id
  folder_id  = var.folder_id
  security_group_ingress = [
    {
      protocol          = "TCP"
      port              = 3306
      description       = "Allow MySQL from app"
      security_group_id = module.sg_app.security_group_id
    }
  ]
  security_group_egress = var.security_group_egress_db
}

module "python-app" {
  depends_on             = [module.mysql]
  source                 = "./modules/vm"
  env_name               = "production"
  network_id             = module.vpc.subnet_info[0].network_id
  subnet_ids             = [module.vpc.subnet_info[0].id]
  subnet_zones           = [module.vpc.subnet_info[0].zone]
  instance_name          = "webs"
  instance_count         = 1
  image_family           = "ubuntu-2004-lts"
  public_ip              = true
  platform               = "standard-v3"
  instance_core_fraction = 20
  security_group_ids     = [module.sg_app.security_group_id]
  service_account_name   = "vm-puller"


  metadata = {
    user-data = templatefile("${path.module}/cloud-init/app.yaml.tpl", {
      ssh_public_key = file("~/.ssh/yavm.pub")
      username       = var.ssh_username
      registry_id    = module.container_registry.registry_id
      mysql_host     = module.mysql.mysql_host_fqdn
      db_user        = var.users[0].name
      db_password    = var.users[0].password
      db_name        = var.databases[0].name
      git_repo       = var.git_repo_url
    })
  }
}

module "mysql" {
  source                   = "./modules/mysql"
  name                     = "mysql-db"
  ha                       = false
  network_id               = module.vpc.subnet_info[1].network_id
  security_groups_ids_list = [module.sg_db.security_group_id]

  subnets = [
    {
      subnet_id = module.vpc.subnet_info[1].id
      zone      = module.vpc.subnet_info[1].zone
    }
  ]

  databases = var.databases
  users = var.users
}