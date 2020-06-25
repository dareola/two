use Cro::HTTP::Router;
use Cro::HTTP::Session::InMemory;
use Cro::HTTP::Auth;
use Cro::HTTP::Session::Persistent;
use Sys::Runtime;
use JSON::Tiny;

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
my $config = qq:to/CONFIG/;
---
cro: 1
id: two
name: two
entrypoint: start_TWO00_mcairsunday_net.p6
env: 
  - name: SID
    value: 'TWO'
  - name: SID_HOST
    value: 'mcairsunday'
  - name: SID_DOMAIN
    value: 'net'
  - name: SID_PORT
    value: '8080'
  - name: SID_NR
    value: "00"
  - name: LANGUAGE
    value: 'EN'
  - name: SITE_NAME
    value: 'Site Two'
  - name: SITE_HOME
    value: 'HomePage'
  - name: SITE_URL
    value: 'http://mcairsunday.net:8080'
  - name: PUBLIC_DIR
    value: './pub'
  - name: DATA_DIR
    value: './data'
  - name: DEBUG_MODE
    value: 'TRUE'
  - name: WIKI_HOME
    value: 'BookShelf'
  - name: WIKI_NAME
    value: 'ResearchLibrary'
ignore:  
  - TWO00/
  - data/
  - pub/
  - t/
endpoints: 
  - 
    id: http
    protocol: http
    name: HTTP
    port-env: TWO_PORT
    host-env: TWO_HOST.SID_DOMAIN
links:  []
...
CONFIG

my Str $config-path = '';
my Str $config-file = '';

$config-path = './'
             ~ 'data'
             ~ '/' 
             ~ %*ENV<SID>
             ~ %*ENV<SID_NR>
             ~ '/'
             ~ 'conf';

$config-file = $config-path     
             ~ '/'
             ~ %*ENV<SID>
             ~ %*ENV<SID_NR>
             ~ '.json';

if defined %*ENV<RECREATE_CONFIG> && %*ENV<RECREATE_CONFIG> eq '1' {
  if $config-file.IO.e {
    $config-file.IO.unlink;
  }
}

if $config-file.IO.e {
  $oRuntime.load-config-file(file => $config-file);
  #-- &TRACE($oRuntime.Config.Str);
}
else {
  my %Config = 
    CONFIG => $config-file,
    SID => %*ENV<SID>,
    SID_NR => %*ENV<SID_NR>,
    SID_HOST => %*ENV<SID_HOST>,
    SID_PORT => %*ENV<SID_PORT>,
    SID_DOMAIN => %*ENV<SID_DOMAIN>,
    LANGUAGE => %*ENV<LANGUAGE>,
    SITE_NAME => %*ENV<SITE_NAME>,
    SITE_HOME => %*ENV<SITE_HOME>,
    DEBUG_MODE => %*ENV<DEBUG_MODE>,
    WIKI_NAME => %*ENV<WIKI_NAME>,
    WIKI_HOME => %*ENV<WIKI_HOME>,
    PUBLIC_DIR => %*ENV<PUBLIC_DIR>,
    DATA_DIR => %*ENV<DATA_DIR>,
    SITE_URL => %*ENV<SITE_URL>,
    CSS_DEFAULT_DIR => 'common',
    CSS_DEFAULT_FILE => 'default.css',
    JS_DEFAULT_DIR => 'common',
    JS_DEFAULT_FILE => 'default.js';
  my Str $config-to-json = to-json %Config;
  $oRuntime.create-directory(path => $config-path);
  $oRuntime.write-string-to-file(file-name => $config-file,
                                 data => $config-to-json);
  $oRuntime.load-config-file(file => $config-file);
}

#Ref: https://cro.services/docs/reference/cro-http-router

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
            $oRuntime.dispatch(app => 'dispatcher',
                                cmd => 'INIT', 
                                userid => $userid, 
                                :%params);
        }

        get -> $dead-end, :%params {
            my Str $userid = '';
          content 'text/html', 
            $oRuntime.dispatch(app => 'default',
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
                $oRuntime.dispatch(app => 'relogin',
                                    cmd => 'WRONG-PASSWORD', 
                                    userid => $userid, 
                                    :%params);

            }
          }
        }

        post -> LoggedIn $user {
          request-body -> ( *%params ) {
            my Str $userid = '';
            $userid = $user.username if defined $user.username && $user.username ne '';
            content 'text/html', 
              $oRuntime.dispatch(app => 'startup',
                                 cmd => 'INIT', 
                                 userid => $userid, 
                                 :%params);
          }
        }

        sub valid-user-pass($username, $password) {
          my Bool $ok = False;
          $ok = True if $username eq 'system' && $password eq 'pass';
          $ok = True if $username eq 'dareola' && $password eq 'ok';
          $ok = True if $username eq 'DAREOLA' && $password eq 'jerome';
          # Call a database or similar here
          return $ok; #$username eq 'system' && $password eq 'pass';
        }


        #-- FAVICON
        get -> 'favicon.ico' {
          my Str $logo = #'./pub/ONE00/themes/img/DEV00_logo.gif';
                  $oRuntime.Config<PUBLIC_DIR> 
                  ~ '/' 
                  ~ $oRuntime.Config<SID> 
                  ~ $oRuntime.Config<SID_NR>
                  ~ '/themes/img/' 
                  ~ $oRuntime.Config<SID> 
                  ~ $oRuntime.Config<SID_NR> 
                  ~ '_logo.gif';
          static $logo;
        }

        #-- THEMES

        get -> 'themes', 'img', *@path {
          #/themes/img/common/home.gif
          my $themes-dir = $oRuntime.Config<PUBLIC_DIR> 
                        ~ '/themes/img/';
          static $themes-dir, @path;
        }

        #-- UPLOADS
        get -> 'file', $dir, *@path {
          my $themes-dir = $oRuntime.Config<PUBLIC_DIR>
            ~ '/' 
            ~ $dir
            ~ '/'
            ~ $oRuntime.Config<SID>
            ~ $oRuntime.Config<SID_NR>
            ~ '/'
            ~ @path[0].substr(0,1).uc
            ~ '/'; 
          static $themes-dir, @path;
        }

        #-- STYLESHEETS
        get -> 'styles', 'common', *@path {
          my $styles-dir = $oRuntime.Config<PUBLIC_DIR> 
                        ~ '/styles/' 
                        ~ $oRuntime.Config<CSS_DEFAULT_DIR> 
                        ~ '/';
          static $styles-dir, @path;
          #http://xxxx.local:8000/styles/common/default.css
        }

        #-- JAVASCRIPT
        get -> 'jscript', 'common', *@path {
          my Str $jscript-dir = $oRuntime.Config<PUBLIC_DIR> 
                        ~ '/jscript/' 
                        ~ $oRuntime.Config<JS_DEFAULT_DIR> 
                        ~ '/';
          static $jscript-dir, @path;
        }


    }
}
