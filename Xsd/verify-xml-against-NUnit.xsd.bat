:begin
  setlocal
  if []==[%*] goto :noXml
  set xsd="%~dp0NUnitXsd\www.nunit.org\docs\2.6.4\files\Results.xsd"
  if not exist %xsd% goto :noXsd
  set validator="%~dp0ValidateXmlWithXsd\Debug\Win32\ValidateXmlWithXsd.exe"
  if not exist %validator% goto :noValidator
  %validator% %1 %xsd%
  goto :exit

:noXml
  echo No xml at %*
  goto :exit
:noValidator
  echo No validator at %validator%  
  goto :exit
:noXsd
  echo No XSD at %xsd%  
:exit
  endlocal