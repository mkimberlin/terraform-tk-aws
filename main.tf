module "global" {
  source  = "./environments/global"
  default_region = var.default_region
  budget_notification_recipients = var.budget_notification_recipients
}

# Load modules for each of the configured environments...these can't be
# located dynamically because module source can't be interpolated in Terraform
module "development-asia" {
  count = contains(var.environments, "development/asia") ? 1 : 0
  source    = "./environments/development/asia"
  depends_on = [module.global]
}

module "development-us" {
  count = contains(var.environments, "development/us") ? 1 : 0
  source    = "./environments/development/us"
  depends_on = [module.global]
}

module "production-asia" {
  count = contains(var.environments, "production/asia") ? 1 : 0
  source    = "./environments/production/asia"
  depends_on = [module.global]
}

module "production-europe" {
  count = contains(var.environments, "production/europe") ? 1 : 0
  source    = "./environments/production/europe"
  depends_on = [module.global]
}

module "production-us" {
  count = contains(var.environments, "production/us") ? 1 : 0
  source    = "./environments/production/us"
  depends_on = [module.global]
}