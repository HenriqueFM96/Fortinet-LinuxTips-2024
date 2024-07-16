#########################################
#              LAB Location             #
#########################################

variable "location" {
    type = string
    default = "Central US"
}

#########################################
#            VAR Spokes TAGs            #
#########################################

// var Content TAG
variable "ContentTAG" {
    type = string
    default = "LinuxTips-"
}

// var PROD TAG
variable "StageTAG_PROD" {
    type = string
    default = "PROD"
}

// var QA TAG
variable "StageTAG_QA" {
    type = string
    default = "QA"
}

// var Spoke_A TAG
variable "TAG_Spoke_A" {
    type = string
    default = "Spoke_A"
}

// var Spoke_B TAG
variable "TAG_Spoke_B" {
    type = string
    default = "Spoke_B"
}

#########################################
#              VAR Attacker             #
#########################################

variable "TAG-attacker" {
    type = string
    default = "attacker"
}

variable "attacker-location" {
    type = string
    default = "Brazil South"
}

// Attacker vNET
variable "Attacker_VNET" {
    type = string
    default = "192.168.0.0/24"
}

// Attacker Subnet
variable "Attacker_subnet" {
    type = string
    default = "192.168.0.0/24"
}

##########################################
#            Spokes Variables            #
##########################################

// Spoke A vNET
variable "spoke_A_VNET" {
    type = string
    default = "172.16.0.0/16"
}

// Spoke A Subnet 01
variable "spoke_A_subnet01" {
    type = string
    default = "172.16.1.0/24"
}

// Spoke A Subnet 02
variable "spoke_A_subnet02" {
    type = string
    default = "172.16.2.0/24"
}

// Spoke B vNET
variable "spoke_B_VNET" {
    type = string
    default = "172.31.0.0/16"
}

// Spoke B Subnet 01
variable "spoke_B_subnet01" {
    type = string
    default = "172.31.0.0/24"
}

// Spokes' VM-Size & Family
variable "spoke-vm-size" {
  type    = string
  default = "Standard_B1s"
}

// Spokes' VM username
variable "spoke-vm-username" {
  type = string
  default = "adminuser"
}

// Spokes' VM Password
variable "spoke-vm-password" {
    type = string
    default = "Fortinet@LinuxTips#2024"
}

