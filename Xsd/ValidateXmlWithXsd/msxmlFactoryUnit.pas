unit msxmlFactoryUnit;

interface

uses
{ up until Delphi 2009, msxml contains the import of C:\WINDOWS\SYSTEM\MSXML.DLL,
  as of Delphi 2010 it imports C:\WINDOWS\SYSTEM\MSXML6.DLL }
{$if CompilerVersion >= 21.0}
  msxml, // Delphi 2010 and up: IXMLDOMSchemaCollection2 et al
{$else}
  MSXML2_TLB, // Delphi < 2010: IXMLDOMSchemaCollection2 et al
  SysUtils,
{$ifend}
  Classes,
  FileVersionUnit;

type
{$if CompilerVersion >= 21.0}
{$else}
  CoFreeThreadedDOMDocument = ComsFreeThreadedDOMDocument;
  CoFreeThreadedDOMDocument26 = ComsFreeThreadedDOMDocument26;
  CoFreeThreadedDOMDocument30 = ComsFreeThreadedDOMDocument30;
  ENotSupportedException = class(Exception);
{$ifend}                   
  TAddXsdToSchemaCollectionMethod = procedure (SchemaCollection: IXMLDOMSchemaCollection2; XsdFileName: string) of object;
  TInnerCreateXMLDOMDocument2Method = function (): IXMLDOMDocument2 of object;
  TmsxmlFactory = class(TObject)
  strict private
    class var Fmsxml6FileVersion: TFileVersion;
    class var FmsxmlBestFileVersion: TFileVersion;
    class var FRetreivedFmsxml6FileVersion: Boolean;
    class var FRetreivedFmsxmlBestFileVersion: Boolean;
  strict protected
    class procedure AddValidatedXsdToSchemaCollection(SchemaCollection: IXMLDOMSchemaCollection2; XsdFileName: string); virtual;
    class procedure AddXsdToSchemaCollection(SchemaCollection: IXMLDOMSchemaCollection2; XsdFileName: string); virtual;
    class procedure AssertExistingFile(const XmlFileName: string); virtual;
    class function Getmsxml6FileVersion: TFileVersion; static;
    class function GetmsxmlBestFileVersion: TFileVersion; static; 
    class function GetmsxmlBestFileVersionInner: TFileVersion;
    class function InnerCreateXMLDOMDocument2: IXMLDOMDocument2; virtual;
    class function InnerCreateXMLDOMDocument2AndGetMsxmlVersion(const msxmlDllFileName: string; const InnerCreateXMLDOMDocument2Method: TInnerCreateXMLDOMDocument2Method): TFileVersion;
    class function InnerCreateXMLDOMDocument2_26: IXMLDOMDocument2; virtual;
    class function InnerCreateXMLDOMDocument2_30: IXMLDOMDocument2; virtual;
    class function InnerCreateXMLDOMDocument2_40: IXMLDOMDocument2; virtual;
    class function InnerCreateXMLDOMDocument3: IXMLDOMDocument3; virtual;
  public
    class procedure AssertCompatibleMsxml6Version; virtual;
    class function CreateValidatedXMLDOMSchemaCollection2(const XsdFileName: string): IXMLDOMSchemaCollection2; overload; static;
    class function CreateValidatedXMLDOMSchemaCollection2(const XsdFileNames: array of string): IXMLDOMSchemaCollection2; overload; 
    class function CreateValidatedXMLDOMSchemaCollection2(const XsdFileNames: TStrings): IXMLDOMSchemaCollection2; overload; 
    class function CreateXMLDOMDocument3: IXMLDOMDocument3; static;
    class function CreateXMLDOMDocument3FromFile(const XmlFileName: string): IXMLDOMDocument3; static;
    class function CreateXMLDOMDocument3WithValidateOnParse: IXMLDOMDocument3; static;
    class function CreateXMLDOMDocument3WithValidateOnParseFromFile(const XmlFileName: string): IXMLDOMDocument3; static;
    class function CreateXMLDOMSchemaCollection1(const XsdFileNames: array of string; const AddXsdToSchemaCollectionMethod: TAddXsdToSchemaCollectionMethod): IXMLDOMSchemaCollection2; overload; static;
    class function CreateXMLDOMSchemaCollection1(const XsdFileNames: TStrings; const AddXsdToSchemaCollectionMethod: TAddXsdToSchemaCollectionMethod): IXMLDOMSchemaCollection2; overload; static;
    class function CreateXMLDOMSchemaCollection2: IXMLDOMSchemaCollection2; overload; static;
    class function CreateXMLDOMSchemaCollection2(const XsdFileName: string): IXMLDOMSchemaCollection2; overload; static;
    class function CreateXMLDOMSchemaCollection2(const XsdFileNames: array of string): IXMLDOMSchemaCollection2; overload; 
    class function CreateXMLDOMSchemaCollection2(const XsdFileNames: TStrings): IXMLDOMSchemaCollection2; overload; 
    class property msxml6FileVersion: TFileVersion read Getmsxml6FileVersion;
    class property msxmlBestFileVersion: TFileVersion read GetmsxmlBestFileVersion;
  end;

implementation

uses
  Windows, // For AnsiSameText inline expansion
{$if CompilerVersion >= 21.0}
  SysUtils,
{$else}
{$ifend}
  XMLDOMParseErrorToStringUnit,
  Variants,
  SysConst,
  ShellAPI,
  ComObj;

const
  STargetNamespace = 'targetNamespace';
  SMsxmlDll = 'msxml.dll';
  SMsxml2Dll = 'msxml2.dll';
  SMsxml3Dll = 'msxml3.dll';
  SMsxml4Dll = 'msxml4.dll';
  SMsxml6Dll = 'msxml6.dll';

class procedure TmsxmlFactory.AddValidatedXsdToSchemaCollection(SchemaCollection: IXMLDOMSchemaCollection2; XsdFileName: string);
var
  XsdDocument: IXMLDOMDocument3;
  targetNamespaceNode: IXMLDOMNode;
  namespaceURI: string;
begin
  XsdDocument := TmsxmlFactory.CreateXMLDOMDocument3WithValidateOnParseFromFile(XsdFileName);
  targetNamespaceNode := XsdDocument.documentElement.attributes.getNamedItem(STargetNamespace);
  if Assigned(targetNamespaceNode) then
    namespaceURI := targetNamespaceNode.nodeValue
  else
    namespaceURI := NullAsStringValue;
  SchemaCollection.Add(namespaceURI, XsdDocument);
end;

class procedure TmsxmlFactory.AddXsdToSchemaCollection(SchemaCollection: IXMLDOMSchemaCollection2; XsdFileName: string);
var
  XsdDocument: IXMLDOMDocument3;
  targetNamespaceNode: IXMLDOMNode;
  namespaceURI: string;
begin
  XsdDocument := TmsxmlFactory.CreateXMLDOMDocument3FromFile(XsdFileName);
  targetNamespaceNode := XsdDocument.documentElement.attributes.getNamedItem(STargetNamespace);
  if Assigned(targetNamespaceNode) then
    namespaceURI := targetNamespaceNode.nodeValue
  else
    namespaceURI := NullAsStringValue;
  SchemaCollection.Add(namespaceURI, XsdDocument);
end;

class procedure TmsxmlFactory.AssertExistingFile(const XmlFileName: string);
var
  InOutError: EInOutError;
begin
  if not FileExists(XmlFileName) then
  begin
    InOutError := EInOutError.CreateFmt('%s: "%s"', [SFileNotFound, XmlFileName]);
    InOutError.ErrorCode := SE_ERR_FNF; //##jpl:todo find a better way to generate a "file not found" exception
    raise InOutError;
  end;
end;

class function TmsxmlFactory.Getmsxml6FileVersion: TFileVersion;
var
  XmlDocument: IXMLDOMDocument3;
begin
  if not FRetreivedFmsxml6FileVersion then
  begin
    XmlDocument := InnerCreateXMLDOMDocument3();
    // now msxml6.dll is loaded, if it is installed, otherwise you get this exception:
    //   Class not registered, ClassID: {88D96A06-F192-11D4-A65F-0040963251E5}.
    // XmlDocument.loadXML('<root>text</root>');
    Fmsxml6FileVersion := TFileVersion.Create(SMsxml6Dll);
    FRetreivedFmsxml6FileVersion := True;
  end;
  Result := Fmsxml6FileVersion;
end;

class function TmsxmlFactory.GetmsxmlBestFileVersion: TFileVersion;
begin
  Result := GetmsxmlBestFileVersionInner;
end;

class function TmsxmlFactory.GetmsxmlBestFileVersionInner: TFileVersion;
var
  localMsxmlBestFileVersion: TFileVersion;
begin
  // MSXML versions http://support.microsoft.com/kb/269238
  // http://msdn.microsoft.com/en-us/data/bb291077
  // avoid MSXML 2, MSXML 4, and MSXML 5.
  // prefer MSXML 6 over MSXML 3 (as MSXML 3 defaults to SelectionLanguage=XSLPattern, and does not support namespaces in XPath)
  if not FRetreivedFmsxmlBestFileVersion then
  begin
    try
      FmsxmlBestFileVersion := Getmsxml6FileVersion;
    except
      on E: EOleSysError do
      try
        localMsxmlBestFileVersion := InnerCreateXMLDOMDocument2AndGetMsxmlVersion(SMsxml4Dll, InnerCreateXMLDOMDocument2_40);
      except
        on E: EOleSysError do
        try
          FmsxmlBestFileVersion  := InnerCreateXMLDOMDocument2AndGetMsxmlVersion(SMsxml3Dll, InnerCreateXMLDOMDocument2_30);
        except
          on E: EOleSysError do
          try
            FmsxmlBestFileVersion  := InnerCreateXMLDOMDocument2AndGetMsxmlVersion(SMsxml2Dll, InnerCreateXMLDOMDocument2_26);
          except
            on E: EOleSysError do
              FmsxmlBestFileVersion  := InnerCreateXMLDOMDocument2AndGetMsxmlVersion(SMsxmlDll, InnerCreateXMLDOMDocument2);
          end; // try
        end; // try
      end; // try
    end; // try
    FRetreivedFmsxmlBestFileVersion := True;
  end;
  Result := FmsxmlBestFileVersion;
end;

class function TmsxmlFactory.InnerCreateXMLDOMDocument2: IXMLDOMDocument2;
begin
  Result := CoFreeThreadedDOMDocument.Create;
  if not Assigned(Result) then
    raise ENotSupportedException.Create('CoFreeThreadedDOMDocument.Create()');
end;

class function TmsxmlFactory.InnerCreateXMLDOMDocument2AndGetMsxmlVersion(const msxmlDllFileName: string; const InnerCreateXMLDOMDocument2Method:
    TInnerCreateXMLDOMDocument2Method): TFileVersion;
var
  XmlDocument: IXMLDOMDocument2;
begin
  XmlDocument := InnerCreateXMLDOMDocument2Method();
  // now msxmlDllFileName is loaded, if it is installed
  Result := TFileVersion.Create(msxmlDllFileName);
end;

class function TmsxmlFactory.InnerCreateXMLDOMDocument2_26: IXMLDOMDocument2;
begin
  Result := CoFreeThreadedDOMDocument26.Create;
  if not Assigned(Result) then
    raise ENotSupportedException.Create('CoFreeThreadedDOMDocument26.Create()');
end;

class function TmsxmlFactory.InnerCreateXMLDOMDocument2_30: IXMLDOMDocument2;
begin
  Result := CoFreeThreadedDOMDocument30.Create;
  if not Assigned(Result) then
    raise ENotSupportedException.Create('CoFreeThreadedDOMDocument30.Create()');
end;

class function TmsxmlFactory.InnerCreateXMLDOMDocument2_40: IXMLDOMDocument2;
begin
  Result := CoFreeThreadedDOMDocument40.Create;
  if not Assigned(Result) then
    raise ENotSupportedException.Create('CoFreeThreadedDOMDocument40.Create()');
end;

class function TmsxmlFactory.InnerCreateXMLDOMDocument3: IXMLDOMDocument3;
begin
  Result := CoFreeThreadedDOMDocument60.Create;
  if not Assigned(Result) then
    raise ENotSupportedException.Create('CoFreeThreadedDOMDocument60.Create()');
end;

class procedure TmsxmlFactory.AssertCompatibleMsxml6Version;
const
  LastBadMinimimFileMajorPart = 6;
  LastBadMinimumFileMinorPart = 20;
  LastBadMinimumFileBuildPart = 1099;
var
  msxml6FileVersionTooLow: Boolean;
  msxmlFileVersion: TFileVersion;
begin
  msxmlFileVersion := msxmlBestFileVersion;
  msxml6FileVersionTooLow := not AnsiSameText(SMsxml6Dll, msxmlFileVersion.FileName);
  msxml6FileVersionTooLow := msxml6FileVersionTooLow or
    (msxmlFileVersion.FileMajorPart < LastBadMinimimFileMajorPart);
  msxml6FileVersionTooLow := msxml6FileVersionTooLow or
    ((msxmlFileVersion.FileMajorPart = LastBadMinimimFileMajorPart) and (msxmlFileVersion.FileMinorPart < LastBadMinimumFileMinorPart));
  msxml6FileVersionTooLow := msxml6FileVersionTooLow or
    ((msxmlFileVersion.FileMajorPart = LastBadMinimimFileMajorPart) and (msxmlFileVersion.FileMinorPart = LastBadMinimumFileMinorPart) and (msxmlFileVersion.FileBuildPart <= LastBadMinimumFileBuildPart));
  if msxml6FileVersionTooLow then
    raise ENotSupportedException.CreateFmt(
      '%s must be newer than version %d.%d.%d.* (you need 6.30.*, 6.20.1103.*, 6.20.2003.0 or higher), but you have version %s',
      [SMsxml6Dll, LastBadMinimimFileMajorPart, LastBadMinimumFileMinorPart, LastBadMinimumFileBuildPart, msxmlFileVersion.ToString()]);
end;

class function TmsxmlFactory.CreateValidatedXMLDOMSchemaCollection2(const XsdFileName: string): IXMLDOMSchemaCollection2;
begin
  Result := CreateValidatedXMLDOMSchemaCollection2([XsdFileName]);
end;

class function TmsxmlFactory.CreateValidatedXMLDOMSchemaCollection2(const XsdFileNames: array of string): IXMLDOMSchemaCollection2;
begin
  Result := CreateXMLDOMSchemaCollection1(XsdFileNames, AddValidatedXsdToSchemaCollection);
end;

class function TmsxmlFactory.CreateValidatedXMLDOMSchemaCollection2(const XsdFileNames: TStrings): IXMLDOMSchemaCollection2;
begin
  Result := CreateXMLDOMSchemaCollection1(XsdFileNames, AddValidatedXsdToSchemaCollection);
end;

class function TmsxmlFactory.CreateXMLDOMDocument3: IXMLDOMDocument3;
begin
  Result := InnerCreateXMLDOMDocument3();
end;

class function TmsxmlFactory.CreateXMLDOMDocument3FromFile(const XmlFileName: string): IXMLDOMDocument3;
begin
  AssertExistingFile(XmlFileName);
  AssertCompatibleMsxml6Version();
  Result := CreateXMLDOMDocument3();
  if not Result.load(XmlFileName) then
    raise EXMLDOMParseError.Create(Result.parseError);
end;

class function TmsxmlFactory.CreateXMLDOMDocument3WithValidateOnParse: IXMLDOMDocument3;
begin
  Result := CreateXMLDOMDocument3();
  Result.validateOnParse := True;
end;

class function TmsxmlFactory.CreateXMLDOMDocument3WithValidateOnParseFromFile(const XmlFileName: string): IXMLDOMDocument3;
begin
  AssertExistingFile(XmlFileName);
  AssertCompatibleMsxml6Version();
  Result := CreateXMLDOMDocument3WithValidateOnParse();
  if not Result.load(XmlFileName) then
    raise EXMLDOMParseError.Create(Result.parseError);
end;

class function TmsxmlFactory.CreateXMLDOMSchemaCollection1(const XsdFileNames: array of string; const AddXsdToSchemaCollectionMethod:
    TAddXsdToSchemaCollectionMethod): IXMLDOMSchemaCollection2;
var
  SchemaCollection: IXMLDOMSchemaCollection2;
  XsdFileName: string;
begin
  SchemaCollection := TmsxmlFactory.CreateXMLDOMSchemaCollection2();

  for XsdFileName in XsdFileNames do
    AddXsdToSchemaCollectionMethod(SchemaCollection, XsdFileName);

  Result := SchemaCollection;
end;

class function TmsxmlFactory.CreateXMLDOMSchemaCollection1(const XsdFileNames: TStrings; const AddXsdToSchemaCollectionMethod:
    TAddXsdToSchemaCollectionMethod): IXMLDOMSchemaCollection2;
var
  SchemaCollection: IXMLDOMSchemaCollection2;
  XsdFileName: string;
begin
  SchemaCollection := TmsxmlFactory.CreateXMLDOMSchemaCollection2();

  for XsdFileName in XsdFileNames do
    AddXsdToSchemaCollectionMethod(SchemaCollection, XsdFileName);

  Result := SchemaCollection;
end;

class function TmsxmlFactory.CreateXMLDOMSchemaCollection2: IXMLDOMSchemaCollection2;
begin
  Result := CoXMLSchemaCache60.Create();
  if not Assigned(Result) then
    raise ENotSupportedException.Create('CoXMLSchemaCache60.Create()');
end;

class function TmsxmlFactory.CreateXMLDOMSchemaCollection2(const XsdFileName: string): IXMLDOMSchemaCollection2;
begin
  Result := CreateXMLDOMSchemaCollection2([XsdFileName]);
end;

class function TmsxmlFactory.CreateXMLDOMSchemaCollection2(const XsdFileNames: array of string): IXMLDOMSchemaCollection2;
begin
  Result := CreateXMLDOMSchemaCollection1(XsdFileNames, AddXsdToSchemaCollection);
end;

class function TmsxmlFactory.CreateXMLDOMSchemaCollection2(const XsdFileNames: TStrings): IXMLDOMSchemaCollection2;
begin
  Result := CreateXMLDOMSchemaCollection1(XsdFileNames, AddXsdToSchemaCollection);
end;

end.
