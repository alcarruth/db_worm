#!/bin/bash

#root_dir=/var/www/git/projects/web-worm
root_dir=/home/carruth/git/web-worm


function build_client {
    
    pushd ${root_dir}
    rm -rf ./client
    mkdir -p ./client
    
    pushd ./src/client
    coffee -c -o ${root_dir}/client db_orm.coffee db_rmi_client.coffee
    cp index.js package.json ${root_dir}/client
    popd

    pushd client
    rm -rf node_modules
    npm i
    popd

    popd
}

function build_server {
    
    pushd ${root_dir}
    rm -rf ./server
    mkdir -p ./server
    
    pushd ./src/server
    coffee -c -o ${root_dir}/server db_obj.coffee db_rmi_server.coffee
    cp index.js package.json ${root_dir}/server
    popd

    pushd server
    rm -rf node_modules
    npm i
    popd

    popd
}


build_client
build_server
