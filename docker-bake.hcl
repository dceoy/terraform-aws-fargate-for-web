variable "REGISTRY" {
  default = "123456789012.dkr.ecr.us-east-1.amazonaws.com"
}

variable "TAG" {
  default = "latest"
}

variable "DEBIAN_VERSION" {
  default = "12"
}

variable "USER_UID" {
  default = 1001
}

variable "USER_GID" {
  default = 1001
}

variable "USER_NAME" {
  default = "fargate"
}

group "default" {
  targets = ["streamlit"]
}

target "streamlit" {
  tags       = ["${REGISTRY}/streamlit-app:${TAG}"]
  context    = "."
  dockerfile = "src/Dockerfile"
  target     = "app"
  platforms  = ["linux/arm64"]
  args = {
    DEBIAN_VERSION = DEBIAN_VERSION
    USER_UID       = USER_UID
    USER_GID       = USER_GID
    USER_NAME      = USER_NAME
  }
  secret     = []
  cache_from = ["type=gha"]
  cache_to   = ["type=gha,mode=max"]
  pull       = true
  push       = false
  load       = true
  provenance = false
}
