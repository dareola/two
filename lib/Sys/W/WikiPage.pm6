
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
  em s strike strong tt var div center blockquote ol ul dl table tr td caption
  br p hr li dt dd th>;

    # Single tags (that do not require a closing /tag)
    has @.HtmlSingle  = <br p hr li dt dd th>;

    #-- begin: testing-declaration
    has Bool $.NonEnglish = False;
    has Bool $.NewFS = False;
    has Bool $.SimpleLinks = True;
    has Bool $.UseSubPage = True;
    has Bool $.NamedAnchors = True;
    has $.LinkPattern is rw = '';
    has $.HalfLinkPattern is rw = '';
    has $.AnchoredLinkPattern is rw = '';
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

      $.Sys.FORM-STRING(text => '<table border="0"><tr><td valign="top">');

      $.Sys.FORM-STRING(text => 'REGEX');
      $.Sys.FORM-SPACE();
      $.Sys.FORM-TEXT(key => 'summary', value => $summary,
                                    size => $edit-cols.Str, length => '80');

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
      $text-string ~~ s:g/<$regex>/{
        $regex-result ~= self.eval-regex($/) ~ '&nbsp;' ~ $C_FS ~ '&nbsp;&nbsp;';
      }/;

      $.Sys.FORM-STRING(text => '</td><td valign="top">REGEX PREVIEW<br/>' ~ $regex-result ~ '</td></tr></table>');
      
      $.Sys.FORM-STRING(text => '<hr/>WIKI Preview<br/>' ~ $preview);

      $cancel = '&nbsp;|&nbsp;<a href="/wiki/display?p='
            ~ $.CurrentWikiPage ~ '">cancel</a>';
      $.Sys.FT(tag => 'MENU_BAR', text => $cancel); # if $.UserID ne '';


  return True;
}

  method eval-regex(Match $result) {
    return $result;
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

  method wiki-init-link-patterns() {
    my Str $upper-letter = '';
    my Str $lower-letter = '';
    my Str $any-letter = '';
    my Str $link-pattern-A = '';
    my Str $link-pattern-B = '';
    my Str $link-pattern-C = '';
    my Str $quote-delim = '';

    $upper-letter = '<[A..Z';
    $lower-letter = '<[a..z';
    $any-letter = '<[A..Za..z';

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
    if $.SimpleLinks {
      $any-letter ~= '_0..9';
    }


    $upper-letter ~= ']>';
    $lower-letter ~= ']>';
    $any-letter ~= ']>';

    #self.TRACE: 'UpperLetter = ' ~ $upper-letter;
    #self.TRACE: 'LowerLetter = ' ~ $lower-letter;
    #self.TRACE: 'AnyLetter = ' ~ $any-letter;

    $link-pattern-A = $upper-letter
                    ~ '+'
                    ~ $lower-letter
                    ~ '+'
                    ~ $upper-letter
                    ~ $any-letter
                    ~ '*';

    #self.TRACE: 'Link pattern A = ' ~ $link-pattern-A;


    $link-pattern-B = $upper-letter
                    ~ '+'
                    ~ $lower-letter
                    ~ '+'
                    ~ $any-letter
                    ~ '*';

    #self.TRACE: 'Link pattern B = ' ~ $link-pattern-B;



    $link-pattern-C = $upper-letter
                    ~ '+'
                    ~ $any-letter
                    ~ '*';

    #self.TRACE: 'Link pattern C = ' ~ $link-pattern-C;

    if $.UseSubPage {
     
      #ref: $.LinkPattern = "(((?:(?:$link-pattern-A)?\\/)+$link-pattern-B)|$link-pattern-A)";
      # 1. ( ( non-greedy link pattern A
      # 2.   back slash
      # 3.   slash
      # 4.  )
      # 5.  greedy link pattern B
      # 6. )
      # 7. OR
      # 8. link pattern A

      $.LinkPattern = "(([[$link-pattern-A?\\/]]+$link-pattern-B)|($link-pattern-A])";  
      #ref: $.HalfLinkPattern = "(((?:(?:$link-pattern-B)?\\/)+$link-pattern-B)|$link-pattern-A)";
      $.HalfLinkPattern = "(([[$link-pattern-B?\\/]]+$link-pattern-B)|$link-pattern-A)";
    }
    else {
      $.LinkPattern = "($.link-pattern-A)";
      $.HalfLinkPattern = "($.link-pattern-C)";
    }

    #self.TRACE: 'Link pattern = ' ~ $.LinkPattern;
    #self.TRACE: 'Half link pattern = ' ~ $.HalfLinkPattern;
    
    $quote-delim = "'\"'" ~ '<-["]>*' ~ "'\"'"; 

    #self.TRACE: 'Quote delimiter = ' ~ $quote-delim;

    $.AnchoredLinkPattern = $.LinkPattern ~ '#(\\w+)' ~ $quote-delim;
    #self.TRACE: 'Anchored link pattern: ' ~ $.AnchoredLinkPattern;
    $.LinkPattern ~= $quote-delim;
    #self.TRACE: 'Link pattern: ' ~ $.LinkPattern;
    $.HalfLinkPattern ~= $quote-delim;
    #self.TRACE: 'Half link pattern: ' ~ $.HalfLinkPattern;

  }

  method wiki-to-html(Str :$text) {
    my Str $wiki-text = '';

    self.wiki-init-link-patterns();

    #self.TRACE: 'TEXT = ' ~ '<hr>' ~ $text;

    my %SaveUrl = ();

    #-- begin: remove field separators
    $wiki-text = self.wiki-remove-field-separator(text => $text);
    #-- end: remove field separators

    #-- begin: remove \r\n
    $wiki-text = $text ~ "\r\n";
    #-- end: remove \r\n


    #-- begin: quote html
    $wiki-text = self.wiki-quote-html(text => $wiki-text);
    #-- end: quote html


    #-- begin: replace .\ with BR
    $wiki-text ~~ s:g/\.\\ *\r?\n/\<br\/\>\&nbsp; /;
    #-- end: replace .\ with BR


    #-- begin: <back> tag
    $wiki-text ~~ s:g/\&lt\;'back'\&gt\;/{
    self.store-raw(text => 'back to ' ~ $.CurrentWikiPage);
    }/;
    #Ref: $pageText =~
    #Ref: s/&lt;back&gt;/$self->StoreRaw("<b>"
    #Ref: . $self->Ts('Backlinks for: %s', $MainPage)
    #Ref: . "<\/b><br \/>\n" . $self->GetPageList($self->SearchTitleAndBody($MainPage)))/ige;
    #-- end: <back> tag


    #-- begin: nowiki tag
    #ref: $pageText =~ s/\&lt;nowiki\&gt;((.|\n)*?)\&lt;\/nowiki\&gt;/$self->StoreRaw($1)/ige;

    #pattern = <nowiki>text<nowiki>
    $wiki-text ~~ s:g/\&lt\;nowiki\&gt\;(.*?)\&lt\;\/nowiki\&gt\;/{
    self.store-raw(text => $0.Str);
    }/;
    #-- end: nowiki tag


    #-- begin: code
    $wiki-text ~~ s:g/\&lt\;code\&gt\;(.*?)\&lt\;\/code\&gt\;/{
    self.store-raw-tag(text => $0.Str, tag => 'code');
    }/;

    #Hide:$wiki-text ~~ s:g/\&lt\;'code'\&gt\;(.*)\&lt\;\/'code'\&gt\;/{
    #Hide:  self.wiki-source-code(text => $0);
    #Hide:}/;
    #-- end: code

    #-- begin: pre
    #Hide:#-- save PRE tags to buffer (for further parsing later in code)
    $wiki-text ~~ s:g/\&lt\;'pre'\&gt\;(.*?)\&lt\;\/'pre'\&gt\;/{
    self.store-raw-tag(text => $0.Str, tag => 'pre');
    #Hide:  self.wiki-pre-formatted_text(text => $0);
    }/;
    #-- end: pre

    #-- begin: paragraph
    #-- split text by paragraph marked by \n
    #$wiki-text ~~ s:g/[^^|\n](.*?)\n$$/{
    #self.TRACE: 'PARA :' ~ $0;
    #self.wiki-parse-paragraph(text => $0);
    #}/;
    #-- end: paragraph

    #-----
    #-- begin: paragraph
    #-- split text by paragraph marked by \n
    $wiki-text ~= "\n";
    $wiki-text ~~ s:g/[^^|\n](.*?)\n|$$/{
    #self.TRACE: 'PARA :' ~ $0;
    #self.TRACE: '<br/>';
    self.wiki-parse-paragraph(text => $0);
    }/;
    #-- end: paragraph

    #-----


    #Hide:#-- HIDE tags
    #Hide:$wiki-text ~~ s:g/\&lt\;hide\&gt\;(.*?)\&lt\;\/hide\&gt\;//;
    #Hide:
    #Hide:#-- join lines terminated with backslash
    #Hide:$wiki-text ~~ s:g/\\' '*\r?\n//; #' comment needed to editor color
    #Hide:
    #Hide:
    #Hide:#-- save TABLE data to buffer
    #Hide:$wiki-text ~~ s:g/^^(\|\|.*?\|\|)\n\n/{
    #Hide:  self.wiki-table(text => $0.Str);
    #Hide:}/;
    #Hide:
    #Hide:  #-- color pattern = {{color,digit% some text}}
    #Hide:$wiki-text ~~ s:g/\{\{(.*?)\,(\d+)\%\s*?(.*?)\}\}/{
    #Hide:  self.wiki-colored-text(color => $0, size => $1, text => $2);
    #Hide:}/;
    #Hide:
    #Hide:#-- translate  &lt;br&gt; to \n
    #Hide:$wiki-text ~~ s:g/\&lt\;br\&gt\;/\n/;
    #Hide:
    #Hide:#-- pattern: == # Heading ==
    #Hide:$wiki-text = self.wiki-numbered-heading(text => $wiki-text);
    #Hide:
    #Hide:#-- clean-up extra tags
    #Hide:$wiki-text = self.wiki-remove-unwanted-tags(text => $wiki-text);
    #Hide:
    #Hide:#-- split text by paragraph marked by \n
    #Hide:$wiki-text ~~ s:g/[^^|\n](.*?)\n$$/{
    #Hide:  self.wiki-paragraph(text => $0);
    #Hide:}/;
    #Hide:
    #Hide:#-- split text by paragraph "</p>" marker
    #Hide:
    #Hide:
    #Hide:
    #Hide:#-- pattern = <pagetitle>SOMETITLE</pagetitle>
    #Hide:$wiki-text ~~ s:g/\&lt\;pagetitle\&gt\;(.*)\&lt\;\/pagetitle\&gt\;/{
    #Hide:  self.wiki-set-page-title(title => $0.Str);
    #Hide:}/;
    #Hide:
    #Hide:
    #Hide:#-- Bring back PREformatted texts
    #Hide:#-- The preformatted text buffer is %.Preformatted
    #Hide:for 1 .. $.PreformattedIndex -> $i {
    #Hide:  $wiki-text ~~ s:g/\<pre\>PRE_$i\<\/pre\>/{
    #Hide:    '<pre>' ~ %.Preformatted{$i.Str} ~ '</pre>';
    #Hide:  }/;
    #Hide:}
    #Hide:%.Preformatted = (); #-- reclaim memory
    #Hide:$.PreformattedIndex = 0;
    #Hide:
    #Hide:#-- clean-up extra tags
    #Hide:$wiki-text = self.wiki-remove-unwanted-tags(text => $wiki-text);
    #Hide:

    $wiki-text = self.restore-saved-text(text => $wiki-text);
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


  method wiki-quote-html(Str :$text) {
    my Str $qtext = '';
    $qtext = $text;
    $qtext ~~ s:g/<[&]>/\&amp\;/;
    $qtext ~~ s:g/<[\<]>/\&lt\;/;
    $qtext ~~ s:g/<[\>]>/\&gt\;/;
    $qtext ~~ s:g/'&amp;'(<[#a..zA..Z0..9]>+)/\&$0;/;
    return $qtext;
  }

  method wiki-pre-formatted_text(:$text) {
    my Str $pre_text = $text.Str;
    $.PreformattedIndex++;
    %.Preformatted{$.PreformattedIndex} = $text.Str;
    $pre_text = '<pre>' ~ 'PRE_' ~ $.PreformattedIndex.Str ~ '</pre>';
    return $pre_text;
  }

  method wiki-table(Str :$text = '') {
    my Str $table = '';
    my Str $wiki-text = '';
    $wiki-text = $text;
    for $wiki-text.split(/\n/) -> $line {
      my Str $current-line = $line.Str;
      $current-line ~~ s:g/^^((\|\|)+)(.*)\|\|\s*$/{
        my $line-text = $1;
        $line-text ~~ s:g/\|\|/{
          my $td = '&nbsp;</td><td class="wikitablecell" align="top">&nbsp;&nbsp;';
          $td;
        }/;
        $table ~= '<tr><td class="wikitablecell" align="top">&nbsp;&nbsp;' ~ $line-text ~ '&nbsp;</td></tr>';
      }/;
    }
    $table = '<table border="0">' ~ $table ~ '</table><br/>';
    return $table;
  }

  method wiki-colored-text(:$color, :$size, :$text) {
    my Str $wiki-text = '';
    $wiki-text ~= '<span style="font-size:' ~ $size ~ '%; ' ~ 'color:' ~ $color
                                         ~ ";" ~ '">' ~ $text ~ '</span>';
    return $wiki-text;
  }

  method wiki-numbered-heading(:$text = '') {
    my $wiki_text = $text;
    my @lines = $wiki_text.split(/\n/);
    my Int $depth = 0;
    my Int $last-depth = 0;
    my Int @HeaderIndex = (1,1,1,1,1,1,1,1,1);
    my Bool $first-time = False;
    my $page = '';
    for @lines -> $line {
      my $line_item = $line;
      if $line_item ~~ m:g/^^\=+\s+?\#\s+/ {
        my $head = '';
        $first-time = True;
        $line_item ~~ s:g/^^(\=+)\s+?\#\s+(.*?)\s+(\=+)\s*?$$/{
          $head = $0;
          $depth = $0.chars;
          #$0 ~ ' ' ~ $1 ~ ' ' ~ $2;
          $1;
        }/;
        if $depth == $last-depth {
          for 1..$depth -> $index {
            @HeaderIndex[$index]++ if $index == $depth;
          }
          my Int $upper-bound = $depth+1;
          for $upper-bound..@HeaderIndex.elems -> $index {
            @HeaderIndex[$index] = 0;
          }
          my Str $number = '';
          for 2..$depth -> $no {
            $number ~= @HeaderIndex[$no].Str ~ '.';
          }
          $line_item = '<H' ~ $depth.Str ~ '>' ~ $number ~ ' ' ~ $line_item
                    ~ '</H' ~ $depth.Str ~ '>';
        }
        elsif $depth > $last-depth {
          for 1..$depth -> $index {
            @HeaderIndex[$index]++ if $index == $depth;
            @HeaderIndex[$index] = 1 if $index == $depth && $first-time;
          }
          my Int $upper-bound = $depth+1;
          for $upper-bound..@HeaderIndex.elems -> $index {
            @HeaderIndex[$index] = 0;
          }
          my Str $number = '';
          for 2..$depth -> $no {
            $number ~= @HeaderIndex[$no].Str ~ '.';
          }
          $line_item = '<H' ~ $depth.Str ~ '>' ~ $number ~ ' ' ~ $line_item
                    ~ '</H' ~ $depth.Str ~ '>';
        }
        elsif $depth < $last-depth {
          for 1..$depth -> $index {
            @HeaderIndex[$index]++ if $index == $depth;
          }
          my Int $upper-bound = $depth+1;
          for $upper-bound..@HeaderIndex.elems -> $index {
            @HeaderIndex[$index] = 0;
          }
          my Str $number = '';
          for 2..$depth -> $no {
            $number ~= @HeaderIndex[$no].Str ~ '.';
          }
          $line_item = '<H' ~ $depth.Str ~ '>' ~ $number ~ ' ' ~ $line_item
                    ~ '</H' ~ $depth.Str ~ '>';
        }
        $first-time = False;
        $last-depth = $depth;
        $page ~= $line_item ~ "\n";
      }
      else {
        $line_item ~~ s:g/(\#+)/{
          #-- replace '##' with icon :i
          my Str $icon = '';
          my Int $icon-type = 0;
          $icon-type = $0.chars;
          if $icon-type > 0 {
            given $icon-type {
              when 1 {
               $icon = '#'; #<img src="/themes/img/common/yellow_square.gif"/>';
               #-- TODO: Determine icon for ## symbol
              }
              when 2 {
               $icon = '<img src="/themes/img/common/yellow_square.gif"/>';
               #-- TODO: Determine icon for ## symbol
              }
              default {
               #$icon = '<img src="/themes/img/common/yellow_square.gif"/>';
               #-- TODO: Determine icon for ## symbol
              }
            }
          }
          $icon;
        }/;
        $page ~= $line_item ~ "\n";
      }
    }
    $wiki_text = $page;
    return $wiki_text;
  }

  method wiki-remove-unwanted-tags(:$text) {
    my $para = $text;
    #-- clean up
    #-- whitespace before BR
    $para ~~ s:g/\s+(\<br\/\>)/{$0}/;

    #-- whitespace before </td>
    $para ~~ s:g/\s+(\<\/td\>)/{$0}/;

    #<br/><ul> - remove br
    $para ~~ s:g/\<br\/\>(\<ul\>)/{$0}/;
    $para ~~ s:g/\<br\/\>\s+(\<ul\>)/{$0}/;

    #<br/></ul> - remove br
    $para ~~ s:g/\<br\/\>(\<\/ul\>)/{$0}/;
    $para ~~ s:g/\<br\/\>\s+(\<\/ul\>)/{$0}/;

    #<br/><ol> - remove br
    $para ~~ s:g/\<br\/\>(\<ol\>)/{$0}/;
    $para ~~ s:g/\<br\/\>\s+(\<ol\>)/{$0}/;

    #<br/>\n</td> - remove br
    $para ~~ s:g/\<br\/\>\s+(\<\/td\>)/{$0}/;

    #<br/>\n<H\d+> - remove br
    $para ~~ s:g/\<br\/\>\s+(\<H\d+\>)/{$0}/;
    $para ~~ s:g/\<br\/\>(\<H\d+\>)/{$0}/;

    #</H\d+><br/> - remove br
    $para ~~ s:g/(\<\/H\d+\>)\n*?\<br\/\>/{$0}/;

    #</form><br/> - remove br
    $para ~~ s:g/(\<\/form\>)\<br\/\>/{$0}/;

    #</ul><br/> - remove br
    $para ~~ s:g/(\<\/ul\>)\<br\/\>/{$0}/;

    #</ol><br/> - remove br
    $para ~~ s:g/(\<\/ol\>)\<br\/\>/{$0}/;
    return $para;
  }

  method wiki-parse-paragraph(:$text) {
    my $para = '';
    if $text ne '' {
      #self.TRACE: '>' ~ $text ~ '<hr/>';
      $para = self.wiki-common-markup(text => $text);
    }
    return '<p>' ~ $para ~ '</p>';
  }

  method wiki-paragraph(:$text) {
    return '' if $text eq '' || $text eq "\n";
    my $para = $text;

    #pattern = [http://some.url some remarks]
    $para ~~ s:g/\[(['http'|'https'])\:\/\/(.*?)\s+(.*?)[\]]/{
            self.wiki-bracket-url(protocol => $0, uri => $1, desc => $2);
            }/;

    #pattern = <wspace>http://some.url.somewhere
    $para ~~ s:g/(\s+)(['http'|'https'])\:\/\/(.*?)[\"|$$|\s+?]/{  #"
            self.wiki-url(prefix => $0, protocol => $1, uri => $2);
            }/;

    #pattern = [http:/somewhere.com this is a sample url]
    $para ~~ s:g/\[(['http'|'https'])\:\/(.*?)\s+(.*?)[\]]/{
            self.wiki-local-url(protocol => $0, uri => $1, desc => $2);
            }/;

    #pattern = [[WikiPattern | Description]]
    $para ~~ s:g/\[\[(\/?)(<upper>+<alnum>+<alpha>*)\s*?(\|+)\s*?(.*?)\s*?\]\]/{
      self.wiki-bracket-link(subpage => $0,
                             page => $1,
                             desc => self.wiki-expand-word(text => $3.Str));
    }/;

    #pattern = [[/Sometext/MorePages/AnotherPage | Sometext]]
    $para ~~ s:g/\[\[(\/?)(.*?)\s*?(\|+)\s*?(.*?)\s*?\]\]/{
      self.wiki-bracket-multilink(subpage => $0,
                                  page => $1,
                                  pipe => $2,
                                  desc => $3);
    }/;

    #pattern = [[UpperLowerAndAnything]]
     $para ~~ s:g/\[\[(<upper>+<alnum>+<alnum>*)\]\]/{
       self.wiki-bracket-link(subpage => '',
                              page => $0,
                              desc => self.wiki-expand-word(text => $0.Str));
     }/;

    #pattern = [[/WikiPattern]]
    $para ~~ s:g/\[\[(\/)(.*?)\]\]/{
      self.wiki-bracket-link(subpage => $0,
                             page => $1,
                             desc => self.wiki-expand-word(text => $1.Str));
    }/;

    $para ~= '<br/>';

    #-- translate paragraph
    #   parse line by line
    $para = self.wiki-common-markup(text => $para);

    $para ~~ s:g/(^^.*?$$)/{
      self.wiki-line(text => $0); # ~ "\n";
    }/;


    #test -- remove \n -- to reduce html size
    if $.Sys.get(key => 'DEBUG_MODE') ne 'true' {
      $para ~~ s:g/\n//;
    }

     $para = self.wiki-list-item(text => $para,
                                listtype => 'ul',
                                symbol => '*'); #-- unordered list
     $para = self.wiki-list-item(text => $para,
                                listtype => 'ol',
                                symbol => '#'); #-- ordered list

    $para ~= "\n";

    return $para;
  }

  method wiki-bracket-url(:$protocol, :$uri, :$desc) {
    my $url = '<a href="' ~ $protocol ~ '://'
                          ~ $uri ~ '" target="_new">'
                          ~ $desc ~ '</a>';
    return $url;
  }

  method wiki-url(:$prefix, :$protocol, :$uri) {
    my $url = $prefix
            ~ '<a href="'
            ~ $protocol
            ~ '://'
            ~ $uri
            ~ '" target="_new">'
            ~ $protocol
            ~ '://'
            ~ $uri
            ~ '</a>'
            ~ "\n";
    return $url;
  }

  method wiki-local-url(:$protocol, :$uri, :$desc) {
    my $site_url = $.Sys.get(key => 'SITE_URL');
    my $url = '<a href="'
            ~ $protocol ~ '://'
            ~ $site_url ~ '/' ~ $uri
            ~ '" target="_new">'
            ~ $desc ~ '</a>';
    return $url;
  }

  method wiki-expand-word(Str :$text) {
    my Str $wiki-word = $text;
    $wiki-word ~~ s:g/\// \//; #put space before /
    $wiki-word ~~ s:g/_/ /; #replace _ with space
    $wiki-word ~~ s:g/(<[a..z]>)(<[A..Z]>)/$0 $1/; #put space between words
    $wiki-word ~~ s:g/(<[a..z]>)(\d)/$0 $1/; #put space between letter then number
    $wiki-word ~~ s:g/(\d)(<[a..z]>)/$0 $1/; #put space between number then letter
    return $wiki-word;
  }

  method wiki-bracket-link(:$subpage, :$page, :$desc) {
    my $url = $.Sys.get(key => 'SITE_URL') ~ '/' ~ $C_APP_NAME.lc;
    my $current_page = $.CurrentWikiPage;
    if $subpage ne '' {
      $current_page = $current_page ~ $subpage ~ $page;
    }
    else {
      $current_page = $page;
    }
    $url = $url ~ '?p=' ~ $current_page;
    #-- detect if page exists..
    my Str $file-name = self.get-page-filename(filename => $current_page.Str);
    if $file-name.IO.e {
      $url = '<a href="' ~ $url ~ '">' ~ $desc ~ '</a>';
    }
    else {
      $url = $desc ~ '<a href="' ~ $url ~ '"><sup>?</sup></a>';
    }
  return $url;
  }

  method wiki-bracket-multilink(:$subpage, :$page, :$pipe, :$desc) {
    my $url = $.Sys.get(key => 'SITE_URL') ~ '/' ~ $C_APP_NAME.lc;
    my $current_page = $.CurrentWikiPage;
    my @subpages = $page.split('/');
    my $the_url = '';

    if $subpage ne '' {
      my $subpagelink = '';
      my $i = 0;
      for @subpages -> $pagelink {
        $i++;
        $subpagelink ~= '/' ~ $pagelink;
        if $i == @subpages.elems {
          $the_url ~= '<a href="' ~ $url ~ '?p=' ~ $current_page
                                        ~ $subpagelink ~ '">' ~ $desc ~ '</a>';
        }
        else {
          $the_url ~= '<a href="' ~ $url ~ '?p=' ~ $current_page
                                  ~ $subpagelink ~ '">' ~ $pagelink ~ '</a>' ~ '/';
        }
      }
    }
    else {
      my $subpagelink = '';
      my $i = 0;
      for @subpages -> $pagelink {
        $i++;
        $subpagelink ~= $pagelink ~ '/';
        my $subpage_url = $subpagelink.chop;
        if $i == @subpages.elems {
          $the_url ~=  '<a href="' ~ $url ~ '?p=' ~ $subpage_url
                                          ~ '">' ~ $desc ~ '</a>';
        }
        else {
          $the_url ~= '<a href="' ~ $url ~ '?p=' ~ $subpage_url
                                        ~ '">' ~ $pagelink ~ '</a>' ~ '/';
        }
      }
    }
  return $the_url;
  }

  method wiki-common-markup(:$text) {
    my $wiki-text = $text;

    #- begin: localdir

    #- end: localdir

    #- begin: nowiki

    #- end: nowiki

    #- begin: wikiproc
    #- end: wikiproc

    #- begin: training
    #- end: training

    #- begin: postit
    #- end: postit

    #- begin: scroll
    #- end: scroll

    #- begin: sidebar
    #- end: sidebar

    #- begin: sidemenu
    #- end: sidemenu

    #- begin: menubar
    #- end: menubar

    #- begin: sitemenubar
    #- end: sitemenubar

    #- begin: menugroup
    #- end: menugroup

    #- begin: insertpage
    #- end: insertpage

    #- begin: banner
    #- end: banner

    #- begin: pagetitle
    #- end: pagetitle

    #- begin: picture
    #- end: picture

    #- begin: code
    #-- begin: code
    $wiki-text ~~ s:g/\&lt\;code\&gt\;(.*?)\&lt\;\/code\&gt\;/{
    self.store-code(text => $0.Str, tag => 'nowiki');
    }/;
    #- end: code

    #- begin: sapnote
    $wiki-text ~~ s:g/\&lt\;sapnote\&gt\;(.*?)\&lt\;\/sapnote\&gt\;/{
    self.store-sap-note(text => $0.Str, tag => 'nowiki');
    }/;
    #- end: sapnote

    #- begin: pre
    $wiki-text ~~ s:g/\&lt\;pre\&gt\;(.*?)\&lt\;\/pre\&gt\;/{
    self.store-pre(text => $0.Str, tag => 'pre');
    }/;
    #- end: pre

    #-- begin: html pairs
    for @.HtmlPairs -> $tag {
      $wiki-text ~~ s:g/
        \&lt\;$tag\&gt\;
        (.*?)
        \&lt\;\/$tag\&gt\;
        /
        \<$tag\>$0\<\/$tag\>
        /;
    }
    #-- end: html pairs

    #-- begin: html single
    # :FIXME
    #-- end: html single


    #- begin: center, strong, em, tt
    for <b i center strong em tt> -> $tag {
      $wiki-text ~~ s:g/
        \&lt\;$tag\&gt\;
        (.*?)
        \&lt\;\/$tag\&gt\;
        /
        \<$tag\>$0\<\/$tag\>
        /;
    }
    #- end: center

    #- begin: line break
      $wiki-text ~~ s:g/
        \&lt\;br\&gt\;
        /
        \<br\>
        /;
    #- end: line break

    #- begin: tt
    $wiki-text ~~ s:g/
      \&lt\;tt\&gt\;
      (.*?)
      \&lt\;\/tt\&gt\;
      /
      \<tt\>$0\<\/tt\>
      /;
    #- end: tt

    #begin: counter
    #end: counter

    #begin: pod
    $wiki-text ~~ s:g/
      (<[BbIiUu]>)\&lt\;((.*?))\&gt\;
      /
      \<$0\>$1\<\/$0\>
      /;

    #end: pod

    #begin: TEXT-T01

    #end: TEXT-T01

    #begin: ICON
    $wiki-text ~~ s:g/
      \%'ICON'\{(.*?)\}\%
    /{
      self.store-icon-tag(icon => $0);
    }/;
    #end: ICON

    #begin: html links
    # s/
    #  \&lt;            <
    #  A(\s[^<>]+?)     A
    #  \&gt;            >
    #  (.*?)           .*?
    #  \&lt;           <
    #  \/a             /a
    #  \&gt;           >
    # /$self->StoreHref($1, $2)/gise;
    #
    $wiki-text ~~ s:g/
    \&lt\;a\s(.*?)\&gt\;(.*?)\&lt\;\/a\&gt\;
    /{
      self.store-href(anchor => $0, text => $1);
    }/;
    #end: html links


    #begin: action pattern

    #end: action pattern

    #begin: search link
    #end: search link

    #begin: free link pattern
    #end: free link pattern

    #begin: anchored link pattern
    #end: anchored link pattern

    #begin: urlpattern
    #end: urlpattern

    #begin: interlink pattern
    #end: interlink pattern

    #begin: linkpattern
    #end: linkpattern

    #begin: anchoredlinkpattern
    #end: anchoredlinkpattern


    #Hide: #pattern = <nowiki>text<nowiki>
    #Hide: $wikitext ~~ s:g/\&lt\;nowiki\&gt\;(.*?)\&lt\;\/nowiki\&gt\;/{
    #Hide:   self.wiki-nowiki(text => $0);
    #Hide: }/;

    #Hide: #pattern = Bold, italics, emphasized etc -- passed
    #Hide: $wikitext ~~ s:g/\&lt\;(<[BbIiUu]>)\&gt\;(.*?)\&lt\;\/(<[BbIiUu]>)\&gt\;/{
    #Hide:   '<' ~ $0 ~ '>' ~ $1 ~ '</' ~ $0 ~ '>';
    #Hide: }/;

    #Hide: #pattern = <tt>some text</tt>
    #Hide: $wikitext ~~ s:g/\&lt\;('tt')\&gt\;(.*?)\&lt\;\/('tt')\&gt\;/{
    #Hide:   '<' ~ $0 ~ '>' ~ $1 ~ '</' ~ $0 ~ '>';
    #Hide: }/;

    #Hide: #pattern = [[UpperAndAnything]]
    #Hide: $wikitext ~~ s:g/\[\[(<upper>*<alpha>*.*?)\]\]/{
    #Hide:    self.wiki-bracket-link(subpage => '',
    #Hide:                           page => self.wiki-free-to-normal(text => $0),
    #Hide:                           desc => self.wiki-expand-word(text => $0.Str));
    #Hide: }/;

    #Hide: -- menugroup
    #Hide: $wikitext ~~ s:g/\&lt\;menugroup\&gt\;(.*?)\&lt\;\/menugroup\&gt\;/{
    #Hide:   self.wiki-side-menu-group(text => $0);
    #Hide: }/;

    return $wiki-text;
  }

  method wiki-nowiki(:$text) {
    my $wikitext = $text;
    #-- remove \n
    $wikitext ~~ s:g/\&lt\;br\&gt\;//;
    $wikitext ~~ s:g/\&lt\;\/br\&gt\;//;
    $wikitext ~~ s:g/\<br\>//;
    $wikitext ~~ s:g/\<\/br\>//;
    $wikitext ~~ s:g/\<br\/\>//;
    return $wikitext;
  }

  method wiki-free-to-normal(:$text) {
    my $id = $text;
    $id ~~ s:g/<space>+/_/;
    return $id;
  }

  method wiki-side-menu-group(:$text) {
    my $wiki-text = '';
    $wiki-text = $text;
    $wiki-text ~~ s:g/\n/\<br\/\>/;
    if $wiki-text ne '' {
     #$text = 'menugroup:' ~ $wikitext;
    }
    return '';
  };

  method wiki-line(:$text) {
    my $line = $text;

    #- <toc>
    $line ~~ s:g/\&lt\;'toc'\&gt\;/TODO:Table-of-Contents/;

    #- B<Bold text> U<underlined> I<italic>
    $line ~~ s:g/(<[BUIbui]>)(\&lt\;)(.*?)(\&gt\;)/{
    self.wiki-pod(text => $2, tag => $0);
    }/;

    my Bool $heading_detected = False;

    #pattern = === Heading === #-- temporarily disable
    $line ~~ s:g/^^(\=+)\s+?(.*?)\s+?(\=+)/{
    $heading_detected = True;
    self.wiki-heading(prefix => $0, heading => $1, suffix => $2);
    }/;

    #pattern = :text - where : is number of &nbsp;
    $line ~~ s:g/^^(\:+)(.*?)$$/{
      self.wiki-indent(indent => $0, text => $1);
    }/;

    #pattern = <space>text - where : is number of &nbsp;
    $line ~~ s:g/^^(' '+)(.*)$$/{ #' comment to fix editor color
      self.wiki-space-indent(indent => $0, text => $1);
    }/;

    $line ~~ s:g/\%'ICON'\{(.*?)\}\%/{
      self.wiki-icon-pattern(icon => $0);
    }/;

    $line ~~ s:g/\[upload\:(.*)\]/{
    self.wiki-get-file-upload(filename => $0);
    }/;


    $line ~~ s:g/\&lt\;'sapnote'\&gt\;\s*?(\d+)\s*?(.*?)\&lt\;\/'sapnote'\&gt\;/{
    self.wiki-sap-note(note => $0.Int, desc => $1.Str);
    }/;

    $line ~~ s:g/\&lt\;hr\/?\&gt\;/\<hr\/\>/;

    $line ~= '<br/>' if !$heading_detected; #-- do not add line break if line is heading

    return $line;
  }

  method wiki-list-item(:$text, :$listtype, :$symbol) {
    my $para = $text;

    my @ParagraphLines = $para.split(/\n/);
    my Bool $inside-list = False;
    my Bool $new-list = False;
    my Bool $current-list = False;
    my Str $item-status = '';
    my Str $last-status = '';
    my Str $new-paragraph = '';
    my Int $depth = 0;
    my Int $last-depth = 0;
    for @ParagraphLines -> $line {
      my $line_item = $line;

      #self.TRACE: 'Line chars: ' ~ $line.chars;

      if $line_item.substr(0..0) eq $symbol {
        my $star = '';

        $line_item ~~ s:g/^^($symbol+)(.*?)$$/{
          $star = $0;
          $depth = $star.chars;
          $1;
        }/;

        $new-list = True;
        if $new-list &&! $current-list {
          $item-status = 'N'; #new
          $last-status = $item-status;
          # OL LI xxx
          my $indent = '';
          if $depth > $last-depth {
            my Int $depthDelta = $depth - $last-depth;
            for 1..$depthDelta {
              $indent ~= '<' ~ $listtype ~ '>';
            }
          }

          $line_item = $indent ~ '<li>' ~ $line_item; #new
        }
        else {
          $item-status = 'C'; #current
          $last-status = $item-status;
          # LI xxx
          my $indent = '';
          if $depth == $last-depth {

          }
          elsif $depth > $last-depth {
            my Int $depthDelta = $depth - $last-depth;
            for 1..$depthDelta {
              $indent ~= '<' ~ $listtype ~ '>';
            }
          }
          elsif $depth < $last-depth {
            my Int $depthDelta = $last-depth - $depth;
            for 1..$depthDelta {
              $indent ~= '</' ~ $listtype ~ '>';
            }
          }

          $line_item = $indent ~ '<li>' ~ $line_item; #new
        }
        $inside-list = True;
        $current-list = $new-list;
      }
      else {
        $item-status = 'L'; #last
        if $inside-list {
          $item-status = 'L'; #last
          $last-status = $item-status;
          # LI xxx OL
          my $indent = '';
          $line_item = '<li>' ~ $line_item; #new
          for 0..$last-depth {
            $line_item ~= '</' ~ $listtype ~ '>';
          }

          $new-list = False;
          $inside-list = False; #- turn off List
        }
      }
      $new-paragraph ~= $line_item ~ ' '; # ~ "\n";
      $last-depth = $depth;
    }
    $new-paragraph ~= ' ';
    $item-status = 'L' if $last-status eq 'C' || $last-status eq 'N';
    if $last-status eq 'C' || $last-status eq 'N' {
      # OL
      for 1..$last-depth {
        $new-paragraph ~= '</' ~ $listtype ~ '>';
      }

    }
    $para = $new-paragraph;
    # end - lists

    #<li></ol> #-- remove -- extra blank list item
    $para ~~ s:g/\<li\>\<\/ol\>//;

    #<li></ul> #-- remove extra list item
    $para ~~ s:g/\<li\>\<\/ul\>//;

    return $para;
  }

  method wiki-set-page-title(Str :$title = '') {
    my Str $title-text = '';
    if $title ne '' {
      #--FIXME: $.PAGETITLE = $title.Str;
    }
    return $title-text;
  }

  method wiki-source-code(:$text) {
    my $source-code = $text;
    $source-code ~~ s:g/(\<br\/\>)+//;
    #$code = '<pre><code>' ~ $code ~ '</code></pre>';
    $source-code = '<textarea name="code" rows="5" cols="132" wrap="virtual" style="width:75%">' ~ $text ~ '</textarea>';
    return $source-code;
  }

  method wiki-pod(:$text, :$tag) {
    my $pod = '<' ~ $tag ~ '>' ~ $text ~ '</' ~ $tag ~ '>';
    return $pod;
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
    $icon-path = 'themes/img/icons/' ~ $icon;
    return $icon-path;
  };

  method wiki-indent(:$indent, :$text) {
    my $indent_text = self.space(2); #'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
    for 1..$indent.chars {
      $indent_text ~= $indent_text;
    }
    return $indent_text ~ $text;
  }

  method store-href(:$anchor, :$text) {
    #    return self.store-raw(text => "<$tag>" ~ $wiki-text ~ "</$tag>");
    my $href = '';
    my $txt = '';
    $txt = $text.Str;
    $href = $anchor.Str;
    return '<a ' ~ self.store-raw(text => $href) ~ '>' ~ $txt ~ '</a>';
  }

  method wiki-space-indent(:$indent, :$text) {
    my $indent_text = self.space(1); #'&nbsp;&nbsp;';
    for 1..$indent.chars {
      $indent_text ~= $indent_text;
    }
    return self.space(5) ~ $indent_text ~ $text;
  }


  method wiki-icon-pattern(:$icon) {
    return '<img src="/themes/img/icons/' ~ $icon.lc ~ '.png"/>';
    #return 'icon:' ~ $icon.uc ~ '; ';
  }



  method wiki-get-file-upload(:$filename) {
    my Str $file-path = '';

    #[upload:/photos/books.jpg] maps to /file/uploads/photos/books.jpg

    my Str $path-prefix = '/file/uploads/';
    if $filename ne '' {
      #self.TRACE: 'FILENAME = ' ~ $filename;
      my $file = $filename;
      my $alt = '';
      $file ~~ s:g/^^(.*?)\s+(.*)/{
        #self.TRACE: '0 = ' ~ $0;
        #self.TRACE: '1 = ' ~ $1;
        $alt = $1;
        $0;
      }/;
      #self.TRACE: 'FILE = ' ~ $file;
      $file-path = '<img src="' ~ $path-prefix ~ $file ~ '" alt="' ~ $alt ~ '"/>';
    }
    return $file-path;
  }


  method wiki-sap-note(Int :$note, Str :$desc?) {
    my Int $sap-note = $note;
    my Str $sDesc = $desc;
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

  method wiki-remove-field-separator(Str :$text) {
    my Str $wiki-text = '';
    $wiki-text = $text;
    $wiki-text ~~ s:g/($C_FS)+(\d)/\|/;
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

