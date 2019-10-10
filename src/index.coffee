#!/usr/bin/env coffee
#
# src/index.coffee
# 

client = require('./client')
exports.DB_ORM = client.DB_ORM
exports.DB_RMI_Client = client.DB_RMI_Client

server = require('./server')
exports.DB_Object = server.DB_Object
exports.DB_RMI_Server = server.DB_RMI_Server 
