
unit module Sys::W::WikiPage:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;

  use Sys::Database;

  class X::Sys::W::WikiPage is Exception {
    has $.msg-id; #message class
    has $.msg-no; #message number
    has $.msg-ty; #message type = [A, E, I, S, W]
    has $.msg-t1; #message text 1
    has $.msg-t2; #message text 2
    has $.msg-t3; #message text 3
    has $.msg-t4; #message text 4

    method message() {
      #-- TODO: Get the message from the data dictionary

      "$.msg-id" ~ "-" ~ $.msg-no ~ " " ~
      "$.msg-ty " ~
      "$.msg-t1 $.msg-t2 $.msg-t3 $.msg-t4"; # Generic error
    }
  }


class Sys::W::WikiPage is export {
    has %.params = ();
    has $.Sys is rw =  '';
    has $.DebugInfo is rw = "";
    has %.Config is rw;
    has $.UserID is rw;
    has $.UserCommand is rw;

    has Str %.CMD = (
        "init" => "INIT"
    );

    has $SCREEN = "";
    has %SCREEN_TITLE = (
      1000 => "TESTING_1000";
    );
    method main($System, Str :$userid, Str :$ucomm, :%params) {
    	$.Sys = $System;
    	$.UserID = $userid;
    	$.UserCommand = $ucomm;
    	%.params = %params;
    	given $ucomm {
    		when %.CMD<init> {
    			#self.initialize-db();
    			$SCREEN = '1000';
    		}
    	}
    	self.goto-screen(screen => $SCREEN);
    }
    method goto-screen(Str :$screen) {
      my Str $sNextScreen = 'screen_' ~ $screen;
      if self.can($sNextScreen) {
        self."$sNextScreen"();
      }
    }
    method screen_1000 {
      my Str $comment = '';
      my $button-pressed = %.params<BUTTON>;
      my Str $home = '<a href="/home">home</a>';

      if %.params<COMMENT> ne '' {
        $comment = %.params<COMMENT>; 
      }

      $.Sys.FT(tag => 'PAGE_TITLE', text => 'The quick brown fox jumps over the lazy dog');

      $.Sys.FT(tag => 'SITE_LOGO', text => 'site-logo');
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => 'whoami');
      #$.Sys.FT(tag => 'WIKIMENU_BAR', text => 'Something WIKIMENU_BAR');


      $.Sys.FORM-STRING(text => '&nbsp;');
      $.Sys.FORM-BUTTON(key => 'BUTTON', 
                       value => 'First', 
                       type => 'submit'); 
      $.Sys.FORM-STRING(text => '&nbsp;');
      $.Sys.FORM-BUTTON(key => 'BUTTON', 
                       value => 'Previous', 
                       type => 'submit'); 
      $.Sys.FORM-STRING(text => '&nbsp;');
      $.Sys.FORM-BUTTON(key => 'BUTTON', 
                       value => 'Next', 
                       type => 'submit'); 
      $.Sys.FORM-STRING(text => '&nbsp;');
      $.Sys.FORM-BUTTON(key => 'BUTTON', 
                       value => 'Last', 
                       type => 'submit'); 
      $.Sys.FORM-BREAK();
      $.Sys.FORM-BREAK();
      $.Sys.FORM-STRING(text => 'Say something');
      $.Sys.FORM-BREAK();
      $.Sys.FORM-LABEL(key => 'USER-COMMENT', value => 'Comment: ');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-TEXT(key => 'COMMENT', value => $comment, size => '75', length => '50'); 
      $.Sys.FORM-BREAK();
      $.Sys.FORM-STRING(text => 'You pressed button <b>' ~ $button-pressed ~ '</b>');

      self.message('You pressed button <b>' ~ $button-pressed ~ '</b>');


      return True;
    }
    method initialize-config(:%cfg) {
      %.Config = %cfg;
    }
    method message(Str $info, Str :$type = 'I') {
      $.Sys.message($info, type => $type);
    }
   method get(Str :$key) {
      my $sVar = '';
      $sVar ~~ s:g/\{\{$key\}\}//;
      if $sVar eq '' {
        #-- get $sVar from config file
        $sVar = %.Config{$key} if defined %.Config{$key};
        $sVar ~~ s:g/\{(.*?)\}/{ #-- Convert embedded variables
          self.get(key => $0.Str);    #-- for example: data_dir = ./{SID}{SID_NR}/some_value
        }/;                      #--    translates to:        ./DEV00/some_value
      }
    return $sVar;
    }
    method getenv(Str :$key) {
      my $sVar =  '';
      $sVar = %*ENV{$key.uc} if defined %*ENV{$key};
      return $sVar;
    }


method TRACE(Str $msg, :$id = "", :$no = "001", :$ty = "I", :$t1 = "", :$t2 = "", :$t3 = "", :$t4 = "" ) {
      my Str $sInfo = "";

      $sInfo = $t1;
      $sInfo = $t1 ~ $msg.Str if $msg ne "";

      $.DebugInfo ~= $id ~ "-" ~ $no ~ " " ~ $ty ~ " ";
      $.DebugInfo ~= $msg ~ "<br/>" if $msg ne "";


  my $e = X::Sys::W::WikiPage.new(
        msg-id => $id, msg-no => $no, msg-ty => $ty,
        msg-t1 => $sInfo, msg-t2 => $t2, msg-t3 => $t3,msg-t4 => $t4);
        note $e.message;
    }
};

