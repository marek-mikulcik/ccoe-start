tags = {
  source      = "CCoE"
  apmid       = "GRPWARESP"
  zone        = "dev"
}

resourceGroup  = "grpwaresp-dev-ccoe-rg"             # Resource group where the solution will be deployed
# Configuration for the Log analytics workspace, modify parameters to meet your requirements
lawConfig = {
  resourceName = "grpwaresp-dev-ccoe-law"
}