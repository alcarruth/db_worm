#!/usr/bin/env coffee
# -*- coding: utf-8 -*-

class Local_Method
  
  constructor: (@method) ->

  __method: (name) =>
    @name = name
    return @method
  
class Column

  constructor: ->
  
  __method: (name) =>
    @name = name
    try
      @__column_method()
    catch error
      console.log("Error in #{@constructor.name} method.")
        

class Reference extends Column

  constructor: (table_name, key_name) ->
    super()
    @table_name = table_name
    @key_name = key_name

  __column_method: =>
    table_name = @table_name
    key_name = @key_name
    return () ->
      table = @__db.tables[table_name]
      key = @__obj[key_name]
      table.find_by_id(key)


class Back_Reference extends Column

  constructor: (table_name, col) ->
    super()
    @table_name = table_name
    @col = col
    
  __column_method: =>
    table_name = @table_name
    col = @col
    return () ->
      table = @__db.tables[table_name]
      id = @__id
      table.find_where(col, id)


class SQL_Column extends Column

  constructor: ->
    super()
        
  __column_method: =>
    name = @name
    return () ->
      @__obj[name]

class SQL_String extends SQL_Column
class SQL_Integer extends SQL_Column
class SQL_Date extends SQL_Column


#------------------------------------------------------------------------------------
# meta classes extended by the definitions below
# 

# An instance of class Table corresponds to a table in the PostgreSQL
# DB.  Note that the constructor argument includes a reference to a
# Row_Class which must be an instance of class Table_Row (below).
 
class Table

  constructor: (spec) ->
    @__db = spec.db
    @__name = spec.tablename
    @__primary_key = spec.primary_key
    @__sql_columns = spec.sql_columns || []
    @__pseudo_columns = spec.pseudo_columns || []
    @__Row_Class = @__row_class(this)
    @__rows = {}
    @__db.tables[@__name] = this
    @__unique_id = "table-#{@__name}"
    @__add_methods()

  __row_class: (table) ->
     class __Row_Class extends Table_Row
      constructor: (obj) ->
        super(table, obj)
        
  __add_methods: =>
    for name, column of @__sql_columns
      @__Row_Class::[name] = column.__method(name)
    for name, column of @__pseudo_columns
      @__Row_Class::[name] = column.__method(name)

  # TODO: insert into DB
  insert: (obj) =>
    cols = (k for k,v of @__sql_columns)
    text = "insert into #{@__name}(#{cols.join(',')})"
    values = (obj[col] for col in cols)
    console.log("Trying query:\n  text: \"#{text}\"\n  values: [ #{values} ]\n")
    try
     # db.query(text, values)
    catch error
      console.log(error)
    
  __add_row: (obj) => 
    row = new @__Row_Class(obj)
    @__rows[row.get_primary_key()] = row

  find_all: (id) =>
    text = "select * from #{@__name}"
    values = [ ]
    try
      rows = @__db.query(text, values)
      return (new @__Row_Class(row) for row in await rows)
    catch error
      console.log("Query failed:\n  text: \"#{text}\"\n  values: [ #{values} ]\n")
      console.log(error)

  find_by_id: (id) =>
    #text = "select * from #{@__name} where #{@__primary_key} = $1 "
    #values = [ id ]
    text = "select * from #{@__name} where #{@__primary_key} = '#{id}' "
    values = [ ]
    try
      rows = @__db.query(text, values)
      return new @__Row_Class((await rows)[0])
    catch error
       console.log(error)

  find_where: (col, val) =>
    #text = "select * from #{@__name} where #{col} = '$1' "
    #values = [ val ]
    text = "select * from #{@__name} where #{col} = '#{val}' "
    values = [ ]
    try
      rows = @__db.query(text, values)
      return (new @__Row_Class(row) for row in await rows)
    catch error
      console.log("Query failed:\n  text: \"#{text}\"\n  values: [ #{values} ]\n")
      console.log(error)
      
  __remove_row: (id) =>
    delete @__rows[id]


# Class Table_Row is the companion to class Table (above)
# Note that the constructor requires a @__table argument.
# Classes which extend Table Row must call super(table)
# in order to link the row type to the appropriate table
# instance.
# 
class Table_Row

  constructor: (@__table, @__obj) ->
    @__db = @__table.__db
    for name, method of this.__proto__
      this[name] = method.bind(this)
    @__id = @__obj[@__table.__primary_key]
    @__unique_id = "#{@__table.__name}-#{@__id}"
      
  simple_obj: =>
    obj = {}
    for col, val of @__obj
      obj[col] = val
    return obj
    
  toJSON: =>
    JSON.stringify(@simple_obj())
      
  toString: =>
    return @toJSON()
    
  toHTML: =>
    # some suitable default


exports.Table = Table
exports.Table_Row = Table_Row

exports.SQL_Column = SQL_Column
exports.SQL_String = SQL_String
exports.SQL_Integer = SQL_Integer
exports.SQL_Date = SQL_Date

exports.Reference = Reference
exports.Local_Method = Local_Method
exports.Back_Reference = Back_Reference


