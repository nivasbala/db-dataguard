resource "oci_database_db_system" "dbaas" {

  availability_domain = data.oci_identity_availability_domains.ADs_A.availability_domains[var.AD - 1]["name"]
  fault_domains       = ["FAULT-DOMAIN-1", "FAULT-DOMAIN-2"]
  compartment_id      = var.compartment_ocid_a
  cpu_core_count      = 1
  database_edition    = "ENTERPRISE_EDITION_EXTREME_PERFORMANCE"

  lifecycle {
    ignore_changes = [cpu_core_count, ssh_public_keys, fault_domains, defined_tags, db_home[0].database[0].defined_tags]
  }

  db_home {
    database {
      admin_password = "WElcome1234##"
      db_name        = "testdb"
      db_workload    = "OLTP"

      db_backup_config {
        auto_backup_enabled = "false"
      }
    }

    db_version   = "19.0.0.0"
    display_name = "testdb"
  }

  disk_redundancy = "HIGH"
  shape           = "VM.Standard2.2"
  subnet_id       = oci_core_subnet.subnet_01_a.id
  nsg_ids         = []
  #backup_subnet_id        = local.backup_subnet_id
  #backup_network_nsg_ids  = local.backup_network_nsd_ids
  data_storage_size_in_gb = 256
  ssh_public_keys         = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmxN2phGyC/CN9czKtSbTwrHE6KauDL7uQsHUKY0aaocuji8zuAAx1Ghrqg0s5NA3KMWHysG9MiMI2qRS/DbneKPfprg+nv0bAusWpT2zaBplnxlWipLIc1NtMLtabtDAu9koZhf4FUVxgEmmJKWjiEUXh2kNlUy1ZgFXZjADMICNqPW5DfsHsr85do8k0wG0AocPGycw2ZEPB0/kAC8hlKd/h5gzJghpTxRjusgndG4hAzCd4a+y3t6l3xMSCTVjCGEyQtg5t5IUDGhrry3lBVatNbVtoNmXuiNbD6Ui+hdO5LpxpTLRvugALu45YmLIF0nzwwSDEx2+STLW0UC4n opc@srini-dev-vm"]
  display_name            = "testdb"
  hostname                = "testdb"
  cluster_name            = "test"
  license_model           = "BRING_YOUR_OWN_LICENSE"
  node_count              = 1
}


resource "oci_database_data_guard_association" "d_guard_a" {

  # Create New DB System
  creation_type = "NewDbSystem"

  # Same as primary admin password
  database_admin_password = "WElcome1234##"

  # OCID of primary db
  database_id = oci_database_db_system.dbaas.db_home[0].database[0].id

  # Only supports true
  delete_standby_db_home_on_delete = true

  # Only supports MAXIMUM_PERFORMANCE
  protection_mode = "MAXIMUM_PERFORMANCE"


  # Needs to be ASYNC because of protection mode
  transport_type = "ASYNC"

  #Optional
  #availability_domain = data.oci_identity_availability_domains.ADs_B.availability_domains[var.AD - 1]["name"]
  availability_domain = data.oci_identity_availability_domains.ADs_B.availability_domains[var.AD]["name"]
  display_name        = "dr-testdb"
  hostname            = "dr-testdb"
  nsg_ids             = []
  shape               = "VM.Standard2.1"
  subnet_id           = oci_core_subnet.subnet_02_a.id

}
