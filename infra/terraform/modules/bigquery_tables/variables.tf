variable "project_id" { type = string }

variable "tables" {
  description = "Table specs"
  type = list(object({
    dataset_id  = string
    table_id    = string
    description = optional(string)
    labels      = optional(map(string), {})
    schema      = optional(string, "")

    partitioning = optional(object({
      type                     = string # DAY | HOUR | MONTH | YEAR
      field                    = optional(string)
      expiration_ms            = optional(number)
      require_partition_filter = optional(bool, true)
    }))

    clustering = optional(list(string), [])
    view_query = optional(string, "")
    external = optional(object({
      source_uris   = list(string)
      source_format = string
      autodetect    = optional(bool, false)
      csv_options = optional(object({
        skip_leading_rows     = optional(number, 1)
        field_delimiter       = optional(string, ",")
        quote                 = optional(string, "\"")
        allow_quoted_newlines = optional(bool, true)
        encoding              = optional(string, "UTF-8")
      }), null)
      hive_partitioning_options = optional(object({
        mode              = optional(string)
        source_uri_prefix = optional(string)
      }), null)
    }), null)

    # optional absolute epoch ms for per-table TTL
    expiration_time = optional(number)
  }))
}
