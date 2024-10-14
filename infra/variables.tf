variable "region" {
  type    = string
  default = "eastus"
}

variable "chat_model_name" {
  type    = string
  default = "gpt-4o"
}

variable "chat_model_version" {
  type    = string
  default = "2024-08-06"
}

variable "chat_scale_type" {
  type    = string
  description = "values: GlobalStandard, Standard"
  default = "GlobalStandard"
}

variable "embedding_model_name" {
  type    = string
  default = "text-embedding-ada-002"
}

variable "embedding_model_version" {
  type    = string
  default = "2"
}

variable "embedding_scale_type" {
  type    = string
  description = "values: GlobalStandard, Standard"
  default = "Standard"
}
