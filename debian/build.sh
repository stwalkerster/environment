#!/bin/bash -ex
PARAMS=$(getopt -o h --long help,version:,distro:,name: -- "$@")

[ $? -eq 0 ] || {
    printUsage
    exit 1
}


VERSION=$(git describe)
NAME=""

eval set -- "$PARAMS"

while true; do
    case "$1" in
        -h | --help )
            printUsage
            exit 0;
            ;;
        --version)
            VERSION="${2}"
            shift
            ;;
        --distro)
            DISTRO="${2}"
            shift
            ;;
        --name)
            NAME="${2}"
            shift
            ;;
        --)
            break
            ;;
    esac
    shift
done

if [[ $NAME == "" ]]; then
    printUsage
    exit 1
fi


export NAME DISTRO VERSION

echo "Using version ${VERSION}"

FQNAME="${NAME}_${VERSION}"

mkdir -p ${FQNAME}/DEBIAN

cp -a debian/control/* ${FQNAME}/DEBIAN
cat debian/control/control | envsubst > ${FQNAME}/DEBIAN/control

# Do standard install things

mkdir -p ${FQNAME}/usr/share/${NAME}/
cp -a bash-completion-git bashrc git-commands git-prompt.sh gitconfig nanorc screenrc ${FQNAME}/usr/share/${NAME}/

mkdir -p ${FQNAME}/usr/share/doc/${NAME}/
cp LICENCE.txt ${FQNAME}/usr/share/doc/${NAME}/copyright

mkdir -p ${FQNAME}/etc/profile.d/
cp debian/z99-stwalkerster-environment.sh ${FQNAME}/etc/profile.d/

sudo chown -R root:root ${FQNAME}
sudo chmod -R u=rwX,go=rX ${FQNAME}/usr ${FQNAME}/etc

dpkg-deb --build ${FQNAME}
