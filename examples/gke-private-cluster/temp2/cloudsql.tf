# /**
#  * Copyright 2019 Google LLC
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License");
#  * you may not use this file except in compliance with the License.
#  * You may obtain a copy of the License at
#  *
#  *      http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software
#  * distributed under the License is distributed on an "AS IS" BASIS,
#  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  * See the License for the specific language governing permissions and
#  * limitations under the License.
#  */

locals {
  read_replica_ip_configuration = {
    ipv4_enabled       = true
    require_ssl        = false
    private_network    = null
    allocated_ip_range = null
    authorized_networks = [
      {
        name  = "${var.project_id}-cidr"
        value = var.mysql_ha_external_ip_range
      },
    ]
  }

}


module "mysql" {
  source               = "../../sql_modules/mysql"
  name                 = var.mysql_ha_name
  random_instance_name = true
  project_id           = var.project
  database_version     = "MYSQL_5_7"
  region               = var.region

  deletion_protection = false

  // Master configurations
  tier                            = "db-n1-standard-1"
  zone                            = var.location
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  database_flags = [{ name = "long_query_time", value = 1 }]

  user_labels = {
    foo = "bar"
  }

  ip_configuration = {
    ipv4_enabled       = true
    require_ssl        = true
    private_network    = null
    allocated_ip_range = null
    authorized_networks = [
      {
        name  = "${var.project_id}-cidr"
        value = var.mysql_ha_external_ip_range
      },
    ]
  }

  backup_configuration = {
    enabled                        = true
    binary_log_enabled             = true
    start_time                     = "20:55"
    location                       = null
    transaction_log_retention_days = null
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }

  // Read replica configurations
  read_replica_name_suffix = "-test"
  read_replicas = [
    {
      name                  = "0"
      zone                  = var.location
      availability_type     = "ZONAL"
      tier                  = "db-n1-standard-1"
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "long_query_time", value = 1 }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { bar = "baz" }
      encryption_key_name   = null
    },
    {
      name                  = "1"
      zone                  = "var.zone"
      availability_type     = "ZONAL"
      tier                  = "db-n1-standard-1"
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "long_query_time", value = 1 }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { bar = "baz" }
      encryption_key_name   = null
    },
    {
      name                  = "2"
      zone                  = "var.zone"
      availability_type     = "ZONAL"
      tier                  = "db-n1-standard-1"
      ip_configuration      = local.read_replica_ip_configuration
      database_flags        = [{ name = "long_query_time", value = 1 }]
      disk_autoresize       = null
      disk_autoresize_limit = null
      disk_size             = null
      disk_type             = "PD_HDD"
      user_labels           = { bar = "baz" }
      encryption_key_name   = null
    },
  ]

  db_name      = var.abc-sql
  db_charset   = "utf8mb4"
  db_collation = "utf8mb4_general_ci"

  additional_databases = [
    {
      name      = "abc-additional"
      charset   = "utf8mb4"
      collation = "utf8mb4_general_ci"
    },
  ]

  user_name     = "tftest"
  user_password = "foobar"

  additional_users = [
    {
      name     = "tftest2"
      password = "abcdefg"
      host     = "localhost"
      type     = "BUILT_IN"
    },
    {
      name     = "tftest3"
      password = "abcdefg"
      host     = "localhost"
      type     = "BUILT_IN"
    },
  ]
}




/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# resource "random_id" "suffix" {
#   byte_length = 5
# }

# locals {
#   /*
#     Random instance name needed because:
#     "You cannot reuse an instance name for up to a week after you have deleted an instance."
#     See https://cloud.google.com/sql/docs/mysql/delete-instance for details.
#   */
#   network_name = "${var.network_name}-safer-${random_id.suffix.hex}"
# }

# module "network-safer-mysql-simple" {
#   source  = "terraform-google-modules/network/google"
#   version = "~> 4.0"

#   project_id   = var.project
#   network_name = local.network_name

#   subnets = []
# }

# module "private-service-access" {
#   source      = "../../modules/private_service_access"
#   project_id  = var.project
#   vpc_network = module.network-safer-mysql-simple.network_name
# }

# module "safer-mysql-db" {
#   source               = "../../../modules/safer_mysql"
#   name                 = var.db_name
#   random_instance_name = true
#   project_id           = var.project

#   deletion_protection = false

#   database_version = "MYSQL_5_6"
#   region           =  var.region
#   zone             =  var.location
#   tier             = "db-n1-standard-1"

#   // By default, all users will be permitted to connect only via the
#   // Cloud SQL proxy.
#   additional_users = [
#     {
#       name     = "abc-app"
#       password = "PaSsWoRd"
#       host     = "localhost"
#       type     = "BUILT_IN"
#     },
#     {
#       name     = "readonly"
#       password = "PaSsWoRd"
#       host     = "localhost"
#       type     = "BUILT_IN"
#     },
#   ]

#   assign_public_ip   = "true"
#   vpc_network        = module.network-safer-mysql-simple.network_self_link
#   allocated_ip_range = module.private-service-access.google_compute_global_address_name

#   // Optional: used to enforce ordering in the creation of resources.
#   module_depends_on = [module.private-service-access.peering_completed]
# }
