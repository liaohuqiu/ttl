#!/bin/bash

set -e

prj_dir=$(cd $(dirname $0); pwd -P)

image_version='1.0.3'
image_name="liaohuqiu/cube-box:$image_version"

env='prod'
app_name='cube-box'
container_name='cube-box'

function link_node_modules() {
    if [ -d "$1/node_modules" ]; then
        run_cmd "rm $1/node_modules"
    fi
    run_cmd "ln -sf /opt/node_npm_data/node_modules $1"
}

function build_image() {
    docker build -t $image_name $prj_dir/docker
}

function run() {
    local projects_dir_in_host="$prj_dir/projects"
    link_node_modules $projects_dir_in_host
    local uid=`id -u`
    local args=$(base_docker_args $env $container_name)
    args="$args -v $projects_dir_in_host:/opt/src"
    args="$args -p 3000:3000"
    args="$args -p 8545:8545"
    args="$args -w /opt/src"
    local cmd_args='tail -f /dev/null'
    local cmd="docker run -d $args $image_name $cmd_args"
    run_cmd "$cmd"
}

function stop() {
    stop_container $container_name
}

function restart() {
    stop
    run
}

function create_branch() {
    local cmd=''
    for user in 21_吴迪 22_李一楠 23_白广通 24_陈杨 25_吕翔 26_黄锦涛 27_徐斌 28_费进 29_王子卓 99_liaohuqiu; do
        cmd='cd /Users/srain/git/ggl-smt-4th/Team_C'
        cmd="$cmd; git checkout $user"
        cmd="$cmd; git rebase origin/master"
        cmd="$cmd; git push origin $user"
        echo $cmd
    done
    cmd="cd /Users/srain/git/ggl-smt-4th/Team_C"
    cmd="$cmd; git checkout master"
    echo $cmd
}

function clone_all() {
    local cmd=''
    local base_path='/Users/srain/git/ggl-smt-4th'
    local team_repo_path=''
    for team in Team_A Team_B Team_D Team_E Team_F Team_G Team_H Team_I Team_J; do
        team_repo_path="$base_path/$team"
        cmd="cd $base_path"
        cmd="$cmd; git clone git@github.com:ggl-smt-4th/$team.git $team_repo_path"
        cmd="$cmd; cd $team_repo_path"
        cmd="$cmd; git config user.name liaohuqiu"
        cmd="$cmd; git config user.email liaohuqiu@gmail.com"
        echo $cmd
    done
}

function update_all_team() {
    local cmd=''
    local base_path='/Users/srain/git/ggl-smt-4th'
    local sample_repo_path="$base_path/Team_C"
    local team_repo_path=''
    for team in Team_A Team_B Team_D Team_E Team_F Team_G Team_H Team_I Team_J; do
        team_repo_path="$base_path/$team"
        cmd="rm -rf $team_repo_path/*"
        cmd="$cmd; cp -rf $sample_repo_path/* $team_repo_path/"
        cmd="$cmd; cp -rf $sample_repo_path/.gitignore $team_repo_path/"
        cmd="$cmd; cp -rf $sample_repo_path/.travis.yml $team_repo_path/"
        cmd="$cmd; cd $team_repo_path"
        cmd="$cmd; git add ."
        cmd="$cmd; git commit -a -m 'update from upsteam'"
        cmd="$cmd; git push origin master"
        echo $cmd
    done
}

function rebase() {
    local cmd=''
    for user in 21_吴迪 22_李一楠 23_白广通 24_陈杨 26_黄锦涛 27_徐斌 28_费进 29_王子卓 99_liaohuqiu; do
        cmd='cd /Users/srain/git/ggl-smt-4th/Team_C'
        cmd="$cmd; git checkout $user"
        cmd="$cmd; git rebase origin/$user"
        echo $cmd
    done
    cmd="cd /Users/srain/git/ggl-smt-4th/Team_C"
    cmd="$cmd; git checkout master"
    echo $cmd
}

function copy() {
    local cmd=''
    local dst_dir="/Users/srain/git/ggl-smt-4th/Team_C"
    cmd="rm -rf $dst_dir/projects/*"
    run_cmd "$cmd" || true
    cmd="cp -rf $prj_dir/projects/ $dst_dir/projects"
    run_cmd "$cmd" || true
    run_cmd "rm -rf $dst_dir/projects/lesson-1/contracts/Payroll.sol"
    run_cmd "rm -rf $dst_dir/projects/lesson-2/contracts/Payroll.sol"
}

function attach() {
    local cmd="docker exec $docker_run_fg_mode $container_name bash"
    run_cmd "$cmd"
}

function run_tests() {
    restart
    local cmd='ganache-cli > /dev/null'
    cmd="$cmd & sleep 2; cd /opt/src/lesson-1"
    cmd="$cmd; truffle test"
    local cmd="docker exec $docker_run_fg_mode $container_name bash -c '$cmd'"
    run_cmd "$cmd"
    stop
}

function help() {
	cat <<-EOF
        Valid options are:

            build_image

            run
            stop
            restart

            attach
            
            help                      show this help message and exit

EOF
}

source "$prj_dir/apuppy/bash-files/base.sh"
action=${1:-help}
$action "$@"
