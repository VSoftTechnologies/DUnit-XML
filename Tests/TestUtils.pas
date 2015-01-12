// Based on Spring.TestUtils in Spring4D

unit TestUtils;

interface

uses
  TestFramework;

procedure ProcessTestResult(const ATestResult: TTestResult);

implementation

procedure ProcessTestResult(const ATestResult: TTestResult);
begin
{$IFNDEF AUTOREFCOUNT}
  ATestResult.Free();
{$ENDIF}
end;

end.
