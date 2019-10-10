#!/bin/bash

root_dir=/var/www/git/projects/web-worm
build_dir="${root_dir}/lib"
src_dir="${root_dir}/src"


function build_client {
    
    pushd ${build_dir}
    rm -rf ./client
    mkdir -p ./client
    popd
    
    pushd ${src_dir}/client
    coffee -c -o ${build_dir}/client db_orm.coffee db_rmi_client.coffee index.coffee
    cp package.json ${build_dir}/client
    popd

    pushd ${build_dir}/client
    rm -rf node_modules
    npm i
    popd

}

function build_server {
    
    pushd ${build_dir}
    rm -rf ./server
    mkdir -p ./server
    popd
    
    pushd ${src_dir}/server
    coffee -c -o ${build_dir}/server db_obj.coffee db_rmi_server.coffee index.coffee
    cp package.json ${build_dir}/server
    popd

    pushd ${build_dir}/server
    rm -rf node_modules
    npm i
    popd
}

function build {

    rm -rf ${build_dir}
    mkdir -p ${build_dir}

    coffee -c -o ${build_dir} ${src_dir}/index.coffee

    build_client
    build_server
}

build
