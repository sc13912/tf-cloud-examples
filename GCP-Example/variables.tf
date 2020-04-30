
variable "org_id" {
  description = "The organization ID."
  type        = string
  default     = "475923086270"
}

variable "billing_account" {
  description = "The ID of the billing account"
  type        = string
  default     = "0125A3-67DE1E-85451A"
}

variable "billing_account_X" {
  description = "The ID of the billing account"
  type        = string
  default     = "not_in_use"
}

variable "parent_id" {
  type        = string
  description = "Id of the resource under which the folders will be placed."
  default     = "444024479882" #parent folder ID or Org ID
}

variable "parent_type" {
  type        = string
  description = "Type of the parent resource. One of `organizations` or `folders`."
  default     = "folders"
}

variable "common_host" {
  type        = string
  description = "Common services host project"
  default     = "comm-host"
}

variable "common_vpc" {
  type        = string
  description = "Common services VPC"
  default     = "comm-vpc"
}

variable "common_service_1" {
  type        = string
  description = "Common services service project 1"
  default     = "comm-srv-1"
}


variable "prod_host" {
  type        = string
  description = "Prod services host project"
  default     = "prod-host"
}

variable "prod_vpc" {
  type        = string
  description = "Common services VPC"
  default     = "prod-vpc"
}

variable "prod_service_1" {
  type        = string
  description = "Prod services service project 1"
  default     = "prod-srv-1"
}
