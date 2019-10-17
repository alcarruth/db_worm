#!/bin/bash

root_dir=/var/www/git/projects/web-worm
lib_dir="${root_dir}/lib"
src_dir="${root_dir}/src"

function build {
    
    pushd ${root_dir}
    rm -rf ${lib_dir}
    mkdir -p ${lib_dir}
    coffee -c -o ${lib_dir} ${src_dir}/lib/*.coffee
    coffee -c -o ${root_dir} ${src_dir}/*.coffee
    popd
}

build
