unit ICO.Creator;
// From https://en.delphipraxis.net/topic/8226-convert-png-to-ico-fmx-delphi/
interface
type
  TIcoCreator = record
  public
    class procedure Convert(const InFileName, OutFileName: string); static;
  end;

implementation
uses SysUtils, Classes, Windows;

const
  RES_ICON = 1;
  RES_CURSOR = 2;

type
  TIconDirectoryHeader = packed record
    Reserved: Word;             // Reserved; must be zero.

    ResType: Word;              // Specifies the resource type. This member must
                                // have one of the following values:
                                //   RES_ICON      Icon resource type.
                                //   RES_CURSOR    Cursor resource type.

    ResCount: Word;             // Specifies the number of icon or cursor
                                // components in the resource group.
  end;

  TIconDirectoryEntry = packed record
    Width: Byte;
    Height: Byte;
    ColorCount: Byte;
    Reserved: Byte;
    ResInfo: packed record
    case byte of
      RES_ICON: (
        IconPlanes: Word;
        IconBitCount: Word);
      RES_CURSOR: (
        CursorHotspotX: Word;
        CursorHotspotY: Word);
    end;
    BytesInRes: DWORD;
    ImageOffset: DWORD;
  end;

  TColorDepth = 1..32; // Bits per pixel. Not bits per plane.

function ColorDepthToColors(ColorDepth: TColorDepth): cardinal;
begin
  Result := 1;
  while (ColorDepth > 0) do
  begin
    Result := Result shl 1;
    dec(ColorDepth);
  end;
end;

// PngStream:	A stream containing the PNG
// IcoStream:	The outout stream
// AWidth:		Width of the PNG
// AHeight:		Height of the PNG
// AColorDepth:	Color depth of the PNG
procedure SavePngStreamToIcoStream(PngStream, IcoStream: TStream; AWidth, AHeight: integer; AColorDepth: TColorDepth = 32);
begin
  var IconDirectoryHeader: TIconDirectoryHeader := Default(TIconDirectoryHeader);
  var IconDirectoryEntry: TIconDirectoryEntry := Default(TIconDirectoryEntry);

  IconDirectoryHeader.ResType := RES_ICON;
  IconDirectoryHeader.ResCount := 1;

  IcoStream.Write(IconDirectoryHeader, SizeOf(IconDirectoryHeader));

  // Note : 256x256 icon sets Width&Height to 0 (according to docs) or to 255 (according to .NET)
  IconDirectoryEntry.Width := AWidth and $FF;
  IconDirectoryEntry.Height := AHeight and $FF;

  var BitCount := 0;
  var ColorCount := 0;
  case AColorDepth of
    1, 4: ColorCount := ColorDepthToColors(AColorDepth);
  else
    BitCount := AColorDepth;
  end;

  IconDirectoryEntry.BytesInRes := PngStream.Size;
  IconDirectoryEntry.ImageOffset := SizeOf(IconDirectoryHeader) + SizeOf(IconDirectoryEntry);
  IconDirectoryEntry.ResInfo.IconPlanes := 1;
  IconDirectoryEntry.ResInfo.IconBitCount := BitCount;
  IconDirectoryEntry.ColorCount := ColorCount;

  IcoStream.Write(IconDirectoryEntry, SizeOf(IconDirectoryEntry));

  IcoStream.CopyFrom(PngStream, 0);
end;

{ TIcoCreator }

class procedure TIcoCreator.Convert(const InFileName, OutFileName: string);
begin
 // SavePngStreamToIcoStream(PngStream, IcoStream, 512, 512);
end;

end.
