#!/usr/bin/env bash

# SETTINGS
sshuser=borg
shdir=borg

default_bakrepo=backup:qiwinote_bak
default_mountpoint=/mnt/backup
default_hostname=192.168.1.2

# alt_download_link=http://my.server.local/borg_bin


borgversion="1.1.14"
key=borg_id_rsa
keypub=borg_id_rsa.pub


# You must charge this script with ssh keys before deploy
# or connect to remote repository.
# Run script with -h to see details.
read -d '' borg_id_rsa << EOF
EOF

read -d '' borg_id_rsa_pub << EOF
EOF

read -d ''  backup_blkdev_create_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpiYWtyZXBvPSJiYWNrdXA6cWl3aW5vdGVf
YmFrIgpESVNLPS9kZXYvc2RhCmJha3ByZWZpeD1mdWxscWl3aW5vdGUKCmV4cG9ydCBMQU5HPWVu
X1VTLlVURjgKCkhFQURFUl9TSVpFPSQoc2ZkaXNrIC1sbyBTdGFydCAkRElTSyB8IGdyZXAgLUEx
IC1QICdTdGFydCQnIHwgdGFpbCAtbjEgfCB4YXJncyBlY2hvKQpQQVJUSVRJT05TPSQoc2ZkaXNr
IC1sbyBEZXZpY2UsVHlwZSAkRElTSyB8IHNlZCAtZSAnMSwvRGV2aWNlXHMqVHlwZS9kJykKZGQg
aWY9JERJU0sgY291bnQ9JEhFQURFUl9TSVpFIHwgYm9yZyBjcmVhdGUgLS1zdGF0cyAgJHtiYWty
ZXBvfTo6JHtiYWtwcmVmaXh9LXBhcnRpbmZvIC0KIyBiYWNrdXAgbnRmcyBwYXJ0aXRpb25zOgpl
Y2hvICIkUEFSVElUSU9OUyIgfCBncmVwIE5URlMgfCBjdXQgLWQnICcgLWYxIHwgd2hpbGUgcmVh
ZCB4OyBkbwogICAgUEFSVE5VTT0kKGVjaG8gJHggfCBncmVwIC1FbyAiWzAtOV0rJCIpCiAgICBu
dGZzY2xvbmUgLXNvIC0gJHggfCBib3JnIGNyZWF0ZSAtLXN0YXRzICAgJHtiYWtyZXBvfTo6JHti
YWtwcmVmaXh9LXBhcnQkUEFSVE5VTSAtCmRvbmUKIyBiYWNrdXAgbm9uLU5URlMgcGFydGl0aW9u
czoKI2VjaG8gIiRQQVJUSVRJT05TIiB8IGdyZXAgLXYgTlRGUyB8IGN1dCAtZCcgJyAtZjEgfCB3
aGlsZSByZWFkIHg7IGRvCiMgICAgUEFSVE5VTT0kKGVjaG8gJHggfCBncmVwIC1FbyAiWzAtOV0r
JCIpCiMgICAgYm9yZyBjcmVhdGUgLS1yZWFkLXNwZWNpYWwgLS1zdGF0cyAgJHtiYWtyZXBvfTo6
JHtiYWtwcmVmaXh9LXBhcnQkUEFSVE5VTSAkeAojZG9uZQo=
EOF

read -d ''  backup_blkdev_restore_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpiYWtyZXBvPSJiYWNrdXA6cWl3aW5vdGVf
YmFrIgpESVNLPS9kZXYvc2RhCmJha3ByZWZpeD1mdWxscWl3aW5vdGUKCmV4cG9ydCBMQU5HPWVu
X1VTLlVURjgKCnJlYWQgLXAgIlJlc3RvcmUgcGFydGl0aW9ucz86ID8gW3kvTl06ICIgeW4KY2Fz
ZSAkeW4gaW4KICAgIFtZeV0qICkgZWNobzs7CiAgICBbTm5dKiApIGVjaG8gIkV4aXQuIiA7ZXhp
dDs7CiAgICAqICkgZWNobyAiRXhpdC4iOyBleGl0OzsKZXNhYwoKYm9yZyBleHRyYWN0IC0tc3Rk
b3V0ICR7YmFrcmVwb306OiR7YmFrcHJlZml4fS1wYXJ0aW5mbyB8IGRkIG9mPSRESVNLICYmIHBh
cnRwcm9iZQpQQVJUSVRJT05TPSQoc2ZkaXNrIC1sbyBEZXZpY2UsVHlwZSAkRElTSyB8IHNlZCAt
ZSAnMSwvRGV2aWNlXHMqVHlwZS9kJykKYm9yZyBsaXN0IC0tZm9ybWF0IHthcmNoaXZlfXtOTH0g
JHtiYWtyZXBvfSB8IGdyZXAgJ3BhcnRbMC05XSokJyB8IHdoaWxlIHJlYWQgeDsgZG8KICAgIFBB
UlROVU09JChlY2hvICR4IHwgZ3JlcCAtRW8gIlswLTldKyQiKQogICAgUEFSVElUSU9OPSQoZWNo
byAiJFBBUlRJVElPTlMiIHwgZ3JlcCAtRSAiJERJU0twPyRQQVJUTlVNIiB8IGhlYWQgLW4xKQog
ICAgaWYgZWNobyAiJFBBUlRJVElPTiIgfCBjdXQgLWQnICcgLWYyLSB8IGdyZXAgLXEgTlRGUzsg
dGhlbgogICAgICAgIGJvcmcgZXh0cmFjdCAtLXN0ZG91dCAke2Jha3JlcG99OjokeCB8IG50ZnNj
bG9uZSAtck8gJChlY2hvICIkUEFSVElUSU9OIiB8IGN1dCAtZCcgJyAtZjEpIC0KICAgIGVsc2UK
ICAgICAgICBib3JnIGV4dHJhY3QgLS1zdGRvdXQgJHtiYWtyZXBvfTo6JHggfCBkZCBvZj0kKGVj
aG8gIiRQQVJUSVRJT04iIHwgY3V0IC1kJyAnIC1mMSkKICAgIGZpCmRvbmUK
EOF

read -d '' backup_create_lvm_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpsdm1zPSJob21lIHJvb3QiCnZnPSJxaXdp
bm90ZSIKYmFrcmVwbz0iYmFja3VwOnFpd2lub3RlX2JhayIKCiMgT1BUSU9OQUwKc25hcHN1ZmZp
eD1zbmFwCgoKCiMgQkVHSU4KYmVnaW5kaXI9IiQocHdkKSIKYmFrcm9vdD0vdG1wL2JvcmdiYWty
b290Cm1rZGlyIC1wICRiYWtyb290IHx8IGV4aXQ7CgpzeW5jCgojIGNyZWF0ZSBzbmFwc2hvdHMK
Zm9yIGx2IGluICRsdm1zOwpkbwogICAgYmFrc25hcD0iJHtsdn0ke3NuYXBzdWZmaXh9IgogICAg
bHZjcmVhdGUgLXMgLUwxRyAtbiAke2Jha3NuYXB9IC9kZXYvJHt2Z30vJHtsdn0gfHwgZXhpdDsK
ZG9uZTsKCiMgbW91bnQgc25hcHNob3RzCmZvciBsdiBpbiAkbHZtczsKZG8KICAgIGJha3NuYXA9
IiR7bHZ9JHtzbmFwc3VmZml4fSIKICAgIGJrcGluPSIke2Jha3Jvb3R9LyR7bHZ9IgogICAgbWtk
aXIgLXAgICRia3BpbgogICAgbW91bnQgLW8gInJvIiAvZGV2LyR7dmd9LyR7YmFrc25hcH0gJHti
a3Bpbn0gfHwgZXhpdDsKICAgIGVjaG8gL2Rldi8ke3ZnfS8ke2Jha3NuYXB9IG1vdW50ZWQgdG8g
JHtia3Bpbn0KZG9uZTsKCgoKIyBiYWNrdXAKY2QgIiRiYWtyb290Igpib3JnIGNyZWF0ZSAtLXN0
YXRzICAke2Jha3JlcG99OjoiJHt2Z30te25vdzolWS0lbS0lZF8lSC0lTS0lU30iIC4KY2QgIiRi
ZWdpbmRpciIKc3luYwpzbGVlcCA1CgojIHVubW91bnQgYW5kIHJlbW92ZSBzbmFwc2hvdHMKZm9y
IGx2IGluICRsdm1zOwpkbwogICAgYmFrc25hcD0iJHtsdn0ke3NuYXBzdWZmaXh9IgogICAgYmtw
aW49IiR7YmFrcm9vdH0vJHtsdn0iCiAgICB1bW91bnQgJHtia3Bpbn0gfHwgZXhpdDsKICAgIGx2
cmVtb3ZlIC15IC9kZXYvJHt2Z30vJHtiYWtzbmFwfSB8fCBleGl0Owpkb25lOwoKZWNobyByZW1v
dmluZyBvbGQgYmFja3Vwcy4uLgpib3JnIHBydW5lICAtLXN0YXRzIC0ta2VlcC13aXRoaW4gMmQg
LS1rZWVwLWRhaWx5IDcgLS1rZWVwLXdlZWtseSA4IC0ta2VlcC1tb250aGx5IDEyICR7YmFrcmVw
b30K
EOF

read -d '' backup_create_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89YmFja3VwOnFpd2ljaHVwYS5u
ZXQKYmFrbmFtZT1xaXdpY2h1cGEubmV0CgoKYm9yZyBjcmVhdGUgLS1zdGF0cyAgJHtiYWtyZXBv
fTo6IiR7YmFrbmFtZX0te25vdzolWS0lbS0lZF8lSC0lTS0lU30iIC8gXAogICAgLS1leGNsdWRl
ICcvdmFyL0JUU3luY19Sb290LyonIFwKICAgIC0tZXhjbHVkZSAnL2Rldi8qJyBcCiAgICAtLWV4
Y2x1ZGUgJy9wcm9jLyonIFwKICAgIC0tZXhjbHVkZSAnL3J1bi8qJyBcCiAgICAtLWV4Y2x1ZGUg
Jy9zeXMvKicKCmJvcmcgcHJ1bmUgIC0tc3RhdHMgLS1rZWVwLXdpdGhpbiAyZCAtLWtlZXAtZGFp
bHkgNyAtLWtlZXAtd2Vla2x5IDggLS1rZWVwLW1vbnRobHkgMTIgJHtiYWtyZXBvfQo=
EOF

read -d '' backup_mount_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89YmFja3VwOnFpd2lub3RlX2Jh
awptbnRkaXI9L21udC9iYWNrdXAKCm1rZGlyIC1wICIke21udGRpcn0iICB8fCBleGl0OwpjaG1v
ZCA3NzcgIiR7bW50ZGlyfSIgfHwgZXhpdDsKYm9yZyBtb3VudCAtbyBhbGxvd19vdGhlciAgIiR7
YmFrcmVwb30iICIke21udGRpcn0iIHx8IGV4aXQ7CmVjaG8gYmFja3VwIG1vdW50cG9pbnQ6ICR7
bW50ZGlyfSAgfHwgZXhpdDsKbWMgIiR7bW50ZGlyfSIKYm9yZyB1bW91bnQgIiR7bW50ZGlyfSIg
JiYgZWNobyB1bW91bnQgY29tcGxldGUKCg==
EOF


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--help)
    SHOWHELP=true
    shift # past argument
    ;;
    -r|--role)
    ROLE="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--client)
    ROLE=client
    shift # past argument
    ;;
    -s|--server)
    ROLE=server
    shift # past argument
    ;;
    -g|--gen-keys)
    GENKEYS=true
    shift # past argument
    ;;
    --clean-keys)
    CLEANKEYS=true
    shift # past argument
    ;;
    -p|--pub-key)
    PUBKEY="$2"
    shift # past argument
    shift # past value
    ;;
     -k|--private-key)
    PRIVATEKEY="$2"
    shift # past argument
    shift # past value
    ;;  --default)
    DEFAULT=YES
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}"


if [[ $SHOWHELP  ]]; then
read -d '' help << EOF
Usage:

    $(basename $0) -s,--server -- deploy server
    $(basename $0) -c,--client -- deploy client

Before deploying server or client with connection to remote storage,
you must charge this script with your ssh-keys:

    $(basename $0) -k /path/to/private_key -p /path/to/public_key

or generate new keys:

    $(basename $0) -g

in both ways keys will be encoded as base64 and saved right into this script.
EOF

echo "$help"
fi


if [[ $ROLE = "client" ]];then
	read -p "enter backup repository [${default_bakrepo}]: " bakrepo
	if [ -z ${bakrepo} ]; then bakrepo=${default_bakrepo}; fi
	read -p "enter mountpoint for backup view [${default_mountpoint}]: " mountpoint
	if [ -z ${mountpoint} ]; then mountpoint=${default_mountpoint}; fi

	if [[ "${bakrepo}" =~ .*:.* ]]; then
		if [[ $(echo "${borg_id_rsa}" | wc -l) > 1 && $(echo "${borg_id_rsa_pub}" | wc -l) > 1 ]] ; then
			mkdir -p "${HOME}"/.ssh
			base64 -d <<<  ${borg_id_rsa} > "${HOME}/.ssh/borg_id_rsa"
			chmod 600 "${HOME}/.ssh/borg_id_rsa"
		else
			echo
			echo It seems you want to use remote repository, but SSH KEYS NOT FOUND.
			echo Use "$(basename $0) -h" to check information about ssh keys.
			echo
			exit;
		fi

		sshconfig="$HOME/.ssh/config"
		host=$(echo $bakrepo | cut -d ':' -f1)
		echo "Host ${host}" >> "${sshconfig}"
		read -p "Enter address for $(echo $bakrepo | cut -d ':' -f1) [${default_hostname}]: " hostname
		if [ -z ${hostname} ]; then hostname=${default_hostname}; fi
		echo "    HostName=${hostname}" >> "${sshconfig}"
		echo "    User ${sshuser}" >> "${sshconfig}"
		echo "    IdentityFile ~/.ssh/borg_id_rsa" >> "${sshconfig}"
		echo "checking ssh connection to ${host} (${hostname})"
		ssh ${host} hostname > /dev/null 2>&1 || echo connection failed ; exit;
	fi

	rm /usr/local/bin/borg
	echo downloading borg to /usr/local/bin/borg
	if [ -z ${alt_download_link} ]; then
		wget --no-verbose -c  https://github.com/borgbackup/borg/releases/download/${borgversion}/borg-linux64 -O /usr/local/bin/borg
	else
		wget --no-verbose -c  ${alt_download_link}  -O /usr/local/bin/borg
	fi;
	chmod +x /usr/local/bin/borg || exit;

	# CREATING SCRIPTS
	mkdir -p  "${HOME}/${shdir}/"
	echo creating files in "${HOME}/${shdir}/"
	base64 -d <<< ${backup_create_sh} > "${HOME}/${shdir}/backup_create.sh"
	base64 -d <<< ${backup_create_lvm_sh} > "${HOME}/${shdir}/backup_create_lvm.sh"
	base64 -d <<< ${backup_mount_sh} > "${HOME}/${shdir}/backup_mount.sh"
	base64 -d <<< ${backup_blkdev_create_sh} > "${HOME}/${shdir}/backup_blkdev_create.sh"
	base64 -d <<< ${backup_blkdev_restore_sh} > "${HOME}/${shdir}/backup_blkdev_restore.sh"
	chmod +x "${HOME}/${shdir}"/*.sh

	# CHANGING DEFAULT SETTINGS IN SCRIPTS
	echo adding bakrepo=${bakrepo} to:
	echo " ${HOME}/${shdir}/backup_create.sh"
	 sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_create.sh"
	echo " ${HOME}/${shdir}/backup_create_lvm.sh"
	 sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_create_lvm.sh"
	echo " ${HOME}/${shdir}/backup_mount.sh"
	 sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_mount.sh"
	echo " ${HOME}/${shdir}/backup_blkdev_create.sh"
	 sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_blkdev_create.sh"
	echo " ${HOME}/${shdir}/backup_blkdev_restore.sh"
	 sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_blkdev_restore.sh"

	echo adding bakprefix=full${HOSTNAME} to:
	echo " ${HOME}/${shdir}/backup_blkdev_create.sh"
	 sed  -e "s/^\(bakprefix=\).*$/\1full${HOSTNAME}/g" -i "${HOME}/${shdir}/backup_blkdev_create.sh"
	echo " ${HOME}/${shdir}/backup_blkdev_restore.sh"
	 sed  -e "s/^\(bakprefix=\).*$/\1full${HOSTNAME}/g" -i "${HOME}/${shdir}/backup_blkdev_restore.sh"

	echo adding mntdir=${mountpoint} to:
	echo " ${HOME}/${shdir}/backup_mount.sh"
	 sed  -e "s|^\(mntdir=\).*$|\1${mountpoint}|g" -i "${HOME}/${shdir}/backup_mount.sh"

	echo check and edit settings in "${HOME}/${shdir}/*.sh"

	echo checking repository
	borg list ${bakrepo} || read -p "try to init new repo? ${bakrepo} [y/N]" initnewrepo
	if [[ $initnewrepo = "y" ]]; then borg init -e none ${bakrepo}; fi
fi


if [[ $ROLE = "server" ]]; then
	if [[ $(echo "${borg_id_rsa}" | wc -l) > 1 && $(echo "${borg_id_rsa_pub}" | wc -l) > 1 ]] ; then
		echo
	else
		echo
		echo You want to deploy server for remote repository, but SSH KEYS NOT FOUND.
		echo Use "$(basename $0) -h" to check information about ssh keys.
		echo
		exit;
	fi

	rm /usr/local/bin/borg
	echo downloading borg to /usr/local/bin/borg
	if [ -z ${alt_download_link} ]; then
		wget --no-verbose -c  https://github.com/borgbackup/borg/releases/download/${borgversion}/borg-linux64 -O /usr/local/bin/borg
	else
		wget --no-verbose -c  ${alt_download_link}  -O /usr/local/bin/borg
	fi;
	chmod +x /usr/local/bin/borg || exit;

	useradd -m ${sshuser} || exit;
	mkdir ~${sshuser}/.ssh
	base64 -d <<<  ${borg_id_rsa_pub} > "~${sshuser}/.ssh/borg_id_rsa.pub"
	echo "command=\"/usr/local/bin/borg serve\" $(cat ~${sshuser}/.ssh/borg_id_rsa.pub)" > ~${sshuser}/.ssh/authorized_keys
	chown -R ${sshuser}:${sshuser} ~${sshuser}/.ssh
	chmod 600 -R ~${sshuser}/.ssh
fi

if [[  $PUBKEY  ]]; then
	if test -f "$PUBKEY"; then
		key=$(base64 $PUBKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
		sed  -e "/^read -d '' borg_id_rsa_pub << EOF$/,/^EOF$/c\read -d '' borg_id_rsa_pub << EOF\n${key}\nEOF" -i $(basename "$0")
	fi
fi

if [[  $PRIVATEKEY ]]; then
	if test -f "$PRIVATEKEY"; then
		key=$(base64 $PRIVATEKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
		sed  -e "/^read -d '' borg_id_rsa << EOF$/,/^EOF$/c\read -d '' borg_id_rsa << EOF\n${key}\nEOF" -i $(basename "$0")
	fi
fi


if [[  $GENKEYS ]]; then
	PRIVATEKEY=$(mktemp -u)
	PUBKEY="${PRIVATEKEY}".pub
	ssh-keygen -q -P '' -t rsa -f ${PRIVATEKEY}

	key=$(base64 $PUBKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
	sed  -e "/^read -d '' borg_id_rsa_pub << EOF$/,/^EOF$/c\read -d '' borg_id_rsa_pub << EOF\n${key}\nEOF" -i $(basename "$0")
	key=$(base64 $PRIVATEKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
	sed  -e "/^read -d '' borg_id_rsa << EOF$/,/^EOF$/c\read -d '' borg_id_rsa << EOF\n${key}\nEOF" -i $(basename "$0")
fi

if [[  $CLEANKEYS ]]; then

	sed  -e "/^read -d '' borg_id_rsa_pub << EOF$/,/^EOF$/c\read -d '' borg_id_rsa_pub << EOF\nEOF" -i $(basename "$0")
	sed  -e "/^read -d '' borg_id_rsa << EOF$/,/^EOF$/c\read -d '' borg_id_rsa << EOF\nEOF" -i $(basename "$0")
fi


