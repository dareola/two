use Cro::HTTP::Router;
use Cro::HTTP::Session::InMemory;
use Cro::HTTP::Auth;
use Cro::HTTP::Session::Persistent;

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

sub routes() is export {
    route {
        before Cro::HTTP::Session::InMemory[UserSession].new(
          expiration => Duration.new(60 * 15),
          cookie-name => '_COOKEE_'
        );
        
        subset LoggedIn of UserSession where *.logged-in;
        
        get -> UserSession $session {
        content 'text/html', 
                "DEFAULT PAGE - Current user: {$session.logged-in ?? 
                                   $session.username ~ ', you can <a href="/logout">logout now</a> or go <a href="/home">home</a> or go <a href="/index">index</a>.' 
                                   !! 
                                   '- pls ' ~ '<a href="/login">login</a>' ~ ''
                               }";
        }

        get -> LoggedIn $user, 'home' {
          content 'text/html', "Secret page just for *YOU*, $user.username()" 
                             ~ '; you can <a href="/logout">logout now</a>' 
                             ~ '; or you can <a href="/index">go to main page</a>';
        }

        get -> LoggedIn $user, 'logout' {
          $user.username = '';
          content 'text/html', "Bye, back to <a href=/index>index</a>";
        }

        get -> LoggedIn $user, 'index' {
          if $user.username {
            content 'text/html', "Main Index, $user.username() " ~ ';' 
                                ~ "perform <a href=/index>refresh</a>" 
                                ~ ' or ' ~ '<a href="/home">home</a>'
                                ~ ' or ' ~ '<a href="/logout">logout</a><hr>TODO: Display OKCODE FORM';

          }
          else {
            content 'text/html', "Main Index, pls " ~ '<a href="/login">login</a> or got to applications that does not need forms';
          }
        }

        get -> 'login' {
          content 'text/html', q:to/HTML/;
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

        get -> LoggedIn $user, $dead-end {
          content 'text/html', 
          $dead-end ~ ': PAGE not found - back to <a href=/index>index</a>';
        }

        get -> $dead-end {
          content 'text/html', 
          $dead-end ~ ': PAGE not found - back to <a href=/>index</a>';
        }

        post -> UserSession $user, 'login' {
          request-body -> (:$username, :$password, *%) {
            if valid-user-pass($username, $password) {
                $user.username = $username;
                redirect '/', :see-other;
            }
            else {
                content 'text/html', "Bad username/password; - pls " ~ '<a href="/login">re-login</a>';
            }
          }
        }

        sub valid-user-pass($username, $password) {
          # Call a database or similar here
          return $username eq 'system' && $password eq 'pass';
        }

    }
}
