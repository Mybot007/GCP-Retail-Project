variable "project_id" { type = string }

variable "datasets" {
  description = "Datasets to create in this project"
  type = list(object({
    dataset_id                      = string
    location                        = string
    description                     = optional(string)
    labels                          = optional(map(string), {})
    default_table_expiration_ms     = optional(number)
    default_partition_expiration_ms = optional(number)
    # Optional dataset-level access; BigQuery dataset roles are READER/WRITER/OWNER
    access = optional(list(object({
      role       = string # "READER" | "WRITER" | "OWNER"
      iam_member = string # e.g. "serviceAccount:sa@p.iam.gserviceaccount.com"
    })), [])
  }))
}
