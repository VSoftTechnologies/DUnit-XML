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

function IsRunningUnderDelphiDebugger: Boolean;
begin
{$WARN SYMBOL_PLATFORM OFF}
  // prevent [DCC Warning] ....pas(52): W1002 Symbol 'DebugHook' is specific to a platform
  Result := (DebugHook <> 0) { running as part of Delphi? }
{$WARN SYMBOL_PLATFORM OFF}
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
    if IsRunningUnderDelphiDebugger then
    begin
      Write('Press <Enter>');
      Readln;
    end;
{$endif DEBUG}
  end;
end.
