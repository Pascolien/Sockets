program TxSocketsClient;

uses
  FastShareMem,
  Vcl.Forms,
  U_Abstract in '..\..\..\Specific_Devs\4.0.0\U_Abstract\29114\U_Abstract.pas',
  U_Const in '..\..\..\Specific_Devs\4.0.0\U_Abstract\29114\U_Const.pas',
  U_Version in '..\..\..\Specific_Devs\4.0.0\U_Abstract\29114\U_Version.pas',
  U_Small_Lib in '..\..\..\Others\lib\U_Small_Lib.pas',
  U_Client in 'Pas\U_Client.pas' {Frm_SocketClient},
  U_Abstract_TxSocketClientDll in '..\TxSocketClientDll\Pas\U_Abstract_TxSocketClientDll.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrm_SocketClient, Frm_SocketClient);
  Application.CreateForm(TFrm_SocketClient, Frm_SocketClient);
  Application.Run;
end.
