#ifndef AppVersion
  #define AppVersion "1.2.35"
#endif

#ifndef PayloadDir
  #define PayloadDir "..\INSTALL"
#endif

[Setup]
AppId={{6A51BF52-32BA-47AB-AD47-66CE17CD03BA}}
AppName=LSP Plugins
AppVersion={#AppVersion}
AppPublisher=lab-o-ratory
AppPublisherURL=https://lsp-plug.in/
DefaultDirName={autopf}\LSP Plugins
DefaultGroupName=LSP Plugins
DefaultTypeName=typical
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
UninstallDisplayName=LSP Plugins {#AppVersion}
OutputBaseFilename=lsp-plugins-setup-{#AppVersion}-x86_64
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Types]
Name: "typical"; Description: "Typical installation"
Name: "full"; Description: "All plugin formats"; Flags: isfull
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "clap"; Description: "CLAP"; Types: typical full custom
Name: "vst3"; Description: "VST3"; Types: typical full custom
Name: "vst2"; Description: "VST2"; Types: full custom
Name: "lv2"; Description: "LV2"; Types: full custom
Name: "ladspa"; Description: "LADSPA (legacy)"; Types: full custom

[Files]
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
var
  Vst2DirPage: TInputDirWizardPage;

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
