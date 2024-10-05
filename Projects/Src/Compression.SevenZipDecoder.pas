unit Compression.SevenZipDecoder;

{
  Inno Setup
  Copyright (C) 1997-2024 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Interface to the 7-Zip Decoder OBJ in Compression.SevenZipDecoder\7ZipDecode,
  used by Setup.
}

interface

function SevenZipDecode(const FileName, DestDir: String;
  const FullPaths: Boolean): Integer;

implementation

uses
  Windows, SysUtils, Compression.LZMADecompressor, Setup.LoggingFunc;

{ Compiled by Visual Studio 2022 using compile.bat
  To enable source debugging recompile using compile-bcc32c.bat and turn off the VISUALSTUDIO define below
  Note that in a speed test the code produced by bcc32c was about 33% slower }
{$L Src\Compression.SevenZipDecoder\7zDecode\IS7zDec.obj}
{$DEFINE VISUALSTUDIO}

function IS_7zDec(const fileName: PChar; const fullPaths: Bool): Integer; cdecl; external name '_IS_7zDec';

{$IFDEF VISUALSTUDIO}
function __CreateDirectoryW(lpPathName: LPCWSTR;
  lpSecurityAttributes: PSecurityAttributes): BOOL; cdecl;
begin
  Result := CreateDirectoryW(lpPathName, lpSecurityAttributes);
end;

{ Never actually called but still required by the linker }
function __CreateFileA(lpFileName: LPCSTR; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; cdecl;
begin
  Result := CreateFileA(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
end;

function __CreateFileW(lpFileName: LPCWSTR; dwDesiredAccess, dwShareMode: DWORD;
  lpSecurityAttributes: PSecurityAttributes; dwCreationDisposition, dwFlagsAndAttributes: DWORD;
  hTemplateFile: THandle): THandle; cdecl;
begin
  Result := CreateFileW(lpFileName, dwDesiredAccess, dwShareMode, lpSecurityAttributes, dwCreationDisposition, dwFlagsAndAttributes, hTemplateFile);
end;

function __FileTimeToLocalFileTime(lpFileTime: PFileTime; var lpLocalFileTime: TFileTime): BOOL; cdecl;
begin
  Result := FileTimeToLocalFileTime(lpFileTime, lpLocalFileTime);
end;

{ Never actually called but still required by the linker }
function __GetFileSize(hFile: THandle; lpFileSizeHigh: Pointer): DWORD; cdecl;
begin
  Result := GetFileSize(hFile, lpFileSizeHigh);
end;

function __ReadFile(hFile: THandle; var Buffer; nNumberOfBytesToRead: DWORD;
  var lpNumberOfBytesRead: DWORD; lpOverlapped: POverlapped): BOOL; cdecl;
begin
  Result := ReadFile(hFile, Buffer, nNumberOfBytesToRead, lpNumberOfBytesRead, lpOverlapped);
end;

function __SetFileAttributesW(lpFileName: LPCWSTR; dwFileAttributes: DWORD): BOOL; cdecl;
begin
  Result := SetFileAttributesW(lpFileName, dwFileAttributes);
end;

function __SetFilePointer(hFile: THandle; lDistanceToMove: Longint;
  lpDistanceToMoveHigh: Pointer; dwMoveMethod: DWORD): DWORD; cdecl;
begin
  Result := SetFilePointer(hFile, lDistanceToMove, lpDistanceToMoveHigh, dwMoveMethod);
end;

function __SetFileTime(hFile: THandle;
  lpCreationTime, lpLastAccessTime, lpLastWriteTime: PFileTime): BOOL; cdecl;
begin
  Result := SetFileTime(hFile, lpCreationTime, lpLastAccessTime, lpLastWriteTime);
end;

function __WriteFile(hFile: THandle; const Buffer; nNumberOfBytesToWrite: DWORD;
  var lpNumberOfBytesWritten: DWORD; lpOverlapped: POverlapped): BOOL; cdecl;
begin
  Result := WriteFile(hFile, Buffer, nNumberOfBytesToWrite, lpNumberOfBytesWritten, lpOverlapped);
end;

function __CloseHandle(hObject: THandle): BOOL; cdecl;
begin
  Result := CloseHandle(hObject);
end;

function __GetLastError: DWORD; cdecl;
begin
  Result := GetLastError;
end;

function __LocalFree(hMem: HLOCAL): HLOCAL; cdecl;
begin
  Result := LocalFree(hMem);
end;

function __FormatMessageA(dwFlags: DWORD; lpSource: Pointer; dwMessageId: DWORD; dwLanguageId: DWORD;
  lpBuffer: LPSTR; nSize: DWORD; Arguments: Pointer): DWORD; cdecl;
begin
  Result := FormatMessageA(dwFlags, lpSource, dwMessageId, dwLanguageId, lpBuffer, nSize, Arguments);
end;

function __WideCharToMultiByte(CodePage: UINT; dwFlags: DWORD;
  lpWideCharStr: LPWSTR; cchWideChar: Integer; lpMultiByteStr: LPSTR;
  cchMultiByte: Integer; lpDefaultChar: LPCSTR; lpUsedDefaultChar: PBOOL): Integer; cdecl;
begin
  Result := WideCharToMultiByte(CodePage, dwFlags, lpWideCharStr, cchWideChar, lpMultiByteStr, cchMultiByte, lpDefaultChar, lpUsedDefaultChar);
end;

//https://github.com/rust-lang/compiler-builtins/issues/403
procedure __allshl; register; external 'ntdll.dll' name '_allshl';
procedure __aullshr; register; external 'ntdll.dll' name '_aullshr';
{$ELSE}
procedure __aullrem; stdcall; external 'ntdll.dll' name '_aullrem';
procedure __aulldiv; stdcall; external 'ntdll.dll' name '_aulldiv';
{$ENDIF}

function _memcpy(dest, src: Pointer; n: Cardinal): Pointer; cdecl;
begin
  Move(src^, dest^, n);
  Result := dest;
end;

function _memset(dest: Pointer; c: Integer; n: Cardinal): Pointer; cdecl;
begin
  FillChar(dest^, n, c);
  Result := dest;
end;

function _malloc(size: Cardinal): Pointer; cdecl;
begin
  Result := LZMAAllocFunc(nil, size);
end;

procedure _free(address: Pointer); cdecl;
begin
  LZMAFreeFunc(nil, address);
end;

function _wcscmp(string1, string2: PChar): Integer; cdecl;
begin
  Result := StrComp(string1, string2);
end;

procedure Log(const S: AnsiString);
begin
  if S <> '' then
    Setup.LoggingFunc.Log(UTF8ToString(S));
end;

var
  LogBuffer: AnsiString;

function __fputs(str: PAnsiChar; unused: Pointer): Integer; cdecl;

  function FindNewLine(const S: AnsiString): Integer;
  begin
    { 7zMain.c always sends #10 as newline but its call to FormatMessage can cause #13#10 anyway  }
    var N := Length(S);
    for var I := 1 to N do
      if CharInSet(S[I], [#13, #10]) then
        Exit(I);
    Result := 0;
  end;

begin
  try
    LogBuffer := LogBuffer + str;
    var P := FindNewLine(LogBuffer);
    while P <> 0 do begin
      Log(Copy(LogBuffer, 1, P-1));
      if (LogBuffer[P] = #13) and (P < Length(LogBuffer)) and (LogBuffer[P+1] = #10) then
        Inc(P);
      Delete(LogBuffer, 1, P);
      P := FindNewLine(LogBuffer);
    end;
    Result := 0;
  except
    Result := -1; { EOF }
  end;
end;

function SevenZipDecode(const FileName, DestDir: String;
  const FullPaths: Boolean): Integer;
begin
  var SaveCurDir := GetCurrentDir;
  if SetCurrentDir(DestDir) then
    Exit(-1);
  try
    LogBuffer := '';
    Result := IS_7zDec(PChar(FileName), FullPaths);
    if LogBuffer <> '' then
      Log(LogBuffer);
  finally
    SetCurrentDir(SaveCurDir);
  end;
end;

end.
