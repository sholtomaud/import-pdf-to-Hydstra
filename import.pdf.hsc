=setup
[Configuration] 
ListFileExtension = TXT

[Window]
Head = IMPORT.PDF.HSC - Import PDF from website

[Labels]
AREASMT       = END   20  +1 Bore ID 
REP     = END   20 +1 Report File

[Fields]
BOREID     = 21 +1 INPUT   CHAR       20  0  FALSE   TRUE   0.0 0.0 '  ' STN
REP        = 21 +1 INPUT   CHAR       40  0  FALSE   TRUE   0.0 0.0 '#PRINT(P           )'

[Perl]
OUTFOLDER  = 21  +1 INPUT   CHAR       60  0  FALSE   FALSE  0.0 0.0 '&hyd-ptmppath.export' $OP
=cut


use strict;
use warnings;

use File::Copy;
use File::stat;
use File::Path qw(make_path remove_tree);
use File::Fetch;
use FileHandle; 
use FindBin qw($Bin);
use lib "$Bin/chr/lib"; 
use Chromicon;
use HydDLLp;
use Cwd;
require 'hydlib.pl';
require 'hydtim.pl';
   
my $prtdest_scr   = '-LSR';   #the Prt() print destination for screen messages
my $prtdest_log   = '-LT';    #the Prt() print destination for log messages
my $prtdest_debug = '-T';     #the Prt() print destination for debug messages
my $prtdest_data  = '-T';     #the Prt() print destination for the data hash
my $_debug = defined( $ENV{HYDEBUG} );
my $DEFBUFFER = 1950;

my (%params, %ini, $dll);

main: { 
  
  IniCrack($ARGV[0],\%params);
  IniHash( $ARGV[0],      \%ini, 0, 0);
  #$dll = HydDllp->New();
  
  my $reportfile = $ini{perl_parameters}{rep};
  OpenFile(*hREPORT,$reportfile,'>');
  Prt(*hREPORT,NowStr()." Starting $0\n");                    #write this to the Process Report, now that it's been done, and we know the name of the report file
  Prt(*hREPORT,NowStr()." - Initialising\n");                 #write this to the Process Report, now that it's been done, and we know the name of the report file
  my $site = $ini{perl_parameters}{boreid};
  my $temp = HyconfigValue('TEMPPATH');
  
  Prt($prtdest_scr,NowStr()." - Checking [$site] is in Hydstra SITE table.\n");  
  my $hydata = Chromicon::HyData->new();
  my $docpath = HyconfigValue('DOCPATH');
  
  if ( ! $hydata->site_exists($site) ){
    Prt('-RSL'," Bore [$site] is not in the Hydstra database. Please contact administrator to add a new Bore.\n Note: You may still be able to get a copy fo the borecard by visiting:\n http://resources.information.qld.gov.au/groundwater/reports/borereport?gw_pub_borecard&p_rn=$site");  
  }
  else{
    Prt($prtdest_scr,NowStr()."  - Site exists. Fetching borecard from DNRM\n");  
    
    #my $site_docpath = $$docref{return}{location}//Prt('-X',"Could not find Bore RN in Hydstra document");
    my $site_docpath = $docpath.'SITE\\'.$site.'\\';
    my $date = NowString();
    my $site_borecard_path = $site_docpath.'DNRM_borecard\\'.$date.'\\';
    MkDir($site_borecard_path);
    my $borecard = $site_borecard_path.'DNRM_'.$site.'_BOREDS_01.PDF';
        
    if ( -e $borecard ) {
      Prt($prtdest_scr,NowStr()."  - Borecard already exists, skipping\n");  
      #Prt('-SLP',NowStr()." Borecard exists, skipping\n");
      return;
    }  
    else{
      my $ff = File::Fetch->new(uri => "http://resources.information.qld.gov.au/groundwater/reports/borereport?gw_pub_borecard&p_rn=$site");
      my $where = $ff->fetch();
      if (defined $where){
        my $where = $ff->fetch( to => $temp );    
        Prt($prtdest_scr,NowStr()."   - Got borecard from DNRM\n");  
        #Prt('-P',"result [$where]");
        if ( copy( $where, $borecard ) ) {
          Prt($prtdest_scr,NowStr()."   - Saved to [$site_borecard_path]\n");  
        }
        else {
          Prt($prtdest_scr,NowStr() . "   *** ERROR - Copy Failed\n" );
        }
        unlink $where;
      }
      else{
        Prt($prtdest_scr,NowStr() . "   *** ERROR [".$ff->error."]\n" );
      }
    }
    Prt($prtdest_scr,NowStr()."  - Opening in pdf viewer\n");      
    system("start $borecard");
    Prt($prtdest_scr,NowStr()." - Fin\n" );
  }
  close(hREPORT);
  
}