program ObjectTetris;

uses
  Forms,
  ObjectTetrisForm in 'ObjectTetrisForm.pas' {ObjectTetrisX};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TObjectTetrisX, ObjectTetrisX);
  Application.Run;
end.
