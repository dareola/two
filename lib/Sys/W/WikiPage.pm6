
unit module Sys::W::WikiPage:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;
  use Base64::Native;
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
    has %.Params = ();
    has $.Sys is rw =  '';
    has $.DebugInfo is rw = "";
    has %.Config is rw;
    has $.UserID is rw;
    has $.UserCommand is rw;
    has $.CurrentWikiPage is rw = '';

    constant $C_ICON_EDIT = 'themes/img/icons/page_edit.png';
    constant $C_ICON_SAVC = 'themes/img/icons/script_save.png';
    constant $C_ICON_SAVE = 'themes/img/icons/disk.png';
    constant $C_ICON_CANC = 'themes/img/icons/cross.png';

    has Str %.CMD = (
        "init" => "INIT"
    );

    has $SCREEN = "";
    has %SCREEN_TITLE = (
      1000 => "TESTING_1000";
    );

    has %.SCREEN = (
      'init' => '1000',
      'register' => '2000',
      'save' => '3000',
      'savc' => '4000'
    );
method main($App, Str :$userid, Str :$ucomm, :%params) {
    $.Sys = $App;
    $.UserID = $userid;
    $.UserCommand = $ucomm;
    %.Params = %params;

  my $next-screen = '';
    given $ucomm {
	    when %.CMD<init> {
		    #self.initialize-db();
		    $SCREEN = '1000';
	    }
    }
    if defined %.Params<save> {
      $.UserCommand = 'INIT';
    }
  
    self.goto-screen(cmd => $.UserCommand, screen => $next-screen);
}

    method goto-screen(Str :$cmd, Str :$screen = '') {
      
      my Str $next-screen = '';
      my Str $method-to-call = '';
      if $screen ne '' {
        $next-screen = $screen;
      }
      else {
        $next-screen = %.SCREEN{"$cmd"}.Str if defined %.SCREEN{"$cmd"};
        $next-screen = '1000' if $next-screen eq '';
      }

      self.TRACE: 'PARAMS: ' ~ $.Params.Str;

      $method-to-call = $cmd.uc ~ '_SCREEN_' ~ $next-screen;

      if self.can($method-to-call) {
        self."$method-to-call"();
      }
      else {
        self.SCREEN_NOT_FOUND_1000(cmd => $method-to-call);
      }
    }
    method SCREEN_NOT_FOUND_1000(Str :$cmd = '') {
      my Str $home-link = '';

      $home-link = '<a href="/home">Exit</a>' ~ '&nbsp;';

      $.Sys.FT(tag => 'PAGE_TITLE', text => 'Error: method <b>' ~ $cmd ~ '</b> not implemented');
      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'MENU_BAR', text => $home-link);       
    }


    method INIT_SCREEN_1000 {
      my Str $home = '<a href="/home">home</a>';
      my Str $edit = ''; 
      my Str $logout-link = '';
      my Str $login-link = '';
      my Str $wiki-name = '';
      $wiki-name = $.Sys.get(key => 'WIKI_NAME');

      $logout-link = '<a href="/logout">Logout</a>' if $.UserID ne '';
      $login-link = '<a href="/login">Login</a>' if $.UserID eq '';

      $.Sys.FT(tag => 'PAGE_TITLE', text => $wiki-name);

      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'WIKIMENU_BAR', text => $login-link ~ $logout-link);

      $.CurrentWikiPage = $.Sys.get(key => 'WIKI_HOME');
      $.CurrentWikiPage = %.Params<p> if defined %.Params<p> && %.Params<p> ne '';

      $edit = '&nbsp;|&nbsp;<a href="/wiki/edit?p=' 
            ~ $.CurrentWikiPage ~ '">edit</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $edit); # if $.UserID ne '';

      return True;
    }


method EDIT_SCREEN_1000() {
        my Str $home = '<a href="/wiki">home</a>';
      my Str $cancel = ''; 
      my Str $logout-link = '';
      my Str $login-link = '';
      my Str $wiki-name = '';
      $wiki-name = $.Sys.get(key => 'WIKI_NAME');

      $logout-link = '<a href="/logout">Logout</a>' if $.UserID ne '';
      $login-link = '<a href="/login">Login</a>' if $.UserID eq '';

      $.Sys.FT(tag => 'PAGE_TITLE', text => $wiki-name);

      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'WIKIMENU_BAR', text => $login-link ~ $logout-link);

      $.CurrentWikiPage = $.Sys.get(key => 'WIKI_HOME');
      $.CurrentWikiPage = %.Params<p> if defined %.Params<p> && %.Params<p> ne '';
  
  

      #$.Sys.FORM-SPACE();

      $.Sys.FORM-IMG-BUTTON(key => 'press-savc',
                            src => $C_ICON_SAVC,
                            alt => 'Save and continue editing');
      
      $.Sys.FORM-SPACE();

      $.Sys.FORM-IMG-BUTTON(key => 'press-save',
                            src => $C_ICON_SAVE,
                            alt => 'Save then exit editor');

      $.Sys.FORM-BREAK();
      $.Sys.FORM-BREAK();

      $.Sys.FORM-TEXTAREA(key => 'text', 
                        value => 'BLANK for now',
                        rows => 25,
                        cols => 65);


      $cancel = '&nbsp;|&nbsp;<a href="/wiki/display?p=' 
            ~ $.CurrentWikiPage ~ '">cancel</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $cancel); # if $.UserID ne '';


  return True;
}




    method DISPLAY_SCREEN_1000 {
      my Str $home = '<a href="/home">home</a>';
      my Str $edit = ''; 
      my Str $logout-link = '';
      my Str $login-link = '';
      my Str $wiki-name = '';
      $wiki-name = $.Sys.get(key => 'WIKI_NAME');

      $logout-link = '<a href="/logout">Logout</a>' if $.UserID ne '';
      $login-link = '<a href="/login">Login</a>' if $.UserID eq '';

      $.Sys.FT(tag => 'PAGE_TITLE', text => $wiki-name);

      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'WIKIMENU_BAR', text => $login-link ~ $logout-link);

      $.CurrentWikiPage = $.Sys.get(key => 'WIKI_HOME');
      $.CurrentWikiPage = %.Params<p> if defined %.Params<p> && %.Params<p> ne '';

      $edit = '&nbsp;|&nbsp;<a href="/wiki/edit?p=' 
            ~ $.CurrentWikiPage ~ '">edit</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $edit); # if $.UserID ne '';

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


method TRACE(Str $msg, :$id = "W1", :$no = "001", :$ty = "I", :$t1 = "", :$t2 = "", :$t3 = "", :$t4 = "" ) {
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

