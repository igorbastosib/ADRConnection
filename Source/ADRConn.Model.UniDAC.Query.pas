unit ADRConn.Model.UniDAC.Query;

interface

uses
  Data.DB,
  System.Classes,
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  MemDS,
  DBAccess,
  Uni,
  ADRConn.Model.Interfaces,
  ADRConn.Model.Generator,
  ADRConn.Model.QueryParam;

type
  TADRConnModelUniDACQuery = class(TInterfacedObject, IADRQuery)
  private
    [Weak]
    FConnection: IADRConnection;
    FQuery: TUniQuery;
    FGenerator: IADRGenerator;
    FBatchParams: IADRQueryBatchParams;
    FQueryParams: IADRQueryParams;
    FSQL: TStrings;

    function TryHandleException(AException: Exception): Boolean;
    procedure ExecSQLDefault;
    procedure ExecSQLBatch;
  protected
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
  public
    constructor Create(AConnection: IADRConnection);
    class function New(AConnection: IADRConnection): IADRQuery;
    destructor Destroy; override;
  end;

implementation

{ TADRConnModelUniDACQuery }

function TADRConnModelUniDACQuery.BatchParams: IADRQueryBatchParams;
begin
  if not Assigned(FBatchParams) then
    FBatchParams := TADRConnModelQueryBatchParams.New(Self);
  Result := FBatchParams;
end;

function TADRConnModelUniDACQuery.Clear: IADRQuery;
begin
  Result := Self;
  FSQL.Text := EmptyStr;
end;

function TADRConnModelUniDACQuery.Component: TComponent;
begin
  Result := FQuery;
end;

constructor TADRConnModelUniDACQuery.Create(AConnection: IADRConnection);
begin
  FConnection := AConnection;
  FQuery := TUniQuery.Create(nil);
  FQuery.Connection := TUniConnection(FConnection.Connection);
  FSQL := TStringList.Create;
  FQueryParams := TADRConnModelQueryParams.New(Self);
end;

function TADRConnModelUniDACQuery.DataSet: TDataSet;
begin
  Result := FQuery;
end;

function TADRConnModelUniDACQuery.DataSource(AValue: TDataSource): IADRQuery;
begin
  Result := Self;
  if Assigned(AValue) then
    AValue.DataSet := FQuery;
end;

destructor TADRConnModelUniDACQuery.Destroy;
begin
  FQuery.Free;
  FSQL.Free;
  inherited;
end;

function TADRConnModelUniDACQuery.ExecSQL: IADRQuery;
begin
  Result := Self;
  if Assigned(FBatchParams) then
    ExecSQLBatch
  else
    ExecSQLDefault;
end;

function TADRConnModelUniDACQuery.ExecSQLAndCommit: IADRQuery;
begin
  Result := Self;
  try
    FConnection.StartTransaction;
    try
      ExecSQL;
      FConnection.Commit;
    except
      FConnection.Rollback;
      raise;
    end;
  finally
    FSQL.Clear;
  end;
end;

procedure TADRConnModelUniDACQuery.ExecSQLBatch;
var
  I, J: Integer;
  LQuery: TUniQuery;
  LParams: TParams;
begin
  LQuery := TUniQuery.Create(nil);
  try
    try
      LQuery.Connection := TUniConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LQuery.Params.ValueCount := FBatchParams.ArraySize;

      if FBatchParams.ArraySize > 0 then
      begin
        LParams := FBatchParams.Params(0);
        for I := 0 to Pred(LParams.Count) do
          LQuery.Params[I].DataType := LParams[I].DataType;
      end;

      for I := 0 to Pred(FBatchParams.ArraySize) do
      begin
        LParams := FBatchParams.Params(I);
        for J := 0 to Pred(LParams.Count) do
        begin
          if LParams[J].IsNull then
            LQuery.ParamByName(LParams[J].Name)[I].Clear
          else
            LQuery.ParamByName(LParams[J].Name)[I].Value := LParams[J].Value;
        end;
      end;
      LQuery.Execute(FBatchParams.ArraySize);
    except
      on E: Exception do
      begin
        if not TryHandleException(E) then
          raise;

        ExecSQLBatch;
      end;
    end;
  finally
    FBatchParams := nil;
    FSQL.Clear;
    LQuery.Free;
  end;
end;

procedure TADRConnModelUniDACQuery.ExecSQLDefault;
var
  LQuery: TUniQuery;
  I: Integer;
  LParams: TParams;
begin
  LQuery := TUniQuery.Create(nil);
  try
    try
      LQuery.Connection := TUniConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LParams := FQueryParams.Params;
      for I := 0 to Pred(Params.Params.Count) do
      begin
        LQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        LQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;

      LQuery.ExecSQL;
    except
      on E: Exception do
      begin
        if not TryHandleException(E) then
          raise;

        ExecSQLDefault;
      end;
    end;
  finally
    FQueryParams.Clear;
    FSQL.Clear;
    LQuery.Free;
  end;
end;

function TADRConnModelUniDACQuery.Generator: IADRGenerator;
begin
  if not Assigned(FGenerator) then
    FGenerator := TADRConnModelGenerator.NewGenerator(FConnection, Self);
  Result := FGenerator;
end;

class function TADRConnModelUniDACQuery.New(AConnection: IADRConnection): IADRQuery;
begin
  Result := Self.Create(AConnection);
end;

function TADRConnModelUniDACQuery.Open: IADRQuery;
var
  I: Integer;
  LParams: TParams;
begin
  Result := Self;
  if FQuery.Active then
    FQuery.Close;

  FQuery.SQL.Text := FSQL.Text;
  try
    try
      LParams := FQueryParams.Params;
      for I := 0 to Pred(LParams.Count) do
      begin
        FQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        FQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;
      FQuery.Open;
    except
      on E: Exception do
      begin
        if not TryHandleException(E) then
          raise;

        Result := Open;
      end;
    end;
  finally
    FSQL.Clear;
    FQueryParams.Clear;
  end;
end;

function TADRConnModelUniDACQuery.OpenDataSet: TDataSet;
var
  LQuery: TUniQuery;
  I: Integer;
  LParams: TParams;
begin
  try
    LQuery := TUniQuery.Create(nil);
    try
      LQuery.Connection := TUniConnection(FConnection.Component);
      LQuery.SQL.Text := FSQL.Text;
      LParams := FQueryParams.Params;
      for I := 0 to Pred(LParams.Count) do
      begin
        LQuery.ParamByName(LParams[I].Name).DataType := LParams[I].DataType;
        LQuery.ParamByName(LParams[I].Name).Value := LParams[I].Value;
      end;
      LQuery.Open;
      Result := LQuery;
    except
      on E: Exception do
      begin
        LQuery.Free;
        if not TryHandleException(E) then
          raise;

        Result := OpenDataSet;
      end;
    end;
  finally
    FSQL.Clear;
    FQueryParams.Clear;
  end;
end;

function TADRConnModelUniDACQuery.ParamAsBoolean(AIndex: Integer;
  AName: string; AValue, ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsBoolean(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsBoolean(AName: string; AValue,
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsBoolean(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsCurrency(AName: string;
  AValue: Currency; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsCurrency(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsCurrency(AIndex: Integer;
  AName: string; AValue: Currency; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsCurrency(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsDate(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsDate(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsDate(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsDate(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsDateTime(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsDateTime(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsDateTime(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsDateTime(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsFloat(AIndex: Integer;
  AName: string; AValue: Double; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsFloat(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsFloat(AName: string;
  AValue: Double; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsFloat(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsInteger(AIndex: Integer;
  AName: string; AValue: Integer; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsInteger(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsLargeInt(AIndex: Integer; AName: string; AValue: Largeint;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsLargeint(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsLargeInt(AName: string; AValue: Largeint;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsLargeint(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsInteger(AName: string;
  AValue: Integer; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsInteger(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsString(AName, AValue: string;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsString(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsStream(AName: string;
  AValue: TStream; ADataType: TFieldType;
  ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsStream(AName, AValue, ADataType, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsString(AIndex: Integer; AName,
  AValue: string; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsString(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.ParamAsTime(AIndex: Integer;
  AName: string; AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  BatchParams.AsTime(AIndex, AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.Params: IADRQueryParams;
begin
  if not Assigned(FQueryParams) then
    FQueryParams := TADRConnModelQueryParams.New(Self);
  Result := FQueryParams;
end;

function TADRConnModelUniDACQuery.ParamAsTime(AName: string;
  AValue: TDateTime; ANullIfEmpty: Boolean): IADRQuery;
begin
  Result := Self;
  Params.AsTime(AName, AValue, ANullIfEmpty);
end;

function TADRConnModelUniDACQuery.SQL(AValue: string): IADRQuery;
begin
  Result := Self;
  FSQL.Add(AValue);
end;

function TADRConnModelUniDACQuery.SQL(AValue: string;
  const Args: array of const): IADRQuery;
begin
  Result := Self;
  SQL(Format(AValue, Args));
end;

function TADRConnModelUniDACQuery.TryHandleException(AException: Exception): Boolean;
begin
  Result := FConnection.Events.HandleException(AException);
end;

end.
