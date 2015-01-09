unit FailingTestCase;

interface

uses
  TestFramework;

type
  TFailingTestCase = class(TTestCase)
  published
    procedure FailingTest;
  end;

implementation

procedure TFailingTestCase.FailingTest;
begin
  Fail('intentional');
end;

end.
