program sample;

{$mode objfpc}{$H+}

uses
  Interfaces,
  Forms,
  uFrmMain;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

