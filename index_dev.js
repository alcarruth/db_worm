#!/usr/bin/env node

require('coffeescript/register')

db_orm = require('./src/db_orm')
db_rmi = require('./src/db_rmi')

exports.DB_ORM = db_orm.DB_ORM
exports.DB_RMI_Server = db_rmi.DB_App_Server 
exports.DB_RMI_Client = db_rmi.DB_App_Client
