Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

CD "c:\Program Files\IIs\Microsoft Web Deploy V3"

# Pulling exact copy from a remote site
./msdeploy.exe -verb:sync -source:apphostconfig="URLShortener",computername=192.168.100.50 `
                          -dest:apphostconfig="s.mhs.com" -whatif > msdeploysync.log



# Pulling modified files from directory to directory
./msdeploy.exe -verb:sync -source:contentpath="c:\inetpub\WebAssessments\ELP_AutoReport",computername=192.168.100.50 `
             -dest:contentpath=D:\Sites\a2.mhs.com\ELP_AutoReport `
             -whatif > msdeploysync.log #-useChecksum


#IncludeAcls='False' setting indicates that you don't want to copy the access control lists (ACLs) of the files in your source web application to the destination server.
#-useChecksum - copy only modified files