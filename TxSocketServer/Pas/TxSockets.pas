unit TxSockets;

interface

uses
  FastShareMem,
  Winapi.Windows, Winapi.Messages,ScktComp, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, ShellAPI, Math, DateUtils,
  IniFiles, Vcl.ExtCtrls, Vcl.ImgList, Vcl.Imaging.pngimage;

type
  TClient = class
    private
      sHostName: string;
      sIP_Adress : String;
      iPort : Integer;

    property HostName: string read sHostName;
    property IP_Adress: string read sIP_Adress;
    property Port: integer read iPort;
  end;

type
  TFileReceive=class(TObject)
  private
    sFileName : string;
    iFullSize : Int64;
    pMem: Pointer;
    PMemSize : Int64;
    FReceivedSize: int64;
    iBufferCount: integer;
    iPos : Int64;
    FFileStream : TMemoryStream;
    bWriting : boolean;

  public
    constructor Create;
    Destructor Destroy;

    procedure SetFileName(AValue: string);
    procedure SetSize(aSize: Int64);
    procedure SetBufferSize(aSize: int64);
    Procedure incBufferCount;
    procedure SetReceivedSize(AValue: Int64);
    procedure SetWriting(aValue: boolean);
    procedure WriteBuffer;
    procedure SaveToFile;

    property FileName: string read sFileName write SetFileName;
    property Buffer: Pointer read pMem ;
    property ReceivedSize: Int64 read FReceivedSize write SetReceivedSize;
    property BufferSize: int64 read PMemSize write SetBufferSize;
    property buffercount: integer read iBufferCount;
    property fullSize: int64 read iFullSize write SetSize;
    property writing: boolean read bWriting write setWriting;
  end;

type
  TFrm_SocketServer = class(TForm)
    Equipment_A: TServerSocket;
    ImageList1: TImageList;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Bt_StartStop_Server: TButton;
    Panel5: TPanel;
    Panel1: TPanel;
    Img_Server_Connected: TImage;
    Label1: TLabel;
    Panel2: TPanel;
    Label4: TLabel;
    Img_Client_Connected: TImage;
    Panel3: TPanel;
    Label5: TLabel;
    Img_Server_Receive_Data: TImage;
    Panel4: TPanel;
    Label6: TLabel;
    Img_Server_Send_Data: TImage;
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    PB_Uploading: TProgressBar;
    GroupBox2: TGroupBox;
    ComboBox1: TComboBox;
    Panel15: TPanel;
    Label11: TLabel;
    E_Server_File: TEdit;
    BT_Select_File: TButton;
    Panel9: TPanel;
    Panel10: TPanel;
    Panel11: TPanel;
    Label9: TLabel;
    E_Server_Name: TEdit;
    Panel16: TPanel;
    Label12: TLabel;
    CB_Clients_Connected: TComboBox;
    Panel17: TPanel;
    Label3: TLabel;
    E_File_Size: TEdit;
    Label2: TLabel;
    E_Received: TEdit;
    Label13: TLabel;
    E_BufferCount: TEdit;
    Cb_Server_State: TComboBox;
    DTP_Valid_Date: TDateTimePicker;
    Panel12: TPanel;
    Panel13: TPanel;
    CB_Boolean: TCheckBox;
    Panel14: TPanel;
    Label10: TLabel;
    E_Text_Value: TEdit;
    Panel7: TPanel;
    Label8: TLabel;
    E_Number_Value: TEdit;
    Ko: TLabel;
    Label7: TLabel;
    Label14: TLabel;

    procedure Initialize;

    procedure Bt_StartStop_ServerClick(Sender: TObject);

    Procedure Start_Server(AServer: TServerSocket);
    procedure Equipment_AClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Equipment_AClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Equipment_AClientRead(Sender: TObject; Socket: TCustomWinSocket);

    procedure Initialize_Commands;
    function Get_Name : string;
    Function Get_Commands : string;
    function Get_Revision_Date : string;
    function Get_Status: string;
    function Get_State: string;
    function Get_Files_List : String;
    function Get_File(AFileName: string): TFileStream;
    function Get_Value(ALimits: String): string;
    function Get_Text (ALimits: String) :  string;
    function Get_Boolean (Alimits:string): String;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BT_Select_FileClick(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
  
  private
    procedure Update_Tracer(aText: string);
    procedure Set_Led_Server_Started(aIndex: integer);
    procedure Set_Led_Client_Active(aIndex: Integer);
    procedure Set_Led_Receive_Data(aIndex: integer);
    procedure Set_Led_Send_Data(aIndex: integer);
    procedure Update_Progress_Bar;
    procedure Reset_UpLoading;
  public
    { D�clarations publiques }
  end;
var
  Frm_SocketServer: TFrm_SocketServer;
  IniFile : TIniFile;

  ReceiveFile: TFileReceive;

implementation

{$R *.dfm}

uses
  U_Small_Lib,
  U_Abstract_TxSocketClientDll;


procedure TFrm_SocketServer.Bt_StartStop_ServerClick(Sender: TObject);
begin
  Start_Server(Equipment_A);
end;

function TFrm_SocketServer.Get_File(AFileName: string): TFileStream;
var
  sFilePathName: string;
begin
  result := nil;
  sFilePathName := ExtractFilePath(Application.ExeName) + 'Server Data\Files\' + AFileName;
  if FileExists(sFilePathName) then
    result := TFileStream.Create(sFilePathName, fmOpenRead);
end;

function TFrm_SocketServer.Get_Files_List: String;
var
  SR: TSearchRec;
  SL : TStringList;
begin
  result := 'No File Found.';
  if FindFirst(ExtractFilePath(Application.ExeName)+ 'Server Data\Files\*.*', faAnyFile, SR) = 0 then
  try
    SL := TStringList.Create;
    repeat
      if (SR.Attr <> faDirectory) then
      begin
        SL.Add(SR.Name);
      end;
    until FindNext(SR) <> 0;
    FindClose(SR);
    result := SLToStr(SL, ';');
  finally
    FreeAndNil(SL);
  end;
end;

function TFrm_SocketServer.Get_Name: string;
begin
  result := Equipment_A.Name;
end;

function TFrm_SocketServer.Get_Revision_Date: string;
begin
  result := DateToStr(DTP_Valid_Date.Date);
end;

function TFrm_SocketServer.Get_State: string;
begin
  result := Cb_Server_State.Text;
end;

function TFrm_SocketServer.Get_Status: string;
begin
  result := Cb_Server_State.Text;
end;

function TFrm_SocketServer.Get_Value(ALimits: String): string;
var
  bLow: Boolean;
  fLow: Extended;
  bHigh: Boolean;
  fHigh: Extended;
  f: Extended;
  i: integer;
  i2: Extended;
begin
  if TryStrToFloat(E_Number_Value.Text, f) then
  begin
    result := FloatToStr(f);
    Exit;
  end ;

  Result := '56';

  bLow := TryStrToFloat(GetToken(aLimits,1,'|'), fLow);
  bHigh := TryStrToFloat(GetToken(aLimits,2,'|'), fHigh);
  if (bLow) and (bHigh) then
  begin
    fLow := round(fLow*1000*0.999);
    fHigh := round(fHigh*1000*1.001);

    Randomize;

    i := RandomRange(Round(fLow), Round(fHigh));

    result := FloatToStr(i/1000);
  end;
end;

function TFrm_SocketServer.Get_Text(alimits:string) : string;

begin
 if E_Text_Value.Text = ''    then
  begin
    result := 'default text';
    Exit;
  end ;
   Result := E_Text_Value.Text;


end;

function TFrm_SocketServer.Get_Boolean(alimits:string);
begin
    if BoolToStr(CB_Boolean.Checked) = 'true' then
    begin
      result := 'checked';
      Exit;
    end;
    Result := 'False';
end;

function TFrm_SocketServer.Get_Commands: string;
var
  slCommands : TStringList;
begin
   slCommands := TStringList.Create;
   result := '';
  try
    try
      IniFile.ReadSection('Parameters', slCommands);
      result := SLToStr(slCommands, ';');
    except on e:Exception do
      result := e.Message;
    end;
  finally
    FreeAndNil(slCommands);
  end;
end;

procedure TFrm_SocketServer.Initialize;
begin
  Load_TxSocketClientDll(ExtractFilePath(Application.ExeName)+ '..\TxSocketClientDll\TxSocketClientDll.dll');

  Set_Led_Server_Started(1);
  Set_Led_Client_Active(1);
  Set_Led_Receive_Data(1);
  Set_Led_Send_Data(1);

  Start_Server(Equipment_A);
end;

procedure TFrm_SocketServer.Initialize_Commands;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Server Data\Data.ini');
end;

procedure TFrm_SocketServer.Memo1DblClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TFrm_SocketServer.Reset_UpLoading;
begin
  E_File_Size.Text := '0';
  E_Received.Text := '0';
  E_BufferCount.Text := '0';
  PB_Uploading.Position := 0;
end;

procedure TFrm_SocketServer.Set_Led_Client_Active(aIndex: Integer);
begin
  ImageList1.GetBitmap(aIndex, Img_Client_Connected.Picture.bitmap);
  Img_Client_Connected.Repaint;
end;

procedure TFrm_SocketServer.Set_Led_Receive_Data(aIndex: integer);
begin
   ImageList1.GetBitmap(aIndex, Img_Server_Receive_Data.Picture.bitmap);
   Img_Server_Receive_Data.Repaint;
end;

procedure TFrm_SocketServer.Set_Led_Send_Data(aIndex: integer);
begin
   ImageList1.GetBitmap(aIndex, Img_Server_Send_Data.Picture.bitmap);
   Img_Server_Send_Data.Repaint;
end;

procedure TFrm_SocketServer.Set_Led_Server_Started(aIndex: integer);
begin
  ImageList1.GetBitmap(aIndex, Img_Server_Connected.Picture.bitmap);
  Img_Server_Connected.Repaint;
end;

procedure TFrm_SocketServer.Start_Server(AServer: TServerSocket);
var
  i: Integer;
begin

  if(Aserver.Active = False) then//The button caption is �Start�
  begin
    if Not Get_Dll_TxSocketClientDll_Loaded then
      Load_TxSocketClientDll(ExtractFilePath(Application.ExeName)+ '..\TxSocketClientDll\TxSocketClientDll.dll');

    Initialize_Commands;
    AServer.Active := True;//Activates the server socket
    Set_Led_Server_Started(2);
    Update_Tracer(Format('Server %s started',[AServer.Name]));
    Update_Tracer(Format('Server Listening on Port %d: ',[Aserver.Port]) + #13#10);
    Bt_StartStop_Server.Caption:='Stop Server';//Set the button caption
  end
  else//The button caption is �Stop�
  begin
    //Disconnecting Clients
    for i := 0 to AServer.Socket.ActiveConnections - 1 do
    begin
      aServer.Socket.Connections[i].SendText('Server Off');
      AServer.Socket.Connections[i].Close;
    end;

    AServer.Active := False;

    Unload_TxSocketClientDll;

    if Assigned(ReceiveFile) then
    begin
      FreeAndNilExt(ReceiveFile);
    end;

    Set_Led_Send_Data(1);
    Set_Led_Receive_Data(1);
    Set_Led_Client_Active(1);
    Set_Led_Server_Started(1);

    Update_Tracer(Format('Server %s Stopped', [aServer.Name])+ #13#10);
    Bt_StartStop_Server.Caption:='Start Server';

  end;
end;

procedure TFrm_SocketServer.Update_Progress_Bar;
begin
  E_Received.Text := FloatToStr(RoundTo(ReceiveFile.ReceivedSize/1000,-2));
  E_Received.Repaint;
  E_BufferCount.Text := IntToStr(ReceiveFile.buffercount);
  E_BufferCount.Repaint;

  PB_Uploading.Position := ReceiveFile.ReceivedSize;
  PB_Uploading.Repaint;
end;

procedure TFrm_SocketServer.Update_Tracer(aText: string);
begin
  Memo1.Lines.Add(Format('At %s', [DateTimeToStr(Now)]));
  Memo1.Lines.Add(aText);
  SendMessage(Memo1.Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TFrm_SocketServer.BT_Select_FileClick(Sender: TObject);
var
  OpenDlg: TOpenDialog;
begin
  OpenDlg := TOpenDialog.Create(self);
  OpenDlg.InitialDir := ExtractFileDir(Application.ExeName) + '\Server Data\Files';
  OpenDlg.Title := 'Select a file';

  if OpenDlg.Execute then
  try
    E_Server_File.Text := OpenDlg.FileName;
  finally
    OpenDlg.Free;
  end;
end;

procedure TFrm_SocketServer.Equipment_AClientConnect(Sender: TObject; Socket: TCustomWinSocket);
var
  rObjClient: TClient;
begin
 // Socket.SendText('Connected');//Sends a message to the client
  Update_Tracer('Connected to ' + Socket.RemoteHost);

  if CB_Clients_Connected.Items.IndexOf(Socket.RemoteHost) < 0 then
  begin
    rObjClient := TClient.Create;
    rObjClient.sHostName := Socket.RemoteHost;
    rObjClient.sIP_Adress := Socket.LocalAddress;
    rObjClient.iPort := Socket.LocalPort;
    CB_Clients_Connected.Items.AddObject(Socket.RemoteHost, rObjClient);
  end;
  Set_Led_Client_Active(2);
end;

procedure TFrm_SocketServer.Equipment_AClientDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Set_Led_Receive_Data(1);
  Update_Tracer(Format('Client %s disconnected', [Socket.RemoteHost])+ #13#10);
  Reset_UpLoading;
  //The server cannot send messages if there is no client connected to it
  if Equipment_A.Socket.ActiveConnections-1=0 then
    Set_Led_Client_Active(1);
end;

procedure TFrm_SocketServer.Equipment_AClientRead(Sender: TObject; Socket: TCustomWinSocket);
var
  IncommingText: AnsiString;
  sfunction: string;
  fStream: TMemoryStream;
  fStreamFile : TFileStream;
  sCommand: string;
  sReqType: string;
  sExtraData: string;
  CopyBuffer: array [0..8192] of Byte;
  iSizeReceived: Integer;

begin
  Set_Led_Receive_Data(2);
  try
    {$REGION 'Receiving File'}
    //First Process File Receiving Mode
    If assigned(ReceiveFile) And (ReceiveFile.bWriting) then
    begin
      repeat
        ReceiveFile.incBufferCount;
        iSizeReceived := socket.ReceiveBuf(CopyBuffer, 8192);
        Update_Tracer(format('%d received in buffer %d',[iSizeReceived, ReceiveFile.buffercount]));

        if iSizeReceived > 0 then
        begin
          ReceiveFile.FFileStream.Position := ReceiveFile.FReceivedSize;
          ReceiveFile.FFileStream.WriteBuffer(CopyBuffer, iSizeReceived);
          Inc(ReceiveFile.FReceivedSize, iSizeReceived);
        end;

        Update_Progress_Bar;

      until
        iSizeReceived <=0 ;

      If ReceiveFile.FReceivedSize = ReceiveFile.iFullSize then
      begin
        Update_Progress_Bar;
        Sleep(1000);
        ReceiveFile.SaveToFile;
        FreeAndNilExt(ReceiveFile);
        Set_Led_Receive_Data(1);
        Set_Led_Client_Active(1);
        //Reset_UpLoading;
        exit;
      end;
      Exit;
    end;
    {$ENDREGION}

    {$REGION 'Other Data'}
    IncommingText := Socket.ReceiveText;

    if length(IncommingText) = 0 then
      Exit;

    sCommand := trim(GetToken(IncommingText,1, ';'));
    sReqType :=  trim(GetToken(IncommingText,2, ';'));
    sExtraData :=  trim(GetToken(IncommingText,3, ';'));



    {$REGION 'Upload File'}

    if (sCommand = 'UploadFile') AND not Assigned(ReceiveFile) then
    begin
      ReceiveFile := TFileReceive.Create;
      ReceiveFile.SetFileName(sExtraData);

      E_File_Size.Text :=  FloatToStr(RoundTo(ReceiveFile.fullSize/1000,-2));
      Socket.SendText('Ready to upload.');
      Update_Tracer(Format('Client: %s / Request:%s',[IntToStr(Socket.SocketHandle), sCommand]));
      PB_Uploading.Max := ReceiveFile.fullSize;

      exit;
    end;

    {$ENDREGION}

    Update_Tracer(Format('Client: %s / Request:%s',[IntToStr(Socket.SocketHandle), sCommand]));

    {$REGION 'Command received'}

    if sCommand = 'Connexion' then
    begin
      Set_Led_Send_Data(2);
      Socket.SendText('Server available');
      exit;
    end;

    if sCommand = 'Commands' then
    begin
      Set_Led_Send_Data(2);
      Socket.SendText(Get_Commands);
      exit;
    end;

    {$REGION 'Download File'}

    if sCommand = 'Get File' then
    begin
      fStream := TMemoryStream.Create;

      Set_Led_Send_Data(2);

      fStreamFile := nil;
      fStreamFile := Get_File(sExtraData);

      if assigned(fStreamFile) then
        Socket.SendStream(fStreamFile);

      exit;
    end;

    {$ENDREGION}

 {$ENDREGION}

    {$REGION 'Known Functions'}
    sfunction  := inifile.ReadString('Parameters', sCommand, '' );

    if sfunction <> '' then
      if sfunction = 'Get_Name' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(E_Server_Name.Text);
        Exit;
      end;

      if sfunction = 'Get_Revision_Date' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_Revision_Date);
        Exit;
      end;

      if sfunction = 'Get_Status' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_Status);
        Exit;
      end;

      if sfunction = 'Get_State' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_State);
        Exit;
      end;

      if sfunction = 'Get_Value' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_Value(sExtraData));
        Exit;
      end;

       if sfunction = 'Get_Text' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_Text(sExtraData));
        Exit;
      end;
    {  if sfunction = 'Get_Boolean' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_Boolean(sExtraData));
      end;   }
      if sFunction = 'Get_File_List' then
      begin
        Set_Led_Send_Data(2);
        Socket.SendText(Get_Files_List);
        Exit;
      end;

    {$ENDREGION}


 {$ENDREGION}

  finally
    Set_Led_Send_Data(1);
    Set_Led_Receive_Data(1);
  end;
end;

procedure TFrm_SocketServer.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  canClose := Equipment_A.Active = false;
end;

procedure TFrm_SocketServer.FormCreate(Sender: TObject);
begin
  Initialize;
end;

{ TFileReceive }

constructor TFileReceive.Create;
begin
  inherited;
  sFileName := '';
  iFullSize := 0;
  iPos := 0;
  GetMem(pMem, 0);
  FFileStream := TMemoryStream.Create;
  bWriting := false;
end;

destructor TFileReceive.Destroy;
begin
  if assigned(FFileStream) then
    FFileStream.Free;
  FreeMem(pMem);
  inherited;
end;

procedure TFileReceive.incBufferCount;
begin
  Inc(iBufferCount,1);
end;

procedure TFileReceive.SaveToFile;
var
  sFileNameShort: string;
begin
  sFileNameShort := ExtractFileName(sFileName);
  FFileStream.SaveToFile(ExtractFilePath(Application.ExeName)+ 'Server Data\Files\' + sFileNameShort);
  SetWriting(false);
end;

procedure TFileReceive.SetBufferSize(aSize: int64);
begin
  ReallocMem(pMem, aSize);
  PMemSize := aSize;
end;

procedure TFileReceive.SetFileName(AValue: string);
var
  info: TWin32FileAttributeData;
begin
  sFileName := GetToken(aValue,1, '|');

  if NOT GetFileAttributesEx(PWideChar(sFileName), GetFileExInfoStandard, @info) then
    iFullSize := 0;

  SetSize(Int64(info.nFileSizeLow) or Int64(info.nFileSizeHigh shl 32));
  FFileStream.SetSize(iFullSize);
  SetWriting(True);
end;

procedure TFileReceive.SetReceivedSize(AValue: Int64);
begin
  FReceivedSize := FReceivedSize + aValue;
end;

procedure TFileReceive.SetSize(aSize: Int64);
begin
  iFullSize := aSize;
end;

procedure TFileReceive.SetWriting(aValue: boolean);
begin
  bWriting := aValue;
end;

procedure TFileReceive.WriteBuffer;
begin
  if (PMemSize >= 0) And (PMemSize + FReceivedSize >= fullSize) then
  begin
    FFileStream.WriteBuffer(pMem^, SizeOf(pMem));
    bWriting := false;
    SaveToFile;
    exit;
  end;

  FFileStream.WriteBuffer(pMem^, SizeOf(pMem));
end;

end.
