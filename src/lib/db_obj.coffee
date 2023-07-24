#!/usr/bin/env coffee
#
# file: /src/lib/db_obj.coffee
# package: web-worm
# 

pg = require('pg')

#-----------------------------------------------------------------------
# CLASS DB_Object
#

# class DB_Object()
# 
# A DB_Object takes as an arg pg_options and provides a method to
# query the database.  This PostgreSQL specific.
# 
class DB_Object

  #constructor: (@pg_options, @db_schema) ->
  constructor: (@pg_options) ->
    @pool = new pg.Pool(@pg_options)

  # method query()
  query: (text, values) =>

    try

      # create connection
      client = await @pool.connect().catch ->
        throw new Error("Failed to connect.")

      # send query and obtain result
      result = await client.query(text, values).catch ->
        throw new Error("Failed to query.")

      # close connection
      client.release()
      return result.rows

    catch error
      msg = "Query failed.\n text: \"#{text}\"\n values: [#{values}]\n"
      throw new Error(msg)


exports.DB_Object = DB_Object
