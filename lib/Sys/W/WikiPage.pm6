
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
    has %.Page = ();
    has %.Section = ();
    has %.Text = ();
    has %.TranslatedText = ();
    has %.Preformatted = ();
    has Int $.PreformattedIndex is rw = 0;
    has %.SaveUrl = ();
    has Int $.SaveUrlIndex is rw = 0;

    # Tags that must be in <tag> ... </tag> pairs:
    has @.HtmlPairs = <b i u font big small sub sup h1 h2 h3 h4 h5 h6 cite code
                       em s strike strong tt var div center blockquote ol ul dl
                       table tr td caption br p hr li dt dd th>;

    # Single tags (that do not require a closing /tag)
    has @.HtmlSingle  = <br p hr li dt dd th>;

    #-- begin: testing-declaration
    has $.FS is rw = '';
    has $.FS1 is rw = '';
    has $.FS2 is rw = '';
    has $.FS3 is rw = '';
    has $.LinkPattern is rw = '';
    has $.HalfLinkPattern is rw = '';
    has $.AnchoredLinkPattern is rw = '';
    has $.EditLinkPattern is rw = '';
    has $.InterSitePattern is rw = '';
    has $.InterLinkPattern is rw = '';
    has $.FreeLinkPattern is rw = '';
    has $.UrlProtocols is rw = '';
    has $.UrlPattern is rw = '';
    has $.ImageExtensions is rw = '';

    has Int $.TaskNumDaysToExpire = 30;
    has Str $.ScriptName is rw = '';
    has Str $.ScriptTZ = "";
    has Int $.RcDefault = 30;
    has Int $.CookieExpire = 60;
    has Int $.KeepDays = 14;
    has Int $.RedirType = 1;
    has Str $.NotFoundPg = "";                      # Page for not-found links ("" for blank pg)
    has Str $.EmailFrom = "Wiki";                   # Text for "From: " field of email notes.
    has Str $.FooterNote = "";                      # HTML for bottom of every page
    has Str $.EditNote = "";                        # HTML notice above buttons on edit page
    has Str $.NewText = "";                         # New page text ("" for default message)
    has Str $.HttpCharset = "";                     # Charset for pages, like "iso-8859-2"
    has Str $.UserGotoBar = "";                     # HTML added to end of goto bar
    has Str $.InterWikiMoniker = '';                # InterWiki moniker for this wiki. (for RSS)
    has Str $.SiteName = '';
    has Str $.SiteDescription = '';                 # Description of this wiki. (for RSS)
    has Str $.RssLogoUrl = '';                      # Optional image for RSS feed
    has Str $.EarlyRules = '';                      # Local syntax rules for wiki->html (evaled)
    has Str $.LateRules = '';                       # Local syntax rules for wiki->html (evaled)
    has Int $.KeepSize = 0;                         # If non-zero, maximum size of keep file
    has Str $.BGColor = 'white';                    # Background color ('' to disable)
    has Str $.DiffColor1 = '#ffffaf';               # Background color of old/deleted text
    has Str $.DiffColor2 = '#cfffcf';               # Background color of new/added text
    has Str $.FavIcon = '';                         # URL of bookmark/favorites icon, or ''
    has Int $.RssDays = 7;                          # Default number of days in RSS feed
    has Str $.PublicFolderMatch = '';
    has Str $.UserHeader = '';                      #<<AUTOFOCUSJAVASCRIPT;
                                                    # Optional HTML header additional content
    has Str $.UserBody = '';                        #'onload="onLoad()"';
                                                    # Optional <BODY> tag additional content
    has Int $.StartUID  = 1001;                     # Starting number for user IDs
    has @.ImageSites = ();                          # Url prefixes of good image sites: ()=all
    has Str $.BreadCrumb = '';
    has Str $.MenuGroup = '';
    has Str $.SiteMenuBar = '';
    has Str $.PopupMenu = '';
    has Str $.TabMenuBar = '';
    has Str $.HttpDocsDir = '../httpdocs';

    # Major options:
    has Bool $.UseSubpage = True;                   # True = use subpages,
                                                    # False = do not use subpages
    has Bool $.UseCache = False;                    # True = cache HTML pages,
                                                    # False = generate every page
    has Bool $.EditAllowed = False;                 # True = editing allowed,
                                                    # False = read-only
    has Bool $.RawHtml = False;                     # 1 = allow <HTML> tag,
                                                    # 0 = no raw HTML in pages
    has Bool $.HtmlTags = True;                     # 1 = "unsafe" HTML tags,
                                                    # 0 = only minimal tags
    has Bool $.UseDiff = True;                      # 1 = use diff features,
                                                    # 0 = do not use diff
    has Bool $.FreeLinks = True;                    # 1 = use [[word]] links,
                                                    # 0 = LinkPattern only
    has Bool $.WikiLinks = True;                    # 1 = use LinkPattern,
                                                    # 0 = use [[word]] only
    has Bool $.AdminDelete = True;                  # 1 = Admin only deletes,
                                                    # 0 = Editor can delete
    has Bool $.RunCGI = True;                       # 1 = Run script as CGI,
                                                    # 0 = Load but do not run
    has Bool $.EmailNotify = False;                 # 1 = use email notices,
                                                    # 0 = no email on changes
    has Bool $.EmbedWiki = False;                   # 1 = no headers/footers,
                                                    # 0 = normal wiki pages
    has Str $.DeletedPage = 'DeletedPage';          # 0 = disable, 'PageName' = tag to delete page
    has Str $.ReplaceFile = 'ReplaceFile';          # 0 = disable, 'PageName' = indicator tag
    has @.ReplaceableFiles = ();                    # List of allowed server files to replace
    has Bool $.TableSyntax = True;                  # 1 = wiki syntax tables,
                                                    # 0 = no table syntax
    has Bool $.NewFS = False;                       # 1 = new multibyte $FS,
                                                    # 0 = old $FS
    has Bool $.UseUpload = True;                    # 1 = allow uploads,
                                                    # 0 = no uploads
    has Str $.MenuSpacer = '&nbsp;';

    # Minor options:
    has Bool $.UseSmilies = True;                   # 1 = use smiley pics
                                                    # 0 = do not change :)
    has Bool $.RecentTop = True;                    # 1 = recent on top, 0 = recent on bottom
    has Bool $.UseDiffLog = True;                   # 1 = save diffs to log,  0 = do not save diffs
    has Bool $.MetaNoIndexHist = True;              # 1 - disallow robots indexing old pages, 0 = allow
    has Bool $.KeepMajor = True;                    # 1 = keep major rev,     0 = expire all revisions
    has Bool $.KeepAuthor = True;                   # 1 = keep author rev,    0 = expire all revisions
    has Bool $.ShowEdits = False;                   # 1 = show minor edits,   0 = hide edits by default
    has Str $.DefaultLanguage = 'English';          # 1 = default user language
    has Bool $.HtmlLinks = False;                   # 1 = allow A HREF links, 0 = no raw HTML links
    has Bool $.SimpleLinks = False;                 # 1 = only letters,       0 = allow _ and numbers
    has Bool $.NonEnglish = False;                  # 1 = extra link chars,   0 = only A-Za-z chars
    has Bool $.ThinLine = False;                    # 1 = fancy <hr> tags,    0 = classic wiki <hr>
    has Int $.BracketText = 2;                      # 1 = allow [URL text],   0 = no link descriptions,
                                                    # 2 = allow but dont emit bracket
    has Bool $.UseAmPm = True;                      # 1 = use am/pm in times, 0 = use 24-hour times
    has Bool $.UseIndex = False;                    # 1 = use index file,     0 = slow/reliable method
    has Bool $.UseHeadings = True;                  # 1 = allow = h1 text =,  0 = no header formatting
    has Bool $.NetworkFile = True;                  # 1 = allow remote file:, 0 = no file:// links
    has Bool $.BracketWiki = False;                 # 1 = [WikiLnk txt] link, 0 = no local descriptions
    has Bool $.UseLookup = True;                    # 1 = lookup host names,  0 = skip lookup (IP only)
    has Bool $.FreeUpper = True;                    # 1 = force upper case,   0 = do not force case
    has Bool $.FastGlob = True;                     # 1 = new faster code,    0 = old compatible code
    has Bool $.DefaultSearch = False;
    has Bool $.MetaKeywords = True;                 # 1 = Google-friendly,    0 = search-engine averse
    has Int $.NamedAnchors = True;                  # 0 = no anchors, 1 = enable anchors,
                                                    # 2 = enable but suppress display
    has Str $.ScrumHdColor = "#ffcccc";             # The scrum wiki table header color
    has Bool $.SlashLinks = False;                  # 1 = use script/action links, 0 = script?action
    has Bool $.UpperFirst = True;                   # 1 = free links start uppercase, 0 = no ucfirst
    has Bool $.AdminBar = True;                     # 1 = admins see admin links, 0 = no admin bar
    has Bool $.RepInterMap = False;                 # 1 = intermap is replacable, 0 = not replacable
    has Bool $.ConfirmDel = True;                   # 1 = delete link confirm page,
                                                    # 0 = immediate delete
    has Bool $.MaskHosts = False;                   # 1 = mask hosts/IPs,      0 = no masking
    has Bool $.LockCrash = False;                   # 1 = crash if lock stuck, 0 = auto clear locks
    has Bool $.HistoryEdit = False;                 # 1 = edit links on history page, 0 = no edit links
    has Bool $.OldThinLine = False;                 # 1 = old ==== thick line,
                                                    # 0 = ------ for thick line
    has Bool $.NumberDates = False;                 # 1 = 2003-6-17 dates,     0 = June 17, 2003 dates
    has Bool $.ParseParas = False;                  # 1 = new paragraph markup, 0 = old markup
    has Bool $.AuthorFooter = True;                 # 1 = show last author in footer, 0 = do not show
    has Bool $.AllUpload = False;                   # 1 = anyone can upload,   0 = only editor/admins
    has Bool $.LimitFileUrl = True;                 # 1 = limited use of file: URLs, 0 = no limits
    has Bool $.MaintTrimRc = False;                 # 1 = maintain action trims RC, 0 = only maintainrc
    has Bool $.SearchButton = False;                # 1 = search button on page, 0 = old behavior
    has Bool $.EditNameLink = False;                # 1 = edit links use name (CSS), 0 = '?' links
    has Bool $.UseMetaWiki = False;                 # 1 = add MetaWiki search links, 0 = no MW links
    has Bool $.BracketImg = True;                   # 1 = [url url.gif] becomes image link, 0 = no img
    has Bool $.FreeUserNames = True;                # 1 = spaces in username, 0 = LinkPattern only
    has Bool $.FullTable  = True;
    has Bool $.UseNumberedAnchor = True;            # 1 = use numbered anchor in NumberedHeadings
    has Str $.DateFormat = '%eBmY';                 # not yet used
    has Bool $.SearchLinks = True;                  # 1 = allow search links syntax, 0 = don't
    has Bool $.AutoMailto = True;                   # converts emails in format name@host
                                                    # into mailto: hyperlinks
    has Str $.UploadFileInfo = '';                  # filename|newfile|X|printfilename
    has Int $.IndentLimit = 20;                     # Maximum depth of nested lists
    has Bool $.TOCFlag is rw = False;




    #-- end: testing-declaration


    constant $C_APP_NAME = "WIKI";
    constant $C_FS  = "\xb3";
    constant $C_FS1 = "\xb3" ~ '1';
    constant $C_FS2 = "\xb3" ~ '2';
    constant $C_FS3 = "\xb3" ~ '3';
    constant $C_NEW_TEXT = "Blank page";

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
        $.UserCommand = 'DISPLAY';
	    }
    }
    if defined %.Params<save> {
      $.UserCommand = 'DISPLAY';
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

      #self.TRACE: 'PARAMS: ' ~ $.Params.Str;

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


    method DISPLAY_SCREEN_1000 {
      my Str $home = '';

      $home = '<a href="/home">exit</a>';

      my Str $edit = '';
      my Str $logout-link = '';
      my Str $login-link = '';
      my Str $wiki-name = '';
      $wiki-name = $.Sys.get(key => 'WIKI_NAME');

      $.CurrentWikiPage = $.Sys.get(key => 'WIKI_HOME');
      $.CurrentWikiPage = %.Params<p> if defined %.Params<p> && %.Params<p> ne '';

      $home = '<a href="/wiki">home</a>' if $.CurrentWikiPage ne $.Sys.get(key => 'WIKI_HOME');

      $logout-link = '<a href="/logout">Logout</a>' if $.UserID ne '';
      $login-link = '<a href="/login">Login</a>' if $.UserID eq '';

      #-- detect if wiki-file exists
      my Int $status = 0;
      my Str $wiki-text = '';
      my Str $summary = '';
      self.TRACE: 'CURRENT WIKI PAGE = ' ~ $.CurrentWikiPage;
      $status = self.wiki-open-page(id => $.CurrentWikiPage);
      $wiki-text = %.Text<txtdata>.Str;
      $summary = %.Text<summary>.Str;

      if defined %.Params<save> {
        self.message('Detected SAVE command');
        self.wiki-save-data(id => $.CurrentWikiPage);
        $wiki-text = %.Text<txtdata>.Str;
        $summary = %.Text<summary>.Str;
      }
      $wiki-name = $.CurrentWikiPage if $.CurrentWikiPage ne '';
      $.Sys.FT(tag => 'PAGE_TITLE', text => $wiki-name);
      #$.Sys.FT(tab => 'PAGE_TITLE', text => $.CurrentWikiPage);

      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'WIKIMENU_BAR', text => $login-link ~ $logout-link);

      $edit = '&nbsp;|&nbsp;<a href="/wiki/edit?p='
            ~ $.CurrentWikiPage ~ '">edit</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $edit); # if $.UserID ne '';

      my $refresh = '&nbsp;|&nbsp;<a href="/wiki/display?p='
            ~ $.CurrentWikiPage ~ '">refresh</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $refresh); # if $.UserID ne '';

      my Str $wiki-to-html = '';
      $wiki-to-html = self.wiki-to-html(text => $wiki-text);

      $.Sys.FORM-STRING(text => $wiki-to-html);

      return True;
    }


method EDIT_SCREEN_1000() {
        my Str $home = '<a href="/wiki">exit</a>';
      my Str $cancel = '';
      my Str $logout-link = '';
      my Str $login-link = '';
      my Str $wiki-name = '';
      my Int $regex-counter = 1;
      $wiki-name = $.Sys.get(key => 'WIKI_NAME');

      $logout-link = '<a href="/logout">Logout</a>' if $.UserID ne '';
      $login-link = '<a href="/login">Login</a>' if $.UserID eq '';

      my Int $status = 0;
      my Str $wiki-text = '';
      my Str $summary = '';

      $.CurrentWikiPage = $.Sys.get(key => 'WIKI_HOME');
      $.CurrentWikiPage = %.Params<p> if defined %.Params<p> && %.Params<p> ne '';

      $home = '<a href="/wiki">home</a>' if $.CurrentWikiPage ne $.Sys.get(key => 'WIKI_HOME');

      $status = self.wiki-open-page(id => $.CurrentWikiPage);
      $wiki-text = %.Text<txtdata>.Str;
      $summary = %.Text<summary>.Str;

      if defined %.Params<savc> {
        self.message('Detected SAVE command, then continue editing');
        self.wiki-save-data(id => $.CurrentWikiPage);
        $wiki-text = %.Text<txtdata>.Str;
        $summary = %.Text<summary>.Str;
      }

      my Int $edit-rows = 15;
      my Int $edit-cols = 60;
      my Int $summary-cols = 180;
      #my Str $wiki-text = '';
      my Int $rows = 0;
      my Int $cols = 0;
      $rows = %.Params<ROWS>.Int if defined %.Params<ROWS> && %.Params<ROWS> ne '';
      $edit-rows = $rows if $rows >= 3;
      $cols = %.Params<COLS>.Int if defined %.Params<COLS> && %.Params<COLS> ne '';
      $edit-cols = $cols if $cols >= 10;

      if defined %.Params<p> && %.Params<p> ne '' {
        $.CurrentWikiPage = %.Params<p>;
      }
      else {
        $.CurrentWikiPage = $.Sys.get(key => 'WIKI_HOME');
      }
      $wiki-name = $.CurrentWikiPage if $.CurrentWikiPage ne '';
      $.Sys.FT(tag => 'PAGE_TITLE', text => $wiki-name);
      #$.Sys.FT(tag => 'PAGE_TITLE', text => $.CurrentWikiPage);

      $.Sys.FT(tag => 'SITE_LOGO', text => $.Sys.site-logo());
      $.Sys.FT(tag => 'MENU_BAR', text => $home);
      $.Sys.FT(tag => 'PAGE_EDITOR', text => $.UserID);
      $.Sys.FT(tag => 'WIKIMENU_BAR', text => $login-link ~ $logout-link);


      $.Sys.FORM-IMG-BUTTON(key => 'press-savc',
                            src => $C_ICON_SAVC,
                            alt => 'Save and continue editing');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-IMG-BUTTON(key => 'press-save',
                            src => $C_ICON_SAVE,
                            alt => 'Save then exit editor');
      #$.Sys.FORM-BREAK();
      #$.Sys.FORM-BREAK();
      $.Sys.FORM-SPACE();
      $.Sys.FORM-SPACE();
      #$.Sys.FORM-STRING(text => 'Page: ' ~ $.CurrentWikiPage);
      $.Sys.FORM-SPACE(spaces => 5);
      $.Sys.FORM-STRING(text => 'Rows');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-TEXT(key => 'ROWS', value => $edit-rows.Str,
                                    size => '2', length => '2');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-STRING(text => 'Cols');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-TEXT(key => 'COLS', value => $edit-cols.Str,
                                   size => '3', length => '3');

      $.Sys.FORM-BREAK();
      $.Sys.FORM-BREAK();

      $.Sys.FORM-STRING(text => '<table border="0"><tr><td valign="top" valign="top" colspan="2">');

      $.Sys.FORM-STRING(text => 'REGEX');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-TEXT(key => 'summary', value => $summary,
                                    size => $summary-cols.Str, length => '1024');

      $.Sys.FORM-STRING(text => '</td><td></td></tr><tr><td valign="top">');


      my Str $regex = '';
      $regex = $summary.Str;

      my Str $text-string = '';
      $text-string = $wiki-text;

      $.Sys.FORM-BREAK();
      $.Sys.FORM-TEXTAREA(key => 'text',
                        value => $wiki-text,
                        rows => $edit-rows,
                        cols => $edit-cols);


      $.Sys.FORM-HIDDEN(key => 'p', value => $.CurrentWikiPage);
      $.Sys.FORM-BREAK();
      my Str $preview = self.wiki-to-html(text => $wiki-text);

      #$.Sys.FORM-STRING(text => '</td><td valign="top">PREVIEW<br/>' ~ $preview ~ '</td></tr></table>');

      #$.Sys.FORM-STRING(text => $preview);

      my $regex-result = '';
      if $regex ne '' {
        $text-string ~~ s:g/<$regex>/{
          $regex-result ~= self.eval-regex($regex-counter++, $/);
        }/;
      };

      $.Sys.FORM-STRING(text => '</td><td valign="top">REGEX MATCH RESULT<br/>' ~ $regex-result ~ '</td></tr></table>');

      $.Sys.FORM-STRING(text => '<hr/>WIKI Preview<br/>' ~ $preview);

      $cancel = '&nbsp;|&nbsp;<a href="/wiki/display?p='
            ~ $.CurrentWikiPage ~ '">cancel</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $cancel); # if $.UserID ne '';


  return True;
}

  method eval-regex($counter, Match $result) {
    return $counter.Str ~ '.&nbsp;' ~ $result ~ '&nbsp;' ~ $C_FS ~ '<br/>';
  }


  method wiki-display-page-metadata() {
    $.Sys.FORM-STRING(text => '<tt>');
    for %.Page.sort -> (:$key, :$value) {
      if $key ne '' {
        if $key ne 'text_default' { #-- skip the text
          $.Sys.FORM-STRING(text => 'PAGE.<b>' ~ $key ~ '</b> = ' ~ $value.Str);
          $.Sys.FORM-BREAK();
        }
      }
    }
    $.Sys.FORM-BREAK();
    for %.Section.sort -> (:$key, :$value) {
      if $key ne '' {
        if $key ne 'secdata' { #-- skip the text
          $.Sys.FORM-STRING(text => 'SECTION.<b>' ~ $key ~ '</b> = ' ~ $value.Str);
          $.Sys.FORM-BREAK();
        }
      }
    }
    $.Sys.FORM-BREAK();
    for %.Text.sort -> (:$key, :$value) {
      if $key ne '' {
        if $key eq 'txtdata' { #-- skip the text
          $.Sys.FORM-STRING(text => 'TEXT.<b>' ~ $key ~ '</b> = ... [skip text]');
          $.Sys.FORM-BREAK();
        }
        else {
          $.Sys.FORM-STRING(text => 'TEXT.<b>' ~ $key ~ '</b> = ' ~ $value.Str);
          $.Sys.FORM-BREAK();
        }
      }
    }
    $.Sys.FORM-STRING(text => '</tt>');

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

  

  method init-link-patterns() {
             $.ScriptName = $.Sys.get(key => 'SITE_URL') 
                 ~ '/'
                 ~ $C_APP_NAME.lc;

             self.TRACE: 'SCRIPT NAME = ' ~ $.ScriptName;

  #1***      my $self = shift;
  #2***      my ($UpperLetter, $LowerLetter, $AnyLetter, $LpA, $LpB, $LpC, $QDelim);
  #b2
             my Str $upper-letter = '';
             my Str $lower-letter = '';
             my Str $any-letter = '';
             my Str $lpA = '';
             my Str $lpB = '';
             my Str $lpC = '';
             my Str $qdelim = '';

  #e2
  #3***      # Field separators are used in the URL-style patterns below.
  #4***      if ($NewFS) {
  #b4
             if $.NewFS {
  #e4
  #5***        $FS = "\x1e\xff\xfe\x1e";    # An unlikely sequence for any charset
  #b5
               $.FS = "\x1e\xff\xfe\x1e";
  #e5
  #b6
             }
  #e6
  #6***      }
  #7***      else {
  #b7
             else {
  #e7
  #8a***        $FS = "\xb3";                # The FS character is a superscript "3"
  #b8a
                $.FS = "\xb3";
  #e8a
  #b8b
            }
  #e8b
  #8b***      }
  #9***      $FS1         = $FS . "1";      # The FS values are used to separate fields
  #10***      $FS2         = $FS . "2";      # in stored hashtables and other data structures.
  #11***      $FS3         = $FS . "3";      # The FS character is not allowed in user data.
  #b8b..11
             $.FS1 = $.FS ~ '1';
             $.FS2 = $.FS ~ '2';
             $.FS3 = $.FS ~ '3';
  #e8b..11
  #12***      $UpperLetter = "[A-Z";
  #13***      $LowerLetter = "[a-z";
  #14***      $AnyLetter   = "[A-Za-z";
  #15***      if ($NonEnglish) {
  #16***        $UpperLetter .= "\xc0-\xde";
  #17***        $LowerLetter .= "\xdf-\xff";
  #18***        if ($NewFS) {
  #19***          $AnyLetter .= "\x80-\xff";
  #20***        }
  #21***        else {
  #22***          $AnyLetter .= "\xc0-\xff";
  #23***        }
  #24***      }
  #b12..24
             $upper-letter = 'A..Z';
             $lower-letter = 'a..z';
             $any-letter = 'A..Za..z';
             if $.NonEnglish {
               $upper-letter ~= "\xc0..\xde";
               $lower-letter ~= "\xdf..\xff";
               if $.NewFS {
                 $any-letter ~= "\x80..\xff";
               }
               else {
                 $any-letter ~= "\xc0..\xff";
               }
             }

  #e12..24
  #25***      if (!$SimpleLinks) {
  #26***        $AnyLetter .= "_0-9";
  #27***      }
  #b25..27
            if !$.SimpleLinks {
              $any-letter ~= '_0..9';
            }
  #e25..27
  #28***      $UpperLetter .= "]";
  #29***      $LowerLetter .= "]";
  #30***      $AnyLetter   .= "]";
  #b28..30
           $upper-letter = '<[' ~ $upper-letter ~ ']>';
           $lower-letter = '<[' ~ $lower-letter ~ ']>';
           $any-letter = '<[' ~ $any-letter ~ ']>';
           #self.TRACE: 'UPPER: ' ~ $upper-letter;
           #self.TRACE: 'LOWER: ' ~ $lower-letter;
           #self.TRACE: 'ANY: ' ~ $any-letter;

  #e28..30
  #31***      # Main link pattern: lowercase between uppercase, then anything
  #32***      $LpA = $UpperLetter . "+" . $LowerLetter . "+" . $UpperLetter . $AnyLetter . "*";
  #b32
              $lpA = $upper-letter ~ '+ ' 
                   ~ $lower-letter ~ '+ ' 
                   ~ $upper-letter 
                   ~ $any-letter ~ '*';
              #self.TRACE: 'link pattern A: ' ~ $lpA;
              #LINK PATTERN A = <[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*
  #e32
  #33***      # Optional subpage link pattern: uppercase, lowercase, then anything
  #34***      $LpB = $UpperLetter . "+" . $LowerLetter . "+" . $AnyLetter . "*";
  #b34
              $lpB = $upper-letter ~ '+ '
                   ~ $lower-letter ~ '+ '
                   ~ $any-letter ~ '*';
              #self.TRACE: 'link pattern B: ' ~ $lpB;
              #LINK PATTERN B = <[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*

  #e34
  #35***      $LpC = $UpperLetter . "+" . $AnyLetter . "*";
  #b35
              $lpC = $upper-letter ~ '+ ' 
                   ~ $any-letter ~ '*';
              #self.TRACE: 'link pattern C: ' ~ $lpC;
              #LINK PATTERN C = <[A..Z]>+ <[A..Za..z_0..9]>*
  #e35    
  #36***      if ($UseSubpage) { # defa: True
  #37***        # Loose pattern: If subpage is used, subpage may be simple name
  #38***        $LinkPattern     = "(((?:(?:$LpA)?\\/)+$LpB)|$LpA)";
  #39***        $HalfLinkPattern = "(((?:(?:$LpB)?\\/)+$LpB)|$LpB)";
  #40***        # Strict pattern: both sides must be the main LinkPattern
  #41***      }
  #42***      else {
  #43***        $LinkPattern     = "($LpA)";
  #44***        $HalfLinkPattern = "($LpC)";
  #45***      }
  #b35..45
              if $.UseSubpage {
                $.LinkPattern = '(' 
                              ~   '(' 
                              ~     '('                   # capture 
                              ~        '(' ~ $lpA ~ ')?'  # optional lpA
                              ~        '\/'               # followed by ) 
                              ~     ')+ '                 # one or more  
                              ~     $lpB                  # and then lpB
                              ~  ')'           
                              ~  '|'                      # or
                              ~  $lpA                     # lpA
                              ~  ')';

              #self.TRACE: 'Link pattern including subpage: ' ~ $.LinkPattern;
              #link pattern = ((((<[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*)?\/)+ <[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*) |<[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*)

               $.HalfLinkPattern = '(' 
                              ~   '(' 
                              ~     '('                   # capture 
                              ~        '(' ~ $lpB ~ ')?'  # optional lpB
                              ~        '\/'               # followed by ) 
                              ~     ')+ '                 # one or more  
                              ~     $lpB                  # and then lpB
                              ~  ')'           
                              ~  '|'                      # or
                              ~  $lpB                     # lpB
                              ~  ')';
               #self.TRACE: 'Half link pattern including subpage: ' ~ $.HalfLinkPattern;
              #Half link pattern = ((((<[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*)?\/)+ <[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*) |<[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*)


              }
              else {
                $.LinkPattern = '(' ~ $lpA ~ ')';
                $.HalfLinkPattern = '(' ~ $lpC ~ ')';
              }
  #e35..45
  #46***      $QDelim = '(?:"")?';                                                          # Optional quote delimiter (not in output)
  #b46

              $qdelim = "'" ~ '"' ~ "'" ~ '<-["]>*' ~ "'" ~ '"' ~ "'";
              self.TRACE: 'Quoted delimiter: ' ~ $qdelim;
              #quoted delimited text = '"'<-["]>*'"'
  #e46
  #47***      $AnchoredLinkPattern = $LinkPattern . '#(\\w+)' . $QDelim if $NamedAnchors;
  #b47
              $.AnchoredLinkPattern = $.LinkPattern   # link pattern
                                    ~ '\#'             # then hash
                                    ~ '('             # followed by
                                    ~ '\w+'           # one or more words
                                    ~ ')';            
                                    #~ $qdelim;        # and optional quotation
               #self.TRACE: 'Anchored link pattern: ' ~ $.AnchoredLinkPattern;
               #-- Anchor link pattern = ((((<[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*)?\/)+ <[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*)|<[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*)\#(\w+)'"'<-["]>*'"'
  #e47
  #48***      $LinkPattern     .= $QDelim;
  #b48
              #-- todo: $.LinkPattern ~= $qdelim;
  #e48
  #49***      $HalfLinkPattern .= $QDelim;
  #b49
              #-- todo: $.HalfLinkPattern ~= $qdelim;
  #e49
  #50***      # pull the fast switch *alj*
  #51***      $EditLinkPattern = $LinkPattern;
  #b51
              $.EditLinkPattern = $.LinkPattern;
  #e51
  #52***      # Inter-site convention: sites must start with uppercase letter
  #53***      # (Uppercase letter avoids confusion with URLs)
  #54***      $InterSitePattern = $UpperLetter . $AnyLetter . "+";
  #b54
              $.InterSitePattern = $upper-letter ~ $any-letter ~ '+';
              #self.TRACE: 'Inter site pattern : ' ~ $.InterSitePattern;
              #-- <[A..Z]><[A..Za..z_0..9]>+ #e54
  #55***      $InterLinkPattern = "((?:$InterSitePattern:[^\\]\\s\"<>$FS]+)$QDelim)";
  #b55
              $.InterLinkPattern = $.InterSitePattern 
                                 ~ ':'
                                 ~ '\?' 
                                 ~ '\s*'
                                 ~ '\w*';

                                 #~ "'" ~ '"' ~ "'" ~ '<-["]>*' ~ "'" ~ '"' ~ "'";

              #self.TRACE: 'Inter link pattern : ' ~ $.InterLinkPattern;
              #- <[A..Z]><[A..Za..z_0..9]>+:\?\s*\w*

  #e55
  #56***      if ($FreeLinks) { #def: True
  #b56
              if $.FreeLinks {
  #e56
  #57***        # Note: the - character must be first in $AnyLetter definition
  #58***        if ($NonEnglish) { #def: False
  #59***          if ($NewFS) {
  #60***            $AnyLetter = "[-,.()' _0-9A-Za-z\x80-\xff]";
  #61***          }
  #62***          else {
  #63***            $AnyLetter = "[-,.()' _0-9A-Za-z\xc0-\xff]";
  #64***          }
  #65***        }
  #66***        else { 
  #67***          $AnyLetter = "[-,.()' _0-9A-Za-z]";
               
                  #self.TRACE: 'ANYLETTER :' ~ $any-letter;
                  #-- <[A..Za..z_0..9]> - previous value
                  $any-letter = '<[A..Za..z_0..9\-,\.()' ~ "'" ~ ' ]>';
                  #self.TRACE: 'ANYLETTER :' ~ $any-letter;
                  #-- <[A..Za..z_0..9\-,\.()' ]> - new value
  #68***        }
  #b69
              }
  #e69
  #69***      }
  #70***      $FreeLinkPattern = "($AnyLetter+";
  #71***      if ($UseSubpage) {
  #72***        $FreeLinkPattern = "((?:(?:$AnyLetter+)?\\/)*$AnyLetter+";
  #73***      }
  #74***      if ($NamedAnchors) {
  #75***        $FreeLinkPattern .= "(?:#(?:\\w+))?)";
  #76***      }
  #77***      else {
  #78***        $FreeLinkPattern .= ")";
  #79***      }
  #b69..79
              $.FreeLinkPattern = '(' ~ $any-letter ~ '+ ';
              if $.UseSubpage {
                $.FreeLinkPattern = '('
                                  ~  '( ' ~ $any-letter ~ '+ )?'
                                  ~  '\/'
                                  ~ ')* '
                                  ~ $any-letter ~ '+ ';
                if $.NamedAnchors {
                  #-- todo
                }
                else {
                 $.FreeLinkPattern ~= ')';
                }
              }

              #self.TRACE: 'FREE LINK PATTERN: ' ~ $.FreeLinkPattern;
              #- (( <[A..Za..z_0..9\-,\.()' ]>+ )?\/)* <[A..Za..z_0..9\-,\.()' ]>+
  #e69..79

  #80***      $FreeLinkPattern .= $QDelim;
  #81***      # Url-style links are delimited by one of:
  #82***      #   1.  Whitespace                           (kept in output)
  #83***      #   2.  Left or right angle-bracket (< or >) (kept in output)
  #84***      #   3.  Right square-bracket (])             (kept in output)
  #85***      #   4.  A single double-quote (")            (kept in output)
  #86***      #   5.  A $FS (field separator) character    (kept in output)
  #87***      #   6.  A double double-quote ("")           (removed from output)
  #88***      $UrlProtocols = "http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|image|download|mms|" . "prospero|telnet|gopher";
  #b88
              $.UrlProtocols = "http|https|ftp|afs|news|nntp|mid|" 
                             ~ "cid|mailto|wais|image|download|mms|" 
                             ~ "prospero|telnet|gopher";
  #e88

  #89***      $UrlProtocols .= '|file' if ($NetworkFile || !$LimitFileUrl);
  #b89
              $.UrlProtocols ~= '|file' if $.NetworkFile || !$.LimitFileUrl;

              #self.TRACE: 'URL PROTOCOLS: ' ~ $.UrlProtocols;
              # http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|image|download|mms|prospero|telnet|gopher|file

  #e89
  #90***      $UrlPattern      = "((?:(?:$UrlProtocols):[^\\]\\s\"<>$FS]+)$QDelim)";
  #b90
              $.UrlPattern = '(' 
                           ~  '('
                           ~   $.UrlProtocols 
                           ~  ')'
                           ~  '\:'
                           ~  '(\/)?'
                           ~  '\/'
                           ~  '(\S+)'  #- any char that is not whitespace
                           ~ ')';

              # self.TRACE: 'URL PATTERN: ' ~ $.UrlPattern;
              #--((http|https|ftp|afs|news|nntp|mid|cid|mailto
              #    |wais|image|download|mms|prospero|telnet|gopher|file)
              #    \:(\/)?\/(\S+))
  #e90
  #91***      $ImageExtensions = "(gif|jpg|png|bmp|jpeg)"; 
  #b91
              $.ImageExtensions = "(gif|jpg|png|bmp|jpeg)"; 

  #e91
  #92***      $RFCPattern      = "RFC\\s?(\\d+)";
  #93***      $ISBNPattern     = "ISBN:?([0-9- xX]{10,})";
  #94***      $BLOGPattern     = "blog:?$HalfLinkPattern";
  #95***      $UploadPattern   = "upload:([^\\]\\s\"<>$FS]+)$QDelim";
  #96***      $ActionPattern   = "action:?([(A-Z|a-z)0-9=&\\/]+):?$HalfLinkPattern";
  #97***      #$ActionPattern   = "action:?([(A-Z|a-z)0-9=&\\/]+):?$HalfLinkPattern";
  #98***      if ($UseSmilies) {
  #99***        %Smilies = (
  #100***          ":-?\\)(?=\\W)"     => "$SmileyPath/smile.png",
  #101***          ";-?\\)(?=\\W)"     => "$SmileyPath/blink.png",
  #102***          ":-?](?=\\W)"       => "$SmileyPath/forced.png",
  #103***          "8-?\\)(?=\\W)"     => "$SmileyPath/braindamaged.png",
  #104***          ":-\\|(?=\\W)"      => "$SmileyPath/indifferent.png",
  #105***          ":-?[/\\\\](?=\\W)" => "$SmileyPath/wry.png",
  #106***          ":-?\\((?=\\W)"     => "$SmileyPath/sad.png",
  #107***          ":-?\\{(?=\\W)"     => "$SmileyPath/frown.png",
  #108***        );
  #109***      }
  }

  method wiki-to-html(Str :$text) {
    my Str $wiki-text = '';

    self.init-link-patterns();

    $wiki-text = $text;

    #1***          my $self = shift;
    #2***          my ($pageText) = @_;
    #3***          $TableMode       = 0;
    #4***          %SaveUrl         = ();
    #5***          %SaveNumUrl      = ();
    #6***          $SaveUrlIndex    = 0;
    #7***          $SaveNumUrlIndex = 0;
    #8***          $pageText        = $self->RemoveFS($pageText);
    #b8
    $wiki-text = self.remove-field-separator(text => $wiki-text);
    #e8
    #9***          if ($RawHtml) {
    #10***            $pageText =~ s/<html>((.|\n)*?)<\/html>/$self->StoreRaw($1)/ige;
    #11***          }

    #12***          $pageText = $self->QuoteHtml($pageText);
    #b12
    $wiki-text = self.quote-html(text => $wiki-text);
    #e12
    #13***          $pageText =~ s/\.\\ *\r?\n/<br\/\>&nbsp; /g;    # .\ used for breaking lines of codes
    #b13
    $wiki-text ~~ s:g/ \. \\ ' '* \n /\<br\/\>\&nbsp\;/;
    #e13
    #14***          $pageText =~ s/\\ *\r?\n/ /g;    # Join lines with backslash at end
    #b14
    $wiki-text ~~ s:g/ \\ ' '* \n/ /;
    #e14
    #15***          $pageText =~
    #16***        s/&lt;back&gt;/$self->StoreRaw("<b>" . $self->Ts('Backlinks for: %s', $MainPage)
    #16***        . "<\/b><br \/>\n" . $self->GetPageList($self->SearchTitleAndBody($MainPage)))/ige;
    #b16
    $wiki-text ~~ s:g/ '&lt;' 'back' '&gt;' /Backlinks to MAINPAGE/;
    #e16
    #17***          $pageText =~
    #18***        s/&lt;back\s+(.*?)&gt;/$self->StoreRaw("<b>" . $self->Ts('Backlinks for: %s',
    #18***                $self->QuoteHtml($1)) . "<\/b><br \/>\n" . $self->GetPageList($self->SearchTitleAndBody($1)))/ige;
    #b18
    $wiki-text ~~ s:g/ '&lt;' 'back' \s+ (.*?) '&gt;' /Backlinks to $0/;
    #e18
    #19***          if ($ParseParas) { #-- current value = False
                    if $.ParseParas {
    #20***            # Note: The following 3 rules may span paragraphs, so they are
    #21***            #       copied from CommonMarkup
    #22***            $pageText =~ s/\&lt;nowiki\&gt;((.|\n)*?)\&lt;\/nowiki\&gt;/$self->StoreRaw($1)/ige;
    #b22
    $wiki-text ~~ s:g/
    '&lt;' 'nowiki' '&gt;'
    (.*?)
    '&lt;' \/ 'nowiki' '&gt;'
    /{
    '<b>' 
    ~ '0: ' ~ $0 
    ~ '1: ' ~ $1 
    ~ '2: ' ~ $2 
    ~ '</b>';
    }/;
    #e22
    #23***            $pageText =~ s/\&lt;code\&gt;((.|\n)*?)\&lt;\/code\&gt;/$self->StorePre($1, "code")/ige;
    #24***            $pageText =~ s/\&lt;pre\&gt;((.|\n)*?)\&lt;\/pre\&gt;/$self->StorePre($1, "pre")/ige;
    #25***            $pageText =~ s/((.|\n)+?\n)\s*\n/$self->ParseParagraph($1)/geo;
    #b25 #-- will not work bec it $.ParseParas is False
    #e25
    #26***            $pageText =~ s/(.*)<\/p>(.+)$/$1.$self->ParseParagraph($2)/geo;
    #27***          }
                    }
    #28***          else {
                    else {
    #29***            $pageText = $self->CommonMarkup($pageText, 1, 0);    # Multi-line markup
                      $wiki-text = self.common-markup(text => $wiki-text,
                                                      use-image => True,
                                                      do-lines => 0);
    #30***            $pageText = $self->WikiLinesToHtml($pageText);       # Line-oriented markup
    #b30
                      $wiki-text = self.wiki-lines-to-html(text => $wiki-text);
    #e30
    #31***          }
                    }
    #32***          while (@HeadingNumbers) {
    #33***            pop @HeadingNumbers;
    #34***            #$TableOfContents .= "</dd></dl>\n\n";
    #35***            $TableOfContents .= "\n\n";
    #36***          }
    #37***          #my $toc = '<div id="page_toc"><dl><dd><span class="wikitext"><h4>' . $self->T('Table of Contents') . '</h4></dd></dl>' . $TableOfContents . '</span></div>' if ($TableOfContents);
    #38***          my $toc = '<div id="page_toc"><span class="wikitext"><h4>' . $self->T('Table of Contents') . '</h4>' . $TableOfContents . '</span></div>' if ($TableOfContents);
    #39***          $toc = "" if (!defined $toc);
    #40***          $pageText =~ s/&lt;toc&gt;/$toc/gi;
    #41***          if ($FloatingImage) {
    #42***            $FloatingImage = "<div id='floating_image'><image src='$FloatingImage' border='0'></div>";
    #43***            $pageText =~ s/&lt;insert_picture&gt;/$FloatingImage/gi;
    #44***          }
    #45***          if ($LateRules ne '') {
    #46***            $pageText = $self->EvalLocalRules($LateRules, $pageText, 0);
    #47***          }
    #48***          return $self->RestoreSavedText($pageText);
    #b48
                $wiki-text = self.restore-saved-text(text => $wiki-text);
    #e48


    return $wiki-text;
  }

  

  method restore-saved-text(:$text) {
    my Str $wiki-text = '';
    $wiki-text = $text;
    1 while $wiki-text ~~ s:g/$C_FS(\d+)$C_FS/%.SaveUrl{$0}/; # Restore saved text
    return $wiki-text;
  }


  method store-raw(Str :$text) {
    %.SaveUrl{$.SaveUrlIndex} = $text;
    return $C_FS ~ $.SaveUrlIndex++ ~ $C_FS;
  }

  method store-raw-tag(Str :$text, Str :$tag) {
    return self.store-raw(text => "<$tag>" ~ $text ~ "</$tag>");
  }

  method store-code(Str :$text, Str :$tag) {
    my $wiki-text = '';
    $wiki-text = $text;
    $wiki-text ~~ s:g/\n/\r\n/;
    return self.store-raw(text => "<$tag>" ~ $wiki-text ~ "</$tag>");
  }

  method store-pre(Str :$text, Str :$tag) {
    my $wiki-text = '';
    $wiki-text = $text;
    return self.store-raw(text => "<$tag>" ~ $wiki-text ~ "</$tag>");
  }


  method store-sap-note(Str :$text, Str :$tag) {
    my $wiki-text = '';
    $wiki-text = $text;

    $wiki-text = '<a href="'
                    ~ 'https://launchpad.support.sap.com/#/notes/'
                    ~ $wiki-text
                    ~ '" target=sapnote_"'
                    ~ $wiki-text
                    ~ '">'
                    ~ $wiki-text
                    ~ '</a>';
    return self.store-raw(text => "<$tag>" ~ $wiki-text ~ "</$tag>");
  }


  method quote-html(Str :$text) {
    my Str $qtext = '';
    $qtext = $text;
    $qtext ~~ s:g/ <[&]> /\&amp\;/;
    $qtext ~~ s:g/ <[<]> /\&lt\;/;
    $qtext ~~ s:g/ <[>]> /\&gt\;/;
    $qtext ~~ s:g/ '&amp;' (<[#a..zA..Z0..9]>+) \; /&$0\;/;
    return $qtext;
  }

  method store-page-or-edit-link(Str :$url, Str :$desc) {
    my Str $page = '';
    my Str $name = '';
    my Str $url-name = '';

    $page = $url;
    $name = $desc;

    $url-name = $page ~ $name;

    #$url-name = 'FL:' ~ $page ~ '&nbsp;<b>' ~ $name ~ '</b>';
    $url-name = self.get-page-or-edit-link(url => $page, desc => $desc);

    return self.store-raw(text => $url-name);
  }


  method get-page-or-edit-link(Str :$url, Str :$desc) {
    my Str $page = '';
    my Str $name = '';
    my Str $url-name = '';
    $page = $url;
    $name = $desc;
    #$url-name = 'link:' ~ $page ~ '<b>' ~ $name ~ '</b>';
    $url-name = self.get-page-or-edit-anchored-link(url => $page, desc => $desc);
    return $url-name;
  }

  method get-page-or-edit-anchored-link(Str :$url, Str :$desc) {
    my Str $page = '';
    my Str $name = '';
    my Str $url-name = '';
    $page = $url;
    $name = $desc;
    #$url-name = 'link:' ~ $page ~ '<b>' ~ $name ~ '</b>';

    #-- Determine if file exists

    #self.TRACE: 'Determine if file exists: ' ~ self.get-page-filename(filename=> $page);
    my Str $page-filename = '';
    $page-filename = self.get-page-filename(filename=> $page);

    my Str $edit-link = '';
    if $page-filename.IO.e {
      $edit-link = self.get-edit-link(page => $page, text => '<b>' ~ $name ~ '</b>');
    }
    else {
      $edit-link = $name ~ self.get-edit-link(page => $page, text => '<b><sup>?</sup></b>');
    }
    #$edit-link = self.get-edit-link(page => $page, text => $name);

    $url-name = $edit-link; # ~ '<b>' ~ $name ~ '</b>';

    return $url-name;
  }

  method get-edit-link(Str :$page, Str :$text) {
    my Str $page-id = '';
    my Str $page-text = '';
    my Str $edit-link = ''; 

    $page-id = $page;
    $page-text = $text;
    $edit-link = $page-id ~ '&nbsp;<b>' ~ $text ~ '</b>';

    $edit-link = self.script-link-class(action => 'action=edit&p=' ~ $page-id ~ '', 
                                        text => $page-text,
                                        class => 'wikipageedit');
    return $edit-link;
  }

  method script-link-class(Str :$action, Str :$text, Str :$class) {
    my Str $page-action = '';
    my Str $page-text = '';
    my Str $page-class = '';
    my Str $page-id = '';

    $page-action = $action;
    $page-text = $text;
    $page-class = $class;
    $page-action = '<a href="' 
                 ~ $.ScriptName 
                 ~ self.script-link-char() 
                 ~ $page-action
                 ~ '">'
                 ~ $page-text 
                 ~ '</a>';
    $page-id = $page-action;
  
    return $page-id;
  }

  method script-link-char() {
    my Str $c = '';
    if $.SlashLinks {
      $c = '/';
    }
    else {
      $c = '?';
    }
    return $c;
  }

  method common-markup(Str :$text, Bool :$use-image, Int :$do-lines) {
    my $wiki-text = '';
    $wiki-text = $text;

    #1***    my $self = shift;
    #2***      my ($text, $useImage, $doLines) = @_;
    #3***      local $_ = $text;
    #4***      if ($doLines < 2) {    # 2 = do line-oriented only
    #b4
               if $do-lines < 2 {
    #e4
    #5***        # The <nowiki> tag stores text with no markup (except quoting HTML)
    #6***        if (m/\&lt;toc\&gt;/) {
    #b6
                 if $wiki-text ~~ m:g/ '&lt;' 'toc' '&gt;' / {
    #e6
    #7***          $TOCFlag = 1;
    #b7
                   $.TOCFlag = True;
    #e7
    #b8
                 }
    #e8
    #8***        }
    #9***         s/\&lt;localdir\&gt;((.|\n)*?)\&lt;\/localdir\&gt;/$self->StoreRaw($self->DisplayLocalDirectory($1))/ige;
    #10***        s/\&lt;nowiki\&gt;((.|\n)*?)\&lt;\/nowiki\&gt;/$self->StoreRaw($1)/ige;
    #b10
    $wiki-text ~~ s:g/
    '&lt;' 'nowiki' '&gt;'
    (.*?)
    '&lt;' \/ 'nowiki' '&gt;'
    /{
    self.store-raw(text => $0.Str);
    #'<b>' 
    #~ '0: ' ~ $0 
    #~ '1: ' ~ $1 
    #~ '2: ' ~ $2 
    #~ '</b>';
    }/;

    #e10
    #11***        s/\&lt;wikiproc\&gt;((.|\n)*?)\&lt;\/wikiproc\&gt;/$self->WikiProc($1)/ige;
    #12***        s/\&lt;training\&gt;((.|\n)*?)\&lt;\/training\&gt;/$self->SetTrainingText($1)/ige;
    #13***        s/\&lt;postit\&gt;((.|\n)*?)\&lt;\/postit\&gt;/$self->PostItNote($1)/ige;
    #14***        s/\&lt;scroll\&gt;((.|\n)*?)\&lt;\/scroll\&gt;/$self->ScrollText($1)/ige;
    #15***        s/\&lt;sidebar\&gt;((.|\n)*?)\&lt;\/sidebar\&gt;/$self->SideBar($1)/ige;
    #16***        s/\&lt;sidemenu\&gt;((.|\n)*?)\&lt;\/sidemenu\&gt;/$self->SideMenu($1)/ige;
    #17***        s/\&lt;menubar\&gt;((.|\n)*?)\&lt;\/menubar\&gt;/$self->MenuBar($1)/ige;
    #18***        s/\&lt;tabmenubar\&gt;((.|\n)*?)\&lt;\/tabmenubar\&gt;/$self->TabMenuBar($1)/ige;
    #b18
                   
    #e18
    #19***        s/\&lt;menu\&gt;((.|\n)*?)\&lt;\/menu\&gt;/$self->PopupMenu($1)/ige;
    #20***        s/\&lt;sitemenubar\&gt;((.|\n)*?)\&lt;\/sitemenubar\&gt;/$self->SiteMenuBar($1)/ige;
    #21***        s/\&lt;menugroup\&gt;((.|\n)*?)\&lt;\/menugroup\&gt;/$self->SideMenuGroup($1)/ige;
    #b21
                  $wiki-text ~~ s:g/
                  '&lt;'
                  'menugroup'
                  '&gt;'
                  (.*?)
                  '&lt;'
                  \/
                  'menugroup'
                  '&gt;'
                  /{
                    #-- TODO: HANDLE THIS MENUGROUP later
                    ''
                  }/;
    #e21
    #22***        s/\&lt;insertpage\&gt;((.|\n)*?)\&lt;\/insertpage\&gt;/$self->ExtractPageText($1)/ige;
    #23***        s/\&lt;banner\&gt;((.|\n)*?)\&lt;\/banner\&gt;/$self->PageBanner($1)/ige;
    #24***        s/\&lt;pagetitle\&gt;((.|\n)*?)\&lt;\/pagetitle\&gt;/$self->PageTitle($1)/ige;
    #25***        s/\&lt;picture\&gt;((.|\n)*?)\&lt;\/picture\&gt;/$self->FloatImage($1)/ige;
    #26***        # The <pre> tag wraps the stored text with the HTML <pre> tag
    #27***        s/\&lt;code\&gt;((.|\n)*?)\&lt;\/code\&gt;/$self->StoreCode($1, "nowiki")/ige;
    #28***        s/\&lt;sapnote\&gt;((.|\n)*?)\&lt;\/sapnote\&gt;/$self->StoreSAPNote($1, "nowiki")/ige;
    #b28
    $wiki-text ~~ s:g/
    '&lt;' 'sapnote' '&gt;'
    (\d+)
    \s*
    (\S+)*
    '&lt;' \/ 'sapnote' '&gt;'
    /{
    self.store-raw(text => self.sap-note(note => $0, desc => $1));
    #'<b>' 
    #~ '0: ' ~ $0 
    #~ '1: ' ~ $1 
    #~ '2: ' ~ $2 
    #~ '</b>';
    }/;

    #e28
    #29***        s/\&lt;pre\&gt;((.|\n)*?)\&lt;\/pre\&gt;/$self->StorePre($1, "pre")/ige;
    #30***        #s/\&lt;center\&gt;((.|\n)*?)\&lt;\/center\&gt;/$self->StorePre($1, "center")/ige;
    #31***        if ($EarlyRules ne '') {
    #32***          $_ = $self->EvalLocalRules($EarlyRules, $_, !$useImage);
    #33***        }
    #34***        s/\[\#(\w+)\]/$self->StoreHref(" name=\"$1\"")/ge if $NamedAnchors;
    #b34
                  $wiki-text ~~ s:g/ '[' '#' (\w+) ']' /{
                    self.store-href(anchor => '', text => " name=\"$0\"")
                  }/ if $.NamedAnchors;
    #e34
    #35***        # Note that these tags are restricted to a single paragraph
    #36***        my ($t);
    #37**        if ($HtmlTags) { #default value = True
    #b37
                 if $.HtmlTags {
    #e37
    #38***          foreach $t (@HtmlPairs) {
    #b38
                    for @.HtmlPairs -> $t {
    #e38
    #39***            s/
    #40***          \&lt\;$t(\s[^<>]+?)?\&gt\;  # match opening tag with params
    #41***          (?>(.*?)((\n\n)|(\&lt\;\/$t\&gt\;)))  # match up to closing tag or end para
    #42***          (?<!\n\n) # fail if end of para
    #43***          /<$t$1>$2<\/$t>/gisx;    #replacement string
    #b39-43
                    $wiki-text ~~ s:g/ '&lt;' <$t> '&gt;' # match opening tag
                    ( .*? )
                     '&lt;' '/' <$t> '&gt;' # match up to closing tag
                    /{
                    "<$t>" ~ $0 ~ "</$t>"
                    }/;

    #e39-43
    #b44
                    }
    #e44
    #44***          }

    #45***          foreach $t (@HtmlSingle) {
    #b45
                    for @.HtmlSingle -> $t {
    #e45
    #46***            s/
    #47***            \&lt\;$t(\s[^<>]+?)?\&gt\;   # match tag with param
    #48***            /<$t$1>/gix;           # replacement string
    #b46..48
                      $wiki-text ~~ s:g/ '&lt;' <$t> '&gt;'
                      /{
                      "<" ~ $0 ~ "/>"
                      }/;
    #e46..49
    #b49
                    }
    #e49
    #49***          }
    #b50
                  }
    #e50
    #50***        }
    #51***        else {
    #b51
                  else {
    #e51
    #52***          foreach $t (qw/b i center strong em tt/) {
    #53***            s/
    #54***              \&lt\;$t\&gt\; # match opening tag
    #55***              (?>(.*?)((\n\n)|(\&lt\;\/$t\&gt\;))) # up to closing tag or end of para
    #56***              (?<!\n\n)  # fail if end of para
    #57***            /<$t>$1<\/$t>/gisx;     #replacement string
    #58***          }
    #59***          s/\&lt\;br\&gt\;/<br>/gi;
    #b59
                    $wiki-text ~~ s:g/'&lt\;' 'br' 'gt;'/\<br\/\>/;
    #e59
    #b60
                  }
    #e60
    #60***        }
    #61***        s/\&lt;br\&gt;/<br>/gi;                                # Allow simple line break anywhere
    #b61
                  $wiki-text ~~ s:g/'&lt;' 'br' '&gt;'/\<br\/\>/;  # Allow simple line break anywhere
    #e61
    #62***        s/\&lt;tt\&gt;(.*?)\&lt;\/tt\&gt;/<tt>$1<\/tt>/gis;    # <tt> (MeatBall)
    #63***        s/([^#])#(\w+)#/$1 . ++$Counters{$2}/ge;
    #64***        # POD style markup
    #65***        s/
    #66***      ([biu]+)\&lt\; #match opening tag
    #67***      (?>(.*?)((\n\n)|(\&gt\;))) # match up to closing tag or end of para
    #68***      (?<!\n\n)  # fail if end of para
    #69***      /"<" . join("><", split("", $1)) . ">" . $2
    #70***        . "<\/" . join("><\/", split("", scalar(reverse($1)))) . ">"/gisex;    #replacement string
    #71***        #bi20090828dma
    #72***        s/
    #73***      TEXT\&lt\; #match opening tag
    #74***      (?>(.*?)((\n\n)|(\&gt\;))) # match up to closing tag or end of para
    #75***      (?<!\n\n)  # fail if end of para
    #76***      /$self->GetTextElement($1)/gisex;                                       #replacement string
    #77***        #ei20090828dma
    #78***        #
    #79***        #bi20180106dma

    #80***        s/\%ICON\{(\w*)\}\%/$self->StoreIconTag($1)/geo;
    #b80
                  $wiki-text ~~ s:g/'%ICON{' (\w*) '}%'/{
                    self.store-icon-tag(icon => $0)
                  }/;
    #e80

    #81***        #
    #82***        #--https://foswiki.org/System/DocumentGraphics
    #83***        #
    #84***        #ei20180106dma
    #85***        if ($HtmlLinks) {
    #86***          s/\&lt;A(\s[^<>]+?)\&gt;(.*?)\&lt;\/a\&gt;/$self->StoreHref($1, $2)/gise;
    #87***        }
    #88***        s/$ActionPattern/$self->StoreAction($1, $2, $3)/geo;
    #89***        if ($SearchLinks) {
    #90***          s/\{\?\s*([^\|]*?)\s*(\|\s*(.*?)\s*)?\}/$self->StoreSearchLink($1, $3)/geo;
    #91***        }
    #92***        if ($FreeLinks) {
    #b92
                  if $.FreeLinks { #-def: True
    #e92
    #93***          # Consider: should local free-link descriptions be conditional?
    #94***          # Also, consider that one could write [[Bad Page|Good Page]]?
    #95***          s/\[\[$FreeLinkPattern\|([^\]]+)\]\]/$self->StorePageOrEditLink($1, $2)/geo;
    
    #b95
                    #self.TRACE: 'FREELINKPATTERN: ' ~ $.FreeLinkPattern;
                    $wiki-text ~~ s:g/
                    \[
                    \[
                     (
                     (( <[A..Za..z_0..9\-,\.()' ]>+ )?\/)* <[A..Za..z_0..9\-,\.()' ]>+
                     )
                     \s*
                     \|
                     (.*?)
                    \]
                    \]
                    /{
                      self.store-page-or-edit-link(url => $0.Str, desc => $1.Str);
                    }/;

    #e95
    #96***          s/\[\[$FreeLinkPattern\]\]/$self->StorePageOrEditLink($1, "")/geo;
    #b96
                    $wiki-text ~~ s:g/
                    \[
                    \[
                     (
                     (( <[A..Za..z_0..9\-,\.()' ]>+ )?\/)* <[A..Za..z_0..9\-,\.()' ]>+
                     )
                    \]
                    \]
                    /{
                    #'<b>0: ' ~ $0.Str ~ '; 1: ' ~ $1.Str ~ '</b>'
                      self.store-page-or-edit-link(url => $0.Str, desc => $0.Str);
                    }/;
    #e96
    #97***          s/\[\[$AnchoredLinkPattern\|([^\]]+)\]\]/$self->StoreAnchoredLink($1, $2, $3)/geos if $NamedAnchors;
    #b97
                    #self.TRACE: 'TODO/TOCHECK: ANCHORED LINK PATTERN: ' ~ $.AnchoredLinkPattern;

                    # ((((<[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*)?\/)+ <[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*)|<[A..Z]>+ <[a..z]>+ <[A..Z]><[A..Za..z_0..9]>*)\#(\w+)
                    $wiki-text ~~ s:g/
                    \[
                    \[
                    (
                     ((((<[A..Z]>+ 
                         <[a..z]>+ 
                         <[A..Z]><[A..Za..z_0..9]>*)?\/)+ 
                         <[A..Z]>+ <[a..z]>+ <[A..Za..z_0..9]>*)
                         |
                         <[A..Z]>+ 
                         <[a..z]>+ 
                         <[A..Z]><[A..Za..z_0..9]>*)\#(\w+)
                    )
                    \]
                    \]
                    /{
                      '0: ' ~ $0.Str ~ '; 1: ' ~ $1.Str
                    }/;

    #e97

    #b98
                  }
    #e98
    #98***        }
    #99***        if ($BracketText) {    # Links like [URL text of link]
    #b99
                  if $.BracketText == 2 {
    #e99

    #100***          s/\[$UrlPattern\s+([^\]]+?)\]/$self->StoreBracketUrl($1, $2, $useImage)/geos;
    #b100
    #                  self.TRACE: 'URL PATTERN :' ~ $.UrlPattern;
                     $wiki-text ~~ s:g/
                     \[
                     (
                     ((
                     http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|image|download|mms|prospero|telnet|gopher|file
                     )
                     \:
                     (\/)?
                     \/)
                     (\S+)
                     )
                     \s*
                     (\S+)
                     \]
                     /{
                     #        ' 0: <u>' ~ $0.Str ~ '</u>'
                     #      ~ ';1: <u>' ~ $1.Str ~ '</u>' 
                     #      ~ ';2: <u><b>' ~ $2.Str ~ '</b></u>' 
                     self.store-bracket-url(url => $0.Str, 
                                            text => $1.Str)
                     }/;
    #                 #-- 0 - url 
    #                 #-- 1 - description
    #e100
    #101***          s/\[$InterLinkPattern\s+([^\]]+?)\]/$self->StoreBracketInterPage($1, $2,
    #102***                                                                $useImage)/geos;
    #103***          if ($WikiLinks && $BracketWiki) {    # Local bracket-links
    #104***            s/\[$LinkPattern\s+([^\]]+?)\]/$self->StoreBracketLink($1, $2)/geos;
    #105***            s/\[$AnchoredLinkPattern\s+([^\]]+?)\]/$self->StoreBracketAnchoredLink($1,
    #106***                                                  $2, $3)/geos if $NamedAnchors;
    #107***          }
    #b108
                   }
    #e108
    #108***        }

    #109***        s/\[$UrlPattern\]/$self->StoreBracketUrl($1, "", 0)/geo;
    #b109
                   #self.TRACE: 'URL PATTERN :' ~ $.UrlPattern;
                   $wiki-text ~~ s:g/
                   \[
                    (
                    (http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|image|download|mms|prospero|telnet|gopher|file)
                    \:
                    (\/)?
                    \/
                    (\S+)
                    )
                    \s*
                    (
                    (.*?)
                    )
                   \]
                   /{
                     self.store-bracket-url(url => $0.Str,
                                            text => $1.Str);
                     #'<b>0: ' ~ $0.Str 
                     #~ '; 1:' ~ $1.Str ~ '</b>'
                   }/;

    #e109

    #110***        s/\[$InterLinkPattern\]/$self->StoreBracketInterPage($1, "", 0)/geo;
    #b110
    #begin: TODO: LATER - no matching text yet
                   #self.TRACE: 'INTERLINK PATTERN: ' ~ $.InterLinkPattern;
                   $wiki-text ~~ s:g/
                   \[
                   <[A..Z]><[A..Za..z_0..9]>+
                   \:
                   \?
                   \s*
                   \w*
                   \]
                   /{
                   '<b>0: ' ~ $0.Str 
                   ~ '; 1:' ~ $1.Str ~ '</b>'

                   }/;
    #end: TODO: LATER - no matching text yet
    #e110
    #111***        s/\b$UrlPattern/$self->StoreUrl($1, $useImage)/geo;    #--
    #b111

                   #self.TRACE: 'URL PATTERN: ' ~ $.UrlPattern;
                   $wiki-text ~~ s:g/
                   \[
                   (
                   (http|https|ftp|afs|news|nntp|mid|cid|mailto|wais|image|download|mms|prospero|telnet|gopher|file)
                   \:
                   (\/)?\/?
                   (\S+)
                   )
                   \s*
                   (\S+)
                   \]
                   /{
                   self.store-bracket-url(url => $0.Str,
                                          text => $1.Str);
                   #'<b>' 
                   #~ '0: ' ~ $0.Str 
                   #~ '; 1:' ~ $1.Str 
                   #~ '; 2:' ~ $2.Str 
                   #~ '; 3:' ~ $3.Str 
                   #~ '</b>'
                   }/;


    #e111
    #112***        s/\b$InterLinkPattern/$self->StoreInterPage($1, $useImage)/geo;
    #113***        if ($WikiLinks) {
    #b113
                   if $.WikiLinks {
    #e113
    #114***          s/$AnchoredLinkPattern/$self->StoreRaw($self->GetPageOrEditAnchoredLink($1,
    #115***                                $2, ""))/geo if $NamedAnchors;
    #116***          # CAA: Putting \b in front of $LinkPattern breaks /SubPage links
    #117***          #      (subpage links without the main page)
    #118***          s/$LinkPattern/$self->GetPageOrEditLink($1, $2)/geo;
    #b118
                     #self.TRACE: 'LINK PATTERN: ' ~ $.LinkPattern;
                     $wiki-text ~~ s:g/
                     \[
                     \[
                     (.*?)  #0 - free-to-normal (wiki link)
                     \|
                     (.*?)  #1 - description
                     \]
                     \]
                     /{
                     self.store-raw(text => self.get-page-or-edit-link(url => self.free-to-normal(text => $0.Str), 
                                        desc => $1.Str))
                   #'<b>' 
                   #~ '0: ' ~ $0.Str  ~ self.free-to-normal(text => $0.Str)
                   #~ '; 1:' ~ $1.Str 
                   #~ '; 2:' ~ $2.Str 
                   #~ '; 3:' ~ $3.Str 
                   #~ '</b>'

                     }/;

                     #self.TRACE: 'LINK PATTERN: ' ~ $.LinkPattern;
                     $wiki-text ~~ s:g/
                     \[
                     \[
                     (.*?)  #0 - free-to-normal (wiki link)
                     \]
                     \]
                     /{
                     self.store-raw(text => self.get-page-or-edit-link(url => self.free-to-normal(text => $0.Str), 
                                        desc => $0.Str))
                   #'<b>' 
                   #~ '0: ' ~ $0.Str  ~ self.free-to-normal(text => $0.Str)
                   #~ '; 1:' ~ $1.Str 
                   #~ '; 2:' ~ $2.Str 
                   #~ '; 3:' ~ $3.Str 
                   #~ '</b>'

                     }/;



    #e118
    #b119
                   }
    #e119
    #119***        }
    #120***        s/\&lt;hide\&gt;((.|\n)*?)\&lt;\/hide\&gt;/$self->StorePre("", "hide")/ige;
    #121***        s/\b$RFCPattern/$self->StoreRFC($1)/geo;
    #122***        s/\b$ISBNPattern/$self->StoreISBN($1)/geo;
    #123***        s/\[(?:(\w+);)\s*(\S+\.$ImageExtensions)\s*\]/$self->StoreImageTagAlign($2, $1)/geo; #dbChange for [] images.
    #124***        s/\[(?:(\w+:\w+)\@)?\s*(\S+\.$ImageExtensions)\s*\]/$self->StoreImageTagCSS($2, $1)/geo;#dbChange for [] images.
    #125***        if ($UseUpload) {
    #126***          #bd20090824dma
    #127***          #      s/$UploadPattern/$self->StoreUpload($1)/geo;
    #128***          #ed20090824dma
    #129***          #bi20090824dma
    #130***          #correct format: [upload:uploaded_doc.ext Description]
    #131***          #invalid format: [upload:uploaded_do.ext] -- to be fixed
    #132***          s/\[$UploadPattern\s+([^\]]+?)\]/$self->StoreUpload($1, $2, $useImage)/geos;
    #133***          #ei20090824dma
    #134***        }
    #135***        if ($ThinLine) {
    #136***          if ($OldThinLine) {    # Backwards compatible, conflicts with headers
    #137***            s/====+/<hr noshade class=wikiline size=2>/g;
    #138***          }
    #139***          else {                 # New behavior--no conflict
    #140***            s/------+/<hr noshade class=wikiline size=2>/g;
    #141***          }
    #142***          s/----+/<hr noshade class=wikiline size=1>/g;
    #b140
                     $wiki-text ~~ s:g/
                     '----'+
                     /{
                     '<hr noshade class=wikiline size=1'
                     }/;
    #e140
    #143***        }
    #144***        else {
    #145***          s/----+/<hr class=wikiline>/g;
    #146***        }
    #147***        if ($UseSmilies) {
    #148***          foreach my $regexp (keys %Smilies) {
    #149***            s/$regexp/<img src="$Smilies{$regexp}" alt="$&">/g;
    #150***          }
    #151***        }
    #152***        if ($AutoMailto) {
    #153***          s/([A-z0-9-_]+(?:\.[A-z0-9-_]+)*)\@([A-z0-9-_]+(?:\.[A-z0-9-_]+)*(?:\.[A-z]{2,})+)/<a href="mailto:$1\@$2">$1\@$2<\/a>/g;
    #154***        }
    #b155
                 }
    #e155
    #155***      }
    #156***      if ($doLines) {
    #b156
                 if $do-lines > 0 {
    #e156
    #157***        # 0 = no line-oriented, 1 or 2 = do line-oriented
    #158***        # The quote markup patterns avoid overlapping tags (with 5 quotes)
    #159***        # by matching the inner quotes for the strong pattern.
    #160***        s/('*)'''(.*?)'''/$1<strong>$2<\/strong>/g;
    #161***        s/''(.*?)''/<em>$1<\/em>/g;
    #162***        if ($UseHeadings) {
    #b162
                   if $.UseHeadings {
    #e162
    #163***          s/(^|\n)\s*(\=+)\s+([^\n]+)\s+\=+/$self->WikiHeading($1, $2, $3)/geo;
                     $wiki-text ~~ s:g/
                     ^^
                     \s*
                     (\=+)
                     (.*?)
                     \s*
                     (\=+)
                     /{
                   #'<b>' 
                   #~ '0: ' ~ $0.Str 
                   #~ '; 1:' ~ $1.Str 
                   #~ '; 2:' ~ $2.Str 
                   #~ '; 3:' ~ $3.Str 
                   #~ '</b>'
                   self.wiki-heading(prefix => $0.Str,
                                     heading => $1.Str,
                                     suffix => $2.Str);
                     }/;
    #b164
                   }
    #e164
    #164***        }
    #165***        if ($TableMode) {
    #166***          s/((\|\|)+)/"<\/TD><TD class='wikitablecell' valign='top' COLSPAN=\"" . (length($1)\/2) . "\">"/ge;
    #167***        }
    #168***        s/(\@[lri]\@)(\S+\.(gif|jpg|png|jpeg))\s/$self->GetImgTag($1, $2)/gei;
    #b169
                 }
    #e169
    #169***      }
    #170***      s/\{\{(\S+)\s/$self->FontStyle($1)/ge;
    #171***      s|\}\}|</span>|g;
    #b170
                 $wiki-text ~~ s:g/
                 \{\{
                 \s*
                 (.*?)   #0
                 \,
                 \s*
                 (\d+)   #1
                 \%?
                 \,?
                 (.*?)   #2
                 \}\}
                 /{
                   self.font-style(color => $0.Str,
                                   size => $1.Str,
                                   text => $2.Str)
                   #'<b>' 
                   #~ '0: ' ~ $0.Str 
                   #~ '; 1:' ~ $1.Str 
                   #~ '; 2:' ~ $2.Str 
                   #~ '</b>'
                   #0 - color
                   #1 - size
                   #2 - description
                 }/;
    #e170

    #172***      if ($FullTable) {
    #173***        #This code is pretty trivial. We take table attributes and put them in a string.
    #174***        #Then we iterate over that string, looking for 'safe' matches, adding those matches to
    #175***        #another string which ultimately becomes the actual tag. Simple, really. :) I think the
    #176***        #best strength of regexp, is that we can 'execute' strings. This should render tables
    #177***        #perfectly, with most of the HTML 3.0 table attributes. You can also put images in tables
    #178***        #by simply using the image URL, and enclosing it in a cell (the aligns, etc, should work).
    #179***        while (my ($table_str) = /&lt;table(.{0,96}?)&gt;.*?&lt;\/table&gt;/gis) {
    #180***          my $table_attr;
    #181***          my $table = "<table";
    #182***          foreach $table_attr (
    #183***            "border=\"?[0-9]{1\,2}\"?",           "cellpadding=\"?[0-9]{1\,2}\"?",
    #184***            "cellspacing=\"?[0-9]{1\,2}\"?",      "width\=\"?(:?\\b(:?100|[0-9]{1,2})\\b%|\\b(:?800|[1-7]?[0-9]{1,2}\\b))\"?",
    #185***            "align\=\"?(:?left|center|right)\"?", "bgcolor\=\"?#[0-9A-Fa-f]{6}\"?"
    #186***            ) {
    #187***            $table .= " " . $1 if ($table_str =~ /($table_attr)/is);
    #188***          }
    #189***          $table .= ">";
    #190***          s/&lt;table(.*?)&gt;(.*?)&lt;\/table&gt;/\L$table\E$2<\/table>/is;
    #191***          while (my ($td_str) = /&lt;td(.{0,96}?)&gt;.*?&lt;\/td&gt;/gis) {
    #192***            my $td_attr;
    #193***            my $td = "<td";
    #194***            foreach $td_attr (
    #195***              "align\=\"?(:?left|center|right)\"?", "valign\=\"?(:?top|middle|bottom|baseline)\"?",
    #196***              "colspan\=\"?[0-9]{1\,2}\"?",         "background\=\"[\/a-zA-Z0-9.]*[a-zA-Z.]\"?",
    #197***              "rowspan\=\"?[0-9]{1\,2}\"?",         "width\=\"?(:?\\b(:?100|[0-9]{1,2})\\b%|\\b(:?200|[1-2]?[0-9]{1,2}\\b))\"?",
    #198***              "bgcolor\=\"?#[0-9A-Fa-f]{6}\"?"
    #199***              ) {
    #200***              $td .= ' ' . $1 if ($td_str =~ /($td_attr)/is);
    #201***              #$m =~ s/\/[a-z]\//\/uc($1)\//;
    #202***              #$td .= " [$m] " . $m if ($m ne ''); # if ( $td_str =~ /($td_attr)/is );
    #203***            }
    #204***            $td .= ">";
    #205***            #bd20170414
    #206***            #s/&lt;td(.*?)&gt;(.*?)&lt;\/td&gt;/$td\E$2<\/td>/is;
    #207***            #ed20170414
    #208***            #bi20170414
    #209***            s/&lt;td(.*?)&gt;(.*?)&lt;\/td&gt;/$td$2<\/td>/is;
    #210***            #ei20170414
    #211***            #---- s/&lt;td(.*?)&gt;(.*?)&lt;\/td&gt;/\L$td\E$2<\/td>/is;
    #212***          }
    #213***          while (my ($th_str) = /&lt;th(.{0,96}?)&gt;.*?&lt;\/th&gt;/gis) {
    #214***            my $th_attr;
    #215***            my $th = "<th";
    #216***            foreach $th_attr (
    #217***              "align\=\"?(:?left|center|right)\"?",
    #218***              "valign\=\"?(:?top|middle|bottom|baseline)\"?",
    #219***              "colspan\=\"?[0-9]{1\,2}\"?",
    #220***              "rowspan\=\"?[0-9]{1\,2}\"?",
    #221***              "width\=\"?(:?\\b(:?100|[0-9]{1,2})\\b%|\\b(:?200|[1-2]?[0-9]{1,2}\\b))\"?",
    #222***              "bgcolor\=\"?#[0-9A-Fa-f]{6}\"?"
    #223***              ) {
    #224***              $th .= " " . $1 if ($th_str =~ /($th_attr)/is);
    #225***            }
    #226***            $th .= ">";
    #227***            s/&lt;th(.*?)&gt;(.*?)&lt;\/th&gt;/\L$th\E$2<\/th>/is;
    #228***          }
    #229***          while (my ($tr_str) = /&lt;tr(.{0,36}?)&gt;.*?&lt;\/tr&gt;/gis) {
    #230***            my $tr_attr;
    #231***            my $tr = "<tr";
    #232***            foreach $tr_attr ("align\=\"?(:?left|center|right)\"?", "valign\=\"?(:?top|middle|bottom|baseline)\"?") {
    #233***              $tr .= " " . $1 if ($tr_str =~ /($tr_attr)/is);
    #234***            }
    #235***            $tr .= ">";
    #236***            s/&lt;tr(.*?)&gt;(.*?)&lt;\/tr&gt;/\L$tr\E$2<\/tr>/is;
    #237***          }
    #238***        }
    #239***      }
    #240***      return $_;



    return $wiki-text;
  }

  method store-bracket-url(Str :$url, 
                           Str :$text) {
    my Str $uri = '';
    my Str $name = '';
    my Str $http = '';
    my Bool $internet-link = False;
    $uri = $url.Str;
    $name = $text;
    if $uri ~~ m:g/^https?:(.*)/ {
      my $uri-link = $0.Str;
      $internet-link = True if $uri-link ~~ m:g/\/\//; 
    }
    $uri ~= '" target="_blank' if $internet-link; 

    $http = '<a href="' ~ $uri ~ '">' ~ $name ~ '</a>';
    #return $http;
    return self.store-raw(text => $http);
 }

  method wiki-lines-to-html(Str :$text) {
    my Str $wiki-text = '';
    $wiki-text = $text;


    #1***  my $self = shift;
    #2***    my ($pageText) = @_;
    #3***    my ($pageHtml, @htmlStack, $code, $codeAttributes, $depth, $oldCode);
    #4***    @htmlStack = ();
    #5***    $depth     = 0;
    #6***    $pageHtml  = "";
    #7***    foreach (split(/\n/, $pageText)) {    # Process lines one-at-a-time
    #b7
             for $wiki-text.lines {
    #e7
    #8***      $code           = '';
    #9***      $codeAttributes = '';
    #10***      $TableMode      = 0;
    #11***      $_ .= "\n";
    #12***      if (s/^(\;+)([^:]+\:?)\:/<dt>$2<dd>/) {
    #13***        $code  = "DL";
    #14***        $depth = length $1;
    #15***      }
    #16***      elsif (s/^(\:+)/<dt><dd>/) {
    #17***        $code  = "DL";
    #18***        $depth = length $1;
    #19***      }
    #20***      elsif (s/^(\*+)/<li>/) {
    #21***        $code  = "UL";
    #22***        $depth = length $1;
    #23***      }
    #24***      elsif (s/^(\#+)(\d*)([aAiI]?)/'<li' . ($2 ? " value=\"$2\"" : '') . '>'/e) {
    #25***        $code  = "OL";
    #26***        $depth = length $1;
    #27***        if ($3) {
    #28***          $codeAttributes = " type=\"$3\"";
    #29***        }
    #30***      }
    #31***      elsif (
    #32***        $TableSyntax
    #33***        && s/^((\|\|)+)(.*)\|\|\s*$/"<TR VALIGN='CENTER' "
    #34***                                . "ALIGN='LEFT'><TD class='wikitablecell' valign='top' colspan='"
    #35***                                . (length($1)\/2) . "'>" . $self->Table_nbsp($3) . "<\/TD><\/TR>\n"/e) {
    #36***        $code           = 'TABLE';
    #37***        $codeAttributes = " BORDER='0'";
    #38***        $TableMode      = 1;
    #39***        $depth          = 1;
    #40***      }
    #41***      elsif (/^[ \t].*\S/) {
    #42***        $code  = "PRE";
    #43***        $depth = 1;
    #44***      }
    #45***      else {
    #46***        $depth = 0;
    #47***      }
    #48***      while (@htmlStack > $depth) {    # Close tags as needed
    #49***        $pageHtml .= "</" . pop(@htmlStack) . ">\n";
    #50***      }
    #51***      if ($depth > 0) {
    #52***        $depth = $IndentLimit if ($depth > $IndentLimit);
    #53***        if (@htmlStack) {              # Non-empty stack
    #54***          $oldCode = pop(@htmlStack);
    #55***          if ($oldCode ne $code) {
    #56***            $pageHtml .= "</$oldCode><$code>\n";
    #57***          }
    #58***          push(@htmlStack, $code);
    #59***        }
    #60***        while (@htmlStack < $depth) {
    #61***          push(@htmlStack, $code);
    #62***          $pageHtml .= "<$code$codeAttributes>\n";
    #63***        }
    #64***      }
    #65***      if (!$ParseParas) {
    #b65
                if !$.ParseParas {
    #e65
    #66***        s/^\s*$/<p><\/p>\n/;    # Blank lines become <p></p> tags
    #b66
                  $wiki-text ~~ s:g/
                    ^^\s*$$
                  /{
                  '<p></p>' 
                  }/;
    #e66
    #b67
                }
    #e67
    #67***      }

    #68***      $pageHtml .= $self->CommonMarkup($_, 1, 2);    # Line-oriented common markup
    #b68
                $wiki-text = self.common-markup(text => $wiki-text,
                                                      use-image => True,
                                                      do-lines => 2);

    #e68
    #b69
              }
    #e59
    #69***    }

    #70***    while (@htmlStack > 0) {                         # Clear stack
    #71***      $pageHtml .= "</" . pop(@htmlStack) . ">\n";
    #72***    }
    #73***    return $pageHtml;

    return $wiki-text;
  }
  

  method wiki-heading(:$prefix, :$heading, :$suffix) {
    my $headtext = $heading;
    if $prefix.chars == $suffix.chars {
      $headtext = '<H' ~ $prefix.chars ~ '>' ~ $headtext ~ '</H' ~ $prefix.chars ~ '>';
    }
    return $headtext;
  }

  method store-icon-tag(:$icon){
    my Str $icon-path = '';
    $icon-path = '<img src="' ~ '/themes/img/icons/'
               ~ $icon
               ~ '.png"'
               ~ 'alt="' ~ $icon ~ '"/>';
    return $icon-path;
  };

  

  method store-href(:$anchor, :$text) {
    # l-anchor = local-variable anchor
    my $l-anchor = '';
    my $l-text = '';
    my $l-href = '';

    $l-text = $text.Str;
    $l-anchor = $anchor.Str;

    if $l-anchor eq '' {
      $l-href = $l-text;
    }
    else {
      $l-href = '<a ' ~ self.store-raw(text => $l-anchor) ~ '>' ~ $l-text ~ '</a>';
    }
    return $l-href;
  }

   


  
  method sap-note(:$note, :$desc?) {
    my Int $sap-note = 0;
    $sap-note = $note.Int;
    my Str $sDesc = '';
    $sDesc = $desc.Str;
    my Str $sap-link = '<a href="'
                    ~ 'https://launchpad.support.sap.com/#/notes/'
                    ~ $sap-note.Str
                    ~ '" target=sapnote_"'
                    ~ $sap-note.Str
                    ~ '">'
                    ~ $sap-note.Str
                    ~ '</a>';
    $sap-link ~= self.space ~ $desc if defined $desc;
    return $sap-link;
  }


  method space(Int $length?) {
    my Str $blank = '';
    if defined $length && $length > 0 {
      for 0..$length {
        $blank ~= '&nbsp;'; #'&nbsp;';
      }
    }
    else {
      $blank = '&nbsp;'; #'&nbsp;';
    }
    return $blank;
  }


  method font-style(Str :$color, Str :$size, Str :$text) {
    my $text-style = '';
    $text-style = '<span style="' 
               ~ 'color:' ~ $color ~ ';'
               ~ 'font-size:' ~ $size ~ '%">' 
               ~ $text 
               ~ '</span>'; 
    return self.store-raw(text => $text-style);
  }

  method free-to-normal(Str :$text) {
    my Str $free-text = '';
    $free-text = $text;
    $free-text = tc($free-text);
    $free-text ~~ s:g/__+/_/;
    $free-text ~~ s:g/' '+/_/;
    return $free-text;
  }

  #-- BEGIN-WIKI library/utilities

  method get-page-filename(Str :$filename = '') {
    my Str $page = '';
    my Str $wiki-page = '';
    $wiki-page = $filename;
    $page = $.Sys.get(key => 'DATA_DIR')
          ~ '/'
          ~ $.Sys.get(key => 'SID')
          ~ $.Sys.get(key => 'SID_NR')
          ~ '/'
          ~ 'wikidata'
          ~ '/'
          ~ 'page'
          ~ '/'
          ~ $wiki-page.substr(0,1).uc
          ~ '/'
          ~ $wiki-page
          ~ '.db';
    return $page;
  }

  method get-keep-filename(Str :$filename = '') {
    my Str $file = '';
    my Str $keep-page = '';
    $keep-page = $filename;
    $file = $.Sys.get(key => 'DATA_DIR')
          ~ '/'
          ~ $.Sys.get(key => 'SID')
          ~ $.Sys.get(key => 'SID_NR')
          ~ '/'
          ~ 'wikidata'
          ~ '/'
          ~ 'keep'
          ~ '/'
          ~ $keep-page.substr(0,1).uc
          ~ '/'
          ~ $keep-page
          ~ '.kp';
    return $file;
  }

  method wiki-read-file(Str :$filename = '') {
    my Str $absolutepath = '';
    my $file-handle = '';
    my $file-data = '';
    my Int $return-code = 0;
    $absolutepath = $filename;
    if $absolutepath ne '' {
      #-- Check if file exists
      if $absolutepath.IO.e { #- file exists
        $file-handle = $absolutepath.IO.open;
        $file-handle.encoding: "latin-1";
        my $data = slurp $file-handle;
        my %Page = ();
        %Page = $data.split(/$C_FS1/);

        for %Page.kv -> $k, $v {
          %.Page{$k} = $v.Str if $k ne '';
          #self.TRACE: 'PAGE.' ~ $k ~ ' = ' ~ $v.Str if $k ne '';

          if $k eq 'text_default' {
            my %Section = ();
            %Section = $v.split(/$C_FS2/);

            for %Section.kv -> $k, $v {
              %.Section{$k} = $v.Str if $k ne '';
              #self.TRACE: 'SECTION.' ~ $k ~ ' = ' ~ $v.Str if $k ne '';

              if $k eq 'secdata' {
                my %Text = ();
                %Text = $v.split(/$C_FS3/);

                for %Text.kv -> $k, $v {
                  %.Text{$k} = $v if $k ne '';
                  given $k {
                    when 'txtdata' {
                      my $text = $v;
                      #-- hide! $file-data = base64-decode($text).decode;
                      $file-data = $text;
                      #$file-data = $text;
                      %.Text{$k} = $file-data;
                    }
                    when 'summary' {
                      my $summary = $v;
                      #-- hide! $summary = base64-decode($summary).decode;

                      #self.TRACE: 'Summary';
                      #%.Text{$k} = $v.Str;
                      %.Text{$k} = $summary;
                    }
                  }
                } #for
              } #if data
            } #for section
          } #if text_default
          else {
            given $k {
              when m:g/'cache_diff'/ {
              } #cache_diff
              default {
              } #def
            } #given
          } #- endif not text_dafault
        } #- for %Page
        $return-code = 1;
      } # absolutepath.IO.e
    } # absolutepath ne ''
    return ($return-code, $file-data);
  }

  method request-page-lock(Str :$pageid) {
    return self.request-lock-dir(name => $pageid,
                                 maxtry => 10,
                                 wait => 3);
  }

  method request-lock-dir(Str :$name,
                          Int :$maxtry,
                          Int :$wait) {
    my Bool $lock-status = False;
    my Str $lock-dir = $.Sys.get(key => 'DATA_DIR')
                     ~ '/'
                     ~ $.Sys.get(key => 'SID')
                     ~ $.Sys.get(key => 'SID_NR')
                     ~ '/'
                     ~ 'wikidata'
                     ~ '/'
                     ~ '/lock/'
                     ~ $name;
    #- TODO: create a lock directory
    my Int $retries = 1;
    my Bool $created = False;
    while (!$created && $retries < $maxtry) {
      $lock-status = False;
      $lock-dir.IO.mkdir;
      $created = True if $lock-dir.IO ~~ :d;
      if $created {
        $lock-status = True;
        last;
      }
      $retries++;
      sleep($wait);
    }
    return $lock-status;
  }

  method release-page-lock(Str :$pageid) {
    return self.release-lock-dir(name => $pageid);
  }

  method release-lock-dir(Str :$name) {
    my Str $lock-dir = $.Sys.get(key => 'DATA_DIR')
                     ~ '/'
                     ~ $.Sys.get(key => 'SID')
                     ~ $.Sys.get(key => 'SID_NR')
                     ~ '/'
                     ~ 'wikidata'
                     ~ '/'
                     ~ '/lock/'
                     ~ $name;
    $lock-dir.IO.rmdir;
    if ($lock-dir.IO.e) {
      return False;
    }
    else {
      return True;
    }
  }

  method wiki-save-data(Str :$id) {
    # %.Text fields:
    #   text,    minor,   newauthor, summary
    #   txtdata, minorch, newauth,   summary

    # %.Section fields:
    #   name,    version, revision, tscreate, ts,      ip,    host,      id,      username, data
    #   secname, version, rvision,  creatdt,  changdt, ipaddrs, hostnam, usercod, usernam,  secdata
    #   kpchgdt (keep change date)

    # %.Page fields:
    #   version, revision, tscreate, ts
    #   version, rvision,  creatdt,  changdt

    my Str $oldtext-text = '';
    my Str $oldtext-minor = '';
    my Str $oldtext-newauthor = '';
    my Str $oldtext-summary = '';

    my Str $oldsection-name = '';
    my Str $oldsection-version = '';
    my Str $oldsection-revision = '';
    my Str $oldsection-tscreate = '';
    my Str $oldsection-ts = '';
    my Str $oldsection-ip = '';
    my Str $oldsection-host = '';
    my Str $oldsection-id = '';
    my Str $oldsection-username = '';
    my Str $oldsection-data = '';

    my Str $oldpage-version = '';
    my Str $oldpage-revision = '';
    my Str $oldpage-tscreate = '';
    my Str $oldpage-ts = '';
    #self.TRACE: 'PREPARING TO SAVE DATA';

    # %.Text fields:
    #   txtdata, minorch, newauth,   summary
    $oldtext-text      = %.Text<txtdata>.Str;
    $oldtext-minor     = %.Text<minorch>.Str;
    $oldtext-newauthor = %.Text<newauth>.Str;
    $oldtext-summary   = %.Text<summary>.Str;

    # %.Section fields:
    #   secname, version, rvision,  creatdt,  changdt, ipaddrs, hostnam, usercod, usernam,  secdata
    $oldsection-name     = %.Section<secname>.Str;
    $oldsection-version  = %.Section<version>.Str;
    $oldsection-revision = %.Section<rvision>.Str;
    $oldsection-tscreate = %.Section<creatdt>.Str;
    $oldsection-ts       = %.Section<changdt>.Str;
    $oldsection-ip       = %.Section<ipaddrs>.Str;
    $oldsection-host     = %.Section<hostnam>.Str;
    $oldsection-id       = %.Section<usercod>.Str;
    $oldsection-username = %.Section<usernam>.Str;
    $oldsection-data     = %.Section<secdata>.Str;


    # %.Page fields:
    #   version, rvision,  creatdt,  changdt
    $oldpage-version  = %.Page<version>.Str;
    $oldpage-revision = %.Page<rvision>.Str;
    $oldpage-tscreate = %.Page<creatdt>.Str;
    $oldpage-ts       = %.Page<changdt>.Str;

    #-- Get data from parameters
    my Str $text-data = '';
    my Str $text-summary = '';
    $text-data = $.Sys.getparam(key => 'text');
    $text-summary = $.Sys.getparam(key => 'summary');
    %.Text<txtdata> = $text-data;
    %.Text<summary> = $text-summary;

    #-- TODO: Save keep section

    my Bool $request-page-lock = False;
    $request-page-lock = self.request-page-lock(pageid => $id);
    if $request-page-lock {
      self.wiki-save-keep-section();
      self.wiki-save-default-text();
      self.wiki-save-page();
    }
    self.release-page-lock(pageid => $id);

  }

  method wiki-save-keep-section() {
    my Str $keep-file = self.get-keep-filename(filename => $.CurrentWikiPage);
    my Str $section-data = '';
    my Str $section-text = '';

    #self.TRACE: 'KEEP filename = ' ~ $keep-file;
    my Int $revision = 0;
    my Str $rvision = '';
    $rvision = %.Section<rvision>.Str if defined %.Section<rvision> && %.Section<rvision> ne '';
    if $rvision ne '' {
      $revision = $rvision.Int;
    }

    if $revision > 0 {
      my $dt = DateTime.now;
      %.Section{'kpchgdt'} = $dt.Str;  # 'keep' change date

      for %.Section.sort -> (:$key, :$value) {
        $section-text = $value.Str;
        #self.TRACE: 'section.key: ' ~ $k;
        given $key {
          when 'secdata' {
            $section-text = $section-text.Str;
            $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
          }
          default {
            if $key ne '' {
              $section-text = $value.Str;
              $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
            }
          }
        }
      }
      $section-data ~= $C_FS2;



      $section-data = $C_FS1 ~ $section-data;
      my Str $page-directory = '';
      $page-directory = $.Sys.get(key => 'DATA_DIR')
                      ~ '/'
                      ~ $.Sys.get(key => 'SID')
                      ~ $.Sys.get(key => 'SID_NR')
                      ~ '/'
                      ~ 'wikidata'
                      ~ '/'
                      ~ 'keep';

      self.wiki-create-page-directory(dir => $page-directory,
                                      page => $.CurrentWikiPage,
                                      root => True);

      #self.write-string-to-file-limited(file => $keep-file,
      #                                  data => $section-data,
      #                                  limit => 0);

    }
  }

  method wiki-save-default-text {
    return self.wiki-save-text(name => 'default');
  }

  method wiki-save-text(Str :$name) {
    my Str $text-data = '';
    my Str $text = '';
    for %.Text.sort -> (:$key, :$value) {
      $text = $value.Str;
      given $key {
        when 'txtdata' {
          #-- $text = $.Sys.getparam(key => 'text');
          #-- hide! $text = base64-encode($text, :str);
          $text = $text; #base64-encode($text, :str);
        }
        when 'summary' {
          #-- hide! $text = base64-encode($text, :str);
          $text = $text; #base64-encode($text, :str);
        }
        default {
          if $key ne '' {
            $text = $value.Str;
          }
        }
      }
      $text-data ~= $key ~ $C_FS3 ~ $text ~ $C_FS3;
    }
    $text-data ~= $C_FS3;
    #self.TRACE: 'TEXT-DATA: ' ~ $text-data;
    return self.wiki-save-section(name => "text_$name",
                                  data => $text-data);
  }

  method wiki-save-section(Str :$name, :$data) {
    my Str $section-data = '';
    my Int $revision = 0;
    my Str $section-text = '';
    #self.TRACE: 'TEXT-DATA: ' ~ $data;
    #self.TRACE: 'SECTION: ' ~ %.Section.Str;
    for %.Section.sort -> (:$key, :$value) {
      $section-text = $value.Str;
      #self.TRACE: 'section.key: ' ~ $k;
      given $key {
        when 'rvision' {
          $revision = $value.Int;
          $revision++;
          $section-text = $revision.Str;
          $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
        }
        when 'changdt' {
          my $dt = DateTime.now;
          $section-text = $dt.Str;
          $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
        }
        when 'secdata' {
          $section-text = $data.Str;
          $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
        }
        when 'usercod' {
          $section-text = $.UserID;
          $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
        }
        default {
          if $key ne '' {
            $section-text = $value.Str;
            $section-data ~= $key ~ $C_FS2 ~ $section-text ~ $C_FS2;
          }
        }
      }
    }
    $section-data ~= $C_FS2;
    #self.TRACE: 'SECTION-DATA: ' ~ $section-data;
    %.Page{"$name"} = $section-data;
    return True;
  }

  method wiki-save-page() {
    my Str $wiki-page = '';
    my Str $file-name = '';
    $wiki-page = $.CurrentWikiPage;
    $file-name = self.get-page-filename(filename => $wiki-page);
    my Str $page-data = '';
    my Int $revision = 0;
    my Str $page-text = '';
    for %.Page.sort -> (:$key, :$value) {
      $page-text = $value.Str;
      given $key {
        when 'rvision' {
          $revision = $value.Int;
          $revision++;
          $page-text = $revision.Str;
        }
        when 'changdt' {
          my $dt = DateTime.now;
          $page-text = $dt.Str;
        }
        when 'text_default' {
          $page-text = $value.Str;
        }
        default {
          if $key ne '' {
            $page-text = $value.Str;
          }
        }
      }
      $page-data ~= $key ~ $C_FS1 ~ $page-text ~ $C_FS1;
    }
    $page-data ~= $C_FS1;
    #self.TRACE: 'PAGE data to save: ' ~ $page-data;
    my Str $page-directory = '';
    $page-directory = $.Sys.get(key => 'DATA_DIR')
                     ~ '/'
                    ~ $.Sys.get(key => 'SID')
                    ~ $.Sys.get(key => 'SID_NR')
                    ~ '/'
                    ~ 'wikidata'
                    ~ '/'
                    ~ 'page';
    #-- MAIN PAGE
    #self.TRACE: 'MAIN: PAGEDIR :' ~ $page-directory;
    self.wiki-create-page-directory(dir => $page-directory,
                                    page => $.CurrentWikiPage,
                                    root => True);
    #self.TRACE: 'CURRENT: PAGEDIR :' ~ $page-directory;
    self.wiki-create-page-directory(dir => $page-directory,
                                    page => $.CurrentWikiPage,
                                    root => False);
    #self.TRACE: 'FILENAME :' ~ $file-name;
    my IO::Path $IOPath = $file-name.IO.resolve;
    my Str $file-path = $IOPath.Str;
    #self.TRACE: 'Expected file path = ' ~ $file-path;
    self.write-string-to-file(file => $file-path,
                               data => $page-data);
    return True;
  }

  method wiki-create-page-directory(Str :$dir,
                                   Str :$page,
                                   Bool :$root?) {
    my Str $page-dir = '';
    $page-dir = $dir
              ~ '/'
              ~ $page.substr(0,1).uc;
    $page-dir ~= '/' ~ $page if !$root;
    self.create-directory(path => $page-dir);
  }

  method create-directory(Str :$path) {
    my @FilePath = $path.split('/');
    #self.TRACE: 'Number of path = ' ~ @FilePath.elems;
    my Str $dir = '.';
    my Int $index = 0;
    for @FilePath -> $path {
      $index++;
      next if $path ~~ /\./;
      next if $path ~~ /^.*\\(.*)$/;
      $dir ~= '/' ~ $path;
      #self.TRACE: 'Create directory: ' ~ $dir;
      if $index < @FilePath.elems {
        unless $dir.IO ~~ :d {
          $dir.IO.mkdir;
        }
      }
    }
  }
  method write-string-to-file(Str :$file, Str :$data) {
    #-- TODO: make sure path exists before creating file
    my $fh = open $file, :w;
    $fh.encoding: 'latin-1';
    $fh.say: $data;
    $fh.close;
    return True;
  }

  method write-string-to-file-limited(Str :$file,
                                      Str :$data,
                                      Int :$limit) {
    my Str $trim-data = $data;
    $trim-data ~~ s:g/(\*)$$/\n/;
    if $file.IO.e {
      my Int $file-size = $file.IO.s;
      my Int $current-size = $file-size + $limit;
      if $limit < 1 || $current-size <= $limit {
        self.append-string-to-file(file => $file,
                                   data => $trim-data);
      }
    }
    else {
      self.append-string-to-file(file => $file,
                                 data => $trim-data);
    }
    return True;
  }

  method append-string-to-file(Str :$file,
                               Str :$data) {
    spurt $file, $data, :append;
    return True;
  }



  method wiki-open-page(Str :$id) {
    my Int $return-code = 0;
    my Str $wiki-page = '';
    my Str $wiki-file = '';
    my Int $status = 0;
    my Str $wiki-text = '';
    my Str $page-data = '';

    # %.Text fields:
    #   text,    minor,   newauthor, summary
    #   txtdata, minorch, newauth,  summary

    # %.Section fields:
    #   name,    version, revision, tscreate, ts,      ip,    host,      id,      username, data
    #   secname, version, rvision,  creatdt,  changdt, ipaddrs, hostnam, usercod, usernam,  secdata,
    #   kpchgdt

    # %.Page fields:
    #   version, revision, tscreate, ts
    #   version, rvision,  creatdt,  changdt


    #-- Initialize data storage
    %.Page = $.Sys.Dbu.structure(
                         fields => ['version', 'rvision', 'createdt', 'changedt'] );
    %.Section = $.Sys.Dbu.structure(
                            fields => ['secname', 'version', 'rvision', 'creatdt', 'changdt',
                                      'ipaddrs', 'hostnam', 'usercod', 'username', 'secdata',
                                      'kpchgdt'] );
    %.Text = $.Sys.Dbu.structure(
                         fields => ['txtdata', 'minorch', 'newauth', 'summary'] );

    $wiki-page = $id;
    $wiki-file = self.get-page-filename(filename => $wiki-page);
    self.TRACE: 'WIKI-FILE = ' ~ $wiki-file;
    ($status, $wiki-text) = self.wiki-read-file(filename => $wiki-file);
    if $status {
      #-- file exists
      # %.Page, %.Section, %.Text is populated by wiki-read-file
      $return-code = $status;
    }
    else {
      #-- file not exists
      self.wiki-open-newpage(id => $wiki-page);
      self.wiki-open-default-text();
      for %.Page.kv -> $k, $v {
        $page-data ~= $k ~ $C_FS1 ~ $v.Str ~ $C_FS1;
      }
    }



    return $return-code;
  }

  method wiki-open-newpage(Str :$id) {
    my $dt = DateTime.now;

    # %.Page fields:
    #   version, revision, tscreate, ts
    #   version, rvision,  creatdt,  changdt

    %.Page = $.Sys.Dbu.structure(
                         fields => ['version', 'rvision', 'creatdt', 'changdt'] );

    %.Page<version> = 3;
    %.Page<rvision> = 0;
    %.Page<creatdt> = $dt.Str;
    %.Page<changdt> = $dt.Str;

    return True;
  }

  method wiki-open-default-text() {
    self.wiki-open-text(name => 'default');
  }

  method wiki-open-text(Str :$name) {
    my Str $text-name = '';
    $text-name = "text_$name";
    if defined %.Page{"$text-name"} {
      #-- open the page section corresponding to text-name
      my Str $section-data = '';
      $section-data = %.Page{"$text-name"}.Str;
      self.TRACE: 'Creating new section: ' ~ $text-name ~ ' = ' ~ $section-data;
      self.wiki-open-new-section(name => $text-name,
                                 data => $section-data);
    }
    else {
      self.wiki-open-new-text(name => $name);
    }
  }

  method wiki-open-new-text(Str :$name) {
    my Str $text-name = '';
    my Str $text-data = '';
    $text-name = "text_$name";

    # %.Text fields:
    #   text,    minor,   newauthor, summary
    #   txtdata, minorch, newauth,  summary

    %.Text = $.Sys.Dbu.structure(
                         fields => ['txtdata', 'minorch', 'newauth', 'summary'] );

    %.Text<txtdata> = $C_NEW_TEXT if $C_NEW_TEXT ne '';
    %.Text<minorch> = 0; #minor edit
    %.Text<newauth> = 1; #default new author
    %.Text<summary> = '';

    for %.Text.kv -> $k, $v {
      $text-data ~= $k ~ $C_FS3 ~ $v.Str ~ $C_FS3;
    }
    #self.TRACE: 'NEW-TEXT: ' ~ $text-data;
    self.wiki-open-new-section(name => $text-name,
                               data => $text-data);
  }

  method wiki-open-new-section(Str :$name, Str :$data) {
    my $dt = DateTime.now;
    my Str $remote-address = '';
    my Str $section-data = '';
    $remote-address = 'how-to-get-REMOTE_ADDR'; #%*ENV{REMOTE_ADDR};

    # %.Section fields:
    #   name,    version, revision, tscreate, ts,      ip,    host,      id,      username, data
    #   secname, version, rvision,  creatdt,  changdt, ipaddrs, hostnam, usercod, usernam,  secdata


    %.Section = $.Sys.Dbu.structure(
                            fields => ['secname', 'version', 'rvision', 'creatdt', 'changdt',
                                       'ipaddrs', 'hostnam', 'usercod', 'usernam', 'secdata',
                                       'kpchgdt'] );
    %.Section<secname> = $name;
    %.Section<version> = 1;
    %.Section<rvision> = 0;
    %.Section<creatdt> = $dt.Str;
    %.Section<changdt> = $dt.Str;
    %.Section<ipaddrs> = $remote-address.Str;
    %.Section<hostnam> = '';
    %.Section<usercod> = $.UserID;
    %.Section<usernam> = ''; #-- FIXME - get this username from database
    %.Section<secdata> = $data;

    for %.Section.kv -> $k, $v {
      $section-data ~= $k ~ $C_FS2 ~ $v.Str ~ $C_FS2;
    }
    #self.TRACE: 'NEW-SECTION: ' ~ $section-data;
    %.Page{"$name"} = $section-data;
  }

  method T(Str $text) {
    my Str $translated-text = '';
    $translated-text = $text;
    if defined %.TranslatedText{"$text"} && %.TranslatedText{"$text"} ne '' {
      $translated-text = %.TranslatedText{"$text"};
    }
    return $translated-text;
  }

  method Ts(Str $text, Str :$msg) {
    my Str $text-message = '';
    $text-message = $text;
    $text-message = self.T($text-message);
    $text-message ~~ s:g/\%s/$msg/;
    return $text-message;
  }

  method Tss(@msg) {
    my Str $text-message = '';
    my Int $index = 0;
    $text-message = @msg[0];
    $text-message = self.T($text-message);
    for @msg -> $txt {
      if $index > 0 {
        $text-message ~~ s:g/\%$index/$txt/;
      }
      $index++;
    }
    return $text-message;
  }

  method remove-field-separator(Str :$text) {
    my Str $wiki-text = '';
    $wiki-text = $text;
    $wiki-text ~~ s:g/($C_FS)+(\d)/$1/;
    return $wiki-text;
  }

  method debug-mode() {
    my Bool $debug-mode = False;
    $debug-mode = True if $.Sys.getenv(key => 'DEBUG_MODE') eq 'TRUE';
    return $debug-mode;
  }

  method is-user-online() {
    my Bool $user-is-online = False;
    $user-is-online = True if $.UserID ne '';
    $user-is-online = True if self.debug-mode(); #-- always True if debugging
    return $user-is-online;
  }


#-- end of Class Sys::W::WikiPage

};

