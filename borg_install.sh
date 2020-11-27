#!/usr/bin/env bash

# SETTINGS (you can leave all of them as is)


default_bakrepo=server:repo
default_mountpoint=/mnt/backup
default_hostname=192.168.1.2

# Uncomment and edit IF you want to set alternate url for borg binary:
# alt_download_link=http://my.server.local/borg_bin


# You can leave this as is:
borgversion="1.1.14"
key=borg_id_rsa
keypub=borg_id_rsa.pub
shdir=borg
sshuser=borg


# You must charge this script with ssh keys before deploy
# or connect to remote repository.
# Run script with -h to see details.
read -d '' borg_id_rsa << EOF
EOF

read -d '' borg_id_rsa_pub << EOF
EOF

read -d ''  backup_blkdev_create_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpiYWtyZXBvPXJlcG8KRElTSz0vZGV2L3Nk
YQpiYWtwcmVmaXg9cHJlZml4CgpleHBvcnQgTEFORz1lbl9VUy5VVEY4CgpIRUFERVJfU0laRT0k
KHNmZGlzayAtbG8gU3RhcnQgJERJU0sgfCBncmVwIC1BMSAtUCAnU3RhcnQkJyB8IHRhaWwgLW4x
IHwgeGFyZ3MgZWNobykKUEFSVElUSU9OUz0kKHNmZGlzayAtbG8gRGV2aWNlLFR5cGUgJERJU0sg
fCBzZWQgLWUgJzEsL0RldmljZVxzKlR5cGUvZCcpCmRkIGlmPSRESVNLIGNvdW50PSRIRUFERVJf
U0laRSB8IGJvcmcgY3JlYXRlIC0tc3RhdHMgICR7YmFrcmVwb306OiR7YmFrcHJlZml4fS1wYXJ0
aW5mbyAtCiMgYmFja3VwIG50ZnMgcGFydGl0aW9uczoKZWNobyAiJFBBUlRJVElPTlMiIHwgZ3Jl
cCBOVEZTIHwgY3V0IC1kJyAnIC1mMSB8IHdoaWxlIHJlYWQgeDsgZG8KICAgIFBBUlROVU09JChl
Y2hvICR4IHwgZ3JlcCAtRW8gIlswLTldKyQiKQogICAgbnRmc2Nsb25lIC1zbyAtICR4IHwgYm9y
ZyBjcmVhdGUgLS1zdGF0cyAgICR7YmFrcmVwb306OiR7YmFrcHJlZml4fS1wYXJ0JFBBUlROVU0g
LQpkb25lCiMgYmFja3VwIG5vbi1OVEZTIHBhcnRpdGlvbnM6CmVjaG8gIiRQQVJUSVRJT05TIiB8
IGdyZXAgLXYgTlRGUyB8IGN1dCAtZCcgJyAtZjEgfCB3aGlsZSByZWFkIHg7IGRvCiAgICBQQVJU
TlVNPSQoZWNobyAkeCB8IGdyZXAgLUVvICJbMC05XSskIikKICAgIGJvcmcgY3JlYXRlIC0tcmVh
ZC1zcGVjaWFsIC0tc3RhdHMgICR7YmFrcmVwb306OiR7YmFrcHJlZml4fS1wYXJ0JFBBUlROVU0g
JHgKZG9uZQo=
EOF

read -d ''  backup_blkdev_restore_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpiYWtyZXBvPXJlcG8KRElTSz0vZGV2L3Nk
YQpiYWtwcmVmaXg9cHJlZml4CgpleHBvcnQgTEFORz1lbl9VUy5VVEY4CgpyZWFkIC1wICJSZXN0
b3JlIHBhcnRpdGlvbnM/OiA/IFt5L05dOiAiIHluCmNhc2UgJHluIGluCiAgICBbWXldKiApIGVj
aG87OwogICAgW05uXSogKSBlY2hvICJFeGl0LiIgO2V4aXQ7OwogICAgKiApIGVjaG8gIkV4aXQu
IjsgZXhpdDs7CmVzYWMKCmJvcmcgZXh0cmFjdCAtLXN0ZG91dCAke2Jha3JlcG99Ojoke2Jha3By
ZWZpeH0tcGFydGluZm8gfCBkZCBvZj0kRElTSyAmJiBwYXJ0cHJvYmUKUEFSVElUSU9OUz0kKHNm
ZGlzayAtbG8gRGV2aWNlLFR5cGUgJERJU0sgfCBzZWQgLWUgJzEsL0RldmljZVxzKlR5cGUvZCcp
CmJvcmcgbGlzdCAtLWZvcm1hdCB7YXJjaGl2ZX17Tkx9ICR7YmFrcmVwb30gfCBncmVwICdwYXJ0
WzAtOV0qJCcgfCB3aGlsZSByZWFkIHg7IGRvCiAgICBQQVJUTlVNPSQoZWNobyAkeCB8IGdyZXAg
LUVvICJbMC05XSskIikKICAgIFBBUlRJVElPTj0kKGVjaG8gIiRQQVJUSVRJT05TIiB8IGdyZXAg
LUUgIiRESVNLcD8kUEFSVE5VTSIgfCBoZWFkIC1uMSkKICAgIGlmIGVjaG8gIiRQQVJUSVRJT04i
IHwgY3V0IC1kJyAnIC1mMi0gfCBncmVwIC1xIE5URlM7IHRoZW4KICAgICAgICBib3JnIGV4dHJh
Y3QgLS1zdGRvdXQgJHtiYWtyZXBvfTo6JHggfCBudGZzY2xvbmUgLXJPICQoZWNobyAiJFBBUlRJ
VElPTiIgfCBjdXQgLWQnICcgLWYxKSAtCiAgICBlbHNlCiAgICAgICAgYm9yZyBleHRyYWN0IC0t
c3Rkb3V0ICR7YmFrcmVwb306OiR4IHwgZGQgb2Y9JChlY2hvICIkUEFSVElUSU9OIiB8IGN1dCAt
ZCcgJyAtZjEpCiAgICBmaQpkb25lCg==
EOF

read -d '' backup_create_lvm_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpsdm1zPSJsdm5hbWUxIGx2bmFtZTIiCnZn
PSJ2Z25hbWUiCmJha3JlcG89IiIKCiMgT1BUSU9OQUwKc25hcHN1ZmZpeD1zbmFwCgoKCiMgQkVH
SU4KYmVnaW5kaXI9IiQocHdkKSIKYmFrcm9vdD0vdG1wL2JvcmdiYWtyb290CgppZiBbWyAiJHti
YWtyZXBvfSIgPX4gLio6LiogXV07IHRoZW4KICAgIGhvc3Q9JChlY2hvICRiYWtyZXBvIHwgY3V0
IC1kICc6JyAtZiAxKQogICAgc3NoICR7aG9zdH0gaG9zdG5hbWUgPiAvZGV2L251bGwgMj4mMSAm
JiAgZWNobyBTU0ggY2hlY2s6IE9LIHx8IHsgZWNobyBTU0ggY2hlY2s6IEZhaWxlZCEgOyBleGl0
IDE7IH0KZmkKCm1rZGlyIC1wICRiYWtyb290IHx8IGV4aXQgMTsKCnN5bmMKCiMgY3JlYXRlIHNu
YXBzaG90cwpmb3IgbHYgaW4gJGx2bXM7CmRvCiAgICBiYWtzbmFwPSIke2x2fSR7c25hcHN1ZmZp
eH0iCiAgICBsdmNyZWF0ZSAtcyAtTDUwME0gLW4gJHtiYWtzbmFwfSAvZGV2LyR7dmd9LyR7bHZ9
IHx8IGV4aXQgMTsKZG9uZTsKCiMgbW91bnQgc25hcHNob3RzCmZvciBsdiBpbiAkbHZtczsKZG8K
ICAgIGJha3NuYXA9IiR7bHZ9JHtzbmFwc3VmZml4fSIKICAgIGJrcGluPSIke2Jha3Jvb3R9LyR7
bHZ9IgogICAgbWtkaXIgLXAgICRia3BpbgogICAgbW91bnQgLW8gInJvIiAvZGV2LyR7dmd9LyR7
YmFrc25hcH0gJHtia3Bpbn0gfHwgZXhpdCAxOwogICAgZWNobyAvZGV2LyR7dmd9LyR7YmFrc25h
cH0gbW91bnRlZCB0byAke2JrcGlufQpkb25lOwoKCgojIGJhY2t1cApjZCAiJGJha3Jvb3QiCmJv
cmcgY3JlYXRlIC0tc3RhdHMgLS1udW1lcmljLW93bmVyICAke2Jha3JlcG99OjoiJHt2Z30te25v
dzolWS0lbS0lZF8lSC0lTS0lU30iIC4KY2QgIiRiZWdpbmRpciIKc3luYwpzbGVlcCA1CgoKIyB1
bm1vdW50IGFuZCByZW1vdmUgc25hcHNob3RzCmVjaG8KZWNobyBVbm1vdW50IGFuZCByZW1vdmUg
c25hcHNob3RzLi4uCmZvciBsdiBpbiAkbHZtczsKZG8KICAgIGJha3NuYXA9IiR7bHZ9JHtzbmFw
c3VmZml4fSIKICAgIGJrcGluPSIke2Jha3Jvb3R9LyR7bHZ9IgogICAgdW1vdW50ICR7YmtwaW59
IHx8IGV4aXQgMTsKICAgIGx2cmVtb3ZlIC15IC9kZXYvJHt2Z30vJHtiYWtzbmFwfSB8fCBleGl0
IDE7CmRvbmU7CgoKZWNobwplY2hvIHJlbW92aW5nIG9sZCBiYWNrdXBzLi4uCmJvcmcgcHJ1bmUg
IC0tc3RhdHMgIC0tcHJlZml4ICIke3ZnfS0iIC0ta2VlcC13aXRoaW4gMmQgLS1rZWVwLWRhaWx5
IDcgLS1rZWVwLXdlZWtseSA4IC0ta2VlcC1tb250aGx5IDEyICR7YmFrcmVwb30gJiYgZWNobyBS
ZW1vdmUgb2xkIGJhY2t1cHM6IE9LIHx8IHsgZWNobyBSZW1vdmUgb2xkIGJhY2t1cHM6IEZhaWxl
ZDsgZXhpdCAxOyB9Cgo=
EOF

read -d '' backup_create_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89cmVwbwpiYWtwcmVmaXg9cHJl
Zml4CgoKYm9yZyBjcmVhdGUgLS1zdGF0cyAtLW51bWVyaWMtb3duZXIgICAke2Jha3JlcG99Ojoi
JHtiYWtwcmVmaXh9LXtub3c6JVktJW0tJWRfJUgtJU0tJVN9IiAvIFwKICAgIC0tZXhjbHVkZSAn
L2Rldi8qJyBcCiAgICAtLWV4Y2x1ZGUgJy9wcm9jLyonIFwKICAgIC0tZXhjbHVkZSAnL3J1bi8q
JyBcCiAgICAtLWV4Y2x1ZGUgJy9zeXMvKicKCmJvcmcgcHJ1bmUgIC0tc3RhdHMgLS1wcmVmaXgg
IiR7YmFrcHJlZml4fS0iIC0ta2VlcC13aXRoaW4gMmQgLS1rZWVwLWRhaWx5IDcgLS1rZWVwLXdl
ZWtseSA4IC0ta2VlcC1tb250aGx5IDEyICR7YmFrcmVwb30K
EOF

read -d '' backup_mount_sh << EOF
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89cmVwbwptbnRkaXI9L3RtcC9i
b3JnYmFja3VwCgpta2RpciAtcCAiJHttbnRkaXJ9IiAgfHwgZXhpdDsKY2htb2QgNzc3ICIke21u
dGRpcn0iIHx8IGV4aXQ7CmJvcmcgbW91bnQgLW8gYWxsb3dfb3RoZXIgICIke2Jha3JlcG99IiAi
JHttbnRkaXJ9IiB8fCBleGl0OwplY2hvIGJhY2t1cCBtb3VudHBvaW50OiAke21udGRpcn0gIHx8
IGV4aXQ7Cm1jICIke21udGRpcn0iCmJvcmcgdW1vdW50ICIke21udGRpcn0iICYmIGVjaG8gdW1v
dW50IGNvbXBsZXRlCgo=
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
    --no-download)
    NODOWNLOAD=true
    shift # past argument
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

Options:
    --no-download -- skip borg downloading (also check 
                     "alt_download_link=" in head of this script)


Before deploying server or client with connection to remote storage,
you must charge this script with your ssh-keys:

    $(basename $0) -k /path/to/private_key -p /path/to/public_key

or generate new keys:

    $(basename $0) -g

in both ways keys will be encoded as base64 and saved right into this script.

If you have no connetion to internet, you have 2 choices:
1. Use "alt_download_link" variable in the beginning of this script
   to set alternative for download link (intranet server or something)
2. Install borg binary manually and after this use key --no-download 
   with -s or -c to prevent download attempts.
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
		read -p "enter address for $(echo $bakrepo | cut -d ':' -f1) [${default_hostname}]: " hostname
		if [ -z ${hostname} ]; then hostname=${default_hostname}; fi
		read -p "enter ssh port for $(echo ${hostname}) [22]: " port
		if [ -z ${port} ]; then port=22; fi
		cfghead="# borg cfg begin"
		cfgtail="# borg cfg end"
		cfgbody="Host ${host}\n  HostName ${hostname}\n  User ${sshuser}\n  Port ${port}\n  IdentityFile ~/.ssh/borg_id_rsa"
		if grep -q "${cfghead}" ${sshconfig} && grep -q "${cfgtail}" ${sshconfig}; then
			sed  -e "/^${cfghead}/,/${cfgtail}/c\\${cfghead}\n${cfgbody}\n${cfgtail}" -i ${sshconfig}
		else
			echo -en "${cfghead}\n${cfgbody}\n${cfgtail}" >> ${sshconfig}
		fi
		echo
		echo "Checking ssh connection to ${host} (${hostname})"
		ssh ${host} hostname > /dev/null 2>&1 && echo -en  "  connection: OK\n" || { echo -en "  connection: failed\n" ; exit 1; }
	fi

	if [[  ${NODOWNLOAD} = true ]]; then
		echo Skipping downloading borg
	else
		rm /usr/local/bin/borg
		echo downloading borg to /usr/local/bin/borg
		if [ -z ${alt_download_link} ]; then
			wget --no-verbose -c  https://github.com/borgbackup/borg/releases/download/${borgversion}/borg-linux64 -O /usr/local/bin/borg
		else
			wget --no-verbose -c  ${alt_download_link}  -O /usr/local/bin/borg
		fi
		chmod +x /usr/local/bin/borg || exit;
	fi

	# CREATING SCRIPTS
	mkdir -p  "${HOME}/${shdir}/"
	echo
	echo creating files in "${HOME}/${shdir}/"
	base64 -d <<< ${backup_create_sh} > "${HOME}/${shdir}/backup_create.sh"
	base64 -d <<< ${backup_create_lvm_sh} > "${HOME}/${shdir}/backup_create_lvm.sh"
	base64 -d <<< ${backup_mount_sh} > "${HOME}/${shdir}/backup_mount.sh"
	base64 -d <<< ${backup_blkdev_create_sh} > "${HOME}/${shdir}/backup_blkdev_create.sh"
	base64 -d <<< ${backup_blkdev_restore_sh} > "${HOME}/${shdir}/backup_blkdev_restore.sh"
	chmod +x "${HOME}/${shdir}"/*.sh

	# CHANGING DEFAULT SETTINGS IN SCRIPTS
	echo
	echo set  bakrepo=${bakrepo} in:
	sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_create.sh" &&\
		echo " ${HOME}/${shdir}/backup_create.sh: OK"
	sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_create_lvm.sh" &&\
		echo " ${HOME}/${shdir}/backup_create_lvm.sh: OK"
	sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_mount.sh" &&\
		 echo " ${HOME}/${shdir}/backup_mount.sh: OK"
	sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_blkdev_create.sh" &&\
		echo " ${HOME}/${shdir}/backup_blkdev_create.sh: OK"
	sed  -e "s/^\(bakrepo=\).*$/\1${bakrepo}/g" -i "${HOME}/${shdir}/backup_blkdev_restore.sh" &&\
		 echo " ${HOME}/${shdir}/backup_blkdev_restore.sh: OK"

	echo set bakprefix=full${HOSTNAME} in:
	sed  -e "s/^\(bakprefix=\).*$/\1full${HOSTNAME}/g" -i "${HOME}/${shdir}/backup_blkdev_create.sh" &&\
		echo " ${HOME}/${shdir}/backup_blkdev_create.sh: OK"
	sed  -e "s/^\(bakprefix=\).*$/\1full${HOSTNAME}/g" -i "${HOME}/${shdir}/backup_blkdev_restore.sh" &&\
		echo " ${HOME}/${shdir}/backup_blkdev_restore.sh: OK"
	sed  -e "s/^\(bakprefix=\).*$/\1${HOSTNAME}/g" -i "${HOME}/${shdir}/backup_create.sh" &&\
		echo " ${HOME}/${shdir}/backup_create.sh: OK"


	echo set mntdir=${mountpoint} in:
	sed  -e "s|^\(mntdir=\).*$|\1${mountpoint}|g" -i "${HOME}/${shdir}/backup_mount.sh" &&\
		echo " ${HOME}/${shdir}/backup_mount.sh: OK"
	echo

	echo checking repository
	borg list ${bakrepo} > /dev/null 2>&1 && echo repository found || read -p "try to init new repo? ${bakrepo} [y/N]" initnewrepo
	if [[ $initnewrepo = "y" ]]; then borg init -e none ${bakrepo}; fi

	echo 
	echo Setup complete. Please check and edit settings in:  "${HOME}/${shdir}/*.sh"
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

	if [[ -z NODOWNLOAD ]]; then
		echo Skip download and install borg
	else
		rm /usr/local/bin/borg
		echo downloading borg to /usr/local/bin/borg
		if [ -z ${alt_download_link} ]; then
			wget --no-verbose -c  https://github.com/borgbackup/borg/releases/download/${borgversion}/borg-linux64 -O /usr/local/bin/borg
		else
			wget --no-verbose -c  ${alt_download_link}  -O /usr/local/bin/borg
		fi
		chmod +x /usr/local/bin/borg || exit;
	fi

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


