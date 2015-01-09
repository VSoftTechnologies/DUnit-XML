program MixTestCaseWithTestSuiteSinglePrefixedTests;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FailingTestCase in 'FailingTestCase.pas',
  RegisterAndRunTests in 'RegisterAndRunTests.pas',
  SucceedingTestCase in 'SucceedingTestCase.pas',
  TestRunner in 'TestRunner.pas',
  TestUtils in 'TestUtils.pas',
  VSoft.DUnit.XMLTestRunner in '..\VSoft.DUnit.XMLTestRunner.pas',
  VSoft.MSXML6 in '..\VSoft.MSXML6.pas',
  TestFramework;

begin
  RegisterTests('MixTestCaseWithTestSuiteSinglePrefix', [
    TSucceedingTestCase.Create('SucceedingTest'),
    TFailingTestCase.Suite
  ]);
  RunXmlOutputTestsCatchedOnConsole('MixTestCaseWithTestSuiteSinglePrefixedTests.xml');
end.
