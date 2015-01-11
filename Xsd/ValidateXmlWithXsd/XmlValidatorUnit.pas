unit XmlValidatorUnit;

interface

uses
  Classes,
  msxml;

type
  /// loosely based on http://msdn.microsoft.com/en-us/library/ms765386(VS.85).aspx
  /// and http://www.nonhostile.com/howto-validate-xml-xsd-in-vb6.asp
  ///
  /// note there are a lot of headaches involved when your schemas are spread over multiple files and/or multiple namespaces
  ///   a few links:
  ///   http://kontrawize.blogs.com/kontrawize/2007/10/the-trouble-wit.html (The Trouble With XML Schema Imports and Includes)
  ///   using <xs:import> more than once for the same namespace is a grey area for W3C XML Schemas, and a typical behaviour for Schema validators is to process the first import for a particular namespace, but to ignore any subsequent imports for the same namespace.  This means you end up with missing definitions and invalid Schemas.
  ///
  ///   MSXML has issues where it cannot load XSD files referenced by relative paths.
  ///   .NET needs a workaround when loading an XSD schema by string, and setting the base path for the relative paths:
  ///   http://objectmix.com/xml-soap/86911-xs-include-path-how-avoid-full-paths.html
  ///   for MSXML this just does not work:
  ///   http://support.microsoft.com/kb/254643
  ///
  ///   http://msdn.microsoft.com/en-us/magazine/cc164169.aspx
  TXmlValidator = class(TObject)
  strict private
    FValidationResult: string;
  public
    function ValidateXml(const XmlFileName, XsdFileName: string): Boolean; overload;
    function ValidateXml(const XmlFileName: string; const XsdFileNames: array of string): Boolean; overload;
    function ValidateXml(const XmlFileName: string; const SchemaCollection: IXMLDOMSchemaCollection2): Boolean; overload;
    function ValidateXml(const XmlFileName: string; const XsdFileNames: TStrings): Boolean; overload;
    function ValidateXmlWithValidatedXsd(const XmlFileName, XsdFileName: string): Boolean; overload;
    function ValidateXmlWithValidatedXsd(const XmlFileName: string; const XsdFileNames: array of string): Boolean; overload;
    function ValidateXmlWithValidatedXsd(const XmlFileName: string; const SchemaCollection: IXMLDOMSchemaCollection2): Boolean; overload;
    function ValidateXmlWithValidatedXsd(const XmlFileName: string; const XsdFileNames: TStrings): Boolean; overload;
    property ValidationResult: string read FValidationResult;
  end;

implementation

uses
  Variants,
  SysUtils,
  ActiveX,
  ComObj,
  XMLDOMParseErrorToStringUnit,
  msxmlFactoryUnit;

function TXmlValidator.ValidateXml(const XmlFileName, XsdFileName: string): Boolean;
begin
  Result := ValidateXml(XmlFileName, [XsdFileName]);
end;

function TXmlValidator.ValidateXml(const XmlFileName: string; const XsdFileNames: array of string): Boolean;
var
  SchemaCollection: IXMLDOMSchemaCollection2;
begin
  SchemaCollection := TmsxmlFactory.CreateXMLDOMSchemaCollection2(XsdFileNames);
  Result := ValidateXml(XmlFileName, SchemaCollection);
end;

function TXmlValidator.ValidateXml(const XmlFileName: string; const SchemaCollection: IXMLDOMSchemaCollection2): Boolean;
var
  XmlDocument: IXMLDOMDocument3;
  parseError: IXMLDOMParseError;
begin
  XmlDocument := TmsxmlFactory.CreateXMLDOMDocument3WithValidateOnParseFromFile(XmlFileName);
  XmlDocument.schemas := SchemaCollection;

  parseError := XmlDocument.validate();
  FValidationResult := TXMLDOMParseErrorToString.ToString(parseError);

  Result := ValidationResult = NullAsStringValue;;
end;

function TXmlValidator.ValidateXml(const XmlFileName: string; const XsdFileNames: TStrings): Boolean;
var
  SchemaCollection: IXMLDOMSchemaCollection2;
begin
  SchemaCollection := TmsxmlFactory.CreateXMLDOMSchemaCollection2(XsdFileNames);
  Result := ValidateXml(XmlFileName, SchemaCollection);
end;

function TXmlValidator.ValidateXmlWithValidatedXsd(const XmlFileName, XsdFileName: string): Boolean;
begin
  Result := ValidateXmlWithValidatedXsd(XmlFileName, [XsdFileName]);
end;

function TXmlValidator.ValidateXmlWithValidatedXsd(const XmlFileName: string; const XsdFileNames: array of string): Boolean;
var
  SchemaCollection: IXMLDOMSchemaCollection2;
begin
  SchemaCollection := TmsxmlFactory.CreateXMLDOMSchemaCollection2(XsdFileNames);
  Result := ValidateXmlWithValidatedXsd(XmlFileName, SchemaCollection);
end;

function TXmlValidator.ValidateXmlWithValidatedXsd(const XmlFileName: string; const SchemaCollection: IXMLDOMSchemaCollection2): Boolean;
var
  XmlDocument: IXMLDOMDocument3;
  parseError: IXMLDOMParseError;
begin
  XmlDocument := TmsxmlFactory.CreateXMLDOMDocument3WithValidateOnParseFromFile(XmlFileName);
  XmlDocument.schemas := SchemaCollection;

  parseError := XmlDocument.validate();
  FValidationResult := TXMLDOMParseErrorToString.ToString(parseError);

  Result := ValidationResult = NullAsStringValue;;
end;

function TXmlValidator.ValidateXmlWithValidatedXsd(const XmlFileName: string; const XsdFileNames: TStrings): Boolean;
var
  SchemaCollection: IXMLDOMSchemaCollection2;
begin
  SchemaCollection := TmsxmlFactory.CreateXMLDOMSchemaCollection2(XsdFileNames);
  Result := ValidateXmlWithValidatedXsd(XmlFileName, SchemaCollection);
end;

initialization
  // http://chrisbensen.blogspot.com/2007/06/delphi-tips-and-tricks_26.html
  if Assigned(ComObj.CoInitializeEx) then
    ComObj.CoInitializeEx(nil, COINIT_MULTITHREADED)
  else
    CoInitialize(nil);
finalization
  CoUninitialize;
end.

