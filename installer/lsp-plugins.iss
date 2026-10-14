#ifndef AppVersion
  #if GetEnv("LSP_VERSION") != ""
    #define AppVersion GetEnv("LSP_VERSION")
  #else
    #define AppVersion "1.2.35"
  #endif
#endif

#ifndef PayloadDir
  #if GetEnv("LSP_INSTALL_DIR") != ""
    #define PayloadDir GetEnv("LSP_INSTALL_DIR")
  #else
    #define PayloadDir "..\INSTALL"
  #endif
#endif

[Setup]
AppId={{6A51BF52-32BA-47AB-AD47-66CE17CD03BA}}
AppName=LSP Plugins
AppVersion={#AppVersion}
AppPublisher=lab-o-ratory
AppPublisherURL=https://lsp-plug.in/
DefaultDirName={autopf}\LSP Plugins
DefaultGroupName=LSP Plugins
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
UninstallDisplayName=LSP Plugins {#AppVersion}
OutputBaseFilename=lsp-plugins-setup-{#AppVersion}-x86_64
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ChangesEnvironment=yes

[Types]
Name: "typical"; Description: "Typical installation"
Name: "full"; Description: "All plugin formats"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Components]
Name: "clap"; Description: "CLAP"; Types: typical full custom
Name: "vst3"; Description: "VST3"; Types: typical full custom
Name: "vst2"; Description: "VST2"; Types: full custom
Name: "lv2"; Description: "LV2"; Types: full custom
Name: "ladspa"; Description: "LADSPA (legacy)"; Types: full custom

[Files]
; Keep the MinGW runtime in one shared directory and on PATH for host applications.
Source: "{#PayloadDir}\libwinpthread-1.dll"; DestDir: "{app}\runtime"; Flags: ignoreversion

; CLAP: the plugin and its MinGW and LSP graphics runtimes must stay together.
Source: "{#PayloadDir}\lib\clap\lsp-plugins.clap"; DestDir: "{commoncf}\CLAP"; Flags: ignoreversion; Components: clap
Source: "{#PayloadDir}\libwinpthread-1.dll"; DestDir: "{commoncf}\CLAP"; Flags: ignoreversion; Components: clap
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib.dll"; DestDir: "{commoncf}\CLAP"; Flags: ignoreversion; Components: clap
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib-*.dll"; DestDir: "{commoncf}\CLAP"; Flags: ignoreversion; Components: clap

; VST3: keep dependencies next to the module inside the VST3 bundle.
Source: "{#PayloadDir}\lib\vst3\lsp-plugins.vst3\*"; DestDir: "{commoncf}\VST3\lsp-plugins.vst3"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: vst3
Source: "{#PayloadDir}\libwinpthread-1.dll"; DestDir: "{commoncf}\VST3\lsp-plugins.vst3\Contents\x86_64-win"; Flags: ignoreversion; Components: vst3
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib.dll"; DestDir: "{commoncf}\VST3\lsp-plugins.vst3\Contents\x86_64-win"; Flags: ignoreversion; Components: vst3
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib-*.dll"; DestDir: "{commoncf}\VST3\lsp-plugins.vst3\Contents\x86_64-win"; Flags: ignoreversion; Components: vst3

; VST2 requires "lsp-plugins" in the installation folder name.
Source: "{#PayloadDir}\lib\vst\lsp-plugins.vst\*"; DestDir: "{code:GetVst2Dir}"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: vst2
Source: "{#PayloadDir}\libwinpthread-1.dll"; DestDir: "{code:GetVst2Dir}"; Flags: ignoreversion; Components: vst2
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib.dll"; DestDir: "{code:GetVst2Dir}"; Flags: ignoreversion; Components: vst2
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib-*.dll"; DestDir: "{code:GetVst2Dir}"; Flags: ignoreversion; Components: vst2

; LV2 bundle files include the plugin metadata and module.
Source: "{#PayloadDir}\lib\lv2\lsp-plugins.lv2\*"; DestDir: "{commoncf}\LV2\lsp-plugins.lv2"; Flags: ignoreversion recursesubdirs createallsubdirs; Components: lv2
Source: "{#PayloadDir}\libwinpthread-1.dll"; DestDir: "{commoncf}\LV2\lsp-plugins.lv2"; Flags: ignoreversion; Components: lv2
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib.dll"; DestDir: "{commoncf}\LV2\lsp-plugins.lv2"; Flags: ignoreversion; Components: lv2
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib-*.dll"; DestDir: "{commoncf}\LV2\lsp-plugins.lv2"; Flags: ignoreversion; Components: lv2

; LADSPA has no single standard Windows scan location; install under the product folder.
Source: "{#PayloadDir}\lib\ladspa\lsp-plugins-ladspa.dll"; DestDir: "{autopf}\LSP Plugins\LADSPA"; Flags: ignoreversion; Components: ladspa
Source: "{#PayloadDir}\libwinpthread-1.dll"; DestDir: "{autopf}\LSP Plugins\LADSPA"; Flags: ignoreversion; Components: ladspa
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib.dll"; DestDir: "{autopf}\LSP Plugins\LADSPA"; Flags: ignoreversion; Components: ladspa
Source: "{#PayloadDir}\lib\lsp-r3d-wgl-lib-*.dll"; DestDir: "{autopf}\LSP Plugins\LADSPA"; Flags: ignoreversion; Components: ladspa

[Code]
const
  EnvironmentKey = 'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';

var
  Vst2DirPage: TInputDirWizardPage;

function PathContainsEntry(const PathValue, EntryToFind: String): Boolean;
var
  StartPos, EndPos: Integer;
  Entry: String;
begin
  Result := False;
  StartPos := 1;
  while StartPos <= Length(PathValue) do
  begin
    EndPos := StartPos;
    while (EndPos <= Length(PathValue)) and (PathValue[EndPos] <> ';') do
      EndPos := EndPos + 1;
    Entry := RemoveQuotes(Trim(Copy(PathValue, StartPos, EndPos - StartPos)));
    if (Entry <> '') and PathSame(Entry, EntryToFind) then
    begin
      Result := True;
      Exit;
    end;
    StartPos := EndPos + 1;
  end;
end;

function AddPathEntry(const PathValue, EntryToAdd: String): String;
begin
  if PathContainsEntry(PathValue, EntryToAdd) then
    Result := PathValue
  else if PathValue = '' then
    Result := EntryToAdd
  else
    Result := PathValue + ';' + EntryToAdd;
end;

function RemovePathEntry(const PathValue, EntryToRemove: String): String;
var
  StartPos, EndPos: Integer;
  Entry: String;
  FirstEntry: Boolean;
begin
  Result := '';
  FirstEntry := True;
  StartPos := 1;
  while StartPos <= Length(PathValue) + 1 do
  begin
    EndPos := StartPos;
    while (EndPos <= Length(PathValue)) and (PathValue[EndPos] <> ';') do
      EndPos := EndPos + 1;
    Entry := Copy(PathValue, StartPos, EndPos - StartPos);
    if not PathSame(RemoveQuotes(Trim(Entry)), EntryToRemove) then
    begin
      if not FirstEntry then
        Result := Result + ';';
      Result := Result + Entry;
      FirstEntry := False;
    end;
    StartPos := EndPos + 1;
  end;
end;

procedure UpdateRuntimePath(AddEntry: Boolean);
var
  CurrentPath, NewPath, RuntimeDir: String;
  HavePath: Boolean;
begin
  RuntimeDir := ExpandConstant('{app}\runtime');
  HavePath := RegQueryStringValue(HKLM64, EnvironmentKey, 'Path', CurrentPath);

  if AddEntry then
  begin
    if not HavePath then
      CurrentPath := '';
    NewPath := AddPathEntry(CurrentPath, RuntimeDir);
    if (NewPath <> CurrentPath) and
       not RegWriteExpandStringValue(HKLM64, EnvironmentKey, 'Path', NewPath) then
      RaiseException('Could not add the LSP Plugins runtime directory to the system PATH.');
  end
  else if HavePath then
  begin
    NewPath := RemovePathEntry(CurrentPath, RuntimeDir);
    if (NewPath <> CurrentPath) and
       not RegWriteExpandStringValue(HKLM64, EnvironmentKey, 'Path', NewPath) then
      Log('Could not remove the LSP Plugins runtime directory from the system PATH.');
  end;
end;

procedure InitializeWizard;
begin
  Vst2DirPage := CreateInputDirPage(wpSelectDir,
    'VST2 plug-in folder',
    'Choose the VST2 scan folder',
    'The installer adds an "lsp-plugins" subfolder here so the VST2 core library can be found.',
    False, '');
  Vst2DirPage.Add('VST2 scan folder:');
  Vst2DirPage.Values[0] := ExpandConstant('{commoncf}\VST');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  Result := (PageID = Vst2DirPage.ID) and not IsComponentSelected('vst2');
end;

function GetVst2Dir(Param: String): String;
begin
  Result := AddBackslash(Vst2DirPage.Values[0]) + 'lsp-plugins';
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
    UpdateRuntimePath(True);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
    UpdateRuntimePath(False);
end;
