unit DelphiZXingQRCodeTestAppMainForm;

// Demo app for ZXing QRCode port to Delphi, by Debenu Pty Ltd (www.debenu.com)
// Need a PDF SDK? Checkout Debenu Quick PDF Library: http://www.debenu.com/products/development/debenu-pdf-library/

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DelphiZXingQRCode, Vcl.ExtCtrls,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    edtText: TEdit;
    Label1: TLabel;
    cmbEncoding: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    edtQuietZone: TEdit;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure edtTextChange(Sender: TObject);
    procedure cmbEncodingChange(Sender: TObject);
    procedure edtQuietZoneChange(Sender: TObject);
  private
    QRCodeBitmap: TBitmap;
  public
    procedure UpdateQRCode;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.cmbEncodingChange(Sender: TObject);
begin
  UpdateQRCode;
end;

procedure TForm1.edtQuietZoneChange(Sender: TObject);
begin
  UpdateQRCode;
end;

procedure TForm1.edtTextChange(Sender: TObject);
begin
  UpdateQRCode;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  QRCodeBitmap := TBitmap.Create;
  UpdateQRCode;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  QRCodeBitmap.Free;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
var
  Scale: Double;
begin
  PaintBox1.Canvas.Brush.Color := clWhite;
  PaintBox1.Canvas.FillRect(Rect(0, 0, PaintBox1.Width, PaintBox1.Height));
  if ((QRCodeBitmap.Width > 0) and (QRCodeBitmap.Height > 0)) then
  begin
    if (PaintBox1.Width < PaintBox1.Height) then
    begin
      Scale := PaintBox1.Width / QRCodeBitmap.Width;
    end else
    begin
      Scale := PaintBox1.Height / QRCodeBitmap.Height;
    end;
    PaintBox1.Canvas.StretchDraw(Rect(0, 0, Trunc(Scale * QRCodeBitmap.Width), Trunc(Scale * QRCodeBitmap.Height)), QRCodeBitmap);
    //PaintBox1.Canvas.Draw(0,0,QRCodeBitmap);;
  end;
end;

procedure TForm1.UpdateQRCode;
type
  TMyScanLine32  = Array[0..16383] of TColor;
var
  QRCode         : TDelphiZXingQRCode;
  Row, Column    : Integer;
  PS32           : ^TMyScanLine32;
  PSDif          : Integer;
begin
  QRCode := TDelphiZXingQRCode.Create;
  try
    QRCode.Data      := edtText.Text;
    QRCode.Encoding  := TQRCodeEncoding(cmbEncoding.ItemIndex);
    QRCode.QuietZone := StrToIntDef(edtQuietZone.Text, 4);
    QRCodeBitmap.SetSize(QRCode.Rows, QRCode.Columns);
    QRCodeBitmap.PixelFormat := pf32bit;

    PS32  := QRCodeBitmap.ScanLine[0];
    PSDif := Integer(QRCodeBitmap.ScanLine[1])-Integer(PS32);
    for Row := 0 to QRCode.Rows - 1 do
    begin
      for Column := 0 to QRCode.Columns - 1 do
      begin
        If (QRCode.IsBlack[Row, Column]) then PS32^[Column] := clBlack else PS32^[Column] := clWhite;
      end;
      Inc(Integer(PS32),PSDif);
    end;
  finally
    QRCode.Free;
  end;
  PaintBox1.Repaint;
end;

end.



