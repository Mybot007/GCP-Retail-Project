resource "google_pubsub_topic" "t" {
  for_each = toset(var.topics)
  name     = each.value
}
