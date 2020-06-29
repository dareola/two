
unit module Sys::Database:ver<0.0.0>:auth<Domingo Areola (dareola@gmail.com)>;
  use DBIish;
  class X::Sys::Database is Exception {
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


class Sys::Database is export {
    constant $C_DBTYPE_SQLITE = 'SQLite';
    has %.params = ();
    has $.Sys is rw =  '';
    has $.DebugInfo is rw = "";
    has %.Config is rw;
    has $.UserID is rw;
    has $.UserCommand is rw;

    has Str %.CMD = (
        'init' => 'INIT',
    );

    has $SCREEN = "";
    has %SCREEN_TITLE = (
      1000 => "TESTING_1000";
    );

    
    method main($App, Str :$userid, Str :$ucomm, :%params) {
    $.Sys = $App;
    $.UserID = $userid;
    $.UserCommand = $ucomm;
    %.params = %params;
    
    #self.TRACE: 'Database user command = ' ~ $ucomm;

    given $ucomm {
      when %.CMD<init> {
        $SCREEN = '1000'; #- create blank database
      }
    }
    self.goto-screen(screen => $SCREEN);
  }

    
    method goto-screen(Str :$screen) {
    my Str $sNextScreen = 'screen_' ~ $screen;
    if self.can($sNextScreen) {
      self."$sNextScreen"();
    }
  }

    
  method screen_1000 { #-- ucomm = INIT; Create a blank database 
  my str $database-file = self.get(key => 'DATA_DIR')
                        ~ '/' 
                        ~ self.get(key => 'SID')
                        ~ self.get(key => 'SID_NR')
                        ~ '/' 
                        ~ self.get(key => 'SID')
                        ~ self.get(key => 'SID_NR')
                        ~ '.db';
  
  if $database-file.IO.e {

    #-- self.TRACE: 'FOUND!! Database file name = ' ~ $database-file;    

  }
  else {

    #-- Create empty sqlite database
    self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $database-file);

    #-- Create empty table structures
    self.initialize-DBTABLES();

    #-- Populate tables
    self.initialize-TABLFLDS(tabname => 'TABLFLDS');
    self.initialize-DBDOMAIN(tabname => 'DBDOMAIN');
    self.initialize-DBDOMAIT(tabname => 'DBDOMAIT');
    self.initialize-DATAELEM(tabname => 'DATAELEM');
    self.initialize-DATAELET(tabname => 'DATAELET');
    self.initialize-STATCODE(tabname => 'STATCODE');
    self.initialize-STATCODT(tabname => 'STATCODT');
    self.initialize-DDICVERS(tabname => 'DDICVERS');
    self.initialize-VERSTEXT(tabname => 'VERSTEXT');
    self.initialize-ISOLANGU(tabname => 'ISOLANGU');
    self.initialize-LOGICALS(tabname => 'LOGICALS');
    self.initialize-BOOLEANS(tabname => 'BOOLEANS');
    self.initialize-DATATYPE(tabname => 'DATATYPE');
    self.initialize-TABLTYPE(tabname => 'TABLTYPE');
    self.initialize-TABLTYPT(tabname => 'TABLTYPT');
    self.initialize-OBJTYPES(tabname => 'OBJTYPES');
    self.initialize-OBJTYPET(tabname => 'OBJTYPET');
    self.initialize-USERMSTR(tabname => 'USERMSTR');
    self.initialize-CLNTMSTR(tabname => 'CLNTMSTR');
    self.initialize-CLNTMSTT(tabname => 'CLNTMSTT');
    self.initialize-CLNTUSER(tabname => 'CLNTUSER');
    self.initialize-APPLAREA(tabname => 'APPLAREA');
    self.initialize-PROGTABL(tabname => 'PROGTABL');
    self.initialize-PROGTABT(tabname => 'PROGTABT');
    self.initialize-SHORTCUT(tabname => 'SHORTCUT'); 
    self.initialize-DDRELATE(tabname => 'DDRELATE'); 
    self.initialize-DDRELATT(tabname => 'DDRELATT'); 
    self.initialize-MESGTXTS(tabname => 'MESGTXTS');

    #-- Define table index
    self.create-table-index(tabname => 'TABLFLDS', reindex => True);
    self.create-table-index(tabname => 'DBDOMAIN', reindex => True);
    self.create-table-index(tabname => 'DBDOMAIT', reindex => True);
    self.create-table-index(tabname => 'DATAELEM', reindex => True);
    self.create-table-index(tabname => 'DATAELET', reindex => True);
    self.create-table-index(tabname => 'STATCODE', reindex => True);
    self.create-table-index(tabname => 'STATCODT', reindex => True);
    self.create-table-index(tabname => 'DDICVERS', reindex => True);
    self.create-table-index(tabname => 'VERSTEXT', reindex => True);
    self.create-table-index(tabname => 'ISOLANGU', reindex => True);
    self.create-table-index(tabname => 'LOGICALS', reindex => True);
    self.create-table-index(tabname => 'BOOLEANS', reindex => True);
    self.create-table-index(tabname => 'DATATYPE', reindex => True);
    self.create-table-index(tabname => 'TABLTYPE', reindex => True);
    self.create-table-index(tabname => 'TABLTYPT', reindex => True);
    self.create-table-index(tabname => 'OBJTYPES', reindex => True);
    self.create-table-index(tabname => 'OBJTYPET', reindex => True);
    self.create-table-index(tabname => 'USERMSTR', reindex => True);
    self.create-table-index(tabname => 'CLNTMSTR', reindex => True);
    self.create-table-index(tabname => 'CLNTMSTT', reindex => True);
    self.create-table-index(tabname => 'CLNTUSER', reindex => True);
    self.create-table-index(tabname => 'APPLAREA', reindex => True);
    self.create-table-index(tabname => 'PROGTABL', reindex => True);
    self.create-table-index(tabname => 'PROGTABT', reindex => True);
    self.create-table-index(tabname => 'SHORTCUT', reindex => True);
    self.create-table-index(tabname => 'DDRELATE', reindex => True);
    self.create-table-index(tabname => 'DDRELATT', reindex => True);
    self.create-table-index(tabname => 'MESGTXTS', reindex => True);

  }

  return True;
}

    
    method initialize-config(:%cfg) {
    %.Config = %cfg;
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

    


method TRACE(Str $msg, :$id = "D0", :$no = "001", :$ty = "I", :$t1 = "", :$t2 = "", :$t3 = "", :$t4 = "" ) {
    my Str $sInfo = "";

    $sInfo = $t1;
    $sInfo = $t1 ~ $msg.Str if $msg ne "";

    $.DebugInfo ~= $id ~ "-" ~ $no ~ " " ~ $ty ~ " ";
    $.DebugInfo ~= $msg ~ "<br/>" if $msg ne "";

    


  my $e = X::Sys::Database.new(
      msg-id => $id, msg-no => $no, msg-ty => $ty,
      msg-t1 => $sInfo, msg-t2 => $t2, msg-t3 => $t3,msg-t4 => $t4);
      note $e.message;
  }

    
    method initialize-DBTABLES() {

        #----------------------------------------------
        my $tabname = 'DBTABLES';
        my $descrip = 'Database table';
        my $langiso = 'E';
        my $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            tabltyp varchar2(1),
            clntdep varchar2(1),
            langdep varchar2(1),
            contflg varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DBTABLET';
        $descrip = 'Database table description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            langiso varchar2(1),
            shortxt varchar2(10),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'ISOLANGU';
        $descrip = 'ISO languages';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            langiso varchar2(1),
            shortxt varchar2(10),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DDICTEXT';
        $descrip = 'Data dictionary text';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'TABLTYPE';
        $descrip = 'Table types';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabltyp varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'TABLTYPT';
        $descrip = 'Table type description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabltyp varchar2(1),
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'OBJTYPES';
        $descrip = 'Dictionary object types';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            objtype varchar2(4),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'OBJTYPET';
        $descrip = 'Data dictionary object types description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            objtype varchar2(4),
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'LOGICALS';
        $descrip = 'Logical true or false';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            logical varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'BOOLEANS';
        $descrip = 'Logical values';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            codenam varchar2(1),
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'VERSTEXT';
        $descrip = 'Data dictionary object description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            version varchar2(4),
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DDICVERS';
        $descrip = 'Data dictionary object version';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            version varchar2(4),
            hiversn varchar2(4),
            loversn varchar2(4),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'STATCODE';
        $descrip = 'Data dictionary object activation status';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            statcod varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'STATCODT';
        $descrip = 'Data dictionary object activation description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            statcod varchar2(1),
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'USERMSTR';
        $descrip = 'User master record';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            usercod varchar2(12),
            firstnm varchar2(60),
            lastnam varchar2(60),
            actvatd varchar2(1),
            changby varchar2(64),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DBDOMAIN';
        $descrip = 'Data domain';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            domname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            datatyp varchar2(4),
            datalen varchar2(4),
            displen varchar2(4),
            datadec varchar2(4),
            lowcase varchar2(1),
            signflg varchar2(1),
            langflg varchar2(1),
            fixvalu varchar2(1),
            valtabl varchar2(30),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DBDOMAIT';
        $descrip = 'Data domain description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            domname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            langiso varchar2(1),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DOMVALUE';
        $descrip = 'Data domain values';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            domname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            dvalkey varchar2(4),
            lovalue varchar2(10),
            hivalue varchar2(10),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DOMVALUT';
        $descrip = 'Data domain value description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            domname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            dvalkey varchar2(4),
            langiso varchar2(1),
            descrip varchar2(20),
            lovalue varchar2(10),
            hivalue varchar2(10),
            slvalue varchar2(10),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'VALUETAB';
        $descrip = 'Data domain value table';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            domname varchar2(30),
            tabname varchar2(30),
            txttabl varchar2(30),
            fldname varchar2(30),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DATAELEM';
        $descrip = 'Data elements';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            delemnt varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            domname varchar2(30),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DATAELET';
        $descrip = 'Data element description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            delemnt varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            langiso varchar2(1),
            descrip varchar2(20),
            shortxt varchar2(20),
            medtext varchar2(30),
            longtxt varchar2(4),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DATATYPE';
        $descrip = 'Internal data types';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            datatyp varchar2(4),
            shortxt varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'TABLFLDS';
        $descrip = 'Table fields';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabname varchar2(30),
            fldname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            delemnt varchar2(30),
            fldspos varchar2(4),
            primkey varchar2(1),
            nullflg varchar2(1),
            chktabl varchar2(30),
            inttype varchar2(4),
            intleng varchar2(6),
            datadec varchar2(4),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'APPLAREA';
        $descrip = 'Application area';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            apparea varchar2(30),
            langiso varchar2(1),
            descrip varchar2(20),
            creatby varchar2(12),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'MESGTXTS';
        $descrip = 'Message texts';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            langiso varchar2(1),
            apparea varchar2(30),
            mesgnum varchar2(3),
            mesgtxt varchar2(73),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DDRELATE';
        $descrip = 'Data dictionary object relationships';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabname varchar2(30),
            fldname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            chktabl varchar2(30),
            objrela varchar2(4),
            lcrdnal varchar2(2),
            rcrdnal varchar2(2),
            apparea varchar2(30),
            mesgnum varchar2(3),
            chkflag varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'DDRELATT';
        $descrip = 'Data dictionary object relationship texts';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            tabname varchar2(30),
            fldname varchar2(30),
            actvatd varchar2(1),
            version varchar2(4),
            langiso varchar2(1),
            descrip varchar2(60),
            mesgtxt varchar2(73),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'CLNTMSTR';
        $descrip = 'Client master table';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            clntnum varchar2(3),
            actvatd varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'CLNTMSTT';
        $descrip = 'Client master table description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            clntnum varchar2(3),
            actvatd varchar2(1),
            langiso varchar2(1),
            descrip varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'CLNTUSER';
        $descrip = 'Client user master table';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            clntnum varchar2(3),
            actvatd varchar2(1),
            usercod varchar2(12),
            usrlock varchar2(1),
            langiso varchar2(1),
            passwrd varchar2(8),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'PROGTABL';
        $descrip = 'Programs listing';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            program varchar2(60),
            actvatd varchar2(1),
            progtxt varchar2(2),
            objtype varchar2(4),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'PROGTABT';
        $descrip = 'Program description';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            program varchar2(60),
            actvatd varchar2(1),
            langiso varchar2(1),
            descrip varchar2(20),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'SHORTCUT';
        $descrip = 'Program shortcuts';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            shortct varchar2(20),
            program varchar2(65),
            actvatd varchar2(1),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        $tabname = 'PROGTEXT';
        $descrip = 'Program text elements';
        $langiso = 'E';
        $new-table = qq:to/SQL/;
          CREATE TABLE $tabname (
            program varchar2(65),
            progtxt varchar2(2),
            langiso varchar2(1),
            messgid varchar2(4),
            mesgtxt varchar2(254),
            changby varchar2(12),
            changdt varchar2(8),
            changtm varchar2(6)
          );
          SQL
        self.db-create-table(tabname => $tabname, descrip => $descrip,
                              sql => $new-table, language => $langiso);
        #----------------------------------------------

        #$tabname = 'LOCKTABLE';
        #$descrip = 'Lock objects';
        #$langiso = 'E';
        #my Str $new-table = qq:to/SQL/;
        #  CREATE TABLE $tabname (
        #    <field> <type>
        #  );
        #  SQL
        #self.db-create-table(tabname => $tabname, descrip => $descrip,
        #                     sql => $new-table, language => $langiso);
        #----------------------------------------------

        #$tabname = 'LOCKTABLT';
        #$descrip = 'Lock object description';
        #$langiso = 'E';
        #my Str $new-table = qq:to/SQL/;
        #  CREATE TABLE $tabname (
        #    <field> <type>
        #  );
        #  SQL
        #self.db-create-table(tabname => $tabname, descrip => $descrip,
        #                     sql => $new-table, language => $langiso);
        #----------------------------------------------

      }

    
    method initialize-TABLFLDS(Str :$tabname) {
        
        #-- Pupulate TABLFLDS
        # TABLFLDS own structure
        self.insert-table($tabname, key => 'TABLFLDS|TABNAME|A|0', values => 'DBTABLE|0001|X| |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'TABLFLDS|FLDNAME|A|0', values => 'FLDNAME|0002|X| ||CHAR|30|30');
        self.insert-table($tabname, key => 'TABLFLDS|ACTVATD|A|0', values => 'ACTVATD|0003|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'TABLFLDS|VERSION|A|0', values => 'DDOVERS|0004|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'TABLFLDS|DELEMNT|A|0', values => 'DELEMNT|0005| | |DATAELEM|CHAR|30|30');
        self.insert-table($tabname, key => 'TABLFLDS|FLDSPOS|A|0', values => 'FLDSPOS|0006| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'TABLFLDS|PRIMKEY|A|0', values => 'PRIMKEY|0007| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'TABLFLDS|NULLFLG|A|0', values => 'NULLFLG|0008| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'TABLFLDS|CHKTABL|A|0', values => 'CHKTABL|0009| | |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'TABLFLDS|INTTYPE|A|0', values => 'INTTYPE|0010| | |DATATYPE|CHAR|4|4');
        self.insert-table($tabname, key => 'TABLFLDS|INTLENG|A|0', values => 'INTLENG|0011| | ||CHAR|6|6');
        self.insert-table($tabname, key => 'TABLFLDS|DATADEC|A|0', values => 'DATADEC|0012| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'TABLFLDS|CHANGBY|A|0', values => 'CHANGBY|0013| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'TABLFLDS|CHANGDT|A|0', values => 'CHANGDT|0014| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'TABLFLDS|CHANGTM|A|0', values => 'CHANGTM|0015| | ||CHAR|6|6');

        # ISOLANGU
        self.insert-table($tabname, key => 'ISOLANGU|LANGISO|A|0', values => 'LANGUAG|0001|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'ISOLANGU|SHORTXT|A|0', values => 'DESCRIP|0002| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'ISOLANGU|CHANGBY|A|0', values => 'CHANGBY|0003| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'ISOLANGU|CHANGDT|A|0', values => 'CHANGDT|0004| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'ISOLANGU|CHANGTM|A|0', values => 'CHANGTM|0005| | ||CHAR|6|6');

        # DDICTEXT
        self.insert-table($tabname, key => 'DDICTEXT|LANGISO|A|0', values => 'LANGUAG|0001|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'DDICTEXT|SHORTXT|A|0', values => 'DESCRIP|0002| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DDICTEXT|CHANGBY|A|0', values => 'CHANGBY|0003| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DDICTEXT|CHANGDT|A|0', values => 'CHANGDT|0004| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DDICTEXT|CHANGTM|A|0', values => 'CHANGTM|0005| | ||CHAR|6|6');

        # TABLTYPE
        self.insert-table($tabname, key => 'TABLTYPE|TABLTYP|A|0', values => 'TABLTYP|0001|X| |TABLTYPE|CHAR|1|1');
        self.insert-table($tabname, key => 'TABLTYPE|CHANGBY|A|0', values => 'CHANGBY|0002| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'TABLTYPE|CHANGDT|A|0', values => 'CHANGDT|0003| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'TABLTYPE|CHANGTM|A|0', values => 'CHANGTM|0004| | ||CHAR|6|6');

        # TABLTYPT
        self.insert-table($tabname, key => 'TABLTYPT|TABLTYP|A|0', values => 'TABLTYP|0001|X| |TABLTYPE|CHAR|1|1');
        self.insert-table($tabname, key => 'TABLTYPT|LANGISO|A|0', values => 'LANGUAG|0002|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'TABLTYPT|SHORTXT|A|0', values => 'DESCRIP|0003| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'TABLTYPT|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'TABLTYPT|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'TABLTYPT|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');

        # OBJTYPES
        self.insert-table($tabname, key => 'OBJTYPES|OBJTYPE|A|0', values => 'OBJTYPE|0001|X| |OBJTYPE|CHAR|4|4');
        self.insert-table($tabname, key => 'OBJTYPES|CHANGBY|A|0', values => 'CHANGBY|0002| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'OBJTYPES|CHANGDT|A|0', values => 'CHANGDT|0003| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'OBJTYPES|CHANGTM|A|0', values => 'CHANGTM|0004| | ||CHAR|6|6');

        # OBJTYPET
        self.insert-table($tabname, key => 'OBJTYPET|OBJTYPE|A|0', values => 'OBJTYPE|0001|X| |OBJTYPE|CHAR|4|4');
        self.insert-table($tabname, key => 'OBJTYPET|LANGISO|A|0', values => 'LANGUAG|0002|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'OBJTYPET|SHORTXT|A|0', values => 'DESCRIP|0003| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'OBJTYPET|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'OBJTYPET|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'OBJTYPET|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');

        # LOGICALS
        self.insert-table($tabname, key => 'LOGICALS|LOGICAL|A|0', values => 'LOGICAL|0001|X| |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'LOGICALS|CHANGBY|A|0', values => 'CHANGBY|0002| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'LOGICALS|CHANGDT|A|0', values => 'CHANGDT|0003| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'LOGICALS|CHANGTM|A|0', values => 'CHANGTM|0004| | ||CHAR|6|6');

        # BOOLEANS
        self.insert-table($tabname, key => 'BOOLEANS|CODENAM|A|0', values => 'BOOLEAN|0001|X| |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'BOOLEANS|LANGISO|A|0', values => 'LANGUAG|0002|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'BOOLEANS|SHORTXT|A|0', values => 'DESCRIP|0003| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'BOOLEANS|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'BOOLEANS|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'BOOLEANS|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');

        # VERSTEXT
        self.insert-table($tabname, key => 'VERSTEXT|VERSION|A|0', values => 'DDOVERS|0001|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'VERSTEXT|LANGISO|A|0', values => 'LANGUAG|0002|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'VERSTEXT|SHORTXT|A|0', values => 'DESCRIP|0003| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'VERSTEXT|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'VERSTEXT|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'VERSTEXT|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');

        # DDICVERS
        self.insert-table($tabname, key => 'DDICVERS|VERSION|A|0', values => 'DDOVERS|0001|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DDICVERS|HIVERSN|A|0', values => 'DDHVERS|0002| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'DDICVERS|LOVERSN|A|0', values => 'DDLVERS|0003| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'DDICVERS|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DDICVERS|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DDICVERS|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');

        # STATCODE
        self.insert-table($tabname, key => 'STATCODE|STATCOD|A|0', values => 'DDOSTAT|0001|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'STATCODE|CHANGBY|A|0', values => 'CHANGBY|0002| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'STATCODE|CHANGDT|A|0', values => 'CHANGDT|0003| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'STATCODE|CHANGTM|A|0', values => 'CHANGTM|0004| | ||CHAR|6|6');

        # STATCODT
        self.insert-table($tabname, key => 'STATCODT|STATCOD|A|0', values => 'DDOSTAT|0001|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'STATCODT|LANGISO|A|0', values => 'LANGUAG|0002|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'STATCODT|SHORTXT|A|0', values => 'DESCRIP|0003| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'STATCODT|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'STATCODT|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'STATCODT|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');

        # USERMSTR
        self.insert-table($tabname, key => 'USERMSTR|USERCOD|A|0', values => 'USERCOD|0001|X| |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'USERMSTR|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'USERMSTR|FIRSTNM|A|0', values => 'FIRSTNM|0003| | ||CHAR|60|60');
        self.insert-table($tabname, key => 'USERMSTR|LASTNAM|A|0', values => 'LASTNAM|0004| | ||CHAR|60|60'); 
        self.insert-table($tabname, key => 'USERMSTR|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'USERMSTR|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'USERMSTR|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # DBTABLES
        self.insert-table($tabname, key => 'DBTABLES|TABNAME|A|0', values => 'DBTABLE|0001|X| |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'DBTABLES|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLES|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DBTABLES|TABLTYP|A|0', values => 'TABLTYP|0004|X| |TABLTYPE|CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLES|CLNTDEP|A|0', values => 'CLNTDEP|0005| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLES|LANGDEP|A|0', values => 'LANGDEP|0006| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLES|CONTFLG|A|0', values => 'CONTFLG|0007| | ||CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLES|CHANGBY|A|0', values => 'CHANGBY|0008| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DBTABLES|CHANGDT|A|0', values => 'CHANGDT|0009| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DBTABLES|CHANGTM|A|0', values => 'CHANGTM|0010| | ||CHAR|6|6');

        # DBTABLET
        self.insert-table($tabname, key => 'DBTABLET|TABNAME|A|0', values => 'DBTABLE|0001|X| |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'DBTABLET|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLET|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DBTABLET|LANGISO|A|0', values => 'LANGUAG|0004|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'DBTABLET|SHORTXT|A|0', values => 'DESCRIP|0005| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DBTABLET|CHANGBY|A|0', values => 'CHANGBY|0006| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DBTABLET|CHANGDT|A|0', values => 'CHANGDT|0007| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DBTABLET|CHANGTM|A|0', values => 'CHANGTM|0008| | ||CHAR|6|6');

        # DBDOMAIN
        self.insert-table($tabname, key => 'DBDOMAIN|DOMNAME|A|0', values => 'DOMNAME|0001|X| |DBDOMAIN|CHAR|30|30');
        self.insert-table($tabname, key => 'DBDOMAIN|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIN|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DBDOMAIN|DATATYP|A|0', values => 'DATATYP|0004| | |DATATYPE|CHAR|4|4');
        self.insert-table($tabname, key => 'DBDOMAIN|DATALEN|A|0', values => 'DATALEN|0005| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'DBDOMAIN|DISPLEN|A|0', values => 'DISPLEN|0006| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'DBDOMAIN|DATADEC|A|0', values => 'DATADEC|0007| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'DBDOMAIN|LOWCASE|A|0', values => 'LOWCASE|0008| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIN|SIGNFLG|A|0', values => 'SIGNFLG|0009| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIN|LANGFLG|A|0', values => 'LANGFLG|0010| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIN|FIXVALU|A|0', values => 'FIXVALU|0011| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIN|VALTABL|A|0', values => 'VALTABL|0012| | |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'DBDOMAIN|CHANGBY|A|0', values => 'CHANGBY|0013| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DBDOMAIN|CHANGDT|A|0', values => 'CHANGDT|0014| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DBDOMAIN|CHANGTM|A|0', values => 'CHANGTM|0015| | ||CHAR|6|6');

        # DBDOMAIT
        self.insert-table($tabname, key => 'DBDOMAIT|DOMNAME|A|0', values => 'DOMNAME|0001|X| |DBDOMAIN|CHAR|30|30');
        self.insert-table($tabname, key => 'DBDOMAIT|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIT|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DBDOMAIT|LANGISO|A|0', values => 'LANGUAG|0004|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'DBDOMAIT|SHORTXT|A|0', values => 'DESCRIP|0005| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DBDOMAIT|CHANGBY|A|0', values => 'CHANGBY|0006| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DBDOMAIT|CHANGDT|A|0', values => 'CHANGDT|0007| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DBDOMAIT|CHANGTM|A|0', values => 'CHANGTM|0008| | ||CHAR|6|6');

        # DATAELEM
        self.insert-table($tabname, key => 'DATAELEM|DELEMNT|A|0', values => 'DELEMNT|0001|X| |DATAELEM|CHAR|30|30');
        self.insert-table($tabname, key => 'DATAELEM|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DATAELEM|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DATAELEM|DOMNAME|A|0', values => 'DOMNAME|0004| | |DBDOMAIN|CHAR|30|30');
        self.insert-table($tabname, key => 'DATAELEM|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DATAELEM|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DATAELEM|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # DATAELET
        self.insert-table($tabname, key => 'DATAELET|DELEMNT|A|0', values => 'DELEMNT|0001|X| |DATAELEM|CHAR|30|30');
        self.insert-table($tabname, key => 'DATAELET|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DATAELET|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DATAELET|LANGISO|A|0', values => 'LANGUAG|0004|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'DATAELET|DESCRIP|A|0', values => 'DESCRIP|0005| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DATAELET|SHORTXT|A|0', values => 'SHORTXT|0006| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DATAELET|MEDTEXT|A|0', values => 'MEDTEXT|0007| | ||CHAR|30|30');
        self.insert-table($tabname, key => 'DATAELET|LONGTXT|A|0', values => 'LONGTXT|0008| | ||CHAR|60|60');
        self.insert-table($tabname, key => 'DATAELET|CHANGBY|A|0', values => 'CHANGBY|0009| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DATAELET|CHANGDT|A|0', values => 'CHANGDT|0010| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DATAELET|CHANGTM|A|0', values => 'CHANGTM|0011| | ||CHAR|6|6');

        # DATATYPE
        self.insert-table($tabname, key => 'DATATYPE|DATATYP|A|0', values => 'DATATYP|0001|X| |DATATYPE|CHAR|4|4');
        self.insert-table($tabname, key => 'DATATYPE|SHORTXT|A|0', values => 'DESCRIP|0002| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DATATYPE|CHANGBY|A|0', values => 'CHANGBY|0003| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DATATYPE|CHANGDT|A|0', values => 'CHANGDT|0004| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DATATYPE|CHANGTM|A|0', values => 'CHANGTM|0005| | ||CHAR|6|6');

        # DOMVALUE
        self.insert-table($tabname, key => 'DOMVALUE|DOMNAME|A|0', values => 'DOMNAME|0001|X| |DBDOMAIN|CHAR|30|30');
        self.insert-table($tabname, key => 'DOMVALUE|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DOMVALUE|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DOMVALUE|DVALKEY|A|0', values => 'DVALKEY|0004|X| ||CHAR|4|4');
        self.insert-table($tabname, key => 'DOMVALUE|LOVALUE|A|0', values => 'LOVALUE|0005| | ||CHAR|10|10');
        self.insert-table($tabname, key => 'DOMVALUE|HIVALUE|A|0', values => 'HIVALUE|0006| | ||CHAR|10|10');
        self.insert-table($tabname, key => 'DOMVALUE|CHANGBY|A|0', values => 'CHANGBY|0007| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DOMVALUE|CHANGDT|A|0', values => 'CHANGDT|0008| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DOMVALUE|CHANGTM|A|0', values => 'CHANGTM|0009| | ||CHAR|6|6');

        # DOMVALUT
        self.insert-table($tabname, key => 'DOMVALUT|DOMNAME|A|0', values => 'DOMNAME|0001|X| |DBDOMAIN|CHAR|30|30');
        self.insert-table($tabname, key => 'DOMVALUT|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DOMVALUT|VERSION|A|0', values => 'DDOVERS|0003|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DOMVALUT|DVALKEY|A|0', values => 'DVALKEY|0004|X| ||CHAR|4|4');
        self.insert-table($tabname, key => 'DOMVALUT|LANGISO|A|0', values => 'LANGUAG|0005|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'DOMVALUT|DESCRIP|A|0', values => 'DESCRIP|0006| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'DOMVALUT|LOVALUE|A|0', values => 'LOVALUE|0007| | ||CHAR|10|10');
        self.insert-table($tabname, key => 'DOMVALUT|HIVALUE|A|0', values => 'HIVALUE|0008| | ||CHAR|10|10');
        self.insert-table($tabname, key => 'DOMVALUT|SLVALUE|A|0', values => 'SLVALUE|0009| | ||CHAR|10|10');
        self.insert-table($tabname, key => 'DOMVALUT|CHANGBY|A|0', values => 'CHANGBY|0010| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DOMVALUT|CHANGDT|A|0', values => 'CHANGDT|0011| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DOMVALUT|CHANGTM|A|0', values => 'CHANGTM|0012| | ||CHAR|6|6');

        # VALUTABL
        self.insert-table($tabname, key => 'VALUETAB|DOMNAME|A|0', values => 'DOMNAME|0001|X| |DBDOMAIN|CHAR|30|30');
        self.insert-table($tabname, key => 'VALUETAB|TABNAME|A|0', values => 'DBTABLE|0002|X| |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'VALUETAB|TXTTABL|A|0', values => 'DBTABLE|0003| | |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'VALUETAB|FLDNAME|A|0', values => 'FLDNAME|0004| | ||CHAR|30|30');
        self.insert-table($tabname, key => 'VALUETAB|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'VALUETAB|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'VALUETAB|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # APPLAREA
        self.insert-table($tabname, key => 'APPLAREA|APPAREA|A|0', values => 'APPAREA|0001|X| |APPLAREA|CHAR|30|30');
        self.insert-table($tabname, key => 'APPLAREA|LANGISO|A|0', values => 'LANGUAG|0002|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'APPLAREA|DESCRIP|A|0', values => 'LONGTXT|0003| | ||CHAR|60|60');
        self.insert-table($tabname, key => 'APPLAREA|CREATBY|A|0', values => 'CREATBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'APPLAREA|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'APPLAREA|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'APPLAREA|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # MESGTXTS
        self.insert-table($tabname, key => 'MESGTXTS|LANGISO|A|0', values => 'LANGUAG|0001|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'MESGTXTS|APPAREA|A|0', values => 'APPAREA|0002|X| |APPLAREA|CHAR|30|30');
        self.insert-table($tabname, key => 'MESGTXTS|MESGNUM|A|0', values => 'MESGNUM|0003|X| ||CHAR|3|3');
        self.insert-table($tabname, key => 'MESGTXTS|MESGTXT|A|0', values => 'MESGTXT|0004| | ||CHAR|73|73');
        self.insert-table($tabname, key => 'MESGTXTS|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'MESGTXTS|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'MESGTXTS|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # DDRELATE
        self.insert-table($tabname, key => 'DDRELATE|TABNAME|A|0', values => 'DBTABLE|0001|X| |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'DDRELATE|FLDNAME|A|0', values => 'FLDNAME|0002|X| ||CHAR|30|30');
        self.insert-table($tabname, key => 'DDRELATE|ACTVATD|A|0', values => 'ACTVATD|0003|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DDRELATE|VERSION|A|0', values => 'DDOVERS|0004|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DDRELATE|CHKTABL|A|0', values => 'CHKTABL|0005| | |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'DDRELATE|OBJRELA|A|0', values => 'OBJRELA|0006| | ||CHAR|4|4');
        self.insert-table($tabname, key => 'DDRELATE|LCRDNAL|A|0', values => 'LCRDNAL|0007| | ||CHAR|2|2');
        self.insert-table($tabname, key => 'DDRELATE|RCRDNAL|A|0', values => 'RCRDNAL|0008| | ||CHAR|2|2');
        self.insert-table($tabname, key => 'DDRELATE|APPAREA|A|0', values => 'APPAREA|0009| | |APPLAREA|CHAR|30|30');
        self.insert-table($tabname, key => 'DDRELATE|MESGNUM|A|0', values => 'MESGNUM|0010| | ||CHAR|3|3');
        self.insert-table($tabname, key => 'DDRELATE|CHKFLAG|A|0', values => 'RELCHKF|0011| | ||CHAR|1|1');
        self.insert-table($tabname, key => 'DDRELATE|CHANGBY|A|0', values => 'CHANGBY|0012| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DDRELATE|CHANGDT|A|0', values => 'CHANGDT|0013| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DDRELATE|CHANGTM|A|0', values => 'CHANGTM|0014| | ||CHAR|6|6');

        # DDRELATT
        self.insert-table($tabname, key => 'DDRELATT|TABNAME|A|0', values => 'DBTABLE|0001|X| |DBTABLES|CHAR|30|30');
        self.insert-table($tabname, key => 'DDRELATT|FLDNAME|A|0', values => 'FLDNAME|0002|X| ||CHAR|30|30');
        self.insert-table($tabname, key => 'DDRELATT|ACTVATD|A|0', values => 'ACTVATD|0003|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'DDRELATT|VERSION|A|0', values => 'DDOVERS|0004|X| |DDICVERS|CHAR|4|4');
        self.insert-table($tabname, key => 'DDRELATT|LANGISO|A|0', values => 'LANGUAG|0005|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'DDRELATT|DESCRIP|A|0', values => 'RELTEXT|0006| | ||CHAR|60|60');
        self.insert-table($tabname, key => 'DDRELATT|MESGTXT|A|0', values => 'RELMESG|0007| | ||CHAR|73|73');
        self.insert-table($tabname, key => 'DDRELATT|CHANGBY|A|0', values => 'CHANGBY|0008| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'DDRELATT|CHANGDT|A|0', values => 'CHANGDT|0009| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'DDRELATT|CHANGTM|A|0', values => 'CHANGTM|0010| | ||CHAR|6|6');

        # CLNTMSTR
        self.insert-table($tabname, key => 'CLNTMSTR|CLNTNUM|A|0', values => 'CLNTNUM|0001|X| |CLNTMSTR|CHAR|3|3');
        self.insert-table($tabname, key => 'CLNTMSTR|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'CLNTMSTR|CHANGBY|A|0', values => 'CHANGBY|0003| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'CLNTMSTR|CHANGDT|A|0', values => 'CHANGDT|0004| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'CLNTMSTR|CHANGTM|A|0', values => 'CHANGTM|0005| | ||CHAR|6|6');

        # CLNTMSTT
        self.insert-table($tabname, key => 'CLNTMSTT|CLNTNUM|A|0', values => 'CLNTNUM|0001|X| |CLNTMSTR|CHAR|3|3');
        self.insert-table($tabname, key => 'CLNTMSTT|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'CLNTMSTT|LANGISO|A|0', values => 'LANGUAG|0003|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'CLNTMSTT|DESCRIP|A|0', values => 'DESCRIP|0004| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'CLNTMSTT|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'CLNTMSTT|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'CLNTMSTT|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # CLNTUSER
        self.insert-table($tabname, key => 'CLNTUSER|CLNTNUM|A|0', values => 'CLNTNUM|0001|X| |CLNTMSTR|CHAR|3|3');
        self.insert-table($tabname, key => 'CLNTUSER|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'CLNTUSER|USERCOD|A|0', values => 'USERCOD|0003|X| |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'CLNTUSER|USRLOCK|A|0', values => 'USRLOCK|0004| | |LOGICALS|CHAR|1|1');
        self.insert-table($tabname, key => 'CLNTUSER|LANGISO|A|0', values => 'LANGUAG|0005| | |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'CLNTUSER|PASSWRD|A|0', values => 'PASSWRD|0006| | ||CHAR|64|64');
        self.insert-table($tabname, key => 'CLNTUSER|CHANGBY|A|0', values => 'CHANGBY|0007| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'CLNTUSER|CHANGDT|A|0', values => 'CHANGDT|0008| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'CLNTUSER|CHANGTM|A|0', values => 'CHANGTM|0009| | ||CHAR|6|6');

        # PROGTABL
        self.insert-table($tabname, key => 'PROGTABL|PROGRAM|A|0', values => 'PROGRAM|0001|X| |PROGTABL|CHAR|60|60');
        self.insert-table($tabname, key => 'PROGTABL|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'PROGTABL|PROGTXT|A|0', values => 'PROGTXT|0003| | ||CHAR|2|2');
        self.insert-table($tabname, key => 'PROGTABL|OBJTYPE|A|0', values => 'OBJTYPE|0004| | |OBJTYPES|CHAR|4|4');
        self.insert-table($tabname, key => 'PROGTABL|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'PROGTABL|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'PROGTABL|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # PROGTABT
        self.insert-table($tabname, key => 'PROGTABT|PROGRAM|A|0', values => 'PROGRAM|0001|X| |PROGTABL|CHAR|60|60');
        self.insert-table($tabname, key => 'PROGTABT|ACTVATD|A|0', values => 'ACTVATD|0002|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'PROGTABT|LANGISO|A|0', values => 'LANGUAG|0003|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'PROGTABT|DESCRIP|A|0', values => 'DESCRIP|0004| | ||CHAR|20|20');
        self.insert-table($tabname, key => 'PROGTABT|CHANGBY|A|0', values => 'CHANGBY|0005| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'PROGTABT|CHANGDT|A|0', values => 'CHANGDT|0006| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'PROGTABT|CHANGTM|A|0', values => 'CHANGTM|0007| | ||CHAR|6|6');

        # PROGTEXT
        self.insert-table($tabname, key => 'PROGTEXT|PROGRAM|A|0', values => 'PROGRAM|0001|X| |PROGTABL|CHAR|60|60');
        self.insert-table($tabname, key => 'PROGTEXT|PROGTXT|A|0', values => 'PROGTXT|0002|X| ||CHAR|2|2');
        self.insert-table($tabname, key => 'PROGTEXT|LANGISO|A|0', values => 'LANGUAG|0003|X| |ISOLANGU|CHAR|1|1');
        self.insert-table($tabname, key => 'PROGTEXT|MESSGID|A|0', values => 'MESSGID|0004|X| ||CHAR|4|4');
        self.insert-table($tabname, key => 'PROGTEXT|MESGTXT|A|0', values => 'MESGTXT|0005| | ||CHAR|254|254');
        self.insert-table($tabname, key => 'PROGTEXT|CHANGBY|A|0', values => 'CHANGBY|0006| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'PROGTEXT|CHANGDT|A|0', values => 'CHANGDT|0007| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'PROGTEXT|CHANGTM|A|0', values => 'CHANGTM|0008| | ||CHAR|6|6');

        # SHORTCUT
        self.insert-table($tabname, key => 'SHORTCUT|SHORTCT|A|0', values => 'SHORTCT|0001|X| |SHORTCUT|CHAR|20|20');
        self.insert-table($tabname, key => 'SHORTCUT|PROGRAM|A|0', values => 'PROGRAM|0002|X| |PROGTABL|CHAR|65|65');
        self.insert-table($tabname, key => 'SHORTCUT|ACTVATD|A|0', values => 'ACTVATD|0003|X| |STATCODE|CHAR|1|1');
        self.insert-table($tabname, key => 'SHORTCUT|CHANGBY|A|0', values => 'CHANGBY|0004| | |USERMSTR|CHAR|12|12');
        self.insert-table($tabname, key => 'SHORTCUT|CHANGDT|A|0', values => 'CHANGDT|0005| | ||CHAR|8|8');
        self.insert-table($tabname, key => 'SHORTCUT|CHANGTM|A|0', values => 'CHANGTM|0006| | ||CHAR|6|6');
      };

    
    method initialize-DBDOMAIN(Str :$tabname) {
        self.insert-table($tabname, key => 'DOMNAME|A|0', values => 'CHAR|30|30|0| | | | |DBDOMAIN');
        self.insert-table($tabname, key => 'DELEMNT|A|0', values => 'CHAR|30|30|0| | | | |DATAELEM');
        self.insert-table($tabname, key => 'DDOSTAT|A|0', values => 'CHAR|1|1|0| | | | |STATCODE');
        self.insert-table($tabname, key => 'DDOVERS|A|0', values => 'NUMR|4|4|0| | | | |DDICVERS');
        self.insert-table($tabname, key => 'LANGUAG|A|0', values => 'CHAR|1|1|0| | | | |ISOLANGU');
        self.insert-table($tabname, key => 'SHORTXT|A|0', values => 'CHAR|20|20|0|X| | | |');
        self.insert-table($tabname, key => 'MEDTEXT|A|0', values => 'CHAR|30|30|0|X| | | |');
        self.insert-table($tabname, key => 'LONGTXT|A|0', values => 'CHAR|60|60|0|X| | | |');
        self.insert-table($tabname, key => 'PROGRAM|A|0', values => 'CHAR|60|60|0|X| | | |PROGTABL');
        self.insert-table($tabname, key => 'SHORTCT|A|0', values => 'CHAR|20|20|0|X| | | |SHORTCUT');
        self.insert-table($tabname, key => 'DATATYP|A|0', values => 'CHAR|4|4|0| | | | |DATATYPE');
        self.insert-table($tabname, key => 'DBTABLE|A|0', values => 'CHAR|30|30|0| | | | |DBTABLES');
        self.insert-table($tabname, key => 'DIGIT01|A|0', values => 'NUMR|1|1|0| | | | |');
        self.insert-table($tabname, key => 'DIGIT02|A|0', values => 'NUMR|2|2|0| | | | |');
        self.insert-table($tabname, key => 'DIGIT03|A|0', values => 'NUMR|3|3|0| | | | |');
        self.insert-table($tabname, key => 'DIGIT04|A|0', values => 'NUMR|4|4|0| | | | |');
        self.insert-table($tabname, key => 'DIGIT06|A|0', values => 'NUMR|6|6|0| | | | |');
        self.insert-table($tabname, key => 'DIGIT10|A|0', values => 'NUMR|10|10|0| | | | |');
        self.insert-table($tabname, key => 'ALPHA01|A|0', values => 'CHAR|1|1|0| | | | |');
        self.insert-table($tabname, key => 'LOGICAL|A|0', values => 'CHAR|1|1|0| | | |X|LOGICALS');
        self.insert-table($tabname, key => 'BOOLEAN|A|0', values => 'CHAR|1|1|0| | | | |LOGICALS');
        self.insert-table($tabname, key => 'DATEYMD|A|0', values => 'DATM|8|8|0| | | | |');
        self.insert-table($tabname, key => 'DATECYR|A|0', values => 'NUMR|4|4|0| | | | |CALYEARS');
        self.insert-table($tabname, key => 'DAT6DMY|A|0', values => 'NUMR|6|6|0| | | | |');
        self.insert-table($tabname, key => 'DATETIM|A|0', values => 'TIME|6|6|0| | | | |');
        self.insert-table($tabname, key => 'TIME6HM|A|0', values => 'NUMR|4|4|0| | | | |');
        self.insert-table($tabname, key => 'FLDNAME|A|0', values => 'CHAR|30|30|0| | | | |');
        self.insert-table($tabname, key => 'USERCOD|A|0', values => 'CHAR|12|12|0| | | | |USERMSTR');
        self.insert-table($tabname, key => 'CLNTNUM|A|0', values => 'NUMR|3|3|0| | | | |CLNTMSTR');
        self.insert-table($tabname, key => 'TABLTYP|A|0', values => 'CHAR|1|1|0| | | | |TABLTYPE');
        self.insert-table($tabname, key => 'VERSION|A|0', values => 'NUMR|4|4|0| | | | |');
        self.insert-table($tabname, key => 'OBJTEXT|A|0', values => 'CHAR|254|254|0| | | | |');
        self.insert-table($tabname, key => 'OBJCODE|A|0', values => 'CHAR|60|60|0| | | | |');
        self.insert-table($tabname, key => 'PASSWRD|A|0', values => 'CHAR|64|64|0| | | | |');
        self.insert-table($tabname, key => 'DATEHMS|A|0', values => 'NUMR|14|14|0| | | | |');
        self.insert-table($tabname, key => 'ALPHA02|A|0', values => 'CHAR|2|2|0| | | | |');
        self.insert-table($tabname, key => 'DOMVALU|A|0', values => 'CHAR|10|10|0| | | | |');
        self.insert-table($tabname, key => 'APPAREA|A|0', values => 'CHAR|30|30|0| | | | |APPLAREA');
        self.insert-table($tabname, key => 'MESGTXT|A|0', values => 'CHAR|73|73|0|X| | | |');
        self.insert-table($tabname, key => 'DEPFCTR|A|0', values => 'NUMR|4|4|0| | | |X|');
        self.insert-table($tabname, key => 'LCRDNAL|A|0', values => 'NUMR|2|2|0| | | |X|');
        self.insert-table($tabname, key => 'RCRDNAL|A|0', values => 'NUMR|2|2|0| | | |X|');
        self.insert-table($tabname, key => 'CHKFLAG|A|0', values => 'CHAR|1|1|0| | | |X|');
        self.insert-table($tabname, key => 'CHAR060|A|0', values => 'CHAR|60|60|0| | | | |');
        self.insert-table($tabname, key => 'OBJTYPE|A|0', values => 'CHAR|4|4|0| | | | |OBJTYPES');
      }

    
    method initialize-DBDOMAIT(Str :$tabname) {
        self.insert-table($tabname, key => 'DOMNAME|A|0|E', values => 'Technical domain description');
        self.insert-table($tabname, key => 'DELEMNT|A|0|E', values => 'Data elements (semantic domain)');
        self.insert-table($tabname, key => 'DDOSTAT|A|0|E', values => 'Data dictionary object status');
        self.insert-table($tabname, key => 'DDOVERS|A|0|E', values => 'Data dictionary object version');
        self.insert-table($tabname, key => 'LANGUAG|A|0|E', values => 'ISO language code');
        self.insert-table($tabname, key => 'SHORTXT|A|0|E', values => 'Short text description');
        self.insert-table($tabname, key => 'MEDTEXT|A|0|E', values => 'Medium text description');
        self.insert-table($tabname, key => 'LONGTXT|A|0|E', values => 'Long text description');
        self.insert-table($tabname, key => 'PROGRAM|A|0|E', values => 'Source code name');
        self.insert-table($tabname, key => 'SHORTCT|A|0|E', values => 'Shortcut or transaction code');
        self.insert-table($tabname, key => 'DATATYP|A|0|E', values => 'Data types');
        self.insert-table($tabname, key => 'DBTABLE|A|0|E', values => 'Database tables');
        self.insert-table($tabname, key => 'DIGIT01|A|0|E', values => 'Numeric - 1 digit');
        self.insert-table($tabname, key => 'DIGIT02|A|0|E', values => 'Numeric - 2 digits');
        self.insert-table($tabname, key => 'DIGIT03|A|0|E', values => 'Numeric - 3 digits');
        self.insert-table($tabname, key => 'DIGIT04|A|0|E', values => 'Numeric - 4 digits');
        self.insert-table($tabname, key => 'DIGIT06|A|0|E', values => 'Numeric - 6 digits');
        self.insert-table($tabname, key => 'DIGIT10|A|0|E', values => 'Numeric - 10 digits');
        self.insert-table($tabname, key => 'ALPHA01|A|0|E', values => 'Alphabet');
        self.insert-table($tabname, key => 'LOGICAL|A|0|E', values => 'Logical values');
        self.insert-table($tabname, key => 'BOOLEAN|A|0|E', values => 'Logical values');
        self.insert-table($tabname, key => 'DATEYMD|A|0|E', values => 'Date - YYYYMMDD');
        self.insert-table($tabname, key => 'DATECYR|A|0|E', values => 'Date calander year - YYYY');
        self.insert-table($tabname, key => 'DAT6DMY|A|0|E', values => 'Date - DDMMYY');
        self.insert-table($tabname, key => 'DATETIM|A|0|E', values => 'Time - HHMMSS');
        self.insert-table($tabname, key => 'TIME6HM|A|0|E', values => 'Time - HHMM');
        self.insert-table($tabname, key => 'FLDNAME|A|0|E', values => 'Field name');
        self.insert-table($tabname, key => 'USERCOD|A|0|E', values => 'User master record');
        self.insert-table($tabname, key => 'CLNTNUM|A|0|E', values => 'Client number');
        self.insert-table($tabname, key => 'TABLTYP|A|0|E', values => 'Database table types');
        self.insert-table($tabname, key => 'VERSION|A|0|E', values => 'Version no.');
        self.insert-table($tabname, key => 'OBJTEXT|A|0|E', values => 'Text placeholder');
        self.insert-table($tabname, key => 'OBJCODE|A|0|E', values => 'Object texts value');
        self.insert-table($tabname, key => 'PASSWRD|A|0|E', values => 'Password');
        self.insert-table($tabname, key => 'DATEHMS|A|0|E', values => 'Date - YYYYMMDDHHMMSS');
        self.insert-table($tabname, key => 'ALPHA02|A|0|E', values => 'Alphabetic code (2 characters)');
        self.insert-table($tabname, key => 'DOMVALU|A|0|E', values => 'Domain value');
        self.insert-table($tabname, key => 'APPAREA|A|0|E', values => 'Application area');
        self.insert-table($tabname, key => 'MESGTXT|A|0|E', values => 'Message text');
        self.insert-table($tabname, key => 'DEPFCTR|A|0|E', values => 'Dependency factor');
        self.insert-table($tabname, key => 'LCRDNAL|A|0|E', values => 'Left side cardinality of relationship');
        self.insert-table($tabname, key => 'RCRDNAL|A|0|E', values => 'Right side cardinality of relationship');
        self.insert-table($tabname, key => 'CHKFLAG|A|0|E', values => 'Flag ("X" or "blank")');
        self.insert-table($tabname, key => 'CHAR060|A|0|E', values => 'String of 60 characters');
        self.insert-table($tabname, key => 'OBJTYPE|A|0|E', values => 'Object types');

      }

    
    method initialize-DATAELEM(Str :$tabname) {
        self.insert-table($tabname, key => 'DOMNAME|A|0', values => 'DOMNAME');
        self.insert-table($tabname, key => 'DELEMNT|A|0', values => 'DELEMNT');
        self.insert-table($tabname, key => 'DDOSTAT|A|0', values => 'DDOSTAT');
        self.insert-table($tabname, key => 'DDOVERS|A|0', values => 'DDOVERS');
        self.insert-table($tabname, key => 'DDHVERS|A|0', values => 'VERSION');
        self.insert-table($tabname, key => 'DDLVERS|A|0', values => 'VERSION');
        self.insert-table($tabname, key => 'LANGUAG|A|0', values => 'LANGUAG');
        self.insert-table($tabname, key => 'DESCRIP|A|0', values => 'SHORTXT');
        self.insert-table($tabname, key => 'SHORTXT|A|0', values => 'SHORTXT');
        self.insert-table($tabname, key => 'MEDTEXT|A|0', values => 'MEDTEXT');
        self.insert-table($tabname, key => 'LONGTXT|A|0', values => 'LONGTXT');
        self.insert-table($tabname, key => 'DATATYP|A|0', values => 'DATATYP');
        self.insert-table($tabname, key => 'DBTABLE|A|0', values => 'DBTABLE');
        self.insert-table($tabname, key => 'NUMBER6|A|0', values => 'DIGIT06');
        self.insert-table($tabname, key => 'LOGICAL|A|0', values => 'LOGICAL');
        self.insert-table($tabname, key => 'DATEYMD|A|0', values => 'DATEYMD');
        self.insert-table($tabname, key => 'DATETIM|A|0', values => 'DATETIM');
        self.insert-table($tabname, key => 'FLDNAME|A|0', values => 'FLDNAME');
        self.insert-table($tabname, key => 'FLDLENG|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'DECIMAL|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'FLDSPOS|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'USERCOD|A|0', values => 'USERCOD');
        self.insert-table($tabname, key => 'CLNTNUM|A|0', values => 'CLNTNUM');
        self.insert-table($tabname, key => 'TABLTYP|A|0', values => 'TABLTYP');
        self.insert-table($tabname, key => 'OBJTYPE|A|0', values => 'OBJTYPE');
        self.insert-table($tabname, key => 'BOOLEAN|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'ACTVATD|A|0', values => 'DDOSTAT');
        self.insert-table($tabname, key => 'CHANGBY|A|0', values => 'USERCOD');
        self.insert-table($tabname, key => 'CREATBY|A|0', values => 'USERCOD');
        self.insert-table($tabname, key => 'CHANGDT|A|0', values => 'DATEYMD');
        self.insert-table($tabname, key => 'CHANGTM|A|0', values => 'DATETIM');
        self.insert-table($tabname, key => 'TABNAME|A|0', values => 'DBTABLE');
        self.insert-table($tabname, key => 'CLNTDEP|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'LANGDEP|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'DISPLEN|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'DATALEN|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'LOWCASE|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'SIGNFLG|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'LANGFLG|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'VALTABL|A|0', values => 'DBTABLE');
        self.insert-table($tabname, key => 'PRIMKEY|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'NULLFLG|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'CHKTABL|A|0', values => 'DBTABLE');
        self.insert-table($tabname, key => 'INTTYPE|A|0', values => 'DATATYP');
        self.insert-table($tabname, key => 'INTLENG|A|0', values => 'DIGIT06');
        self.insert-table($tabname, key => 'DATADEC|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'USRLOCK|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'CONTFLG|A|0', values => 'ALPHA01');
        self.insert-table($tabname, key => 'FIXVALU|A|0', values => 'BOOLEAN');
        self.insert-table($tabname, key => 'LOVALUE|A|0', values => 'DOMVALU');
        self.insert-table($tabname, key => 'HIVALUE|A|0', values => 'DOMVALU');
        self.insert-table($tabname, key => 'DVALKEY|A|0', values => 'DIGIT04');
        self.insert-table($tabname, key => 'SLVALUE|A|0', values => 'DOMVALU');
        self.insert-table($tabname, key => 'APPAREA|A|0', values => 'APPAREA');
        self.insert-table($tabname, key => 'MESGNUM|A|0', values => 'DIGIT03');
        self.insert-table($tabname, key => 'MESGTXT|A|0', values => 'MESGTXT');
        self.insert-table($tabname, key => 'OBJRELA|A|0', values => 'DEPFCTR');
        self.insert-table($tabname, key => 'LCRDNAL|A|0', values => 'LCRDNAL');
        self.insert-table($tabname, key => 'RCRDNAL|A|0', values => 'RCRDNAL');
        self.insert-table($tabname, key => 'RELCHKF|A|0', values => 'CHKFLAG');
        self.insert-table($tabname, key => 'RELTEXT|A|0', values => 'CHAR060');
        self.insert-table($tabname, key => 'RELMESG|A|0', values => 'MESGTXT');
        self.insert-table($tabname, key => 'SHORTCT|A|0', values => 'SHORTCT');
        self.insert-table($tabname, key => 'PROGRAM|A|0', values => 'PROGRAM');
        self.insert-table($tabname, key => 'PROGTXT|A|0', values => 'ALPHA02');
        self.insert-table($tabname, key => 'PASSWRD|A|0', values => 'PASSWRD');
        self.insert-table($tabname, key => 'FIRSTNM|A|0', values => 'CHAR060');   
        self.insert-table($tabname, key => 'LASTNAM|A|0', values => 'CHAR060');
        self.insert-table($tabname, key => 'MESSGID|A|0', values => 'DIGIT04');
      }

    
    method initialize-DATAELET(Str :$tabname) {
        self.insert-table($tabname, key => 'DOMNAME|A|0|E', values => 'Domain name|Domain name|Domain name|Domain name');
        self.insert-table($tabname, key => 'DELEMNT|A|0|E', values => 'Data element|Data element|Data element|Data element');
        self.insert-table($tabname, key => 'DDOSTAT|A|0|E', values => 'DDO activation status|DDO activation status|DDO activation status|DDO activation status');
        self.insert-table($tabname, key => 'DDOVERS|A|0|E', values => 'Version|Version|Version|Version');
        self.insert-table($tabname, key => 'DDHVERS|A|0|E', values => 'Major version|Major version|Major version|Major version');
        self.insert-table($tabname, key => 'DDLVERS|A|0|E', values => 'Minor version|Minor version|Minor version|Minor version');
        self.insert-table($tabname, key => 'LANGUAG|A|0|E', values => 'Language|Language|Language|Language');
        self.insert-table($tabname, key => 'DESCRIP|A|0|E', values => 'Description|Description|Description|Description');
        self.insert-table($tabname, key => 'SHORTXT|A|0|E', values => 'Short text|Short text|Short text|Short text');
        self.insert-table($tabname, key => 'MEDTEXT|A|0|E', values => 'Medium text|Medium text|Medium text|Medium text');
        self.insert-table($tabname, key => 'LONGTXT|A|0|E', values => 'Long text|Long text|Long text|Long text');
        self.insert-table($tabname, key => 'DATATYP|A|0|E', values => 'Data type|Data type|Data type|Data type');
        self.insert-table($tabname, key => 'DBTABLE|A|0|E', values => 'Database table|Database table|Database table|Database table');
        self.insert-table($tabname, key => 'NUMBER6|A|0|E', values => 'Length (6 digits)|Length (6 digits)|Length (6 digits)|Length (6 digits)');
        self.insert-table($tabname, key => 'LOGICAL|A|0|E', values => 'Logical values|Logical values|Logical values|Logical values');
        self.insert-table($tabname, key => 'DATEYMD|A|0|E', values => 'Date - YYYYMMDD|Date - YYYYMMDD|Date - YYYYMMDD|Date - YYYYMMDD');
        self.insert-table($tabname, key => 'DATETIM|A|0|E', values => 'Time - HHMMSS|Time - HHMMSS|Time - HHMMSS|Time - HHMMSS');
        self.insert-table($tabname, key => 'FLDNAME|A|0|E', values => 'Field name|Field name|Field name|Field name');
        self.insert-table($tabname, key => 'FLDLENG|A|0|E', values => 'Field length|Field length|Field length|Field length');
        self.insert-table($tabname, key => 'DECIMAL|A|0|E', values => 'Precision|Precision|Precision|Precision');
        self.insert-table($tabname, key => 'FLDSPOS|A|0|E', values => 'Field position|Field position|Field position|Field position');
        self.insert-table($tabname, key => 'USERCOD|A|0|E', values => 'User id|User id|User id|User id');
        self.insert-table($tabname, key => 'CLNTNUM|A|0|E', values => 'Client number|Client number|Client number|Client number');
        self.insert-table($tabname, key => 'TABLTYP|A|0|E', values => 'Table type|Table type|Table type|Table type');
        self.insert-table($tabname, key => 'OBJTYPE|A|0|E', values => 'Object type|Object type|Object type|Object type');
        self.insert-table($tabname, key => 'BOOLEAN|A|0|E', values => 'Boolean values|Boolean values|Boolean values|Boolean values');
        self.insert-table($tabname, key => 'ACTVATD|A|0|E', values => 'Active|Active|Active|Active');
        self.insert-table($tabname, key => 'CHANGBY|A|0|E', values => 'Last change by|Last change by|Last change by|Last change by');
        self.insert-table($tabname, key => 'CREATBY|A|0|E', values => 'Created by|Created by|Created by|Created by');
        self.insert-table($tabname, key => 'CHANGDT|A|0|E', values => 'Last change on|Last change on|Last change on|Last change on');
        self.insert-table($tabname, key => 'CHANGTM|A|0|E', values => 'Last change at|Last change at|Last change at|Last change at');
        self.insert-table($tabname, key => 'TABNAME|A|0|E', values => 'Table name|Table name|Table name|Table name');
        self.insert-table($tabname, key => 'CLNTDEP|A|0|E', values => 'Client dependent|Client dependent|Client dependent|Client dependent');
        self.insert-table($tabname, key => 'LANGDEP|A|0|E', values => 'Language dependent|Language dependent|Language dependent|Language dependent');
        self.insert-table($tabname, key => 'DISPLEN|A|0|E', values => 'Display length|Display length|Display length|Display length');
        self.insert-table($tabname, key => 'DATALEN|A|0|E', values => 'Data length|Data length|Data length|Data length');
        self.insert-table($tabname, key => 'LOWCASE|A|0|E', values => 'Lower case|Lower case|Lower case|Lower case');
        self.insert-table($tabname, key => 'SIGNFLG|A|0|E', values => 'Sign flag|Sign flag|Sign flag|Sign flag');
        self.insert-table($tabname, key => 'LANGFLG|A|0|E', values => 'Language flag|Language flag|Language flag|Language flag');
        self.insert-table($tabname, key => 'VALTABL|A|0|E', values => 'Value table|Value table|Value table|Value table');
        self.insert-table($tabname, key => 'PRIMKEY|A|0|E', values => 'Primary key|Primary key|Primary key|Primary key');
        self.insert-table($tabname, key => 'NULLFLG|A|0|E', values => 'Not null|Not null|Not null|Not null');
        self.insert-table($tabname, key => 'CHKTABL|A|0|E', values => 'Check table|Check table|Check table|Check table');
        self.insert-table($tabname, key => 'INTTYPE|A|0|E', values => 'Internal data type|Internal data type|Internal data type|Internal data type');
        self.insert-table($tabname, key => 'INTLENG|A|0|E', values => 'Internal data length|Internal data length|Internal data length|Internal data length');
        self.insert-table($tabname, key => 'DATADEC|A|0|E', values => 'No of decimals|No of decimals|No of decimals|No of decimals');
        self.insert-table($tabname, key => 'USRLOCK|A|0|E', values => 'User id locked|User id locked|User id locked|User id locked');
        self.insert-table($tabname, key => 'CONTFLG|A|0|E', values => 'Delivery class|Delivery class|Delivery class|Delivery class');
        self.insert-table($tabname, key => 'FIXVALU|A|0|E', values => 'Fixed value exists|Fixed value exists|Fix value exists|Fix value exist');
        self.insert-table($tabname, key => 'LOVALUE|A|0|E', values => 'Lower limit value|Lower limit value|Lower limit value|Lower limit value');
        self.insert-table($tabname, key => 'HIVALUE|A|0|E', values => 'Higher limit value|Higher limit value|Higher limit value|Higher limit value');
        self.insert-table($tabname, key => 'DVALKEY|A|0|E', values => 'Domain value key|Domain value key|Domain value key|Domain value key');
        self.insert-table($tabname, key => 'SLVALUE|A|0|E', values => 'Single value|Single value|Single value|Single value');
        self.insert-table($tabname, key => 'APPAREA|A|0|E', values => 'Application area|Application area|Application area|Application area');
        self.insert-table($tabname, key => 'MESGNUM|A|0|E', values => 'Message number|Message number|Message number|Message number');
        self.insert-table($tabname, key => 'MESGTXT|A|0|E', values => 'Message text|Message text|Message text|Message text');
        self.insert-table($tabname, key => 'OBJRELA|A|0|E', values => 'Object relationship|Object relationship|Object relationship|Object relationship');
        self.insert-table($tabname, key => 'LCRDNAL|A|0|E', values => 'Left side cardinality|Left side cardinality|Left side cardinality|Left side cardinality');
        self.insert-table($tabname, key => 'RCRDNAL|A|0|E', values => 'Right side cardinality|Right side cardinality|Right side cardinality|Right side cardinality');
        self.insert-table($tabname, key => 'RELCHKF|A|0|E', values => 'No relationship check|No relationship check|No relationship check|No relationship check');
        self.insert-table($tabname, key => 'RELTEXT|A|0|E', values => 'Explanatory short text|Explanatory short text|Explanatory short text|Explanatory short text');
        self.insert-table($tabname, key => 'RELMESG|A|0|E', values => 'Msg for failed FK check|Msg for failed FK check|Msg for failed FK check|Message for failed FK check');
        self.insert-table($tabname, key => 'SHORTCT|A|0|E', values => 'Transaction code|Transaction code|Transaction code|Transaction code');
        self.insert-table($tabname, key => 'PROGRAM|A|0|E', values => 'Program name|Program name|Program name|Program name');
        self.insert-table($tabname, key => 'PROGTXT|A|0|E', values => 'Program text|Program text|Program text|Program text');
        self.insert-table($tabname, key => 'PASSWRD|A|0|E', values => 'Password|Password|Password|Password');
        self.insert-table($tabname, key => 'FIRSTNM|A|0|E', values => 'First name|First name|First name|First name');
        self.insert-table($tabname, key => 'LASTNAM|A|0|E', values => 'Last name|Last name|Last name|Last name');
        self.insert-table($tabname, key => 'MESSGID|A|0|E', values => 'Message no|Message no|Message no|Message no');
      }

    
    method initialize-STATCODE(Str :$tabname) {
        self.insert-table($tabname, key => 'A', values => '');
        self.insert-table($tabname, key => 'N', values => '');
        self.insert-table($tabname, key => 'I', values => '');
        self.insert-table($tabname, key => 'U', values => '');
        self.insert-table($tabname, key => 'R', values => '');
        self.insert-table($tabname, key => 'D', values => '');
      }

    
    method initialize-STATCODT(Str :$tabname) {
        self.insert-table($tabname, key => 'A|E', values => 'Active');
        self.insert-table($tabname, key => 'N|E', values => 'New');
        self.insert-table($tabname, key => 'I|E', values => 'Inactive');
        self.insert-table($tabname, key => 'U|E', values => 'Unknown');
        self.insert-table($tabname, key => 'R|E', values => 'Revised');
        self.insert-table($tabname, key => 'D|E', values => 'Deleted');

      }

    
    method initialize-DDICVERS(Str :$tabname) {
        self.insert-table($tabname, key => '0', values => '0|0');
      }

    
    method initialize-VERSTEXT(Str :$tabname) {
        self.insert-table($tabname, key => '0|E', values => 'Original');
      }

    
    method initialize-ISOLANGU(Str :$tabname) {
        self.insert-table($tabname, key => 'E', values => 'English');
      }

    
    method initialize-LOGICALS(Str :$tabname) {
        self.insert-table($tabname, key => 'Y', values => '');
        self.insert-table($tabname, key => 'N', values => '');
        self.insert-table($tabname, key => 'T', values => '');
        self.insert-table($tabname, key => 'F', values => '');
        self.insert-table($tabname, key => 'X', values => '');
        self.insert-table($tabname, key => ' ', values => '');
        self.insert-table($tabname, key => '1', values => '');
        self.insert-table($tabname, key => '0', values => '');
      }

    
    method initialize-BOOLEANS(Str :$tabname) {
        self.insert-table($tabname, key => 'Y|E', values => 'Yes');
        self.insert-table($tabname, key => 'N|E', values => 'No');
        self.insert-table($tabname, key => 'T|E', values => 'True');
        self.insert-table($tabname, key => 'F|E', values => 'False');
        self.insert-table($tabname, key => 'X|E', values => 'True');
        self.insert-table($tabname, key => ' |E', values => 'False');
        self.insert-table($tabname, key => '1|E', values => 'Logical True');
        self.insert-table($tabname, key => '0|E', values => 'Logical False');

      }

    
    method initialize-DATATYPE(Str :$tabname) {
        self.insert-table($tabname, key => 'CHAR', values => 'Character');
        self.insert-table($tabname, key => 'NUMR', values => 'Numeric');
        self.insert-table($tabname, key => 'DECI', values => 'Decimals');
        self.insert-table($tabname, key => 'CURR', values => 'Currency');
        self.insert-table($tabname, key => 'BOOL', values => 'Boolean');
        self.insert-table($tabname, key => 'DATM', values => 'Date as YYYYMMDD');
        self.insert-table($tabname, key => 'TIME', values => 'Time as HHMMSS');

      }

    
    method initialize-TABLTYPE(Str :$tabname) {
        self.insert-table($tabname, key => 'T', values => '');
        self.insert-table($tabname, key => 'I', values => '');
      }

    
    method initialize-TABLTYPT(Str :$tabname) {
        self.insert-table($tabname, key => 'T|E', values => 'Table');
        self.insert-table($tabname, key => 'I|E', values => 'Index');
      }

    
    method initialize-OBJTYPES(Str :$tabname) {
        self.insert-table($tabname, key => 'WEBA', values => '');
        self.insert-table($tabname, key => 'WEBC', values => '');
      }

    
    method initialize-OBJTYPET(Str :$tabname) {
        self.insert-table($tabname, key => 'WEBA|E', values => 'Web app - generic application');
        self.insert-table($tabname, key => 'WEBC|E', values => 'Web app with form control');
      }

    
    method initialize-USERMSTR(Str :$tabname) {
        self.insert-table($tabname, key => 'SYSTEM|A', values => 'System|System');
      }

    
    method initialize-CLNTMSTR(Str :$tabname) {
        self.insert-table($tabname, key => '000|A', values => '');
      }

    
    method initialize-CLNTMSTT(Str :$tabname) {
        self.insert-table($tabname, key => '000|A|E', values => 'Template client');
      }

    
    method initialize-CLNTUSER(Str :$tabname) {
        self.insert-table($tabname, key => '000|A|SYSTEM', values => '0|E|1a1dc91c907325c69271ddf0c944bc72');
      }

    
    method initialize-APPLAREA(Str :$tabname) {
        self.insert-table($tabname, key => 'SY|E', values => 'System - Core Components|SYSTEM');
        self.insert-table($tabname, key => 'SY-DDIC|E', values => 'System - Data dictionary|SYSTEM');
      }

    
    method initialize-PROGTABL(Str :$tabname) {
        self.insert-table($tabname, key => 'DataBrowser|A', values => 'D1|WEBC'); 
        self.insert-table($tabname, key => 'TestProgram|A', values => 'T9|WEBC'); 
        self.insert-table($tabname, key => 'UserManager|A', values => 'U1|WEBC');
        self.insert-table($tabname, key => 'HomePage|A', values => 'S2|WEBC'); 
        self.insert-table($tabname, key => 'WikiPage|A', values => 'W1|WEBC'); 
        self.insert-table($tabname, key => 'Shortcut|A', values => 'S3|WEBC'); 
        self.insert-table($tabname, key => 'HelloWorld|A', values => 'H1|WEBA'); 
      }

    
    method initialize-PROGTABT(Str :$tabname) {
        self.insert-table($tabname, key => 'DataBrowser|A|E', values => 'Database table browser');
        self.insert-table($tabname, key => 'TestProgram|A|E', values => 'Test program - safe to delete');
        self.insert-table($tabname, key => 'UserManager|A|E', values => 'User Login Session'); 
        self.insert-table($tabname, key => 'HomePage|A|E', values => 'Default front page');
        self.insert-table($tabname, key => 'WikiPage|A|E', values => 'Wiki page application');
        self.insert-table($tabname, key => 'Shortcut|A|E', values => 'Program shortcuts');
        self.insert-table($tabname, key => 'HelloWorld|A|E', values => 'Demo program');
      }

    
    method initialize-SHORTCUT(Str :$tabname) {
        self.insert-table($tabname, key => 'SCUT|Shortcut|A', values => 'Shortcut module');
        self.insert-table($tabname, key => 'HELO|HelloWorld|A', values => 'Test program - Hello world');
        self.insert-table($tabname, key => 'DATA|DataBrowser|A', values => 'Database table browser');
        self.insert-table($tabname, key => 'TEST|TestProgram|A', values => 'Testing program - safe to delete');
        self.insert-table($tabname, key => 'USER|UserManager|A', values => 'User login manager');
        self.insert-table($tabname, key => 'HOME|HomePage|A', values => 'Home front page');
        self.insert-table($tabname, key => 'WIKI|WikiPage|A', values => 'Wiki page application');
      }

    
    method initialize-DDRELATE(Str :$tabname) {

      self.insert-table($tabname, key => 'DBTABLET|TABNAME|A|0', values => 'DBTABLES|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'STATCODT|STATCOD|A|0', values => 'STATCODE|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'VERSTEXT|VERSION|A|0', values => 'DDICVERS|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLTYPT|TABLTYP|A|0', values => 'TABLTYPE|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIT|DOMNAME|A|0', values => 'DBDOMAIN|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELET|DELEMNT|A|0', values => 'DATAELEM|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATT|FLDNAME|A|0', values => 'DDRELATE|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTMSTT|CLNTNUM|A|0', values => 'CLNTMSTR|KEY|1|CN|SY_DDIC| |');

      # DBTABLES-key
      self.insert-table($tabname, key => 'DBTABLES|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLES|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLES|TABLTYP|A|0', values => 'TABLTYPE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLES|CLNTDEP|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLES|LANGDEP|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLES|CONTFLG|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLES|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DBTABLET-key
      self.insert-table($tabname, key => 'DBTABLET|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLET|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLET|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBTABLET|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # ISOLANGU-key
      self.insert-table($tabname, key => 'ISOLANGU|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DDICTEXT-key
      self.insert-table($tabname, key => 'DDICTEXT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDICTEXT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # TABLETYPE-key
      self.insert-table($tabname, key => 'TABLTYPE|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # TABLETYPT-key
      self.insert-table($tabname, key => 'TABLTYPT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLTYPT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # LOGICALS-key
      self.insert-table($tabname, key => 'LOGICALS|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # BOOLEANS-key
      self.insert-table($tabname, key => 'BOOLEANS|CODENAM|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'BOOLEANS|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'BOOLEANS|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # VERSTEXT-key
      self.insert-table($tabname, key => 'VERSTEXT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'VERSTEXT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DDICVERS-key
      self.insert-table($tabname, key => 'DDICVERS|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # STATCODE-key
      self.insert-table($tabname, key => 'STATCODE|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # STATCODT-key
      self.insert-table($tabname, key => 'STATCODT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # USERMSTR-key
      self.insert-table($tabname, key => 'USERMSTR|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');

      # DBDOMAIN-key
      self.insert-table($tabname, key => 'DBDOMAIN|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|DATATYP|A|0', values => 'DATATYPE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|LOWCASE|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|SIGNFLG|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|LANGFLG|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|FIXVALU|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|VALTABL|A|0', values => 'DBTABLES|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIN|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DBDOMAIT-key
      self.insert-table($tabname, key => 'DBDOMAIT|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIT|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DBDOMAIT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DATAELEM-key
      self.insert-table($tabname, key => 'DATAELEM|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELEM|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELEM|DOMNAME|A|0', values => 'DBDOMAIN|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELEM|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DATAELET-key
      self.insert-table($tabname, key => 'DATAELET|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELET|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELET|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DATAELET|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DATATYPE-key
      self.insert-table($tabname, key => 'DATATYPE|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # TABLFLDS-key
      self.insert-table($tabname, key => 'TABLFLDS|TABNAME|A|0', values => 'DBTABLES|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|DELEMNT|A|0', values => 'DATAELEM|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|PRIMKEY|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|NULLFLG|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|CHKTABL|A|0', values => 'DBTABLES|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|INTTYPE|A|0', values => 'DATATYPE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'TABLFLDS|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # APPLAREA-key
      self.insert-table($tabname, key => 'APPLAREA|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'APPLAREA|CREATBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'APPLAREA|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # MESGTXTS-key
      self.insert-table($tabname, key => 'MESGTXTS|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'MESGTXTS|APPAREA|A|0', values => 'APPLAREA|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'MESGTXTS|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # CLNTMSTR-key
      self.insert-table($tabname, key => 'CLNTMSTR|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTMSTR|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # CLNTMSTT-key
      self.insert-table($tabname, key => 'CLNTMSTT|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTMSTT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTMSTT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # CLNTUSER-key
      self.insert-table($tabname, key => 'CLNTUSER|CLNTNUM|A|0', values => 'CLNTMSTR|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTUSER|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTUSER|USERCOD|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTUSER|USRLOCK|A|0', values => 'LOGICALS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'CLNTUSER|LANGUAG|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');

      # DOMVALUE-key
      self.insert-table($tabname, key => 'DOMVALUE|DOMNAME|A|0', values => 'DBDOMAIN|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUE|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUE|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUE|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DOMVALUT-key
      self.insert-table($tabname, key => 'DOMVALUT|DOMNAME|A|0', values => 'DOMVALUE|KEY|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUT|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUT|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DOMVALUT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');

      # DDRELATE-key
      self.insert-table($tabname, key => 'DDRELATE|TABNAME|A|0', values => 'DBTABLES|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATE|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATE|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATE|CHKTABL|A|0', values => 'DBTABLES|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATE|APPAREA|A|0', values => 'APPLAREA|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATE|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

      # DDRELATT-key
      self.insert-table($tabname, key => 'DDRELATT|TABNAME|A|0', values => 'DBTABLES|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATT|ACTVATD|A|0', values => 'STATCODE|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATT|VERSION|A|0', values => 'DDICVERS|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATT|LANGISO|A|0', values => 'ISOLANGU|REF|1|CN|SY_DDIC| |');
      self.insert-table($tabname, key => 'DDRELATT|CHANGBY|A|0', values => 'USERMSTR|REF|1|CN|SY_DDIC| |');

    }

    
    method initialize-DDRELATT(Str :$tabname) {
            
        self.insert-table($tabname, key => 'DBTABLET|TABNAME|A|0|E', values => 'Text for table headers|');
        self.insert-table($tabname, key => 'STATCODT|STATCOD|A|0|E', values => 'Text for status codes|');
        self.insert-table($tabname, key => 'VERSTEXT|VERSION|A|0|E', values => 'Text for version numbers|');
        self.insert-table($tabname, key => 'TABLTYPT|TABLTYP|A|0|E', values => 'Text for table types|');
        self.insert-table($tabname, key => 'DBDOMAIT|DOMNAME|A|0|E', values => 'Text for domains|');
        self.insert-table($tabname, key => 'DATAELET|DELEMNT|A|0|E', values => 'Text for data elements|');
        self.insert-table($tabname, key => 'DDRELATT|FLDNAME|A|0|E', values => 'Text for relationships|');
        self.insert-table($tabname, key => 'CLNTMSTT|CLNTNUM|A|0|E', values => 'Text for clients|');

        # DBTABLES-text
        self.insert-table($tabname, key => 'DBTABLES|ACTVATD|A|0|E', values => 'table - activation status|');
        self.insert-table($tabname, key => 'DBTABLES|VERSION|A|0|E', values => 'table - version|');
        self.insert-table($tabname, key => 'DBTABLES|TABLTYP|A|0|E', values => 'table - table type|');
        self.insert-table($tabname, key => 'DBTABLES|CLNTDEP|A|0|E', values => 'table - client dependent|');
        self.insert-table($tabname, key => 'DBTABLES|LANGDEP|A|0|E', values => 'table - language dependent|');
        self.insert-table($tabname, key => 'DBTABLES|CONTFLG|A|0|E', values => 'table - content flag|');
        self.insert-table($tabname, key => 'DBTABLES|CHANGBY|A|0|E', values => 'table - user (change by)|');

        # DBTABLET-text
        self.insert-table($tabname, key => 'DBTABLET|ACTVATD|A|0|E', values => 'table text - activation status|');
        self.insert-table($tabname, key => 'DBTABLET|VERSION|A|0|E', values => 'table text - version|');
        self.insert-table($tabname, key => 'DBTABLET|LANGISO|A|0|E', values => 'table text - language|');
        self.insert-table($tabname, key => 'DBTABLET|CHANGBY|A|0|E', values => 'table text - user (change by)|');

        # ISOLANGU-text
        self.insert-table($tabname, key => 'ISOLANGU|CHANGBY|A|0|E', values => 'language - user (change by)|');

        # DDICTEXT-text
        self.insert-table($tabname, key => 'DDICTEXT|LANGISO|A|0|E', values => 'string text - language|');
        self.insert-table($tabname, key => 'DDICTEXT|CHANGBY|A|0|E', values => 'string text - user (change by)|');

        # TABLETYPE-text
        self.insert-table($tabname, key => 'TABLTYPE|CHANGBY|A|0|E', values => 'table type - user (change by)|');

        # TABLETYPT-text
        self.insert-table($tabname, key => 'TABLTYPT|LANGISO|A|0|E', values => 'table type text - language|');
        self.insert-table($tabname, key => 'TABLTYPT|CHANGBY|A|0|E', values => 'table type text - user (change by)|');

        # LOGICALS-text
        self.insert-table($tabname, key => 'LOGICALS|CHANGBY|A|0|E', values => 'table:logical- user (change by)|');

        # BOOLEANS-text
        self.insert-table($tabname, key => 'BOOLEANS|CODENAM|A|0|E', values => 'Logical values|');
        self.insert-table($tabname, key => 'BOOLEANS|LANGISO|A|0|E', values => 'boolean text - language|');
        self.insert-table($tabname, key => 'BOOLEANS|CHANGBY|A|0|E', values => 'boolean text - user (change by)|');

        # VERSTEXT-text
        self.insert-table($tabname, key => 'VERSTEXT|LANGISO|A|0|E', values => 'version text - language|');
        self.insert-table($tabname, key => 'VERSTEXT|CHANGBY|A|0|E', values => 'version text - user (change by)|');

        # DDICVERS-text
        self.insert-table($tabname, key => 'DDICVERS|CHANGBY|A|0|E', values => 'version - user (change by)|');

        # STATCODE-text
        self.insert-table($tabname, key => 'STATCODE|CHANGBY|A|0|E', values => 'status code - user (change by)|');

        # STATCODT-text
        self.insert-table($tabname, key => 'STATCODT|CHANGBY|A|0|E', values => 'status code text - user (change by)|');

        # USERMSTR-text
        self.insert-table($tabname, key => 'USERMSTR|ACTVATD|A|0|E', values => 'user master - activation status|');

        # DBDOMAIN-text
        self.insert-table($tabname, key => 'DBDOMAIN|ACTVATD|A|0|E', values => 'domain - activation status|');
        self.insert-table($tabname, key => 'DBDOMAIN|VERSION|A|0|E', values => 'domain - version|');
        self.insert-table($tabname, key => 'DBDOMAIN|DATATYP|A|0|E', values => 'domain - version|');
        self.insert-table($tabname, key => 'DBDOMAIN|LOWCASE|A|0|E', values => 'domain - lowcase flag|');
        self.insert-table($tabname, key => 'DBDOMAIN|SIGNFLG|A|0|E', values => 'domain - sign flag|');
        self.insert-table($tabname, key => 'DBDOMAIN|LANGFLG|A|0|E', values => 'domain - language flag|');
        self.insert-table($tabname, key => 'DBDOMAIN|FIXVALU|A|0|E', values => 'domain - fix values flag|');
        self.insert-table($tabname, key => 'DBDOMAIN|VALTABL|A|0|E', values => 'domain - check table|');
        self.insert-table($tabname, key => 'DBDOMAIN|CHANGBY|A|0|E', values => 'domain - user (change by)|');

        # DBDOMAIT-text
        self.insert-table($tabname, key => 'DBDOMAIT|ACTVATD|A|0|E', values => 'domain text - activation status|');
        self.insert-table($tabname, key => 'DBDOMAIT|VERSION|A|0|E', values => 'domain text - version|');
        self.insert-table($tabname, key => 'DBDOMAIT|LANGISO|A|0|E', values => 'domain text - language|');
        self.insert-table($tabname, key => 'DBDOMAIT|CHANGBY|A|0|E', values => 'domain text - user (change by)|');

        # DATAELEM-text
        self.insert-table($tabname, key => 'DATAELEM|ACTVATD|A|0|E', values => 'data element - activation status|');
        self.insert-table($tabname, key => 'DATAELEM|VERSION|A|0|E', values => 'data element - version|');
        self.insert-table($tabname, key => 'DATAELEM|DOMNAME|A|0|E', values => 'data element - domain|');
        self.insert-table($tabname, key => 'DATAELEM|CHANGBY|A|0|E', values => 'data element - user (change by)|');

        # DATAELET-text
        self.insert-table($tabname, key => 'DATAELET|ACTVATD|A|0|E', values => 'data element text - activation status|');
        self.insert-table($tabname, key => 'DATAELET|VERSION|A|0|E', values => 'data element text - version|');
        self.insert-table($tabname, key => 'DATAELET|LANGISO|A|0|E', values => 'data element text - language|');
        self.insert-table($tabname, key => 'DATAELET|CHANGBY|A|0|E', values => 'data element text - user (change by)|');

        # DATATYPE-text
        self.insert-table($tabname, key => 'DATATYPE|CHANGBY|A|0|E', values => 'data type - user (change by)|');

        # TABLFLDS-text
        self.insert-table($tabname, key => 'TABLFLDS|TABNAME|A|0|E', values => 'table field - tables|');
        self.insert-table($tabname, key => 'TABLFLDS|ACTVATD|A|0|E', values => 'table field - activation status|');
        self.insert-table($tabname, key => 'TABLFLDS|DELEMNT|A|0|E', values => 'table field - version|');
        self.insert-table($tabname, key => 'TABLFLDS|PRIMKEY|A|0|E', values => 'table field pkey - logical|');
        self.insert-table($tabname, key => 'TABLFLDS|NULLFLG|A|0|E', values => 'table field null - logical|');
        self.insert-table($tabname, key => 'TABLFLDS|CHKTABL|A|0|E', values => 'table field chk table - tables|');
        self.insert-table($tabname, key => 'TABLFLDS|INTTYPE|A|0|E', values => 'table field - data type|');
        self.insert-table($tabname, key => 'TABLFLDS|CHANGBY|A|0|E', values => 'table field - user (change by)|');

        # APPLAREA-text
        self.insert-table($tabname, key => 'APPLAREA|LANGISO|A|0|E', values => 'app area  - language|');
        self.insert-table($tabname, key => 'APPLAREA|CREATBY|A|0|E', values => 'app area - create by|');
        self.insert-table($tabname, key => 'APPLAREA|CHANGBY|A|0|E', values => 'app area - user (create by)|');

        # MESGTXTS-text
        self.insert-table($tabname, key => 'MESGTXTS|LANGISO|A|0|E', values => 'mesg text - language|');
        self.insert-table($tabname, key => 'MESGTXTS|APPAREA|A|0|E', values => 'mesg text - app area|');
        self.insert-table($tabname, key => 'MESGTXTS|CHANGBY|A|0|E', values => 'mesg text - user (change by)|');

        # CLNTMSTR-text
        self.insert-table($tabname, key => 'CLNTMSTR|ACTVATD|A|0|E', values => 'client - activation status|');
        self.insert-table($tabname, key => 'CLNTMSTR|CHANGBY|A|0|E', values => 'client - user (change by)|');

        # CLNTMSTT-text
        self.insert-table($tabname, key => 'CLNTMSTT|ACTVATD|A|0|E', values => 'client text - activation status|');
        self.insert-table($tabname, key => 'CLNTMSTT|LANGISO|A|0|E', values => 'client text - language|');
        self.insert-table($tabname, key => 'CLNTMSTT|CHANGBY|A|0|E', values => 'client text - user (change by)|');

        # CLNTUSER-text
        self.insert-table($tabname, key => 'CLNTUSER|CLNTNUM|A|0|E', values => 'client users - client master|');
        self.insert-table($tabname, key => 'CLNTUSER|ACTVATD|A|0|E', values => 'client users - activation status|');
        self.insert-table($tabname, key => 'CLNTUSER|USERCOD|A|0|E', values => 'client users - user (change by)|');
        self.insert-table($tabname, key => 'CLNTUSER|USRLOCK|A|0|E', values => 'client users - lock status|');
        self.insert-table($tabname, key => 'CLNTUSER|LANGUAG|A|0|E', values => 'client users - language|');

        # DOMVALUE-text
        self.insert-table($tabname, key => 'DOMVALUE|DOMNAME|A|0|E', values => 'domain values - domain|');
        self.insert-table($tabname, key => 'DOMVALUE|ACTVATD|A|0|E', values => 'domain values - activation status|');
        self.insert-table($tabname, key => 'DOMVALUE|VERSION|A|0|E', values => 'domain values - version table|');
        self.insert-table($tabname, key => 'DOMVALUE|CHANGBY|A|0|E', values => 'domain values - user (change by)|');

        # DOMVALUT-text
        self.insert-table($tabname, key => 'DOMVALUT|DOMNAME|A|0|E', values => 'domain values text - domain|');
        self.insert-table($tabname, key => 'DOMVALUT|ACTVATD|A|0|E', values => 'domain values text - activation status|');
        self.insert-table($tabname, key => 'DOMVALUT|VERSION|A|0|E', values => 'domain values text - version table|');
        self.insert-table($tabname, key => 'DOMVALUT|CHANGBY|A|0|E', values => 'domain values text - user (change by)|');
        self.insert-table($tabname, key => 'DOMVALUT|LANGISO|A|0|E', values => 'domain values text - language|');

        # DDRELATE-text
        self.insert-table($tabname, key => 'DDRELATE|TABNAME|A|0|E', values => 'relationship - table|');
        self.insert-table($tabname, key => 'DDRELATE|ACTVATD|A|0|E', values => 'relationship - activation status|');
        self.insert-table($tabname, key => 'DDRELATE|VERSION|A|0|E', values => 'relationship - version table|');
        self.insert-table($tabname, key => 'DDRELATE|CHKTABL|A|0|E', values => 'relationship - check table|');
        self.insert-table($tabname, key => 'DDRELATE|APPAREA|A|0|E', values => 'relationship - app area|');
        self.insert-table($tabname, key => 'DDRELATE|CHANGBY|A|0|E', values => 'relationship - user (change by)|');

        # DDRELATT-text
        self.insert-table($tabname, key => 'DDRELATT|TABNAME|A|0|E', values => 'relationship text - table|');
        self.insert-table($tabname, key => 'DDRELATT|ACTVATD|A|0|E', values => 'relationship text - activation status|');
        self.insert-table($tabname, key => 'DDRELATT|VERSION|A|0|E', values => 'relationship text - version table|');
        self.insert-table($tabname, key => 'DDRELATT|LANGISO|A|0|E', values => 'relationship text - language|');
        self.insert-table($tabname, key => 'DDRELATT|CHANGBY|A|0|E', values => 'relationship text - user (change by)|');

      }

    
    method initialize-MESGTXTS(Str :$tabname) {
        self.insert-table($tabname, key => 'E|SY|001', values => 'This is sample message &1.');     
      }

    
    #-------- BEGIN: DATABASE utilities (not auto-generated)  

    
    method db-connect(Str :$dbtype, :$dbname) {
        my Str $db-path = '';
        my $db-file = '';
        $db-file = $dbname.IO.resolve;
        $db-path = self.get(key => 'DATA_DIR')
                  ~ '/' 
                  ~ self.get(key => 'SID')
                  ~ self.get(key => 'SID_NR')
                  ~ '/' 
                  ~ self.get(key => 'SID')
                  ~ self.get(key => 'SID_NR')
                  ~ '.db';

        self.create-directory(path => $db-path);

        my $dbh = DBIish.connect($dbtype, database => $db-file); 
        return $dbh;
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

    
    method db-create-table(Str :$tabname, Str :$descrip, Str :$sql, Str :$language = 'E') {
        
        my Str $db-file = self.db-filename(dbtype => $C_DBTYPE_SQLITE);
        #self.TRACE: $db-file;
        #self.TRACE: $sql;
        
        my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
        if defined $dbh {
          #-- query SQLITE_MASTER for table DBTABLES
          my $sth = $dbh.prepare(qq:to/SQL/);
            SELECT name FROM SQLITE_MASTER WHERE name = 'DBTABLES'
          SQL
          $sth.execute;
          
          my @iTable = $sth.fetchall-AoH;

          if (@iTable.elems) {
            #self.TRACE: 'Table ' ~ $tabname.uc ~ ' already exists';
            
            #-- Query DBTABLES if tabname is registered
            $sth = $dbh.prepare(qq:to/SQL/);
              SELECT tabname
              FROM dbtables
              WHERE tabname = '$tabname' AND
                    actvatd = 'A' AND
                    tabltyp = 'T'
              SQL

            $sth.execute;
            @iTable = $sth.fetchall-AoH;
            
            $sth.finish;

            if (@iTable.elems) {
              #-- Table already registered in DBTABLES, then DO NOTHING
              #self.TRACE: $tabname ~ ' alreay exists, do nothing';
            }
            else {
              if $tabname eq 'DBTABLET' {

                #-- Create DBTABLET
                #self.TRACE: $sql;
                $dbh.do($sql);

                #-- Register DBTABLES into DBTABLET

                my Str $date = self.system-date();
                my Str $time = self.system-time();

                my %wDBTABLET = ();
                my @iDBTABLET = ();

                %wDBTABLET = self.structure( fields => [
                        'tabname', 'actvatd', 'version', 'langiso', 'shortxt',
                        'changby', 'changdt', 'changtm'  
                        ]);

                %wDBTABLET<tabname> = 'DBTABLES';
                %wDBTABLET<actvatd> = 'A';
                %wDBTABLET<version> = '0';
                %wDBTABLET<langiso> = 'E';
                %wDBTABLET<shortxt> = 'Database table';
                %wDBTABLET<changby> = 'SYSTEM';
                %wDBTABLET<changdt> = $date;
                %wDBTABLET<changtm> = $time;

                self.append-table(@iDBTABLET, %wDBTABLET);
                my Str $sql-insert = self.db-insert(table => $tabname, data => @iDBTABLET);

                $dbh.do($sql-insert);

                
                #-- Register DBTABLET into DBTABLES

                my %wDBTABLES = ();
                my @iDBTABLES = ();

                %wDBTABLES = self.structure( fields => [
                        'tabname', 'actvatd', 'version', 'tabltyp', 'clntdep',
                        'langdep', 'contflg', 'changby', 'changdt', 'changtm'  
                        ]);

                %wDBTABLES<tabname> = 'DBTABLET';
                %wDBTABLES<actvatd> = 'A';
                %wDBTABLES<version> = '0';
                %wDBTABLES<tabltyp> = 'T';
                %wDBTABLES<clntdep> = '';
                %wDBTABLES<langdep> = '';
                %wDBTABLES<contflg> = 'S';
                %wDBTABLES<changby> = 'SYSTEM';
                %wDBTABLES<changdt> = $date;
                %wDBTABLES<changtm> = $time;

                self.append-table(@iDBTABLES, %wDBTABLES);
                $sql-insert = self.db-insert(table => 'DBTABLES', data => @iDBTABLES);
                #self.TRACE: $sql-insert;
                $dbh.do($sql-insert);

                #-- Register DBTABLET into DBTABLET

                %wDBTABLET = ();
                @iDBTABLET = ();

                %wDBTABLET = self.structure( fields => [
                        'tabname', 'actvatd', 'version', 'langiso', 'shortxt',
                        'changby', 'changdt', 'changtm'  
                        ]);

                %wDBTABLET<tabname> = 'DBTABLET';
                %wDBTABLET<actvatd> = 'A';
                %wDBTABLET<version> = '0';
                %wDBTABLET<langiso> = 'E';
                %wDBTABLET<shortxt> = 'Database table description';
                %wDBTABLET<changby> = 'SYSTEM';
                %wDBTABLET<changdt> = $date;
                %wDBTABLET<changtm> = $time;

                self.append-table(@iDBTABLET, %wDBTABLET);
                $sql-insert = self.db-insert(table => $tabname, data => @iDBTABLET);
                $dbh.do($sql-insert);

              }
              else {
                #-- Table is not DBTABLET
                $dbh.do($sql);
                #self.TRACE: $sql;

                #-- Register <TABNAME> into DBTABLES
                my Str $date = self.system-date();
                my Str $time = self.system-time();

                my %wDBTABLES = ();
                my @iDBTABLES = ();

                %wDBTABLES = self.structure( fields => [
                        'tabname', 'actvatd', 'version', 'tabltyp', 'clntdep',
                        'langdep', 'contflg', 'changby', 'changdt', 'changtm'  
                        ]);

                %wDBTABLES<tabname> = $tabname;
                %wDBTABLES<actvatd> = 'A';
                %wDBTABLES<version> = '0';
                %wDBTABLES<tabltyp> = 'T';
                %wDBTABLES<clntdep> = '';
                %wDBTABLES<langdep> = '';
                %wDBTABLES<contflg> = 'S';
                %wDBTABLES<changby> = 'SYSTEM';
                %wDBTABLES<changdt> = $date;
                %wDBTABLES<changtm> = $time;

                self.append-table(@iDBTABLES, %wDBTABLES);
                my $sql-insert = self.db-insert(table => 'DBTABLES', data => @iDBTABLES);
                #self.TRACE: $sql-insert;
                $dbh.do($sql-insert);

                #-- Register <TABNAME> into DBTABLET

                my %wDBTABLET = ();
                my @iDBTABLET = ();

                %wDBTABLET = self.structure( fields => [
                        'tabname', 'actvatd', 'version', 'langiso', 'shortxt',
                        'changby', 'changdt', 'changtm'  
                        ]);

                %wDBTABLET<tabname> = $tabname;
                %wDBTABLET<actvatd> = 'A';
                %wDBTABLET<version> = '0';
                %wDBTABLET<langiso> = 'E';
                %wDBTABLET<shortxt> = $descrip;
                %wDBTABLET<changby> = 'SYSTEM';
                %wDBTABLET<changdt> = $date;
                %wDBTABLET<changtm> = $time;

                self.append-table(@iDBTABLET, %wDBTABLET);
                $sql-insert = self.db-insert(table => 'DBTABLET', data => @iDBTABLET);
                $dbh.do($sql-insert);

              }
            }
          }
          else {
            #self.TRACE: 'Table ' ~ $tabname.uc ~ ' NOT FOUND';
            my Str $date = self.system-date();
            my Str $time = self.system-time();

            my %wDBTABLES = ();
            my @iDBTABLES = ();

            %wDBTABLES = self.structure( fields => [
                    'tabname', 'actvatd', 'version', 'tabltyp', 'clntdep',
                    'langdep', 'contflg', 'changby', 'changdt', 'changtm'  
                    ]);

            %wDBTABLES<tabname> = $tabname;
            %wDBTABLES<actvatd> = 'A';
            %wDBTABLES<version> = '0';
            %wDBTABLES<tabltyp> = 'T';
            %wDBTABLES<clntdep> = '';
            %wDBTABLES<langdep> = '';
            %wDBTABLES<contflg> = 'S';
            %wDBTABLES<changby> = 'SYSTEM';
            %wDBTABLES<changdt> = $date;
            %wDBTABLES<changtm> = $time;

            self.append-table(@iDBTABLES, %wDBTABLES);
            my Str $sql-insert = self.db-insert(table => $tabname, data => @iDBTABLES);
            
            $dbh.do($sql); #-- Create table DBTABLES

            $dbh.do($sql-insert); #-- Register DBTABLES in DBTABLES

          }
          $dbh.dispose;
        } #defined dbh
      };

    
    method db-filename(Str :$dbtype = $C_DBTYPE_SQLITE) {
        my Str $file-name = '';
        $file-name = self.get(key => 'DATA_DIR') 
                  ~ '/'
                  ~ self.get(key => 'SID') 
                  ~ self.get(key => 'SID_NR')
                  ~ '/' 
                  ~ self.get(key => 'SID') 
                  ~ self.get(key => 'SID_NR') 
                  ~ '.db';
        return $file-name;
      }

    
    method system-date() {
        my $YYYYMMDD = { sprintf "%04d%02d%02d", .year, .month, .day };
        return Date.new(DateTime.now, formatter => $YYYYMMDD).Str;
      }

    
    method system-time() {
        my $HHMMSS = { sprintf "%02d%02d%02d", .hour, .minute, .second };
        return DateTime.now(formatter => $HHMMSS).Str;
      }

    
    method structure(:@fields) {
        my Str %wFieldStructure = ();
        for @fields -> $fldname {
          %wFieldStructure{"$fldname"} = '';
        }
        return %wFieldStructure; 
      }

    method clear(:%fields) {
      for %fields -> $fld {
        #self.TRACE: 'key = ' ~ $fld.key;
        %fields{$fld.key} = '';
      }
    }

    
    method table-query(Str :$tabname, :%fields, :%where) {
        my @iTableRecords = ();
        my Int $index = 0;
        my Str $fldname-list = '';
        my Str $where-list = '';
        my Str $db-file = '';
        my Bool $continue = True;
        for %fields.sort({.key}) -> $field {
          my $fldname = $field.key;
          if self.is-field(tabname => $tabname,
                          fldname => $fldname) {
            $index++;
            $fldname-list ~= $fldname;
            $fldname-list ~= ', ' if $index < %fields.elems;
          }
          else {
            $continue = False;
          }
        }
        if $continue {
          $index = 0;
          for %where -> $condition {
            my $fldname = $condition.key;
            if self.is-field(tabname => $tabname,
                            fldname => $fldname) { 
              $index++;
              $where-list ~= $fldname ~ '=' ~ '"' ~ $condition.value ~ '"';
              $where-list ~= ' AND ' if $index < %where.elems;
            }
            else {
              $continue = False;
            }
          }
        }

        if $continue {
          $db-file =  self.db-filename(dbtype => $C_DBTYPE_SQLITE);
          my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
          if defined $dbh {
            #my $sth_temp = qq:to/SQL/;
            #  SELECT $fldname-list
            #  FROM $tabname
            #  WHERE $where-list            
            #SQL
            #self.TRACE: 'method table-query: ' ~ $sth_temp;
            my $sth = $dbh.prepare(qq:to/SQL/);
              SELECT $fldname-list
              FROM $tabname
              WHERE $where-list
            SQL
            $sth.execute;
            @iTableRecords = $sth.fetchall-AoH;
            $dbh.dispose;
          }
        }
        return @iTableRecords;
      }

    
    method table-structure(Str :$tabname = '', Bool :$keyonly = False) {
        my Str %wTableStructure = ();
        if $tabname ne '' {
          if self.is-table(tabname => $tabname) {
            #-- Query TABLFLDS for fldname, fldspos
            my %wFields = self.structure( fields => ['fldname', 'fldspos'] );
            %wFields<fldname> = 'fldname';
            %wFields<fldspos> = 'fldspos';
            my %wWhere = ();
            if $keyonly {
              %wWhere = self.structure( fields => ['tabname', 'actvatd', 'version', 'primkey'] );
              %wWhere<tabname> = $tabname;
              %wWhere<actvatd> = 'A';
              %wWhere<version> = '0';
              %wWhere<primkey> = 'X';
            }
            else {
              %wWhere = self.structure( fields => ['tabname', 'actvatd', 'version'] );
              %wWhere<tabname> = $tabname;
              %wWhere<actvatd> = 'A';
              %wWhere<version> = '0';
            }
            my @iTABLFLDS = self.table-query(tabname => 'TABLFLDS', 
                                            fields => %wFields,
                                            where => %wWhere);
            if (@iTABLFLDS.elems) {
              for @iTABLFLDS -> $fldname {
                my $field-name = $fldname<fldname>.lc;
                if $field-name ne '' {
                  %wTableStructure{$field-name} = '';  #-- set initial blank value, we only need fields
                }
              }
            }
          }
        }
        return %wTableStructure;
      }

    
    method field-info(Str :$field, Str :$language = 'E') {
        my Str ($tab, $fld) = $field.split(/\-/);
        my Str $tabname = $tab.uc;
        my Str $fldname = $fld.uc;

        my %wFieldInfo = ();
        if self.is-field(tabname => $tabname.uc, fldname => $fldname.uc) {
          my Str $db-file = ''; 
          my Str $active-flag = 'A';
          my Str $table-name = $tabname.uc;
          my Str $field-name = $fldname.uc;

          $db-file = self.db-filename();
          my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
          if defined $dbh {  
            #-- Table fields
            my $sth = $dbh.prepare(qq:to/SQL/);        
              SELECT tabname, fldname, delemnt, fldspos, primkey,
                    chktabl, inttype, intleng, datadec
              FROM TABLFLDS
              WHERE tabname = '$table-name' AND
                    fldname = '$field-name' and
                    actvatd = '$active-flag' AND
                    version = '0'
            SQL
            $sth.execute;
            my %wTABLFLDS = $sth.fetchall-hash;
            for %wTABLFLDS -> $fld {
              my $fldvalu = $fld.value;
              %wFieldInfo{$fld.key} = $fldvalu.Str;
            }
            
            %wFieldInfo{'tablfld'} = %wTABLFLDS<tabname>.Str ~ '-' ~ %wTABLFLDS<fldname>.Str;
            my Str $data-element = %wFieldInfo<delemnt>.Str;

            #-- Text elements
            $sth = $dbh.prepare(qq:to/SQL/);
              SELECT descrip, shortxt, medtext, longtxt
              FROM DATAELET
              WHERE delemnt = '$data-element' AND
                    actvatd = '$active-flag' AND
                    version = '0' AND
                    langiso = '$language'
            SQL
            $sth.execute;
            my %wDATAELET = $sth.fetchall-hash;
            for %wDATAELET -> $fld {
              my $fldvalu = $fld.value;
              %wFieldInfo{$fld.key} = $fldvalu.Str;
            }
          
            #-- Data domain 
            $sth = $dbh.prepare(qq:to/SQL/);
              SELECT domname
              FROM DATAELEM
              WHERE delemnt = '$data-element' AND
                    actvatd = '$active-flag' AND
                    version = '0'
            SQL
            $sth.execute;
            my %wDATAELEM = $sth.fetchall-hash;
            for %wDATAELEM -> $fld {
              my $fldvalu = $fld.value;
              %wFieldInfo{$fld.key} = $fldvalu.Str;
            }
            my Str $data-domain = %wDATAELEM<domname>.Str;

          #-- Data type
            $sth = $dbh.prepare(qq:to/SQL/); 
              SELECT datatyp, datalen, displen, datadec, lowcase,
                    signflg, langflg, fixvalu, valtabl
              FROM DBDOMAIN
              WHERE domname = '$data-domain' AND
                    actvatd = '$active-flag' AND
                    version = '0'
            SQL
            $sth.execute;
            my %wDBDOMAIN = $sth.fetchall-hash;
            for %wDBDOMAIN -> $fld {
              my $fldvalu = $fld.value;
              %wFieldInfo{$fld.key} = $fldvalu.Str;
            }
            $dbh.dispose;
          }
        }
        return %wFieldInfo;
      }

    
    method field-text(Str :$field, Str :$type = 'D', Str :$language = 'E') {
        my Str ($tab, $fld) = $field.split(/\-/);
        my Str $tabname = $tab.uc;
        my Str $fldname = $fld.uc;
        my Str $text-element = '';
        my %wFieldInfo = ();
        if self.is-field(tabname => $tabname, fldname => $fldname) {
          my Str $db-file = ''; 
          my Str $active-flag = 'A';
          my Str $table-name = $tabname.uc;
          my Str $field-name = $fldname.uc;

          $db-file = self.db-filename();
          my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
          if defined $dbh {  
            #-- Table fields
            my $sth = $dbh.prepare(qq:to/SQL/);        
              SELECT delemnt
              FROM TABLFLDS
              WHERE tabname = '$table-name' AND
                    fldname = '$field-name' and
                    actvatd = '$active-flag' AND
                    version = '0'
            SQL
            $sth.execute;
            my %wTABLFLDS = $sth.fetchall-hash;
            for %wTABLFLDS -> $fldname {
              my $fldvalu = $fldname.value;
              %wFieldInfo{$fldname.key} = $fldvalu.Str;
            }
            my Str $data-element = %wFieldInfo<delemnt>.Str;

            #-- Text eleemnts
            $sth = $dbh.prepare(qq:to/SQL/);
              SELECT descrip, shortxt, medtext, longtxt
              FROM DATAELET
              WHERE delemnt = '$data-element' AND
                    actvatd = '$active-flag' AND
                    version = '0' AND
                    langiso = '$language'
            SQL
            $sth.execute;
            my %wDATAELET = $sth.fetchall-hash;
            for %wDATAELET -> $fldname {
              my $fldvalu = $fldname.value;
              %wFieldInfo{$fldname.key} = $fldvalu.Str;
            }
          
            $dbh.dispose;
          }
        }
        given $type {
          when 'D' { #description
            $text-element = %wFieldInfo<descrip>;
          }
          when 'S' { #short text
            $text-element = %wFieldInfo<shortxt>;
          }
          when 'M' { #medium text
            $text-element = %wFieldInfo<medtext>;
          }
          when 'L' { #long text
            $text-element = %wFieldInfo<longtxt>;
          }
        }
        return $text-element;
      }

    
    method append-table(@iTable, %wRecord) {
        @iTable.push(%wRecord.list.hash);
      }

    
    method db-insert(Str :$table, :@data) {
        my Str $tabname = $table;
        my @iRecords = @data;
        my Str $sql = '';
        my Int $index = 0;
        my Str $record-lines = '';
        my Str $header = '';
        for @iRecords -> $record {
          $index++;
          $header = '';
          my $data = '';
          my %wFields = $record;
          for %wFields -> $field {
            #self.TRACE: 'Field key/value: ' ~ $field.key ~ '/' ~ $field.value;
            $header ~= $field.key ~ ',' if $index == 1;
            $data ~= '"' ~ $field.value ~ '",';
          }
          $header ~~ s:g/\,$$// if $index == 1;
          $data ~~ s:g/\,$$//;
          #self.TRACE: 'HEADER: ' ~ $header if $index == 1;
          $record-lines ~= '(' ~ $data ~ '),';
        }
        $record-lines ~~ s:g/\,$$//;
        
        $sql = qq:to/SQL/;
        INSERT INTO $tabname ($header)
        VALUES $record-lines
        SQL

        #self.TRACE: $sql;
        return $sql;
      }

    
    method is-table(Str :$tabname, Bool :$active = True, Str :$tabltyp = 'T') {
        my Str $db-file = ''; 
        $db-file = self.db-filename();
        my Str $actvatd = 'I'; 
        $actvatd = 'A' if $active eq True;
        my Bool $table-exists = False; 
        my Str $table-type = 'T'; 
        $table-type = $tabltyp if defined $tabltyp;
        my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
        if defined $dbh {
          my $sth = $dbh.prepare(qq:to/SQL/);
            SELECT tabname
            FROM DBTABLES
            WHERE tabname = '$tabname' AND
                  actvatd = '$actvatd' AND
                  tabltyp = '$table-type'
            SQL
          $sth.execute;
          my @table = $sth.fetchall-AoH;
          $table-exists = True if (@table.elems); # > 0;
          $dbh.dispose;
        }
        return $table-exists;
      }

    
    method is-field(Str :$tabname = '', Str :$fldname = '', Bool :$active = True) {
        my Bool $field-exists = False;
        my Str $active-flag = 'I';
        my Str $db-file = '';
        my Str $table-name = $tabname.uc;
        my Str $field-name = $fldname.uc;
        $db-file = self.db-filename();
        $active-flag = 'A' if $active;
        my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
        if defined $dbh {
          my $sth = $dbh.prepare(qq:to/SQL/);
            SELECT fldname
            FROM TABLFLDS
            WHERE tabname = '$table-name' AND
                  fldname = '$field-name' AND
                  actvatd = '$active-flag' AND
                  version = '0'
          SQL
          $sth.execute;
          my @iFields = $sth.fetchall-AoH;
          $field-exists = True if (@iFields.elems);
          $dbh.dispose;
        }
        return $field-exists;
      }

    
    method insert-table(Str $tabname, Str :$key, Str :$values) {
        if self.is-table(tabname => $tabname) { #- table exists?
          #self.TRACE: 'Table ' ~ $tabname ~ ' exists';

          my Str $date = self.system-date();
          my Str $time = self.system-time();

          if $tabname.uc eq 'TABLFLDS' {
            my %wTABLFLDS_k = self.structure( fields => [
              'tabname', 'fldname', 'actvatd', 'version'
            ]);
            my %wTABLFLDS_v = self.structure( fields => [
              'delemnt', 'fldspos', 'primkey', 'nullflg', 'chktabl',
              'inttype', 'intleng', 'datadec', 'changby', 'changdt', 'changtm'
            ]);

            my @pkeys = $key.split(/\|/);
            %wTABLFLDS_k<tabname> = @pkeys[0]; 
            %wTABLFLDS_k<fldname> = @pkeys[1]; 
            %wTABLFLDS_k<actvatd> = @pkeys[2];
            %wTABLFLDS_k<version> = @pkeys[3];

            my @values = $values.split(/\|/);
            %wTABLFLDS_v<delemnt> = @values[0];
            %wTABLFLDS_v<fldspos> = @values[1];
            %wTABLFLDS_v<primkey> = @values[2];
            %wTABLFLDS_v<nullflg> = @values[3];
            %wTABLFLDS_v<chktabl> = @values[4];
            %wTABLFLDS_v<inttype> = @values[5];
            %wTABLFLDS_v<intleng> = @values[6];
            %wTABLFLDS_v<datadec> = @values[7];
            %wTABLFLDS_v<changby> = 'SYSTEM';
            %wTABLFLDS_v<changdt> = $date;
            %wTABLFLDS_v<changtm> = $time;

            #-- Remove existing record (if already exists)

            #--- look for primary keys
            my $db-file = self.db-filename();
            my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);

            if defined $dbh {

              my $sth = $dbh.prepare(qq:to/SQL/);
                SELECT fldname
                FROM TABLFLDS
                WHERE tabname = '%wTABLFLDS_k<tabname>' AND
                      fldname = '%wTABLFLDS_k<fldname>' AND
                      actvatd = '%wTABLFLDS_k<actvatd>' AND
                      version = '%wTABLFLDS_k<version>'
              SQL

              $sth.execute;
              
              my @iTABLFLDS-fldname = $sth.fetchall-AoH;
              if (@iTABLFLDS-fldname.elems) {

                #-- Existing record found, then remove it
                $sth = $dbh.prepare(qq:to/SQL/);
                  DELETE FROM TABLFLDS
                  WHERE tabname = '%wTABLFLDS_k<tabname>' AND
                        fldname = '%wTABLFLDS_k<fldname>' AND
                        actvatd = '%wTABLFLDS_k<actvatd>' AND
                        version = '%wTABLFLDS_k<version>'
                SQL
                $sth.execute;
              }

              #-- if given values are not blank
              if $values ne '' {

                #-- insert the record into TABLFLDS            
                $sth = $dbh.prepare(qq:to/SQL/);
                  INSERT INTO TABLFLDS
                  (
                    tabname, fldname, actvatd, version,
                    delemnt, fldspos, primkey, nullflg,
                    chktabl, inttype, intleng, datadec,
                    changby, changdt, changtm
                  )
                  VALUES (
                    '%wTABLFLDS_k<tabname>', 
                    '%wTABLFLDS_k<fldname>', 
                    '%wTABLFLDS_k<actvatd>', 
                    '%wTABLFLDS_k<version>',
                    '%wTABLFLDS_v<delemnt>', 
                    '%wTABLFLDS_v<fldspos>', 
                    '%wTABLFLDS_v<primkey>', 
                    '%wTABLFLDS_v<nullflg>',
                    '%wTABLFLDS_v<chktabl>', 
                    '%wTABLFLDS_v<inttype>', 
                    '%wTABLFLDS_v<intleng>', 
                    '%wTABLFLDS_v<datadec>',
                    '%wTABLFLDS_v<changby>', 
                    '%wTABLFLDS_v<changdt>', 
                    '%wTABLFLDS_v<changtm>'
                  )
                  SQL
                  $sth.execute;
              
              }

              $sth.finish;
              
              $dbh.dispose;

            } #defined $dbh

          } #- tabname eq TABLFLDS
          else {
            #-- Check if table definition already exists
            #self.TRACE: 'TABLE NAME = ' ~ $tabname;

            my $db-file = self.db-filename();
            
            my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
            
            if defined $dbh {
              #-- Query TABLFLDS for primary keys
              my $sth = $dbh.prepare(qq:to/SQL/);
                SELECT fldname
                FROM TABLFLDS
                WHERE tabname = '$tabname' AND
                      actvatd = 'A' AND
                      primkey = 'X'
                ORDER BY fldspos
                SQL
              $sth.execute;

              my @iTABLFLDS-fldname = $sth.fetchall-AoH;
              if (@iTABLFLDS-fldname.elems) {
                my @iPKeys = $key.split(/\|/);
                my %wPKeys = ();
                my Int $index = 0;
                my Str $fldname = '';
                my Str $condition = '';
                for @iTABLFLDS-fldname -> $fld {
                  %wPKeys{$fldname.lc} = @iPKeys[$index];
                  $fldname ~= $fld<fldname>.lc;
                  $condition ~= $fld<fldname>.lc ~ '=' ~ "'" ~ @iPKeys[$index] ~ "'";
                  $index++;
                  $fldname ~= ', ' if $index < @iPKeys.elems;
                  $condition ~= ' AND ' if $index < @iPKeys.elems;
                }
                #self.TRACE: 'fldname = ' ~ $fldname;
                #self.TRACE: 'condition = ' ~ $condition;

                $sth = $dbh.prepare(qq:to/SQL/);
                  SELECT $fldname
                  FROM $tabname
                  WHERE $condition
                SQL
                $sth.execute;

                my @iTABLE-primkey = $sth.fetchall-AoH;
                if (@iTABLE-primkey.elems) {
                  #-- remove existing record if keys found
                  $sth = $dbh.prepare(qq:to/SQL/);
                    DELETE FROM $fldname
                    WHERE $condition
                  SQL
                  $sth.execute;
                }

                #-- get the fieldnames for non-primary keys 
                #--   to be populated with values
                $sth = $dbh.prepare(qq:to/SQL/);
                  SELECT fldname
                  FROM TABLFLDS
                  WHERE tabname = '$tabname' AND
                        actvatd = 'A' AND
                        primkey = ' '
                  ORDER BY fldspos
                SQL
                $sth.execute;

                #-- collect the value fields
                my @iTABFLDS-values = $sth.fetchall-AoH;

                #-- Assemble INSERT SQL statement
                #--- PRIMARY keys
                my Str $key-fields = '';
                my Str $key-values = '';
                $index = 0;
                for @iPKeys -> $primkey {
                  #self.TRACE: $index.Str ~ ': ' ~ @iTABLFLDS-fldname[$index]<fldname>  ~ ' = ' ~ $primkey;
                  $key-fields ~= @iTABLFLDS-fldname[$index]<fldname>.lc;
                  $key-values ~= "'" ~ $primkey ~ "'";
                  $index++;
                  $key-fields ~= ', ' if $index < @iPKeys.elems;
                  $key-values ~= ', ' if $index < @iPKeys.elems;
                  
                }
                #self.TRACE: 'key fields = ' ~ $key-fields;
                #self.TRACE: 'key values = ' ~ $key-values;

                #--- NON-PRIMARY fields
                my @iValues = $values.split(/\|/);
                my Str $val-fields = '';
                my Str $val-values = '';
                $index = 0;
                for @iTABFLDS-values -> $values {
                  my $fldname = @iTABFLDS-values[$index]<fldname>;
                  $val-fields ~= $fldname.lc;
                  given $fldname {
                    when 'CHANGBY' {
                      $val-values ~= "'SYSTEM'";
                    }
                    when 'CHANGDT' {
                      $val-values ~= "'" ~ $date ~ "'";
                    }
                    when 'CHANGTM' {
                      $val-values ~= "'" ~ $time ~ "'";
                    }
                    default {
                      $val-values ~= "'" ~ @iValues[$index] ~ "'";
                    }
                  }            
                  $index++;
                  $val-fields ~= ', ' if $index < @iTABFLDS-values.elems;
                  $val-values ~= ', ' if $index < @iTABFLDS-values.elems;

                }
                #self.TRACE: 'val fields = ' ~ $val-fields;
                #self.TRACE: 'val values = ' ~ $val-values;

                $sth = $dbh.prepare(qq:to/SQL/);
                  INSERT INTO $tabname ( $key-fields, $val-fields )
                  VALUES ( $key-values, $val-values )
                SQL

                $sth.execute;

                $sth.finish;

                $dbh.dispose;
              }
            } #defined $dbh
          }
        }
      }

    
    method db-execute(Str :$sql) {
        my Str $db-file = '';
        $db-file = self.db-filename();
        my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
        if defined $dbh {
          my $sth = $dbh.prepare($sql);
          $sth.execute;
          $sth.finish;
          $dbh.dispose;
        }
      }

    
    method create-table-index(Str :$tabname, Bool :$reindex = True) {
        if self.is-table(tabname => $tabname, tabletyp => 'T') {
          my Str $index-name = $tabname ~ '~0';
          if $reindex {
            #-- remove existing index if exists
            if self.is-table(tabname => $index-name, tabletyp => 'I') {
              # DROP INDEX <indexname>
              my $db-file = self.db-filename();
              my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
              if defined $dbh {
                my $sql = qq:to/SQL/;
                  DROP INDEX '$index-name'
                SQL
                
                $dbh.do($sql);  
                
                my $sth = $dbh.prepare(qq:to/SQL/);
                  DELETE FROM DBTABLES
                  WHERE tabname = '$index-name' AND
                        actvatd = 'A' AND
                        version = '0' AND
                        tabltyp = 'I'
                SQL
                
                $sth.execute;
                $sth.finish;
                
                $dbh.dispose;
              }
            }
          } #- reindex = True
          
          #self.TRACE: 'TODO: reindex - ' ~ $tabname;

          if self.is-table(tabname => $index-name, tabltype => 'I') {
            #-- index exists, do nothing
          }
          else {
            #-- get primary keys of the table to be reindex
            my $db-file = self.db-filename();
            my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
            if defined $dbh {
            
              my $sth = $dbh.prepare(qq:to/SQL/);
                SELECT fldname
                FROM TABLFLDS
                WHERE tabname = '$tabname' AND
                      actvatd = 'A' AND
                      primkey = 'X'
                ORDER BY fldspos
              SQL
              $sth.execute;
              
              my @iTABLFLDS-primkeys = $sth.fetchall-AoH;
              if @iTABLFLDS-primkeys.elems {
                my Str $primary-keys = '';
                my Int $index = 0;
                
                for @iTABLFLDS-primkeys -> $primkey {
                  $primary-keys ~= "'" ~ $primkey<fldname>.lc ~ "'";
                  $index++;
                  $primary-keys ~= ', ' if $index < @iTABLFLDS-primkeys.elems;
                }
                #self.TRACE: 'INDEX ' ~ $index-name;

                $sth = $dbh.prepare(qq:to/SQL/);
                  CREATE UNIQUE INDEX '$index-name'
                  ON '$tabname' ( $primary-keys )
                SQL
                $sth.execute;

                my Str $date = self.system-date();
                my Str $time = self.system-time();

                my %wDBTABLES = ();
                my @iDBTABLES = ();

                %wDBTABLES = self.structure(fields => [
                  'tabname', 'actvatd', 'version', 'tabltyp', 'clntdep',
                  'langdep', 'contflg', 'changby', 'changdt', 'changtm'
                ]);
                
                %wDBTABLES<tabname> = $index-name;
                %wDBTABLES<actvatd> = 'A';
                %wDBTABLES<version> = '0';
                %wDBTABLES<tabltyp> = 'I';
                %wDBTABLES<clntdep> = '';
                %wDBTABLES<langdep> = '';
                %wDBTABLES<contflg> = 'S';
                %wDBTABLES<changby> = 'SYSTEM';
                %wDBTABLES<changdt> = $date;
                %wDBTABLES<changtm> = $time;
                
                self.append-table(@iDBTABLES, %wDBTABLES);
                my Str $sql-insert = self.db-insert(table => 'DBTABLES', data => @iDBTABLES);
                $dbh.do($sql-insert);

              }
              $dbh.dispose;
            }  
          }
        }
      };

    
    method is-shortcut(Str :$shortcut = '') {
        my Str $program = '';
        my Str $progtxt = '';
        my Str $progtyp = '';
        
        my $db-file = self.db-filename();
        my $dbh = self.db-connect(dbtype => $C_DBTYPE_SQLITE, dbname => $db-file);
        if defined $dbh {
        
          my $sth = $dbh.prepare(qq:to/SQL/);
            SELECT program
            FROM SHORTCUT
            WHERE shortct = '$shortcut' AND
                  actvatd = 'A'
          SQL

          $sth.execute;
          my @iSHORTCUT = $sth.fetchall-AoH;
          if (@iSHORTCUT.elems) {
            $program = @iSHORTCUT[0]<program>.Str;

            my $sth = $dbh.prepare(qq:to/SQL/);
              SELECT progtxt, objtype
              FROM PROGTABL
              WHERE program = '$program' AND
                    actvatd = 'A' 
            SQL

            $sth.execute;
            my @iPROGTABL = $sth.fetchall-AoH;
            if (@iPROGTABL.elems) {
              $progtxt = @iPROGTABL[0]<progtxt>.Str;
              $progtyp = @iPROGTABL[0]<objtype>.Str;
            }
            else { #-- program text, and program type not found
              $program = '';
              $progtxt = '';
              $progtyp = '';
            }
            $sth.finish;
          } 

          $sth.finish;
          $dbh.dispose;
          
        }
        return ($program, $progtxt, $progtyp);
      }

    

    #-------- END: DATABASE utilities

    };

    

