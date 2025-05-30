unit ADRConn.Model.Interfaces;

interface

uses
  Data.DB,
  System.Classes,
  System.SysUtils;

type
  TADRDriverConn = (adrFirebird, adrPostgres, adrMySql, adrSQLite, adrMSSQL, adrOracle,
    adrMongoDB);

  IADRConnectionEvents = interface;

  IADRConnectionParams = interface;

  IADRQueryParams = interface;

  IADRQueryBatchParams = interface;

  IADRGenerator = interface;

  TADRHandleException = TFunc<Exception, Boolean>;

  TADROnLog = TProc<string>;

  IADRConnection = interface
    ['{681E59C7-6AAC-47DE-AE6D-F649C1922565}']
    function Events: IADRConnectionEvents;
    function Connection: TCustomConnection;
    function Component: TComponent;

    function Params: IADRConnectionParams;

    function Connected: Boolean;
    function Connect: IADRConnection;
    function Disconnect: IADRConnection;
    function StartTransaction: IADRConnection;
    function Commit: IADRConnection;
    function Rollback: IADRConnection;
    function InTransaction: Boolean;
  end;

  IADRConnectionEvents = interface
    ['{18F33391-6D45-42A0-9AD7-DD4D54688402}']
    function OnHandleException(AValue: TADRHandleException): IADRConnectionEvents; overload;
    function OnHandleException: TADRHandleException; overload;

    function OnLog(AValue: TADROnLog): IADRConnectionEvents; overload;
    function OnLog: TADROnLog; overload;

    function HandleException(AException: Exception): Boolean;
    function Log(ALog: string): IADRConnectionEvents; overload;
    function Log(ALog: string; const AArgs: array of const): IADRConnectionEvents; overload;
  end;

  IADRConnectionParams = interface
    ['{439941DC-9841-478E-9E9A-BCAB3015DB9C}']
    function Database(AValue: string): IADRConnectionParams; overload;
    function Database: string; overload;
    function UserName(AValue: string): IADRConnectionParams; overload;
    function UserName: string; overload;
    function Password(AValue: string): IADRConnectionParams; overload;
    function Password: string; overload;
    function Server(AValue: string): IADRConnectionParams; overload;
    function Server: string; overload;
    function Schema(AValue: string): IADRConnectionParams; overload;
    function Schema: string; overload;
    function Lib(AValue: string): IADRConnectionParams; overload;
    function Lib: string; overload;
    function Port(AValue: Integer): IADRConnectionParams; overload;
    function Port: Integer; overload;
    function AutoCommit(AValue: Boolean): IADRConnectionParams; overload;
    function AutoCommit: Boolean; overload;
    function Driver(AValue: TADRDriverConn): IADRConnectionParams; overload;
    function Driver: TADRDriverConn; overload;
    function AppName(AValue: string): IADRConnectionParams; overload;
    function AppName: string; overload;
    function Settings: TFormatSettings;

    function AddParam(AName, AValue: string): IADRConnectionParams;
    function ParamNames: TArray<string>;
    function ParamByName(AName: string): string;

    function &End: IADRConnection;
  end;

  IADRQuery = interface
    ['{AE3BE608-658C-46D4-AC60-6F4EDB6AF90D}']
    function SQL(AValue: string): IADRQuery; overload;
    function SQL(AValue: string; const Args: array of const): IADRQuery; overload;
    function Clear: IADRQuery;

    function Component: TComponent;
    function DataSet: TDataSet;
    function DataSource(AValue: TDataSource): IADRQuery;

    function Params: IADRQueryParams;
    function BatchParams: IADRQueryBatchParams;

    function ParamAsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsLargeInt(AName: string; AValue: Largeint; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsStream(AName: string; AValue: TStream; ADataType: TFieldType = ftBlob; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;

    function ParamAsBoolean(AIndex: Integer; AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsCurrency(AIndex: Integer; AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDate(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsDateTime(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsFloat(AIndex: Integer; AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsInteger(AIndex: Integer; AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsLargeInt(AIndex: Integer; AName: string; AValue: Largeint; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsString(AIndex: Integer; AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQuery; overload;
    function ParamAsTime(AIndex: Integer; AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQuery; overload;

    function OpenDataSet: TDataSet;
    function Open: IADRQuery;
    function ExecSQL: IADRQuery;
    function ExecSQLAndCommit: IADRQuery;

    function Generator: IADRGenerator;
  end;

  IADRQueryParam = interface
    ['{E4A5F235-9646-4D26-936B-76CC3D7AF1AF}']
    function Name(AValue: string): IADRQueryParam; overload;
    function Name: string; overload;

    function DataType(AValue: TFieldType): IADRQueryParam; overload;
    function DataType: TFieldType; overload;

    function NullIfEmpty(AValue: Boolean): IADRQueryParam; overload;
    function NullIfEmpty: Boolean; overload;

    function NotEmpty(AValue: Boolean): IADRQueryParam; overload;
    function NotEmpty: Boolean; overload;

    function MinLength(AValue: Integer): IADRQueryParam; overload;
    function MinLength: Integer; overload;

    function MaxLength(AValue: Integer): IADRQueryParam; overload;
    function MaxLength: Integer; overload;

    function MinValue(AValue: Double): IADRQueryParam; overload;
    function MinValue: Double; overload;

    function MaxValue(AValue: Double): IADRQueryParam; overload;
    function MaxValue: Double; overload;

    procedure Validate;

    function AsBoolean(AValue: Boolean): IADRQueryParam; overload;
    function AsBoolean: Boolean; overload;
    function AsCurrency(AValue: Currency): IADRQueryParam; overload;
    function AsCurrency: Currency; overload;
    function AsDate(AValue: TDate): IADRQueryParam; overload;
    function AsDate: TDate; overload;
    function AsDateTime(AValue: TDateTime): IADRQueryParam; overload;
    function AsDateTime: TDateTime; overload;
    function AsFloat(AValue: Double): IADRQueryParam; overload;
    function AsFloat: Double; overload;
    function AsGuid(AValue: string): IADRQueryParam; overload;
    function AsInteger(AValue: Integer): IADRQueryParam; overload;
    function AsInteger: Integer; overload;
    function AsLargeint(AValue: Largeint): IADRQueryParam; overload;
    function AsLargeint: Largeint; overload;
    function AsStream(AValue: TStream): IADRQueryParam; overload;
    function AsStream: TStream; overload;
    function AsString(AValue: string): IADRQueryParam; overload;
    function AsString: string; overload;
    function AsTime(AValue: TTime): IADRQueryParam; overload;
    function AsTime: TTime; overload;

    function Build: TParam;
    function Param: TParam;
    function &End: IADRQueryParams;
  end;

  IADRQueryParams = interface
    ['{FC0A2424-6065-4D20-AF72-FA64E3327068}']
    function Params: TParams;
    function Build: TParams;
    function Clear: IADRQueryParams;
    procedure ValidateParameters;

    function AsBoolean(AName: string; AValue: Boolean; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsCurrency(AName: string; AValue: Currency; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsDate(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsDateTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsFloat(AName: string; AValue: Double; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsGuid(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsInteger(AName: string; AValue: Integer; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsLargeint(AName: string; AValue: Largeint; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsString(AName: string; AValue: string; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsTime(AName: string; AValue: TDateTime; ANullIfEmpty: Boolean = False): IADRQueryParam;
    function AsStream(AName: string; AValue: TStream; ADataType: TFieldType = ftBlob;
      ANullIfEmpty: Boolean = False): IADRQueryParam;

    function &End: IADRQuery;
  end;

  IADRQueryBatchParams = interface
    ['{6B9CE513-1051-4818-857B-8C6298BCEDB3}']
    function Params(AIndex: Integer): TParams;
    function Clear: IADRQueryBatchParams;
    function ArraySize: Integer;

    function AsBoolean(AIndex: Integer; AName: string; AValue: Boolean;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsCurrency(AIndex: Integer; AName: string; AValue: Currency;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsDate(AIndex: Integer; AName: string; AValue: TDateTime;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsDateTime(AIndex: Integer; AName: string; AValue: TDateTime;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsFloat(AIndex: Integer; AName: string; AValue: Double;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsInteger(AIndex: Integer; AName: string; AValue: Integer;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsLargeint(AIndex: Integer; AName: string; AValue: Largeint;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsString(AIndex: Integer; AName: string; AValue: string;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;
    function AsTime(AIndex: Integer; AName: string; AValue: TDateTime;
      ANullIfEmpty: Boolean = False): IADRQueryBatchParams;

    function &End: IADRQuery;
  end;

  IADRQueryParamValidator = interface
    ['{54D236DA-8D30-457F-AD5D-9AB7A086F560}']
    procedure Validate;
  end;

  IADRGenerator = interface
    ['{ABAB66A1-F210-4BD4-8594-F67F1781158A}']
    function GetCurrentSequence(AName: string): Double;
    function GetNextSequence(AName: string): Double;
  end;

  TADRDriverConnHelper = record helper for TADRDriverConn
  public
    function ToString: string;
    procedure FromString(AValue: string);
  end;

function CreateConnection: IADRConnection; overload;
function CreateConnection(AComponent: TComponent): IADRConnection; overload;
function CreateQuery(AConnection: IADRConnection): IADRQuery;

implementation

uses
{$IFDEF ADRCONN_FIREDAC}
  ADRConn.Model.Firedac.Connection,
  ADRConn.Model.Firedac.Query,
{$ENDIF}
{$IFDEF ADRCONN_PGDAC}
  ADRConn.Model.PgDAC.Connection,
  ADRConn.Model.PgDAC.Query,
{$ENDIF}
{$IFDEF ADRCONN_UNIDAC}
  ADRConn.Model.UniDAC.Connection,
  ADRConn.Model.UniDAC.Query,
{$ENDIF}
{$IFDEF ADRCONN_ZEOS}
  ADRConn.Model.Zeos.Connection,
  ADRConn.Model.Zeos.Query,
{$ENDIF}
  ADRConn.Model.Factory;

const
  DirectiveMessage = 'Use the ADRCONN_FIREDAC, ADRCONN_PGDAC or ADRCONN_UNIDAC directive ' +
    'to use a Engine Connection...';

function CreateConnection: IADRConnection;
begin
{$IFDEF ADRCONN_FIREDAC}
  Result := TADRConnModelFiredacConnection.New;
{$ELSEIF Defined(ADRCONN_PGDAC)}
  Result := TADRConnModelPgDACConnection.New;
{$ELSEIF Defined(ADRCONN_UNIDAC)}
  Result := TADRConnModelUniDACConnection.New;
{$ELSEIF Defined(ADRCONN_ZEOS)}
  Result := TADRConnModelZeosConnection.New;
{$ELSE}
  raise Exception.Create(DirectiveMessage);
{$ENDIF}
end;

function CreateConnection(AComponent: TComponent): IADRConnection;
begin
{$IFDEF ADRCONN_FIREDAC}
  Result := TADRConnModelFiredacConnection.New(AComponent);
{$ELSEIF Defined(ADRCONN_PGDAC)}
  Result := TADRConnModelPgDACConnection.New(AComponent);
{$ELSEIF Defined(ADRCONN_UNIDAC)}
  Result := TADRConnModelUniDACConnection.New(AComponent);
{$ELSEIF Defined(ADRCONN_ZEOS)}
  Result := TADRConnModelZeosConnection.New(AComponent);
{$ELSE}
  raise Exception.Create(DirectiveMessage);
{$ENDIF}
end;

function CreateQuery(AConnection: IADRConnection): IADRQuery;
begin
{$IFDEF ADRCONN_FIREDAC}
  Result := TADRConnModelFiredacQuery.New(AConnection);
{$ELSEIF Defined(ADRCONN_PGDAC)}
  Result := TADRConnModelPgDACQuery.New(AConnection);
{$ELSEIF Defined(ADRCONN_UNIDAC)}
  Result := TADRConnModelUniDACQuery.New(AConnection);
{$ELSEIF Defined(ADRCONN_ZEOS)}
  Result := TADRConnModelZeosQuery.New(AConnection);
{$ELSE}
  raise Exception.Create(DirectiveMessage);
{$ENDIF}
end;

{ TADRDriverConnHelper }

procedure TADRDriverConnHelper.FromString(AValue: string);
var
  LDriver: string;
begin
  LDriver := AValue.Trim.ToLower;
  if LDriver.Equals('firebird') then
  begin
    Self := adrFirebird;
    Exit;
  end;

  if LDriver.Equals('postgres') then
  begin
    Self := adrPostgres;
    Exit;
  end;

  if LDriver.Equals('mysql') then
  begin
    Self := adrMySql;
    Exit;
  end;

  if LDriver.Equals('sqlite') then
  begin
    Self := adrSQLite;
    Exit;
  end;

  if LDriver.Equals('oracle') then
  begin
    Self := adrOracle;
    Exit;
  end;

  if LDriver.Equals('mssql') then
  begin
    Self := adrMSSQL;
    Exit;
  end;

  if LDriver.Equals('mongodb') then
  begin
    Self := adrMongoDB;
    Exit;
  end;
end;

function TADRDriverConnHelper.ToString: string;
begin
  case Self of
    adrFirebird:
      Result := 'Firebird';
    adrPostgres:
      Result := 'Postgres';
    adrMySql:
      Result := 'MySQL';
    adrSQLite:
      Result := 'SQLite';
    adrMSSQL:
      Result := 'MSSQL';
    adrOracle:
      Result := 'Oracle';
    adrMongoDB:
      Result := 'MongoDB';
  end;
end;

end.
