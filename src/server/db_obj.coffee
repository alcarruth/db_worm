#!/usr/bin/env coffee
# -*- coding: utf-8 -*-
#
#  db_obj.coffee
# 

pg = require('pg')

#-------------------------------------------------------------------------------
# CLASS DB_Object
#

class DB_Object

  constructor: (@pg_options, @db_schema) ->
    @pool = new pg.Pool(@pg_options)

  get_db_schema: =>
    return new Promise((resolve, reject) =>
      try
        resolve(@db_schema)
      catch
        reject("Could not get @db_schema."))
      
    
  query: (text, values) =>

    try
      client = await @pool.connect().catch ->
        throw new Error("Failed to connect.")
      result = await client.query(text, values).catch ->
        throw new Error("Failed to query.")
      client.release()
      return result.rows

    catch error
      msg = "Query failed.\n text: \"#{text}\"\n values: [#{values}]\n"
      throw new Error(msg)


exports.DB_Object = DB_Object
