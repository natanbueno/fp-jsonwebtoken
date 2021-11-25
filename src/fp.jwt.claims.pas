unit fp.jwt.claims;

{$MODE DELPHI}{$H+}

interface

uses
  Classes,
  SysUtils,
  Types,
  Generics.Collections;

type
  TReservedClaimNames = class
  public const
    SUBJECT    = 'sub'; //Entidade à quem o token pertence, normalmente o ID do usuário;
    ISSUER     = 'iss'; //Emissor do token
    EXPIRATION = 'exp'; //Tempo de quando o token irá expirar;
    ISSUED_AT  = 'iat'; //Data de quando o token foi criado;
    AUDIENCE   = 'aud'; //Destinatário do token, representa a aplicação que irá usá-lo.
  end;

  TClaimPublicType = (claimPublicString,
                      claimPublicInteger,
                      claimPublicDouble,
                      claimPublicBoolean,
                      claimPublicDateTime,
                      claimPublicNumber);

  TClaimPublic = record
    _name : string;
    _value: variant;
    _type : TClaimPublicType;
  end;

  EInvalidClaimPublic = class(Exception)
  public
    constructor Create(const AClaimName: String);
  end;

  TListClaimsPublic = TList<TClaimPublic>;

  { TJWTClaims }

  TJWTClaims = class
  private
    FAudience     : TStringDynArray;
    FExpiration   : TDateTime;
    FHasIssuedAt  : Boolean;
    FIssuedAt     : TDateTime;
    FIssuer       : string;
    FSubject      : string;
    FClaimsPublic : TListClaimsPublic;
    FHasExpiration: Boolean;

    procedure AddClaim( const AName : String;
                        const AValue: Variant;
                        const AType : TClaimPublicType
                       );
    procedure SetExpiration(const AValue: TDateTime);
    procedure SetIssuedAt  (const AValue: TDateTime);

  public
    constructor Create;
    destructor Destroy(); override;

    procedure SetClaim   (const AName: String; const AValue: String   ); overload;
    procedure SetClaim   (const AName: String; const AValue: Integer  ); overload;
    procedure SetClaim   (const AName: String; const AValue: Double   ); overload;
    procedure SetClaim   (const AName: String; const AValue: Boolean  ); overload;
    procedure SetClaim   (const AName: String; const AValue: TDateTime); overload;
    procedure SetClaim   (const AName: String; const AValue: Variant  ); overload;
    procedure AddAudience(const aValue: String);

    property Subject      : string            read FSubject    write FSubject;
    property Issuer       : string            read FIssuer     write FIssuer;
    property Expiration   : TDateTime         read FExpiration write SetExpiration;
    property IssuedAt     : TDateTime         read FIssuedAt   write SetIssuedAt;
    property Audience     : TStringDynArray   read FAudience;
    property AsPublic     : TListClaimsPublic read FClaimsPublic;

    property HasExpiration: Boolean   read FHasExpiration;
    property HasIssuedAt  : Boolean   read FHasIssuedAt;

    function HasSubject : Boolean;
    function HasIssuer  : Boolean;
    function HasAudience: Boolean;
    function HashPublic : Boolean;
  end;


implementation

{ EInvalidClaimPublic }

constructor EInvalidClaimPublic.Create(const AClaimName: String);
begin
  Self.Message := AClaimName + ' is not a public claim.';
end;

constructor TJWTClaims.Create;
begin
  FClaimsPublic  := TListClaimsPublic.Create;
  FHasExpiration := False;
  FHasIssuedAt   := False;
end;

destructor TJWTClaims.Destroy();
begin
  FClaimsPublic.Free;
  inherited Destroy();
end;

procedure TJWTClaims.AddClaim(const AName: String; const AValue: Variant;const AType: TClaimPublicType);
var
  Claim: TClaimPublic;
  ConvertedClaimName: String;
begin
  ConvertedClaimName := LowerCase(AName);

  if (ConvertedClaimName = TReservedClaimNames.SUBJECT) then
    Raise EInvalidClaimPublic.Create(TReservedClaimNames.SUBJECT);

  if (ConvertedClaimName = TReservedClaimNames.ISSUER) then
    Raise EInvalidClaimPublic.Create(TReservedClaimNames.ISSUER);

  if (ConvertedClaimName = TReservedClaimNames.EXPIRATION) then
    Raise EInvalidClaimPublic.Create(TReservedClaimNames.EXPIRATION);

  if (ConvertedClaimName = TReservedClaimNames.ISSUED_AT) then
    Raise EInvalidClaimPublic.Create(TReservedClaimNames.ISSUED_AT);

  if (ConvertedClaimName = TReservedClaimNames.AUDIENCE) then
    Raise EInvalidClaimPublic.Create(TReservedClaimNames.AUDIENCE);

  Claim._name  := AName;
  Claim._value := AValue;
  Claim._type  := AType;

  FClaimsPublic.Add(Claim);
end;

procedure TJWTClaims.SetExpiration(const AValue: TDateTime);
begin
  FHasExpiration := true;
  FExpiration    := AValue;
end;

procedure TJWTClaims.SetIssuedAt(const AValue: TDateTime);
begin
  FHasIssuedAt := true;
  FIssuedAt    := AValue;
end;

procedure TJWTClaims.SetClaim(const AName: String; const AValue: String);
begin
  AddClaim(AName, AValue, claimPublicString);
end;

procedure TJWTClaims.SetClaim(const AName: String; const AValue: Integer);
begin
  AddClaim(AName, AValue, claimPublicInteger);
end;

procedure TJWTClaims.SetClaim(const AName: String; const AValue: Double);
begin
  AddClaim(AName, AValue, claimPublicDouble);
end;

procedure TJWTClaims.SetClaim(const AName: String; const AValue: Boolean);
begin
  AddClaim(AName, AValue, claimPublicBoolean);
end;

procedure TJWTClaims.SetClaim(const AName: String; const AValue: TDateTime);
begin
  AddClaim(AName, AValue, claimPublicDateTime);
end;

procedure TJWTClaims.SetClaim(const AName: String; const AValue: Variant);
begin
  AddClaim(AName, AValue, claimPublicNumber);
end;

procedure TJWTClaims.AddAudience(const aValue: String);
var
  Increment: Integer;
  Position : Integer;
begin
  if aValue <> '' then
  begin
    Increment := Length(FAudience) + 1;
    SetLength(FAudience, Increment);

    Position            := High(FAudience);
    FAudience[Position] := aValue;
  end;
end;

function TJWTClaims.HasSubject: Boolean;
begin
  Result := FSubject <> '';
end;

function TJWTClaims.HasIssuer: Boolean;
begin
  Result := FIssuer <> '';
end;

function TJWTClaims.HasAudience: Boolean;
begin
  Result := Length(FAudience) > 0;
end;

function TJWTClaims.HashPublic: Boolean;
begin
  Result := FClaimsPublic.Count > 0;
end;


end.

