unit Form.Message;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormMessage = class(TForm)
    LblMessage: TLabel;
    ButtonPanel: TPanel;
    ButtonOk: TButton;
    MessagePanel: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    class procedure Show(const aCaption, aText: string; const aShowInTaskbar: boolean); static;
    { Public declarations }
  end;




implementation
uses Theme.Manager;

{$R *.dfm}

{ TFormMessage }

procedure TFormMessage.FormCreate(Sender: TObject);
begin
  TThemeManager.UpdateControl(Self);
end;

class procedure TFormMessage.Show(const aCaption, aText: string; const aShowInTaskbar: boolean);
begin
  var FormMessage := TFormMessage.Create(nil);
  try
    FormMessage.Caption := aCaption;
    FormMessage.LblMessage.Caption := aText;
    FormMessage.ShowInTaskBar := aShowInTaskbar;
    FormMessage.ShowModal;
  finally
    FormMessage.Free;
  end;

end;

end.
