#!/bin/bash

#root_dir=/var/www/git/projects/web-worm
root_dir="."
lib_dir="${root_dir}/lib"
src_dir="${root_dir}/src"

function clean {
    echo "rm -rf ${lib_dir}"
    rm -rf ${lib_dir}
    echo "rm *.js"
    rm *.js
}

function build {
    echo "building web-worm/lib"
    pushd ${root_dir} > /dev/null
    mkdir -p ${lib_dir}
    coffee -c -o ${lib_dir} ${src_dir}/lib/*.coffee > /dev/null
    coffee -c -o ${root_dir} ${src_dir}/*.coffee > /dev/null
    popd > /dev/null
}
