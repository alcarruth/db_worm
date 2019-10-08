#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_rmi_server.coffee
# 

ws_rmi = require('ws-rmi')

# { DB_ORM } = require('./db_orm')
{ DB_Object } = require('./db_obj')


class DB_RMI_Object extends ws_rmi.Object
  constructor: (pg_options, db_schema, log_level) ->
    db_obj = new DB_Object(pg_options, db_schema)
    method_names = ['query', 'get_db_schema']
    super('db_obj', db_obj, method_names, log_level) 


class DB_RMI_Server extends ws_rmi.Server
  constructor: (options, pg_options, db_schema) ->
    db_rmi_obj = new DB_RMI_Object(pg_options, db_schema)
    super(options, [db_rmi_obj])


exports.DB_RMI_Server = DB_RMI_Server
