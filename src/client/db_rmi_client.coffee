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
  init_stubs: =>
    super().then(@init_db)
  init_db: =>
    @db = new DB_ORM(@stubs.db_obj)

  
class DB_RMI_Client extends WS_RMI_Client
  constructor: (options) ->
    super(options, [], DB_RMI_Connection)


exports.DB_RMI_Client = DB_RMI_Client
  
