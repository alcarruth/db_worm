#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_rmi_client.coffee
# 

ws_rmi = require('ws-rmi')
{ DB_ORM } = require('./db_orm')


class DB_RMI_Connection extends ws_rmi.Connection

  init_db: =>
    @init_stubs()
    .then(()=>
      @db = new DB_ORM(@stubs.db_obj)
      return @db)

  
class DB_RMI_Client extends ws_rmi.Client
  constructor: (options) ->
    objects = []
    super(objects, options, DB_RMI_Connection)


exports.DB_RMI_Client = DB_RMI_Client
  
