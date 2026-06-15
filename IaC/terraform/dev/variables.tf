# Cluster

variable "cluster_name" {
  description = "The name of the Minikube cluster"
  type        = string
  default     = "shop-cluster"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes to use for the Minikube cluster"
  type        = string
  default     = "v1.30.0"
}

variable "cluster_cpus" {
  description = "The number of CPUs to allocate to the Minikube cluster"
  type        = number
  default     = 4
}

variable "cluster_memory" {
  description = "The amount of memory to allocate to the Minikube cluster"
  type        = string
  default     = "8192mb"
}

variable "cluster_disk_size" {
  description = "The size of the disk to allocate to the Minikube cluster"
  type        = string
  default     = "30gb"
}


# Application

variable "namespace" {
  description = "The Kubernetes namespace for the shop application"
  type        = string
  default     = "shop"
}

variable "backend_image" {
  description = "The Docker image for the backend service"
  type        = string
  default     = "shop-backend:latest"
}

variable "frontend_image" {
  description = "The Docker image for the frontend service"
  type        = string
  default     = "shop-frontend:latest"
}

variable "backend_replicas" {
  description = "The number of replicas for the backend service"
  type        = number
  default     = 2
}

variable "frontend_replicas" {
  description = "The number of replicas for the frontend service"
  type        = number
  default     = 2
}

# MongoDB

variable "mongo_uri" {
  description = "The connection URI for the MongoDB database"
  type      = string
  sensitive = true
}

variable "mongo_storage_size" {
    description = "The size of the persistent storage for MongoDB"
    type        = string
    default     = "5Gi"
}

# Monitoring

variable "monitoring_namespace" {
    description = "namespace for monitoring tools prometheus and grafana"
    type        = string
    default     = "monitoring"
}

variable "grafana_admin_password" {
    description = "Admin password for Grafana"
    type        = string
    sensitive   = true
}

variable "prometheus_chart_version" {
    description = "Version of the Prometheus Helm chart"
    type        = string
    default     = "65.1.1"
}