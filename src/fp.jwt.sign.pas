unit fp.jwt.sign;

interface

uses
  Classes,
  SysUtils,
  DateUtils,
  fpjson,
  fp.jwt,
  fp.jwt.utils;

type

  TJWTSign = class
  private
    FHeader   : String;
    FPayLoad  : String;
    FSignature: String;
    FJWT      : TJWT;

    function SerealizeHeaderToJsonString : String;
    function SerealizePayloadToJsonString: String;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Sign(const ASecretKey: String; var AJWT: TJWT);
    function CompactToken: String;
    property Signature: String read FSignature;
  end;

implementation

{ TJWTSign }

constructor TJWTSign.Create;
begin

end;

destructor TJWTSign.Destroy;
begin
  inherited Destroy;
end;

procedure TJWTSign.Sign(const ASecretKey: String; var AJWT: TJWT);
var
  LContent: String;
  existSecretKey, existToken: Boolean;
begin
  existSecretKey := ASecretKey <> '';
  existToken := Assigned(AJWT);

  if not existSecretKey then Raise Exception.Create('Key secret not informed.');
  if not existToken     then Raise Exception.Create('TJWT not created.');

  FJWT       := AJWT;
  FHeader    := TJWTUtils.EncodeBase64Url(SerealizeHeaderToJsonString );
  FPayLoad   := TJWTUtils.EncodeBase64Url(SerealizePayloadToJsonString);

  LContent   := FHeader + '.'+ FPayLoad;
  FSignature := TJWTUtils.EncryptHashHMAC(ASecretKey, LContent, 'SHA256');
  FSignature := TJWTUtils.EncodeBase64Url(FSignature);

  AJWT.Signature := FSignature;
  AJWT.Verified  := true;
end;

function TJWTSign.SerealizeHeaderToJsonString: String;
var
  LHeader: TJSONObject;
  LAlg   : String;
begin
  LHeader := TJSONObject.Create;
  try
    LHeader.Add('typ', FJWT.Header.typ);

    if FJWT.Header.alg = TJWTAlg.HS256 then
      LAlg := 'HS256';

    LHeader.Add('alg', LAlg);

    Result := LHeader.AsJSON;
  finally
    FreeAndNil(LHeader);
  end;
end;

function TJWTSign.SerealizePayloadToJsonString: String;
var
  LPayLoad   : TJSONObject;
  LClaimName : String;
  LClaimValue: Variant;
  LAudiences : TJSONArray;
  I: Integer;
begin
  LPayLoad := TJSONObject.Create;
  try

    with FJWT.Claims do
    begin
      if HasSubject    then LPayLoad.Add(TClaimPrivate.Subject   , Subject   );
      if HasIssuer     then LPayLoad.Add(TClaimPrivate.ISSUER    , Issuer    );
      if HasExpiration then LPayLoad.Add(TClaimPrivate.EXPIRATION, DateTimeToUnix(Expiration));
      if HasIssuedAt   then LPayLoad.Add(TClaimPrivate.ISSUED_AT , DateTimeToUnix(IssuedAt  ));

      if HasAudience then
      begin
        LAudiences := TJSONArray.Create;

        for I := 0 to Length(Audience) -1 do
          LAudiences.Add(Audience[I]);

        LPayLoad.Add(TClaimPrivate.AUDIENCE , LAudiences);
      end;

      if HashPublic then
      begin
        for i := 0 to AsPublic.Count - 1 do
        begin
          LClaimName  := AsPublic.Items[I]._name;
          LClaimValue := AsPublic.Items[I]._value;

          case AsPublic.Items[i]._type of
            TClaimPublicType.claimPublicInteger : LPayLoad.Add(LClaimName, Integer(LClaimValue ));
            TClaimPublicType.claimPublicString  : LPayLoad.Add(LClaimName, String (LClaimValue ));
            TClaimPublicType.claimPublicBoolean : LPayLoad.Add(LClaimName, Boolean(LClaimValue ));
            TClaimPublicType.claimPublicDouble  : LPayLoad.Add(LClaimName, Double (LClaimValue ));
            TClaimPublicType.claimPublicDateTime: LPayLoad.Add(LClaimName, DateTimeToUnix(LClaimValue));
          end;
        end;
      end;
    end;

    Result := LPayLoad.AsJSON;
  finally
    FreeAndNil(LPayLoad);
  end;

end;

function TJWTSign.CompactToken: String;
begin
  Result := FHeader + '.' + FPayLoad + '.' + FSignature;
end;

end.

