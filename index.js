#!/usr/bin/env node

db_orm = require('./js/db_orm');

Table = db_orm.Table
Table_Row = db_orm.Table_Row

SQL_Column = db_orm.SQL_Column
SQL_String = db_orm.SQL_String
SQL_Integer = db_orm.SQL_Integer
SQL_Date = db_orm.SQL_Date

Reference = db_orm.Reference
Back_Reference = db_orm.Back_Reference
Local_Method = db_orm.Local_Method

exports.Table = Table;
exports.Table_Row = Table_Row;

exports.SQL_Column = SQL_Column;
exports.SQL_String = SQL_String;
exports.SQL_Integer = SQL_Integer;
exports.SQL_Date = SQL_Date;

exports.Reference = Reference;
exports.Back_Reference = Back_Reference;
exports.Local_Method = Local_Method;

