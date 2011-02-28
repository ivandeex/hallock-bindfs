# VITKI
%define vitver  01
%global rhver   %((head -1 /etc/redhat-release 2>/dev/null || echo 0) | tr -cd 0-9 | cut -c1)
%define relver  vitki.%{vitver}%{?dist}%{!?dist:.el%{rhver}}
%define debug_package %{nil}

Name:           bindfs
Version:        1.9
Release:        %{relver}
Summary:        Fuse filesystem to mirror a directory

Group:          System Environment/Base
License:        GPLv2+
URL:            http://code.google.com/p/bindfs/
Source0:        http://bindfs.googlecode.com/files/bindfs-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  fuse-devel
BuildRequires:  recode


%description
Bindfs allows you to mirror a directory and also change the the permissions in
the mirror directory.


%prep
%setup -q
recode latin1..utf8 ChangeLog


%build
%configure INSTALL="%{_bindir}/install -p"
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT


%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc COPYING ChangeLog README
%{_bindir}/%{name}
%{_mandir}/man1/%{name}.1*


%changelog
* Thu Sep 17 2009 Peter Lemenkov <lemenkov@gmail.com> - 1.8.3-3
- Rebuilt with new fuse

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.8.3-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Mon Apr 13 2009 Till Maas <opensource@till.name> - 1.8.3-1
- Update to new upstream release

* Mon Feb 23 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.8.2-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Sun Dec 14 2008 Till Maas <opensource@till.name> - 1.8.2-2
- Update URL and Source0 to google code

* Sun Dec 14 2008 Till Maas <opensource@till.name> - 1.8.2-1
- Update to new release with GPLv2+ license headers 

* Fri Dec 12 2008 Till Maas <opensource@till.name> - 1.8.1-2
- Skip Requires: fuse
- Preseve timestamp of manpage with install -p in %%configure

* Fri Dec 12 2008 Till Maas <opensource@till.name> - 1.8.1-1
- Update to new release

* Wed Oct 29 2008 Till Maas <opensource@till.name> - 1.8-2
- Convert ChangeLog to UTF8

* Wed Oct 29 2008 Till Maas <opensource@till.name> - 1.8-1
- Update to new release

* Fri Oct 05 2007 Till Maas <opensource till name> - 1.3-1
- initial spec for Fedora
