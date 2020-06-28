
unit module Sys::U::UserManager:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;

  use Sys::Database;

  class X::Sys::U::UserManager is Exception {
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


class Sys::U::UserManager is export {
    has %.Params = ();
    has $.Sys is rw =  '';
    has $.DebugInfo is rw = "";
    has %.Config is rw;
    has $.UserID is rw;
    has $.UserCommand is rw;

    constant $C_ICON_LOGIN = 'themes/img/icons/key.png';
    constant $C_ICON_REGISTER = 'themes/img/icons/user_add.png';
    constant $C_ICON_SAVEREG = 'themes/img/icons/disk.png';

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
    			$SCREEN = '1000';
          #-- Detect Pressed button
          if defined %.Params<save> { #-- button "Save" was pressed
            $.UserCommand = 'REGISTER';
          } 
    		}
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

      self.TRACE: 'NEXT SCREEN TO CALL: ' ~ $next-screen;
      self.TRACE: 'PARAMS: ' ~ $.Params.Str;

      $method-to-call = 'SCREEN_'~ $cmd.uc ~ '_' ~ $next-screen;

      self.TRACE: 'METHOD TO CALL: ' ~ $method-to-call;

      if self.can($method-to-call) {
        self."$method-to-call"();
      }
      else {
        self.SCREEN_NOT_FOUND_1000(cmd => $method-to-call);
      }


      #my Str $sNextScreen = 'screen_' ~ $screen;
      #if self.can($sNextScreen) {
      #  self."$sNextScreen"();
      #}
    }

    method SCREEN_NOT_FOUND_1000(Str :$cmd = '') {
      my Str $home-link = '';
      my Str $index-link = '';
      my Str $help-link = '';
      my Str $login-link = '';
      my Str $logout-link = '';

      $home-link = '<a href="/home">Exit</a>' ~ '&nbsp;';

      $.Sys.FT(tag => 'PAGE_TITLE', text => 'Error: method <b>' ~ $cmd ~ '</b> not implemented');
      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'MENU_BAR', text => $home-link);       
    }


    method SCREEN_INIT_1000 {
      my Str $home = '<a href="/home">home</a>';
      my %wRegister = $.Sys.Dbu.structure( #- input/output structure
        fields => ['clntnum', 'langiso', 'usercod', 'passwrd', 'firstnm', 'lastnam'] 
      );

      $.Sys.Dbu.clear(fields => %wRegister);

      %wRegister<clntnum> = %.Params<CLNTUSER-CLNTNUM>.Str if defined %.Params<CLNTUSER-CLNTNUM>;
      %wRegister<langiso> = %.Params<CLNTUSER-LANGISO>.Str if defined %.Params<CLNTUSER-LANGISO>;
      %wRegister<usercod> = %.Params<CLNTUSER-USERCOD>.Str if defined %.Params<CLNTUSER-USERCOD>;
      %wRegister<passwrd> = %.Params<PASSWORD>.Str if defined %.Params<PASSWORD>;
      %wRegister<firstnm> = %.Params<USERMSTR-FIRSTNM>.Str if defined %.Params<USERMSTR-FIRSTNM>;
      %wRegister<lastnam> = %.Params<USERMSTR-LASTNAM>.Str if defined %.Params<USERMSTR-LASTNAM>;


      $.Sys.FT(tag => 'PAGE_TITLE', text => 'Register user');

      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);

      $.Sys.FORM-IMG-BUTTON(key => 'press-save',
                            src => $C_ICON_SAVEREG,
                            alt => 'Save');

      $.Sys.FORM-BREAK();
      $.Sys.FORM-BREAK();

      #-- begin: Display registration form
      #--------- clntnum    
      my $clntnum-text = $.Sys.Dbu.field-text(field => 'CLNTUSER-CLNTNUM', type => 'S');
      $.Sys.FORM-STRING(text => $clntnum-text ~ '&nbsp;*');
      $.Sys.FORM-SPACE;

      #$.Sys.FORM-TEXT(key => 'CLNTUSER-CLNTNUM', value => '', size => '3', length => '3'); 
      my %wSelectOptions = ();
      $.Sys.FORM-SELECT(key => 'CLNTUSER-CLNTNUM',
                        value => %wRegister<clntnum>,
                        options => %wSelectOptions,
                        label => 'Client number');
      #--------- usercod
      $.Sys.FORM-BREAK();
      my $usercod-text = $.Sys.Dbu.field-text(field => 'CLNTUSER-USERCOD', type => 'S');
      $.Sys.FORM-STRING(text => $usercod-text ~ '&nbsp;*');

      $.Sys.FORM-SPACE;
      $.Sys.FORM-TEXT(key => 'CLNTUSER-USERCOD', value => %wRegister<usercod>, size => '18', length => '18'); 

      #--------- firstname
      $.Sys.FORM-BREAK();

      my $firstnm-text = $.Sys.Dbu.field-text(field => 'USERMSTR-FIRSTNM', type => 'S');
      $.Sys.FORM-STRING(text => $firstnm-text ~ '&nbsp;*');

      $.Sys.FORM-SPACE;
      $.Sys.FORM-TEXT(key => 'USERMSTR-FIRSTNM', value => %wRegister<firstnm>, size => '18', length => '18'); 

      #--------- lastname
      $.Sys.FORM-BREAK();

      my $lastnam-text = $.Sys.Dbu.field-text(field => 'USERMSTR-LASTNAM', type => 'S');
      $.Sys.FORM-STRING(text => $lastnam-text ~ '&nbsp;*');

      $.Sys.FORM-SPACE;
      $.Sys.FORM-TEXT(key => 'USERMSTR-LASTNAM', value => %wRegister<lastnam>, size => '18', length => '18'); 

      #--------- passwrd
      $.Sys.FORM-BREAK();

      my $password-field = $.Sys.encrypt-field('PASSWORD');
      my $javascript = '<script type="text/javascript">' 
                    ~ "\n"
                    ~ '//<![CDATA[' 
                    ~ "\n";
        $javascript ~= $password-field 
                    ~ "\n";
        $javascript ~= $.Sys.encrypt-md5();
        $javascript ~= '//]]'
                    ~ "\n" 
                    ~ '</script>';
      $.Sys.FT(tag => 'JAVASCRIPT', text => $javascript); #-- This will insert javascript code header

      my $passwrd-text = $.Sys.Dbu.field-text(field => 'CLNTUSER-PASSWRD', type => 'S');
      $.Sys.FORM-STRING(text => $passwrd-text ~ '&nbsp;*');
      $.Sys.FORM-SPACE;

      #-- encoded password is 32 characters
      $.Sys.FORM-PASSWORD(key => 'PASSWORD',
                          value => '',
                          size => '32',
                          length => '15',
                          event => 'onChange',
                          action => 'javascript:encryptPassword_' 
                                    ~ 'PASSWORD' ~ '();'
                );

      $.Sys.FORM-BREAK();
      my $langiso-text = $.Sys.Dbu.field-text(field => 'CLNTUSER-LANGISO', type => 'S');
      $.Sys.FORM-STRING(text => $langiso-text ~ '&nbsp;*');
      $.Sys.FORM-SPACE;
      %wSelectOptions = ();
      $.Sys.FORM-SELECT(key => 'CLNTUSER-LANGISO',
                        value => 'E',
                        options => %wSelectOptions,
                        label => 'Language');


      return True;
    }


    method SCREEN_REGISTER_1000() {
      my Str $home-link = '';
      my Str $index-link = '';
      my Str $help-link = '';
      my Str $login-link = '';
      my Str $logout-link = '';

      my %wRegister = $.Sys.Dbu.structure( #- input/output structure
        fields => ['clntnum', 'langiso', 'usercod', 'passwrd', 'firstnm', 'lastnam'] 
      );

      $.Sys.Dbu.clear(fields => %wRegister);

      %wRegister<clntnum> = %.Params<CLNTUSER-CLNTNUM>.Str if defined %.Params<CLNTUSER-CLNTNUM>;
      %wRegister<langiso> = %.Params<CLNTUSER-LANGISO>.Str if defined %.Params<CLNTUSER-LANGISO>;
      %wRegister<usercod> = %.Params<CLNTUSER-USERCOD>.Str if defined %.Params<CLNTUSER-USERCOD>;
      %wRegister<passwrd> = %.Params<PASSWORD>.Str if defined %.Params<PASSWORD>;
      %wRegister<firstnm> = %.Params<USERMSTR-FIRSTNM>.Str if defined %.Params<USERMSTR-FIRSTNM>;
      %wRegister<lastnam> = %.Params<USERMSTR-LASTNAM>.Str if defined %.Params<USERMSTR-LASTNAM>;


      $home-link = '<a href="/user">Register</a>' ~ '&nbsp;';

      $.Sys.FT(tag => 'PAGE_TITLE', text => 'INITIAL SCREEN - 1000');
      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'MENU_BAR', text => $home-link);       


      my Bool $save-data = True;
      
      $save-data = False if $save-data && %wRegister<clntnum> eq '';
      $save-data = False if $save-data && %wRegister<langiso> eq '';
      $save-data = False if $save-data && %wRegister<usercod> eq '';
      $save-data = False if $save-data && %wRegister<passwrd> eq '';
      $save-data = False if $save-data && %wRegister<firstnm> eq '';
      $save-data = False if $save-data && %wRegister<lastnam> eq '';
      if $save-data {
        self.message: 'TODO: SAVE DATA';
      }
      else {
        self.message: 'TODO: CANNOT SAVE, INCOMPLETE DATA';
      }
      
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


method TRACE(Str $msg, :$id = "U1", :$no = "001", :$ty = "I", :$t1 = "", :$t2 = "", :$t3 = "", :$t4 = "" ) {
      my Str $sInfo = "";

      $sInfo = $t1;
      $sInfo = $t1 ~ $msg.Str if $msg ne "";

      $.DebugInfo ~= $id ~ "-" ~ $no ~ " " ~ $ty ~ " ";
      $.DebugInfo ~= $msg ~ "<br/>" if $msg ne "";


  my $e = X::Sys::U::UserManager.new(
        msg-id => $id, msg-no => $no, msg-ty => $ty,
        msg-t1 => $sInfo, msg-t2 => $t2, msg-t3 => $t3,msg-t4 => $t4);
        note $e.message;
    }
};

