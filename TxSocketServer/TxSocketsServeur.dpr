program TxSocketsServeur;

uses
  Vcl.Forms,
  TxSockets in 'Pas\TxSockets.pas' {Frm_SocketServer},
  U_Small_Lib in '..\..\..\Others\lib\U_Small_Lib.pas',
  U_Abstract_TxSocketClientDll in '..\TxSocketClientDll\Pas\U_Abstract_TxSocketClientDll.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrm_SocketServer, Frm_SocketServer);
  Application.Run;
end.
