copy-files.ps1 -buildType "Blue"     

  -copies the SSL DLL's and Install.bat file that is needed to the server.

launch-server.ps1 -buildType "Blue" 

-asks you to log in if needed
-get's the auth token from the compute resouce
-warns you if you your IP Addresss isn't the one associated with the Compute Resource
-launches the server.

All the variables are at the top of each file and can be passed as paraams.

I Use Blue / Green build cycle.  You can pass in Build1 or Build2 instead of Blue, Greeen
