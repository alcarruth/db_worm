#!/usr/bin/env node

db_orm = require('./js/db_orm');

Table = db_orm.Table
Table_Row = db_orm.Table_Row

String_Column = db_orm.String_Column
Integer_Column = db_orm.Integer_Column
Date_Column = db_orm.Date_Column

Reference = db_orm.Reference
Back_Reference = db_orm.Back_Reference

exports.Table = Table;
exports.Table_Row = Table_Row;
exports.String_Column = String_Column;
exports.Integer_Column = Integer_Column;
exports.Date_Column = Date_Column;
exports.Reference = Reference;
exports.Back_Reference = Back_Reference;

