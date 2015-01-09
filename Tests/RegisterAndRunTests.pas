unit RegisterAndRunTests;

interface

procedure RegisterAndRunXmlOutputTestsCatchedOnConsole(const SuitePathPrefix, XmlFilename: string);

procedure RunXmlOutputTestsCatchedOnConsole(const XmlFilename: string);

implementation

uses
  SysUtils,
  FailingTestCase,
  SucceedingTestCase,
  TestFramework,
  TestRunner;

procedure RunXmlOutputTestsCatchedOnConsole(const XmlFilename: string);
begin
  try
    TestRunner.RunRegisteredTests(
{$IFDEF CONSOLE_TESTRUNNER}
  {$IFDEF XMLOUTPUT}
      XmlFilename
  {$ENDIF XMLOUTPUT}
{$ENDIF CONSOLE_TESTRUNNER}
    );
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end;

procedure RegisterAndRunXmlOutputTestsCatchedOnConsole(const SuitePathPrefix, XmlFilename: string);
var
  DottedSuitePathPrefix: string;
begin
  if SuitePathPrefix = '' then
    DottedSuitePathPrefix := SuitePathPrefix
  else
    DottedSuitePathPrefix := SuitePathPrefix + '.';
  RegisterTests(DottedSuitePathPrefix  + 'FailingTest', [TFailingTestCase.Suite]);
  RegisterTests(DottedSuitePathPrefix  + 'SucceedingTest', [TSucceedingTestCase.Suite]);
  RunXmlOutputTestsCatchedOnConsole(XmlFilename);
end;

end.
