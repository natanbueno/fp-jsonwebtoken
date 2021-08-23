unit fp.jwt.core;

interface

uses
  Classes,
  SysUtils,
  fp.jwt,
  fp.jwt.sign,
  fp.jwt.verify;

type
  TJWT = fp.jwt.TJWT;

  { TJWTCore }

  TJWTCore = class
    class function Verify            (const ASecretKey: String; const ACompactToken: String): TJWT;
    class function SHA256CompactToken(const ASecretKey: String; var   AToken       : TJWT  ): String;
  end;


implementation

class function TJWTCore.Verify(const ASecretKey: String;const ACompactToken: String): TJWT;
var
  LJWTVerify: TJWTVerify;
  LJWT: TJWT;
begin
  LJWTVerify := TJWTVerify.Create;
  LJWT       := LJWTVerify.Verify(ASecretKey, ACompactToken);

  Result := LJWT;
  FreeAndNil(LJWTVerify);
end;

{ TJWTCore }
class function TJWTCore.SHA256CompactToken(const ASecretKey: String; var AToken: TJWT): String;
var
  LJWTSign: TJWTSign;
begin
  LJWTSign := TJWTSign.Create;
  try
    LJWTSign.Sign(ASecretKey, AToken);
    Result := LJWTSign.CompactToken;
  finally
    FreeAndNil(LJWTSign);
  end;
end;

end.

