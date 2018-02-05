unit UFullscreen;

{$mode objfpc}{$H+}

{$DEFINE Mydebug}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LclType, LclProc, LclIntf, Menus, strutils, Types, Dos {$ifdef Mydebug},Windows{$endif};

type

  { TfrmFullscreen }

  TfrmFullscreen = class(TForm)
    Image1: TImage;
    MenuItem1: TMenuItem;
    MenuItemRandom: TMenuItem;
    MenuItemRepeat: TMenuItem;
    MenuItemFit: TMenuItem;
    MenuItemExpand: TMenuItem;
    MenuItemStretchBoth: TMenuItem;
    MenuItemMoniters: TMenuItem;
    MenuItemFilterFileSize: TMenuItem;
    MenuItemPlayback: TMenuItem;
    MenuItemInterval: TMenuItem;
    MenuItemFilter: TMenuItem;
    MenuItemQuit: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItemBack: TMenuItem;
    MenuItemNext: TMenuItem;
    MenuItemPause: TMenuItem;
    MenuItemEffect: TMenuItem;
    MenuItemStretch: TMenuItem;
    PopupMenu1: TPopupMenu;
    TimerInterval: TTimer;
    TimerFadeIn: TTimer;
    TimerFadeOut: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Image1DblClick(Sender: TObject);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemExpandClick(Sender: TObject);
    procedure MenuItemFitClick(Sender: TObject);
    procedure MenuItemQuitClick(Sender: TObject);
    procedure MenuItemBackClick(Sender: TObject);
    procedure MenuItemNextClick(Sender: TObject);
    procedure MenuItemPauseClick(Sender: TObject);
    procedure MenuItemEffectClick(Sender: TObject);
    procedure MenuItemRandomClick(Sender: TObject);
    procedure MenuItemRepeatClick(Sender: TObject);
    procedure MenuItemStretchBothClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure TimerFadeInTimer(Sender: TObject);
    procedure TimerFadeOutTimer(Sender: TObject);
    procedure TimerIntervalTimer(Sender: TObject);

  private
    FFileList:TStringlist;
    FFileListHistory:TStringlist;
    FFileListRemaining:TStringList;
    //FFileListIgnore:TStringList;
    FiCurr:integer;
    FInterval:integer;
    FStretch:boolean;
    FExpand:boolean;
    FFit:boolean;
    FEffect:boolean;
    FMinimulFileSizeKiloByte:integer;
    FManualTransition:boolean;
    FRandom:boolean;
    FRepeat:boolean;
    FIsFullScreen: boolean;
    FIsSlideshowPlaying:boolean;//TODO this actually doing nothing.Reconsider.
    FOrigBounds: TRect;
    FOrigWndState: TWindowState;
    procedure ShowFullScreen(AValue: boolean);
    procedure SetFullScreen_Universal(AValue: boolean);
    procedure SetFullScreen_Win32(AValue: boolean);
    procedure StartSlideshow();
      {Starts slideshow begining of specified "starts" index.
      }
    function DisplayImage(id:integer):integer;
      {Display an Image.
        Takes an index of the playback list, return current index.
    }
    function ValidateFileIndex(id:integer):boolean;
      {Validates if given int is in range of the list.
        Returns true if id is in range of the playback list,
      }
    function ValideteFile(id:integer):integer;
      {Validate Image file. It determines if it is exists.
        Returns -1 if "not there", or return "FileSize".
      }
    procedure DisplayError(id:integer;message:string);
      {Takes an index of the playback list,
        Return current index.
      }
    function GetNextImageIndex(id:integer):integer;
      {Takes current index, and returns next index of the playback list.
        Returns -1 if there is no next or reached at the end of the list.
      }
    function GetNextRandomImageIndex():integer;
      {Takes current index, and returns next Random index of the playback list
        which does not exists in history list.
        Returns -1 if there is no next or reached at the end of the list.
      }
    function GetPreviousImageIndex(id:integer):integer;
      {Takes current index, and returns previous index of the playback list.
        Returns -1 if there is no previous or reached at the beggining.
      }
    //function GetRandomImageIndex(id:integer):integer;
      {Takes current index, and random index of the playback list.
        Returns -1 if there is no file.
      }
    procedure ChangeMoniterClicked(Sender: TObject);
    procedure ChangeIntervalClicked(Sender: TObject);
    procedure ChangeMinFileSizeClicked(Sender: TObject);

    procedure PlaybackNext(Sender: TObject);
    procedure PlaybackBack(Sender: TObject);
    procedure PlaybackPause(Sender: TObject);
    procedure PlaybackPlay(preLoad:boolean);
    procedure PlaybackRepeatStart();

  public
    property Current: integer read FiCurr;
  end;

var
  frmFullscreen: TfrmFullscreen;

implementation

uses UMain;

{$R *.lfm}

procedure TfrmFullscreen.FormCreate(Sender: TObject);
var
  i:integer;
  childItem: TMenuItem;
begin
  FiCurr:=-1;
  TimerFadeIn.Interval:=1;
  TimerFadeOut.Interval:=2;

  FFileList:=TStringlist.Create;
  FFileList.Assign(frmMain.FileList);
  FFileListHistory:=TStringList.Create;
  FFileListRemaining:=TStringlist.Create;
  //FFileListIgnore:=TStringlist.Create;

  FInterval:= frmMain.OptIntervalIntSeconds*1000;
  TimerInterval.Interval:=FInterval;
  TimerInterval.Enabled:=false;

  FStretch:= frmMain.OptStretch;
  FFit:=frmMain.OptFit;
  FExpand:=frmMain.OptExpand;
  FEffect:=frmMain.OptTransitEffect;
  FMinimulFileSizeKiloByte:=frmMain.OptMinimulFileSizeKiloByte;
  FManualTransition:=frmMain.OptManualTransition;
  FRandom:= frmMain.OptRandom;
  FRepeat:= frmMain.OptRepeat;

  Image1.Stretch:=false;
  if FStretch or FFit then begin
    Image1.StretchInEnabled:=true;
  end else begin
    Image1.StretchInEnabled:=false;
  end;
  Image1.StretchOutEnabled:=true;

  Image1.Proportional:=true;
  Image1.Center:=true;


  //Popup Menues

  for i:=0 to 9 do begin
    childItem := TMenuItem.Create(PopupMenu1);
    childItem.Caption := '[&'+intToStr(i+1)+'] seconds';
    childItem.OnClick := @ChangeIntervalClicked;
    childItem.Tag:=i+1;
    MenuItemInterval.Add(childItem);
  end;
  childItem := TMenuItem.Create(PopupMenu1);
  childItem.Caption := '[One] &minute';
  childItem.OnClick := @ChangeIntervalClicked;
  childItem.Tag:=60;
  MenuItemInterval.Add(childItem);
  childItem := TMenuItem.Create(PopupMenu1);
  childItem.Caption := '[Five] &minute';
  childItem.OnClick := @ChangeIntervalClicked;
  childItem.Tag:=300;
  MenuItemInterval.Add(childItem);
  childItem := TMenuItem.Create(PopupMenu1);
  childItem.Caption := '[Ten] &minute';
  childItem.OnClick := @ChangeIntervalClicked;
  childItem.Tag:=600;
  MenuItemInterval.Add(childItem);
  childItem := TMenuItem.Create(PopupMenu1);
  childItem.Caption := '[Fifteen] &minute';
  childItem.OnClick := @ChangeIntervalClicked;
  childItem.Tag:=900;
  MenuItemInterval.Add(childItem);

  //minimum file size
  childItem := TMenuItem.Create(PopupMenu1);
  childItem.Caption := '> [&'+intToStr(1)+'] KB';
  childItem.OnClick := @ChangeMinFileSizeClicked;
  childItem.Tag:=1;
  MenuItemFilterFileSize.Add(childItem);
  childItem := TMenuItem.Create(PopupMenu1);
  childItem.Caption := '> [&'+intToStr(50)+'] KB';
  childItem.OnClick := @ChangeMinFileSizeClicked;
  childItem.Tag:=50;
  MenuItemFilterFileSize.Add(childItem);
  for i:=0 to 9 do begin
    childItem := TMenuItem.Create(PopupMenu1);
    childItem.Caption := '> [&'+intToStr(i+1)+'00] KB';
    childItem.OnClick := @ChangeMinFileSizeClicked;
    childItem.Tag:=i*100;
    MenuItemFilterFileSize.Add(childItem);
  end;

  //moniters
  for i:=0 to frmMain.MoniterList.Count-1 do begin
    childItem := TMenuItem.Create(PopupMenu1);
    childItem.Caption := 'Moniter[&'+intToStr(i+1)+']';
    childItem.OnClick := @ChangeMoniterClicked;
    childItem.Tag:=i;
    MenuItemMoniters.Add(childItem);
  end;

  self.Visible:=false; //don't set to true.
  self.ShowInTaskBar:=stNever;

  self.AlphaBlend:=true;
  self.AlphaBlendValue := 255; // do NOT ever set it to 0.

  Randomize;//important
end;

procedure TfrmFullscreen.FormDestroy(Sender: TObject);
begin
  FFileList.Free;
  FFileListHistory.Free;
  FFileListRemaining.Free;
end;

procedure TfrmFullscreen.FormShow(Sender: TObject);
begin
  self.Cursor:=crNone;
  Screen.Cursor:=crNone;
  Screen.UpdateScreen;

  if (FFileList.Count > 0) then
  begin
    //Sets fullscreen and show.
    ShowFullScreen(true);
  end else begin
    //no files are selected or to open. List empty.
    //this should not happen.
  end;
  StartSlideshow();
end;

procedure TfrmFullscreen.FormActivate(Sender: TObject);
begin
  //StartSlideshow();
end;

procedure TfrmFullscreen.StartSlideshow();
begin
  //reset
  FFileListHistory.Clear;
  FFileListRemaining.Clear;
  FFileListRemaining.Assign(FFileList);

  //specify index to display.
  if FRandom then begin
    TimerInterval.tag:= GetNextRandomImageIndex();
  end else
  begin
    TimerInterval.tag:=0;
  end;

  //Start slideshow.
  if FEffect then begin
    self.AlphaBlendValue := 1;
    PlaybackPlay(false);
  end else begin
    PlaybackPlay(false);
    TimerInterval.Enabled:=true;
  end;

  FIsSlideshowPlaying:=true;
end;

procedure TfrmFullscreen.PlaybackPlay(preLoad:boolean);
var
  i,iNext:integer;
begin

  //TODO if preLoad,

  TimerInterval.Enabled:=false;

  {$ifdef Mydebug}
  OutputDebugString(PChar(TrimRight( 'PlaybackPlay:id '+ intToStr(TimerInterval.Tag) )));
  {$endif}

  i:=TimerInterval.Tag;
  if ValidateFileIndex(i) then
  begin

    //display image
    FiCurr:=DisplayImage(i);
  end else begin
    DisplayError(i,'Display file index out of rainge.'+intToStr(i));
    {$ifdef Mydebug}
    OutputDebugString(PChar(TrimRight( 'Display file index out of rainge.'+intToStr(i) )));
    {$endif}
    exit;
  end;

  //next cycle.
  if FFileList.Count > 0 then
  begin
    //tell Timer what to play.
    if FRandom then begin
      iNext:=GetNextRandomImageIndex();
    end else begin
      iNext:=GetNextImageIndex(Current);
    end;
    if (iNext > -1) then
    begin
      {$ifdef Mydebug}
      OutputDebugString(PChar(TrimRight( 'PlaybackPlay: ->Next:'+ intToStr(iNext))));
      {$endif}
      //set next
      TimerInterval.tag:= iNext;

      //start timer
      if FEffect then begin
        TimerFadeIn.Enabled:=true;
      end else begin
        TimerInterval.Enabled:=true;
      end;

    end else begin
      //next is the end of list.
      {$ifdef Mydebug}
      OutputDebugString(PChar(TrimRight( 'PlaybackPlay: ->PlaybackRepeatStart')));
      {$endif}
      if FEffect then begin
        //it's the last but you need to fade in.
        // TimerFadeIn checks repeat option
        TimerFadeIn.Enabled:=true;
      end else begin
        //checking repeat option
        PlaybackRepeatStart();
      end;
    end;
  end;
end;

procedure TfrmFullscreen.PlaybackRepeatStart();
begin

  {$ifdef Mydebug}
  OutputDebugString(PChar(TrimRight( 'PlaybackRepeatStart ')));
  {$endif}

  if FRepeat then begin
    //start from beggining.

    //clear
    FFileListRemaining.Clear;
    FFileListRemaining.Assign(FFileList);

    //reset next
    if FRandom then begin
      TimerInterval.tag:=GetNextRandomImageIndex();
    end else begin
      FiCurr:=0;
      TimerInterval.tag:=0;
    end;

    {$ifdef Mydebug}
    OutputDebugString(PChar(TrimRight( 'PlaybackRepeatStart '+ intToStr(TimerInterval.tag) )));
    {$endif}

    //start timer
    if FEffect then begin
      TimerInterval.Enabled:=true;
    end else begin
      TimerInterval.Enabled:=true;
    end;
  end else begin
    //TODO
    //self terminate?
    {$ifdef Mydebug}
    OutputDebugString(PChar(TrimRight( 'PlaybackRepeatStart: No repeat.')));
    {$endif}
  end;
end;

procedure TfrmFullscreen.PlaybackPause(Sender: TObject);
begin
  //toggle playback pause/start
  if FIsSlideshowPlaying then begin
    if TimerInterval.Enabled or TimerFadeIn.Enabled or TimerFadeOut.Enabled then
    begin
      TimerInterval.Enabled:=false;
      TimerFadeIn.Enabled:=false;
      TimerFadeOut.Enabled:=false;

      self.AlphaBlendValue:=255;
      {
      if self.AlphaBlendValue < 50 then begin
        //we don't wanna totall black screen.
        self.AlphaBlendValue:=255;
      end;
      }
    end else begin
      if FEffect then begin
        TimerFadeOut.Enabled:=true;
      end else begin
        PlaybackPlay(false);
      end;
    end;
  end;
end;

procedure TfrmFullscreen.PlaybackNext(Sender: TObject);
begin
  if FEffect then begin
    TimerFadeIn.Enabled:=false;
    TimerFadeOut.Enabled:=false;
    TimerFadeOut.Enabled:=true;
  end else begin
    PlaybackPlay(false);
  end;
end;

procedure TfrmFullscreen.PlaybackBack(Sender: TObject);
var
  iPrev:integer;
begin
  //OutputDebugString(PChar(TrimRight('PlaybackBack:(Current):'+intToStr(Current))));
  iPrev:=GetPreviousImageIndex(Current);
  //OutputDebugString(PChar(TrimRight('PlaybackBack:(iPrev):'+intToStr(iPrev))));
  if (iPrev > -1) then
  begin
    if FEffect then begin
      TimerFadeIn.Enabled:=false;
      TimerInterval.Enabled:=false;
      TimerInterval.Tag := iPrev;
      TimerFadeOut.Enabled:=true;
    end else begin
      TimerInterval.Enabled:=false;
      TimerInterval.Tag := iPrev;
      PlaybackPlay(false);
    end;
  end;
end;

function TfrmFullscreen.ValidateFileIndex(id:integer):boolean;
begin
  if (id > -1) and ((FFileList.Count-1) >= id) then
  begin
    result := true;
  end else
  begin
    result := false;
  end;
end;

function TfrmFullscreen.ValideteFile(id:integer):integer;
begin
  //FileExists?
  result := FileSize(FFileList[id]);
end;

function TfrmFullscreen.DisplayImage(id:integer):integer;
var
  f:integer;
begin
  f:= ValideteFile(id);
  if f >= (FMinimulFileSizeKiloByte * 1024) then
  begin
    Image1.Picture.Clear;
    Image1.Stretch:=false;
    try
      Image1.Picture.LoadFromFile(FFileList[id]);

      if FStretch then begin
         Image1.Stretch:=true;
      end else begin
        if FFit then begin
          if ((Image1.Picture.Width > screen.Monitors[frmMain.OptIntMoniter].Width) or
                  (Image1.Picture.height > screen.Monitors[frmMain.OptIntMoniter].Height)) then begin
            Image1.Stretch:=true;
            //fit only when larger than screen size.
          end else begin
            Image1.Stretch:=false;
          end;
        end;
        if FExpand then begin
          Image1.Stretch:=true;
        end;
      end;

      Image1.Refresh;
      FFileListHistory.Add(FFileList[id]);
      result:=id;
      {$ifdef Mydebug}
      OutputDebugString(PChar(TrimRight( 'DisplayImage:id '+ intToStr(id) )));
      {$endif}

    except
      On E :Exception do begin
        {$ifdef Mydebug}
        OutputDebugString(PChar(TrimRight( 'Exception@DisplayImage_LoadFromFile:id '+ intToStr(id)+':'+E.Message )));
        {$endif}
        Image1.Picture.Clear;
        DisplayError(id,E.Message);
      end;
    end;
  end else
  begin
    //file does not exists.
    if (f < 0) then begin
      Image1.Picture.Clear;
      with image1.Canvas do
        begin
          Brush.Style := bsClear;
          Font.Color := clWhite;
          TextOut(24,24, 'File not found: '+FFileList[id]);
      end;
      Image1.Update;
      result:=id;
      {$ifdef Mydebug}
      OutputDebugString(PChar(TrimRight( 'DisplayImage FileNotFound:id '+ intToStr(id) )));
      {$endif}
    end else begin
      //file size just too small. skipping.
      //TODO getNext and continue?
      result:=-1;
    end;
  end;

  if (FFileListRemaining.IndexOf(FFileList[id]) > -1) then begin
     FFileListRemaining.Delete(FFileListRemaining.IndexOf(FFileList[id]));
  end;
end;

Function L0(w:word):string;
var
  s : string;
begin
  Str(w,s);
  if w<10 then
   L0:='0'+s
  else
   L0:=s;
end;

procedure TfrmFullscreen.DisplayError(id:integer;message:string);
var
  Hour,Min,Sec,HSec : word;
  strFilePath:string;
  esl:TStringlist;
  logFile:string;
begin
  if ValidateFileIndex(id) then
  begin
   strFilePath:=FFileList[id];
  end;

  Image1.Picture.Clear;
  with image1.Canvas do
    begin
      Brush.Style := bsClear;
      Font.Color := clWhite;
      TextOut(24,24, 'Opps, something went wrong. Sorry... : '+message);
      TextOut(52,52, strFilePath);
  end;
  Image1.Update;

  try
    esl:=TStringlist.Create;
    try
    logFile:=ReplaceStr(ExtractFileName(ParamStr(0)),ExtractFileExt(ParamStr(0)),'.log');
    if FileExists(logFile) then
    begin
      esl.LoadFromFile(logFile);
    end;
    GetTime(Hour,Min,Sec,HSec);
    esl.Add(L0(Hour)+':'+L0(Min)+':'+L0(Sec));
    esl.Add('DisplayError: '+message);
    esl.Add('FileIndex: '+intToStr(id));
    esl.Add('File: '+strFilePath);
    esl.SaveToFile(logFile);

    finally
      esl.Free;
    end;
  except
    //shee
  end;
end;

procedure TfrmFullscreen.TimerFadeInTimer(Sender: TObject);
var
  iNext:integer;
begin
  if FFileList.Count = 0 then
  begin
    TimerInterval.Enabled:=false;
    self.AlphaBlendValue := 255;
    //close;
    exit;
  end;

  if self.AlphaBlendValue < 255 then
  begin
    if (self.AlphaBlendValue < 100 ) then begin
       self.AlphaBlendValue := self.AlphaBlendValue + 10;
    end else
    begin
      if (self.AlphaBlendValue +5 >= 255) then begin
        self.AlphaBlendValue := 255;
      end else begin
        self.AlphaBlendValue := self.AlphaBlendValue + 4;
      end;
    end;
  end else begin
    TimerFadeIn.Enabled:=false;
    {$ifdef Mydebug}
    OutputDebugString(PChar(TrimRight( 'TimerFadeInTimer' )));
    {$endif}
    //start timer or repeat check.
    if FRandom then begin
      iNext:=GetNextRandomImageIndex();
    end else begin
      iNext:=GetNextImageIndex(Current);
    end;
    if (iNext > -1) then begin
      //start interval timer
      {$ifdef Mydebug}
      OutputDebugString(PChar(TrimRight( 'TimerFadeInTimer: ->Next:' + intToStr(iNext) )));
      {$endif}
      TimerInterval.Enabled:=true;

      //TODO preLoading.

    end else begin
        //todo debug this.
      {$ifdef Mydebug}
      OutputDebugString(PChar(TrimRight( 'TimerFadeInTimer: ->PlaybackRepeatStart')));
      {$endif}
      PlaybackRepeatStart();
    end;

  end;
end;

procedure TfrmFullscreen.TimerIntervalTimer(Sender: TObject);
begin
  if FEffect then begin
    TimerFadeOut.Enabled:=true;
  end else begin
    PlaybackPlay(false);
  end;
end;

procedure TfrmFullscreen.TimerFadeOutTimer(Sender: TObject);
begin
  if FFileList.Count = 0 then
  begin
    TimerInterval.Enabled:=false;
    TimerFadeOut.Enabled:=false;
    //close;
    exit;
  end else if FFileList.Count = 1 then
  begin
    TimerInterval.Enabled:=false;
    TimerFadeOut.Enabled:=false;
    exit;
  end;

  TimerInterval.Enabled:=false;;

  if self.AlphaBlendValue > 12 then
  begin
    if (self.AlphaBlendValue > 128 ) then begin
      self.AlphaBlendValue := self.AlphaBlendValue - 4;
    end else
    begin
      if (self.AlphaBlendValue  < 20) then begin
        self.AlphaBlendValue := 10;
      end else begin
        self.AlphaBlendValue := self.AlphaBlendValue - 15;
      end;
    end;
  end else begin
    TimerFadeOut.Enabled:=false;
    //Display
    {$ifdef Mydebug}
    OutputDebugString(PChar(TrimRight( 'TimerFadeOutTimer: ->PlaybackPlay' )));
    {$endif}
    PlaybackPlay(false);
    {$ifdef Mydebug}
    //OutputDebugString(PChar(TrimRight( 'TimerFadeOutTimer: ->(PlaybackPlay)TimerFadeIn' )));
    {$endif}
    //TimerFadeIn.Enabled:=true;
  end;
end;

function TfrmFullscreen.GetNextImageIndex(id:integer):integer;
begin
  if ValidateFileIndex(id) then begin
    if (id = (FFileList.Count-1)) then
    begin
      //end of the list. There is no NEXT.
      result:=-1;
    end else if (id > (FFileList.Count-1)) then
    begin
      //TODO close? or ...
      result:=-1;
    end else begin
      //just next.
      result:=id+1;
    end;
  end else
  begin
    //something went wrong.
    //OutputDebugString(PChar(TrimRight('GetNextImageIndex:(id): ValidateFileIndex FAILED: '+intToStr(id))));
    result:=-1;
  end;
end;

function TfrmFullscreen.GetNextRandomImageIndex():integer;
var
  r:integer;
begin
  result:=-1;
  if FFileList.Count = 0 then begin
    exit;
  end;
  if (FFileListRemaining.Count = 0) then
  begin
    exit;
  end;
  if FFileListRemaining.Count = 1 then
  begin
    result:=FFileList.IndexOf(FFileListRemaining[0]);
    exit;
  end;
  r:= Random(FFileListRemaining.Count-1);
  result:=FFileList.IndexOf(FFileListRemaining[r]);
end;

function TfrmFullscreen.GetPreviousImageIndex(id:integer):integer;
begin
  if FRandom then
  begin
    if FFileListHistory.Count > 0 then begin

      //saving for the "next"
      FFileListRemaining.Insert(0,FFileListHistory[FFileListHistory.Count-1]);
      //delete current?
      if ((FFileListHistory.Count-1) > 0) then
      begin
        FFileListHistory.Delete(FFileListHistory.Count-1);
      end;
      result := FFileList.IndexOf(FFileListHistory[FFileListHistory.Count-1]);
      //delete for the future?
      if ((FFileListHistory.Count-1) > 0) then
      begin
        FFileListHistory.Delete(FFileListHistory.Count-1);
      end;
    end else begin
      result:=id;
    end;
  end else
  begin
    if ValidateFileIndex(id) then begin
      if (id <= 0) then
      begin
        //beggining of the list. There is no PREVIOUS.
        result:=-1;
      end else
      begin
        result:=id-1;
      end;
    end else
    begin
      //something went wrong.
      //OutputDebugString(PChar(TrimRight('GetNextImageIndex:(id): VALIDATE: '+intToStr(id))));
      result:=-1;
    end;
  end;
end;

procedure TfrmFullscreen.Image1DblClick(Sender: TObject);
begin
  close;
  //TODO or...
end;

procedure TfrmFullscreen.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbRight) then
  begin
    PopupMenu1.PopUp;
  end;
end;

procedure TfrmFullscreen.MenuItemExpandClick(Sender: TObject);
begin
  if FStretch then FStretch:=false;
  if FExpand then begin
     FExpand :=false;
  end else begin
     FExpand :=true;
  end;

  if not Assigned(Image1.Picture) then exit;
  Image1.Stretch:=FExpand;
  Image1.Refresh;
end;

procedure TfrmFullscreen.MenuItemFitClick(Sender: TObject);
begin
  if FStretch then FStretch:=false;
  if FFit then begin
     FFit :=false;
     Image1.StretchInEnabled:=false;
  end else begin
     FFit :=true;
     Image1.StretchInEnabled:=true;
  end;

  if not Assigned(Image1.Picture) then exit;
  Image1.Refresh;
end;

procedure TfrmFullscreen.MenuItemStretchBothClick(Sender: TObject);
begin
  if FFit then FFit:=false;
  if FExpand then FExpand:=false;
  if FStretch then begin
     FStretch :=false;
     Image1.StretchInEnabled:=false;
  end else begin
     FStretch :=true;
     Image1.StretchInEnabled:=true;
  end;
  Image1.Stretch:=FStretch;
  Image1.Refresh;
end;

procedure TfrmFullscreen.MenuItemQuitClick(Sender: TObject);
begin
  close;
end;

procedure TfrmFullscreen.MenuItemBackClick(Sender: TObject);
begin
  PlaybackBack(sender);
end;

procedure TfrmFullscreen.MenuItemNextClick(Sender: TObject);
begin
  PlaybackNext(sender);
end;

procedure TfrmFullscreen.MenuItemPauseClick(Sender: TObject);
begin
  PlaybackPause(sender);
end;

procedure TfrmFullscreen.MenuItemEffectClick(Sender: TObject);
begin
  //consider timers.
  if FEffect then begin
    if TimerFadeOut.Enabled then begin
       TimerFadeOut.Enabled:=false;
       PlaybackPlay(false);
    end;
    if TimerFadeIn.Enabled then begin

    end;
    self.AlphaBlendValue:=255;
    FEffect:=false;
  end else begin
    FEffect:=true;
  end;
end;

procedure TfrmFullscreen.MenuItemRandomClick(Sender: TObject);
begin
  if FRandom then
  begin
    FRandom:=false;
    //play first image.
    TimerInterval.tag:=0;
  end else
  begin
    FRandom:=true;
  end;
end;

procedure TfrmFullscreen.MenuItemRepeatClick(Sender: TObject);
begin
  if FRepeat then begin
    FRepeat:=false;
  end else begin
    FRepeat:=true;

    if (not TimerInterval.Enabled) and
    (not TimerFadeIn.Enabled) and
    (not TimerFadeOut.Enabled) then  //gotta be a better way to check if it's the end of list...
    begin
      PlaybackRepeatStart();
    end;
  end;
end;

procedure TfrmFullscreen.PopupMenu1Popup(Sender: TObject);
begin
  if FStretch then
  begin
    MenuItemStretchBoth.checked:=true;
  end else
  begin
    MenuItemStretchBoth.checked:=false;
  end;

  if Ffit then
  begin
    MenuItemFit.checked:=true;
  end else
  begin
    MenuItemFit.checked:=false;
  end;

  if FExpand then
  begin
    MenuItemExpand.checked:=true;
  end else
  begin
    MenuItemExpand.checked:=false;
  end;

  if FEffect then
  begin
    MenuItemEffect.checked:=true;
  end else
  begin
    MenuItemEffect.checked:=false;
  end;

  if FRepeat then
  begin
    MenuItemRepeat.Checked:=true;
  end else
  begin
    MenuItemRepeat.Checked:=false;
  end;

  if FRandom then
  begin
    MenuItemRandom.Checked:=true;
  end else
  begin
    MenuItemRandom.Checked:=false;
  end;

  if screen.MonitorCount <= 1 then begin
    MenuItemMoniters.Visible:=false;
  end;

end;

procedure TfrmFullscreen.ChangeMoniterClicked(Sender: TObject);
begin
  frmMain.OptIntMoniter:= TMenuItem(Sender).Tag;
  ShowFullScreen(FisFullScreen);
end;

procedure TfrmFullscreen.ChangeIntervalClicked(Sender: TObject);
begin
  Finterval:= TMenuItem(Sender).Tag * 1000;
  TimerInterval.Interval:=Finterval;
end;

procedure TfrmFullscreen.ChangeMinFileSizeClicked(Sender: TObject);
begin
  FMinimulFileSizeKiloByte := TMenuItem(Sender).Tag;
  {
  TimerFadeIn.Enabled:=false;
  TimerFadeOut.Enabled:=false;
  TimerInterval.Enabled:=false;

  FMinimulFileSizeKiloByte := TMenuItem(Sender).Tag;
  FFilelist.Clear;
  FFilelist.Assign(frmMain.FileList);

  if FEffect then
  begin
    TimerFadeOut.Enabled:=true;
  end else
  begin
    TimerInterval.Enabled:=true;
  end;}
end;

procedure TfrmFullscreen.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Key = VK_F11) or (Key = VK_ESCAPE)) then
  begin
    close;
  end;

  //TODO pop up?
  //VK_RMENU
  //VK_LMENU

  if FManualTransition then begin

    //next
    if (Key = VK_RIGHT) then begin
      PlaybackNext(sender);
    end;
    //back
    if (Key = VK_LEFT) or (Key = VK_BACK) then begin
      PlaybackBack(sender);
    end;
    //pause/start
    if (Key = VK_PAUSE) or (Key = VK_SPACE) then
    begin
      PlaybackPause(sender);
    end;
  end;
end;

procedure TfrmFullscreen.FormMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if FManualTransition then begin
     PlaybackNext(sender);
     Handled:=true;
  end;
end;

procedure TfrmFullscreen.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if FManualTransition then begin
     PlaybackBack(sender);
     Handled:=true;
  end;
end;

procedure TfrmFullscreen.FormPaint(Sender: TObject);
begin
  Screen.UpdateScreen;
  self.Cursor:=crNone;
  Screen.Cursor:=crNone;
  Screen.UpdateScreen;
end;

procedure TfrmFullscreen.ShowFullScreen(AValue: boolean);
begin

  {$ifdef windows}
  SetFullScreen_Win32(AValue);
  {$else}
  SetFullScreen_Universal(AValue);
  {$endif}
  FisFullscreen:=AValue;

end;

procedure TfrmFullscreen.SetFullScreen_Universal(AValue: boolean);
begin

  if AValue then
  begin
    FOrigWndState:= WindowState;
    BorderStyle:= bsNone;
    WindowState:=wsFullScreen;
    ShowWindow(Handle, SW_SHOWFULLSCREEN)
  end else
  begin
    ShowWindow(Handle, SW_SHOWNORMAL);
    WindowState:= FOrigWndState;
    BorderStyle:= bsSizeable;
  end;

end;

procedure TfrmFullscreen.SetFullScreen_Win32(AValue: boolean);
begin
  if AValue then
  begin
    FOrigWndState:= WindowState;
    FOrigBounds:= BoundsRect;
    BorderStyle:= bsNone;
    WindowState:=wsFullScreen;
    BoundsRect:= Screen.Monitors[frmMain.OptIntMoniter].BoundsRect;
  end
  else
  begin
    WindowState:= FOrigWndState;
    BoundsRect:= FOrigBounds;
    BorderStyle:= bsSizeable;
    BoundsRect:= FOrigBounds; //again
  end;
end;

procedure TfrmFullscreen.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
end;



end.

