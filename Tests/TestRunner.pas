// Based on Spring.TestRunner in the Spring4D project

unit TestRunner;

interface

procedure RunRegisteredTests; overload;
{$IFDEF CONSOLE_TESTRUNNER}
  {$IFDEF XMLOUTPUT}
procedure RunRegisteredTests(const OutputFileName: string); overload;
  {$ENDIF XMLOUTPUT}
{$ENDIF CONSOLE_TESTRUNNER}

implementation

uses
{$IFDEF CONSOLE_TESTRUNNER}
  SysUtils,
  TestUtils,
  {$IFDEF XMLOUTPUT}
    {$IFDEF WIN32}
      {$DEFINE WINDOWS}
    {$ELSE}
      {$IFDEF WIN64}
        {$DEFINE WINDOWS}
      {$ENDIF WIN64}
    {$ENDIF WIN32}
    {$IFDEF WINDOWS}
      VSoft.DUnit.XMLTestRunner, // better NUnit XSD support
    {$ELSE}
      FinalBuilder.XMLTestRunner, // more cross platform suitable, but bad NUnit XSD support
    {$ENDIF WINDOWS}
  {$ELSE}
    TextTestRunner,
  {$ENDIF XMLOUTPUT}
  TestFramework;
{$ELSE}
  {$IFNDEF FMX}
  Forms,
  GUITestRunner;
  {$ELSE}
  FMXTestRunner;
  {$ENDIF}
{$ENDIF CONSOLE_TESTRUNNER}

function IsRunningUnderDelphiDebugger: Boolean;
begin
{$WARN SYMBOL_PLATFORM OFF}
  // prevent [DCC Warning] ....pas(52): W1002 Symbol 'DebugHook' is specific to a platform
  Result := (DebugHook <> 0) { running as part of Delphi? }
{$WARN SYMBOL_PLATFORM OFF}
end;

procedure WaitForEnterWhenDebugHook;
begin
{$IFDEF DEBUG}
  if IsRunningUnderDelphiDebugger() then
  begin
    Write('Press <Enter>');
    Readln;
  end;
{$ENDIF DEBUG}
end;

{$IFDEF CONSOLE_TESTRUNNER}
  {$IFDEF XMLOUTPUT}
var
  OutputFilename: string = 'Tests.Reports.xml';
  {$ENDIF}
{$ENDIF}

procedure RunRegisteredTests;
{$IFDEF CONSOLE_TESTRUNNER}
  {$IFNDEF XMLOUTPUT}
var
  TestResult: TTestResult;
  {$ENDIF}
{$ENDIF}
begin
{$IFDEF CONSOLE_TESTRUNNER}
  {$IFDEF XMLOUTPUT}
    if ParamCount > 0 then
      OutputFilename := ParamStr(1);
    RunRegisteredTests(OutputFilename);
  {$ELSE}
    TestResult := TextTestRunner.RunRegisteredTests();
    ProcessTestResult(TestResult);
    WaitForEnterWhenDebugHook();
  {$ENDIF XMLOUTPUT}
{$ELSE}
  {$IFNDEF FMX}
  Application.Initialize();
  TGUITestRunner.RunRegisteredTests();
  {$ELSE}
  TFMXTestRunner.RunRegisteredTests();
  {$ENDIF}
  ReportMemoryLeaksOnShutdown := True;
{$ENDIF}
end;

{$IFDEF CONSOLE_TESTRUNNER}
  {$IFDEF XMLOUTPUT}
procedure RunRegisteredTests(const OutputFileName: string);
var
  TestResult: TTestResult;
  TestSuite: ITestSuite;
begin
  WriteLn('Writing output to ' + OutputFilename);
  TestSuite := RegisteredTests;
  if Assigned(TestSuite) then
    WriteLn(Format('Running %d of %d test cases', [TestSuite.CountEnabledTestCases, TestSuite.CountTestCases]));
  {$IFDEF WINDOWS}
    // better NUnit XSD support
    TestResult := VSoft.DUnit.XMLTestRunner.RunRegisteredTests(OutputFilename);
  {$ELSE}
    // more cross platform suitable, but bad NUnit XSD support
    TestResult := FinalBuilder.XMLTestRunner.RunRegisteredTests(OutputFile);
  {$ENDIF WINDOWS}
  ProcessTestResult(TestResult);
  WaitForEnterWhenDebugHook();
end;
  {$ENDIF XMLOUTPUT}
{$ENDIF CONSOLE_TESTRUNNER}

end.
