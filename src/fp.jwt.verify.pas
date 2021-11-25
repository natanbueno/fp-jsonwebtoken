unit fp.jwt.verify;

interface

uses
  Types,
  Classes,
  SysUtils,
  StrUtils,
  DateUtils,
  fpjson,
  fp.jwt,
  fp.jwt.utils;

type

  { TJWTVerify }

  TJWTVerify = class
  const
    PART_SEPARATOR = '.';

  private
    FParts: TStringDynArray;

    procedure DeserializeHeader (var AJWT: TJWT);
    procedure DeserializePayload(var AJWT: TJWT);

    function IsValidSignature(ASecretKey: String): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    function Verify(const ASecretKey, ACompactToken: String): TJWT;
  end;

implementation

{ TJWTVerify }

constructor TJWTVerify.Create;
begin

end;

destructor TJWTVerify.Destroy;
begin
  inherited Destroy;
end;

procedure TJWTVerify.DeserializeHeader(var AJWT: TJWT);
var
  LJsonHeader: TJSONObject;
  LHeaderTokenDecoded: String;
begin
  LHeaderTokenDecoded := TJWTUtils.DecodeBase64Url(FParts[0]);

  if LHeaderTokenDecoded <> '' then
  begin
    LJsonHeader := TJSONObject(GetJSON(LHeaderTokenDecoded));

    if (LJsonHeader.Strings['alg'] <> 'SHA256') then
      AJWT.Header.alg := TJWTAlg.JWTAlgNone;

    FreeAndNil(LJsonHeader);
  end;
end;

procedure TJWTVerify.DeserializePayload(var AJWT: TJWT);
var
  jPayload       : TJSONObject;
  LPayLoadDecoded: String;
  field_name     : String;
  field_typ      : TJSONtype;
  LAudiences     : TJSONArray;
  I,J: Integer;
begin
  LPayLoadDecoded := TJWTUtils.DecodeBase64Url(FParts[1]);

  if LPayLoadDecoded <> '' then
  begin
    jPayload := TJSONObject( GetJSON(LPayLoadDecoded) );

    for I := 0 to jPayload.Count -1 do
    begin

      field_name := LowerCase(jPayload.Names[I]);

      if      (field_name = 'sub') then AJWT.Claims.Subject    := jPayload.Strings['sub']
      else if (field_name = 'iss') then AJWT.Claims.Issuer     := jPayload.Strings['iss']
      else if (field_name = 'exp') then AJWT.Claims.Expiration := UnixToDateTime(jPayload.Integers['exp'])
      else if (field_name = 'iat') then AJWT.Claims.IssuedAt   := UnixToDateTime(jPayload.Integers['iat'])
      else if (field_name = 'aud') then
      begin
        LAudiences  := jPayload.Arrays['aud'];

        for J := 0 to LAudiences.Count -1 do
          AJWT.Claims.AddAudience(LAudiences.Strings[J]);
      end
      else
      begin
        field_typ  := jPayload.Items[I].JSONType;

        case field_typ of
            jtNumber : AJWT.Claims.SetClaim(field_name, jPayload.FindPath(jPayload.Names[I]).Value);
            jtString : AJWT.Claims.SetClaim(field_name, jPayload.FindPath(jPayload.Names[I]).AsString);
            jtBoolean: AJWT.Claims.SetClaim(field_name, jPayload.FindPath(jPayload.Names[I]).AsBoolean);
        end;
      end;
    end;
    FreeAndNil(jPayload);
  end;
end;

function TJWTVerify.IsValidSignature(ASecretKey: String): Boolean;
var
  LTokenSignatureDecoded: String;
  LTokenSignatureContent: String;
  LContentToken         : String;
begin
  LTokenSignatureDecoded := TJWTUtils.DecodeBase64Url(FParts[2]);
  LTokenSignatureContent := TJWTUtils.DecryptHashHMAC(ASecretKey, LTokenSignatureDecoded, 'SHA256');

  LContentToken :=  FParts[0] + PART_SEPARATOR + FParts[1];

  Result := (LTokenSignatureContent = LContentToken);
end;

function TJWTVerify.Verify(const ASecretKey, ACompactToken: String): TJWT;
var
  LJWT: TJWT;
  existKey,
  existToken,
  existHeaderPayloadSignature: Boolean;
begin
  Result := nil;

  existKey   := ASecretKey <> '';
  existToken := ACompactToken <> '';

  if not existKey   then Raise Exception.Create('Key secret not informed.');
  if not existToken then Raise Exception.Create('Compact Token does not exist.');

  FParts                      := SplitString(ACompactToken, PART_SEPARATOR);
  existHeaderPayloadSignature := Length(FParts) = 3;

  if not existHeaderPayloadSignature then raise Exception.Create('Informed Compact Token is not formatted.');

  LJWT          := TJWT.Create;
  LJWT.Verified := IsValidSignature(ASecretKey);

  DeserializeHeader(LJWT);
  DeserializePayload(LJWT);

  Result := LJWT;
end;

end.

