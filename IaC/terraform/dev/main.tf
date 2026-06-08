resource "minikube_cluster" "shop-cluster" {
  cluster_name = "shop-cluster"
  driver = "docker"
  cpus = 4
  memory = "8192mb"
  disk_size = "30gb"

  apiserver_name = "minikubeCA"  

  addons = [
    "ingress",
    "storage-provisioner",
  ]
}

resource "time_sleep" "wait_for_cluster" {
  depends_on = [minikube_cluster.shop-cluster]
  create_duration = "3m"

}

module "shop_app" {
  source = "../modules"
  depends_on = [time_sleep.wait_for_cluster]
}