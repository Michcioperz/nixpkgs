{ lib, stdenv, fetchFromGitHub, kernel }:
let
  version = "1.0.12";
  sha256 = "0k098zkxa8spj5rbmzpndxs0cf5i2n22g3ym6kq4j43kvs18x6c7";
in
stdenv.mkDerivation {
  name = "system76-module-${version}-${kernel.version}";

  passthru.moduleName = "system76";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "system76-dkms";
    rev = version;
    inherit sha256;
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildFlags = [
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D system76.ko $out/lib/modules/${kernel.modDirVersion}/misc/system76.ko
    mkdir -p $out/lib/udev/hwdb.d
    mv lib/udev/hwdb.d/* $out/lib/udev/hwdb.d
  '';

  meta = with lib; {
    maintainers = [ maintainers.khumba ];
    license = [ licenses.gpl2Plus ];
    platforms = [ "i686-linux" "x86_64-linux" ];
    broken = versionOlder kernel.version "4.14";
    description = "System76 DKMS driver";
    homepage = "https://github.com/pop-os/system76-dkms";
    longDescription = ''
      The System76 DKMS driver. On newer System76 laptops, this driver controls
      some of the hotkeys and allows for custom fan control.
    '';
  };
}
