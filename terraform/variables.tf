variable "gcp_svc_key" {
  type = string
}

variable "startup_script" {
  type = string
}

variable "project_id" {
  type = string
}

variable "region" {
  type = list(string)
}

variable "zone" {
  type = string
}

variable "vm_roles" {
  type        = list(string)
  default     = []
  description = "roles for management vm's service account"
}

variable workerload_cidr {
  type        = string
  default     = ""
  description = "Cidr range for workerload subnet"
}

variable control_plane_cidr {
  type        = string
  default     = ""
  description = "Cidr range for control plane"
}

variable management_cidr {
  type        = string
  default     = ""
  description = "Cidr range of management subnet"
}


variable "machine_type" {
  type        = string
  default     = ""
  description = "the management instance machine type"
}

variable "image" {
  type        = string
  default     = ""
  description = "management vm OS image"
}

variable "workers_machine_type" {
  type        = string
  default     = ""
  description = "the worker pool's machines type"
}

variable "workers_image" {
  type        = string
  default     = ""
  description = "workers pool OS image"
}

variable "workers_disk" {
  type        = number
  default     = 50
  description = "workers pool disk size"
}

variable "network_tags" {
  type        = list(string)
  default     = []
  description = "network tags for the management vm"
}

variable "scopes" {
  type    = list(string)
  default = ["cloud-platform"]
}
