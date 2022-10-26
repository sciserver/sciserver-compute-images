#!/bin/bash -i


# By default, if no test is specified (heasoft | ciao | fermi | xmmsas), run all of them
heasoft=0; ciao=0; fermi=0; xmmsas=0

if ( [ "$#" == "1" ] && [[ $1 == *"history"* ]] ) || [ "$1" == "all" ]; then
    echo option-1
    heasoft=1; ciao=1; fermi=1; xmmsas=1
else
    for i in $@; do
        if [ $i == "heasoft" ];  then 
            heasoft=1; continue
        elif [ $i == "ciao" ];   then 
            ciao=1; continue
        elif [ $i == "fermi" ];  then 
            fermi=1; continue
        elif [ $i == "xmmsas" ]; then 
            xmmsas=1; continue
        elif [ $i == "all" ]; then 
            heasoft=1; ciao=1; fermi=1; xmmsas=1; continue
        else
            echo "** ERROR: Unrecognized option $i"
            exit 1
        fi
    done
fi



echo
echo "**************************"
echo "Running scierver tests ..."
echo "**************************"
echo


test_dir=`dirname $0`
for image in heasoft ciao fermi xmmsas; do
    
    if [ ${!image} == "1" ]; then
        echo
        echo "Testing the ($image) environment"
        echo "----------------------------------"
        echo
        if conda activate $image; then
            echo "Activated $image"
        else
            printf "** ERROR: No ($image) conda environment.\n"
            exit 1
        fi
        if python $test_dir/test_$image.py; then
            echo "**************************"
            echo "Tests for ($image) passed successfully"
            echo "**************************"
        else
            echo "**************************"
            echo "** ERROR: Tests for ($image) failed."
            echo "**************************"
            exit 1
        fi
    fi

done
