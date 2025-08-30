terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

locals {
  tables_map = { for t in var.tables : "${t.dataset_id}.${t.table_id}" => t }
}

resource "google_bigquery_table" "t" {
  for_each = local.tables_map

  project    = var.project_id
  dataset_id = each.value.dataset_id
  table_id   = each.value.table_id

  description = try(each.value.description, null)
  labels      = try(each.value.labels, {})

  # per-table absolute epoch ms (optional)
  expiration_time     = try(each.value.expiration_time, null)
  deletion_protection = false

  # View
  dynamic "view" {
    for_each = length(try(each.value.view_query, "")) > 0 ? [1] : []
    content {
      query          = each.value.view_query
      use_legacy_sql = false
    }
  }

  # External table
  dynamic "external_data_configuration" {
    for_each = each.value.external == null ? [] : [each.value.external]
    content {
      source_format = external_data_configuration.value.source_format
      autodetect    = try(external_data_configuration.value.autodetect, false)
      source_uris   = external_data_configuration.value.source_uris

      dynamic "csv_options" {
        for_each = external_data_configuration.value.csv_options == null ? [] : [external_data_configuration.value.csv_options]
        content {
          skip_leading_rows     = try(csv_options.value.skip_leading_rows, 1)
          field_delimiter       = try(csv_options.value.field_delimiter, ",")
          quote                 = try(csv_options.value.quote, "\"")
          allow_quoted_newlines = try(csv_options.value.allow_quoted_newlines, true)
          encoding              = try(csv_options.value.encoding, "UTF-8")
        }
      }

      dynamic "hive_partitioning_options" {
        for_each = external_data_configuration.value.hive_partitioning_options == null ? [] : [external_data_configuration.value.hive_partitioning_options]
        content {
          mode              = try(hive_partitioning_options.value.mode, null)
          source_uri_prefix = try(hive_partitioning_options.value.source_uri_prefix, null)
        }
      }
    }
  }

  # Schema (skip for views or external with autodetect)
  schema = (
    length(try(each.value.view_query, "")) > 0 ||
    (each.value.external != null && try(each.value.external.autodetect, false))
  ) ? null : try(each.value.schema, null)

  # Time partitioning (keep this block as-is)
  dynamic "time_partitioning" {
    for_each = each.value.partitioning == null ? [] : [each.value.partitioning]
    content {
      type                     = time_partitioning.value.type
      field                    = try(time_partitioning.value.field, null)
      expiration_ms            = try(time_partitioning.value.expiration_ms, null)
      require_partition_filter = try(time_partitioning.value.require_partition_filter, true)
    }
  }

  # ✅ Clustering is an attribute (list of strings), NOT a block
  #    Only set it when non-empty; otherwise pass null to omit.
  clustering = length(try(each.value.clustering, [])) == 0 ? null : each.value.clustering
}