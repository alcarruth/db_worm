#!/usr/bin/env node
//
// package web-worm
// index.js
//

exports.client = require('./lib/client')
exports.server = require('./lib/server')

lib = require('./lib')
exports.DB_ORM = lib.DB_ORM
exports.DB_RMI_Client = lib/.DB_RMI_Client
exports.DB_Object = lib.DB_Object
exports.DB_RMI_Server = lib.DB_RMI_Server
