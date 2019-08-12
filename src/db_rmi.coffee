#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_orm.coffee
# 

ws_rmi = require('ws_rmi')

class DB_RMI_Server extends ws_rmi.Server
  constructor: (db, options) ->
    objects = []
    for table in db.tables
      name = table.__name
      console.log name
      method_names = table.__method_names
      objects.push(new ws_rmi.Object(name, table, method_names))
    super(options, objects)


class DB_RMI_Client extends ws_rmi.Client
  constructor: (options) ->
    super(options, [])


exports.DB_RMI_Client = DB_RMI_Client
exports.DB_RMI_Server = DB_RMI_Server
