#!/usr/bin/env node

require('coffeescript/register')

//db_worm = require('./js/db_worm')

db_worm = require('./src/db_worm')

Table = db_worm.Table
Table_Row = db_worm.Table_Row

SQL_Column = db_worm.SQL_Column
SQL_String = db_worm.SQL_String
SQL_Integer = db_worm.SQL_Integer
SQL_Date = db_worm.SQL_Date

Reference = db_worm.Reference
Back_Reference = db_worm.Back_Reference
Local_Method = db_worm.Local_Method

exports.Table = Table
exports.Table_Row = Table_Row

exports.SQL_Column = SQL_Column
exports.SQL_String = SQL_String
exports.SQL_Integer = SQL_Integer
exports.SQL_Date = SQL_Date

exports.Reference = Reference
exports.Back_Reference = Back_Reference
exports.Local_Method = Local_Method



