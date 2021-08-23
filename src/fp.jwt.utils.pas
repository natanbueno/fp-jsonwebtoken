unit fp.jwt.utils;

interface

uses
  Classes,
  SysUtils,
  base64,
  DCPrc4,
  DCPsha256;

type

  { TJWTUtils }

  TJWTUtils = class
    class function EncodeBase64Url(const Value: String): String;
    class function DecodeBase64Url(const Value: String): String;

    class function EncryptHashHMAC(const Key, Value: String; const Alg: String = 'SHA256'): String;
    class function DecryptHashHMAC(const Key, Value: String; const Alg: String = 'SHA256'): String;

  end;

implementation


class function TJWTUtils.EncodeBase64Url(const Value: String): String;
var
  LBase64Str: string;
begin
  LBase64Str := EncodeStringBase64(Value);

  LBase64Str := StringReplace(LBase64Str, #13#10, '', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, #13, '', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, #10, '', [rfReplaceAll]);
  LBase64Str := LBase64Str.TrimRight(['=']);

  LBase64Str := StringReplace(LBase64Str, '+', '-', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, '/', '_', [rfReplaceAll]);

  Result := LBase64Str;
end;

class function TJWTUtils.DecodeBase64Url(const Value: String): String;
var
  LBase64Str: string;
begin
  LBase64Str := Value;

  LBase64Str := LBase64Str + StringOfChar('=', (4 - Length(Value) mod 4) mod 4);
  LBase64Str := StringReplace(LBase64Str, '-', '+', [rfReplaceAll]);
  LBase64Str := StringReplace(LBase64Str, '_', '/', [rfReplaceAll]);

  Result := DecodeStringBase64(LBase64Str);
end;

class function TJWTUtils.EncryptHashHMAC(const Key, Value: string; const Alg: String
  ): String;
var
  Cipher: TDCP_rc4;
begin
  Cipher := TDCP_rc4.Create(nil);
  try
    if Alg = 'SHA256' then
    begin
      Cipher.InitStr(key,TDCP_sha256);
      Result := Cipher.EncryptString(Value);
    end
    else
      Result := '';
  finally
    Cipher.Burn;
    Cipher.Free;
  end;
end;

class function TJWTUtils.DecryptHashHMAC(const Key, Value: string; const Alg: String
  ): String;
var
  Cipher: TDCP_rc4;
begin
  Cipher := TDCP_rc4.Create(nil);
  try
    if Alg = 'SHA256' then
    begin
      Cipher.InitStr(key,TDCP_sha256);
      Result := Cipher.DecryptString(Value);
    end
    else
      Result := '';
  finally
    Cipher.Burn;
    Cipher.Free;
  end;

end;

end.

