#!/usr/bin/env bash

# SETTINGS (you can leave all of them as is)

default_bakrepo=backup:repo
default_mountpoint=/tmp/borgbackup
default_hostname=192.168.1.53

# Uncomment and edit IF you want to set alternate url for borg binary:
# alt_download_link=http://my.server.local/borg_bin

# You can leave this as is:
borgversion="1.2.3"
key=borg_id_rsa
keypub=borg_id_rsa.pub
shdir=borg
sshuser=borg

# You must charge this script with ssh keys before deploy
# or connect to remote repository.
# Run script with -h to see details.
read -d '' borg_id_rsa << 'EOF'
Cg== 
EOF

read -d '' borg_id_rsa_pub << 'EOF'
Cg== 
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
JChzZmRpc2sgLWxvIERldmljZSxUeXBlICRESVNLIHwgc2VkIC1lICcxLC9EZXZpY2VzKlR5cGUv
ZCcpCmRkIGlmPSRESVNLIGNvdW50PSRIRUFERVJfU0laRSB8IGJvcmcgY3JlYXRlIC0tc3RhdHMg
ICR7YmFrcmVwb306OiR7YmFrcHJlZml4fS0ke2RhdGVzdHJ9LXBhcnRpbmZvIC0KKChmaWxlc2Nv
dW50KyspKQoKIyBiYWNrdXAgTlRGUyBwYXJ0aXRpb25zCmVjaG8gIiRQQVJUSVRJT05TIiB8IGdy
ZXAgICAgTlRGUyB8IGN1dCAtZCcgJyAtZjEgfCB3aGlsZSByZWFkIHg7IGRvCiAgICBlY2hvICJT
YXZpbmcgJHt4fS4uLiIKICAgIFBBUlROVU09JChlY2hvICR4IHwgZ3JlcCAtRW8gIlswLTldKyQi
KQogICAgbnRmc2Nsb25lIC1zbyAtICR4IHwgYm9yZyBjcmVhdGUgLS1zdGF0cyAgICR7YmFrcmVw
b306OiR7YmFrcHJlZml4fS0ke2RhdGVzdHJ9LXBhcnQkUEFSVE5VTSAtCmRvbmUKCiMgYmFja3Vw
IG5vbi1OVEZTIHBhcnRpdGlvbnM6CmVjaG8gIiRQQVJUSVRJT05TIiB8IGdyZXAgLXYgTlRGUyB8
IGN1dCAtZCcgJyAtZjEgfCB3aGlsZSByZWFkIHg7IGRvCiAgICBlY2hvICJTYXZpbmcgJHt4fS4u
LiIKICAgIFBBUlROVU09JChlY2hvICR4IHwgZ3JlcCAtRW8gIlswLTldKyQiKQogICAgYm9yZyBj
cmVhdGUgLS1yZWFkLXNwZWNpYWwgLS1zdGF0cyAgJHtiYWtyZXBvfTo6JHtiYWtwcmVmaXh9LSR7
ZGF0ZXN0cn0tcGFydCRQQVJUTlVNICR4CmRvbmUKCiMgY291bnQgcGFydGl0aW9ucwpmaWxlc2Nv
dW50PSQoZWNobyAiJFBBUlRJVElPTlMiIHwgeyAKICAgIHdoaWxlIElGUz09IHJlYWQgLXIgbGlu
ZTsgZG8gKChmaWxlc2NvdW50KyspKTsgZG9uZQogICAgZWNobyAkZmlsZXNjb3VudAp9CikKCiMg
cHJ1bmUKaWYgW1sgIiR7a2VlcGxhc3Rvbmx5fSIgLWVxICJ5ZXMiIF1dOyB0aGVuCiAgICBlY2hv
ICJyZW1vdmluZyBvbGQgYmFja3Vwcywga2VlcGluZyB0aGUgbGFzdCBvbmU6IHRvdGFsICR7Zmls
ZXNjb3VudH0gZmlsZXMuLi4iCiAgICBib3JnIHBydW5lICAtLXN0YXRzICAtLWdsb2ItYXJjaGl2
ZXMgIiR7YmFrcHJlZml4fS0qIiAgLS1rZWVwLWxhc3QgJHtmaWxlc2NvdW50fSAgJHtiYWtyZXBv
fSAmJiBlY2hvIFJlbW92ZSBvbGQgYmFja3VwczogT0sgfHwgeyBlY2hvIFJlbW92ZSBvbGQgYmFj
a3VwczogRmFpbGVkOyBleGl0IDE7IH0KICAgIGVjaG8gY29tcGFjdGluZyByZXBvc2l0b3J5Li4u
CiAgICBib3JnIGNvbXBhY3QgJHtiYWtyZXBvfSAmJiBlY2hvIENvbXBhY3RpbmcgcmVwb3NpdG9y
eTogT0sgfHwgeyBlY2hvIENvbXBhY3RpbmcgcmVwb3NpdG9yeTogRmFpbGVkOyBleGl0IDE7IH0K
ZmkK 
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
c2sgLWxvIERldmljZSxUeXBlICRESVNLIHwgc2VkIC1lICcxLC9EZXZpY2VzKlR5cGUvZCcpCmJv
cmcgbGlzdCAtLWZvcm1hdCB7YXJjaGl2ZX17Tkx9ICR7YmFrcmVwb30gfCBncmVwICdwYXJ0WzAt
OV0qJCcgfCB3aGlsZSByZWFkIHg7IGRvCiAgICBQQVJUTlVNPSQoZWNobyAkeCB8IGdyZXAgLUVv
ICJbMC05XSskIikKICAgIFBBUlRJVElPTj0kKGVjaG8gIiRQQVJUSVRJT05TIiB8IGdyZXAgLUUg
IiRESVNLcD8kUEFSVE5VTSIgfCBoZWFkIC1uMSkKICAgIGlmIGVjaG8gIiRQQVJUSVRJT04iIHwg
Y3V0IC1kJyAnIC1mMi0gfCBncmVwIC1xIE5URlM7IHRoZW4KICAgICAgICBib3JnIGV4dHJhY3Qg
LS1zdGRvdXQgJHtiYWtyZXBvfTo6JHggfCBudGZzY2xvbmUgLXJPICQoZWNobyAiJFBBUlRJVElP
TiIgfCBjdXQgLWQnICcgLWYxKSAtCiAgICBlbHNlCiAgICAgICAgYm9yZyBleHRyYWN0IC0tc3Rk
b3V0ICR7YmFrcmVwb306OiR4IHwgZGQgb2Y9JChlY2hvICIkUEFSVElUSU9OIiB8IGN1dCAtZCcg
JyAtZjEpCiAgICBmaQpkb25lCg== 
EOF

read -d '' backup_create_lvm_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKIyBTRVRUSU5HUwpsdm1zPSJsdm5hbWUxIGx2bmFtZTIiCnZn
PSJ2Z25hbWUiCmJha3JlcG89IiIKCiMgb3B0aW9uYWwKc25hcHN1ZmZpeD1zbmFwCmJha3Jvb3Q9
L3RtcC9ib3JnYmFrcm9vdApleGNsdWRlc3RyaW5nPSIiICMgZm9yIGV4YW1wbGU6IGV4Y2x1ZGVz
dHJpbmc9Ii0tZXhjbHVkZSAqL1N0ZWFtTGlicmFyeS9zdGVhbWFwcHMvY29tbW9uLyIKCiMgRlVO
QwpmdW5jdGlvbiB1bW91bnRfYW5kX3JlbW92ZXNuYXBzIHsKICAgIGZvciBsdiBpbiAkbHZtczsg
ZG8KICAgICAgICBiYWtzbmFwPSIke2x2fSR7c25hcHN1ZmZpeH0iCiAgICAgICAgYmtwaW49IiR7
YmFrcm9vdH0vJHtsdn0iCiAgICAgICAgc2xlZXAgMTsKICAgICAgICB1bW91bnQgJHtia3Bpbn0g
JiYgeyBzbGVlcCA1OyBsdnJlbW92ZSAteSAvZGV2LyR7dmd9LyR7YmFrc25hcH07IH0gfHwgZWNo
byB1bW91bnQgJHtia3Bpbn0gZXJyb3IKICAgIGRvbmU7Cn0KCgojIEJFR0lOCmJlZ2luZGlyPSIk
KHB3ZCkiCgojIGNoZWNrIHNzaApkYXRlCmlmIFtbICIke2Jha3JlcG99IiA9fiAuKjouKiBdXTsg
dGhlbgogICAgaG9zdD0kKGVjaG8gJGJha3JlcG8gfCBjdXQgLWQgJzonIC1mIDEpCiAgICBzc2gg
JHtob3N0fSBob3N0bmFtZSA+IC9kZXYvbnVsbCAyPiYxICYmICBlY2hvIFNTSCBjaGVjazogT0sg
fHwgeyBlY2hvIFNTSCBjaGVjazogRmFpbGVkISA7IGV4aXQgMTsgfQpmaQojIGNoZWNrIHJlcG8K
Ym9yZyBsaXN0ICR7YmFrcmVwb30gPiAvZGV2L251bGwgMj4mMSAmJiAgZWNobyByZXBvc2l0b3J5
IGNoZWNrOiBPSyAgfHwgeyAgZWNobyByZXBvc2l0b3J5IGNoZWNrOiBGYWlsZWQ7IGV4aXQgMTsg
fQoKbWtkaXIgLXAgIiR7YmFrcm9vdH0iIHx8IGV4aXQgMTsKCnN5bmMKCiMgY3JlYXRlIHNuYXBz
aG90cwpmb3IgbHYgaW4gJGx2bXM7CmRvCiAgICBiYWtzbmFwPSIke2x2fSR7c25hcHN1ZmZpeH0i
CiAgICAjIGlmIGxhc3QgcnVuIGZhaWxzIGFuZCBzbmFwc2hvdHMgZXhpc3RzIC0gdHJ5aW5nIHRv
IHVubW91bnQgYW5kIHJlbW92ZSBiZWZvcmUgY3JlYXRlIG5ldyBvbmUKICAgIGlmIFtbIC1iICAv
ZGV2LyR7dmd9LyR7YmFrc25hcH0gXV07IHRoZW4KICAgICAgICBlY2hvIFdBUk5JTkc6IHNoYXBz
aG90ICAvZGV2LyR7dmd9LyR7YmFrc25hcH0gYWxyZWFkeSBleGlzdAogICAgICAgIGJrcGluPSIk
e2Jha3Jvb3R9LyR7bHZ9IgogICAgICAgIG1vdW50cG9pbnQgLXEgICR7YmtwaW59ICYmIHVtb3Vu
dCAke2JrcGlufQogICAgICAgIGx2cmVtb3ZlIC15IC9kZXYvJHt2Z30vJHtiYWtzbmFwfSB8fCB7
IGVjaG8gdHJ5aW5nIHRvIHJlbW92ZSBhbGwgc25hcHNob3RzIGFuZCBleGl0Li4uOyB1bW91bnRf
YW5kX3JlbW92ZXNuYXBzOyBlY2hvIGV4aXQhOyAgZXhpdCAxOyB9CiAgICBmaQogICAgbHZjcmVh
dGUgLXMgLUw5MDBNIC1uICR7YmFrc25hcH0gL2Rldi8ke3ZnfS8ke2x2fSB8fCBleGl0IDE7CmRv
bmU7CgoKIyBtb3VudCBzbmFwc2hvdHMKZm9yIGx2IGluICRsdm1zOwpkbwogICAgYmFrc25hcD0i
JHtsdn0ke3NuYXBzdWZmaXh9IgogICAgYmtwaW49IiR7YmFrcm9vdH0vJHtsdn0iCiAgICBta2Rp
ciAtcCAgJGJrcGluCiAgICBtb3VudCAtbyAicm8iIC9kZXYvJHt2Z30vJHtiYWtzbmFwfSAke2Jr
cGlufSB8fCBleGl0IDE7CiAgICBlY2hvIC9kZXYvJHt2Z30vJHtiYWtzbmFwfSBtb3VudGVkIHRv
ICR7YmtwaW59CmRvbmU7CgoKCiMgYmFja3VwCmNkICIkYmFrcm9vdCIKYm9yZyBjcmVhdGUgLS1z
dGF0cyAtLW51bWVyaWMtaWRzICR7ZXhjbHVkZXN0cmluZ30gJHtiYWtyZXBvfTo6IiR7dmd9LXtu
b3c6JVktJW0tJWRfJUgtJU0tJVN9IiAuCmNkICIkYmVnaW5kaXIiCnN5bmMKc2xlZXAgNQoKCiMg
dW5tb3VudCBhbmQgcmVtb3ZlIHNuYXBzaG90cwplY2hvCmVjaG8gVW5tb3VudCBhbmQgcmVtb3Zl
IHNuYXBzaG90cy4uLgp1bW91bnRfYW5kX3JlbW92ZXNuYXBzCgojIHBydW5lCmVjaG8KZWNobyBy
ZW1vdmluZyBvbGQgYmFja3Vwcy4uLgpib3JnIHBydW5lICAtLXN0YXRzICAtLWdsb2ItYXJjaGl2
ZXMgIiR7dmd9LSoiIC0ta2VlcC13aXRoaW4gMmQgLS1rZWVwLWRhaWx5IDcgLS1rZWVwLXdlZWts
eSA4IC0ta2VlcC1tb250aGx5IDEyICR7YmFrcmVwb30gJiYgZWNobyBSZW1vdmUgb2xkIGJhY2t1
cHM6IE9LIHx8IHsgZWNobyBSZW1vdmUgb2xkIGJhY2t1cHM6IEZhaWxlZDsgZXhpdCAxOyB9IApl
Y2hvIGNvbXBhY3RpbmcgcmVwb3NpdG9yeS4uLgpib3JnIGNvbXBhY3QgJHtiYWtyZXBvfSAmJiBl
Y2hvIENvbXBhY3RpbmcgcmVwb3NpdG9yeTogT0sgfHwgeyBlY2hvIENvbXBhY3RpbmcgcmVwb3Np
dG9yeTogRmFpbGVkOyBleGl0IDE7IH0K 
EOF

read -d '' backup_create_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89IiIKYmFrcHJlZml4PXByZWZp
eAoKIyBjaGVjayBzc2gKZGF0ZQppZiBbWyAiJHtiYWtyZXBvfSIgPX4gLio6LiogXV07IHRoZW4K
ICAgIGhvc3Q9JChlY2hvICRiYWtyZXBvIHwgY3V0IC1kICc6JyAtZiAxKQogICAgc3NoICR7aG9z
dH0gaG9zdG5hbWUgPiAvZGV2L251bGwgMj4mMSAmJiAgZWNobyBTU0ggY2hlY2s6IE9LIHx8IHsg
ZWNobyBTU0ggY2hlY2s6IEZhaWxlZCEgOyBleGl0IDE7IH0KZmkKIyBjaGVjayByZXBvCmJvcmcg
bGlzdCAke2Jha3JlcG99ID4gL2Rldi9udWxsIDI+JjEgJiYgIGVjaG8gcmVwb3NpdG9yeSBjaGVj
azogT0sgIHx8IHsgIGVjaG8gcmVwb3NpdG9yeSBjaGVjazogRmFpbGVkOyBleGl0IDE7IH0KCgpi
b3JnIGNyZWF0ZSAtLXN0YXRzIC0tbnVtZXJpYy1pZHMgICAke2Jha3JlcG99OjoiJHtiYWtwcmVm
aXh9LXtub3c6JVktJW0tJWRfJUgtJU0tJVN9IiAvICAgICAtLWV4Y2x1ZGUgJy9kZXYvKicgICAg
IC0tZXhjbHVkZSAnL3Byb2MvKicgICAgIC0tZXhjbHVkZSAnL3J1bi8qJyAgICAgLS1leGNsdWRl
ICcvc3lzLyonCgpib3JnIHBydW5lICAtLXN0YXRzIC0tZ2xvYi1hcmNoaXZlcyAiJHtiYWtwcmVm
aXh9LSoiIC0ta2VlcC13aXRoaW4gMmQgLS1rZWVwLWRhaWx5IDcgLS1rZWVwLXdlZWtseSA4IC0t
a2VlcC1tb250aGx5IDEyICR7YmFrcmVwb30gCmNvbXBhY3RpbmcgcmVwb3NpdG9yeS4uLgpib3Jn
IGNvbXBhY3QgJHtiYWtyZXBvfSAmJiBlY2hvIENvbXBhY3RpbmcgcmVwb3NpdG9yeTogT0sgfHwg
eyBlY2hvIENvbXBhY3RpbmcgcmVwb3NpdG9yeTogRmFpbGVkOyBleGl0IDE7IH0K 
EOF

read -d '' backup_mount_sh << 'EOF'
IyEvdXNyL2Jpbi9lbnYgYmFzaAoKI3NldHRpbmdzCmJha3JlcG89cmVwbwptbnRkaXI9L3RtcC9i
b3JnYmFja3VwCgpta2RpciAtcCAiJHttbnRkaXJ9IiAgfHwgZXhpdDsKY2htb2QgNzc3ICIke21u
dGRpcn0iIHx8IGV4aXQ7CmJvcmcgbW91bnQgLW8gYWxsb3dfb3RoZXIgICIke2Jha3JlcG99IiAi
JHttbnRkaXJ9IiB8fCBleGl0OwplY2hvIGJhY2t1cCBtb3VudHBvaW50OiAke21udGRpcn0gIHx8
IGV4aXQ7Cm1jICIke21udGRpcn0iCmJvcmcgdW1vdW50ICIke21udGRpcn0iICYmIGVjaG8gdW1v
dW50IGNvbXBsZXRlCg== 
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
		read -p "enter ip or hostname of repository $(echo $bakrepo | cut -d ':' -f1) [${default_hostname}]: " hostname
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
