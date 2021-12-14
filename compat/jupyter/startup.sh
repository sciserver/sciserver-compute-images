#!/bin/bash -l

OPTS=$(getopt -l job,cmdfile:,cwd:,notebook: -- "" $@)
if [[ $? != 0 ]]; then
    echo "bad options"
    exit 1
fi
eval set -- "$OPTS"
while true; do
    case $1 in
        --job) ISJOB=1; shift;;
        --cwd) CWD=$2; shift 2;;
        --cmdfile) CMD=$2; shift 2;;
        --notebook) NB=$2; shift 2;;
        --) shift; break;;
        *) echo "bad options"; exit 1;;
    esac
done

# find conda environments in user volumes and add to kernel list
echo "$(date) - scanning for conda environments"
for uv in /home/idies/workspace/{Storage,Temporary}/*/* /home/idies/workspace/*; do
    if [[ -d ${uv}/conda-meta ]]; then
        name=$(basename $uv)
        displayname="$name (uservolume environment)"
        [[ $uv == /home/idies/workspace/$name ]] && displayname="$name (datavol environment)"
        echo "$(date) - adding environment $displayname"
        ${uv}/bin/python -m ipykernel install --user --name "$name" --display-name "$displayname"
    fi
done
echo "$(date) - completed scanning for conda environments. Starting Jupyter server"

[[ $CWD ]] && cd $CWD

if [[ $ISJOB ]]; then
    echo "$(date) - startup-based job execution selected"
    if [[ $CMD ]]; then
        if [[ ! -f $CMD ]]; then
            echo "$(date) ERROR - command file $CMD not found"
            exit 1
        fi
        bash $CMD >> stdout.txt 2>> stderr.txt
    elif [[ $NB ]]; then
        jupyter nbconvert --to notebook --execute $NB --output $NB --ExecutePreprocessor.allow_errors=False >> stdout.txt 2>> stderr.txt
    fi
    EXIT=$?
    echo "$(date) - job completed, exit status: $EXIT"
    echo "$(date) - JOB stdout ======================================="
    cat stdout.txt
    echo "$(date) - JOB stderr ======================================="
    cat stderr.txt
    exit $EXIT
else
    export SHELL=/bin/bash
    exec jupyter notebook \
         --no-browser \
         --ip=* \
         --notebook-dir=/home/idies/workspace \
         --NotebookApp.token='' \
         --NotebookApp.base_url=$1
fi
