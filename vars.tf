variable "AWS_REGION" {
  default = "ap-south-1"
}

variable "PROJECT_TAG" {
  default = "ci-project"
}

variable "KEY_NAME" {
  default = "ci-key"
}

variable "PUBLIC_KEY_NAME" {
  default = "key.pub"
}

variable "SG_NAME" {
  type = "map"
  default {
    Jenkins = "JenkinsSG"
    Nexus = "NexusSG"
    Sonar = "SonarSG"
  }
}

variable "AMIS" {
  type = "map"
  default {
    Jenkins = "ami-0caf778a172362f1c"
    Nexus = "ami-0d81306eddc614a45"
    Sonar = "ami-000ed5810ea2ca0a0"
  }
}

variable "INSTANCE_TYPE" {
  type = "map"
  default {
    Jenkins = "t2.small"
    Nexus = "t2.medium"
    Sonar = "t2.medium"
  }
}

variable "INSTANCE_NAME" {
  type = "map"
  default {
    Jenkins = "JenkinsServer"
    Nexus = "NexusServer"
    Sonar = "SonarServer"
  }
}

variable "PROVISIONING_SCRIPT" {
  type = "map"
  default {
    Jenkins = "./provision/jenkins.sh"
    Nexus = "./provision/nexus.sh"
    Sonar = "./provision/sonar.sh"
  }
}
