﻿unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Winapi.PsAPI, System.Math, Vcl.Menus, Winapi.ShellApi, TlHelp32;

type
  TForm1 = class(TForm)
    btn_List: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edt_Port: TEdit;
    CheckBox_Filter: TCheckBox;
    ListView_Connections: TListView;
    PopupMenu1: TPopupMenu;
    PMI_OpenFileFolder: TMenuItem;
    PMI_FileProperties: TMenuItem;
    N1: TMenuItem;
    PMI_KillProcess: TMenuItem;
    procedure btn_ListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListView_ConnectionsColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView_ConnectionsCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure PMI_OpenFileFolderClick(Sender: TObject);
    procedure PMI_FilePropertiesClick(Sender: TObject);
    procedure PMI_KillProcessClick(Sender: TObject);
  private
   Descending: Boolean;
   SortedColumn: Integer;
   SortPort: Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  DOSOutput: TstringList;

implementation

{$R *.dfm}

function GetPathPID(PID: DWORD): String;
var
    Handle: THandle;
begin
   Result := '';
   Handle := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, False, PID);
   if Handle <> 0 then
   try
      SetLength(Result, MAX_PATH);
   if GetModuleFileNameEx(Handle, 0, PChar(Result), MAX_PATH) > 0 then
      SetLength(Result, StrLen(PChar(Result)))
   else
      Result := '';
   finally
      CloseHandle(Handle);
   end;
end;

function GetDosOutput(CommandLine: string; Work: string = 'C:\'): String;
var
    SA: TSecurityAttributes;
    SI: TStartupInfo;
    PI: TProcessInformation;
    StdOutPipeRead, StdOutPipeWrite: THandle;
    WasOK: Boolean;
    Buffer: Array[0 .. 255] of Byte;
    BytesRead: Cardinal;
    WorkDir: string;
    Handle: Boolean;
    Encoding: TEncoding;
    Partial: String;
begin
    Result := '';
    with SA do
    begin
        nLength := SizeOf(SA);
        bInheritHandle := True;
        lpSecurityDescriptor := nil;
    end;
    CreatePipe(StdOutPipeRead, StdOutPipeWrite, @SA, 0);
    try
        with SI do
        begin
            FillChar(SI, SizeOf(SI), 0);
            cb := SizeOf(SI);
            dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
            wShowWindow := SW_HIDE;
            hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
            hStdOutput := StdOutPipeWrite;
            hStdError := StdOutPipeWrite;
        end;
        WorkDir := Work;
        Handle := CreateProcess(nil, PWideChar('cmd.exe /C ' + CommandLine), nil, nil, True, 0, nil, PWideChar(WorkDir), SI, PI);
        CloseHandle(StdOutPipeWrite);
        if Handle then
            try
               Encoding := TEncoding.GetEncoding(GetOEMCP);
                repeat
                    WasOK := ReadFile(StdOutPipeRead, Buffer, 255, BytesRead, nil);
                    if BytesRead > 0 then
                    begin
                        Buffer[BytesRead] := $00;
                        Partial := Encoding.GetString(Buffer);
                        Result := Result + Copy(Partial, 0, BytesRead);
                    end;
                until not WasOK or (BytesRead = 0);
                WaitForSingleObject(PI.hProcess, INFINITE);
            finally
                CloseHandle(PI.hThread);
                CloseHandle(PI.hProcess);
            end;
    finally
        CloseHandle(StdOutPipeRead);
    end;
end;

procedure TForm1.btn_ListClick(Sender: TObject);
var
   I, Idx: Integer;
   DOSLine: String;
   Line: TStringList;
   Item: TListItem;
   vProt, vLocalAddr, vPort, vExtAddr, vStatus, vPID, vAppName, vLocation: String;
begin
   DOSOutput.Clear;
   ListView_Connections.Clear;
   try
      DOSOutput.Text := Trim(GetDosOutput('Netstat -a -n -o -p TCP'));
   finally
   end;
   if DOSOutput.Count > 1 then
   begin
      DOSOutput.Delete(0);
      DOSOutput.Delete(0);
      DOSOutput.Delete(0);
   end;
   Line := TStringList.Create;
   for I := 0 to DOSOutput.Count - 1 do
   begin
      DOSLine := Trim(DOSOutput.Strings[I]);
      if Pos(':', DOSLine) = 0 then
         Continue;

      Line.Delimiter := Char(20);
      Line.DelimitedText := DOSLine;
      if Line.Count <> 5 then
         Continue;

      vProt       := Line.Strings[0];
      vLocalAddr  := Copy(Line.Strings[1],0, Pos(':', Line.Strings[1]) - 1);
      vPort       := Copy(Line.Strings[1], Pos(':', Line.Strings[1]) + 1, Length(Line.Strings[1]));
      vExtAddr    := Line.Strings[2];
      vStatus     := Line.Strings[3];
      vPID        := Line.Strings[4];

      vLocation := GetPathPID(vPID.ToInteger);
      vAppName := ExtractFileName(vLocation);

      //ShowMessage(GetDosOutput('tasklist | findstr "' + vPID + '"'));


      if CheckBox_Filter.Checked then
      begin
         if vPort <> edt_Port.Text then
            Continue;
      end;

      Item := ListView_Connections.Items.Add;
      Item.Caption := vProt;
      Item.SubItems.Add(vLocalAddr);
      Item.SubItems.Add(vPort);
      Item.SubItems.Add(vExtAddr);
      Item.SubItems.Add(vStatus);
      Item.SubItems.Add(vPID);
      Item.SubItems.Add(vAppName);
      Item.SubItems.Add(vLocation);
   end;
   Line.Free;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   DOSOutput.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   DOSOutput := TstringList.Create;
end;

procedure TForm1.ListView_ConnectionsColumnClick(Sender: TObject; Column: TListColumn);
begin
   if (Column.Index = 2) or (Column.Index = 5) then
      SortPort := True
   else
      SortPort := False;

   TListView(Sender).SortType := stNone;
   if Column.Index <> SortedColumn then
   begin
      SortedColumn := Column.Index;
      Descending := False;
   end
   else
      Descending := not Descending;
   TListView(Sender).SortType := stText;
end;

procedure TForm1.ListView_ConnectionsCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
   if SortedColumn = 0 then
      Compare := CompareText(Format('%.8s', [Item1.Caption]), Format('%.8s', [Item2.Caption]))
   else
      if SortedColumn <> 0 then
      begin
         if SortPort then
            Compare := CompareText(Format('%.8d', [StrToInt(Item1.SubItems[SortedColumn-1])]), Format('%.8d', [StrToInt(Item2.SubItems[SortedColumn-1])]))
         else
            Compare := CompareText(Format('%.8s', [Item1.SubItems[SortedColumn-1]]), Format('%.8s', [Item2.SubItems[SortedColumn-1]]));
      end;
   if Descending then
      Compare := -Compare;
end;

Procedure ShowFileProperties(Const filename: String);
Var
sei: TShellExecuteinfo;
Begin
   FillChar(sei,sizeof(sei),0);
   sei.cbSize := sizeof(sei);
   sei.lpFile := Pchar(filename);
   sei.lpVerb := 'Properties';
   sei.fMask  := SEE_MASK_INVOKEIDLIST;
   ShellExecuteEx(@sei);
End;

procedure TForm1.PMI_FilePropertiesClick(Sender: TObject);
begin
   if (Assigned(ListView_Connections.Selected)) and (Trim(ListView_Connections.Selected.SubItems[6]) <> '') then
      ShowFileProperties(ListView_Connections.Selected.SubItems[6]);
end;

procedure TForm1.PMI_KillProcessClick(Sender: TObject);
const
   PROCESS_TERMINATE = $0001;
var
   ContinueLoop: BOOL;
   FSnapshotHandle: THandle;
   FProcessEntry32: TProcessEntry32;
begin
   if (Assigned(ListView_Connections.Selected)) and (Trim(ListView_Connections.Selected.SubItems[6]) <> '') then
   begin
      FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
      FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
      ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);

      while Integer(ContinueLoop) <> 0 do
      begin
       if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile)) = UpperCase(ListView_Connections.Selected.SubItems[5])) or
         (UpperCase(FProcessEntry32.szExeFile) = UpperCase(ListView_Connections.Selected.SubItems[5]))) then
            TerminateProcess(OpenProcess(PROCESS_TERMINATE, BOOL(0), FProcessEntry32.th32ProcessID), 0);
        ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
      end;
      CloseHandle(FSnapshotHandle);
      btn_ListClick(nil);
   end;
end;

procedure TForm1.PMI_OpenFileFolderClick(Sender: TObject);
var
   pt: TPoint;
begin
   if (Assigned(ListView_Connections.Selected)) and (Trim(ListView_Connections.Selected.SubItems[6]) <> '') then
      ShellExecute(Handle, 'OPEN', PChar('explorer.exe'), PChar('/select, "' + ListView_Connections.Selected.SubItems[6] + '"'), '/properties', SW_NORMAL);
end;

end.