#!/usr/bin/env coffee
#
# file: /src/lib/index.coffee
# package: web-worm
# 

{ DB_RMI_Client } = require('./db_rmi_client')
{ DB_RMI_Server } = require('./db_rmi_server')

module.exports = {
  DB_RMI_Client
  DB_RMI_Server
}
