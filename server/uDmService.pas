unit uDmService;

interface

uses
  SysUtils, Classes, IBConnection, sqldb, SysTypes, uDWDatamodule,
  uDWJSONObject, Dialogs, ZConnection, ZDataset, ServerUtils, uDWConsts,
  uDWConstsData, RestDWServerFormU, uRESTDWPoolerDB, uRESTDWServerEvents,
  uRESTDWServerContext, uRestDWLazDriver, uRESTDWDriverZEOS, uDWJSONTools,
  uDWConstsCharset, Graphics, uDWAbout, uSystemEvents;

type

  { TServerMethodDM }

  TServerMethodDM = class(TServerMethodDataModule)
    DWServerContext1: TDWServerContext;
    DWServerEvents1: TDWServerEvents;
    sqlPedido: TRESTDWClientSQL;
    sqlComplemento: TRESTDWClientSQL;
    RESTDWDriverZeos1: TRESTDWDriverZeos;
    RESTDWPoolerDB1: TRESTDWPoolerDB;
    ZConnection1: TZConnection;
    zQuery1: TZQuery;
    procedure DataModuleWelcomeMessage(Welcomemsg, AccessTag: string;
      var ConnectionDefs: TConnectionDefs; var Accept: boolean;
      var ContentType, ErrorMessage: string);
    procedure DWServerEvents1EventsClientesReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsGenericoReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsGravarReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsGravaVendasReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsLoginReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure DWServerEvents1EventsStatusReplyEvent(var Params: TDWParams;
      var Result: string);
    procedure ServerMethodDataModuleCreate(Sender: TObject);
    procedure ZConnection1BeforeConnect(Sender: TObject);

    function Login(aValue: string): boolean;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ServerMethodDM: TServerMethodDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.lfm}

procedure TServerMethodDM.ServerMethodDataModuleCreate(Sender: TObject);
begin
  RESTDWPoolerDB1.Active := True;
end;

procedure TServerMethodDM.DWServerEvents1EventsGenericoReplyEvent(
  var Params: TDWParams;
  var Result: string);
var
  lQry: TZQuery;
  JSONValue: TJSONValue;
  s: string;
begin
  JSONValue := TJSONValue.Create;
  try
    s := DecodeStrings(Params.ItemsString['pSelect'].AsString, csUndefined);
    if s <> '' then
    begin
      lQry := TZQuery.Create(nil);
      lQry.Connection := ZConnection1;
      try
        lQry.SQL.Clear;
        lQry.SQL.add(s);
        lQry.Open();

        if not lQry.IsEmpty then
        begin
          JSONValue.Utf8SpecialChars := False;
          JSONValue.LoadFromDataset('', lQry, False, jmPureJSON);
          Result := JSONValue.ToJson;
        end
        else
          Result := 'erro';

      finally
        lQry.Close;
        FreeAndNil(lQry);
      end;
    end;
  finally
    FreeAndNil(JSONValue);
  end;

end;

procedure TServerMethodDM.DWServerEvents1EventsGravarReplyEvent(
  var Params: TDWParams; var Result: string);
var
  lQry: TZQuery;
  sqlHeader, sqlItem: TRESTDWClientSQL;
begin
  lQry := TZQuery.Create(nil);
  sqlHeader := TRESTDWClientSQL.Create(nil);
  sqlItem := TRESTDWClientSQL.Create(nil);

  sqlHeader.OpenJson(DecodeStrings(Params.ItemsString['pHeader'].AsString,
    csUndefined));
  try
    try
      if not sqlHeader.IsEmpty then
      begin
        sqlHeader.First;
        while not sqlHeader.EOF do
        begin
          lQry.Close;
          lQry.SQL.Clear;
          lQry.SQL.Text :=
            'UPDATE OR INSERT INTO PEDIDO (ID, VENDEDOR, CLIENTE, DIA)' +
            ' values (:ID, :VENDEDOR, :CLIENTE, :DIA)';
          lQry.ParamByName('ID').AsInteger :=
            Params.ItemsString['ID'].AsInteger;
          lQry.ParamByName('VENDEDOR').AsInteger :=
            Params.ItemsString['VENDEDOR'].AsInteger;
          lQry.ParamByName('CLIENTE').AsInteger := sqlHeader.Fields[4].AsInteger;
          lQry.ParamByName('CLIENTE').AsInteger := sqlHeader.Fields[0].AsInteger;
          lQry.Connection.StartTransaction;
          lQry.ExecSQL;
          lQry.Connection.Commit;
          sqlHeader.Next;
          //itens do pedido
          if (Params.ItemsString['pItem'] <> nil) then
          begin
            sqlItem.OpenJson(
              DecodeStrings(Params.ItemsString['pItem'].AsString, csUndefined));
            if not sqlItem.IsEmpty then
            begin
              sqlItem.First;
              lQry.Close;
              lQry.SQL.Clear;
              lQry.SQL.Text :=
                'UPDATE OR INSERT INTO ITEM (PEDIDO, PRODUTO, QTDE, UNITARIO) ' +
                ' values (:PEDIDO, PRODUTO :QTDE, :UNITARIO)';
              lQry.ParamByName('PEDIDO').AsInteger := sqlItem.Fields[1].AsInteger;
              lQry.ParamByName('PRODUTO').AsInteger :=
                sqlItem.Fields[2].AsInteger;
              lQry.ParamByName('QTDE').AsFloat := sqlItem.Fields[3].AsFloat;
              lQry.ParamByName('UNITARIO').AsFloat := sqlItem.Fields[3].AsFloat;
              lQry.Connection.StartTransaction;
              lQry.ExecSQL;
              lQry.Connection.Commit;
              sqlItem.Next;
            end;
          end;
        end;
        Result := 'ok';
      end;
    except
      Result := 'erro';
    end;
  finally
    FreeAndNil(lQry);
    FreeAndNil(sqlHeader);
    FreeAndNil(sqlItem);
  end;

end;

procedure TServerMethodDM.DWServerEvents1EventsGravaVendasReplyEvent(
  var Params: TDWParams; var Result: string);
var
  a: TDate;
begin
  sqlPedido.OpenJson(DecodeStrings(Params.ItemsString['pHeader'].AsString,
    csUndefined));
  if not sqlPedido.IsEmpty then
  begin
    sqlPedido.First;
    while not sqlPedido.EOF do
    begin
      ZQuery1.Close;
      ZQuery1.SQL.Clear;
      ZQuery1.SQL.Text :=
        'insert into PEDIDO (ID, VENDEDOR, CLIENTE, DIA, CONFERIDO)' +
        ' values (:ID, :VENDEDOR, :CLIENTE, :DIA, 0)';

      ZQuery1.ParamByName('ID').AsString := sqlPedido.Fields[0].AsString;
      ZQuery1.ParamByName('VENDEDOR').AsInteger := sqlPedido.Fields[1].AsInteger;
      ZQuery1.ParamByName('CLIENTE').AsString := sqlPedido.Fields[2].AsString;
      a := StrToDate(sqlPedido.Fields[4].AsString);
      ZQuery1.ParamByName('DIA').AsDate := a;

      ZQuery1.Connection.StartTransaction;
      ZQuery1.ExecSQL;
      ZQuery1.Connection.Commit;

      sqlPedido.Next;

    end;
  end;
  sqlComplemento.OpenJson(
    DecodeStrings(Params.ItemsString['pItens'].AsString, csUndefined));
  if not sqlComplemento.IsEmpty then
  begin
    sqlComplemento.First;

    while not sqlComplemento.EOF do
    begin

      ZQuery1.Close;
      ZQuery1.SQL.Clear;
      ZQuery1.SQL.Text := 'insert into ITEM (PEDIDO, PRODUTO, QTDE, SUBTOTAL) ' +
        ' values (:PEDIDO, :PRODUTO, :QTDE, :SUBTOTAL)';

      ZQuery1.ParamByName('PEDIDO').AsString := sqlComplemento.Fields[1].AsString;
      ZQuery1.ParamByName('PRODUTO').AsInteger := sqlComplemento.Fields[2].AsInteger;
      ZQuery1.ParamByName('QTDE').AsFloat := sqlComplemento.Fields[3].AsFloat;
      ZQuery1.ParamByName('SUBTOTAL').AsString := sqlComplemento.Fields[4].AsString;

      ZQuery1.Connection.StartTransaction;
      ZQuery1.ExecSQL;
      ZQuery1.Connection.Commit;

      sqlComplemento.Next;

    end;
  end;

end;

procedure TServerMethodDM.DWServerEvents1EventsLoginReplyEvent(
  var Params: TDWParams; var Result: string);
//http://192.168.0.105:8082/Login?dwaccesstag=cHJpdmFkbw==&user=ZGF0YXByaW1l&pwd=c2VuaGE=
var
  lQry: TZQuery;
  JSONValue: TJSONValue;
  u, s: string;
begin
  JSONValue := TJSONValue.Create;
  try
    u := DecodeStrings(Params.ItemsString['user'].AsString, csUndefined);
    s := DecodeStrings(Params.ItemsString['pwd'].AsString, csUndefined);
    if u <> '' then
    begin
      lQry := TZQuery.Create(nil);
      lQry.Connection := ZConnection1;
      try
        lQry.SQL.Clear;
        lQry.SQL.add('select codigo, nome from usuario ');
        lQry.SQL.add(' where login = :login            ');
        lQry.SQL.add('   and senha = :senha            ');
        lQry.ParamByName('login').AsString := u;
        lQry.ParamByName('senha').AsString := s;
        lQry.Open();
        if not lQry.IsEmpty then
        begin
          JSONValue.Utf8SpecialChars := False;
          JSONValue.LoadFromDataset('', lQry, False, jmPureJSON);
          Result := JSONValue.ToJson;
        end
        else
          Result := 'erro';
      finally
        lQry.Close;
        FreeAndNil(lQry);
      end;
    end;
  finally
    FreeAndNil(JSONValue);
  end;

end;

procedure TServerMethodDM.DWServerEvents1EventsStatusReplyEvent(
  var Params: TDWParams; var Result: string);
begin
  Result := 'Servidor REST Dataware - [ ' + DateTimeToStr(Now);
end;

procedure TServerMethodDM.DataModuleWelcomeMessage(Welcomemsg, AccessTag: string;
  var ConnectionDefs: TConnectionDefs; var Accept: boolean;
  var ContentType, ErrorMessage: string);
begin
  (*Accept := false;
  Accept := Login( Welcomemsg );
  if not Accept then
    ErrorMessage := '0';  *)
end;

procedure TServerMethodDM.DWServerEvents1EventsClientesReplyEvent(
  var Params: TDWParams;
  var Result: string);
var
  lQry: TZQuery;
  sqlHeader: TRESTDWClientSQL;
begin
  lQry := TZQuery.Create(nil);
  lQry.Connection := ZConnection1;
  sqlHeader := TRESTDWClientSQL.Create(nil);
  sqlHeader.OpenJson(DecodeStrings(Params.ItemsString['pSelect'].AsString,
    csUndefined));

  try
    try
      if not sqlHeader.IsEmpty then
      begin
        sqlHeader.First;
        while not sqlHeader.EOF do
        begin
          lQry.Close;
          lQry.SQL.Clear;
          lQry.SQL.Text :=
            'update or insert into CLIENTE (UUID, NOME, FANTASIA,' +
            ' CNPJCPF, ENDERECO, NUMERO, BAIRRO, CEP, TELEFONE, UF, MUNICIPIO, LAT, LNG)' +
            ' values (:UUID, :NOME, :FANTASIA, :CNPJCPF, :ENDERECO, :NUMERO, :BAIRRO,' +
            '   :CEP, :TELEFONE, :UF, :MUNICIPIO, :LAT, :LNG) matching (UUID);';
          lQry.ParamByName('UUID').AsString :=
            sqlHeader.Fields[0].AsString;
          lQry.ParamByName('CNPJCPF').AsString :=
            sqlHeader.Fields[1].AsString;
          lQry.ParamByName('NOME').AsString :=
            sqlHeader.Fields[2].AsString;
          lQry.ParamByName('FANTASIA').AsString :=
            sqlHeader.Fields[3].AsString;
          lQry.ParamByName('ENDERECO').AsString :=
            sqlHeader.Fields[4].AsString;
          lQry.ParamByName('NUMERO').AsString :=
            sqlHeader.Fields[5].AsString;
          lQry.ParamByName('BAIRRO').AsString :=
            sqlHeader.Fields[6].AsString;
          lQry.ParamByName('CEP').AsString :=
            sqlHeader.Fields[7].AsString;
          lQry.ParamByName('TELEFONE').AsString :=
            sqlHeader.Fields[8].AsString;
          lQry.ParamByName('UF').AsString :=
            sqlHeader.Fields[9].AsString;
          lQry.ParamByName('MUNICIPIO').AsString :=
            sqlHeader.Fields[10].AsString;
          lQry.ParamByName('LAT').AsString :=
            sqlHeader.Fields[11].AsString;
          lQry.ParamByName('LNG').AsString :=
            sqlHeader.Fields[12].AsString;

          lQry.Connection.StartTransaction;
          lQry.ExecSQL;
          lQry.Connection.Commit;
          sqlHeader.Next;
        end;
        Result := 'ok';
      end;
    except
      Result := 'erro';
    end;
  finally
    FreeAndNil(lQry);
    FreeAndNil(sqlHeader);
  end;

end;

procedure TServerMethodDM.ZConnection1BeforeConnect(Sender: TObject);
var
  Driver_BD: string;
  Porta_BD: string;
  Servidor_BD: string;
  DataBase: string;
  Pasta_BD: string;
  Usuario_BD: string;
  Senha_BD: string;
begin
  database := RestDWForm.EdBD.Text;
  Driver_BD := RestDWForm.CbDriver.Text;
  if RestDWForm.CkUsaURL.Checked then
    Servidor_BD := RestDWForm.EdURL.Text
  else
    Servidor_BD := RestDWForm.DatabaseIP;
  case RestDWForm.CbDriver.ItemIndex of
    0:
    begin
      Pasta_BD := IncludeTrailingPathDelimiter(RestDWForm.EdPasta.Text);
      Database := RestDWForm.edBD.Text;
      Database := Pasta_BD + Database;
    end;
    1: Database := RestDWForm.EdBD.Text;
  end;
  Porta_BD := RestDWForm.EdPortaBD.Text;
  Usuario_BD := RestDWForm.EdUserNameBD.Text;
  Senha_BD := RestDWForm.EdPasswordBD.Text;
  TZConnection(Sender).Database := Database;
  TZConnection(Sender).HostName := Servidor_BD;
  TZConnection(Sender).Port := StrToInt(Porta_BD);
  TZConnection(Sender).User := Usuario_BD;
  TZConnection(Sender).Password := Senha_BD;
  TZConnection(Sender).LoginPrompt := False;
end;

function TServerMethodDM.Login(aValue: string): boolean;
var
  lQry: TZQuery;
  //lJson: TJson;
begin
  Result := False;
  // lJson := TJson.Create;
  try
    //  if (Trim( aValue ) <> '') and lJson.IsJsonObject( aValue ) then
    begin
      lQry := TZQuery.Create(nil);
      lQry.Connection := ZConnection1;
      try
        //  lJson.Parse( aValue );

        lQry.SQL.Clear;
        lQry.SQL.add('select codigo from usuario ');
        lQry.SQL.add(' where login = :login      ');
        lQry.SQL.add('   and senha = :senha      ');

        //   lQry.ParamByName('login').AsString := lJson.Get('login').AsString;
        //   lQry.ParamByName('senha').AsString := lJson.Get('senha').AsString;

        lQry.Open();
        Result := not lQry.IsEmpty;
      finally
        lQry.Close;
        FreeAndNil(lQry);
      end;
    end;
  finally
    //  FreeAndNil( lJson );
  end;

end;




end.
