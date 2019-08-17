#!/usr/bin/env node

DB_ORM = require('./db_orm').DB_ORM
DB_Object = require('./db_obj').DB_Object
DB_RMI_Server = require('./db_rmi_server').DB_RMI_Server
DB_RMI_Client = require('./db_rmi_client').DB_RMI_Client

exports.DB_ORM = DB_ORM
exports.DB_Object = DB_Object

exports.DB_RMI_Server = DB_RMI_Server 
exports.DB_RMI_Client = DB_RMI_Client
