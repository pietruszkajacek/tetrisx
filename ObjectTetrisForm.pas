{

   - ObjectTetrisX - Copyright (c) 2004-2005 by Pietruszka Jacek
                   Wszelkie prawa zastrzeżone.
}
unit ObjectTetrisForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  Menus, DXDraws, DXInput, DXClass, mxarrays;

const
  { Szerokosc i wysokosc czlonu figury w pikselach }
  WH_CzlonuFigury = 15;

  { Liczba wszystkich figur }
  LiczbaFigur = 7;

  { Maksymalna liczba czlonow z ilu moze skladac sie kazda figura }
  MaxLiczbaCzlonowFigury = 8;

  { Szerokosc planszy }
  SzerPlanszy = 16;

  { Wysokosc planszy }
  WysPlanszy = 20;

  { Wartosc jakiej odpowiada pusta (wolna) pozycja na planszy }
  PustaPozPlanszy = 0;

  { Szerokosc okna. W trybie pelnoekranowym rozdzielczosc pozioma ekranu }
  SzerEkranu = 640;

  { Wysokosc okna. W trybie pelnoekranowym rozdzielczosc pionowa ekranu }
  WysEkranu = 480;

  { Liczba kolorow w trybie pelnoekranowym }
  KoloryEkranu = 256;

  { Wspolrzedna pozioma planszy }
  XPlanszy = (SzerEkranu div 2) - ((SzerPlanszy * WH_CzlonuFigury) div 2);

  { Wspolrzedna pionowa planszy }
  YPlanszy = 50;

  { Liczba pozycji na liscie najlepszych }
  LiczbaNajlepszychHS = 5;

  { Nagłówek identyfikacyjny pliku z lista najlepszych .otx }
  IDNaglowekHS = #$03#$02#$81'ObjectTetrisX'#$00;

  { Nazwa pliku z lista najlepszych }
  NazwaPlikuHS = 'HighScores.otx';

  { Nazwa pliku z muzyka }
  NazwaPlikuMuzyka = 'trp2mars.s3m';

type
  { Tablica na przechowywanie wspolrzednych czlonu. 1-wsp. X, 2-wsp. Y }
  TTablicaXY = array[1..2] of Byte;

  { Tablica na definicje figur. Kazda figura sklada sie z 4 rzutow, kazdy rzut
    sklada sie z liczby czlonow okreslonych przez MaxLiczbaCzlonowFigury
  }
  TTablicaFigur = array[1..LiczbaFigur, 1..4, 1..MaxLiczbaCzlonowFigury] of TTablicaXY;

  { Plansza }
  TPlanszaGry = array[1..SzerPlanszy, 1..WysPlanszy] of TColor;

  { Rekord na dane figury }
  TRecFigura = record
    Nr, Obrot: Byte;
  end;

  {
  NazwyKlawiszy = (kbLewo, kbPrawo, kbGora, kbDol, kbSpace, kbF1, kbF3, kbF5, kbF7, kbESC);
  TBuforZnakow = set of NazwyKlawiszy;
  }

  { Poziomy trudnosci }
  TPoziomTrudnosci = (ptLatwy, ptNormalny, ptTrudny, ptSuperTrudny, ptExtreme);

  {
    Klasa abstrakcyjna TScena stanowi baze dla wszystkich scen jak i podscen.
    Podscena rozni sie od sceny tym, ze podczas zmiany scen nastepuje
    konczenie biezacej sceny, a przy zmianie na podscene biezaca scena zostaje
    "zawieszona" (koniecznosc powrocenia do sceny, z ktorej nastapilo wywolanie
    podsceny).
  }
  TScena = class(TObject)
  private
    { wskazanie na bufor ekranu }
    VRam: TDXDraw;

    { wskazanie na bufor klawiatury }
    VKeyboard: TDXInput;

    { konstruktor }
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput); virtual; abstract;

    { obsluga klawiatury w scenie }
    procedure ObslugaKlawiszy; virtual; abstract;

    {procedura rysujaca do bufora }
    procedure Rysuj; virtual; abstract;

    { kod wykonywanej sceny }
    procedure Wykonuj; virtual; abstract;

    { kod wykonywany przed startem sceny }
    procedure Start; virtual; abstract;

    { kod wykonywany przed zakonczeniem sceny }
    procedure Koniec; virtual; abstract;
  end;

  {
    Podscena potwierdzenia przerwania gry i wyjscia do glownego menu
  }
  TPodScenaConfirm = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
  end;

  {
    Podscena podswietlenia pelnej linii
  }
  TPodScenaFlashLine = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    PodswLinia: Byte;
    Tick: Integer;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
  end;

  {
    Scena MENU GLOWNEGO
  }
  TScenaMenu = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
  end;

  { Pozycje w scenie OPCJE }
  TPozOpcji = (poMuzyka, poPoziomTr, poFPS);

  {
    Scena opcji gry
  }
  TScenaOpcje = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    Muzyka: Boolean;
    PoziomTrudnosci: TPoziomTrudnosci;
    FPS: Boolean;
    Pozycja: TPozOpcji;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
  end;

  {
    Scena glowna (TETRIS)
  }
  TScenaGlowna = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    PoziomTr: TPoziomTrudnosci; { poziom trudnosci }
    Linie: Integer; { liczba pelnych linii }
    Cykl: Byte;
    PlanszaGry: TPlanszaGry; { plansza }
    Figura, PrevNastFigury: TRecFigura;
    XFigury, YFigury: Integer; { wspolrzedne figury wzgledem planszy }
    Tick: Integer; { czas jednego cyklu }
    RzeczOpozn: Integer;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
    procedure InitNowejGry;
    procedure InitNowegoCyklu;
    procedure RedukcjaLinii(RedukowanaLinia: Integer);
    procedure ZapisFiguryNaPlanszy(Figura: TRecFigura; X_Figury, Y_Figury: Integer);
    procedure RysujPlansze;
    procedure RysujFigure(NrFigury, ObrFigury, X, Y: Integer);
    procedure RysujRamkePlanszy;
    procedure RysujLogo;
    procedure RysujInfo;
    function SprWysKolizjiNaPlanszy(NrFigury, ObrFigury: Byte; X, Y: Integer): Boolean;
    function SprawdzObrot: Boolean;
    function SprawdzDol: Boolean;
    function SprawdzLewo: Boolean;
    function SprawdzPrawo: Boolean;
    function SprawdzPelneLinie: Byte;
  end;

  {
    Scena Game Over
  }
  TScenaGameOver = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    Tick: Integer;
    Mrug: Boolean;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
  end;

  {
    Scena Credits (Kredyty)
  }
  TScenaCredits = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
  end;

  {
    Rekord na pozycje listy najlepszych
  }
  THighScoresRec = record
    Ksywa: string[20];
    IleLinii: Integer;
  end;

  {
    THighScores (dynamiczna tablica oparta na klasie TBaseArray)
  }
  THighScores = class(TBaseArray)
  public
    constructor Create(itemcount, iSize: Integer ); virtual;
    procedure Sort(Compare: TCompareProc); virtual;
    procedure Exchange(Index1, Index2: Integer); virtual;
  end;

  {
    Scena Lista Najlepszych
  }
  TScenaListaNajlepszych = class(TScena)
  private
    VRam: TDXDraw;
    VKeyboard: TDXInput;
    Lista: THighScores;
    Dodawanie: Boolean;
    KsywaDodawana: string[20];
    constructor Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
    procedure ObslugaKlawiszy; override;
    procedure ObslugaKlawiszyWpis;
    procedure PrzypiszKlawisze;
    procedure Start; override;
    procedure Koniec; override;
    procedure Rysuj; override;
    procedure Wykonuj; override;
    procedure LadujListe;
    procedure ZapiszListe;
  end;

  {
    Klasa odpowiedzialna za obsluge poszczegolnych scen
  }
  TInicjatorScen = class(TObject)
  private
    ScenaBiezaca: TScena;
    PodScenaBiezaca: TScena;
    constructor Init;
    procedure InicjujScene(NowaScena: TScena);
    procedure InicjujPodScene(NowaPodScena: TScena);
    procedure PowrotZPodSceny;
    procedure WykonujKodSceny;
  end;

  (*
  TBuforKlaw = class(TObject)
  private
    DXInputPtr: TDXInput;
    FBufor: TBuforZnakow;
    procedure OdswiezBufor;
  public
    property Bufor: TBuforZnakow read FBufor;
    constructor Init(DXBufor: TDXInput);
  end;
  *)

  {
    Glowny formularz
  }
  TObjectTetrisX = class(TDXForm)
    DXDraw: TDXDraw;
    DXTimer: TDXTimer;
    DXInput: TDXInput;
    DXImageList: TDXImageList;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DXDrawFinalize(Sender: TObject);
    procedure DXDrawInitialize(Sender: TObject);
    procedure DXTimerTimer(Sender: TObject; LagCount: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DXDrawInitializing(Sender: TObject);
  private
    //BuforKlaw: TBuforKlaw;

    { Inicjator Scen }
    InicjatorScen: TInicjatorScen;
    { Sceny }
    ScenaMenu: TScenaMenu;
    ScenaOpcje: TScenaOpcje;
    ScenaGlowna: TScenaGlowna;
    ScenaGameOver: TScenaGameOver;
    ScenaCredits: TScenaCredits;
    ScenaListaNajlepszych: TScenaListaNajlepszych;
    { Podsceny }
    PodScenaConfirm: TPodScenaConfirm;
    PodScenaFlashLine: TPodScenaFlashLine;

//    procedure Inicjalizacja;
    procedure CzyscBuforKlawiatury;
    procedure FPSView;
    procedure UstawPaleteKolorow;
    procedure WyjscieZGry;
    procedure InitMusic;
    procedure PrzypiszKlawisze;
  end;

var
  ObjectTetrisX: TObjectTetrisX;

implementation

{$R *.DFM}

uses Bass, DIB;


{ --- Definicje typow --------- }


{ --- Zmienne, literaly zmienne --------- }

var
  { Tablica z opisem figur, pola 4x4 }
  Figury: TTablicaFigur =
  (
    (
      ( (2,1),(2,2),(2,3),(2,4),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,3),(2,3),(3,3),(4,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (3,1),(3,2),(3,3),(3,4),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,2),(2,2),(3,2),(4,2),(0,0),(0,0),(0,0),(0,0) )
    ),
    (
      ( (2,2),(2,3),(3,1),(3,2),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,2),(2,2),(2,3),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,3),(2,4),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(3,2),(3,3),(4,3),(0,0),(0,0),(0,0),(0,0) )
    ),
    (
      ( (2,1),(2,2),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,3),(2,2),(2,3),(3,2),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(3,3),(3,4),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,3),(3,2),(3,3),(4,2),(0,0),(0,0),(0,0),(0,0) )
    ),
    (
      ( (2,1),(2,2),(2,3),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,3),(2,3),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(3,2),(3,3),(3,4),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(3,2),(4,2),(0,0),(0,0),(0,0),(0,0) )
    ),
    (
      ( (2,3),(3,1),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,2),(2,2),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(2,4),(3,2),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(3,3),(4,3),(0,0),(0,0),(0,0),(0,0) )
    ),
    (
      ( (2,1),(2,2),(2,3),(3,2),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,2),(2,1),(2,2),(3,2),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,2),(2,1),(2,2),(2,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (1,2),(2,2),(2,3),(3,2),(0,0),(0,0),(0,0),(0,0) )
    ),
    (
      ( (2,2),(2,3),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) ),
      ( (2,2),(2,3),(3,2),(3,3),(0,0),(0,0),(0,0),(0,0) )
    )
  );

  { Poziomy trudnosci. Czas w [ms] przypadajacy na jeden cykl }
  PoziomyTrOpoz: array[TPoziomTrudnosci] of Integer = (500, 300, 200, 100, 50);

  { Nazwy poziomow trudnosci }
  NazwyPoziomowTr: array[TPoziomTrudnosci] of ShortString =
    ('Prosty', 'Normalny', 'Trudny', 'Super trudny', 'Extreme!');

  { Kolory figur }
  KoloryFigur: array[1..LiczbaFigur] of TColor =
    ($00919276, $00ffffff, $00FEE2AE, $00AAAE8A, $00CDD4B9, $00666666, $00999999);

{
  Funkcja porownujaca przy sortowaniu
}
function FunkcjaPorownania(var item1, item2): Integer;
var
  ItemHS1, ItemHS2: THighScoresRec;
begin
  {
    CompareProc should compare the two items given as parameters and return a
    value less than 0 if item1 comes before item2, return a value greater than
    0 if item1 comes after item2, and return 0 if item1 is the same as item2.

    FunkcjaPorownania powinna porownac dwie pozcje listy (obiekty) dane jako
    parametry (item1, item2) i zwrocic wartosc mniejsza od 0 jesli item1
    poprzedza item2, zwrocic wartosc wieksza od 0 jesli item1 nastepuje po item2
    i zwrocic 0 jesli item1 jest takie samo jak item2 w danej relacji porownania.
  }

  ItemHS1 := THighScoresRec(item1);
  ItemHS2 := THighScoresRec(item2);

  if ItemHS1.IleLinii < ItemHS2.IleLinii
    then  Result := - 1
  else if ItemHS1.IleLinii > ItemHS2.IleLinii
    then  Result := 1
  else if ItemHS1.Ksywa > ItemHS2.Ksywa then
    Result := - 1
  else if ItemHS1.Ksywa < ItemHS2.Ksywa then
    Result := 1
  else Result := 0;
end;

var
  mods: HMUSIC;

procedure TObjectTetrisX.InitMusic;

  procedure Error(msg: string);
  var
	  s: string;
  begin
	  s := msg + #13#10 + '(Error code: ' + IntToStr(BASS_ErrorGetCode) + ')';
	  MessageBox(Handle, PChar(s), 'Error', MB_ICONERROR or MB_OK);
  end;

begin
	// Ensure BASS 2.1 was loaded
	if BASS_GetVersion() <> DWORD(MAKELONG(2,1)) then begin
		Error('BASS version 2.1 was not loaded!');
		Halt;
	end;

	// Initialize audio - default device, 44100hz, stereo, 16 bits
	if not BASS_Init(1, 44100, 0, Handle, nil) then
		Error('Error initializing audio!');

  mods := BASS_MusicLoad(False, PChar(NazwaPlikuMuzyka), 0, 0, BASS_MUSIC_RAMP or
    BASS_SAMPLE_LOOP, 0);

	if not (mods <> 0) then
  begin
    Error('Error loading music!');
    Halt;
  end;

  if not BASS_ChannelPlay(mods, True) then
    Error('Error playing music!');
end;

{
  Czyszczenie bufora klawiatury
}
procedure TObjectTetrisX.CzyscBuforKlawiatury;
begin
  DXInput.States := [];
end;

(*
constructor TBuforKlaw.Init(DXBufor: TDXInput);
begin
  inherited Create;
  DXInputPtr := DXBufor;
end;

procedure TBuforKlaw.OdswiezBufor;
var
  i: Byte;
begin
  with DXInputPtr do
  begin
    Update; //odswiez z DXInput

    for i := 0 to sizeof(TBuforZnakow) do
      if TDXInputState(i) in States then
        include(FBufor, NazwyKlawiszy(i));
  end;
end;
*)

{
  Inicjator scen
}
constructor TInicjatorScen.Init;
begin
  inherited Create;
  ScenaBiezaca := nil;
  PodScenaBiezaca := nil;
end;

procedure TInicjatorScen.InicjujScene(NowaScena: TScena);
begin
  if ScenaBiezaca <> nil then ScenaBiezaca.Koniec;

  ObjectTetrisX.CzyscBuforKlawiatury;

  PodScenaBiezaca := nil;
  ScenaBiezaca := NowaScena;
  ScenaBiezaca.Start;
end;

procedure TInicjatorScen.InicjujPodScene(NowaPodScena: TScena);
begin
  ObjectTetrisX.CzyscBuforKlawiatury;

  PodScenaBiezaca := NowaPodScena;
  PodScenaBiezaca.Start;
end;

procedure TInicjatorScen.WykonujKodSceny;
begin
  if PodScenaBiezaca = nil
    then ScenaBiezaca.Wykonuj
    else PodScenaBiezaca.Wykonuj;
end;

procedure TInicjatorScen.PowrotZPodSceny;
begin
  PodScenaBiezaca.Koniec;

  ObjectTetrisX.CzyscBuforKlawiatury;

  PodScenaBiezaca := nil;
end;

{
  Pod scena sceny glownej. (Potwierdzenie wyjscia z gry)
}
constructor TPodScenaConfirm.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
end;

procedure TPodScenaConfirm.Start;
begin
;
end;

procedure TPodScenaConfirm.Koniec;
begin
;
end;

procedure TPodScenaConfirm.Rysuj;
var
  s: String;
begin
  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;

    s := 'Czy chcesz zakonczyc gre? ( T )ak / ( N )ie.';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 450, s);

    Release;
  end;
end;

procedure TPodScenaConfirm.Wykonuj;
begin
  ObslugaKlawiszy;
  Rysuj;
end;

procedure TPodScenaConfirm.ObslugaKlawiszy;
begin
  with ObjectTetrisX do
    with VKeyboard do
    begin
      if isButton8 in States
        then InicjatorScen.InicjujScene(ScenaMenu);
      if (isButton9 in States) or (isButton3 in States) then
        InicjatorScen.PowrotZPodSceny;
    end;
end;

{
  Pod scena sceny glownej. (Flash pelnej linii na planszy)
}
constructor TPodScenaFlashLine.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
end;

procedure TPodScenaFlashLine.Start;
begin
  PodswLinia := ObjectTetrisX.ScenaGlowna.SprawdzPelneLinie;
  Tick := GetTickCount;
end;

procedure TPodScenaFlashLine.Koniec;
begin
;
end;

procedure TPodScenaFlashLine.Rysuj;
var
  i, j: Byte;
  rx1, rx2, ry1, ry2: Integer;
begin
  with ObjectTetrisX.ScenaGlowna do
  begin
    { Rysuj plansze }
    for i := 1 to SzerPlanszy do
      for j := 1 to WysPlanszy do
      begin
        rx1 := (i-1) * WH_CzlonuFigury + XPlanszy;
        ry1 := (j-1) * WH_CzlonuFigury + YPlanszy;
        rx2 := rx1 + WH_CzlonuFigury;
        ry2 := ry1 + WH_CzlonuFigury;

        with VRam.Surface.Canvas do
        begin
          Brush.Style := bsSolid;

          if j = PodswLinia then
          begin
            Brush.Color := clWhite;
            Pen.Color := Brush.Color;//Random(256);//clWhite;
          end
          else
          begin
            Brush.Color := PlanszaGry[i, j];
            Pen.Color := PlanszaGry[i, j];
          end;
          Rectangle(rx1, ry1, rx2, ry2);
        end;
      end;
    RysujRamkePlanszy;
    VRam.Surface.Canvas.Release;
  end;
end;

procedure TPodScenaFlashLine.Wykonuj;
begin
  Rysuj;
  if Abs(GetTickCount - Tick) >= 75 then
  begin
    with ObjectTetrisX do
    begin
      ScenaGlowna.RedukcjaLinii(PodswLinia);
      if ScenaGlowna.SprawdzPelneLinie = 0
        then InicjatorScen.PowrotZPodSceny
        else PodswLinia := ObjectTetrisX.ScenaGlowna.SprawdzPelneLinie;
    end;
    Tick := GetTickCount;
  end;
end;

procedure TPodScenaFlashLine.ObslugaKlawiszy;
begin
  with ObjectTetrisX do
    with VKeyboard do
    begin
    ;
    end;
end;

{
  Scena menu
}
constructor TScenaMenu.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
end;

procedure TScenaMenu.Start;
begin
  ;
end;

procedure TScenaMenu.Koniec;
begin
;
end;

procedure TScenaMenu.Rysuj;
var
  s: string;
begin
  VRam.Surface.FillRect(Rect(0, 0, SzerEkranu, WysEkranu), 0);

  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;

    s := 'Menu glowne:';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 50, s);

    s := '( F1 ) - Start gry';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 70, s);

    s := '( F3 ) - Opcje gry';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 90, s);

    s := '( F5 ) - Kredyty (Credits)';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 110, s);

    s := '( F7 ) - Lista najlepszych';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 130, s);

    s := '( ESC ) - Powrot do systemu';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 150, s);

    s := '>> ObjectTetrisX <<';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 280, s);

    Font.Size := 9;

    s := 'Version 1.0';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 300, s);

    s := 'Copyright '#$A9' 2004-2005 by Pietruszka Jacek';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 315, s);

    s := 'Wszelkie prawa zastrzezone';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 330, s);

    Release;
  end;
  ObjectTetrisX.ScenaGlowna.RysujLogo;
end;

procedure TScenaMenu.Wykonuj;
begin
  Rysuj;
  ObslugaKlawiszy;
end;

procedure TScenaMenu.ObslugaKlawiszy;
begin
  with ObjectTetrisX do
    with VKeyboard do
    begin
      if isButton4 in States { F1 }
        then InicjatorScen.InicjujScene(ScenaGlowna);
      if isButton5 in States { F3 }
        then InicjatorScen.InicjujScene(ScenaOpcje);
      if isButton6 in States { F5 }
        then InicjatorScen.InicjujScene(ScenaCredits);
      if isButton7 in States { F7 }
        then InicjatorScen.InicjujScene(ScenaListaNajlepszych);
      if isButton3 in States then
      { ESC }
      begin
        ScenaListaNajlepszych.ZapiszListe;
        WyjscieZGry;
      end;
    end;
end;

{
  Scena opcje gry
}
constructor TScenaOpcje.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
  Muzyka := True;
  PoziomTrudnosci := ptLatwy;
  FPS := False;
end;

procedure TScenaOpcje.Start;
begin
;
end;

procedure TScenaOpcje.Koniec;
begin
;
end;

procedure TScenaOpcje.Rysuj;

  procedure UstawKolor(po: TPozOpcji);
  begin
    with VRam.Surface.Canvas.Font do
      if Pozycja = po
        then Color := clYellow
        else Color := clWhite;
  end;

var
  s: string;
begin
  VRam.Surface.FillRect(Rect(0, 0, SzerEkranu, WysEkranu), 0);

  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;

    s := 'Opcje:';

    TextOut((SzerEkranu-TextWidth(s)) div 2, 50, s);

    UstawKolor(poMuzyka);
    s := 'Muzyka: ';
    if Muzyka
      then s := s + 'TAK'
      else s := s + 'NIE';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 70, s);

    UstawKolor(poPoziomTr);
    s := 'Poziom trudnosci: ' + NazwyPoziomowTr[PoziomTrudnosci];
    TextOut((SzerEkranu-TextWidth(s)) div 2, 90, s);

    UstawKolor(poFPS);
    s:= 'FPS: ';
    if FPS
      then s := s + 'TAK'
      else s := s + 'NIE';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 110, s);

    Release;
  end;
  ObjectTetrisX.ScenaGlowna.RysujLogo;
end;

procedure TScenaOpcje.Wykonuj;
begin
  ObslugaKlawiszy;
  Rysuj;
end;

procedure TScenaOpcje.ObslugaKlawiszy;
begin
  with VKeyboard do
  begin
    if isDown in States then
    begin
      if Pozycja < High(TPozOpcji)
        then Inc(Pozycja)
        else Pozycja := Low(TPozOpcji);
      States := States - [isDown];
    end;

    if isUp in States then
    begin
      if Pozycja > Low(TPozOpcji)
        then Dec(Pozycja)
        else Pozycja := High(TPozOpcji);
      States := States - [isUp];
    end;

    if isButton2 in States then
    begin
      case Pozycja of
        poMuzyka:
        begin
          Muzyka := not Muzyka;

          if not Muzyka then BASS_ChannelStop(mods)
          else BASS_ChannelPlay(mods, False);
        end;

        poPoziomTr:
        begin
          if PoziomTrudnosci < High(TPoziomTrudnosci)
            then Inc(PoziomTrudnosci)
            else PoziomTrudnosci := Low(TPoziomTrudnosci);
        end;

        poFPS: FPS := not FPS;
      end;
      States := States - [isButton2];
    end;

    with ObjectTetrisX do
      if isButton3 in States then InicjatorScen.InicjujScene(ScenaMenu);
  end;
end;

{
  Scena lista najlepszych
}
constructor TScenaListaNajlepszych.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;

  VRam := DXDraw;
  VKeyboard := DXInput;
  Lista := THighScores.Create(LiczbaNajlepszychHS, sizeof(THighScoresRec));
  Lista.SortOrder := TSDESCENDING;
  Dodawanie := False;
end;

procedure TScenaListaNajlepszych.Start;
begin
  if Dodawanie then
  begin
    KsywaDodawana := '';
    PrzypiszKlawisze;
  end;
end;

procedure TScenaListaNajlepszych.PrzypiszKlawisze;
var
  Klawisze: TKeyAssignList;
begin
  Klawisze[isButton1, 0]  := Ord('A');
  Klawisze[isButton2, 0]  := Ord('B');
  Klawisze[isButton3, 0]  := Ord('C');
  Klawisze[isButton4, 0]  := Ord('D');
  Klawisze[isButton5, 0]  := Ord('E');
  Klawisze[isButton6, 0]  := Ord('F');
  Klawisze[isButton7, 0]  := Ord('G');
  Klawisze[isButton8, 0]  := Ord('H');
  Klawisze[isButton9, 0]  := Ord('I');
  Klawisze[isButton10, 0] := Ord('J');
  Klawisze[isButton11, 0] := Ord('K');
  Klawisze[isButton12, 0] := Ord('L');
  Klawisze[isButton13, 0] := Ord('M');
  Klawisze[isButton14, 0] := Ord('N');
  Klawisze[isButton15, 0] := Ord('O');
  Klawisze[isButton16, 0] := Ord('P');
  Klawisze[isButton17, 0] := Ord('Q');
  Klawisze[isButton18, 0] := Ord('R');
  Klawisze[isButton19, 0] := Ord('S');
  Klawisze[isButton20, 0] := Ord('T');
  Klawisze[isButton21, 0] := Ord('U');
  Klawisze[isButton22, 0] := Ord('V');
  Klawisze[isButton23, 0] := Ord('W');
  Klawisze[isButton24, 0] := Ord('X');
  Klawisze[isButton25, 0] := Ord('Y');
  Klawisze[isButton26, 0] := Ord('Z');
  Klawisze[isButton27, 0] := VK_SPACE;
  Klawisze[isButton28, 0] := VK_BACK;
  Klawisze[isButton29, 0] := VK_ESCAPE;
  Klawisze[isButton30, 0] := VK_RETURN;

  VKeyboard.Keyboard.KeyAssigns := Klawisze;
end;

procedure TScenaListaNajlepszych.Koniec;
begin
;
end;

var
  Poz: array[0..LiczbaNajlepszychHS - 1] of Integer =
  (70, 85, 100, 115, 130);

procedure TScenaListaNajlepszych.Rysuj;
var
  s: string;
  ItemHS: THighScoresRec;
  i: Integer;
begin
  VRam.Surface.FillRect(Rect(0, 0, SzerEkranu, WysEkranu), 0);

  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;

    s := 'Lista najlepszych:';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 50, s);

    for i := 0 to Lista.Count - 1 do
    begin
      Lista.GetItem(i, ItemHS);
      s := ItemHS.Ksywa + ': ' + IntToStr(ItemHS.IleLinii);
      TextOut((SzerEkranu-TextWidth(s)) div 2, Poz[i], s);
    end;

    if Dodawanie then
    begin
      s := KsywaDodawana + '_';
      TextOut((SzerEkranu-TextWidth(s)) div 2, 200, s);
    end;

    Release;
  end;
  ObjectTetrisX.ScenaGlowna.RysujLogo;
end;

procedure TScenaListaNajlepszych.Wykonuj;
begin
  ObslugaKlawiszy;
  Rysuj;
end;

{
  Obsluga klawiatury podczas wpisu do listy najlepszych
}
procedure TScenaListaNajlepszych.ObslugaKlawiszyWpis;
var
  itemHS: THighScoresRec;
begin
  with VKeyboard do
  begin
    if isButton1 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'A';
      States := States - [isButton1];
    end;
    if isButton2 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'B';
      States := States - [isButton2];
    end;
    if isButton3 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'C';
      States := States - [isButton3];
    end;
    if isButton4 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'D';
      States := States - [isButton4];
    end;
    if isButton5 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'E';
      States := States - [isButton5];
    end;
    if isButton6 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'F';
      States := States - [isButton6];
    end;
    if isButton7 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'G';
      States := States - [isButton7];
    end;
    if isButton8 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'H';
      States := States - [isButton8];
    end;
    if isButton9 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'I';
      States := States - [isButton9];
    end;
    if isButton10 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'J';
      States := States - [isButton10];
    end;
    if isButton11 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'K';
      States := States - [isButton11];
    end;
    if isButton12 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'L';
      States := States - [isButton12];
    end;
    if isButton13 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'M';
      States := States - [isButton13];
    end;
    if isButton14 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'N';
      States := States - [isButton14];
    end;
    if isButton15 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'O';
      States := States - [isButton15];
    end;
    if isButton16 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'P';
      States := States - [isButton16];
    end;
    if isButton17 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'Q';
      States := States - [isButton17];
    end;
    if isButton18 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'R';
      States := States - [isButton18];
    end;
    if isButton19 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'S';
      States := States - [isButton19];
    end;
    if isButton20 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'T';
      States := States - [isButton20];
    end;
    if isButton21 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'U';
      States := States - [isButton21];
    end;
    if isButton22 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'V';
      States := States - [isButton3];
    end;
    if isButton23 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'W';
      States := States - [isButton23];
    end;
    if isButton24 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'X';
      States := States - [isButton24];
    end;
    if isButton25 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'Y';
      States := States - [isButton25];
    end;
    if isButton26 in States then
    begin
      KsywaDodawana := KsywaDodawana + 'Z';
      States := States - [isButton26];
    end;
    //Spacja
    if isButton27 in States then
    begin
      KsywaDodawana := KsywaDodawana + ' ';
      States := States - [isButton27];
    end;
    //Backspace
    if isButton28 in States then
    begin
      KsywaDodawana := Copy(KsywaDodawana, 1, Length(KsywaDodawana)-1);
      States := States - [isButton28];
    end;
    //Escape
    if isButton29 in States then
    begin
      Dodawanie := False;
      States := States - [isButton29];

      ObjectTetrisX.PrzypiszKlawisze;
    end;
    //Enter
    if isButton30 in States then
    begin
      {
        Dodanie do listy nowej pozycji
      }
      if KsywaDodawana <> '' then
      begin
        Dodawanie := False;
        itemHS.Ksywa := KsywaDodawana;
        itemHS.IleLinii := ObjectTetrisX.ScenaGlowna.Linie;

        Lista.PutItem(Lista.Count - 1, itemHS);
        Lista.Sort(FunkcjaPorownania);

        States := States - [isButton30];
        ObjectTetrisX.PrzypiszKlawisze;
      end;
    end;
  end;
end;

procedure TScenaListaNajlepszych.ObslugaKlawiszy;
begin
  if Dodawanie
    then ObslugaKlawiszyWpis
    else
      with ObjectTetrisX do
        with VKeyboard do
          if isButton3 in States then InicjatorScen.InicjujScene(ScenaMenu);
end;

procedure TScenaListaNajlepszych.LadujListe;
var
  OpenLista: File;
  Naglowek: array[0..16] of Char;
  i, Bezp: Integer;
  ItemHS: THighScoresRec;
begin



end;

{
  Zapisuje liste najlepszych do pliku
}
procedure TScenaListaNajlepszych.ZapiszListe;
var
  SaveLista: File;
  i, Bezp: Integer;
  ItemHS: THighScoresRec;
begin
  try
    AssignFile(SaveLista, NazwaPlikuHS);
    Rewrite(SaveLista, 1);
    try
      { Zapisuje nagłówek }
      BlockWrite(SaveLista, IDNaglowekHS, Length(IDNaglowekHS), Bezp);

      for i := 0 to LiczbaNajlepszychHS - 1 do
      begin
        Lista.GetItem(i, ItemHS);
        BlockWrite(SaveLista, ItemHS, SizeOf(THighScoresRec), Bezp);
      end;

      finally
        CloseFile(SaveLista);
    end;
    except
    on E: EInOutError do
    begin
      Application.MessageBox(PChar(SysErrorMessage(E.ErrorCode)), 'ObjectTetrisX - Błąd Wejścia/Wyjścia (I/O).', MB_ICONERROR);
      //ObjectTetrisX.WyjscieZGry;
      Application.Terminate;
    end;
  end;
end;

{
  THighScores
}

{
  Procedura sortujaca w oparciu o algorytm sortowania babelkowego. Algorytm z
  ksiazki Algorytmy + struktury danych = programy, Niklaus Wirth.
}
procedure THighScores.Sort(Compare: TCompareProc);
var
 i, j: Integer;
 tminus1, t: THighScoresRec;
begin
  for i := 1 to Count - 1 do
  begin
    for j := Count - 1 downto i do
    begin
      GetItem(j - 1, tminus1);
      GetItem(j, t);

      case SortOrder of
        TSASCENDING  : if Compare(tminus1, t) = 1 then Exchange(j, j - 1);
        TSDESCENDING : if Compare(tminus1, t) = - 1 then Exchange(j, j - 1);
        TSNONE       : ;
      end;
    end;
  end;
end;

{
  Konstruktor
}
constructor THighScores.Create(itemcount, iSize: Integer);
begin
  inherited Create(itemcount, iSize);
end;

{
  Zamiana miejscami Index1 <---> Index2
}
procedure THighScores.Exchange(Index1, Index2: Integer);
var
  item1, item2: THighScoresRec;
begin
  if (Index1 > Count - 1) or (Index2 > Count - 1) then Exit;

  GetItem(Index1, item1);
  GetItem(Index2, item2);

  PutItem(Index2, item1);
  PutItem(Index1, item2);
end;

{
  Scena Game Over
}
constructor TScenaGameOver.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
end;

procedure TScenaGameOver.Start;
begin
  Tick := GetTickCount;
end;

procedure TScenaGameOver.Koniec;
begin
;
end;

procedure TScenaGameOver.Rysuj;
var
  s: string;
begin
  VRam.Surface.FillRect(Rect(0, 0, SzerEkranu, WysEkranu), 0);

  with ObjectTetrisX.ScenaGlowna do
  begin
    RysujPlansze;
    RysujRamkePlanszy;
  end;

  with VRam.Surface.Canvas do
  begin

    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;

    s := 'K o n i e c G R Y';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 242, s);

    if Mrug then
    begin
      Font.Size := 9;
      s := '( Spacja )';
      TextOut((SzerEkranu-TextWidth(s)) div 2, 258, s);
    end;

    Release;
  end;
  ObjectTetrisX.ScenaGlowna.RysujLogo;
end;

procedure TScenaGameOver.Wykonuj;
begin
  Rysuj;
  ObslugaKlawiszy;

  if Abs(GetTickCount - Tick) >= 750 then
  begin
    Mrug := not Mrug;
    Tick := GetTickCount;
  end;

end;

procedure TScenaGameOver.ObslugaKlawiszy;
var
  itemHS: THighScoresRec;
begin
  with ObjectTetrisX do
    with VKeyboard do
      { Space }
      if isButton1 in States then
      begin
        ScenaListaNajlepszych.Lista.GetItem(LiczbaNajlepszychHS - 1, itemHS);

        if ScenaGlowna.Linie > itemHS.IleLinii
          then ScenaListaNajlepszych.Dodawanie := True
          else ScenaListaNajlepszych.Dodawanie := False;

        InicjatorScen.InicjujScene(ScenaListaNajlepszych);
      end;
end;

{
  Scena Credits
}
constructor TScenaCredits.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
end;

procedure TScenaCredits.Start;
begin
  ;
end;

procedure TScenaCredits.Koniec;
begin
;
end;

procedure TScenaCredits.Rysuj;
var
  s: string;
  Logo: TPictureCollectionItem;
begin
  VRam.Surface.FillRect(Rect(0, 0, SzerEkranu, WysEkranu), 0);

  with ObjectTetrisX do
  begin
    Logo := DXImageList.Items.Find('PBDbig');
    Logo.Draw(DXDraw.Surface, (SzerEkranu - Logo.Width) div 2, 195, 0);
  end;

  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;

    s := 'Credits (Kredyty):';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 50, s);

    Font.Size := 9;

    s := 'Code, design and logo by Pietruszka Jacek';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 70, s);

    s := 'DelphiX powered by the official JEDI DirectX headers by Hiroyuki Hori';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 85, s);

    s := 'BASS Sound System 2.1.(0.4) by Ian Luck';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 100, s);

    s := 'Music by Torben Hansen (Metal of Vibrants)';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 115, s);

    s := 'Powrot do menu ( ESC )';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 140, s);

    Font.Size := 10;

    s := '>> ObjectTetrisX <<';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 280, s);

    Font.Size := 9;

    s := 'Version 1.0';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 300, s);

    s := 'Copyright '#$A9' 2004-2005 by Pietruszka Jacek';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 315, s);

    s := 'Wszelkie prawa zastrzezone';
    TextOut((SzerEkranu-TextWidth(s)) div 2, 330, s);

    Release;
  end;
  ObjectTetrisX.ScenaGlowna.RysujLogo;
end;

procedure TScenaCredits.Wykonuj;
begin
  Rysuj;
  ObslugaKlawiszy;
end;

procedure TScenaCredits.ObslugaKlawiszy;
begin
  with ObjectTetrisX do
    with VKeyboard do
    begin
      if isButton3 in States { ESC }
        then InicjatorScen.InicjujScene(ScenaMenu);
    end;
end;

{
  Scena glowna gry
}
constructor TScenaGlowna.Init(var DXDraw: TDXDraw; var DXInput: TDXInput);
begin
  inherited Create;
  VRam := DXDraw;
  VKeyboard := DXInput;
end;

procedure TScenaGlowna.ObslugaKlawiszy;
begin
  with VKeyboard do
  begin
    if isUp in States then
    begin
      if SprawdzObrot then
        if Figura.Obrot = 4
          then Figura.Obrot := 1
          else Figura.Obrot := Figura.Obrot + 1;
      States := States - [isUp];
    end;

    if isDown in States then
    begin
      while SprawdzDol do
        YFigury := YFigury + 1;
        States := States - [isDown];
    end;

    if isLeft in States then
    begin
      if SprawdzLewo then XFigury := XFigury - 1;
        States := States - [isLeft];
    end;

    if isRight in States then
    begin
      if SprawdzPrawo then XFigury := XFigury + 1;
        States := States - [isRight];
    end;

    with ObjectTetrisX do
      if isButton3 in States then InicjatorScen.InicjujPodScene(PodScenaConfirm);
  end;
end;

procedure TScenaGlowna.Start;
begin
  InitNowejGry;
  Tick := GetTickCount;
end;

procedure TScenaGlowna.Koniec;
begin
;
end;

procedure TScenaGlowna.Rysuj;
begin
  with VRam.Surface do
  begin
    { Czysc ekran }
    FillRect(Rect(0, 0, SzerEkranu, WysEkranu), 0);

    { Rysuj plansze }
    RysujPlansze;

    { Rysuj figure }
    RysujFigure(Figura.Nr, Figura.Obrot, XFigury, YFigury);

    { Rysuj preview nastepnej figury }
    RysujFigure(PrevNastFigury.Nr, PrevNastFigury.Obrot, -8, 3);

    RysujInfo;

    { Rysuj logo }
    RysujLogo;

    { Rysuj ramke planszy }
    RysujRamkePlanszy;
  end;
end;

procedure TScenaGlowna.Wykonuj;
var
  itemHS: THighScoresRec;
begin
  Rysuj;
  if SprWysKolizjiNaPlanszy(Figura.Nr, Figura.Obrot, XFigury, YFigury) then
  begin
    with ObjectTetrisX do
    begin
      InicjatorScen.InicjujScene(ScenaGameOver);
    end;
  end
  else
  begin
    ObslugaKlawiszy;

    if Abs(GetTickCount - Tick) >= PoziomyTrOpoz[PoziomTr] then
    begin
      RzeczOpozn := Abs(GetTickCount - Tick);
      if SprWysKolizjiNaPlanszy(Figura.Nr, Figura.Obrot, XFigury, YFigury + 1) then
      begin
        { Zapis figury na planszy }
        ZapisFiguryNaPlanszy(Figura, XFigury, YFigury);

        { Sprawdzenie czy sa jakies pelne linie }
        if SprawdzPelneLinie <> 0 then
        begin
          with ObjectTetrisX do
          begin
            InicjatorScen.InicjujPodScene(PodScenaFlashLine);
          end;
        end;
        { Nowy cykl }
        InitNowegoCyklu;
      end
      { Figura o jedna pozycje w dol }
      else Inc(YFigury);
      Tick := GetTickCount;
    end;
  end;
end;

procedure TScenaGlowna.InitNowejGry;
{
  Inicjalizacja przed rozpoczeciem nowej gry
}
var
  k, w: Byte;
begin
  { Czyszczenie planszy }
  for k := 1 to SzerPlanszy do
    for w := 1 to WysPlanszy do
      PlanszaGry[k, w] := PustaPozPlanszy;

  PoziomTr := ObjectTetrisX.ScenaOpcje.PoziomTrudnosci;

  Linie := 0;
  Cykl := PoziomyTrOpoz[PoziomTr];

  Figura.Nr := Random(LiczbaFigur)+1;
  Figura.Obrot := 1;
  PrevNastFigury.Nr := Random(LiczbaFigur)+1;
  PrevNastFigury.Obrot := 1;

  XFigury := (SzerPlanszy div 2) - 1;
  YFigury := 1;
end;

function TScenaGlowna.SprWysKolizjiNaPlanszy(NrFigury, ObrFigury: Byte; X, Y: Integer): Boolean;
{
  Funkcja zwraca wartosc FALSE gdy dana figure mozna umiejscowic na danej pozycji
  (X, Y)
}
var
  i, X_CzlonuFigury, Y_CzlonuFigury: Byte;
  wzgX, wzgY: Integer; //wartosci wzgledem planszy
begin
  Result := False;
  for i := 1 to MaxLiczbaCzlonowFigury do
    if Figury[NrFigury, ObrFigury, i, 1] <> PustaPozPlanszy then
    begin
      X_CzlonuFigury := Figury[NrFigury, ObrFigury, i, 1];
      Y_CzlonuFigury := Figury[NrFigury, ObrFigury, i, 2];

      wzgX := X+X_CzlonuFigury-1;
      wzgY := Y+Y_CzlonuFigury-1;

      if (PlanszaGry[wzgX, wzgY] <> PustaPozPlanszy) or (wzgY > WysPlanszy) or
        (wzgX > SzerPlanszy) or (wzgX < 1) then
        begin
          Result := True;
          Break;
        end;
    end;
end;

function TScenaGlowna.SprawdzObrot: Boolean;
{
  Funkcja zwraca wartosc FALSE gdy obrot biezacej figury (Figura) nie jest mozliwy,
  a TRUE w przeciwnym (bezkolizyjnym) wypadku
}
var
  Obrot: Byte;
begin
  Result := True;
  if Figura.Obrot = 4
    then Obrot := 1
    else Obrot := Figura.Obrot + 1;

  if SprWysKolizjiNaPlanszy(Figura.Nr, Obrot, XFigury, YFigury)
    then Result := False;
end;

function TScenaGlowna.SprawdzDol: Boolean;
{
  Funkcja zwraca wartosc FALSE gdy ruch biezacej figury (Figura) o jedna pozycje w dol
  nie jest mozliwy, a TRUE w przeciwnym (bezkolizyjnym) wypadku
}
begin
  Result := True;

  if SprWysKolizjiNaPlanszy(Figura.Nr, Figura.Obrot, XFigury, YFigury + 1)
    then Result := False;
end;

function TScenaGlowna.SprawdzLewo: Boolean;
{
  Funkcja zwraca wartosc FALSE gdy ruch biezacej figury (Figura) o jedna pozycje w lewo
  nie jest mozliwy, a TRUE w przeciwnym (bezkolizyjnym) wypadku
}
begin
  Result := True;

  if SprWysKolizjiNaPlanszy(Figura.Nr, Figura.Obrot, XFigury - 1, YFigury)
    then Result := False;
end;

function TScenaGlowna.SprawdzPrawo: Boolean;
{
  Funkcja zwraca wartosc FALSE gdy ruch biezacej figury (Figura) o jedna pozycje w prawo
  nie jest mozliwy, a TRUE w przeciwnym (bezkolizyjnym) wypadku
}
begin
  Result := True;

  if SprWysKolizjiNaPlanszy(Figura.Nr, Figura.Obrot, XFigury + 1, YFigury)
    then Result := False;
end;

procedure TScenaGlowna.RedukcjaLinii(RedukowanaLinia: Integer);
{
  Redukuje pelna linie w planszy i zwieksza licznik pelnych linii (Linie)
}
var
  w, k: Integer;
begin
  Inc(Linie);

  for w := RedukowanaLinia - 1 downto 1 do
    for k := 1 to SzerPlanszy do
    begin
      PlanszaGry[k, w + 1] := PlanszaGry[k, w];
      PlanszaGry[k, w] := 0;
    end;
end;

(*
{
  Sprawdza wystepowanie pelnych linii w planszy
}
procedure TScenaGlowna.SprawdzPelneLinie;
var
  w, k: Integer;
begin
  for w := 1 to WysPlanszy do
  begin
    for k := 1 to SzerPlanszy do
      if PlanszaGry[k, w] = 0
        then Break;

    if k = SzerPlanszy + 1 then RedukcjaLinii(w);
  end;
end;
*)

function TScenaGlowna.SprawdzPelneLinie: Byte;
{
  Sprawdza wystepowanie pelnych linii w planszy
}
var
  w, k: Integer;
begin
  Result := 0;
  for w := 1 to WysPlanszy do
  begin
    for k := 1 to SzerPlanszy do
      if PlanszaGry[k, w] = 0
        then Break;

    if k = SzerPlanszy + 1 then
    begin
      Result := w;
      Break;
    end;
  end;
end;

procedure TScenaGlowna.ZapisFiguryNaPlanszy(Figura: TRecFigura; X_Figury, Y_Figury: Integer);
{
  Zapis figury na plansze
}
var
  i, X_CzlonuFigury, Y_CzlonuFigury: Byte;
begin
  for i := 1 to MaxLiczbaCzlonowFigury do
    if Figury[Figura.Nr, Figura.Obrot, i, 2] <> PustaPozPlanszy then
    begin
      X_CzlonuFigury := Figury[Figura.Nr, Figura.Obrot, i, 1];
      Y_CzlonuFigury := Figury[Figura.Nr, Figura.Obrot, i, 2];
      PlanszaGry[X_CzlonuFigury + X_Figury - 1, Y_CzlonuFigury + Y_Figury - 1] :=
        KoloryFigur[Figura.Nr];
    end;
end;

procedure TScenaGlowna.InitNowegoCyklu;
{
  Init nowego cyklu (kolejna figura)
}
begin
  Figura := PrevNastFigury;
  PrevNastFigury.Nr := Random(LiczbaFigur) + 1;
  PrevNastFigury.Obrot := 1;
  YFigury := 1;
  XFigury := (SzerPlanszy div 2) - 1;
end;

procedure TScenaGlowna.RysujPlansze;
{
  Rysuje plansze
}
var
  i, j: Byte;
  rx1, rx2, ry1, ry2: Integer;
begin
  { Rysuj plansze }
  for i := 1 to SzerPlanszy do
    for j := 1 to WysPlanszy do
    begin
      rx1 := (i-1) * WH_CzlonuFigury + XPlanszy;
      ry1 := (j-1) * WH_CzlonuFigury + YPlanszy;
      rx2 := rx1 + WH_CzlonuFigury;
      ry2 := ry1 + WH_CzlonuFigury;

      with VRam.Surface.Canvas do
      begin
        Brush.Style := bsSolid;
        Brush.Color := PlanszaGry[i, j];
        Pen.Color := PlanszaGry[i, j];
        Rectangle(rx1, ry1, rx2, ry2);
        Release;
      end;
    end;
end;

procedure TScenaGlowna.RysujFigure(NrFigury, ObrFigury, X, Y: Integer);
{
   Rysuje figure o wspolrzednych X, Y
}
var
  i: Byte;
  rx1, rx2, ry1, ry2: Integer;
begin
  for i := 1 to MaxLiczbaCzlonowFigury do
    if Figury[NrFigury, ObrFigury, i, 1] <> 0 then
    begin
      rx1 := (Figury[NrFigury, ObrFigury, i, 1] + X - 2)*WH_CzlonuFigury+XPlanszy;
      ry1 := (Figury[NrFigury, ObrFigury, i, 2] + Y - 2)*WH_CzlonuFigury+YPlanszy;
      rx2 := rx1 + WH_CzlonuFigury;
      ry2 := ry1 + WH_CzlonuFigury;

      { Rysuje czlon figury }
      with VRam.Surface.Canvas do
      begin
        Brush.Style := bsSolid;
        Brush.Color := KoloryFigur[NrFigury];
        Pen.Color := KoloryFigur[NrFigury];
        Rectangle(rx1, ry1, rx2, ry2);
        Release;
      end;
    end;
end;

procedure TScenaGlowna.RysujRamkePlanszy;
var
  x, y, sz, wys: Integer;
begin
  x := XPlanszy;
  y := YPlanszy;

  sz := x+(SzerPlanszy*WH_CzlonuFigury);
  wys := y+(WysPlanszy*WH_CzlonuFigury);

  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Pen.Color := clWhite;
    MoveTo(x, y);
    LineTo(x, wys);
    LineTo(sz, wys);
    LineTo(sz, y);
    Release;
  end;
end;

procedure TScenaGlowna.RysujLogo;
{
  Rysuje logo
}
var
  Logo: TPictureCollectionItem;
begin
  with ObjectTetrisX do
  begin
    Logo := DXImageList.Items.Find('Logo');
    Logo.Draw(DXDraw.Surface, (SzerEkranu - Logo.Width) div 2, 360, 0);
  end;
end;

procedure TScenaGlowna.RysujInfo;
var
  s: string;
begin
  with VRam.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 9;

    s := 'Pelne linie: ' + IntToStr(Linie);
    TextOut(20, 170, s);

    s := 'Poziom trudnosci: ' + NazwyPoziomowTr[PoziomTr];
    TextOut(20, 185, s);

    s := 'Opoznienie [ms]: ' + IntToStr(RzeczOpozn);
    TextOut(20, 200, s);

    s := 'X: ' + IntToStr(XFigury);
    TextOut(20, 215, s);

    s := 'Y: ' + IntToStr(YFigury);
    TextOut(20, 230, s);

    Release;
  end;
end;

procedure TObjectTetrisX.DXTimerTimer(Sender: TObject; LagCount: Integer);
{
  Glowna petla. Zdarzenie timera.
}
begin
  if not DXDraw.CanDraw then exit;

  DXInput.Update;

  InicjatorScen.WykonujKodSceny;

  if ScenaOpcje.FPS then FPSView;

  DXDraw.Flip;
end;

procedure TObjectTetrisX.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {  Zmiana trybu okno/pelny ekran  }
  if (ssAlt in Shift) and (Key=VK_RETURN) then
  begin
    DXDraw.Finalize;

    if doFullScreen in DXDraw.Options then
    begin
      RestoreWindow;

      DXDraw.Cursor := crDefault;
      BorderStyle := bsSizeable;
      DXDraw.Options := DXDraw.Options - [doFullScreen];
    end else
    begin
      StoreWindow;

      DXDraw.Cursor := crNone;
      BorderStyle := bsNone;
      DXDraw.Options := DXDraw.Options + [doFullScreen];
    end;
    DXDraw.Initialize;
  end;
end;

procedure TObjectTetrisX.FormCreate(Sender: TObject);
begin
  InicjatorScen := TInicjatorScen.Init;
  ScenaMenu := TScenaMenu.Init(DXDraw, DXInput);
  ScenaOpcje := TScenaOpcje.Init(DXDraw, DXInput);
  ScenaGlowna := TScenaGlowna.Init(DXDraw, DXInput);
  ScenaGameOver := TScenaGameOver.Init(DXDraw, DXInput);
  ScenaCredits := TScenaCredits.Init(DXDraw, DXInput);
  ScenaListaNajlepszych := TScenaListaNajlepszych.Init(DXDraw, DXInput);

  PodScenaConfirm := TPodScenaConfirm.Init(DXDraw, DXInput);
  PodScenaFlashLine := TPodScenaFlashLine.Init(DXDraw, DXInput);

  PrzypiszKlawisze;

  UstawPaleteKolorow; // Ustawia palete kolorow

  InitMusic;

  ScenaListaNajlepszych.LadujListe;

  InicjatorScen.InicjujScene(ScenaMenu); // Start sceny Menu
end;

procedure TObjectTetrisX.UstawPaleteKolorow;
{
  Ustawienie palety kolorow
}
begin
  DXImageList.Items.MakeColorTable;
  DXDraw.ColorTable := DXImageList.Items.ColorTable;
  DXDraw.DefColorTable := DXImageList.Items.ColorTable;
end;

procedure TObjectTetrisX.DXDrawInitialize(Sender: TObject);
begin
  Randomize;
  DXTimer.Enabled := True;
end;

procedure TObjectTetrisX.DXDrawFinalize(Sender: TObject);
begin
  DXTimer.Enabled := False;
end;

procedure TObjectTetrisX.WyjscieZGry;
begin
  Close;
end;

procedure TObjectTetrisX.FPSView;
begin
  with DXDraw.Surface.Canvas do
  begin
    Brush.Style := bsClear;
    Font.Color := clWhite;
    Font.Size := 10;
    TextOut(0, 0, 'FPS: '+IntToStr(DXTimer.FrameRate));
    Release;
  end;
end;

procedure TObjectTetrisX.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  BASS_ChannelStop(mods);
  BASS_MusicFree(mods);
end;

procedure TObjectTetrisX.DXDrawInitializing(Sender: TObject);
begin
  if doFullScreen in DXDraw.Options then
  begin
    BorderStyle := bsNone;
    DXDraw.Cursor := crNone;
  end
  else
  begin
    BorderStyle := bsSingle;
    DXDraw.Cursor := crDefault;
  end;
end;

{
  Przypisanie do DXInput standardowej obslugi klawiszy
}
procedure TObjectTetrisX.PrzypiszKlawisze;
var
  Klawisze: TKeyAssignList;
begin
  Klawisze[isUp, 0]      := VK_UP;
  Klawisze[isDown, 0]    := VK_DOWN;
  Klawisze[isLeft, 0]    := VK_LEFT;
  Klawisze[isRight, 0]   := VK_RIGHT;

  Klawisze[isButton1, 0] := VK_SPACE;
  Klawisze[isButton2, 0] := VK_RETURN;
  Klawisze[isButton3, 0] := VK_ESCAPE;

  Klawisze[isButton4, 0] := VK_F1;
  Klawisze[isButton5, 0] := VK_F3;
  Klawisze[isButton6, 0] := VK_F5;
  Klawisze[isButton7, 0] := VK_F7;

  Klawisze[isButton8, 0] := Ord('T');
  Klawisze[isButton9, 0] := Ord('N');

  DXInput.Keyboard.KeyAssigns := Klawisze;
end;

end.

