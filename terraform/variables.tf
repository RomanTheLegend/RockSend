variable "get_regions_pkg" {
  default     = "../packages/get_regions.zip"
  description = "File name for get_regions lambda"
}

variable "base_layer_pkg" {
  default     = "../packages/base_layer.zip"
  description = "Common libraries to be shared by all Lambdas"
}