unit SucceedingTestCase;

interface

uses
  TestFramework;

type
  TSucceedingTestCase = class(TTestCase)
  published
    procedure SucceedingTest;
  end;

implementation

{ TSucceedingTestCase }

procedure TSucceedingTestCase.SucceedingTest;
begin
  // success: cannot be empty method: DUnit tests on a $C3 RET instruction being the start of the method
  if IsConsole then
end;

end.
