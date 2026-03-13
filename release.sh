#!/bin/bash
VERSION=0.13.0
DIR=notepadnext-$VERSION
ARCH=$(uname -m)
ARCH_DPKG=$(dpkg --print-architecture)
export VERSION=$VERSION

# cleanup
rm -rf build release i18n/*.qm rpm/BUILD rpm/BUILDROOT rpm/*RPMS rpm/SOURCES debug*.list elfbins.list

# build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j $(nproc)
strip -s build/src/NotepadNext

# assets
mkdir -p release/$DIR
cp -r src thirdparty .cpm-cache i18n cmake CMakeLists.txt deploy desktop icon release/$DIR

# translations
export QT_SELECT=qt6
# Expand PATH to find lupdate & lrelease
export PATH="/usr/lib/$QT_SELECT/bin:$PATH"
lupdate src/ -ts i18n/*.ts
lrelease i18n/*.ts
mkdir -p release/$DIR/notepadnext/i18n
cp i18n/*.qm release/$DIR/notepadnext/i18n

# Change architecture
sed -i "s/^Architecture:\s\+.*$/Architecture: $ARCH_DPKG/g" release/$DIR/debian/control

# tarball
tar -czf release/$DIR.tar.gz -C release $DIR

# appimagetool
wget -qc https://github.com/$(wget -q https://github.com/probonopd/go-appimage/releases/expanded_assets/continuous -O - | grep "appimagetool-.*-$ARCH.AppImage" | head -n 1 | cut -d '"' -f 2) -O appimagetool-$ARCH.AppImage
chmod +x appimagetool-$ARCH.AppImage

# appimage
DESTDIR=../release/$DIR cmake --build build --target install -j $(nproc)
./appimagetool-$ARCH.AppImage -s deploy release/$DIR/usr/share/applications/NotepadNext.desktop
./appimagetool-$ARCH.AppImage release/$DIR
mv Notepad_Next-$VERSION-$ARCH.AppImage release/NotepadNext-$VERSION-$ARCH.AppImage

rm appimagetool-$ARCH.AppImage

# deb package
cd release/$DIR
# Export CMake prefix path for debuild using aqtinstall
if [ -z "$QT_PLUGIN_PATH" ]; then
    QT_ROOT=$(dirname "$QT_PLUGIN_PATH")
    export CMAKE_PREFIX_PATH="$QT_ROOT/lib/cmake"
fi
dh_make --createorig --indep --yes
debuild --preserve-envvar=CMAKE_PREFIX_PATH \
    --preserve-envvar=QT_PLUGIN_PATH \
    --preserve-envvar=LD_LIBRARY_PATH \
    --no-lintian -us -uc
cd ../..

# rpm package
mkdir -p rpm/SOURCES
cp release/$DIR.tar.gz rpm/SOURCES
# Change architecture
sed -i "s/^BuildArch:\s\+.*$/BuildArch:      $ARCH/g" rpm/SPECS/NotepadNext.spec
rpmbuild -bb --build-in-place --define "_topdir $(pwd)/rpm" rpm/SPECS/NotepadNext.spec
mv rpm/RPMS/$ARCH/NotepadNext-$VERSION-1.$ARCH.rpm release/NotepadNext-$VERSION.$ARCH.rpm
