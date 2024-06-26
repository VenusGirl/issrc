unit ModernColors;

{
  Inno Setup
  Copyright (C) 1997-2024 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Colors for modern dark and light themes, with classic theme support
}

interface

uses
  Graphics;

type
  TThemeType = (ttModernLight, ttModernDark, ttClassic);
  TThemeColor = (tcFore, tcBack, tcToolBack, tcSelBack,
                 tcWordAtCursorOccurrenceBack, tcSelTextOccurrenceBack,
                 tcMarginFore, tcMarginBack, tcSplitterBack, tcBraceBack, tcIdentGuideFore,
                 tcRed, tcGreen, tcBlue, tcOrange, tcPurple, tcYellow, tcTeal, tcGray);

  TTheme = class
  private
    FType: TThemeType;
    function FGetDark: Boolean;
    function FGetModern: Boolean;
    function FGetColor(Color: TThemeColor): TColor;
  public
    property Colors[Color: TThemeColor]: TCOlor read FGetColor;
    property Dark: Boolean read FGetDark;
    property Modern: Boolean read FGetModern;
    property Typ: TThemeType read FType write FType;
  end;

implementation

function TTheme.FGetColor(Color: TThemeColor): TColor;
const
  { D = Dark, L = Light, M = Modern, C = Classic }

  DFore = $D6D6D6;           { VSCode Modern Dark, 2 tints lightened using color-hex.com }
  DBack = $1F1F1F;           { VSCode Modern Dark }
  DToolBack = $413E40;       { Monokai Pro }
  DSelBack = $764F1D;        { VSCode Modern Dark }
  DWACOBack = $4A4A4A;       { VSCode Modern Dark }
  DSTOBACK = $403A33;        { VSCode Modern Dark }
  DMarginFore = $716F71;     { Monokai Pro }
  DMarginBack = $413E40;     { Monokai Pro }
  DSplitterBack = $413E40;   { Monokai Pro }
  DBraceBack = DWACOBack;
  DIdentGuideFore = $716F71; { Monokai Pro }
  //Monokai Pro's dark control color: $221F22

  LFore = $3B3B3B;           { VSCode Modern Light }
  LBack = clWhite;
  LToolBack = clBtnFace;
  LSelBack = $FDD6A7;        { VSCode Modern Light }
  LWACOBack = $ECECEC;       { Inno Setup 5, 4 tints lightened using color-hex.com }
  LSTOBACK = $FEEAD3;        { VSCode Modern Light }
  LMarginFore = $716F71;     { Monokai Pro }
  LMarginBack = $F9FBFB;     { Monokai Pro }
  LSplitterBack = clBtnFace;
  LBraceBack = LWACOBack;
  LIdentGuideFore = clSilver;

  CFore = clBlack;
  CBack = clWhite;
  CToolBack = clBtnFace;
  CSelBack = $FDD6A7;        { VSCode Modern Light }
  CWACOBack = $ECECEC;       { Inno Setup 5, 4 tints lightened using color-hex.com }
  CSTOBACK = $FEEAD3;        { VSCode Modern Light }
  CMarginFore = clWindowText;
  CMarginBack = clBtnFace;
  CSplitterBack = clBtnFace;
  CBraceBack = CWACOBack;
  CIdentGuideFore = clSilver;

  { The Microsoft Azure DevOps work well as foreground colors on both dark and light backgrounds.
    Its red and blue also fit well with the colors used by Microsoft's VS Image Library. }

  MRed = $6353D6;            { Azure DevOps, 2 tints lightened using color-hex.com }
  MGreen = $339933;          { Azure DevOps }
  MBlue = $D47800;           { Azure DevOps }   
  MOrange = $5E88E5;         { Azure DevOps }
  MPurple = $A86292;         { Azure DevOps, 2 tints lightened using color-hex.com }
  MYellow = $1DCBF2;         { Azure DevOps }
  MTeal = $B0C94E;           { Visual Studio 2017 }
  MGray = $707070;           { Inno Setup 5 }

  CRed = clRed;
  CGreen = clGreen;
  CBlue = clBlue;
  COrange = clOlive;
  CPurple = $C00080;         { Inno Setup 5 }
  CYellow = clYellow;
  CTeal = clTeal;
  CGray = $707070;           { Inno Setup 5 }

  Colors: array [TThemeType, TThemeColor] of TColor = (
    (LFore, LBack, LToolBack, LSelBack, LWACOBack, LSTOBack, LMarginFore, LMarginBack, LSplitterBack, LBraceBack, LIdentGuideFore, MRed, MGreen, MBlue, MOrange, MPurple, MYellow, MTeal, MGray),
    (DFore, DBack, DToolBack, DSelBack, DWACOBack, DSTOBack, DMarginFore, DMarginBack, DSplitterBack, DBraceBack, DIdentGuideFore, MRed, MGreen, MBlue, MOrange, MPurple, MYellow, MTeal, MGray),
    (CFore, CBack, CToolBack, CSelBack, CWACOBack, CSTOBack, CMarginFore, CMarginBack, CSplitterBack, CBraceBack, CIdentGuideFore, CRed, CGreen, CBlue, COrange, CPurple, CYellow, CTeal, CGray)
  );
  
begin
  Result := Colors[FType, Color];
end;

function TTheme.FGetDark: Boolean;
begin
  Result := FType = ttModernDark;
end;

function TTheme.FGetModern: Boolean;
begin
  Result := FType <> ttClassic;
end;

end.
