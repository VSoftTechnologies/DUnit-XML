@echo off
:main
  setlocal
  pushd Debug
  del *.xml
  if [%1]==[] call :list  
  if not [%1]==[] call :item %~n1
  popd
  endlocal
  goto :eof
  
:list
  for %%e in (*.exe) do call :item %%~ne
  goto :eof
  
:item
  echo.
  echo Running %1
  %1.exe
  set Pretty=%1.PrettyPrinted.xml
  ..\..\Xsd\PrettyPrintXml\Debug\PrettyPrintXml.exe %1.xml %Pretty%
  echo Verifying %Pretty%
  call ..\..\Xsd\verify-xml-against-NUnit.xsd.bat %Pretty%
  goto :eof
