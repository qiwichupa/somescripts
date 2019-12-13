#!/bin/bash

PACKAGE=$1
SCRIPT="setup_${PACKAGE}.sh"
if [[ "" == $(dpkg-query  -W --showformat='${Status}\n'  debconf-utils | grep "install ok") ]]; then
    apt install debconf-utils
fi


if [[ "" == $(dpkg-query  -W --showformat='${Status}\n'  ${PACKAGE} | grep "install ok") ]]; then
    apt install ${PACKAGE}
fi


if [[ "" != $(dpkg-query  -W --showformat='${Status}\n'  ${PACKAGE} | grep "install ok") ]]; then
    echo '#!/bin/sh' > ${SCRIPT}
    chmod +x ${SCRIPT}
    #echo 'DEBIAN_FRONTEND=noninteractive apt-get install -y debconf-utils' >> ${SCRIPT}
    echo "debconf-set-selections << 'END'" >> ${SCRIPT}
    debconf-get-selections | fgrep ${PACKAGE} >> ${SCRIPT}
    echo 'END' >> ${SCRIPT}
    echo "DEBIAN_FRONTEND=noninteractive apt-get install -y ${PACKAGE}" >> ${SCRIPT} 
fi
