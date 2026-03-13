Name:           NotepadNext
Version:        0.13.0
Release:        1%{?dist}
Summary:        A cross-platform, reimplementation of Notepad++

License:        GPL-3.0
URL:            https://github.com/QuentiumYT/NotepadNext
Source0:        %{name}-%{version}.tar.gz

BuildArch:      x86_64
Requires:       qt6-qtbase qt6-qtbase-gui

%description

%prep
%setup -q

%build
cmake -S . -B build \
    -DCMAKE_INSTALL_PREFIX=%{_prefix} \
    -DCMAKE_BUILD_TYPE=Release

cmake --build build -j $(nproc)

%install
rm -rf %{buildroot}

DESTDIR=%{buildroot} cmake --install build

install -Dm644 deploy/linux/com.github.dail8859.%{name}.metainfo.xml %{buildroot}/usr/share/metainfo/com.github.dail8859.%{name}.metainfo.xml

%files
%license LICENSE
%doc README.md debian/changelog debian/copyright
%{_bindir}/%{name}
%{_prefix}/lib
%{_includedir}/*
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/scalable/apps/%{name}.svg
%{_datadir}/icons/hicolor/scalable/mimetypes/%{name}.svg
%{_datadir}/metainfo/com.github.dail8859.%{name}.metainfo.xml
%{_datadir}/%{name}/translations/*.qm
%{_datadir}/ads/license/*

%changelog
