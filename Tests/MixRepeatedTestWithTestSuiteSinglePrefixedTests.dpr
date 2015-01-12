program MixRepeatedTestWithTestSuiteSinglePrefixedTests;

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
  TestFramework,
  TestExtensions;

begin
  RegisterTests('MixRepeatedTestWithTestSuitePrefix', [
    TRepeatedTest.Create(TSucceedingTestCase.Suite, 3),
    TFailingTestCase.Suite
  ]);
  RunXmlOutputTestsCatchedOnConsole('MixRepeatedTestWithTestSuitePrefixedTests.xml');
end.
