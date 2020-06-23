use Cro::HTTP::Router;
use Cro::HTTP::Session::InMemory;
use Cro::HTTP::Auth;
use Cro::HTTP::Session::Persistent;
use Sys::Runtime;

class Session does Cro::HTTP::Auth {
  has $.is-logged-in;
  has $.admin;
  has @.recently-viewed-items;
}

class SessionStore does Cro::HTTP::Session::Persistent[Session] {
    # This will be called whenever we need to load session state, and the
    # session ID will be pased. Return 'fail' if it is not possible
    # e.g. no such session is found.

  method load(Str $session-id --> Session) {
    # Load session $session-id, place data into a new Session instance
  }
  method create(Str $session-id) {
    #-- Will be called when new session starts.
    # INSERT a new session
  }
  method save(Str $session-id, Session $session --> Nil) {
    # UPDATE existing session
  }
  method clear(--> Nil) {
    # CLEAR sessons older than maximum age to retain them
  }
}

class UserSession does Cro::HTTP::Auth {
  has $.username is rw;
  method logged-in() {
    defined $!username;
  }
}

class X::Routes is Exception {
	has $.msg-id;
	#message class
	has $.msg-no;
	#message number
	has $.msg-ty;
	#message type = [A, E, I, S, W]
	has $.msg-t1;
	#message text 1
	has $.msg-t2;
	#message text 2
	has $.msg-t3;
	#message text 3
	has $.msg-t4;
	#message text 4

	method message() {
		#-- TODO: Get the message from the data dictionary
		"$.msg-id" ~ "-" 
               ~ $.msg-no 
               ~ " " 
               ~ "$.msg-ty " 
               ~ "$.msg-t1 $.msg-t2 $.msg-t3 $.msg-t4";
	}
}


sub TRACE(Str $msg, 
          Str :$id = "R0", 
          Str :$no = "001", 
          Str :$ty = "I", 
          Str :$t1 = "", 
          Str :$t2 = "", 
          Str :$t3 = "", 
          Str :$t4 = "" ) {
  my Str $info = "";
  $info = $t1;
  $info = $t1 ~ $msg.Str if $msg ne "";
  my $e = X::Routes.new( 
          msg-id => $id, 
          msg-no => $no, 
          msg-ty => $ty,
          msg-t1 => $info, 
          msg-t2 => $t2, 
          msg-t3 => $t3,
          msg-t4 => $t4);
  note $e.message;
}

my $oRuntime = Runtime.new();

sub routes() is export {
    route {
        before Cro::HTTP::Session::InMemory[UserSession].new(
          expiration => Duration.new(60 * 15),
          cookie-name => '_COOKEE_'
        );
        
        subset LoggedIn of UserSession where *.logged-in;
        
        get -> UserSession $session, :%params {
          my Str $userid = '';
          $userid = $session.username if defined $session.username && $session.username ne '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'startup',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        get -> LoggedIn $user, 'home', :%params {
          my Str $userid = '';
          $userid = $user.username if defined $user.username && $user.username ne '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'home',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        get -> LoggedIn $user, 'logout', :%params {
          my Str $userid = '';
          $user.username = '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'logout',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        get -> LoggedIn $user, 'index', :%params {
          my Str $userid = '';
          $userid = $user.username if defined $user.username && $user.username ne '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'index',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        get -> 'login', :%params {
          my Str $userid = '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'login',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        get -> LoggedIn $user, $dead-end, :%params {
          my Str $userid = '';
          $userid = $user.username if defined $user.username && $user.username ne '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'dead-end',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        get -> $dead-end, :%params {
            my Str $userid = '';
          content 'text/html', 
                  $oRuntime.dispatch(app => 'dead-end',
                                     cmd => 'INIT', 
                                     userid => $userid, 
                                     :%params);
        }

        post -> UserSession $user, 'login' {
          request-body -> (:$username, :$password, *%params) {
            if valid-user-pass($username, $password) {
                $user.username = $username;
                redirect '/', :see-other;
            }
            else {
              my Str $userid = '';          
              content 'text/html', 
                  $oRuntime.dispatch(app => 're-login',
                                     cmd => 'WRONG-PASSWORD', 
                                     userid => $userid, 
                                     :%params);

            }
          }
        }

        sub valid-user-pass($username, $password) {
          # Call a database or similar here
          return $username eq 'system' && $password eq 'pass';
        }

    }
}
