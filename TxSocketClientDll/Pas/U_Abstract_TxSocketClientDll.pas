///<author>dev@bassetti.fr</author>
///<summary>Unit loading / unloading the dll named "TxSocketClientDll". This file is generated by TXUtils. Do not modify.</summary>
unit U_Abstract_TxSocketClientDll;
interface

uses
  Windows,SysUtils,System.Win.ScktComp,Classes, U_Small_Lib;

type
  {$REGION 'TxSocketClientThread'}
  TClientSocketThread=class(TThread);

  TClientRequestThread=function(aIP: string; aPort: Integer; aCommand: string; aRequiredType: string='str'; aExtraData: string=''; aClientType: TClientType=ctBlocking; aTimeOut: Integer=2000): TMemoryStream; stdcall;

  TClientSendFile=function(aIP: string; aPort: Integer; aCommand: string; aFileName: string=''; aClientType: TClientType=ctBlocking; aTimeOut: Integer=2000): string; stdcall;

  TWriteStreamInt=procedure(aStream: TMemoryStream; Num: Integer); stdcall;

  TWriteStreamStr=procedure(aStream: TMemoryStream; Str: string); stdcall;

  TMemoryStreamToString=function(aStream: TMemoryStream; AEncoding: TEncoding): string; stdcall;
  {$ENDREGION}



var
  {$REGION 'TxSocketClientThread'}
  ClientRequestThread: TClientRequestThread;
  ClientSendFile: TClientSendFile;
  WriteStreamInt: TWriteStreamInt;
  WriteStreamStr: TWriteStreamStr;
  MemoryStreamToString: TMemoryStreamToString;
  {$ENDREGION}


///<summary>Procedure loading the dll named "TxSocketClientDll".</summary>
///<param name="AFilePath">The absolute path to the dll.</param>
procedure Load_TxSocketClientDll(AFilePath: string);

///<summary>Procedure unloading the dll named "TxSocketClientDll".</summary>
procedure Unload_TxSocketClientDll;

///<summary>Function returning true if the dll "TxSocketClientDll" was loaded.</summary>
function Get_Dll_TxSocketClientDll_Loaded: boolean;

implementation

var
  hDll: THandle;

procedure Load_TxSocketClientDll(AFilePath: string);
resourcestring
  RS_Error_Invalide_File='Le fichier %s n''est pas valide.';
begin
  if hDll <> 0 then
    exit;

  Check_FileExists(AFilePath);

  hDll := Load_Dll(AFilePath);

  {$REGION 'TxSocketClientThread'}
  @ClientRequestThread := Get_Dll_Function_Adress(hDll,'ClientRequestThread',AFilePath);
  @ClientSendFile := Get_Dll_Function_Adress(hDll,'ClientSendFile',AFilePath);
  @WriteStreamInt := Get_Dll_Function_Adress(hDll,'WriteStreamInt',AFilePath);
  @WriteStreamStr := Get_Dll_Function_Adress(hDll,'WriteStreamStr',AFilePath);
  @MemoryStreamToString := Get_Dll_Function_Adress(hDll,'MemoryStreamToString',AFilePath);
  {$ENDREGION}


end;

procedure Unload_TxSocketClientDll;
begin
  if hDll <> 0 then
  begin
    try
      FreeLibrary(hDll);
      hDll := 0;
    except
    end;
  end;
end;

function Get_Dll_TxSocketClientDll_Loaded: boolean;
begin
  result := (hDll>0)
end;

initialization
  hDll := 0;

finalization
  Unload_TxSocketClientDll;

end.