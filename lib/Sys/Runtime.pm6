unit module Sys::Runtime:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;
use JSON::Tiny;

# VARIABLE naming conventions
# $.CamelCase = globally declared variable
# $.lower-snake-case = for methods and local variables
# $C_UPPER_CASE = constants (global)


#-- Exception handlers
class X::Runtime is Exception {
	has Str $.msg-id; #message class
	has Str $.msg-no; #message number
	has Str $.msg-ty; #message type = [A, E, I, S, W]
	has Str $.msg-t1; #message text 1
	has Str $.msg-t2; #message text 2
	has Str $.msg-t3; #message text 3
	has Str $.msg-t4; #message text 4

	method message() {
		#-- TODO: Get the message from the data dictionary
		"$.msg-id" ~ '-' 
               ~ $.msg-no 
               ~ " " 
               ~ "$.msg-ty " 
               ~ "$.msg-t1 $.msg-t2 $.msg-t3 $.msg-t4";
	}
}

class Runtime is export {

  constant $C_AUTHOR = 'Domingo Areola (dareola@gmail.com)';
  constant $C_VERSION = '0.0.0';
  constant $C_NAMESPACE = 'Sys';
	constant $C_LIBPATH = './lib';
  constant $C_DBTYPE_SQLITE = 'SQLite';

  has %.Config is rw; # Configuration environment
  has Str $.DebugInfo is rw = ''; # Debugging information
  has Str $.Page is rw = ''; # HTML page
  has $.Sys is rw; # System object
  has $.Dbu is rw; # Database object
  has $.App is rw;  # Application object
  has Str $.Shortcut is rw; # User command
  has %.Params is rw; # Parameters
  has &!callback;
 

  #--begin: Autogenerated modules (for new installation)
  has Str %.APPTABLE = ( #-- Autogenerated modules
    'SY00' => 'System',
    'DB00' => 'Database',
  );
  has Str %.APPTEXTS = ( #-- for the Exception
    'SY00' => 'S1',
    'DB00' => 'D0',
  );
  #--end: Autogenerated modules (for new installation)

  #-- begin: page templates (defaults)
	has Str $.HtmlBegin = '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">'
					~ '<html lang="en" itemscope itemtype="http://schema.org/WebPage">'
					~ '<meta charset="utf-8">'
					~ '<META NAME="viewport" CONTENT="width=device-widh, initial-scale=1.0">'
					~ '<META HTTP-EQUIV="Pragma" CONTENT="no-cache">';
	has Str $.HtmlHeaderBegin = '<head>';
	has Str $.HtmlTitleBegin = '<title>';
	has Str $.HtmlTitleEnd = '</title>';
	has Str $.HtmlHeaderEnd = '</head>';
	has Str $.HtmlBodyBegin = '<body bgcolor="#ffffff" leftmargin="0" topmargin="0" marginheight="0" marginwidth="0" '
					~ 'BGCOLOR="white">';
	has Str $.HtmlBodyEnd = '</body>';
	has Str $.HtmlEnd = '</html>';
	has Str $.AppTitle is rw = 'Untitled';
  #-- end: page templates (defaults)


  submethod BUILD(:&!callback) { #-- constructor
  }

  method new() { #-- Initialize configuration
    my %Config;
    return self.bless(:%Config);
  }

  method TWEAK() { #-- last method called to intialize instance variables 
  }

  submethod DESTROY { #-- called when instance is garbage collected
  }

  multi method TRACE(Str $msg, 
                     Str :$id = 'R1', Str :$no = '001', 
                     Str :$ty = 'I', Str :$t1 = '', 
                     Str :$t2 = '', Str :$t3 = '', 
                     Str :$t4 = '' ) {
		# T1 - Generic or general text
		my Str $info = '';
		$info = $t1;
		$info = $t1 ~ $msg.Str if defined $msg && $msg ne '';
		$.DebugInfo ~= $id ~ '-' ~ $no ~ ' ' ~ $ty ~ ' ';
		$.DebugInfo ~= $msg ~ '<br/>' if $msg ne '';
		my $e = X::Runtime.new(
						msg-id => $id, msg-no => $no, 
            msg-ty => $ty, msg-t1 => $info, 
            msg-t2 => $t2, msg-t3 => $t3,
            msg-t4 => $t4);
		note $e.message;
	}

	method set-page-heading() {
		my Str $html-heading = '';
		my Str $style-sheet = '';
    my Str $javascript = '';
    #$style-sheet = $.Sys.render(web-part => 'STYLE');
		#$javascript = $.Sys.render(web-part => 'JSCRIPT');
		$html-heading = $style-sheet
       	  				~ $javascript
			      			~ $.HtmlHeaderBegin
	  				      ~ self.set-page-title(title => $.AppTitle)
						      ~ $.HtmlHeaderEnd;
		return $html-heading;
	}


	method set-page-title(Str :$title) {
		my Str $page-title = '';
    #$.AppTitle = $.Sys.get(key => 'PAGE_TITLE');
    #self.TRACE: $.Sys.Config.Str;
		$page-title = $.HtmlTitleBegin
                ~ $.AppTitle
						    ~ $.HtmlTitleEnd if $title ne '';
		return $page-title;
	}


	method set-page-body(Str :$text = '') {
		my Str $html-body = '';
		#$.Page = $.Sys.render(web-part => 'BODY');
		$html-body = $.HtmlBodyBegin;
		$html-body ~= '<tt>' ~ $.DebugInfo ~ '</tt><hr/>' if $.DebugInfo ne '';
    $html-body ~= $text;
		$html-body ~= $.Page;
		$html-body ~= $.HtmlBodyEnd;
		return $html-body;
	}

  multi method build-html-page(Str :$text = '') {
    my Str $html-page = '';
    $html-page = $.HtmlBegin
               ~ self.set-page-heading()
               ~ self.set-page-body(text => $text)
               ~ $.HtmlEnd;
    return $html-page;
  }

  method load-config-file(Str :$file) {
    %.Config = from-json(slurp($file));
  }

  multi method dispatch(Str :$app, 
                        Str :$cmd,
                        Str :$userid,
                        :%params) {
    self.detect-button(:%params);
    self.initialize();
    self.TRACE: 'Parameters: ' ~ %.Params;

    try self.run(signature => '1',
                 app => $app,
                 cmd => $cmd,
                 userid => $userid,
                 params => %.Params);
    if ($!) {
      note $!.gist;
    }
    CATCH {
      when X::Runtime {
        note $!.gist;
      }
      default {
        $!.resume;
      }
    }      

    my Str $user = '';
    $user = $userid if $userid ne '';

    my Str $app-toolbar = '';

    $app-toolbar ~= '<a href="/">home</a>' ~ '&nbsp;|&nbsp;';
    $app-toolbar ~= '<a href="/index">index</a>' ~ '&nbsp;|&nbsp;';
    $app-toolbar ~= '<a href="/help">help</a>' ~ '&nbsp;|&nbsp;';
    $app-toolbar ~= '<a href="/login">login</a>' ~ '&nbsp;' if $user eq '';
    $app-toolbar ~= '<b>' ~ $user.uc ~ '</b>&nbsp;<a href="/logout">logout</a>' ~ '&nbsp;' if $user ne '';
    $app-toolbar ~= '<hr/>';

    if $user ne '' {
      if $app ne 'login' {
        $app-toolbar ~= self.begin-form() ~ self.user-command() ~ self.end-form() ;
        $app-toolbar ~= 'Parameters: [' ~ %.Params.Str ~ ']<br>';
      }
    }

    my Str $text = '';

    given $app {
      when 'startup' {
        $text ~= $app-toolbar;
        $text ~= '<br>WELCOME<br><br>';
      }
      when 'login' {
        $app-toolbar ~= self.begin-form(app => 'login') 
                     ~ self.user-login() 
                     ~ self.end-form() ;
        $text ~= $app-toolbar;
      }
      when 'logout' {
        $text ~= $app-toolbar;
      }
      when 'home' {
        $text ~= $app-toolbar;
      }
      when 'index' {
        $text ~= $app-toolbar;
      }
      when 'default' {
        $text ~= $app-toolbar;
      }
      when 'dispatcher' {
        $text ~= $app-toolbar;
      }
      when 'relogin' {
        $text ~= $app-toolbar;
      }
    }

    $text ~= 'User = ' ~ $user ~ '<br>' 
          ~ 'Application = ' ~ $app ~ '<br>'
          ~ 'Command = ' ~ $cmd ~ '<br>';

    return self.build-html-page(text => $text); #$text;
  }

  method initialize() {
    $.Page = '';
    $.DebugInfo = '';
  }

  method detect-button(:%params) {
    my Str $button = '';
    %.Params = ();
    for %params.kv -> $k, $v {
      $button = $k;
      if $button ~~ m:g/press\-(.+?)\.x/ {
        $button ~~ s:g/(press\-)(.+?)(\.x)/$1/;
        #%params{'fcode'} = $button;
        %.Params{"$button"} = $button;
      }
      elsif $button ~~ m:g/press\-(.+?)\.y/ {
        #-- do nothing
      }
      else {
        %.Params{"$k"} = $v;
      }
    }
  }


  method begin-form(Str :$app = '') {
    my Str $form = '';
    if $app ne '' {
      $form = '<form method="POST" action="/' ~ $app ~ '" enctype="application/x-www-form-url-encoded">';
    }
    else {
      $form = '<form method="POST" action="/" enctype="application/x-www-form-url-encoded">';
    }  
    return $form;
  }
  method end-form() {
    my Str $form = '';
    $form = '</form>';
    return $form;
  }

  method user-command() {
    my Str $form = '';
    my Str $alt = '';
    $alt = 'Enter';
    $form ~= '<input type="image" name="press-enter" '
          ~  'src="themes/img/icons/tick.png" '
          ~  'alt="' ~ $alt ~ '">'
          ~  '&nbsp;<span style="font-size:75%;">' ~ $alt ~ '</span>&nbsp;';
    #$form ~= '<input type="submit" name="enter" value="Enter" />';
    $form ~= '&nbsp;<input type="text" name="ucomm" value="" size="10" maxlength="60" />';
    #$form ~= '&nbsp;<input type="submit" name="fcode" value="first" />';
    #$form ~= '&nbsp;<input type="submit" name="fcode" value="previous" />';
    #$form ~= '&nbsp;<input type="submit" name="fcode" value="next" />';
    #$form ~= '&nbsp;<input type="submit" name="fcode" value="last" />';
    return $form;
  }

  method user-login() {
    my Str $form = '';
    my Str $alt = '';
    $alt = 'Login';
    $form ~= '<input type="image" name="press-login" '
          ~  'src="themes/img/icons/key.png" '
          ~  'alt="' ~ $alt ~ '">'
          ~  '&nbsp;<span style="font-size:75%;">' ~ $alt ~ '</span>&nbsp;';
    #$form ~= '<input type="submit" name="login" value="Login" />';
    $form ~= '<br><br><div>';
    $form ~= 'Username: <input type="text" name="username" />';
    $form ~= '</div>';
    $form ~= '<div>';
    $form ~= 'Password: <input type="password" name="password" />';
    $form ~= '</div>';
    return $form;
  }

  multi method run(Str :$signature,
                  Str :$app,
                  Str :$cmd,
                  Str :$userid,
                  :%params) {

    my Str $sy-application = 'SY00';
    my Str $db-utility = 'DB00';
    my Str $module-name = '';



      #-- generate default directory structures
      self.create-default-directories();
      #-- generate Database module
      #-- then load DB utility module
      $module-name = self.is-tcode(tcode => $db-utility);

      #-- generate System Module

    #self.TRACE: 'RUN-PARAMS: ' ~ %params.Str;
    return True;
  }

  method create-directory(Str :$path) {
    my Str @FilePath = $path.split('/');
    my Str $directory = '.';
    for @FilePath -> $dir {
      next if $dir ~~ /\./;
      next if $dir ~~ /^.*\\(.*)$/;
      $directory ~= '/' ~ $dir;
      unless $directory.IO ~~ :d {
        $directory.IO.mkdir;
      }
    }
  }

  method write-string-to-file (Str :$file-name, Str :$data) {
		my $file-handle = open $file-name, :w;
		$file-handle.say: $data;
		$file-handle.close;
		return True;
	}

	method get(Str :$key) {
		my Str $value = '';
		#-- get $sVar from config file
		$value = %.Config{"$key"}.Str if defined %.Config{"$key"};
		$value ~~ s:g/\{(.*?)\}/{   #-- Convert embedded variables
			self.get(key => $0.Str);  #-- for example: data_dir = ./{SID}{SID_NR}/some_value
		}/;                         #--   translates to:        ./DEV00/some_value
		return $value;
	}

  method get-param(Str :$key = '') {
    my Str $parameter-value = '';
    if %.Params{"$key"}:exists {
      $parameter-value = %.Params{"$key"}.Str;
    }
    return $parameter-value;
  }

	method create-default-directories() {
		my Str $instance = self.get(key => 'SID') ~ self.get(key => 'SID_NR');
    #self.TRACE: 'Instance = ' ~ $instance;

    my Str $temp-dir = './';
    #self.TRACE: 'Temp directory = ' ~ $temp-dir;

    my Str $public-dir = self.get(key => 'PUBLIC_DIR');
    #self.TRACE: 'Public directory = ' ~ $public-dir;

    my Str $data-dir = self.get(key => 'DATA_DIR');
   #self.TRACE: 'Data directory = ' ~ $data-dir;
   
    my Str $instance-dir = $public-dir ~ '/' ~ $instance;
    #self.TRACE: 'Instance directory = ' ~ $instance-dir;
   
    my Str $themes-dir = $public-dir ~ '/themes';
    #self.TRACE: 'Themes directory = ' ~ $themes-dir;
   
    my Str $styles-dir = $public-dir ~ '/styles';
    #self.TRACE: 'Styles directory = ' ~ $styles-dir;
   
    my Str $jscript-dir = $public-dir ~ '/jscript';
    #self.TRACE: 'Jscript directory = ' ~ $jscript-dir;
   
    my Str $upload-dir = $public-dir ~ '/uploads';
    #self.TRACE: 'Upload directory = ' ~ $upload-dir;
   
    my Str $wikidata-dir = $data-dir ~ '/' ~ $instance ~ '/wikidata';
    #self.TRACE: 'Wikidata directory = ' ~ $wikidata-dir;
   
		self.create-directory(path => $temp-dir);
		self.create-directory(path => $public-dir);
    self.create-directory(path => $instance-dir);
    self.create-directory(path => $instance-dir ~ '/themes');
    self.create-directory(path => $instance-dir ~ '/themes/img');
    self.create-directory(path => $instance-dir ~ '/styles');
    self.create-directory(path => $instance-dir ~ '/jscript');
    self.create-directory(path => $instance-dir ~ '/uploads');
    self.create-directory(path => $themes-dir);
    self.create-directory(path => $themes-dir ~ '/img');
    self.create-directory(path => $themes-dir ~ '/img/common');
    self.create-directory(path => $styles-dir);
    self.create-directory(path => $styles-dir ~ '/common');
    self.create-directory(path => $jscript-dir);
    self.create-directory(path => $jscript-dir ~ '/common');
    self.create-directory(path => $upload-dir);
    self.create-directory(path => $wikidata-dir);
    self.create-directory(path => $wikidata-dir ~ '/page');
    self.create-directory(path => $wikidata-dir ~ '/user');
    self.create-directory(path => $wikidata-dir ~ '/temp');
    self.create-directory(path => $wikidata-dir ~ '/lock');
    self.create-directory(path => $wikidata-dir ~ '/tmpl');
  }

  method is-tcode(Str :$tcode = '') {
    my Str $module-name = '';
    my Str $module-text = '';
    my Str $module-type = '';
    if defined %.APPTABLE{"$tcode"} { #check for hardcoded tcode
      # check hard coded listing first
      $module-name = %.APPTABLE{$tcode};
      $module-text = %.APPTEXTS{$tcode};
      given $tcode {
        when 'SY00' { #-- App HANDLE is $.Sys
          self.is-module($.Sys, tcode => $tcode,
                                module => $module-name,
                                text => $module-text);
        }
        when 'DB00' { #-- App HANDLE is $.Dbu
          self.is-module($.Dbu, tcode => $tcode,
                                module => $module-name,
                                text => $module-text);
        }
        default {
          #self.TRACE: 'MODULE NAME = ' ~ $module-name;
          self.is-module($.App, tcode => $tcode,
                                module => $module-name,
                                text => $module-text);
        }
      }
    }
    else { 
      #- for non-hardcoded tcode, get shortcut from Dbu
      if defined $.Dbu { #-- make sure Dbu exists
        ($module-name, $module-text, $module-type) = $.Dbu.is-shortcut(shortcut => $tcode.uc);
        if $module-name ne '' {
          self.is-module($.App, tcode => $tcode,
                                module => $module-name,
                                text => $module-text);
        }
      }
    }
    return $module-name;
  }

  method is-module($handler is rw, Str :$tcode,
                                   Str :$module,
                                   Str :$text) {
  }

  method generate-module(Str :$shortcut,
                        Str :$module,
                        Str :$file,
                        Str :$text) {
    given $shortcut {
      when 'DB00' { #-- Database utility
        #self.TRACE: 'TODO: Generate module: ' 
        #        ~ "tcode: $shortcut; module: $module; file: $file; text: $text";      
        self.generate-database-utility-module(shortcut => $shortcut,
                                    module => $module,
                                    file => $file,
                                    text => $text);
      }
    }
  }

  method generate-database-utility-module(Str :$shortcut,
                              Str :$module,
                              Str :$file,
                              Str :$text) {

      my Str $module-name = $C_NAMESPACE ~ '::' ~ $module;
      my $source-code = '';
      my $snippet = '';
      my $exception-text = $text;



      $snippet = "\n" 
      ~ 'unit module ' ~ $C_NAMESPACE ~ '::' ~ $module ~ ':ver<' ~ $C_VERSION ~ '>:auth<' ~ $C_AUTHOR ~ '>;' 
      ~ "\n" ~ '  class X::' ~ $C_NAMESPACE ~ '::' ~ $module ~ ' is Exception {'
      ~ "\n";
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      has $.msg-id; #message class
      has $.msg-no; #message number
      has $.msg-ty; #message type = [A, E, I, S, W]
      has $.msg-t1; #message text 1
      has $.msg-t2; #message text 2
      has $.msg-t3; #message text 3
      has $.msg-t4; #message text 4

    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      method message() {
        #-- TODO: Get the message from the data dictionary

        "$.msg-id" ~ "-" ~ $.msg-no ~ " " ~
        "$.msg-ty " ~
        "$.msg-t1 $.msg-t2 $.msg-t3 $.msg-t4"; # Generic error
      }
    }
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = "\n"
    ~ "\n" ~ 'class ' ~ $module ~ ' is export {'
    ~ "\n";
      $source-code ~= $snippet;

      $snippet = q:to/END_OF_CODE/;
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
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      method main($App, Str :$userid, Str :$ucomm, :%params) {
        $.Sys = $App;
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
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      method goto-screen(Str :$screen) {
        my Str $sNextScreen = 'screen_' ~ $screen;
        if self.can($sNextScreen) {
          self."$sNextScreen"();
        }
      }
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      method screen_1000 {
        my Str $comment = '';
        return True;
      }
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      method initialize-config(:%cfg) {
        %.Config = %cfg;
      }
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
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
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
      method getenv(Str :$key) {
        my $sVar =  '';
        $sVar = %*ENV{$key.uc} if defined %*ENV{$key};
        return $sVar;
      }
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = "\n" 
      ~ "\n" ~ 'method TRACE(Str $msg, :$id = "' ~ $exception-text ~ '", :$no = "001", :$ty = "I", :$t1 = "", :$t2 = "", :$t3 = "", :$t4 = "" ) {'
      ~ "\n";
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;  
        my Str $sInfo = "";

        $sInfo = $t1;
        $sInfo = $t1 ~ $msg.Str if $msg ne "";

        $.DebugInfo ~= $id ~ "-" ~ $no ~ " " ~ $ty ~ " ";
        $.DebugInfo ~= $msg ~ "<br/>" if $msg ne "";
    END_OF_CODE
      $source-code ~= $snippet;


      $snippet = "\n" 
      ~ "\n" ~ '  my $e = X::' ~ $C_NAMESPACE ~ '::' ~ $module ~ '.new('
      ~ "\n";
      $source-code ~= $snippet;


      $snippet = q:to/END_OF_CODE/;
          msg-id => $id, msg-no => $no, msg-ty => $ty,
          msg-t1 => $sInfo, msg-t2 => $t2, msg-t3 => $t3,msg-t4 => $t4);
          note $e.message;
      }
    };
    END_OF_CODE
      $source-code ~= $snippet;


      self.write-string-to-file(file-name => $file,
                                  data => $source-code);

  }





#-- END-OF-CLASS --

}