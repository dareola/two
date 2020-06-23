use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Routes;

my Cro::Service $http = Cro::HTTP::Server.new(
    http => <1.1>,
    host => %*ENV<TWO_HOST> ||
        die("Missing TWO_HOST in environment"),
    port => %*ENV<SID_PORT> ||
        die("Missing TWO_PORT in environment"),
    #port => %*ENV<TWO_PORT> ||
    #    die("Missing TWO_PORT in environment"),
    application => routes(),
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
);
$http.start;
say "Listening at http://%*ENV<TWO_HOST>.%*ENV<SID_DOMAIN>:%*ENV<SID_PORT>";
react {
    whenever signal(SIGINT) {
        say "Shutting down...";
        $http.stop;
        done;
    }
}
