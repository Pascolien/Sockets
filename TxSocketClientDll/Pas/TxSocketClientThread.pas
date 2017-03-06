unit TxSocketClientThread;

interface
uses
  Classes, System.Win.ScktComp, System.SysUtils, Windows;

type
 TClientSocketThread = class(TThread)
  private
    FClientSocket: TClientSocket;
    FTimeOut : Integer;
    FData: TMemoryStream;
    FFile: TFileStream;
    FLastException: Exception;
    FCommand: string;
    FRequiredType : string;
    FExtraData : string;
    FThreadDone : boolean;
    procedure SetCommand(const aValue: string);
    procedure SetTimeOut(const aValue: integer);
    Procedure SetRequiredType(const AValue: string);
    procedure SetExtraData(const aValue: string);

  protected
    procedure Execute; override;
    Procedure Terminate; overload;
    procedure HandleThreadException;
    procedure ThreadDone(sender: TObject);

  public
    constructor Create(aIP: String; aPort: integer; aClientType: TClientType= ctNonBlocking);overload;
    destructor Destroy; override;
    property Command: string read FCommand write SetCommand;
    property TimeOut: Integer read FTimeOut write SetTimeOut;
    property RequiredType: string read FRequiredType write SetRequiredType;
    property ExtraData: string read FExtraData write SetExtraData;
  end;

  Function ClientRequestThread( aIP: String;
                                aPort: integer;
                                aCommand: string;
                                aRequiredType: string='str';
                                aExtraData: string='';
                                aClientType: TClientType=ctBlocking;
                                aTimeOut: integer=2000) : TMemoryStream; stdcall;Export;

  function ClientSendFile ( aIP: String;
                            aPort: integer;
                            aCommand: string;
                            aFileName: string='';
                            aClientType: TClientType=ctBlocking;
                            aTimeOut: integer=2000) : String; stdcall;Export;


  procedure WriteStreamStr(aStream : TMemoryStream; Str : string); stdcall;export;
  procedure WriteStreamInt(aStream : TMemoryStream; Num : integer); stdcall;export;

  function MemoryStreamToString(aStream : TMemoryStream; AEncoding: TEncoding) : string; stdcall; export;

implementation
uses
  U_Small_Lib;

var
  FCSThread : TClientSocketThread;


Function ClientRequestThread(aIP: String; aPort: integer; aCommand: string; aRequiredType: string='str'; aExtraData: string='' ; aClientType: TClientType=ctBlocking; aTimeOut: integer=2000) : TMemoryStream;
begin
  FCSThread := nil;
  FCSThread := TClientSocketThread.Create(aIP, aPort, aClientType);
  FCSThread.SetCommand(aCommand);
  FCSThread.SetTimeOut(aTimeOut);
  FCSThread.SetRequiredType(aRequiredType);
  FCSThread.SetExtraData(aExtraData);
  try
    FCSThread.Execute;
    result := FCSThread.FData;
  except
     WriteStreamStr(result, FCSThread.FLastException.Message);
  end;
end;

function ClientSendFile(aIP: String;
                        aPort: integer;
                        aCommand: string;
                        aFileName: string='';
                        aClientType: TClientType=ctBlocking;
                        aTimeOut: integer=2000) : String;
var
  ClientSocket: TClientSocket;
  sCommandText: string;
  iFileSize: Integer;
  iBytesRead: Integer;
  FileStream : TFileStream;
  sExtraData: string;
  Buffer: pointer;
  iBytesBuffered: Integer;
  iChunckSize: Integer;
  ibuffers: Integer;
  SL_Lines: TStringList;

  const
    iMaxChunkSize = 2048;

begin
  SL_Lines := TStringList.Create;

  ClientSocket := TClientSocket.Create(nil);
  ClientSocket.Address := aIP;
  ClientSocket.Port := aPort;
  ClientSocket.Socket.ClientType := aClientType;

  ClientSocket.Active := true;
  try
    FileStream := TFileStream.Create(aFilename, fmOpenRead);
    iFileSize := FileStream.Size;
    iBytesRead := 0;
    ibuffers := 0;

    try
      repeat
        inc (ibuffers);
        if iFileSize - iBytesRead < iMaxChunkSize then
          iChunckSize := iFileSize - iBytesRead
        else
          iChunckSize := iMaxChunkSize;

        GetMem(Buffer, iChunckSize);
        FileStream.ReadBuffer(Buffer^, iChunckSize);
        iBytesBuffered := ClientSocket.Socket.SendBuf(Buffer^, iChunckSize);
        Inc(iBytesRead, iBytesBuffered);
        SL_Lines.add(format('%d bytes sent in buffer %d',[ iBytesBuffered, ibuffers]));
        Sleep(1);
      until
        iBytesRead = iFileSize;

      result := SLToStr(SL_Lines,';');
    Except on e: Exception do
      raise Exception.Create('Message d''erreur');

    end;

  finally
    Sleep(2000);
    FreeMem(Buffer, 0);
    FileStream.Free;
    ClientSocket.Active := false;
    ClientSocket.Free;
    SL_Lines.Free;
  end;
end;

procedure TClientSocketThread.SetCommand(const aValue: string);
begin
  FCommand := aValue;
end;

procedure TClientSocketThread.SetExtraData(const aValue: string);
begin
  FExtraData := AValue;
end;

procedure TClientSocketThread.SetRequiredType(const AValue: string);
begin
  FRequiredType := AValue;
end;

procedure TClientSocketThread.SetTimeOut(const aValue: integer);
begin
  FTimeOut := aValue;
end;

procedure TClientSocketThread.Terminate;
begin
  inherited;
  FClientSocket.Socket.Close;
  FClientSocket.Active := False;
 // FFile.Free;
  FThreadDone := true;
end;

procedure TClientSocketThread.ThreadDone(Sender: TObject);
begin
   FThreadDone := true;
end;

constructor TClientSocketThread.Create(aIP: String; aPort: integer; aClientType: TClientType) ;
begin
  inherited Create(True); // Intially suspended
  FreeOnTerminate := True;
  FClientSocket := TClientSocket.Create(nil);
  FClientSocket.Address := aIP;
  FClientSocket.Port := aPort;
  FClientSocket.ClientType := aClientType; // Blocking, so it is in a thread
  FData := TMemoryStream.Create;
  FFile := Nil;
end;

destructor TClientSocketThread.Destroy;
begin
  FClientSocket.Free;
  FFile.Free;
  FData.Free;
  inherited;
end;

procedure TClientSocketThread.Execute;
var
  s: string;
  iLength: Integer;
  pMem: Pointer;
  SizeRead: Int64;
  sCommandText: string;
  iBufferSize: integer;
  SizeWrite: Int64;
begin
  SizeWrite := 0;
  try
    FClientSocket.Active := True;

    sCommandText := Format('%s ; %s ; %s' , [Command, RequiredType, ExtraData]);


    FClientSocket.Socket.SendText(sCommandText);

    Sleep(FCSThread.TimeOut);

    if FClientSocket.Socket.ReceiveLength > 0 then
    begin
      iLength := FClientSocket.Socket.ReceiveLength;
      pMem := AllocMem( iLength );
      while iLength > 0 do
      begin
        Sleep(10);
        FClientSocket.Socket.ReceiveBuf(pMem^, iLength);
        FData.Write(pMem^, iLength);
        iLength := FClientSocket.Socket.ReceiveLength;
        if iLength > 0 then
          ReAllocMem(pMem, iLength)
      end;
      FData.Position := 0;
      ReAllocMem(pMem, FData.Size);
      FData.Read(pMem^, FData.Size);
      SizeRead := FData.Size;
      FCSThread.Terminate;
    end
    else
    begin
      pMem := nil;
      SizeRead := 0;
      FCSThread.Terminate;
    end;
  except on e: exception do
    begin
      s := e.Message;
      FCSThread.Terminate;
    end;
  end;
end;

procedure TClientSocketThread.HandleThreadException;
begin
  WriteStreamStr(FData, FLastException.Message);
end;

procedure WriteStreamInt(aStream : TMemoryStream; Num : integer);
 {writes an integer to the stream}
begin
 aStream.WriteBuffer(Num, SizeOf(integer));
end;

procedure WriteStreamStr(aStream : TMemoryStream; Str : string);
 var
  i:integer;
  c:  char;
begin
  if length(Str)>0 then
    for i:=1 to length(Str) do
    begin
      c := Str[i];
      aStream.Write(c,1);
    end;
  c := #0;
  aStream.Write(c,1);
end;

function MemoryStreamToString(aStream : TMemoryStream; AEncoding: TEncoding) : string;
var
  StringBytes: TBytes;
begin
  aStream.Position := 0;
  SetLength(StringBytes, aStream.Size);
  aStream.ReadBuffer(StringBytes, aStream.Size);
  Result := AEncoding.GetString(StringBytes);
end;

end.
