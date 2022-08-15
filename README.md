# PkgManager
Package Manager of Mac packages (using pkgutil)

The Packager Manager helps to deal with pkgutil command on Mac.
The pkgutil command displays information about packages installed with pkg.

Currently the following commands are supported

- List all packages (--pkgs)
- List all packages without Apple packages (i.e. packages starting with com.apple.pkg)
- List info of a packages (--pkg-info)
- List all files and directories of a package (--lsbom)
- List only files of a package (--only-files --lsbom)
- List only directories of a package (--only-dirs --lsbom)
