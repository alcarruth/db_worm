#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_rmi_client.coffee
# 

ws_rmi = require('ws-rmi')
WS_RMI_Connection = ws_rmi.Connection
WS_RMI_Client = ws_rmi.Client
{ DB_ORM } = require('./db_orm')


class DB_RMI_Connection extends WS_RMI_Connection

  init_db: =>
    @init_stubs()
    .then(()=>
      @db = new DB_ORM(@stubs.db_obj)
      return @db)

  
class DB_RMI_Client extends WS_RMI_Client
  constructor: (options, log_level) ->
    console.log("DB_RMI_Client")
    super(options, [], DB_RMI_Connection, log_level)


exports.DB_RMI_Client = DB_RMI_Client
  
