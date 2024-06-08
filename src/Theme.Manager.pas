unit Theme.Manager;

interface
uses  Theme.Colors, Vcl.Controls;
type
 TThemeManager = record
 private
   class var ThemeColors: TThemeColors;
 public
   class constructor Create;
   class procedure UpdateControl(const Control: TControl); static;
 end;


implementation
uses Vcl.Forms, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.ControlList, UITypes;

type
  TControlAccess = class(TControl)
  public
    property Color;
  end;


class constructor TThemeManager.Create;
begin
  ThemeColors := TThemeColors.Create(true);
end;

class procedure TThemeManager.UpdateControl(const Control: TControl);
begin
  if Integer(ThemeColors.BackColor) <> -1 then
  begin
    TControlAccess(Control).Color := ThemeColors.GetBackColor(Control.Tag <> 0);

    for var i := 0 to Control.ComponentCount - 1 do
    begin
      var Comp := Control.Components[i];
      var BackColor := ThemeColors.GetBackColor(Comp.Tag <> 0);
      var TextColor := ThemeColors.GetTextColor(Comp.Tag <> 0);
      if Comp is TControlList then
      begin
        TControlList(Comp).Color := BackColor;
        TControlList(Comp).BorderStyle := bsNone;
        continue;
      end;

      if Comp is TLabel then
      begin
        TLabel(Comp).Font.Color := TextColor;
        continue;
      end;

      if Comp is TLabeledEdit then
      begin
        TLabeledEdit(Comp).Color := ThemeColors.AltBackColor;
        TLabeledEdit(Comp).Font.Color :=ThemeColors.AltTextColor;
        TLabeledEdit(Comp).EditLabel.Font.Color := ThemeColors.AltTextColor;
        continue;
      end;

      if Comp is TMemo then
      begin
        TMemo(Comp).Color := ThemeColors.AltBackColor;
        TMemo(Comp).Font.Color := ThemeColors.AltTextColor;
        continue;
      end;

      if Comp is TComboBox then
      begin
        TComboBox(Comp).Color := ThemeColors.AltBackColor;
        TComboBox(Comp).Font.Color := ThemeColors.AltTextColor;
        continue;
      end;

      if Comp is TListBox then
      begin
        TListBox(Comp).Color := ThemeColors.AltBackColor;
        TListBox(Comp).Font.Color := ThemeColors.AltTextColor;
        continue;
      end;

      if Comp is TControlListButton then
      begin
        TControlListButton(Comp).Font.Color := TextColor;
        continue;
      end;

      if Comp is TControl then
      begin
        UpdateControl(TControl(Comp));
      end;

    end;
  end;
end;

end.
