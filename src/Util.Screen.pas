unit Util.Screen;

interface
uses Forms;

type TScreenUtil = record
public
  class procedure PutInPosition(const Form: TForm; const ItemHeight: integer = 0; const ItemCount: integer = 0); static;
end;

implementation
uses Controls, Math;

class procedure TScreenUtil.PutInPosition(const Form: TForm; const ItemHeight, ItemCount: integer);
const
  Margin = 10;
begin
    var p := Mouse.CursorPos;
    var r := Screen.MonitorFromPoint(p).WorkareaRect;
    Form.Position := poDesigned;

    var TitleHeight := Form.Height - Form.ClientHeight;
    var NewHeight := Form.Height;

    if ItemHeight > 0 then
    begin
      var MaxHeight := Round(r.Height * 0.6);
      NewHeight := ItemCount * ItemHeight + Margin + TitleHeight;
      if NewHeight > MaxHeight then
      begin
        //We'll cut the last entry in half so it is clear there are more items.
        NewHeight := (MaxHeight div ItemHeight) * ItemHeight + ItemHeight div 2 + TitleHeight;
      end;
    end;

    var FormLeft := Max(p.X - Form.Width div 2, r.Left + Margin);
    FormLeft := Min(FormLeft, r.Right - Form.Width - Margin);

    var FormTop: integer;
    FormTop := Max(r.Top + Margin, p.Y - TitleHeight - ItemHeight div 2);
    FormTop := Min(FormTop, r.Bottom - NewHeight - Margin);

    Form.SetBounds(FormLeft, FormTop, Form.Width, NewHeight);
end;

end.
