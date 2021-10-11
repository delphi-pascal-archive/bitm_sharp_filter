unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, Jpeg;

type
  TForm1 = class(TForm)
    Image1: TImage;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;
  OrigBmp: TBitmap;

implementation

{$R *.dfm}

procedure BmpAccentuation(Bmp : TBitmap; Correction: integer);
type
  TRGBArray = array[Word] of TRGBTriple;
  PRGBArray = ^TRGBArray;
var
  Filter: array[0..8] of integer; // matrice de 3 * 3 pixels
  Red, Green, Blue, NewR, NewG, NewB, I,
  PosX, PosY, mX, mY, dX, dY, Diviseur : integer;
  TabScanlineBmp : array of PRGBArray;
  TabScanlineFinalBmp : array of PRGBArray;
  FinalBmp : TBitmap;
begin
   for I:= 0 to High(Filter) do
     if I in [0,2,6,8] then Filter[I]:= - Correction
     else if I = 4 then Filter[I]:= (Correction * 4) + 128 // +128 permet une correction bien étalée
     else Filter[I]:= 0;
   Diviseur:= Filter[4] - (Correction * 4);

   FinalBmp := TBitmap.Create;

   try
      FinalBmp.Assign(Bmp);
      SetLength(TabScanlineBmp, Bmp.Height);
      SetLength(TabScanlineFinalBmp, Bmp.Height);
      for I := 0 to Bmp.Height-1 do
      begin
          TabScanlineBmp[I] := Bmp.Scanline[I];
          TabScanlineFinalBmp[I] := FinalBmp.Scanline[I];
      end;

      for PosY := 0 to Bmp.Height - 1 do
          for PosX := 0 to Bmp.Width - 1 do
          begin
             NewR :=0;
             NewG :=0;
             NewB :=0;
             for dY := -1 to 1 do
                for dX := -1 to 1 do
                begin
                   //position du pixel à traiter
                   mY := PosY + dY;
                   mX := PosX + dX;
                   //Vérification des limites pour éviter les effets de bord
                   //Lecture des composantes RGB de chaque pixel
                   if  (mY >= 1) and (mY <= BMP.Height - 1)
                     and (mX >= 1) and (mX <= BMP.Width - 1) then
                        begin
                           Red := TabScanlineBmp[mY,mX].RGBTRed;
                           Green := TabScanlineBmp[mY,mX].RGBTGreen;
                           Blue := TabScanlineBmp[mY,mX].RGBTBlue;
                        end
                   else
                        begin
                           Red := TabScanlineBmp[PosY,PosX].RGBTRed;
                           Green := TabScanlineBmp[PosY,PosX].RGBTGreen;
                           Blue := TabScanlineBmp[PosY,PosX].RGBTBlue;
                         end;

                   I := 4 + (dY * 3) + dX; // I peut varier de 0 à 8
                   NewR := NewR + Red * Filter[I];
                   NewG := NewG + Green * Filter[I];
                   NewB := NewB + Blue * Filter[I];
                end;

             NewR := NewR div Diviseur;
             NewG := NewG div Diviseur;
             NewB := NewB div Diviseur;
             if NewR > 255 then NewR := 255 else if NewR < 0 then NewR := 0;
             if NewG > 255 then NewG := 255 else if NewG < 0 then NewG := 0;
             if NewB > 255 then NewB := 255 else if NewB < 0 then NewB := 0;
             TabScanlineFinalBmp[PosY,PosX].RGBTRed   := NewR;
             TabScanlineFinalBmp[PosY,PosX].RGBTGreen := NewG;
             TabScanlineFinalBmp[PosY,PosX].RGBTBlue  := NewB;
      end;

      Bmp.Assign(FinalBmp);

   finally
      FinalBmp.Free;
      Finalize(TabScanlineBmp);
      Finalize(TabScanlineFinalBmp);
   end;
end;


procedure TForm1.FormCreate(Sender: TObject);
var
  Jpg: TJpegImage;
begin
  Jpg:= TJpegImage.Create;
  OrigBmp:= TBitmap.Create;
  Jpg.LoadFromFile('ImageTest.jpg');
  OrigBmp.Assign(Jpg);
  OrigBmp.PixelFormat:= pf24bit;
  Jpg.Free;
  Image1.Picture.Bitmap.Assign(OrigBmp);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Origbmp.Free;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  Bmp: TBitmap;
begin
  Bmp:= TBitmap.Create;
  try
    Bmp.Assign(OrigBmp);
    Bmp.PixelFormat:= pf24bit;
    BmpAccentuation(Bmp, Trackbar1.Position);
    Image1.Picture.Bitmap.Assign(Bmp);
  finally
    bmp.Free;
  end;
end;

end.
