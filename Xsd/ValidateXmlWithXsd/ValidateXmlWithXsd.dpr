program ValidateXmlWithXsd;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  FileVersionUnit in 'FileVersionUnit.pas',
  msxmlFactoryUnit in 'msxmlFactoryUnit.pas',
  XMLDOMParseErrorToStringUnit in 'XMLDOMParseErrorToStringUnit.pas',
  XmlValidatorUnit in 'XmlValidatorUnit.pas';

procedure Run();
begin
  if ParamCount <> 2 then
  begin
    Writeln('Validates XML against XSD.');
    Writeln('Use two parameters: XmlFilename and XsdFilename.');
  end
  else
  begin
    with TXmlValidator.Create do
      try
        if ValidateXml(ParamStr(1), ParamStr(2)) then
          Writeln('OK')
        else
        begin
          Writeln(ValidationResult);
        end;
      finally
        Free;
      end;
  end;
end;

begin
  try
    try
      Run();
    except
      on E: Exception do
        Writeln(E.Classname, ': ', E.Message);
    end;
  finally
{$ifdef DEBUG}
    Write('Press <Enter>');
    Readln;
{$endif DEBUG}
  end;
end.
