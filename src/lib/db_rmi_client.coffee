#!/usr/bin/env coffee
#
# file: /src/lib/db_rmi_client.coffee
# package: web-worm
# 

# for the develop branch only we require the src coffeescript from ws_rmi
ws_rmi = require('ws-rmi')
{ DB_ORM } = require('db-worm')


# Factory function create_Connection_Class()
# 
# This function, create_Connection_Class, exists to address a specific
# problem. My first attempt at this had here instead a plain
# DB_RMI_Connection definition.  The problem was that the db_schema is
# app specific and not known here so it is provided as an arg to the
# DB_RMI_Client constructor (below).  An arg could be added to
# WS_RMI_Client but we want ws_rmi to be agnostic wrt any subclass
# specifics.
#
# So what we have is this class factory function, which is called by
# DB_RMI_Client at construction.  The db_schema is passed in as an arg
# and the appropriate DB_Connection_Class which extends
# WS_RMI_Connection is produced at that time.
# 
create_DB_RMI_Connection = (db_schema) ->

  class DB_RMI_Connection extends ws_rmi.Connection

    constructor: (owner, ws, options) ->
      super(owner, ws, options)
      @db_schema = db_schema

    init_db: =>
      await @init_stubs()
      @db = new DB_ORM(@stubs.db_obj, @db_schema)


# class DB_RMI_Client
#
# DB_RMI_Client provides a DB_RMI_Connection class to WS_RMI_Client
# which will use it to wrap the websocket upon connecting.
# 
class DB_RMI_Client extends ws_rmi.Client

  constructor: (db_schema, options) ->
    objects = []
    DB_RMI_Connection = create_DB_RMI_Connection(db_schema)
    super(objects, options, DB_RMI_Connection)

  connect: =>
    await super.connect()
    @connection.init_db()


exports.DB_RMI_Client = DB_RMI_Client
  
