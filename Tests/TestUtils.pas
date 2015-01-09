// Based on Spring.TestUtils in Spring4D

unit TestUtils;

interface

uses
  TestFramework,
  Classes,
  IniFiles;

procedure ProcessTestResult(const ATestResult: TTestResult);

type
  TTestDecorator = class(TAbstractTest)
  private
    fTest: ITest;
    fTests: IInterfaceList;
  protected
    procedure RunTest(ATestResult: TTestResult); override;
  public
    constructor Create(const ATest: ITest; const AName: string = '');

    function CountEnabledTestCases: Integer; override;
    function CountTestCases: Integer; override;

    function GetName: string; override;
    function Tests: IInterfaceList; override;

    procedure LoadConfiguration(const iniFile: TCustomIniFile; const section: string); override;
    procedure SaveConfiguration(const iniFile: TCustomIniFile; const section: string); override;

    property Test: ITest read fTest;
  end;

  TRepeatedTest = class(TTestDecorator)
  private
    fCount: Integer;
  protected
    procedure RunTest(ATestResult: TTestResult); override;
  public
    constructor Create(const ATest: ITest; ACount: Integer; const AName: string = '');
    function GetName: string; override;

    function CountEnabledTestCases: Integer; override;
    function CountTestCases: Integer; override;
  end;

implementation

uses
  SysUtils;

procedure ProcessTestResult(const ATestResult: TTestResult);
begin
{$IFNDEF AUTOREFCOUNT}
  ATestResult.Free();
{$ENDIF}
end;

{$REGION 'TTestDecorator'}

constructor TTestDecorator.Create(const ATest: ITest; const AName: string);
begin
  if AName = '' then
    inherited Create(ATest.Name)
  else
    inherited Create(AName);
  fTest := ATest;
  fTests := TInterfaceList.Create;
  fTests.Add(fTest);
end;

function TTestDecorator.GetName: string;
begin
  Result := fTest.Name;
end;

function TTestDecorator.CountEnabledTestCases: Integer;
begin
  if Enabled then
    Result := fTest.CountEnabledTestCases
  else
    Result := 0;
end;

function TTestDecorator.CountTestCases: Integer;
begin
  if Enabled then
    Result := fTest.CountTestCases
  else
    Result := 0;
end;

procedure TTestDecorator.RunTest(ATestResult: TTestResult);
begin
  fTest.RunWithFixture(ATestResult);
end;

function TTestDecorator.Tests: IInterfaceList;
begin
  Result := fTests;
end;

procedure TTestDecorator.LoadConfiguration(const iniFile: TCustomIniFile;
  const section: string);
var
  i: Integer;
begin
  inherited LoadConfiguration(iniFile, section);
  for i := 0 to fTests.Count - 1 do
    ITest(fTests[i]).LoadConfiguration(iniFile, section + '.' + Name);
end;

procedure TTestDecorator.SaveConfiguration(const iniFile: TCustomIniFile;
  const section: string);
var
  i: integer;
begin
  inherited SaveConfiguration(iniFile, section);
  for i := 0 to fTests.Count - 1 do
    ITest(fTests[i]).SaveConfiguration(iniFile, section + '.' + Name);
end;

{$ENDREGION}


{$REGION 'TRepeatedTest'}

constructor TRepeatedTest.Create(const ATest: ITest; ACount: Integer;
  const AName: string);
begin
  inherited Create(ATest, AName);
  fCount := ACount;
end;

function TRepeatedTest.CountEnabledTestCases: Integer;
begin
  Result := inherited CountEnabledTestCases * fCount;
end;

function TRepeatedTest.CountTestCases: Integer;
begin
  Result := inherited CountTestCases * fCount;
end;

function TRepeatedTest.GetName: string;
begin
  Result := Format('%d x %s', [fCount, Test.Name]);
end;

procedure TRepeatedTest.RunTest(ATestResult: TTestResult);
var
  i: Integer;
  errorCount: Integer;
  failureCount: integer;
begin
  errorCount := ATestResult.ErrorCount;
  failureCount := ATestResult.FailureCount;

  for i := 0 to fCount - 1 do
  begin
    if ATestResult.ShouldStop
      or (ATestResult.ErrorCount > errorCount)
      or (ATestResult.FailureCount > failureCount) then
      Break;
    inherited RunTest(ATestResult);
  end;
end;

{$ENDREGION}

end.
