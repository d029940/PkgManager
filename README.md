# PkgManager
Package Manager of Mac packages (using pkgutil)

The Packager Manager helps to deal with pkgutil command on Mac.
The pkgutil command displays information about packages installed with pkg.

There are two targets in this project:
- pkgManager: Command Utility only for testing
- Package Manager: The GUI version of the pkgutil command

PackageManager offers the followiing features:
- Show all packages installed on the system in the sidebar. 
    By default, packages provided by Apple are not shown. 
    There is a toggle button to include Apple packages
- Selecting a package shows the information of a package similar to the command pkgutil --pkg-info 
    next to the sidebar in the details view
- The details view can provide
    - information (pkgutil --pkg-info)
    - files & dirs (pkgutil --lsbom)
    - only files (pkgutil --only-files --lsbom)
    - only dirs (pkgutil --only-dirs --lsbom)
    about the selected package
    
- If the files and/or dirs are shown, they can be checked if they exist on the drive by checkmark
- In the list of files/dirs right clicking an entry will open Finder with the file/dir selected

