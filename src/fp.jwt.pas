unit fp.jwt;

interface

uses
  Classes,
  SysUtils,
  fp.jwt.claims,
  fp.jwt.header;

type
  TJWTAlg          = fp.jwt.header.TJWTAlg;
  TClaimPublicType = fp.jwt.claims.TClaimPublicType;
  TClaimPrivate    = fp.jwt.claims.TReservedClaimNames;

  TJWT = class
  private
    FHeader   : TJWTHeader;
    FClaims   : TJWTClaims;
    FVerified : Boolean;
    FSignature: String;

  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property Header   : TJWTHeader read FHeader;
    property Claims   : TJWTClaims read FClaims    write FClaims;
    property Verified : Boolean    read FVerified  write FVerified;
    property Signature: String     read FSignature write FSignature;

  end;

implementation

constructor TJWT.Create;
begin
  FHeader   := TJWTHeader.Create;
  FClaims   := TJWTClaims.Create;
  FVerified := false;
end;

destructor TJWT.Destroy;
begin
  FreeAndNil(FHeader);
  FreeAndNil(FClaims);
  inherited Destroy;
end;

procedure TJWT.Clear;
begin
  if Assigned(FClaims) then;
    FClaims := TJWTClaims.Create;

  FVerified := false;
end;

end.

