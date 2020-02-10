unit Unit1;

interface

uses
  Windows, Messages, SysUtils,  Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, mxarrays;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure OpenList(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SaveList(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

const
  { Liczba pozycji na liscie najlepszych }
  LiczbaNajlepszychHS = 5;

  { Nagłówek identyfikacyjny pliku z lista najlepszych .otx }
  IDNaglowekHS = #$03#$02#$81'ObjectTetrisX'#$00;

  { Nazwa pliku z lista najlepszych }
  NazwaPlikuHS = 'c:\Temp\HighScores.otx';

type
  THighScoresRec = record
    Ksywa: string[20];
    IleLinii: Integer;
  end;

var
  Lista: TBaseArray;

procedure TForm1.OpenList(Sender: TObject);
var
  OpenLista: File;
  Naglowek: string;
  i, Bezp: Integer;
  ItemHS: THighScoresRec;
begin
  try
    AssignFile(OpenLista, NazwaPlikuHS);
    Reset(OpenLista, 1);
    try
      { Czyta nagłówek }
      BlockRead(OpenLista, Naglowek, SizeOf(IDNaglowekHS), Bezp);

      if Naglowek = IDNaglowekHS then
        for i := 0 to LiczbaNajlepszychHS - 1 do
        begin
          BlockRead(OpenLista, ItemHS, SizeOf(THighScoresRec), Bezp);
          Lista.Insert(Lista.Count, ItemHS);
        end
      else
      begin
        Application.MessageBox('Nieprawidłowy format pliku.', 'ObjectTetrisX - Błąd', MB_ICONERROR);
        Close;
      end;
      finally
        CloseFile(OpenLista);
    end;
    except
    on E: EInOutError do
    begin
      Application.MessageBox(PChar(SysErrorMessage(E.ErrorCode)), 'ObjectTetrisX - Błąd Wejścia/Wyjścia (I/O).', MB_ICONERROR);
      Close;
    end;
  end;
end;

var
  tab: array[0..  LiczbaNajlepszychHS - 1] of THighScoresRec =
  (
    (
      Ksywa: 'Jacek';
      IleLinii: 30
    ),
    (
      Ksywa: 'Jac';
      IleLinii: 10
    ),
    (
      Ksywa: 'Erwin';
      IleLinii: 60
    ),
    (
      Ksywa: 'Kac';
      IleLinii: 30
    ),
    (
      Ksywa: 'Jacek';
      IleLinii: 30
    )
  );

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Lista := TBaseArray.Create(5, sizeof(THighScoresRec));

  for i := 0 to LiczbaNajlepszychHS - 1 do
    Lista.Insert(Lista.Count, tab[i]);
end;

procedure TForm1.SaveList(Sender: TObject);
var
  SaveLista: File;
  Naglowek: string;
  i, Bezp: Integer;
  ItemHS: THighScoresRec;
begin
  try
    AssignFile(SaveLista, NazwaPlikuHS);
    Rewrite(SaveLista, 1);
    try
      BlockWrite(SaveLista, IDNaglowekHS, Length(IDNaglowekHS), Bezp);

      for i := 0 to Lista.Count-1 do
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
      Close;
    end;
  end;
end;


end.
