#!/usr/bin/env node

exports.client = {
  DB_ORM: require('./lib/db_orm').DB_ORM,
  DB_RMI_Client: require('./lib/db_rmi_client').DB_RMI_Client
};

exports.server = {
  DB_Object: require('./lib/db_obj').DB_Object,
  DB_RMI_Server: require('./lib/db_rmi_server').DB_RMI_Server 
};

