#!/usr/bin/env coffee
#
# file: /src/lib/db_rmi_server.coffee
# package: web-worm
# 

ws_rmi = require('ws-rmi')
{ DB_Object } = require('./db_obj')
{ DB_ORM } = require('./db_orm')


# class DB_RMI_Object()
#
# DB_RMI_Object takes args which allow it to create a DB_Object which
# is then made remotable by the call to the superclass WS_RMI_Object.
# Note that DB_RMI_Object is used only by DB_RMI_Server (below) and is
# not exported.
# 
class DB_RMI_Object extends ws_rmi.Object
  constructor: (pg_options, options) ->
    db_obj = new DB_Object(pg_options)
    method_names = ['query']
    super('db_obj', db_obj, method_names, options)


# class DB_RMI_Server()
#
# DB_RMI_Server takes args used to create a DB_RMI_Object which is then
# used in a list of objects to be provided by WS_RMI_Server
# 
class DB_RMI_Server extends ws_rmi.Server
  constructor: (db_schema, pg_options, options) ->
    db_rmi_obj = new DB_RMI_Object(pg_options, options)
    objects = [db_rmi_obj]
    super(objects, options)
    @db = new DB_ORM(db_rmi_obj, db_schema)


exports.DB_RMI_Server = DB_RMI_Server
