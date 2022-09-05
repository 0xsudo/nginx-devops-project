variable "profile" {
    description = "Profile used to connect to AWS"
}

variable "region" {
    description = "Region of resources deployment"
}

variable "group" {
    description = "Used by ansible to group hosts"
}

variable "name" {
    description = "Name of instance being launched"
}

variable "instance_type" {
    description = "Type of instance being launched"
    default = "t2.micro"    
}