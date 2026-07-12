variable "namespace" { type = string }
variable "backend_image" { type = string }
variable "frontend_image" { type = string }
variable "backend_replicas" { type = number }
variable "frontend_replicas" { type = number }
variable "mongo_storage_size" { type = string }

variable "mongo_uri" {
  type      = string
  sensitive = true
}
