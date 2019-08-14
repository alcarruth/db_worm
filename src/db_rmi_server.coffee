#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_orm.coffee
# 

if not window?
  ws_rmi = require('ws_rmi')
  WS_RMI_Server = ws_rmi.Server
  WS_RMI_Object = ws_rmi.Object
  { DB_ORM, DB_Object } = require('./db_orm')


class DB_RMI_Object extends WS_RMI_Object
  constructor: (pg_options, db_schema, log_level) ->
    db_obj = new DB_Object(pg_options, db_schema)
    method_names = ['query', 'get_db_schema']
    super('db_obj', db_obj, method_names, log_level) 


class DB_RMI_Server extends WS_RMI_Server
  constructor: (options, pg_options, db_schema) ->
    db_rmi_obj = new DB_RMI_Object(pg_options, db_schema)
    super(options, [db_rmi_obj])


if not window?
  exports.DB_RMI_Server = DB_RMI_Server
