program NoTests;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FailingTestCase in 'FailingTestCase.pas',
  RegisterAndRunTests in 'RegisterAndRunTests.pas',
  SucceedingTestCase in 'SucceedingTestCase.pas',
  TestRunner in 'TestRunner.pas',
  TestUtils in 'TestUtils.pas',
  VSoft.MSXML6 in '..\VSoft.MSXML6.pas',
  VSoft.DUnit.XMLTestRunner in '..\VSoft.DUnit.XMLTestRunner.pas';

begin
  // Expected: no XML file to be generated at all.
  RunXmlOutputTestsCatchedOnConsole('NoTests.xml');
end.
