#!/usr/bin/env coffee
#
# file: /src/client.coffee
# package: web-worm
# 

{ DB_Object, DB_ORM } = require('db-worm/src')
DB_RMI_Client = require('./lib')

module.exports = {
  DB_Object
  DB_ORM
  DB_RMI_Client
}

