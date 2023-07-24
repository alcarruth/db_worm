#!/usr/bin/env coffee
#
# file: /src/lib/db_orm.coffee
# package: web-worm
# 

#-------------------------------------------------------------------------------
#
#  Column definitions
#
#  Each must have a '__method()' method (Yeah, I know. Sorry !-) which
#  returns a method to be added to the @__Row_Class() definition in
#  class Table, (q.v.)  It's convoluted but the end result is that
#  each Table has a corresponding Row_Class method that is used to to
#  create new Table_Rows from a simple Javascript object such as that
#  returned by a db query.
# 

# Class Column is a general superclass for all column classes defined
# below.
# 
class Column

  constructor: (spec) ->
    { @table_name, @col_name, @options } = spec

    # Boolean sql_column indicates that this is a column which can be
    # accessed direcly from a row returned from a database query.  It
    # must be set to true or false in a subclass.
    # 
    @sql_column = undefined

  # __method returns a method to be bound to a row object and used to
  # handle this column of the row.
  __method: =>
    try
      @__column_method()
    catch error
      console.log("Error in #{@constructor.name} method.")


# For a Local_Method the method is provided by the db_schema itself.
# So that's what we return.
# 
class Local_Method extends Column
  
  constructor: (spec) ->
    super(spec)
    @sql_column = false

  # Return method as defined in the db_schema
  # 
  __column_method: =>
    { method } = @options
    return method

  
# A Reference column refers to some other table using a foreign key
# which is held in this column.
# 
class Reference extends Column

  constructor: (spec) ->
    super(spec)
    @sql_column = false

  # The function returned by this method uses the table name and
  # column name to fetch the foreign row.
  # 
  __column_method: =>
    { table_name, col_name } = @options
    return  ->
      table = @__db.tables[table_name]
      key = @__obj[col_name]
      table.find_by_primary_key(key)


# A Back_Reference is used to find rows in another table which refer
# back to the current row object.
# 
class Back_Reference extends Column

  constructor: (spec) ->
    super(spec)
    @sql_column = false

  # The foreign table name and the column name which might refer to
  # the current object are provided in the db_schema
  #   
  __column_method: =>
    { table_name, col_name } = @options
    return ->
      table = @__db.tables[table_name]
      table.find_where(col_name, @__id)


# A SQL_Column is a column which contains primitive PostgreSQL data
# which is stored in the db and can be read from the simple object.
# 
class SQL_Column extends Column

  constructor: (options) ->
    super(options)
    @sql_column = true
        
  __column_method: =>
    name = @col_name
    return () ->
      @__obj[name]


# We define a few classes here each of which corresponds to a Postgres
# datatype.
#
# TODO: Is this useful?  If so, we should perhaps do this for all
# Postgres datatypes and have some functionality specific to each
# type.  Otherwise it seems it might suffice to have just the
# SQL_Column class and forget the subclasses.
# 
class SQL_String extends SQL_Column
class SQL_Integer extends SQL_Column
class SQL_Date extends SQL_Column



  
#-----------------------------------------------------------------------
# CLASS TABLE_ROW
# 
# Class Table_Row is the companion to class Table (below) A Table_Row
# corresponds to a row in the in the PostgreSQL table.  Note that the
# constructor requires a @__table argument.  Classes which extend
# Table Row must call super(table) in order to link the row type to
# the appropriate table instance.
#
# Methods toString() and toHTML() are defined here as defaults.
# Table_Row should be extended and these methods overridden with
# app-specific methods producing the desired pretty strings and html
# code.
# 
class Table_Row

  constructor: (@__table, @__obj) ->
    @__db = @__table.__db
    @__id = @__obj[@__table.__primary_key]
    @__unique_id = "#{@__table.__name}-#{@__id}"

  # Method simple_obj() returns a copy of @__obj 
  simple_obj: =>
    obj = {}
    for col, val of @__obj
      obj[col] = val
    return obj

  # Method toJSON() returns a JSON string 
  toJSON: =>
    JSON.stringify(@simple_obj())
      
  # Method toString() returns a JSON string by default.
  toString: =>
    return @toJSON()
    
  # Not my purview
  toHTML: =>
    # some suitable default



#-------------------------------------------------------------------------------
# CLASS TABLE
# 
# A Table corresponds to a table in the PostgreSQL DB.
#  
class Table

  constructor: (spec) ->
    @__unique_id = "table-#{@__name}"
    @__db = spec.db
    @__name = spec.name
    @__primary_key = spec.primary_key || 'id'
    @__rows = {}
    
    # remotable method names for object stub creation.
    @__method_names = [
      'find_all',
      'find_where',
      'find_one',
      'find_by_id',
      'find_by_primary_key',
      ]

    # A Table object contains row objects which have a method
    # for each column defined in the db_schema.
    # 
    @__row_methods = {}
    for name, column of spec.columns
      @__row_methods[name] = column.__method(name)

    # Associated with each Table is a __Row_Class which handles
    # each row in the Table.  The method defined just below is
    # produces the class.
    # 
    @__Row_Class = @__row_class(this)

  # Method __row_class() returns a class definition suitable for
  # creating a row object for a row in the table.  The object will
  # have methods for accessing each column, as specified by the
  # db_schema.  See the column class definitions at the top of this
  # file.
  # 
  __row_class: (table) ->
    class __Row_Class extends Table_Row
      constructor: (obj) ->
        super(table, obj)
        for name, method of table.__row_methods
          this[name] = method #.bind(this)

  # TODO: insert into DB
  # So far this code has not been exercised.
  # 
  insert: (obj) =>
    cols = (k for k,v of @__sql_columns)
    text = "insert into #{@__name}(#{cols.join(',')})"
    values = (obj[col] for col in cols)
    #console.log("Trying query:\n  text: \"#{text}\"\n  values: [ #{values} ]\n")
    try
     # db.query(text, values)
    catch error
      console.log(error.message)

  # Add a row object.  Note that this does not insert the new
  # row into the DB.
  # 
  add_row: (row) =>
    key = row[@__primary_key]()
    @__rows[key] = row
      
  # Delete a row object.  Note that this does not delete the row from
  # the DB.
  # 
  remove_row: (id) =>
    delete @__rows[id]


  # Method find_all() returns an array containing a row object for each
  # row in the table.
  # 
  find_all: =>
    try
      text = "select * from #{@__name}"
      values = []
      rows = @__db.query(text, values)
      return (new @__Row_Class(row) for row in await rows)
    catch error
      console.log(error.message)


  # Method find_where() returns an array containing all rows where
  # column col has value val.
  # 
  find_where: (col, val) =>
    try
      text = "select * from #{@__name} where #{col} = $1 "
      values = [val]
      rows = await @__db.query(text, values)
      return (new @__Row_Class(row) for row in await rows)
    catch error
      console.log(error.message)


  # Method find_one() returns the first row object in the array
  # returned by method find_where()
  # 
  find_one: (col, val) =>
    (await @find_where(col, val))[0]
  

  # Method find_by_id() returns a row object for a row having the
  # requested id.
  # 
  find_by_id: (id) =>
    @find_one('id', id)


  # Method find_by_primary_key()
  # 
  find_by_primary_key: (val) =>
    @find_one(@__primary_key, val)



#----------------------------------------------------------------------
# CLASS DB_ORM

# Class DB_ORM provides an object-relational-mapping for a database
# which can be accesed by @db_obj and is described by @db_schema.
# 
class DB_ORM

  # TODO: perhaps move this up to column definitions at top of this
  # file?
  # 
  # Dictionary column_Class maps db_schema column types to the
  # apropropriate column class defined above.
  # 
  column_Class:
    string: SQL_String
    integer: SQL_Integer
    date: SQL_Date
    reference: Reference
    back_reference: Back_Reference
    local_method: Local_Method

  # @db_obj: a DB_Object. See ./db_obj.coffee
  # The @db_schema is parsed and used to create the appropriate
  # class definitions for the tables, rows and columns of the db.
  # 
  constructor: (@db_obj, @db_schema) ->
    @init_tables()

  # query the db
  query: (text, values) =>
    @db_obj.query(text, values)

  # Create @tables which is a dict containing each table defined in
  # db_schema.
  # 
  init_tables: =>
    # @db_schema = @db_obj.db_schema
    @tables = {}
    @add_table(name, def) for name, def of @db_schema

  # Add a table to the @tables dict
  # 
  add_table: (table_name, table_def) =>
    columns = {}

    # add each column in the table definition
    for col_name, col_def of table_def
      
      # Get the column type and its options from the column
      # definition.  There's just one key and value.
      # 
      [type, options] = ([k,v] for k,v of col_def)[0]

      # TODO: there should be just one column with primary_key set to
      # true.  We could check for that here but we don't so the last
      # column with primary_key true will become the primary key for
      # the table.
      # 
      primary_key = col_name if options.primary_key

      # Create the appropriate column object for this spec and add it
      # to the columns dict.
      # 
      Column_Class = @column_Class[type]
      columns[col_name] = new Column_Class
        table_name: table_name
        col_name: col_name
        options: options        
  
    # Create the table object with the dict of column objects
    # created above.
    # 
    @tables[table_name] = new Table
      db: this
      name: table_name
      primary_key: primary_key || 'id'
      columns: columns


exports.DB_ORM = DB_ORM
