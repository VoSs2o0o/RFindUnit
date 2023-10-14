//Base code Font: https://github.com/RRUZ/blog/tree/master/Misc/SelectDelphiVersion
unit uDelphiInstallationCheck;

interface

uses
  ComCtrls, Controls, SysUtils, Windows,

  System.Win.Registry;

const
   DELPHI_EDITION_COMMUNITY: string = 'Starter';

type
  TDelphiVersions = (
    DelphiSeattle100,
    DelphiBerlin101,
    DelphiTokyo102,
    DelphiRio103,
    DelphiSydney104,
    DelphiAlexandria110);

  TDelphiInstallationCheck = class(TObject)
  public
    class procedure LoadInstalledVersions(ImageList: TImageList; ListView: TListView);
    class function GetDelphiVersionByName(DelphiName: string): TDelphiVersions;
    class function GetDelphiRegPathFromVersion(Version: TDelphiVersions): string;
    class function GetDelphiDpkFromVersion(Version: TDelphiVersions): string;
    class function GetDelphiNameByVersion(Version: TDelphiVersions): string;
    class function GetEdition(Version: TDelphiVersions): string;
  end;

implementation

uses
  CommCtrl, ShellAPI;

const
  TDelphiVersionsNames: array [TDelphiVersions] of string = (
    'RAD Studio 10 Seattle',
    'RAD Studio 10.1 Berlin',
    'RAD Studio 10.2 Tokyo',
    'RAD Studio 10.3 Rio',
    'RAD Studio 10.4 Sydney',
    'RAD Studio 11.0 Alexandria'
    );

  TDelphiRegPaths: array [TDelphiVersions] of string = (
    '\Software\Embarcadero\BDS\17.0',
    '\Software\Embarcadero\BDS\18.0',
    '\Software\Embarcadero\BDS\19.0',
    '\Software\Embarcadero\BDS\20.0',
    '\Software\Embarcadero\BDS\21.0',
    '\Software\Embarcadero\BDS\22.0'
  );

  TDelphiPackages: array [TDelphiVersions] of string = (
    'Delphi101\',
    'Delphi100\',
    'Delphi102\',
    'Delphi103\',
    'Delphi104\',
    'Delphi110\'
  );

  DPK_FILENAME = 'RFindUnit.dpk';

function RegKeyExists(const RegPath: string; const RootKey: HKEY): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Reg.RootKey := RootKey;
      Result := Reg.KeyExists(RegPath);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

function RegReadStr(const RegPath, RegValue: string; var Str: string; const RootKey: HKEY): Boolean;
var
  Reg: TRegistry;
begin
  try
    Reg := TRegistry.Create;
    try
      Reg.RootKey := RootKey;
      Result := Reg.OpenKey(RegPath, True);
      if Result then
        Str := Reg.ReadString(RegValue);
    finally
      Reg.Free;
    end;
  except
    Result := False;
  end;
end;

procedure ExtractIconFileToImageList(ImageList: TImageList; const Filename: string);
var
  FileInfo: TShFileInfo;
begin
  if FileExists(Filename) then
  begin
    FillChar(FileInfo, SizeOf(FileInfo), 0);
    SHGetFileInfo(PChar(Filename), 0, FileInfo, SizeOf(FileInfo), SHGFI_ICON or SHGFI_SMALLICON);
    if FileInfo.hIcon <> 0 then
    begin
      ImageList_AddIcon(ImageList.Handle, FileInfo.hIcon);
      DestroyIcon(FileInfo.hIcon);
    end;
  end;
end;

{ TFrmSelDelphiVer }
class function TDelphiInstallationCheck.GetDelphiDpkFromVersion(Version: TDelphiVersions): string;
begin
  Result := TDelphiPackages[Version] + DPK_FILENAME;
end;

class function TDelphiInstallationCheck.GetDelphiNameByVersion(Version: TDelphiVersions): string;
begin
  Result := TDelphiVersionsNames[Version];
end;

class function TDelphiInstallationCheck.GetDelphiRegPathFromVersion(Version: TDelphiVersions): string;
begin
  Result := TDelphiRegPaths[Version];
end;

class function TDelphiInstallationCheck.GetDelphiVersionByName(DelphiName: string): TDelphiVersions;
var
  DelphiComp: TDelphiVersions;
begin
  for DelphiComp := Low(TDelphiVersions) to High(TDelphiVersions) do
    if TDelphiVersionsNames[TDelphiVersions(DelphiComp)] = DelphiName then
    begin
      Result := TDelphiVersions(DelphiComp);
    end;
end;

class procedure TDelphiInstallationCheck.LoadInstalledVersions(ImageList: TImageList; ListView: TListView);
Var
  Item: TListItem;
  DelphiComp: TDelphiVersions;
  Filename: string;
  ImageIndex: Integer;
begin
  for DelphiComp := Low(TDelphiVersions) to High(TDelphiVersions) do
    if RegKeyExists(TDelphiRegPaths[DelphiComp], HKEY_CURRENT_USER) then
      if RegReadStr(TDelphiRegPaths[DelphiComp], 'App', Filename, HKEY_CURRENT_USER) and FileExists(Filename) then
      begin
        Item := ListView.Items.Add;
        Item.Caption := TDelphiVersionsNames[DelphiComp];
        Item.SubItems.Add(Filename);
        ExtractIconFileToImageList(ImageList, Filename);
        ImageIndex := ImageList.Count - 1;
        Item.ImageIndex := ImageIndex;
      end;
end;

class function TDelphiInstallationCheck.GetEdition(Version: TDelphiVersions): string;
begin
  var regpath := GetDelphiRegPathFromVersion(Version);
  if RegKeyExists(regpath, HKEY_CURRENT_USER) then
    if not RegReadStr(regpath, 'Edition', result, HKEY_CURRENT_USER) then
      result:= 'unknown';
end;

end.
