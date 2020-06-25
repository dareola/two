unit module Sys::Runtime:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;
use JSON::Fast;

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
  has %.Config is rw; # Configuration environment
  has Str $.DebugInfo is rw = ''; # Debugging information
  has Str $.Page is rw = ''; # HTML page
  has $.Sys is rw; # System object
  has $.Dbu is rw; # Database object
  has $.App is rw;  # Application object
  has $.Shortcut is rw; # User command
  has %.Params is rw; # Parameters
  has &!callback;
 
  submethod BUILD(:&!callback) { #-- constructor
    $!DebugInfo = '';
    $!Page = '';
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

  method load-config-file(Str :$file) {
    %.Config = from-json(slurp($file));
  }

  multi method dispatch(Str :$app, 
                        Str :$cmd,
                        Str :$userid,
                        :%params) {
    self.TRACE: 'Parameters: ' ~ %params;
    %.Params = %params;

    try self.run(signature => '1',
                 app => $app,
                 cmd => $cmd,
                 userid => $userid,
                 :%params);
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
        $app-toolbar ~= 'Parameters: [' ~ %params.Str ~ ']<br>';
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
    return $text;
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
    $form ~= '<input type="submit" name="enter" value="Enter" />';
    $form ~= '&nbsp;<input type="text" name="ucomm" value="" size="10" maxlength="60" />';
    $form ~= '&nbsp;<input type="submit" name="fcode" value="first" />';
    $form ~= '&nbsp;<input type="submit" name="fcode" value="previous" />';
    $form ~= '&nbsp;<input type="submit" name="fcode" value="next" />';
    $form ~= '&nbsp;<input type="submit" name="fcode" value="last" />';
    return $form;
  }

  method user-login() {
    my Str $form = '';
    $form ~= '<input type="submit" name="login" value="Login" />';
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
    self.create-default-directories();

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
    self.TRACE: 'Instance = ' ~ $instance;

    my Str $temp-dir = './';
    self.TRACE: 'Temp directory = ' ~ $temp-dir;

    my Str $public-dir = self.get(key => 'PUBLIC_DIR');
    self.TRACE: 'Public directory = ' ~ $public-dir;

    my Str $data-dir = self.get(key => 'DATA_DIR');
   self.TRACE: 'Data directory = ' ~ $data-dir;
   
    my Str $instance-dir = $public-dir ~ '/' ~ $instance;
    self.TRACE: 'Instance directory = ' ~ $instance-dir;
   
    my Str $themes-dir = $public-dir ~ '/themes';
    self.TRACE: 'Themes directory = ' ~ $themes-dir;
   
    my Str $styles-dir = $public-dir ~ '/styles';
    self.TRACE: 'Styles directory = ' ~ $styles-dir;
   
    my Str $jscript-dir = $public-dir ~ '/jscript';
    self.TRACE: 'Jscript directory = ' ~ $jscript-dir;
   
    my Str $upload-dir = $public-dir ~ '/uploads';
    self.TRACE: 'Upload directory = ' ~ $upload-dir;
   
    my Str $wikidata-dir = $data-dir ~ '/' ~ $instance ~ '/wikidata';
    self.TRACE: 'Wikidata directory = ' ~ $wikidata-dir;
   
		self.create-directory(path => $temp-dir);
		self.create-directory(path => $public-dir);
    #self.create-directory(path => $instance-dir);
    #self.create-directory(path => $instance-dir ~ '/themes');
    #self.create-directory(path => $instance-dir ~ '/themes/img');
    #self.create-directory(path => $instance-dir ~ '/styles');
    #self.create-directory(path => $instance-dir ~ '/jscript');
    #self.create-directory(path => $instance-dir ~ '/uploads');
    #self.create-directory(path => $themes-dir);
    #self.create-directory(path => $themes-dir ~ '/img');
    #self.create-directory(path => $themes-dir ~ '/img/common');
    #self.create-directory(path => $styles-dir);
    #self.create-directory(path => $styles-dir ~ '/common');
    #self.create-directory(path => $jscript-dir);
    #self.create-directory(path => $jscript-dir ~ '/common');
    #self.create-directory(path => $upload-dir);
    #self.create-directory(path => $wikidata-dir);
    #self.create-directory(path => $wikidata-dir ~ '/page');
    #self.create-directory(path => $wikidata-dir ~ '/user');
    #self.create-directory(path => $wikidata-dir ~ '/temp');
    #self.create-directory(path => $wikidata-dir ~ '/lock');
    #self.create-directory(path => $wikidata-dir ~ '/tmpl');

	}

#-- END-OF-CLASS --

}