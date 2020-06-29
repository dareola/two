
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
    constant $C_ICON_FIND = 'themes/img/icons/find.png';

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
          elsif defined %.Params<find> { #-- button "Find" was pressed
            $.UserCommand = 'SEARCH';
          }
          elsif defined %.Params<search> { #-- button "Display user" was pressed
            $.UserCommand = 'SEARCH';
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

      #self.TRACE: 'NEXT SCREEN TO CALL: ' ~ $next-screen;
      #self.TRACE: 'PARAMS: ' ~ $.Params.Str;

      $method-to-call = $cmd.uc ~ '_SCREEN_' ~ $next-screen;

      #self.TRACE: 'METHOD TO CALL: ' ~ $method-to-call;

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


    method INIT_SCREEN_1000 {
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

      $.Sys.FORM-SPACE;

      $.Sys.FORM-IMG-BUTTON(key => 'press-find',
                            src => $C_ICON_FIND,
                            alt => 'Search user');


      $.Sys.FORM-BREAK();
      $.Sys.FORM-BREAK();

      $.Sys.FORM-STRING(text => 'Please key in user registration data:');
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


    method REGISTER_SCREEN_1000() {
      my Str $home-link = '';
      my Str $home-base-link = '';
      my Str $index-link = '';
      my Str $help-link = '';
      my Str $login-link = '';
      my Str $logout-link = '';

      $home-base-link = '<a href="/home">home</a>' ~ '&nbsp;';

      my Str $system-date = $.Sys.Dbu.system-date();
      my Str $system-time = $.Sys.Dbu.system-time();

      my %wRegister = $.Sys.Dbu.structure( #- input/output structure
        fields => ['clntnum', 'langiso', 'usercod', 'passwrd', 'firstnm', 'lastnam'] 
      );

      $.Sys.Dbu.clear(fields => %wRegister);

      #-- Capture input from parameter
      %wRegister<clntnum> = %.Params<CLNTUSER-CLNTNUM>.Str if defined %.Params<CLNTUSER-CLNTNUM>;
      %wRegister<langiso> = %.Params<CLNTUSER-LANGISO>.Str if defined %.Params<CLNTUSER-LANGISO>;
      %wRegister<usercod> = %.Params<CLNTUSER-USERCOD>.Str if defined %.Params<CLNTUSER-USERCOD>;
      %wRegister<passwrd> = %.Params<PASSWORD>.Str if defined %.Params<PASSWORD>;
      %wRegister<firstnm> = %.Params<USERMSTR-FIRSTNM>.Str if defined %.Params<USERMSTR-FIRSTNM>;
      %wRegister<lastnam> = %.Params<USERMSTR-LASTNAM>.Str if defined %.Params<USERMSTR-LASTNAM>;

      #-- Move the input to table structures
      my %wCLNTUSER = $.Sys.Dbu.table-structure(tabname => 'CLNTUSER');
      my %wUSERMSTR = $.Sys.Dbu.table-structure(tabname => 'USERMSTR');
      my %wCLNTUSER_WHERE = $.Sys.Dbu.structure(fields =>['clntnum', 'actvatd', 'usercod']);

      #-- populate USERMSTR
      %wUSERMSTR<usercod> = %wRegister<usercod>;
      %wUSERMSTR<firstnm> = %wRegister<firstnm>;
      %wUSERMSTR<lastnam> = %wRegister<lastnam>;
      %wUSERMSTR<actvatd> = 'A';
      %wUSERMSTR<changby> = 'SYSTEM'; 
      %wUSERMSTR<changdt> = $system-date;
      %wUSERMSTR<changtm> = $system-time;

      #-- populate CLNTUSER
      %wCLNTUSER<clntnum> = %wRegister<clntnum>;
      %wCLNTUSER<actvatd> = 'A';
      %wCLNTUSER<usercod> = %wRegister<usercod>;
      %wCLNTUSER<usrlock> = '0';
      %wCLNTUSER<langiso> = %wRegister<langiso>;
      %wCLNTUSER<passwrd> = %wRegister<passwrd>;
      %wCLNTUSER<changby> = 'SYSTEM';
      %wCLNTUSER<changdt> = $system-date;
      %wCLNTUSER<changtm> = $system-time;

      #-- set primary keys
      %wCLNTUSER_WHERE<clntnum> = %wCLNTUSER<clntnum>;
      %wCLNTUSER_WHERE<actvatd> = %wCLNTUSER<actvatd>;
      %wCLNTUSER_WHERE<usercod> = %wCLNTUSER<usercod>;


      $home-link = '<a href="/user">Register</a>' ~ '&nbsp;';

      $.Sys.FT(tag => 'PAGE_TITLE', text => 'Save user registration data');
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

        $.Sys.FORM-BREAK();
        $.Sys.FORM-BREAK();

        my @iCLNTUSER = ();
        my @iUSERMSTR = ();

        @iCLNTUSER = $.Sys.Dbu.table-query(tabname => 'CLNTUSER',
                                      fields => %wCLNTUSER,
                                      where => %wCLNTUSER_WHERE);

        if (@iCLNTUSER.elems) {
          $.Sys.FORM-STRING( text => 'User record for ' ~ %wCLNTUSER<clntnum> ~ '/' 
                              ~ %wCLNTUSER<usercod> ~ ' found');

          self.message: 'Save failed, data already exists in the database';
          $.Sys.FT(tag => 'WIKIMENU_BAR', text => $home-base-link);

        }
        else {
          @iUSERMSTR = ();
          $.Sys.Dbu.append-table(@iUSERMSTR, %wUSERMSTR);
          my Str $insert-usermstr = $.Sys.Dbu.db-insert(table => 'USERMSTR', data => @iUSERMSTR);
          #self.TRACE: 'SQL: ' ~ $insert-usermstr;
          $.Sys.Dbu.db-execute(sql => $insert-usermstr);

          @iCLNTUSER = ();
          $.Sys.Dbu.append-table(@iCLNTUSER, %wCLNTUSER);
          my Str $insert-clntuser = $.Sys.Dbu.db-insert(table => 'CLNTUSER', data => @iCLNTUSER);
          $.Sys.Dbu.db-execute(sql => $insert-clntuser);
          #self.TRACE: 'SQL: ' ~ $insert-clntuser;

          $.Sys.FORM-STRING( text => 'User record ' ~ %wCLNTUSER<clntnum> ~ '/' 
                              ~ %wCLNTUSER<usercod> ~ ' saved successfully.');
          
          $.Sys.FT(tag => 'WIKIMENU_BAR', text => $home-base-link);

          self.message: 'Data saved successfully.';

        }

      }
      else {
        $.Sys.FORM-BREAK();
        $.Sys.FORM-BREAK();
        for %wRegister -> $kv {
          if $kv.value eq '' {
            my Str $fldname = '';
            if $kv.key eq 'lastnam' || $kv.key eq 'firstnm' {
              $fldname = 'USERMSTR-' ~ $kv.key.uc;
            }
            else {
              $fldname = 'CLNTUSER-' ~ $kv.key.uc;
            }
            my $short-text = '';
            $short-text = $.Sys.Dbu.field-text(field => $fldname, type => 'S');
            $.Sys.FORM-STRING(text => 'Error: <b>' ~ $short-text ~ '</b> field is blank, input is required');
            $.Sys.FORM-BREAK(); 
          }
        }
        $.Sys.FT(tag => 'WIKIMENU_BAR', text => $home-base-link);

        self.message: 'Error saving data - required input fiels are not complete';
      }
      
    }


    method SEARCH_SCREEN_1000() {
      my Str $home = '<a href="/home">home</a>';
      
      if defined %.Params<find> {
        $.Sys.FT(tag => 'PAGE_TITLE', text => 'Find user');
      }
      elsif defined %.Params<search> {
        $.Sys.FT(tag => 'PAGE_TITLE', text => 'Display user data');
      }
      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);

      if defined %.Params<find> {
        $.Sys.FORM-IMG-BUTTON(key => 'press-search',
                              src => $C_ICON_FIND,
                              alt => 'Display user');
        $.Sys.FORM-SPACE();
        $.Sys.FORM-IMG-BUTTON(key => 'press-register',
                          src => $C_ICON_REGISTER,
                          alt => 'Register new user');

        $.Sys.FORM-BREAK();
        $.Sys.FORM-BREAK();
        $.Sys.FORM-STRING(text => 'DISPLAY CLIENT, USER fields');

        $.Sys.FORM-BREAK();
        $.Sys.FORM-BREAK();

        my $clntnum-text = $.Sys.Dbu.field-text(field => 'CLNTUSER-CLNTNUM', type => 'S');
        $.Sys.FORM-STRING(text => $clntnum-text);
        $.Sys.FORM-SPACE;

        my %wSelectOptions = ();
        $.Sys.FORM-SELECT(key => 'CLNTUSER-CLNTNUM',
                          value => '000',
                          options => %wSelectOptions,
                          label => 'Client number');

        $.Sys.FORM-BREAK();

        my $usercod-text = $.Sys.Dbu.field-text(field => 'CLNTUSER-USERCOD', type => 'S');
        $.Sys.FORM-STRING(text => $usercod-text);

        $.Sys.FORM-SPACE;
        $.Sys.FORM-TEXT(key => 'CLNTUSER-USERCOD', value => '', size => '18', length => '18'); 


      }
      elsif defined %.Params<search> {
        $.Sys.FORM-IMG-BUTTON(key => 'press-find',
                              src => $C_ICON_FIND,
                              alt => 'Find user');
        $.Sys.FORM-SPACE();
        $.Sys.FORM-IMG-BUTTON(key => 'press-register',
                          src => $C_ICON_REGISTER,
                          alt => 'Register new user');


        $.Sys.FORM-BREAK();
        $.Sys.FORM-BREAK();


        my %wUser = $.Sys.Dbu.structure( #- input/output structure
          fields => ['clntnum', 'usercod', 'actvatd'] 
        );

        %wUser<clntnum> = %.Params<CLNTUSER-CLNTNUM>.Str if defined %.Params<CLNTUSER-CLNTNUM>;
        %wUser<usercod> = %.Params<CLNTUSER-USERCOD>.Str if defined %.Params<CLNTUSER-USERCOD>;
        %wUser<actvatd> = 'A';

        #$.Sys.FORM-BREAK();
        #$.Sys.FORM-STRING(text => %wUser<clntnum>);
        #$.Sys.FORM-STRING(text => %wUser<usercod>);
        #$.Sys.FORM-STRING(text => %wUser<actvatd>);

        my %wCLNTUSER = $.Sys.Dbu.table-structure(tabname => 'CLNTUSER');
        my %wUSERMSTR = $.Sys.Dbu.table-structure(tabname => 'USERMSTR');

        my %wCLNTUSER_WHERE = $.Sys.Dbu.structure(fields =>['clntnum', 'actvatd', 'usercod']);
        my %wUSERMSTR_WHERE = $.Sys.Dbu.structure(fields =>['usercod', 'actvatd']);

        %wCLNTUSER_WHERE<clntnum> = %wUser<clntnum>;
        %wCLNTUSER_WHERE<actvatd> = %wUser<actvatd>;
        %wCLNTUSER_WHERE<usercod> = %wUser<usercod>;

        %wUSERMSTR_WHERE<usercod> = %wUser<usercod>;
        %wUSERMSTR_WHERE<actvatd> = %wUser<actvatd>;

        my @iCLNTUSER = ();
        my @iUSERMSTR = ();

        @iCLNTUSER = $.Sys.Dbu.table-query(tabname => 'CLNTUSER',
                                      fields => %wCLNTUSER,
                                      where => %wCLNTUSER_WHERE);

        if (@iCLNTUSER.elems) {
          $.Sys.FORM-BREAK();
          for @iCLNTUSER -> $clntuser {
            my %clntuser = $clntuser;
            for %clntuser -> $kv {
              if $kv.key ne 'passwrd' {
                my $short-text = '';
                my $fldname = 'CLNTUSER-' ~ $kv.key.uc;
                $short-text = $.Sys.Dbu.field-text(field => $fldname, type => 'S');
                $.Sys.FORM-STRING(text => $short-text);
                $.Sys.FORM-SPACE();
                $.Sys.FORM-STRING(text => '&nbsp;&nbsp;=&nbsp;&nbsp;');
                $.Sys.FORM-STRING(text => $kv.value);
                $.Sys.FORM-BREAK();
              }
            }
          }
          $.Sys.FORM-BREAK();


          @iUSERMSTR = $.Sys.Dbu.table-query(tabname => 'USERMSTR',
                                             fields => %wUSERMSTR,
                                             where => %wUSERMSTR_WHERE);
          $.Sys.FORM-BREAK();
          if (@iUSERMSTR.elems) {
            for @iUSERMSTR -> $usermstr {
              my %usermstr = $usermstr;
              for %usermstr -> $kv {
                

                my $short-text = '';
                my $fldname = 'USERMSTR-' ~ $kv.key.uc;
                $short-text = $.Sys.Dbu.field-text(field => $fldname, type => 'S');

                $.Sys.FORM-STRING(text => $short-text);
                $.Sys.FORM-SPACE();
                $.Sys.FORM-STRING(text => '&nbsp;&nbsp;=&nbsp;&nbsp;');
                $.Sys.FORM-STRING(text => $kv.value);
                $.Sys.FORM-BREAK();

              }
            }
          }
        }
        else {
          $.Sys.FORM-BREAK();
          $.Sys.FORM-STRING(text => 'USER DATA DOES NOT EXISTS');
        }

        #$.Sys.FORM-BREAK();
        #$.Sys.FORM-BREAK();
        #$.Sys.FORM-STRING(text => 'Query database and display user information');

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

