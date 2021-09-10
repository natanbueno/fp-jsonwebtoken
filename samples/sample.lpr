program sample;

{$mode objfpc}{$H+}

uses
  heaptrc,
  Interfaces,
  Forms,
  uFrmMain;

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  SetHeapTraceOutput('LogLeakMemory.txt');
  Application.Run;
end.

