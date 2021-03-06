LINUXDEPLOYQT_URL = https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage
LINUXDEPLOYQT = ./linuxdeployqt-continuous-x86_64.AppImage

linuxdeployqt.target = $$LINUXDEPLOYQT
linuxdeployqt.commands = \
    curl -L -o $$LINUXDEPLOYQT $$LINUXDEPLOYQT_URL && \
    chmod +x $$LINUXDEPLOYQT

appimage.target = appimage
appimage.depends = linuxdeployqt appimagetool
appimage.commands = \
    rm -rf AppImageBuild && \
    make install INSTALL_ROOT=$$OUT_PWD/AppImageBuild && \
    cp $$PWD/templates/appimage/default.desktop AppImageBuild/ && \
    mkdir -p AppImageBuild/usr/share/icons/hicolor/ && \
    cp -r $$PWD/app/icons/* AppImageBuild/usr/share/icons/hicolor/ && \
    cp -r $$PWD/app/icons/hicolor/64x64/apps/net.rpdev.OpenTodoList.png AppImageBuild/ && \
    $$LINUXDEPLOYQT --appimage-extract && \
    ./squashfs-root/AppRun \
        AppImageBuild/usr/bin/OpenTodoList \
        -qmldir=$$PWD/app \
        -qmake=$$QMAKE_QMAKE \
        -extra-plugins=platforms/libqwayland-generic.so,platforminputcontexts,wayland-graphics-integration-client \
        -appimage && \
    mv OpenTodoList-*-x86_64.AppImage OpenTodoList-x86_64.AppImage

QMAKE_EXTRA_TARGETS += linuxdeployqt appimagetool appimage
