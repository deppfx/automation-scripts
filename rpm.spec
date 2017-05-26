Name:        RecoServiceWebMain
Version:    104
Release:    39
Summary:    Recommendation Service

BuildArch:    noarch
Source0:    %{name}-%{version}-%{release}.tar.gz
License:    Proprietary
Group:        Inkiru
BuildRoot: %{_tmppath}/%{name}-buildroot
%description
This package installs the Recommendation (Reco) application.
%prep
%setup -q
%build
%install
rm -rf %{buildroot}
install -m 0755 -d $RPM_BUILD_ROOT//app/home/inkiru/inkadmin/lib/
install -m 0755 RecoServiceWebMain.jar $RPM_BUILD_ROOT/app/home/inkiru/inkadmin/lib/RecoServiceWebMain.jar
%clean
rm -rf $RPM_BUILD_ROOT
%post
%files
%dir /app/home/inkiru/inkadmin/lib/
/app/home/inkiru/inkadmin/lib/RecoServiceWebMain.jar
