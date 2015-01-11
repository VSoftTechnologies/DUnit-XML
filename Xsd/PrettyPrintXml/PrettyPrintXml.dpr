program PrettyPrintXml;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  ActiveX,
  ComObj,
  XMLIntf,
  XMLDoc,
  xmldom;

procedure Run();
var
  InputDocument: IXMLDocument;
  InputXml: DOMString;
  OutputDocument: IXMLDocument;
  OutputXml: DOMString;
begin
  if ParamCount <> 2 then
  begin
    Writeln('Pretty prints XML from Source to Destionation.');
    Writeln('Use two parameters: SourceXmlFilename and DestinationXmlFilename.');
  end
  else
  begin
    // Force CoInitialize or CoInitializeEx to be called the Delphi way.
    // Assume multi-threading (just in case we ever use this example code in a MultiThreaded app).
    CoInitFlags := COINIT_MULTITHREADED;
    if InitProc <> nil then
      TProcedure(InitProc);

    InputDocument := TXMLDocument.Create(nil);
    InputDocument.LoadFromFile(ParamStr(1));
    InputDocument.SaveToXML(InputXml);
    OutputXml := FormatXMLData(InputXml);
    OutputDocument := TXMLDocument.Create(nil);
    OutputDocument.LoadFromXML(OutputXml);
    OutputDocument.SaveToFile(ParamStr(2));
  end;
end;

function IsRunningUnderDelphiDebugger: Boolean;
begin
{$WARN SYMBOL_PLATFORM OFF}
  // prevent [DCC Warning] ....pas(52): W1002 Symbol 'DebugHook' is specific to a platform
  Result := (DebugHook <> 0) { running as part of Delphi? }
{$WARN SYMBOL_PLATFORM ON}
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
