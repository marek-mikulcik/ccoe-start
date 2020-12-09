tags = {
  source      = "CCoE"
  apmid       = "APMID"
  zone        = "dev"
}

resourceGroup  = "apmid-dev-ccoe-rg"             # Resource group where the solution will be deployed
# Configuration for the Log analytics workspace, modify parameters to meet your requirements
lawConfig = {
  resourceName = "apmid-dev-ccoe-law"
}