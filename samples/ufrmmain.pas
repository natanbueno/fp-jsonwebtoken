unit uFrmMain;

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  Buttons,
  Clipbrd,
  fp.jwt.core;

type

  { TFrmMain }

  TFrmMain = class(TForm)

    edt_key                : TEdit;
    edt_signature          : TEdit;
    edt_token              : TEdit;
    lb_secretkey           : TLabel;
    lb_signature           : TLabel;
    lb_desc_compacToken    : TLabel;
    lb_title               : TLabel;
    lb_menu                : TLabel;
    input_compacttoken     : TPanel;
    input_secret           : TPanel;
    input_secret2          : TPanel;
    lyt01                  : TPanel;
    lyt02                  : TPanel;
    containerMenu          : TPanel;
    container              : TPanel;
    containerSpacing       : TPanel;
    lyt_buttonBuild        : TPanel;
    lyt_buttonCopySignature: TPanel;
    lyt_buttonCopyToken    : TPanel;
    lyt_buttonVerifyToken  : TPanel;
    lyt_buttonValidate     : TPanel;
    SpeedButton1           : TSpeedButton;
    SpeedButton2           : TSpeedButton;
    SpeedButton3           : TSpeedButton;
    SpeedButton4           : TSpeedButton;
    SpeedButton5           : TSpeedButton;
    Memo1                  : TMemo;

    procedure FormCreate       (Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
  private
    FISSUER: String;
    FJWT   : TJWT;

  public
    procedure BuildToken;
    procedure VerifyToken;
    procedure ValidateToken;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.lfm}
procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FISSUER := 'fpjsonwebtoken';
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FJWT) then FreeAndNil(FJWT);
end;

procedure TFrmMain.SpeedButton1Click(Sender: TObject);
begin
  BuildToken;
end;

procedure TFrmMain.SpeedButton2Click(Sender: TObject);
begin
  Clipboard.AsText := edt_signature.Text;
  ShowMessage('Signature copied!');
end;

procedure TFrmMain.SpeedButton3Click(Sender: TObject);
begin
  Clipboard.AsText := edt_token.Text;
  ShowMessage('Compact Token copied!');
end;

procedure TFrmMain.SpeedButton4Click(Sender: TObject);
begin
  VerifyToken;;
end;

procedure TFrmMain.SpeedButton5Click(Sender: TObject);
begin
  ValidateToken;
end;

procedure TFrmMain.BuildToken;
begin
  memo1.Lines.Clear;

  if Assigned(FJWT) then FreeAndNil(FJWT);

  FJWT := TJWT.Create;

  //Payload
  FJWT.Claims.Issuer     := FISSUER;
  FJWT.Claims.Expiration := Now - 1;
  // Add custom
  FJWT.Claims.SetClaim('userId', 1);

  try
    edt_token.Text     := TJWTCore.SHA256CompactToken(edt_key.Text, FJWT);
    edt_signature.Text := FJWT.Signature;
  except
    On E: Exception do
    begin
      memo1.Lines.Add(E.Message);
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TFrmMain.VerifyToken;
begin
  if Assigned(FJWT) then FreeAndNil(FJWT);
  memo1.Lines.Clear;

  try
    FJWT := TJWTCore.Verify(edt_key.Text, edt_token.Text);

    if FJWT.Verified then
      Memo1.Lines.Add('Is valid token.')
    else
      Memo1.Lines.Add('Not a valid token.')

  except
    ON E: Exception do
    begin
      Memo1.Lines.Add(E.Message);
      ShowMessage(E.Message);
    end;
  end;

end;

procedure TFrmMain.ValidateToken;
begin
  //Simple example of how we can validate the token.
  Memo1.Lines.Clear;

  if not Assigned(FJWT) then
  begin
    Memo1.Lines.Add('Class JWT not Assigned!');
    exit;
  end;

  if not FJWT.Verified then
  begin
    Memo1.Lines.Add('Token not Verified!');
    exit;
  end;

  if (FJWT.Claims.HasExpiration) and (FJWT.Claims.Expiration < Now) then
    Memo1.Lines.Add('Your token is expired.');

  if (FJWT.Claims.HasIssuer) and (FJWT.Claims.Issuer <>  'outroEmissor') then
    Memo1.Lines.Add('incorrect token issuer.');
end;

end.

