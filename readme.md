<h1>Summary</h1>


This script will determine the correct extension for your comic book files (.cbr or .cbz) and rename them accordingly.

It will then convert all cbr's to cbz and log any failed cbr's to a "cbr2cbzlog[datetime].txt" file in the directory you run the script from.

FullOutput will show a the full output of the script and unrar actions.






<h1>Requirements</h1>


TRiD has a weird issue with the "LANG=" value being set in linux.  From what I can tell if you set LANG=/usr/lib/locale/en_US (or whatever your LANG value should be) it will work.  It just needs to be a complete path.

Requires Unrar and Powershell to be installed.

unrar download    --  https://www.rarlab.com/rar_add.htm

powershell linux  --  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-6



<h1>Files And explanations </h1>


Trid      --   Linux executable of trid  (http://mark0.net/soft-trid-e.html)

Trid.exe  --   Windows executable of trid (http://mark0.net/soft-trid-e.html)

cbx.trd   --   cbr/cbz definition file for trid
