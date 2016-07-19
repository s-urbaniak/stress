#!/usr/bin/env bash
set -e

acbuildend () {
    export EXIT=$?;
    acbuild --debug end && exit $EXIT;
}

os=linux
version=0.0.1
arch=amd64
name=stress

acbuild --debug begin
trap acbuildend EXIT

GOOS="${os}"
GOARCH="${arch}"
CGO_ENABLED=0
go build -v

acbuild set-name s-urbaniak.github.io/images/stress
acbuild copy "${name}" /bin/"${name}"
acbuild set-exec /bin/"${name}"
acbuild label add version "${version}"
acbuild label add arch "${arch}"
acbuild label add os "${os}"
acbuild annotation add authors "Sergiusz Urbaniak <sergiusz.urbaniak@gmail.com>"
acbuild write --overwrite "${name}"-"${version}"-"${os}"-"${arch}".aci
rm -f stress

gpg --yes --batch \
    -u sergiusz.urbaniak@gmail.com \
    --armor \
    --output "${name}"-"${version}"-"${os}"-"${arch}".aci.asc \
    --detach-sign "${name}"-"${version}"-"${os}"-"${arch}".aci
