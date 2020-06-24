unit module Sys::Runtime:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;

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
  has Str $.DebugInfo is rw = '';
  has %.Config is rw;
  has &!callback;
 
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

  multi method dispatch(Str :$app, 
                        Str :$cmd,
                        Str :$userid,
                        :%params) {
    self.TRACE: 'Parameters: ' ~ %params;

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
        $text ~= $app-toolbar;
        $text ~= q:to/HTML/;
            <form method="POST" action="/login">
              <div>
                Username: <input type="text" name="username" />
              </div>
              <div>
                Password: <input type="password" name="password" />
              </div>
              <input type="submit" value="Log In" />
            </form>
            HTML
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
      when 'dead-end' {
        $text ~= $app-toolbar;
      }
      when 're-login' {
        $text ~= $app-toolbar;
      }
    }

    $text ~= 'User = ' ~ $user ~ '<br>' 
          ~ 'Application = ' ~ $app ~ '<br>'
          ~ 'Command = ' ~ $cmd ~ '<br>';
    return $text;
  }

  method begin-form() {
    my Str $form = '';
    $form = '<form method="POST" action="/" enctype="application/x-www-form-url-encoded">';
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

  multi method run(Str :$signature,
                  Str :$app,
                  Str :$cmd,
                  Str :$userid,
                  :%params) {
    return True;
  }

}