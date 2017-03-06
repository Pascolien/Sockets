unit TxSocketClient;

interface

uses
  SysUtils, Classes,
  System.Win.ScktComp;

procedure InitializeSocket();
procedure FinalizeSocket();

function SocketConnect(aIP: string; aPort: integer; aTimeOut: integer; var smessage: string): boolean; stdcall; export;
function SocketDisconnect : boolean; stdcall; export;
function SocketIsConnected : boolean; stdcall; export;
function SocketSendText(aCommand: string): boolean; stdcall; export;
function SocketSendFile(aStream: TFileStream; aTimeOut: integer): boolean;stdcall; export;
function SocketRequest(aCommand: string; aTimeOut: integer): string; stdcall; export;

var
  Socket: TClientSocket;

implementation

procedure InitializeSocket();
begin
  Socket := TClientSocket.Create(nil);
end;

procedure FinalizeSocket();
begin
  if Socket.Active then
    Socket.Close;

  Socket.Free;
end;

function SocketConnect(aIP: string; aPort: integer; aTimeOut: integer; var smessage: string): boolean;
var
  i: integer;
begin
  i := 0;
  Socket.ClientType := ctBlocking;
  Socket.Address := aIP;
  Socket.Port := aPort;
  Socket.Active := true;

  while (Socket.Active = False) and (i < aTimeOut) do
  begin
    Socket.Active := true;
    sleep(1);
    inc(i);
  end;

  Sleep(aTimeOut);

  sMessage := Socket.Socket.ReceiveText();
  result := Socket.Socket.Connected;
end;

function SocketDisconnect : boolean;
begin
  Socket.Active := False;
  result := Socket.socket.Connected;
end;

function SocketIsConnected : boolean;
begin
  result := socket.Socket.Connected;
end;

function SocketSendText(aCommand: string): boolean;
begin
  result := true;
  if Socket.Socket.Connected then
    Socket.Socket.SendText(aCommand);
end;

function SocketSendFile(aStream: TFileStream; aTimeOut: integer): boolean;
var
  iSize: Int64;
begin
  iSize := aStream.Size;
  Socket.Socket.SendBuf(iSize, SizeOf(iSize));
  Socket.Socket.SendStream(aStream);
  sleep(aTimeOut);
end;

function SocketRequest(aCommand: string; aTimeOut: integer): string;
begin
  result := '';
  if Socket.Socket.Connected then
  begin
    Socket.Socket.SendText(aCommand);
    Sleep(aTimeOut);
    result := Socket.Socket.ReceiveText;
    if result = '' then
    begin
      Sleep(aTimeOut);
      result := Socket.Socket.ReceiveText;
    end;
  end;
end;

Initialization
  InitializeSocket;

Finalization
  FinalizeSocket;

end.
