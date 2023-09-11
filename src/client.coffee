#!/usr/bin/env coffee
#
#  web-worm/src/client/index.coffee
# 

DB_ORM = require('./lib/db_orm').DB_ORM
DB_RMI_Client = require('./lib/db_rmi_client').DB_RMI_Client

exports.DB_ORM = DB_ORM
exports.DB_RMI_Client = DB_RMI_Client

