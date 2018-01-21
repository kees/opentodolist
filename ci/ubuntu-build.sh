#!/bin/bash

set -e

if [ -n "$CI" ]; then
    curl -d install="true" -d adminlogin=admin -d adminpass=admin \
        http://nextcloud/index.php
    curl -d install="true" -d adminlogin=admin -d adminpass=admin \
            http://owncloud/index.php
    CMAKE_EXTRA_FLAGS="
        -DOPENTODOLIST_NEXTCLOUD_TEST_URL=http://admin:admin@nextcloud/
        -DOPENTODOLIST_OWNCLOUD_TEST_URL=http://admin:admin@owncloud/
    "
fi

which cmake || (apt-get update && apt-get install -y cmake)

desktop-file-validate templates/appimage/default.desktop

source /opt/qt510/bin/qt510-env.sh || true
export QT_QPA_PLATFORM=minimal

mkdir build-ubuntu
cd build-ubuntu

cmake \
    -DCMAKE_PREFIX_PATH=/opt/qt510 \
    $CMAKE_EXTRA_FLAGS \
    -DCMAKE_BUILD_TYPE=Release \
    -DOPENTODOLIST_WITH_UPDATE_SERVICE=ON \
    -DOPENTODOLIST_WITH_APPIMAGE_EXTRAS=ON \
    ..
cmake --build . --target all -- -j4
cmake --build . --target test
cmake --build . --target appimage
