#!/usr/bin/env node

require('coffeescript/register')

DB_ORM = require('./src/db_orm').DB_ORM
DB_Object = require('./src/db_orm').DB_Object
DB_RMI_Server = require('./src/db_rmi_server').DB_RMI_Server
DB_RMI_Client = require('./src/db_rmi_client').DB_RMI_Client

exports.DB_ORM = DB_ORM
exports.DB_Object = DB_Object

exports.DB_RMI_Server = DB_RMI_Server 
exports.DB_RMI_Client = DB_RMI_Client
