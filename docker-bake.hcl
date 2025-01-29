variable "REGISTRY" {
  default = "123456789012.dkr.ecr.us-east-1.amazonaws.com"
}

variable "TAG" {
  default = "latest"
}

variable "PYTHON_VERSION" {
  default = "3.13"
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
  context    = "./src"
  dockerfile = "Dockerfile"
  target     = "app"
  platforms  = ["linux/arm64"]
  args = {
    PYTHON_VERSION = PYTHON_VERSION
    USER_UID       = USER_UID
    USER_GID       = USER_GID
    USER_NAME      = USER_NAME
    MODEL_GGUF_URL = MODEL_GGUF_URL
  }
  cache_from = ["type=gha"]
  cache_to   = ["type=gha,mode=max"]
  pull       = true
  push       = false
  load       = true
  provenance = false
}
