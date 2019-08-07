#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_rmi.coffee
# 

ws_rmi = require('ws_rmi')
{ App_Server, App_Client } = ws_rmi
{ App_Object, App_Stub } = ws_rmi
{ App_Admin_Object, App_Admin_Stub } = ws_rmi

#----------------------------------------------------------------------

class DB_App_Server extends App_Server

  constructor: (app_id, db, options) ->
    super(app_id, options)

    for name, table of db.tables
      app_obj = new DB_App_Table( name, table)
      @add_app_obj( app_obj)
      @load( app_obj.id)

class DB_App_Client extends App_Client
  constructor: (app_id, db, options) ->
    super(app_id, options)




#----------------------------------------------------------------------



class DB_App_Table extends App_Object

  method_names = [
    'find_all',
    'find_by_id',
    'find_by_primary_key',
    'find_where'
    ]
  constructor: (name, table) ->
    super(name, table, method_names)



  
  # TODO:
  # Remember these methods return Promises !!!
  # Where can I add an 'await' ?


    
class DB_App_Table_Stub  extends App_Stub
  method_names = [
    'find_all',
    'find_by_id',
    'find_by_primary_key',
    'find_where'
    ]
  constructor: (id, name) ->
    super(id, name, method_names)



class DB_App_Admin_Stub extends App_Admin_Stub

  constructor: ->
    super()

  init_cb: (result) =>
    #console.log(result)
    for name, id of result
      table_stub = new DB_App_Table_Stub(id,name)


exports.DB_App_Server = DB_App_Server
exports.DB_App_Client = DB_App_Client
