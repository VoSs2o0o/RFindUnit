unit uInstaller;

interface

uses
	ShellAPI, Windows, SysUtils, uDelphiInstallationCheck, System.Win.Registry;

type
  TRetProcedure = procedure(Desc: string) of object;

  TInstaller = class(TObject)
  private
    FCallBackProc: TRetProcedure;

    function GetDelphiVersionFromDescription(DelphiDescription: string): TDelphiVersions;
  const
      BPL_FILENAME = 'RFindUnit.bpl';

      RSVARS_FILENAME = 'rsvars.bat';
      DCU32INT_EXE = 'dcu32int.exe';
  var
    FDelphiBplOutPut, FDelphiBinPath, FCurPath, FOutPutDir, FDelphiDesc,
    FUserAppDirFindUnit, FDcu32IntPath: string;
    FReg, FRegPacks: string;


    FDelphiVersion: TDelphiVersions;
    FPackagePath: string;

    procedure LoadPaths(DelphiDesc, DelphiPath: string);
    procedure CheckDelphiRunning;
    procedure CheckDpkExists;
    procedure RemoveCurCompiledBpl;
    procedure CompileProject;
    procedure RegisterBpl;
    procedure RemoveOldDelphiBpl;
    procedure InstallBpl;
    procedure InstallDcu32Int;
  public
    constructor Create(DelphiDesc, DelphiPath: string);
    destructor Destroy; override;

    procedure Install(CallBackProc: TRetProcedure);
  end;

implementation

uses
  TlHelp32, Vcl.Forms, System.IOUtils;

{ TInstaller }

function IsProcessRunning(const AExeFileName: string): Boolean;
var
  Continuar: BOOL;
  SnapshotHandle: THandle;
  Entry: TProcessEntry32;
begin
  Result := False;
  try
    SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    Entry.dwSize := SizeOf(Entry);
    Continuar := Process32First(SnapshotHandle, Entry);
    while Integer(Continuar) <> 0 do
    begin
      if ((UpperCase(ExtractFileName(Entry.szExeFile)) = UpperCase(AExeFileName)) or
        (UpperCase(Entry.szExeFile) = UpperCase(AExeFileName))) then
      begin
        Result := True;
      end;
      Continuar := Process32Next(SnapshotHandle, Entry);
    end;
    CloseHandle(SnapshotHandle);
  except
    Result := False;
  end;
end;

procedure TInstaller.CheckDelphiRunning;
begin
  FCallBackProc('Cheking if is there same Delphi instance running...');
  if (IsProcessRunning('bds.exe')) and (not IsDebuggerPresent()) then
    Raise Exception.Create('Close all you Delphi instances before install.');
end;

procedure TInstaller.CheckDpkExists;
begin
  FCallBackProc('Cheking if project file exist...');
  if not FileExists(FPackagePath) then
    raise Exception.Create('The system was not able to find: ' + FCurPath);
end;

procedure TInstaller.CompileProject;
const
  GCC_CMDLINE = '/c cd "%s" & call "%s" & dcc32 "%s" -LE"%s" & pause';
var
  GccCmd: WideString;
  I: Integer;
begin

  FCallBackProc('Compiling project...');
  GccCmd := Format(GCC_CMDLINE, [
    ExtractFilePath(FPackagePath),
    FDelphiBinPath + RSVARS_FILENAME,
    FPackagePath,
    ExcludeTrailingPathDelimiter(FOutPutDir)]);

  ShellExecute(0, nil, 'cmd.exe', PChar(GccCmd), nil, SW_HIDE);

  for I := 0 to 10 do
  begin
    if FileExists(FOutPutDir + BPL_FILENAME) then
      Exit;

    if I = 9 then
      raise Exception.Create('Could not compile file: ' + FOutPutDir + BPL_FILENAME);
    Sleep(1000);
  end;
end;

function TInstaller.GetDelphiVersionFromDescription(DelphiDescription: string): TDelphiVersions;
begin
  if DelphiDescription.Contains('Seattle') then
    Result := TDelphiVersions.DelphiSeattle100
  else if DelphiDescription.Contains('Berlin') then
    Result := TDelphiVersions.DelphiBerlin101
  else if DelphiDescription.Contains('Tokyo') then
    Result := TDelphiVersions.DelphiTokyo102
  else if DelphiDescription.Contains('Rio') then
    Result := TDelphiVersions.DelphiRio103
  else if DelphiDescription.Contains('Rio') then
    Result := TDelphiVersions.DelphiSydney104
  else if DelphiDescription.Contains('Alexandria') then
    Result := TDelphiVersions.DelphiAlexandria110;
end;

constructor TInstaller.Create(DelphiDesc, DelphiPath: string);
begin
  FDelphiDesc := DelphiDesc;
  FDelphiVersion := GetDelphiVersionFromDescription(FDelphiDesc);
  LoadPaths(DelphiDesc, DelphiPath);
end;

destructor TInstaller.Destroy;
begin

  inherited;
end;

procedure TInstaller.Install(CallBackProc: TRetProcedure);
begin
  FCallBackProc := CallBackProc;

  CheckDelphiRunning;
  CheckDpkExists;
  RemoveCurCompiledBpl;
  if TDelphiInstallationCheck.GetEdition(FDelphiVersion) = DELPHI_EDITION_COMMUNITY then
  begin;
    var PkgDir:= ExtractFilePath(FPackagePath);
    if not FileExists(TPath.Combine(PkgDir, BPL_FILENAME)) then
    begin
      Application.MessageBox('You have a Community Edition, you have to compile the package by yourself:' + #13#10 +
                             '1) Start the Project with Packages/<Version>/RFindUnit.dproj' + #13#10 +
                             '2) compile RFindUnit.bpl as with Release Target' +#13#10 +
                             '3) come back :-)', 'Error', MB_OK);
      Halt;
    end
    else
    begin
      TFile.Copy(PkgDir + BPL_FILENAME, FOutputDir + BPL_FILENAME);
    end;
  end
  else
  begin;
    CompileProject;
  end;
  RegisterBpl;
  RemoveOldDelphiBpl;
  InstallBpl;
  InstallDcu32Int;
end;

procedure TInstaller.InstallBpl;
var
  I: Integer;
  Return: Boolean;
begin
  FCallBackProc('Installing new version...');
  Return := Windows.CopyFile(PChar(FOutPutDir + BPL_FILENAME), PChar(FDelphiBplOutPut + BPL_FILENAME), True);

  if not Return then
    raise Exception.Create('Could not install: ' + FDelphiBplOutPut + BPL_FILENAME + '. ' + SysErrorMessage(GetLastError));

  for I := 0 to 30 do
  begin
    if FileExists(FDelphiBplOutPut + BPL_FILENAME) then
      Exit;

    if I = 9 then
      raise Exception.Create('Could not install: ' + FDelphiBplOutPut + BPL_FILENAME);
    Sleep(500);
  end;
end;

procedure TInstaller.InstallDcu32Int;
begin
  FCallBackProc('Installing Dcu32Int');
  Windows.CopyFile(PChar(FDcu32IntPath + DCU32INT_EXE), PChar(FUserAppDirFindUnit + DCU32INT_EXE), True);
end;

procedure TInstaller.LoadPaths(DelphiDesc, DelphiPath: string);
var
  DelphiInst: TDelphiInstallationCheck;
  DelphiVersion: TDelphiVersions;
begin
  FDelphiBinPath := ExtractFilePath(DelphiPath);
  FCurPath := ExtractFilePath(ParamStr(0));

  FDelphiBplOutPut := GetEnvironmentVariable('public') + '\Documents\RAD Studio\RFindUnit\' + DelphiDesc + '\bpl\';
  FDcu32IntPath := ExtractFilePath(ParamStr(0)) + '\Thirdy\Dcu32Int\';
  FUserAppDirFindUnit := GetEnvironmentVariable('appdata') + '\DelphiFindUnit\';
  FOutPutDir := FCurPath + 'build\' + TDelphiInstallationCheck.GetDelphiNameByVersion(FDelphiVersion) + '\';
  FPackagePath := TDirectory.GetParent(ExcludeTrailingPathDelimiter(FCurPath)) + '\Packages\';
  FPackagePath := FPackagePath + TDelphiInstallationCheck.GetDelphiDpkFromVersion(FDelphiVersion);

  ForceDirectories(FUserAppDirFindUnit);
  ForceDirectories(FDelphiBplOutPut);
  ForceDirectories(FOutPutDir);

  DelphiInst := TDelphiInstallationCheck.Create;
  try
    DelphiVersion := DelphiInst.GetDelphiVersionByName(DelphiDesc);
    FReg := DelphiInst.GetDelphiRegPathFromVersion(DelphiVersion);
    FRegPacks := FReg + '\Known Packages';
  finally
    DelphiInst.Free;
  end;
end;

procedure TInstaller.RegisterBpl;
var
  Reg: TRegistry;
begin
  FCallBackProc('Registering package...');

  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey(FRegPacks, False);
    Reg.WriteString(FDelphiBplOutPut + BPL_FILENAME, 'RfUtils');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

procedure TInstaller.RemoveCurCompiledBpl;
var
  I: Integer;
begin
  FCallBackProc('Removing old bpl...');
  for I := 0 to 10 do
  begin
    if not FileExists(FOutPutDir + BPL_FILENAME) then
      Exit;
    DeleteFile(FOutPutDir + BPL_FILENAME);

    if I = 9 then
      raise Exception.Create('Could not remote file: ' + FOutPutDir + BPL_FILENAME);
    Sleep(200);
  end;
end;

procedure TInstaller.RemoveOldDelphiBpl;
var
  I: Integer;
begin
  FCallBackProc('Uninstalling old version...');
  for I := 0 to 10 do
  begin
    if not FileExists(FDelphiBplOutPut + BPL_FILENAME) then
      Exit;
    DeleteFile(FDelphiBplOutPut + BPL_FILENAME);

    if I = 9 then
      raise Exception.Create('Could not uninstall old version: ' + FDelphiBplOutPut + BPL_FILENAME);
    Sleep(200);
  end;
end;

end.
