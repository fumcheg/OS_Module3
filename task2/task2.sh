#!/bin/bash

ARCHIVE="/archive"
if [ ! -d $ARCHIVE ]
then
	mkdir $ARCHIVE
fi

tar cpf "$ARCHIVE/my-backup.tar" \
/home/fumo/Documents/bash/ \
/var/log/ \
/etc/ssh \
/etc/xrdp \
/etc/vsftpd.conf

