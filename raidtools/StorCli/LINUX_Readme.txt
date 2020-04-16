To install StorCLI, perform the following steps:
1. Unzip the StorCLI package.
2. To install the StorCLI RPM, run the rpm -ivh <StorCLI-x.xx-x.noarch.rpm> command.
3. To upgrade the StorCLI RPM, run the rpm -Uvh <StorCLI-x.xx-x.noarch.rpm> command.
4. To create individual X64 and X86  RPM's run the shell file splitpackage.sh with release RPM file as parameter (./splitpackage.sh StorCLI-x.xx-x.noarch.rpm)


Steps to verify StorCLI RPM signature:
Step 1. Import the public key to RPM DB. Command : rpm --import <public-key.asc>
Step 2. Verify the RPM signature. Command : rpm -Kv <storcli-rpm>
Step 3. Install the StorCLI RPM. If imported public key is for the RPM being installed, No warnings should be shown during installation.

Note: Please follow the steps in the mentioned order.