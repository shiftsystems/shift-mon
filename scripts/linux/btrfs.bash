#!/bin/bash
for filesystem in /sys/fs/btrfs/*; do
    if [ "${filesystem}" != "/sys/fs/btrfs/features" ]; then
        label=$(cat ${filesystem}/label)
        echo "fs_name=${label} fs_id=${filesystem##*/} node_size_bytes=$(cat ${filesystem}/nodesize)"
        echo "fs_name=${label} fs_id=${filesystem##*/} sector_size_bytes=$(cat ${filesystem}/sector_size)"
        for file in ${filesystem}/bdi/*; do
            test -f ${file} && echo "fs_name=${label} fs_id=${filesystem##*/} bdi_${file##*/}=$(cat ${file})"
        done
        for file in ${filesystem}/discard/*; do
            test -f ${file} && echo "fs_name=${label} fs_id=${filesystem##*/} discard_${file##*/}=$(cat ${file})"
        done
        for file in ${filesystem}/allocation/data/*; do
            test -f ${file} && echo "fs_name=${label} fs_id=${filesystem##*/} data_${file##*/}=$(cat ${file})"
        done
        for file in ${filesystem}/allocation/metadata/*; do
            test -f ${file} && echo "fs_name=${label} fs_id=${filesystem##*/} data_${file##*/}=$(cat ${file})"
        done
        for file in ${filesystem}/allocation/system/*; do
            test -f ${file} && echo "fs_name=${label} fs_id=${filesystem##*/} data_${file##*/}=$(cat ${file})"
        done
        for device in $filesystem/devinfo/*; do
            for stat in $(cat "${device}/error_stats" | sed 's/ /=/g'); do
                echo "fs_name=${label} fs_id=${filesystem##*/} dev_num=${device##*/} $stat"
            done
            echo "fs_name=${label} fs_id=${filesystem##*/} dev_num=${device##*/} missing=$(cat $device/missing)"
            echo "fs_name=${label} fs_id=${filesystem##*/} dev_num=${device##*/} metadata_device=$(cat $device/in_fs_metadata)"
            echo "fs_name=${label} fs_id=${filesystem##*/} dev_num=${device##*/} writeable=$(cat $device/missing)"

        done
        for stat in $(cat $filesystem/commit_stats | sed 's/ /=/g'); do
            echo "fs_name=${label} fs_id=${filesystem##*/} "${stat}""
        done
    fi
done
