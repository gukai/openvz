#!/bin/sh

# Known snapshot ID
ID=$(uuidgen)
CTID=$1
TEMPPATH=$2
TEMPNAME=$3
 
# Directory used to mount a snapshot
MNTDIR=/var/run/xinvz/${CTID}/mktemp/
mkdir -p $MNTDIR

 
# Take a snapshot without suspending a CT and saving its config
vzctl snapshot $CTID --id $ID --skip-suspend --skip-config
 
# Mount the snapshot taken
vzctl snapshot-mount $CTID --id $ID --target $MNTDIR
 
# Perform a backup using your favorite backup tool
# (tar is just an example)
tar -zcf ${TEMPPATH}/${TEMPNAME}.tar.gz -C $MNTDIR .
 
# Unmount the snapshot
vzctl snapshot-umount $CTID --id $ID
 
# Delete (merge) the snapshot
vzctl snapshot-delete $CTID --id $ID
