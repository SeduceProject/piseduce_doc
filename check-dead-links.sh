#!/bin/bash
WGET_OUTPUT="external_link_check"
LINK_TARGETS=$(grep -R --include "*.md" --exclude "README.md" "\[.*\](" | sed 's:.*\](\(.*\)).*:\1:' | sed 's/#.*//')

for link in $LINK_TARGETS; do
    echo "### Check the target '$link'"
    if [[ $link = http* ]]; then
        wget $link -O $WGET_OUTPUT &> /dev/null
        if [ $? -ne 0 ]; then
            echo "ERROR: $link"
        fi
    else
        # There is no extension
        if [[ $link != *"."* ]]; then
            # Looking for a post in the _posts directory
            res=$(find _posts/ -name "${link:1}*")
            if [ -z "$res" ]; then
                echo "ERROR: $link"
                # Retrieve the file containing the link
                grep -R --include "*.md" $link | cut -d ":" -f1
            fi
        else
            # Remove the beginning /
            if [ ! -e ${link:1} ]; then
                echo "ERROR: $link"
                # Retrieve the file containing the link
                grep -R --include "*.md" $link | cut -d ":" -f1
            fi
        fi
    fi
done
rm -f $WGET_OUTPUT
