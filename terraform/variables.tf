variable "get_areas_pkg" {
  default     = "../packages/get_areas.zip"
  description = "File name for get_areas lambda"
}

variable "get_regions_pkg" {
  default     = "../packages/get_regions.zip"
  description = "File name for get_regions lambda"
}

variable "get_sectors_pkg" {
  default     = "../packages/get_sectors.zip"
  description = "File name for get_sectors lambda"
}

variable "get_walls_pkg" {
  default     = "../packages/get_walls.zip"
  description = "File name for get_walls lambda"
}

variable "get_routes_pkg" {
  default     = "../packages/get_routes.zip"
  description = "File name for get_routes lambda"
}

variable "base_layer_pkg" {
  default     = "../packages/base_layer.zip"
  description = "Common libraries to be shared by all Lambdas"
}