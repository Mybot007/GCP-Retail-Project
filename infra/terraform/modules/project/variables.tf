variable "project_id" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "folder_id" {
  type    = string
  default = null
  # optional: "folders/123456789012"
}
