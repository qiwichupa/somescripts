#!/usr/bin/env bash

# SETTINGS (you can leave all of them as is)


default_bakrepo=backup:repo
default_mountpoint=/tmp/borgbackup
default_hostname=192.168.1.53

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
read -d '' borg_id_rsa << 'EOF'
EOF

read -d '' borg_id_rsa_pub << 'EOF'
EOF

read -d ''  backup_blkdev_create_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpiYWtyZXBvPWJhY2t1cDpyZXBvCkRJU0s9
L2Rldi9zZGEKYmFrcHJlZml4PXByZWZpeAprZWVwbGFzdG9ubHk9eWVzCgoKCmV4cG9ydCBMQU5H
PWVuX1VTLlVURjgKCiMgY2hlY2sgc3NoCmRhdGUKaWYgW1sgIiR7YmFrcmVwb30iID1+IC4qOi4q
IF1dOyB0aGVuCiAgICBob3N0PSQoZWNobyAkYmFrcmVwbyB8IGN1dCAtZCAnOicgLWYgMSkKICAg
IHNzaCAke2hvc3R9IGhvc3RuYW1lID4gL2Rldi9udWxsIDI+JjEgJiYgIGVjaG8gU1NIIGNoZWNr
OiBPSyB8fCB7IGVjaG8gU1NIIGNoZWNrOiBGYWlsZWQhIDsgZXhpdCAxOyB9CmZpCiMgY2hlY2sg
cmVwbwpib3JnIGxpc3QgJHtiYWtyZXBvfSA+IC9kZXYvbnVsbCAyPiYxICYmICBlY2hvIHJlcG9z
aXRvcnkgY2hlY2s6IE9LICB8fCB7ICBlY2hvIHJlcG9zaXRvcnkgY2hlY2s6IEZhaWxlZDsgZXhp
dCAxOyB9CgoKZGF0ZXN0cj0kKGRhdGUgKyVZJW0lZC0lSCVNJVMpCmZpbGVzY291bnQ9MAoKIyBi
YWNrdXAgZGlzayBoZWFkZXIKSEVBREVSX1NJWkU9JChzZmRpc2sgLWxvIFN0YXJ0ICRESVNLIHwg
Z3JlcCAtQTEgLVAgJ1N0YXJ0JCcgfCB0YWlsIC1uMSB8IHhhcmdzIGVjaG8pClBBUlRJVElPTlM9
JChzZmRpc2sgLWxvIERldmljZSxUeXBlICRESVNLIHwgc2VkIC1lICcxLC9EZXZpY2VccypUeXBl
L2QnKQpkZCBpZj0kRElTSyBjb3VudD0kSEVBREVSX1NJWkUgfCBib3JnIGNyZWF0ZSAtLXN0YXRz
ICAke2Jha3JlcG99Ojoke2Jha3ByZWZpeH0tJHtkYXRlc3RyfS1wYXJ0aW5mbyAtCigoZmlsZXNj
b3VudCsrKSkKCiMgYmFja3VwIE5URlMgcGFydGl0aW9ucwplY2hvICIkUEFSVElUSU9OUyIgfCBn
cmVwICAgIE5URlMgfCBjdXQgLWQnICcgLWYxIHwgd2hpbGUgcmVhZCB4OyBkbwogICAgZWNobyAi
U2F2aW5nICR7eH0uLi4iCiAgICBQQVJUTlVNPSQoZWNobyAkeCB8IGdyZXAgLUVvICJbMC05XSsk
IikKICAgIG50ZnNjbG9uZSAtc28gLSAkeCB8IGJvcmcgY3JlYXRlIC0tc3RhdHMgICAke2Jha3Jl
cG99Ojoke2Jha3ByZWZpeH0tJHtkYXRlc3RyfS1wYXJ0JFBBUlROVU0gLQpkb25lCgojIGJhY2t1
cCBub24tTlRGUyBwYXJ0aXRpb25zOgplY2hvICIkUEFSVElUSU9OUyIgfCBncmVwIC12IE5URlMg
fCBjdXQgLWQnICcgLWYxIHwgd2hpbGUgcmVhZCB4OyBkbwogICAgZWNobyAiU2F2aW5nICR7eH0u
Li4iCiAgICBQQVJUTlVNPSQoZWNobyAkeCB8IGdyZXAgLUVvICJbMC05XSskIikKICAgIGJvcmcg
Y3JlYXRlIC0tcmVhZC1zcGVjaWFsIC0tc3RhdHMgICR7YmFrcmVwb306OiR7YmFrcHJlZml4fS0k
e2RhdGVzdHJ9LXBhcnQkUEFSVE5VTSAkeApkb25lCgojIGNvdW50IHBhcnRpdGlvbnMKZmlsZXNj
b3VudD0kKGVjaG8gIiRQQVJUSVRJT05TIiB8IHsgCiAgICB3aGlsZSBJRlM9PSByZWFkIC1yIGxp
bmU7IGRvICgoZmlsZXNjb3VudCsrKSk7IGRvbmUKICAgIGVjaG8gJGZpbGVzY291bnQKfQopCgoj
IHBydW5lCmlmIFtbICIke2tlZXBsYXN0b25seX0iIC1lcSAieWVzIiBdXTsgdGhlbgogICAgZWNo
byAicmVtb3Zpbmcgb2xkIGJhY2t1cHMsIGtlZXBpbmcgdGhlIGxhc3Qgb25lOiB0b3RhbCAke2Zp
bGVzY291bnR9IGZpbGVzLi4uIgogICAgYm9yZyBwcnVuZSAgLS1zdGF0cyAgLS1wcmVmaXggIiR7
YmFrcHJlZml4fS0iICAtLWtlZXAtbGFzdCAke2ZpbGVzY291bnR9ICAke2Jha3JlcG99ICYmIGVj
aG8gUmVtb3ZlIG9sZCBiYWNrdXBzOiBPSyB8fCB7IGVjaG8gUmVtb3ZlIG9sZCBiYWNrdXBzOiBG
YWlsZWQ7IGV4aXQgMTsgfQpmaQoK
EOF

read -d ''  backup_blkdev_restore_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpiYWtyZXBvPXJlcG8KRElTSz0vZGV2L3Nk
YQpiYWtwcmVmaXg9cHJlZml4CgoKIyBjaGVjayBzc2gKZGF0ZQppZiBbWyAiJHtiYWtyZXBvfSIg
PX4gLio6LiogXV07IHRoZW4KICAgIGhvc3Q9JChlY2hvICRiYWtyZXBvIHwgY3V0IC1kICc6JyAt
ZiAxKQogICAgc3NoICR7aG9zdH0gaG9zdG5hbWUgPiAvZGV2L251bGwgMj4mMSAmJiAgZWNobyBT
U0ggY2hlY2s6IE9LIHx8IHsgZWNobyBTU0ggY2hlY2s6IEZhaWxlZCEgOyBleGl0IDE7IH0KZmkK
IyBjaGVjayByZXBvCmJvcmcgbGlzdCAke2Jha3JlcG99ID4gL2Rldi9udWxsIDI+JjEgJiYgIGVj
aG8gcmVwb3NpdG9yeSBjaGVjazogT0sgIHx8IHsgIGVjaG8gcmVwb3NpdG9yeSBjaGVjazogRmFp
bGVkOyBleGl0IDE7IH0KCgoKZXhwb3J0IExBTkc9ZW5fVVMuVVRGOAoKcmVhZCAtcCAiUmVzdG9y
ZSBwYXJ0aXRpb25zPzogPyBbeS9OXTogIiB5bgpjYXNlICR5biBpbgogICAgW1l5XSogKSBlY2hv
OzsKICAgIFtObl0qICkgZWNobyAiRXhpdC4iIDtleGl0OzsKICAgICogKSBlY2hvICJFeGl0LiI7
IGV4aXQ7Owplc2FjCgpib3JnIGV4dHJhY3QgLS1zdGRvdXQgJHtiYWtyZXBvfTo6JHtiYWtwcmVm
aXh9LXBhcnRpbmZvIHwgZGQgb2Y9JERJU0sgJiYgcGFydHByb2JlClBBUlRJVElPTlM9JChzZmRp
c2sgLWxvIERldmljZSxUeXBlICRESVNLIHwgc2VkIC1lICcxLC9EZXZpY2VccypUeXBlL2QnKQpi
b3JnIGxpc3QgLS1mb3JtYXQge2FyY2hpdmV9e05MfSAke2Jha3JlcG99IHwgZ3JlcCAncGFydFsw
LTldKiQnIHwgd2hpbGUgcmVhZCB4OyBkbwogICAgUEFSVE5VTT0kKGVjaG8gJHggfCBncmVwIC1F
byAiWzAtOV0rJCIpCiAgICBQQVJUSVRJT049JChlY2hvICIkUEFSVElUSU9OUyIgfCBncmVwIC1F
ICIkRElTS3A/JFBBUlROVU0iIHwgaGVhZCAtbjEpCiAgICBpZiBlY2hvICIkUEFSVElUSU9OIiB8
IGN1dCAtZCcgJyAtZjItIHwgZ3JlcCAtcSBOVEZTOyB0aGVuCiAgICAgICAgYm9yZyBleHRyYWN0
IC0tc3Rkb3V0ICR7YmFrcmVwb306OiR4IHwgbnRmc2Nsb25lIC1yTyAkKGVjaG8gIiRQQVJUSVRJ
T04iIHwgY3V0IC1kJyAnIC1mMSkgLQogICAgZWxzZQogICAgICAgIGJvcmcgZXh0cmFjdCAtLXN0
ZG91dCAke2Jha3JlcG99OjokeCB8IGRkIG9mPSQoZWNobyAiJFBBUlRJVElPTiIgfCBjdXQgLWQn
ICcgLWYxKQogICAgZmkKZG9uZQo=
EOF

read -d '' backup_create_lvm_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpsdm1zPSJsdm5hbWUxIGx2bmFtZTIiCnZn
PSJ2Z25hbWUiCmJha3JlcG89IiIKCiMgb3B0aW9uYWwKc25hcHN1ZmZpeD1zbmFwCmJha3Jvb3Q9
L3RtcC9ib3JnYmFrcm9vdAoKCgojIEZVTkMKZnVuY3Rpb24gdW1vdW50X2FuZF9yZW1vdmVzbmFw
cyB7CiAgICBmb3IgbHYgaW4gJGx2bXM7IGRvCiAgICAgICAgYmFrc25hcD0iJHtsdn0ke3NuYXBz
dWZmaXh9IgogICAgICAgIGJrcGluPSIke2Jha3Jvb3R9LyR7bHZ9IgogICAgICAgIHNsZWVwIDE7
CiAgICAgICAgdW1vdW50ICR7YmtwaW59ICYmIHsgc2xlZXAgNTsgbHZyZW1vdmUgLXkgL2Rldi8k
e3ZnfS8ke2Jha3NuYXB9OyB9IHx8IGVjaG8gdW1vdW50ICR7YmtwaW59IGVycm9yCiAgICBkb25l
Owp9CgoKIyBCRUdJTgpiZWdpbmRpcj0iJChwd2QpIgoKIyBjaGVjayBzc2gKZGF0ZQppZiBbWyAi
JHtiYWtyZXBvfSIgPX4gLio6LiogXV07IHRoZW4KICAgIGhvc3Q9JChlY2hvICRiYWtyZXBvIHwg
Y3V0IC1kICc6JyAtZiAxKQogICAgc3NoICR7aG9zdH0gaG9zdG5hbWUgPiAvZGV2L251bGwgMj4m
MSAmJiAgZWNobyBTU0ggY2hlY2s6IE9LIHx8IHsgZWNobyBTU0ggY2hlY2s6IEZhaWxlZCEgOyBl
eGl0IDE7IH0KZmkKIyBjaGVjayByZXBvCmJvcmcgbGlzdCAke2Jha3JlcG99ID4gL2Rldi9udWxs
IDI+JjEgJiYgIGVjaG8gcmVwb3NpdG9yeSBjaGVjazogT0sgIHx8IHsgIGVjaG8gcmVwb3NpdG9y
eSBjaGVjazogRmFpbGVkOyBleGl0IDE7IH0KCm1rZGlyIC1wICIkaXtiYWtyb290fSIgfHwgZXhp
dCAxOwoKc3luYwoKIyBjcmVhdGUgc25hcHNob3RzCmZvciBsdiBpbiAkbHZtczsKZG8KICAgIGJh
a3NuYXA9IiR7bHZ9JHtzbmFwc3VmZml4fSIKICAgICMgaWYgbGFzdCBydW4gZmFpbHMgYW5kIHNu
YXBzaG90cyBleGlzdHMgLSB0cnlpbmcgdG8gdW5tb3VudCBhbmQgcmVtb3ZlIGJlZm9yZSBjcmVh
dGUgbmV3IG9uZQogICAgaWYgW1sgLWIgIC9kZXYvJHt2Z30vJHtiYWtzbmFwfSBdXTsgdGhlbgog
ICAgICAgIGVjaG8gV0FSTklORzogc2hhcHNob3QgIC9kZXYvJHt2Z30vJHtiYWtzbmFwfSBhbHJl
YWR5IGV4aXN0CiAgICAgICAgYmtwaW49IiR7YmFrcm9vdH0vJHtsdn0iCiAgICAgICAgbW91bnRw
b2ludCAtcSAgJHtia3Bpbn0gJiYgdW1vdW50ICR7YmtwaW59CiAgICAgICAgbHZyZW1vdmUgLXkg
L2Rldi8ke3ZnfS8ke2Jha3NuYXB9IHx8IHsgZWNobyB0cnlpbmcgdG8gcmVtb3ZlIGFsbCBzbmFw
c2hvdHMgYW5kIGV4aXQuLi47IHVtb3VudF9hbmRfcmVtb3Zlc25hcHM7IGVjaG8gZXhpdCE7ICBl
eGl0IDE7IH0KICAgIGZpCiAgICBsdmNyZWF0ZSAtcyAtTDUwME0gLW4gJHtiYWtzbmFwfSAvZGV2
LyR7dmd9LyR7bHZ9IHx8IGV4aXQgMTsKZG9uZTsKCgojIG1vdW50IHNuYXBzaG90cwpmb3IgbHYg
aW4gJGx2bXM7CmRvCiAgICBiYWtzbmFwPSIke2x2fSR7c25hcHN1ZmZpeH0iCiAgICBia3Bpbj0i
JHtiYWtyb290fS8ke2x2fSIKICAgIG1rZGlyIC1wICAkYmtwaW4KICAgIG1vdW50IC1vICJybyIg
L2Rldi8ke3ZnfS8ke2Jha3NuYXB9ICR7YmtwaW59IHx8IGV4aXQgMTsKICAgIGVjaG8gL2Rldi8k
e3ZnfS8ke2Jha3NuYXB9IG1vdW50ZWQgdG8gJHtia3Bpbn0KZG9uZTsKCgoKIyBiYWNrdXAKY2Qg
IiRiYWtyb290Igpib3JnIGNyZWF0ZSAtLXN0YXRzIC0tbnVtZXJpYy1vd25lciAgJHtiYWtyZXBv
fTo6IiR7dmd9LXtub3c6JVktJW0tJWRfJUgtJU0tJVN9IiAuCmNkICIkYmVnaW5kaXIiCnN5bmMK
c2xlZXAgNQoKCiMgdW5tb3VudCBhbmQgcmVtb3ZlIHNuYXBzaG90cwplY2hvCmVjaG8gVW5tb3Vu
dCBhbmQgcmVtb3ZlIHNuYXBzaG90cy4uLgp1bW91bnRfYW5kX3JlbW92ZXNuYXBzCgojIHBydW5l
CmVjaG8KZWNobyByZW1vdmluZyBvbGQgYmFja3Vwcy4uLgpib3JnIHBydW5lICAtLXN0YXRzICAt
LXByZWZpeCAiJHt2Z30tIiAtLWtlZXAtd2l0aGluIDJkIC0ta2VlcC1kYWlseSA3IC0ta2VlcC13
ZWVrbHkgOCAtLWtlZXAtbW9udGhseSAxMiAke2Jha3JlcG99ICYmIGVjaG8gUmVtb3ZlIG9sZCBi
YWNrdXBzOiBPSyB8fCB7IGVjaG8gUmVtb3ZlIG9sZCBiYWNrdXBzOiBGYWlsZWQ7IGV4aXQgMTsg
fQo=
EOF

read -d '' backup_create_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89IiIKYmFrcHJlZml4PXByZWZp
eAoKIyBjaGVjayBzc2gKZGF0ZQppZiBbWyAiJHtiYWtyZXBvfSIgPX4gLio6LiogXV07IHRoZW4K
ICAgIGhvc3Q9JChlY2hvICRiYWtyZXBvIHwgY3V0IC1kICc6JyAtZiAxKQogICAgc3NoICR7aG9z
dH0gaG9zdG5hbWUgPiAvZGV2L251bGwgMj4mMSAmJiAgZWNobyBTU0ggY2hlY2s6IE9LIHx8IHsg
ZWNobyBTU0ggY2hlY2s6IEZhaWxlZCEgOyBleGl0IDE7IH0KZmkKIyBjaGVjayByZXBvCmJvcmcg
bGlzdCAke2Jha3JlcG99ID4gL2Rldi9udWxsIDI+JjEgJiYgIGVjaG8gcmVwb3NpdG9yeSBjaGVj
azogT0sgIHx8IHsgIGVjaG8gcmVwb3NpdG9yeSBjaGVjazogRmFpbGVkOyBleGl0IDE7IH0KCgpi
b3JnIGNyZWF0ZSAtLXN0YXRzIC0tbnVtZXJpYy1vd25lciAgICR7YmFrcmVwb306OiIke2Jha3By
ZWZpeH0te25vdzolWS0lbS0lZF8lSC0lTS0lU30iIC8gXAogICAgLS1leGNsdWRlICcvZGV2Lyon
IFwKICAgIC0tZXhjbHVkZSAnL3Byb2MvKicgXAogICAgLS1leGNsdWRlICcvcnVuLyonIFwKICAg
IC0tZXhjbHVkZSAnL3N5cy8qJwoKYm9yZyBwcnVuZSAgLS1zdGF0cyAtLXByZWZpeCAiJHtiYWtw
cmVmaXh9LSIgLS1rZWVwLXdpdGhpbiAyZCAtLWtlZXAtZGFpbHkgNyAtLWtlZXAtd2Vla2x5IDgg
LS1rZWVwLW1vbnRobHkgMTIgJHtiYWtyZXBvfQo=
EOF

read -d '' backup_mount_sh << 'EOF'
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
    ;;  
    --export-plain)
    TOPLAIN=true
    shift # past argument
    ;;
    --export-base64)
    TOBASE64=true
    shift # past argument
    ;;
    --default)
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
    --no-download    -- skip borg downloading (also check 
                        "alt_download_link=" in head of this script)
    --export-plain   -- save "editable" version of this script - all base64 variables will be replaced by plain text (only for editing purpose!)
    --export-base64  -- run "editable" version of script with this key to save as working script
    


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
		sed  -e "/^read -d '' borg_id_rsa_pub << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa_pub << 'EOF'\n${key}\nEOF" -i $(basename "$0")
	fi
fi

if [[  $PRIVATEKEY ]]; then
	if test -f "$PRIVATEKEY"; then
		key=$(base64 $PRIVATEKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
		sed  -e "/^read -d '' borg_id_rsa << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa << 'EOF'\n${key}\nEOF" -i $(basename "$0")
	fi
fi


if [[  $GENKEYS ]]; then
	PRIVATEKEY=$(mktemp -u)
	PUBKEY="${PRIVATEKEY}".pub
	ssh-keygen -q -P '' -t rsa -f ${PRIVATEKEY}

	key=$(base64 $PUBKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
	sed  -e "/^read -d '' borg_id_rsa_pub << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa_pub << 'EOF'\n${key}\nEOF" -i $(basename "$0")
	key=$(base64 $PRIVATEKEY | sed -z 's/\n/\\n/g' | sed -e 's/\\n$//g')
	sed  -e "/^read -d '' borg_id_rsa << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa << 'EOF'\n${key}\nEOF" -i $(basename "$0")
fi

if [[  $CLEANKEYS ]]; then

	sed  -e "/^read -d '' borg_id_rsa_pub << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa_pub << 'EOF'\nEOF" -i $(basename "$0")
	sed  -e "/^read -d '' borg_id_rsa << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa << 'EOF'\nEOF" -i $(basename "$0")
fi

if [[  $TOPLAIN ]]; then
    plainfile=$(basename -s .sh "$0").plain.sh
	cat $(basename "$0") > "$plainfile"
	chmod +x "$plainfile"
	# first sed is for trimming, second for correct replacing in next block
	borg_id_rsa_pub_plain=$(base64 -d <<< ${borg_id_rsa_pub} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	borg_id_rsa_plain=$(base64 -d <<< ${borg_id_rsa} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_create_sh_plain=$(base64 -d <<< ${backup_create_sh} | sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_create_lvm_sh_plain=$(base64 -d <<< ${backup_create_lvm_sh} | sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_mount_sh_plain=$(base64 -d <<< ${backup_mount_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_blkdev_create_sh_plain=$(base64 -d <<< ${backup_blkdev_create_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_blkdev_restore_sh_plain=$(base64 -d <<< ${backup_blkdev_restore_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	
	sed  -E "/^read -d '' borg_id_rsa_pub << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa_pub << 'EOF'\n${borg_id_rsa_pub_plain} \nEOF" -i "$plainfile"
	sed  -E "/^read -d '' borg_id_rsa << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa << 'EOF'\n${borg_id_rsa_plain} \nEOF" -i "$plainfile"
	sed  -E "/^read -d ''  backup_blkdev_create_sh << 'EOF'$/,/^EOF$/c\read -d ''  backup_blkdev_create_sh << 'EOF'\n${backup_blkdev_create_sh_plain} \nEOF" -i "$plainfile"
	sed  -E "/^read -d ''  backup_blkdev_restore_sh << 'EOF'$/,/^EOF$/c\read -d ''  backup_blkdev_restore_sh << 'EOF'\n${backup_blkdev_restore_sh_plain} \nEOF" -i "$plainfile"
	sed  -E "/^read -d '' backup_create_lvm_sh << 'EOF'$/,/^EOF$/c\read -d '' backup_create_lvm_sh << 'EOF'\n${backup_create_lvm_sh_plain} \nEOF" -i "$plainfile"
	sed  -E "/^read -d '' backup_create_sh << 'EOF'$/,/^EOF$/c\read -d '' backup_create_sh << 'EOF'\n${backup_create_sh_plain} \nEOF" -i "$plainfile"
	sed  -E "/^read -d '' backup_mount_sh << 'EOF'$/,/^EOF$/c\read -d '' backup_mount_sh << 'EOF'\n${backup_mount_sh_plain} \nEOF" -i "$plainfile"
fi

if [[  $TOBASE64 ]]; then
    base64file=$(basename -s .sh "$0").base64.sh
	cat $(basename "$0") > "$base64file"
	chmod +x "$base64file"
	# first sed is for trimming, second for correct replacing in next block
	borg_id_rsa_pub_base64=$(base64 <<< ${borg_id_rsa_pub} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	borg_id_rsa_base64=$(base64 <<< ${borg_id_rsa} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_create_sh_base64=$(base64 <<< ${backup_create_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_create_lvm_sh_base64=$(base64 <<< ${backup_create_lvm_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_mount_sh_base64=$(base64 <<< ${backup_mount_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_blkdev_create_sh_base64=$(base64 <<< ${backup_blkdev_create_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	backup_blkdev_restore_sh_base64=$(base64 <<< ${backup_blkdev_restore_sh} |  sed  -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}'  | sed 's/\\/&&/g;s/^[[:blank:]]/\\&/;s/$/\\/')
	
	sed  -e "/^read -d '' borg_id_rsa_pub << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa_pub << 'EOF'\n${borg_id_rsa_pub_base64} \nEOF" -i "$base64file"
	sed  -e "/^read -d '' borg_id_rsa << 'EOF'$/,/^EOF$/c\read -d '' borg_id_rsa << 'EOF'\n${borg_id_rsa_base64} \nEOF" -i "$base64file"
	sed  -e "/^read -d ''  backup_blkdev_create_sh << 'EOF'$/,/^EOF$/c\read -d ''  backup_blkdev_create_sh << 'EOF'\n${backup_blkdev_create_sh_base64} \nEOF" -i "$base64file"
	sed  -e "/^read -d ''  backup_blkdev_restore_sh << 'EOF'$/,/^EOF$/c\read -d ''  backup_blkdev_restore_sh << 'EOF'\n${backup_blkdev_restore_sh_base64} \nEOF" -i "$base64file"
	sed  -e "/^read -d '' backup_create_lvm_sh << 'EOF'$/,/^EOF$/c\read -d '' backup_create_lvm_sh << 'EOF'\n${backup_create_lvm_sh_base64} \nEOF" -i "$base64file"
	sed  -e "/^read -d '' backup_create_sh << 'EOF'$/,/^EOF$/c\read -d '' backup_create_sh << 'EOF'\n${backup_create_sh_base64} \nEOF" -i "$base64file"
	sed  -e "/^read -d '' backup_mount_sh << 'EOF'$/,/^EOF$/c\read -d '' backup_mount_sh << 'EOF'\n${backup_mount_sh_base64} \nEOF" -i "$base64file"
	
fi
