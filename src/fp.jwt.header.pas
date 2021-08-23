unit fp.jwt.header;

interface

uses
  Classes, SysUtils;
  
 type
  TJWTAlg = (HS256, JWTAlgNone);

  TJWTHeader = class
  private
    Ftyp: string;
    Falg: TJWTAlg;

  public
    constructor Create();
    destructor Destroy(); override;

    property typ: string  read Ftyp write Ftyp;
    property alg: TJWTAlg read FAlg write Falg;
  end;

implementation

constructor TJWTHeader.Create();
begin
  Ftyp := 'jwt';
  FAlg := HS256;
end;
destructor TJWTHeader.Destroy();
begin

end;
end.

