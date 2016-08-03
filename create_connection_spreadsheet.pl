#!/usr/bin/perl
use strict;
use Cwd;
use Getopt::Long;
use Verilog::Netlist;
use Time::Local;

##################### Variable Declarations ##################
my $user = `whoami`;
chomp ($user);
my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my ($sec,$min,$hour,$mday,$mon,$year,$wday) = localtime();
my $year_final = $year+1900;
my $cwd;
my $cwd1;
my $path;
my $update;
my $audit_run;
my $cell;
my $output;
my $trig_o;
my $verilog_file;
my @opt_files;
my @tmp1;
my @ip_tmp;
my @int_tmp;
my @rev_tmp;
my $audit0a = 0;
my $audit1a = 0;
my $audit2a = 0;
my $audit3a = 0;
my $audit4a = 0;
my $pwr;
my $multi;
my $single;
my $file;
my $file_bak;
my $file_all;
my $file_bak_all;
my $verilog_list;
my $conn_list;
my @conn_array;
my @port_same;
my @port_same3;
my @port_diff;
my @port_diff2;
my @port_diff3;
my @port_diff4;
my $count_difference = 0;
my $count_difference1 = 0;
##############################################################

##################### managing options #######################
if (scalar (@ARGV)<1){error()}
Getopt::Long::config ("no_auto_abbrev","pass_through");
error() if (! GetOptions 
	("p=s"		=>\$path,
	"h|help"      	=> \&usage,
	"update"	=>\$update,
	"audit"		=>\$audit_run,
	"pdef"		=>\$pwr,
	"m"		=>\$multi,
	"s"		=>\$single,
	"c=s"		=>\$conn_list,
	"v=s"		=>\$verilog_list,
	"<>"          	=> \&parameter,
    ));

##############################################################

##################initialize working directory ###############
if (defined $path) # gets the argument -p defined by the user
{
	$cwd = $path;
	chomp $cwd; # removes new lines
	chdir ($cwd);
}
else
{
	$cwd = `pwd`; # gets the current working directory
	chomp $cwd; # removes new lines
}
##############################################################
##################initialize log file ########################
open (FILE, ">make_conn.log");
print FILE "";
close (FILE);
open (LOGFILE, ">>make_conn.log") or die "n\cannot open file";
##############################################################
#################initialize input files#######################
$cwd1 = $cwd;
if ($cwd1 =~ /conn$/){$cwd1 =~ s/\/conn$//g;}
else
{
	print "\n\n\n---------------------------------\n";
	print "Processed Date: ";
	printf("%02d:%02d:%02d", $hour, $min, $sec);
	print " $mday $months[$mon] $days[$wday]\n";
	print "Processed By: $user\n\n";
	print "[ERROR-001] Not run in the conn directory\n";
	print "<status> aborted!\n";
	print "<log> N/A\n";
	print "------------------------------------\n\n\n";
	
	print LOGFILE "Processed Date: ";
	printf(LOGFILE "%02d:%02d:%02d", $hour, $min, $sec);
	print LOGFILE " $mday $months[$mon] $days[$wday]\n";
	print LOGFILE "Processed By: $user\n\n";
	print LOGFILE "<status> aborted\n";
	print LOGFILE "[ERROR-001] Not run in the conn directory\n";
	print LOGFILE "<log> N/A\n";
	exit(1);
}
my $ipname;
# Logic design directory
if ($cwd =~ /(.*\/logic_design)\/(\S+)\/data\/conn$/)
{
	$cell = $2;
	$verilog_file = "$1\/$cell\/data\/netlists\/verilog_func\/$cell.v";
}
# Custom design directory
if ($cwd =~ /.*\/custom_design\/\S+\/(\S+)\/conn$/)
{
	$cell = $1;
	$verilog_file = "$cwd1/netlists/verilog_func/$cell.v";
}
# IP_generic directory
if ($cwd =~ /(.*\/logic_design)\/(\S+)\/data\/conn$/)
{
	$cell = $2;
	$verilog_file = "$1\/$cell\/data\/netlists\/verilog_func\/$cell.v";
}
$file = "$cwd1/conn/conn_file_$cell.xlsx";
$file_bak = "$cwd1/conn/conn_file_bak_$cell.xlsx";
##############################################################

#################### main module #############################
# Variable declaration and 
my $tmp1 = "$cwd1/conn/tmp1";
my $ip_tmp = "$cwd1/conn/ip_tmp";
my $int_tmp = "$cwd1/conn/int_tmp";
my $rev_tmp = "$cwd1/conn/rev_tmp";
my $ip_tmp = "$cwd1/conn/ip_tmp";
my $int_tmp = "$cwd1/conn/int_tmp";
my $rev_tmp = "$cwd1/conn/rev_tmp";
my $v_tmp = "$cwd1/conn/v_tmp";
my $output0 = "$cwd1/conn/conn_file_$cell.xlsx";
my $output1 = "$cwd1/conn/conn_file_temp_$cell.xlsx";
my $workbook;
my $sheet1;
my $sheet2;
my $sheet3;
my $format0;
my $format1;
my $format2;
my $format3;
my $format4;
my $format5;
my $rev = 1.0;
my @v_port_combo;
my $comment = "Created initial version";
my @data1a = ('PORT','PORT TYPE (I/O)','PORT CLASSIFICATION','VOLTAGE DOMAIN','DRIVER INFO');
my @data1b = ('USED STATE','UNUSED STATE');
my @data1c = ('METAL','SPACING (um)','WIDTH (um)','SHIELD WIDTH (um)','SHIELD TYPE');
my @data2a = ('PORT','PORT TYPE (I/O)','PORT CLASSIFICATION');
my @data2b = ('IP','PORT');
my @data2b = ('IP','PORT');
my @data3a = ('Revision','Date', 'Revision Owner','Comments');
my @data4b_new = ($rev,"$months[$mon]/$mday/$year_final",$user,'Created initial version');
my @data4a = ("","","","","","","","","");
my @data4b = ("","","","");
my @data4c = ("","");
my @data4d = ("","","","","");
my @data4e = ("","","");
my $data1a_ref = \@data1a;
my $data1b_ref = \@data1b;
my $data1c_ref = \@data1c;
my $data2a_ref = \@data2a;
my $data2b_ref = \@data2b;
my $data3a_ref = \@data3a;
my $data4a_ref = \@data4a;
my $data4b_ref = \@data4b;
my $data4c_ref = \@data4c;
my $data4d_ref = \@data4d;
my $data4e_ref = \@data4e;
my $data4b_ref_new = \@data4b_new;
my $A1 = "Specify the project-specific IPs\nExample:\n1.SA85H\n2.SA45H\n3.SA25H\n\nIf generic IP, please leave the cell blank";
my $B1 = "<IP_NAME>-is the name of the design block or IP for the project.\nExamples:\n1.EBR-EBR\n2.SYSIO-IOS_BANKREF_LR,IOS_IOBUF_QUADT\n3.ASR-ASR_TOP,ASR_LOGIC,ASR\n4.DCU-DCU_TOP\n5.CLK-CLK_LMID,CLK_RMID\n\nNote that connections for different project-specific IPs (ex.CLK_LMID for SA85H,SA45H,and SA25H) are recommended to be added in different sheets.Enter the project code in Cell A1";
my $C2 = "Select pin direction:\nI-Input\nO-Output\nIO-Bi-Di\nP-Power\nF-Feedthrough";
my $D2 = "Specify the voltage domains for each port. Leave cells as blank if not applicable.";
my $E2 = "Specify output driver information or input driver requirements if applicable.\n\nDriver loads are \"Integration Dependent\",hence this will need to be taken care of via Full Chip Timing Closure";
my $F2 = "Provide the default port setting that results to the lowest power state of the IP.Ideally,this is achieved when IP is in the NOT USED state.";
my $G2 = "Provide port default values that results to the lowest power state of the IP while it is in the USED state.\n\nEnter values only when different from the default values in the NOT USED state.\n\nLimitation of this info is that the lowest power state during used state is only derived from one setting/mode.\nWhen IP Factory is up and running,default port values at lowest power state can be provided for all modes (User Components).";
my $H2 = "Provide the port function: DATA, ADDRESS, CLOCK, RESET, CONFIG, CONTROL, POWER_VCC, POWER_GND";
my $new_audit = 0;
# Checking if the netlists or functional model exists
if (-e $verilog_file)
{
	print "\n\n\n----------------------------\n";
	print "Processed Date: ";
	printf("%02d:%02d:%02d", $hour, $min, $sec);
	print " $mday $months[$mon] $days[$wday]\n";
	print "Processed By: $user\n";
	print "Netlist found!\n";
	print "Running the generator...\n\n";
	print LOGFILE "Processed Date: ";
	printf(LOGFILE "%02d:%02d:%02d", $hour, $min, $sec);
	print LOGFILE " $mday $months[$mon] $days[$wday]\n";
	print LOGFILE "Processed By: $user\n";
	print LOGFILE "Netlist found.\n";
	print LOGFILE "Running the generator..\n\n";	
	
	# reading mutiple conn files to create single conn file containing multiple blocks
	if ((defined $multi)&&(defined $conn_list))	
	{	&gen_multi_con();
		unlink($ip_tmp);
		unlink($int_tmp);
		unlink($rev_tmp);		
		if (defined $audit_run)
		{
		&audit_multi($file);		
		}		
	}
	# reading mutiple verilog modules to create single conn file containing multiple blocks	
	elsif ((defined $multi)&&(defined $verilog_list)&&!(-e $file))
	{	&gen_multi($verilog_file);
		unlink($v_tmp);
		unlink($ip_tmp);
		unlink($int_tmp);
		unlink($rev_tmp);
		
		print "[INFO] conn_file_$cell.xlsx created!\n";		
		print LOGFILE "[INFO] conn_file_$cell.xlsx created!\n";
		if (defined $audit_run)
		{
		&audit_multi($file);		
		}
		else
		{
		print "<status> conn file created - half done\n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status> conn file created - half done\n";
		print LOGFILE "<log> $file\n";
		}		
	}
	elsif ((defined $multi)&&(defined $verilog_list)&&(-e $file)&&(defined $audit_run))
	{	
		&con_parser($file);
		&audit_multi($file);
	}	
	#if single block IPs
	elsif (defined $single)
	{
	if ((-e $file)&&(defined $audit_run) &&(!defined $update)) # Checks if a conn file already exists. If this is true, the conn file will be updated if there are updates made in the netlist ports
	{	&con_parser($file);
		&single_audit($verilog_file);
		`rm ip_tmp*`;
		`rm int_tmp*`;
		`rm rev_tmp*`;
		`rm v_tmp*`;
	}
	if ((-e $file)&&(defined $update)) # Checks if a conn file already exists. If this is true, the conn file will be updated if there are updates made in the netlist ports
	{	&con_parser($file);
		&update_single($verilog_file);
		`rm ip_tmp*`;
		`rm int_tmp*`;
		`rm rev_tmp*`;
		`rm v_tmp*`;	
		
	}
	unless (-e $file) # If no conn file originally created, this will generate a conn file template using the netlists.
	{
		&gen_single($verilog_file);	
		print "[INFO] conn_file_$cell.xlsx created!\n";		
		print LOGFILE "[INFO] conn_file_$cell.xlsx created!\n";
		if (defined $audit_run)
		{
		&con_parser($file);
		&single_audit($verilog_file);
		unlink($ip_tmp);
		unlink($int_tmp);			
		}
		else
		{
		print "<status> half done\n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status> conn file created - half done\n";
		print LOGFILE "<log> $file\n";
		}		
		`rm ip_tmp*`;
		`rm int_tmp*`;
		`rm rev_tmp*`;
		`rm v_tmp*`;
  	}}
}
else
{
	print "\n\n\n----------------------------\n";
	print "Processed Date: ";
	printf("%02d:%02d:%02d", $hour, $min, $sec);
	print " $mday $months[$mon] $days[$wday]\n";
	print "Processed By: $user\n\n";
	print "Netlist cannot be found\n";
	print "<status> aborted\n";
	print "<log> N/A\n";
	print "---------------------------\n\n\n";
	print LOGFILE "Processed Date: ";
	printf(LOGFILE "%02d:%02d:%02d", $hour, $min, $sec);
	print LOGFILE " $mday $months[$mon] $days[$wday]\n";
	print LOGFILE "Processed By: $user\n\n";
	print LOGFILE "[ERROR-002] Netlist cannot be found.\n";
	print LOGFILE "\n<status> aborted\n";
	print LOGFILE "<log> N\A\n";
}
exit (0);

#-----------------------------------------------------------
#description: sub module for verilog single_parser
sub verilog_parser
{
	open (VOUT, ">$v_tmp");
	$verilog_file = shift;
	open (DATA0, $verilog_file);
	my @v_data = (<DATA0>);
	my $nl = new Verilog::Netlist (); 
	$nl->read_file (filename=>$verilog_file);
	$nl->exit_if_error();
	my $dir;
	my $sig_dir;
	my $sig_name;
	my @v_port;
	foreach my $line(@v_data)
	{	if ($line =~ m/^module\s+$cell\s*\(/i)
		{	foreach my $mod ($nl->find_module($cell))
			{	foreach my $sig ($mod->ports_sorted) 
				{	$dir = $sig->direction;
					$sig_name = $sig->name;
					$sig_dir = "$dir,$sig_name";
					push (@v_port,$sig_dir);
				}
			}
		}	
	}
	## Extracting port and port type in the sub module
	foreach my $line1(@v_port)
	{	my $busmax;
		my $busmin;
		my $flag = 0;
		my $port_name;	
		my $port_name1;
		my $port_name2;
		my $port_type;
		if ($line1 =~ m/^(in|out|inout),(\S+)/i)
		{	$port_name = $2;
			$port_type = $1;
			$port_type =~s/in|input/I/;
			$port_type =~s/out|output/O/;
			$port_type =~s/inout/IO/;
			my @split_var;
			my $trig=0;
			foreach my $line2(@v_data)
			{	if ($line2 =~ m/^module\s+$cell\s*\(/i) # module extraction
				{$trig = 1}
				if (($line2=~m/^\s*(input|output|inout)\s+\[(\d+)\:(\d+)\]\s+(.*)\;/i) && ($trig == 1))
				{	$busmax =$2;
					$busmin =$3;
					if ($4=~m/^($port_name)\;/i)
					{	$flag = 1;
						$trig = 0;
					}
					else
					{	@split_var=split(",",$4);
						foreach $port_name1(@split_var)
						{	$port_name1 =~s/ //g;
							if ($port_name1 eq $port_name)
							{	$flag = 1;	
								$trig = 0;	
								$port_name=$port_name1;			
							}
						}
					}
				}
			}
			if ($flag == 1)
			{	$port_name2 = "$port_name<$busmax:$busmin>";
				my $name_dir = "$port_name2($port_type)";
				print VOUT "$name_dir\n";
			}
			else
			{	$port_name2 = "$port_name";
				my $name_dir = "$port_name2($port_type)";
				print VOUT "$name_dir\n";
			}
		}
	}
return;
}
# -------------------------------------------------------------------------------
# Parsing conn file 
sub con_parser
{
use lib "/usr/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi";
use Spreadsheet::XLSX;
$file = shift;
my $excel = Spreadsheet::XLSX -> new ($file);
my $sheets = $excel->{SheetCount};
my ($eSheet, $sheetName);
my $source_cell;
my $val;
open(IPOUT, ">$ip_tmp");
open(INTOUT, ">$int_tmp");
open(REVOUT, ">$rev_tmp");
foreach my $sheet (0 .. $sheets - 1) 
{	$eSheet = $excel->{Worksheet}[$sheet];
	$sheetName = $eSheet->{Name};
	if (($sheetName =~m/(IP)_(.*)/i)||($sheetName eq "IP Information"))
	{		
		foreach my $sheet_row (2 .. $eSheet->{MaxRow})
		{
		if (defined $multi)
		{print IPOUT "$2\t"}
			foreach my $sheet_col (1 .. $eSheet->{MaxCol}) 
			{	$source_cell = $eSheet->{Cells}[$sheet_row][$sheet_col];
				if ($source_cell ne "")
				{	$val = $source_cell->value;
					for ($val)
	 				{	s/&lt;/</;
	   					s/&gt;/>/;	
	  				}
					print IPOUT "$val";
					print IPOUT "\t";
				}
				if ($source_cell eq "")
				{	print IPOUT "";
					print IPOUT "\t";
				}
		}			
			print IPOUT "\n";
	    	}
	}
	if (($sheetName =~m/(INT)_(.*)/i)||($sheetName eq "Integration Connectivity"))
	{		
		foreach my $sheet_row (2 .. $eSheet->{MaxRow})
		{
		if (defined $multi)
		{print INTOUT "$2\t"}
			foreach my $sheet_col (1 .. $eSheet->{MaxCol}) 
			{	$source_cell = $eSheet->{Cells}[$sheet_row][$sheet_col];
				if ($source_cell ne "")
				{	$val = $source_cell->value;
					for ($val)
	 				{	s/&lt;/</;
	   					s/&gt;/>/;	
	  				}
					print INTOUT "$val";
					print INTOUT "\t";
				}
				if ($source_cell eq "")
				{	print INTOUT "";
					print INTOUT "\t";
				}
		}			
			print INTOUT "\n";
	    	}
	}
	if ($sheetName eq "Revision History")
	{	
		foreach my $sheet_row (1 .. $eSheet->{MaxRow})
		{
			foreach my $sheet_col (0 .. $eSheet->{MaxCol}) 
			{	$source_cell = $eSheet->{Cells}[$sheet_row][$sheet_col];
				if ($source_cell ne "")
				{	$val = $source_cell->value;
					print REVOUT "$val";
					print REVOUT "\t";
				}
				if ($source_cell eq "")
				{	print REVOUT "";
					print REVOUT "\t";
				}
		}			
			print REVOUT "\n";
	    	}
	}
}
return;
}
#------------------------------------------------------------------------
# Generating 
sub gen_single
{
	
	
	
	use Excel::Writer::XLSX;
	open(OUT, ">>$output0");
	my $workbook = Excel::Writer::XLSX->new("$output0");
	my $worksheet;	
	my $header = "CURRENT BLOCK:$cell";
	&verilog_parser($verilog_file);	
	`cp v_tmp v_data_$cell`;	
	open (VDATA, "v_data_$cell");
	my @v_data0 = (<VDATA>);
	########## defining worksheets/tab names #####
	my $formata = $workbook->add_format();
	my $formatb = $workbook->add_format();
	my $formatc = $workbook->add_format();
	my $formatd = $workbook->add_format();
	my $formate = $workbook->add_format();
	my $formatf = $workbook->add_format();
	my $formatg = $workbook->add_format();	
	$formata->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', border => 1, size => 10);
	$formatb->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', border => 1, size => 10);
	$formatc->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'yellow', border => 1, size => 10);
	$formatd->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'lime', border => 1, size => 10);
	$formate->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'gray', border => 1, size => 10);
	$formatf->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', border => 1, size => 10);	
	$formatg->set_format_properties(font => 'Arial',color => 'black', align => 'left', border => 1, size => 10);	
	#IP Information
	$worksheet = $workbook->add_worksheet('IP Information');
	$worksheet->write_row(1,1,$data1a_ref,$formatc);
	$worksheet->write_row(1,6,$data1b_ref,$formata);
	$worksheet->write_row(1,8,$data1c_ref,$formatd);	
	$worksheet->write_string('A2', "ITEM",$formata);
	$worksheet->merge_range_type('string','B1:F1', $header,$formatc);
	$worksheet->merge_range_type('string','G1:H1', 'DEFAULT VALUE',$formata);
	$worksheet->merge_range_type('string','I1:M1', 'LAYOUT INFORMATION',$formatd); 
	$worksheet->merge_range_type('string','N1:N2', 'COMMENTS',$formata); 
	$worksheet->write_comment('A1',"$A1");
	$worksheet->write_comment('B1',"$B1");
	$worksheet->write_comment('C2',"$C2");
	$worksheet->write_comment('E2',"$D2");
	$worksheet->write_comment('F2',"$E2");
	$worksheet->write_comment('G2',"$F2");
	$worksheet->write_comment('H2',"$G2");
	$worksheet->write_comment('D2',"$H2");
	$worksheet->set_column(0,0,10,$formata);
	$worksheet->set_column(1,5,22,$formatc);
	$worksheet->set_column(6,7,22,$formata);
	$worksheet->set_column(8,12,22,$formatd);
	$worksheet->set_column(13,13,30,$formatb);
	my $ip_row = 2;
	my $ip_item = 1;
	foreach my $line(@v_data0)
	{
	if ($line=~m/(.*)(\()(I|O|IO|P|F)(\))/i)
	{
	$worksheet->write($ip_row,0,$ip_item);
	$worksheet->write($ip_row,1,$1);
	$worksheet->write($ip_row,2,$3);
	$ip_row++;
	$ip_item++;
	}
	}
	#Integration Connectivity		
	$worksheet = $workbook->add_worksheet("Integration Connectivity");
	$worksheet->write_row(1,1,$data2a_ref,$formatc);
	$worksheet->write_row(1,4,$data2b_ref,$formatd);
	$worksheet->merge_range_type('string','B1:D1', $header,$formatc);
	$worksheet->merge_range_type('string','E1:F1', 'SOURCE/DESTINATION',$formatd); 
	$worksheet->merge_range_type('string','G1:G2', 'COMMENTS',$formata);
	$worksheet->write_string('B1', $header,$formatc);
	$worksheet->write_string('A2', "ITEM",$formata);
	$worksheet->write_comment('A1',"$A1");
	$worksheet->write_comment('B1',"$B1");
	$worksheet->write_comment('C2',"$C2");
	$worksheet->write_comment('D2',"$H2");	
	$worksheet->set_column(0,0,10,$formata);
	$worksheet->set_column(1,3,22,$formatc);
	$worksheet->set_column(4,5,22,$formatd);
	$worksheet->set_column(6,6,30,$formatb);
	my $int_row = 2;
	my $int_item = 1;
	foreach my $line(@v_data0)
	{
	if ($line=~m/(.*)(\()(I|O|IO|P|F)(\))/i)
	{
	$worksheet->write($int_row,0,$int_item);
	$worksheet->write($int_row,1,$1);
	$worksheet->write($int_row,2,$3);
	$int_row++;
	$int_item++;
	}
	}
	`rm v_data_$cell`;
	#Revision History
	$worksheet = $workbook->add_worksheet("Revision History");
	$worksheet->write_row(0,0,$data3a_ref);
	$worksheet->write(1,0,"1.0");
	$worksheet->write(1,1,"$months[$mon]/$mday/$year_final");
	$worksheet->write(1,2,$user);
	$worksheet->write(1,3,$comment);
	$worksheet->set_column(0,2,22,$formata);
	$worksheet->set_column(3,3,100,$formatf);
						
close (OUT);
return;
}
# -----------------------------------------------------------------------
# Generate conn file for multiple blocks using verilog file
sub gen_multi
{
	my @verilog_list_array = split(",",$verilog_list);	
	my $block_cell;
	use Excel::Writer::XLSX;
	open(OUT, ">>$output0");
	my $workbook = Excel::Writer::XLSX->new("$output0");
	my $worksheet;
	my $header;
	my $formata = $workbook->add_format();
	my $formatb = $workbook->add_format();
	my $formatc = $workbook->add_format();
	my $formatd = $workbook->add_format();
	my $formate = $workbook->add_format();
	my $formatf = $workbook->add_format();
	my $formatg = $workbook->add_format();	
	$formata->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', border => 1, size => 10);
	$formatb->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', border => 1, size => 10);
	$formatc->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'yellow', border => 1, size => 10);
	$formatd->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'lime', border => 1, size => 10);
	$formate->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'gray', border => 1, size => 10);
	$formatf->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', border => 1, size => 10);	
	$formatg->set_format_properties(font => 'Arial',color => 'black', align => 'left', border => 1, size => 10);	
	foreach $block_cell(@verilog_list_array)
	{
	$cell = $block_cell;
	$header = "CURRENT BLOCK:$block_cell";
	$worksheet = $workbook->add_worksheet("IP_$block_cell");
	$worksheet->write_row(1,1,$data1a_ref,$formatc);
	$worksheet->write_row(1,6,$data1b_ref,$formata);
	$worksheet->write_row(1,8,$data1c_ref,$formatd);	
	$worksheet->write_string('A2', "ITEM",$formata);
	$worksheet->merge_range_type('string','B1:F1', $header,$formatc);
	$worksheet->merge_range_type('string','G1:H1', 'DEFAULT VALUE',$formata);
	$worksheet->merge_range_type('string','I1:M1', 'LAYOUT INFORMATION',$formatd); 
	$worksheet->merge_range_type('string','N1:N2', 'COMMENTS',$formata); 
	$worksheet->write_comment('A1',"$A1");
	$worksheet->write_comment('B1',"$B1");
	$worksheet->write_comment('C2',"$C2");
	$worksheet->write_comment('E2',"$D2");
	$worksheet->write_comment('F2',"$E2");
	$worksheet->write_comment('G2',"$F2");
	$worksheet->write_comment('H2',"$G2");
	$worksheet->write_comment('D2',"$H2");
	$worksheet->set_column(0,0,10,$formata);
	$worksheet->set_column(1,5,22,$formatc);
	$worksheet->set_column(6,7,22,$formata);
	$worksheet->set_column(8,12,22,$formatd);
	$worksheet->set_column(13,13,30,$formatb);
	&verilog_parser($verilog_file);	
	`cp v_tmp v_data_$cell`;	
	open (VDATA, "v_data_$cell");
	my @v_data0 = (<VDATA>);
	my $ip_row = 2;
	my $ip_item = 1;
	foreach my $line(@v_data0)
	{
	if ($line=~m/(.*)(\()(I|O|IO|P|F)(\))/i)
	{
		$worksheet->write($ip_row,0,$ip_item);
		$worksheet->write($ip_row,1,$1);
		$worksheet->write($ip_row,2,$3);
		$ip_row++;
		$ip_item++;
	}
	}		
	$worksheet = $workbook->add_worksheet("INT_$block_cell");
	$worksheet->write_row(1,1,$data2a_ref,$formatc);
	$worksheet->write_row(1,4,$data2b_ref,$formatd);
	$worksheet->merge_range_type('string','B1:D1', $header,$formatc);
	$worksheet->merge_range_type('string','E1:F1', 'SOURCE/DESTINATION',$formatd); 
	$worksheet->merge_range_type('string','G1:G2', 'COMMENTS',$formata);
	$worksheet->write_string('B1', $header,$formatc);
	$worksheet->write_string('A2', "ITEM",$formata);
	$worksheet->write_comment('A1',"$A1");
	$worksheet->write_comment('B1',"$B1");
	$worksheet->write_comment('C2',"$C2");
	$worksheet->write_comment('D2',"$H2");	
	$worksheet->set_column(0,0,10,$formata);
	$worksheet->set_column(1,3,22,$formatc);
	$worksheet->set_column(4,5,22,$formatd);
	$worksheet->set_column(6,6,30,$formatb);
	my $int_row = 2;
	my $int_item = 1;
	foreach my $line(@v_data0)
	{
		if ($line=~m/(.*)(\()(I|O|IO|P|F)(\))/i)
		{
		$worksheet->write($int_row,0,$int_item);
		$worksheet->write($int_row,1,$1);
		$worksheet->write($int_row,2,$3);
		$int_row++;
		$int_item++;
		}
	}
	`rm v_data_$cell`;
 	}		
	$worksheet = $workbook->add_worksheet("Revision History");
	$worksheet->write_row(0,0,$data3a_ref);
	$worksheet->set_column(0,2,22,$formata);
	$worksheet->set_column(3,3,100,$formatf);
	if (-e $file)
	{
		$worksheet->write(1,0,"1.0");
		$worksheet->write(1,1,"$months[$mon]/$mday/$year_final");
		$worksheet->write(1,2,$user);
		$worksheet->write(1,3,$comment);
	
	
	}	
close (OUT);
return;
}
#-----------------------------------------------------------
# Description: This module parse the connection_file spreadsheet and extract the data
sub gen_multi_con
{
	my @list;
	my @rev_list;
	my @rev_list1;
	my $cell_all;
	my $con_trig = 0;
	@conn_array = split(",",$conn_list);
	my $block;	
	#checking existence of the conn file.
	if (-e "conn_file_$cell.xlsx")
	{
		&con_parser("conn_file_$cell.xlsx");
		`cp rev_tmp REV_$cell`;		
		unlink($ip_tmp);
		unlink($int_tmp);
		unlink($rev_tmp);
		$con_trig = 1;
	}
	foreach $block(@conn_array)
	{if ($cwd1=~m/(.*)($cell)/i)
	{	$file = "$1/$block/conn/conn_file_$block.xlsx";	
		if ($file=~m/(.*)(conn_file_)(.*)(.xlsx)/i)
		{$cell_all = $3}
		if (-e $file)
		{	
			&con_parser($file);
			`cp ip_tmp IP_$cell_all`;
			`cp int_tmp INT_$cell_all`;
			push(@list,"IP_$cell_all","INT_$cell_all");
			unlink($ip_tmp);
			unlink($int_tmp);
			unlink($rev_tmp);
		}
		else{print "$file not found!\n"}
	}
	}	
	use lib "/usr/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi";
	use Excel::Writer::XLSX;
	open(OUT, ">>","conn_file_$cell.xlsx");
	my $workbook = Excel::Writer::XLSX->new("conn_file_$cell.xlsx");
	my $worksheet;	
	my $header;
	my $formata = $workbook->add_format();
	my $formatb = $workbook->add_format();
	my $formatc = $workbook->add_format();
	my $formatd = $workbook->add_format();
	my $formate = $workbook->add_format();
	my $formatf = $workbook->add_format();
	my $formatg = $workbook->add_format();
	foreach my $file_list(@list)
	{
		$worksheet = $workbook->add_worksheet($file_list);	
		$header = "CURRENT BLOCK:$cell_all";
		$formata->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', border => 1, size => 10);
		$formatb->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', border => 1, size => 10);
		$formatc->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'yellow', border => 1, size => 10);
		$formatd->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'lime', border => 1, size => 10);
		$formate->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'gray', border => 1, size => 10);
		$formatf->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', border => 1, size => 10);	
		$formatg->set_format_properties(font => 'Arial',color => 'black', align => 'left', border => 1, size => 10);	
	if ($file_list =~m/(IP_)(.*)/i)
	{			
		$worksheet->write_row(1,1,$data1a_ref,$formatc);
		$worksheet->write_row(1,6,$data1b_ref,$formata);
		$worksheet->write_row(1,8,$data1c_ref,$formatd);	
		$worksheet->write_string('A2', "ITEM",$formata);
		$worksheet->merge_range_type('string','B1:F1', $header,$formatc);
		$worksheet->merge_range_type('string','G1:H1', 'DEFAULT VALUE',$formata);
		$worksheet->merge_range_type('string','I1:M1', 'LAYOUT INFORMATION',$formatd); 
		$worksheet->merge_range_type('string','N1:N2', 'COMMENTS',$formata); 
		$worksheet->write_comment('A1',"$A1");
		$worksheet->write_comment('B1',"$B1");
		$worksheet->write_comment('C2',"$C2");
		$worksheet->write_comment('E2',"$D2");
		$worksheet->write_comment('F2',"$E2");
		$worksheet->write_comment('G2',"$F2");
		$worksheet->write_comment('H2',"$G2");
		$worksheet->write_comment('D2',"$H2");
		$worksheet->set_column(0,0,10,$formata);
		$worksheet->set_column(1,5,22,$formatc);
		$worksheet->set_column(6,7,22,$formata);
		$worksheet->set_column(8,12,22,$formatd);
		$worksheet->set_column(13,13,30,$formatb);
	}
	elsif ($file_list =~m/(INT_)(.*)/i)
	{	
		$worksheet->write_row(1,1,$data2a_ref,$formatc);
		$worksheet->write_row(1,4,$data2b_ref,$formatd);
		$worksheet->merge_range_type('string','B1:D1', $header,$formatc);
		$worksheet->merge_range_type('string','E1:F1', 'SOURCE/DESTINATION',$formatd); 
		$worksheet->merge_range_type('string','G1:G2', 'COMMENTS',$formata);
		$worksheet->write_string('B1', $header,$formatc);
		$worksheet->write_string('A2', "ITEM",$formata);
		$worksheet->write_comment('A1',"$A1");
		$worksheet->write_comment('B1',"$B1");
		$worksheet->write_comment('C2',"$C2");
		$worksheet->write_comment('D2',"$H2");	
		$worksheet->set_column(0,0,10,$formata);
		$worksheet->set_column(1,3,22,$formatc);
		$worksheet->set_column(4,5,22,$formatd);
		$worksheet->set_column(6,6,30,$formatb);
	}
	open (DATA, $file_list);
	my @data = (<DATA>);
	my $row = 2;
	my $item = 1;
	my @line_array;
	my $line_array_ref;
	foreach my $line(@data)
	{
		@line_array =split("\t",$line);
		$line_array_ref=\@line_array;
		$worksheet->write_row($row,1,$line_array_ref);
		$worksheet->write($row,0,$item,$formatb);
		$row++;
		$item++;
	}
		`rm $file_list`;	
	}	
	$worksheet = $workbook->add_worksheet("Revision History");
	$worksheet->write_row(0,0,$data3a_ref);
	$worksheet->set_column(0,2,22,$formata);
	$worksheet->set_column(3,3,130,$formatf);	
	if ($con_trig == 1)
	{
		open (REVA, "REV_$cell");
		my @rev_data1 = (<REVA>);
		my $rev_row = 1;
		my @line1_array;
		my $line1_array_ref;
		foreach my $line1(@rev_data1)
		{
		@line1_array=split("\t",$line1);
		$worksheet->write($rev_row,0,$line1_array[0]);
		$worksheet->write($rev_row,1,$line1_array[1]);
		$worksheet->write($rev_row,2,$line1_array[2]);
		$worksheet->write($rev_row,3,$line1_array[3]);
		$rev_row++;
		}	
		`rm REV_$cell`;	
	}	
	else
	{
		$worksheet->write(1,0,"1.0");
		$worksheet->write(1,1,"$months[$mon]/$mday/$year_final");
		$worksheet->write(1,2,$user);
		$worksheet->write(1,3,$comment);
	}
	if (($con_trig ==1)&& (defined $update))
	{
		print "\n<status> conn file updated - half done\n";
		print "<log> $cwd1\/conn_file_$cell.xlsx\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status> conn file updated - half done\n";
		print LOGFILE "<log> $cwd1\/conn_file_$cell.xlsx\n";
	}
	else
	{
		print "\n<status> conn file created - half done\n";
		print "<log> $cwd1\/conn_file_$cell.xlsx\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status> conn file created - half done\n";
		print LOGFILE "<log> $cwd1\/conn_file_$cell.xlsx\n";
	}	
close(OUT);
return;
}

#------------------------------------------------------------------------
# Description:
# 1. Module that compares the conn files port with the netlists ports 
# 2. This also update the connection_file spreadsheet if netlist ports were updated
sub update_single
{
	$verilog_file = shift;
	`cp ip_tmp ip_tmp_$cell`;
	`cp int_tmp int_tmp_$cell`;
	`cp rev_tmp rev_tmp_$cell`;
	open (IPDATA, "ip_tmp_$cell");
	my @ipdata = (<IPDATA>);
	open (INTDATA, "int_tmp_$cell");
	my @intdata = (<INTDATA>);
	open (REVDATA, "rev_tmp_$cell");
	my @revdata = (<REVDATA>);
	my $nl = new Verilog::Netlist (); 
 	$nl->read_file (filename=>$verilog_file);
	$nl->exit_if_error();
	my $dir;
	my $sig_dir;
	my $sig_name;	
	## Extracting ports at the top module
	&verilog_parser($verilog_file);
	`cp v_tmp v_tmp_$cell`;	
	open (VDATA, "v_tmp_$cell");
	my @vdata = (<VDATA>);
	my @vport;
	foreach my $line(@vdata)
	{chomp ($line);
	push(@vport,"$line")}
	## extracting IP ports in the conn file
	my $xlsx_value;
	my @xlsx_port;
	my @xlsx_port_comb;
	my $xlsx_port_name;
	foreach my $line(@ipdata)
	{
		chomp ($line);
		my @column = split ("\t",$line);
		push (@xlsx_port,$column[0]);
		$column[1] =~s/P/I/;
		$xlsx_port_name =  "$column[0]($column[1])";
		push (@xlsx_port_comb,$xlsx_port_name);
	}
	## extracting Integration ports in the conn file
	my $xlsx_value1;
	my @xlsx_port1;
	my @xlsx_port1_comb;
	my $xlsx_port_name1;
	foreach my $line(@intdata)
	{	chomp ($line);
		my @column = split ("\t",$line);
		push (@xlsx_port1,$column[0]);
		$column[1] =~s/P/I/;
		$xlsx_port_name1 =  "$column[0]($column[1])";
		push (@xlsx_port1_comb,$xlsx_port_name1);
	}
	##checking mismatch between netlist ports and conn file IP ports 
	my %hash;
	for my $key1 (@xlsx_port_comb) 
	{	$hash{$key1}++;
	}
	for my $key1 (@vport) 
	{	if (not exists $hash{$key1})
		{	push (@port_diff,"$key1");
			$count_difference++;
		}
		else 
		{	push (@port_same,"$key1");
		}
	}
	my %hash2;
	for my $key2 (@vdata) 
	{	$hash2{$key2}++;
	}
	for my $key2 (@xlsx_port_comb) 
	{	if (not exists $hash2{$key2})
		{	push (@port_diff2,"$key2");
		}
	}	
	##checking mismatch between IP and integration ports
	my %hash3;
	for my $key3 (@xlsx_port_comb) 
	{	$hash3{$key3}++;
	}
	for my $key3 (@xlsx_port1_comb) 
	{	if (not exists $hash3{$key3})
		{	push (@port_diff3,"$key3");
			$count_difference1++;
		}
		else 
		{	push (@port_same3,"$key3");
		}
	}
	my %hash4;
	for my $key4 (@xlsx_port1_comb) 
	{	$hash4{$key4}++;
	}
	for my $key4 (@xlsx_port_comb) 
	{	if (not exists $hash4{$key4})
		{	push (@port_diff4,"$key4");
		}
	}
	
	my $row = 2;
	my $row1= 1;	
	my $rowa = 2;
	my $row1a= 1;
	my $column = 1;
	my $item = 1;
	my $itema = 1;
	my $no_match = 0;
	my $column1 = 3;
	
	if (($count_difference == 0)&&($count_difference1 ==0))
	{
		if (defined $audit_run)
		{
			&con_parser($file);
			&single_audit($verilog_file);
		}
		else
		{
		print "\n<status> No changes made in the conn file - half done \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status>  No changes made in the conn file - half done \n";
		print LOGFILE "<log> $file\n";
		print LOGFILE "---------------------------\n\n\n";
		}
	
	}
	else
	{
	use Excel::Writer::XLSX;
	open(OUT, ">>$output1");
	my $workbook = Excel::Writer::XLSX->new("$output1");
	########## defining worksheets/tab names #####
	$sheet1 = $workbook->add_worksheet('IP Information');
	$sheet2 = $workbook->add_worksheet('Integration Connectivity');
	$sheet3 = $workbook->add_worksheet('Revision History');
	########## spread sheet metadata #############
	$format0 = $workbook->add_format();
	$format1 = $workbook->add_format();
	$format2 = $workbook->add_format();
	$format3 = $workbook->add_format();
	$format4 = $workbook->add_format();
	$format5 = $workbook->add_format();
	my $header1 = "CURRENT BLOCK:$cell";
	$format0->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', bg_color => 'yellow', border => 1, size => 10);
	$format1->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', border => 1, size => 10);
	$format2->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'yellow', border => 1, size => 10);
	$format3->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'lime', border => 1, size => 10);
	$format4->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'left', bg_color => 'white', border => 1, size => 10);
	$format5->set_format_properties(font => 'Arial',bold => 1,color => 'black', align => 'center', bg_color => 'gray', border => 1, size => 10);
	$sheet1->set_column(0,0,10);
	$sheet1->set_column(1,1,25);
	$sheet1->set_column(1,14,22);
	$sheet2->set_column(0,0,10);
	$sheet2->set_column(1,10,22);
	$sheet3->set_column(0,3,22);
	$sheet1->write_row(1,1,$data1a_ref,$format2);
	$sheet1->write_row(1,6,$data1b_ref,$format1); #updated 7 to 6
	$sheet1->write_row(1,8,$data1c_ref,$format3); #updated 9 to 8
	$sheet2->write_row(1,1,$data2a_ref,$format2);
	$sheet2->write_row(1,4,$data2b_ref,$format3); #updated 8 to 4
	$sheet3->write_row(0,0,$data3a_ref,$format5);
	########## spreadhsheet header ################
	$sheet1->write_string('A2', "ITEM",$format1);
	$sheet1->merge_range_type('string','B1:F1', $header1,$format2);
	$sheet1->merge_range_type('string','G1:H1', 'DEFAULT VALUE',$format4); #updated
	$sheet1->merge_range_type('string','I1:M1', 'LAYOUT INFORMATION',$format3); #updated
	$sheet1->merge_range_type('string','N1:N2', 'COMMENTS',$format1); #updated
	$sheet2->merge_range_type('string','B1:D1', $header1,$format2);
	$sheet2->merge_range_type('string','E1:F1', 'SOURCE/DESTINATION',$format3); #updated
	$sheet2->merge_range_type('string','G1:G2', 'COMMENTS',$format1); #updated
	$sheet2->write_string('B1', $header1,$format2);
	$sheet2->write_string('A2', "ITEM",$format1);
	########## defining comments ##################
	$sheet1->write_comment('A1',"$A1");
	$sheet1->write_comment('B1',"$B1");
	$sheet1->write_comment('C2',"$C2");
	$sheet1->write_comment('E2',"$D2");
	$sheet1->write_comment('F2',"$E2");
	$sheet1->write_comment('G2',"$F2");
	$sheet1->write_comment('H2',"$G2");
	$sheet2->write_comment('D2',"$H2");
	$sheet2->write_comment('A1',"$A1");
	$sheet2->write_comment('B1',"$B1");
	$sheet2->write_comment('C2',"$C2");
	$sheet2->write_comment('D2',"$H2");

	
	if (($count_difference > 0) && ($count_difference1 == 0))
	{print "Updating the $file ...\n\n";
		
		my $port_name;
		my $port_type;
		foreach my $port_name_comb(@port_same)
		{
		if ($port_name_comb =~ m/(.*)\((.*)/i)
			{$port_name=$1;
			foreach my $line(@ipdata)
			{	$line=~s/\t/,/g;
				my @line_1;
				my @line_3;
				my @line_4;
				my $line_2;
				my $line_5;
				my $line_6;
				my $line_1a;
				my $line_3a;
				my $line_4a;
				if ($line =~ m/($port_name),(I|O|IO|P|F),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),/i)
				{	$port_type = $2;
					if (defined $pwr){if ($port_name=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type = "P"}} 
					push (@line_1,$port_type,"$3","$4","$5");
					push (@line_3,"$6","$7");
					push (@line_4,"$8","$9","$10","$11","$12");
					$line_6= $1;
					$line_5= $13;
					$line_1a=\@line_1;	
					$line_3a=\@line_3;	
					$line_4a=\@line_4;				
					$sheet1->write($row,1,$line_6,$format0);	
					$sheet1->write($row,2,$line_1a,$format2);			
					$sheet1->write($row,6,$line_3a,$format1);		
					$sheet1->write($row,8,$line_4a,$format3);		
					$sheet1->write($row,13,$line_5,$format1);	
					$sheet1->write($row,0,$item,$format1);
					$row++;
					$item++;
				}
				else
				{ $no_match = 1;
				}
			}
			}
			foreach my $linea(@intdata)
			{	chomp ($linea);
				$linea=~s/\t/,/g;
				my @linea_1;
				my @linea_2;
				my @linea_3;
				my $linea_4;
				my $linea_5;
				my $linea_1a;
				my $linea_2a;
				my $linea_3a;
				if ($linea =~ m/($port_name),(I|O|IO|P|F),(.*),(.*),(.*),(.*),/i)
				{	$port_type = $2;
					if (defined $pwr){if ($port_name=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type = "P"}} 
					push (@linea_1,$port_type,"$3");
					push (@linea_3,"$4","$5");
					$linea_4= $6;
					$linea_5= $1;
					$linea_1a=\@linea_1;	
					$linea_3a=\@linea_3;				
					$sheet2->write($rowa,1,$linea_5,$format0);	
					$sheet2->write($rowa,2,$linea_1a,$format2);			
					$sheet2->write($rowa,4,$linea_3a,$format3);			
					$sheet2->write($rowa,6,$linea_4,$format1);
					$sheet2->write($rowa,0,$itema,$format1);
					$rowa++;
					$itema++;
				}
				else
				{$no_match = 1}
			}
		}	
		
		#extracting revision history		
		my $rev_num1;
		foreach my $lineb(@revdata)
		{	chomp ($lineb);
			my @lineb_data = split ("\t",$lineb);
			$rev_num1 = $lineb_data[0];
			my $lineb_data1=\@lineb_data;	
			$sheet3->write_row($row1a,0,$lineb_data1,$format4);
			$row1a++;		
		}
		$rev_num1 = $rev_num1+0.1;
		my $rev_comm1 = "New ports added: @port_diff"."Ports deleted: @port_diff2";
		$sheet3->write($row1a,0,$rev_num1,$format4);
		$sheet3->write($row1a,1,"$months[$mon]/$mday/$year_final",$format4);
		$sheet3->write($row1a,2,$user,$format4);
		$sheet3->write($row1a,3,$rev_comm1,$format4);

		if ($no_match==1)
		{	my $port_name_a;
			my $port_type_a;
			foreach my $data_diff(@port_diff)
			{if ($data_diff =~ m/^(.*)\((.*)/i){$port_name_a = $1}
				foreach my $line(@vport)
				{	if ($line =~ m/^($port_name_a)\((.*)\)/i)
					{	$port_type_a = $2;
						if (defined $pwr){if ($port_name_a=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type_a = "P"}} 
						$sheet1->write($row,1,$port_name_a,$format0);
						$sheet1->write($row,2,$port_type_a,$format2);
						$sheet1->write_row($row,3,$data4e_ref,$format2);
						$sheet1->write_row($row,6,$data4c_ref,$format1); #updated 7 to 6
						$sheet1->write_row($row,8,$data4d_ref,$format3); #updated 9 to 8
						$sheet1->write($row,13,"",$format4); #updated 14 to 13
						$sheet1->write($row,0,$item,$format1);
						$sheet2->write($rowa,1,$port_name_a,$format0);
						$sheet2->write($rowa,2,$port_type_a,$format2);
						$sheet2->write($rowa,3,"",$format2);
						$sheet2->write_row($rowa,4,$data4c_ref,$format3); #updated 8 to 4
						$sheet2->write($rowa,6,"",$format4); #updated 10 to 6
						$sheet2->write($rowa,0,$itema,$format1);
						$row++;
						$rowa++;
						$column1++;
						$item++;
						$itema++;
					}
				}
			}
		
		}
		print "[INFO] New ports added in the conn file: @port_diff\n";
		print "[INFO] Ports deleted in the conn file: @port_diff2\n";
		print LOGFILE "[INFO] New ports added in the conn file: @port_diff\n";
		print LOGFILE "[INFO] Ports deleted in the conn file: @port_diff2\n";
		rename ("$file","$file_bak");
		rename ("$output1","$output0");	
		if (defined $audit_run)
		{
			&con_parser($file);
			&single_audit($verilog_file);
		}
		else
		{
		print "\n<status> conn file updated - half done \n";
		print "<log> $file\n";
		print LOGFILE "\n<status> conn file updated - half done \n";
		print LOGFILE "<log> $file\n";
		}
	}	
	
	if (($count_difference1 > 0) && ($count_difference == 0))
	{print "Updating the $file ...\n\n";
		my $port_name;
		my $port_type;
		foreach my $port_name_comb(@port_same3) 
		{
		if ($port_name_comb =~ m/(.*)\((.*)/i)
			{$port_name=$1;
			foreach my $line(@ipdata)
			{	$line=~s/\t/,/g;
				my @line_1;
				my @line_3;
				my @line_4;
				my $line_2;
				my $line_5;
				my $line_6;
				my $line_1a;
				my $line_3a;
				my $line_4a;
				if ($line =~ m/($port_name),(I|O|IO|P|F),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),/i)
				{	$port_type = $2;
					if (defined $pwr){if ($port_name=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type = "P"}} 
					push (@line_1,$port_type,"$3","$4","$5");
					push (@line_3,"$6","$7");
					push (@line_4,"$8","$9","$10","$11","$12");
					$line_6= $1;
					$line_5= $13; 
					$line_1a=\@line_1;	
					$line_3a=\@line_3;	
					$line_4a=\@line_4;				
					$sheet1->write($row,1,$line_6,$format0);	
					$sheet1->write($row,2,$line_1a,$format2);			
					$sheet1->write($row,6,$line_3a,$format1);	
					$sheet1->write($row,8,$line_4a,$format3);		
					$sheet1->write($row,13,$line_5,$format1);	
					$sheet1->write($row,0,$item,$format1);
					$row++;
					$item++;
				}
				else
				{ $no_match = 1;
				}
			}
			}
			foreach my $linea(@intdata)
			{	chomp ($linea);
				$linea=~s/\t/,/g;
				my @linea_1;
				my @linea_2;
				my @linea_3;
				my $linea_4;
				my $linea_5;
				my $linea_1a;
				my $linea_2a;
				my $linea_3a;
				if ($linea =~ m/($port_name),(I|O|IO|P|F),(.*),(.*),(.*),(.*),/i)
				{	$port_type =  $2;
					if (defined $pwr){if ($port_name=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type = "P"}} 
					push (@linea_1,$port_type,"$3");
					push (@linea_3,"$4","$5"); #updated from $8 and $9
					$linea_4= $6; #updated from $10
					$linea_5= $1;
					$linea_1a=\@linea_1;	
					$linea_3a=\@linea_3;				
					$sheet2->write($rowa,1,$linea_5,$format0);	
					$sheet2->write($rowa,2,$linea_1a,$format2);			
					$sheet2->write($rowa,4,$linea_3a,$format3);			
					$sheet2->write($rowa,6,$linea_4,$format1);
					$sheet2->write($rowa,0,$itema,$format1);
					$rowa++;
					$itema++;
				}
				else
				{$no_match = 1}
			}
		}
		
		my $rev_num2;
		foreach my $lineb(@revdata)
		{	chomp ($lineb);
			my @lineb_data = split ("\t",$lineb);
			$rev_num2 = $lineb_data[0];
			my $lineb_data1=\@lineb_data;	
			$sheet3->write_row($row1a,0,$lineb_data1,$format4);
			$row1a++;		
		}
		$rev_num2 = $rev_num2+0.1;
		my $rev_comm2 = "New ports added: @port_diff4"."Ports deleted: @port_diff3";
		$sheet3->write($row1a,0,$rev_num2,$format4);
		$sheet3->write($row1a,1,"$months[$mon]/$mday/$year_final",$format4);
		$sheet3->write($row1a,2,$user,$format4);
		$sheet3->write($row1a,3,$rev_comm2,$format4);


		if ($no_match==1)
		{	my $port_name_a;
			my $port_type_a;
			foreach my $data_diff(@port_diff4)
			{
			if ($data_diff =~ m/^(.*)\((.*)/i)
			{$port_name_a = $1}
				foreach my $line(@vport)
				{	if ($line =~ m/^($port_name_a)\((.*)\)/i)
					{	$port_type_a = $2;
						if (defined $pwr){if ($port_name_a=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type_a = "P"}} 
 						$sheet1->write($row,1,$port_name_a,$format0);
 						$sheet1->write($row,2,$port_type_a,$format2);
 						$sheet1->write_row($row,3,$data4e_ref,$format2);
 						$sheet1->write_row($row,6,$data4c_ref,$format1); #updated 7 to 6
 						$sheet1->write_row($row,8,$data4d_ref,$format3); #updated 9 to 8
 						$sheet1->write($row,13,"",$format4); #updated 14 to 13
 						$sheet1->write($row,0,$item,$format1);
						$sheet2->write($rowa,1,$port_name_a,$format0);
						$sheet2->write($rowa,2,$port_type_a,$format2);
						$sheet2->write($rowa,3,"",$format2);
						$sheet2->write_row($rowa,4,$data4b_ref,$format3); #updated 8 to 4
						$sheet2->write($rowa,6,"",$format4); #updated 10 to 6
						$sheet2->write($rowa,0,$itema,$format1);
						$row++;
						$rowa++;
						$column1++;
						$item++;
						$itema++;
					}
				}
			}
		
		}
		
		print "[INFO] New ports added in the conn file : @port_diff4\n";
		print "[INFO] Ports deleted in the conn file : @port_diff3\n";
		print LOGFILE "[INFO] New ports added in the conn file : @port_diff4\n";
		print LOGFILE "[INFO] Ports deleted in the conn file : @port_diff3\n";			
		rename ("$file","$file_bak");
		rename ("$output1","$output0");	
		if (defined $audit_run)
		{
			&con_parser($file);
			&single_audit($verilog_file);
		}
		else
		{
		print "\n<status> conn file updated - half done \n";
		print "<log> $file\n";
		print LOGFILE "\n<status>  conn file updated - half done \n";
		print LOGFILE "<log> $file\n";
		}
	}
	if (($count_difference1 > 0) && ($count_difference > 0))
	{ print "Updating the $file ...\n\n";
		my $port_name;
		my $port_type;
		foreach my $port_name_comb(@port_same)
		{
		if ($port_name_comb =~ m/(.*)\((.*)/i)
			{$port_name=$1;
			foreach my $line(@ipdata)
			{	$line=~s/\t/,/g;
				my @line_1;
				my @line_3;
				my @line_4;
				my $line_2;
				my $line_5;
				my $line_6;
				my $line_1a;
				my $line_3a;
				my $line_4a;
				if ($line =~ m/($port_name),(I|O|IO|P|F),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),(.*),/i)
				{	$port_type = $2;
					if (defined $pwr){if ($port_name=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type = "P"}} 
					push (@line_1,"$port_type","$3","$4","$5");
					push (@line_3,"$6","$7");
					push (@line_4,"$8","$9","$10","$11","$12");
					$line_6= $1;
					$line_5= $13; #updated from $14
					$line_1a=\@line_1;	
					$line_3a=\@line_3;	
					$line_4a=\@line_4;				
					$sheet1->write($row,1,$line_6,$format0);	
					$sheet1->write($row,2,$line_1a,$format2);			
					$sheet1->write($row,6,$line_3a,$format1);	#updated from 7		
					$sheet1->write($row,8,$line_4a,$format3);	#updated from 9		
					$sheet1->write($row,13,$line_5,$format1);	#updated from 14
					$sheet1->write($row,0,$item,$format1);
					$row++;
					$item++;
				}
				else
				{ $no_match = 1;
				}
			}
		}
		}
		my $port_name_int;
		my $port_type_int;
		foreach my $port_name_comb(@port_same3)
		{
		if ($port_name_comb =~ m/(.*)\((.*)/i)
			{$port_name_int=$1}
			foreach my $linea(@intdata)
			{	chomp ($linea);
				$linea=~s/\t/,/g;
				my @linea_1;
				my @linea_2;
				my @linea_3;
				my $linea_4;
				my $linea_5;
				my $linea_1a;
				my $linea_2a;
				my $linea_3a;
				if ($linea =~ m/($port_name_int),(I|O|IO|P|F),(.*),(.*),(.*),(.*),/i)
				{	$port_type_int = $2;
					if (defined $pwr){if ($port_name_int=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type_int = "P"}} 
					push (@linea_1,"$port_type_int","$3");
					push (@linea_3,"$4","$5"); #updated from $8 and $9
					$linea_4= $6; #updated from $10
					$linea_5= $1;
					$linea_1a=\@linea_1;	
					$linea_3a=\@linea_3;				
					$sheet2->write($rowa,1,$linea_5,$format0);	
					$sheet2->write($rowa,2,$linea_1a,$format2);			
					$sheet2->write($rowa,4,$linea_3a,$format3);			
					$sheet2->write($rowa,6,$linea_4,$format1);
					$sheet2->write($rowa,0,$itema,$format1);
					$rowa++;
					$itema++;
				}
			}
		}
		
		# extracting revision history
		my $rev_num3;
		foreach my $lineb(@revdata)
		{	
			chomp ($lineb);
			my @lineb_data = split ("\t",$lineb);
			$rev_num3 = $lineb_data[0];
			my $lineb_data1=\@lineb_data;	
			$sheet3->write_row($row1a,0,$lineb_data1,$format4);
			$row1a++;		
		}
		$rev_num3 = $rev_num3+0.1;
		my $rev_comm3 = "New ports added: @port_diff"."Ports deleted: @port_diff2";
		$sheet3->write($row1a,0,$rev_num3,$format4);
		$sheet3->write($row1a,1,"$months[$mon]/$mday/$year_final",$format4);
		$sheet3->write($row1a,2,$user,$format4);
		$sheet3->write($row1a,3,$rev_comm3,$format4);
		
		#Only use the no match in ip_ports and will update both IP and integration
		if ($no_match==1)
		{	my $port_name_a;
			my $port_type_a;
			foreach my $data_diff(@port_diff)
			{if ($data_diff =~ m/^(.*)\((.*)/i)
			{$port_name_a = $1}
				foreach my $line(@vport)
				{	if ($line =~ m/^($port_name_a)\((.*)\)/i)
					{	$port_type_a = $2;
						if (defined $pwr){if ($port_name_a=~ m/(vcc|vccpg|vccr|vss|vdd|sgnd|spwr|vgnd|vsup)/){$port_type_a = "P"}} 
						$sheet1->write($row,1,$port_name_a,$format0);
						$sheet1->write($row,2,$port_type_a,$format2);
						$sheet1->write_row($row,3,$data4e_ref,$format2);
						$sheet1->write_row($row,6,$data4c_ref,$format1);
						$sheet1->write_row($row,8,$data4d_ref,$format3);
						$sheet1->write($row,13,"",$format4); 
						$sheet1->write($row,0,$item,$format1);
						$sheet2->write($rowa,1,$port_name_a,$format0);
						$sheet2->write($rowa,2,$port_type_a,$format2);
						$sheet2->write($rowa,3,"",$format2);
						$sheet2->write_row($rowa,4,$data4c_ref,$format3);
						$sheet2->write($rowa,6,"",$format4);
						$sheet2->write($rowa,0,$itema,$format1);
						$row++;
						$rowa++;
						$column1++;
						$item++;
						$itema++;
					}
				}
			}
		
		}
		print "[INFO] New ports added in the conn file: @port_diff\n";
		print "[INFO] Ports deleted in the conn file: @port_diff2\n";
		print LOGFILE "[INFO] New ports added in the conn file: @port_diff\n";
		print LOGFILE "[INFO] Ports deleted in the conn file: @port_diff2\n";				
		rename ("$file","$file_bak");
		rename ("$output1","$output0");	
		if (defined $audit_run)
		{
			&con_parser($file);
			&single_audit($verilog_file);
		}
		else
		{
		print "\n<status> conn file updated - half done \n";
		print "<log> $file\n";
		print LOGFILE "\n<status>  conn file updated - half done \n";
		print LOGFILE "<log> $file\n";
		}
	}	
	}
	
close (OUT);
return;
}
# -------------------------------------------------------------------------------
# audit submodule
# Description:
# 1. Module that compares the conn files port with the netlists ports 

sub single_audit
{
	$verilog_file = shift;
	`cp ip_tmp ip_tmp_$cell`;
	`cp int_tmp int_tmp_$cell`;
	`cp rev_tmp rev_tmp_$cell`;
	open (IPDATA, "ip_tmp_$cell");
	my @ipdata = (<IPDATA>);
	open (INTDATA, "int_tmp_$cell");
	my @intdata = (<INTDATA>);
	open (REVDATA, "rev_tmp_$cell");
	my @revdata = (<REVDATA>);
	my $nl = new Verilog::Netlist (); 
 	$nl->read_file (filename=>$verilog_file);
	$nl->exit_if_error();
	my $dir;
	my $sig_dir;
	my $sig_name;	
	## Extracting ports at the top module
	&verilog_parser($verilog_file);
	`cp v_tmp v_tmp_$cell`;	
	open (VDATA, "v_tmp_$cell");
	my @vdata = (<VDATA>);
	my @vport;
	foreach my $line(@vdata)
	{chomp ($line);
	push(@vport,"$line")}
	## extracting IP ports in the conn file
	my $xlsx_value;
	my @xlsx_port;
	my @xlsx_port_comb;
	my $xlsx_port_name;
	foreach my $line(@ipdata)
	{
		chomp ($line);
		my @column = split ("\t",$line);
		push (@xlsx_port,$column[0]);
		$column[1] =~s/P/I/;
		$xlsx_port_name =  "$column[0]($column[1])";
		push (@xlsx_port_comb,$xlsx_port_name);
	}
	## extracting Integration ports in the conn file
	my $xlsx_value1;
	my @xlsx_port1;
	my @xlsx_port1_comb;
	my $xlsx_port_name1;
	foreach my $line(@intdata)
	{	chomp ($line);
		my @column = split ("\t",$line);
		push (@xlsx_port1,$column[0]);
		$column[1] =~s/P/I/;
		$xlsx_port_name1 =  "$column[0]($column[1])";
		push (@xlsx_port1_comb,$xlsx_port_name1);
	}
	##checking mismatch between netlist ports and conn file IP ports 
	my %hash;
	for my $key1 (@xlsx_port_comb) 
	{	$hash{$key1}++;
	}
	for my $key1 (@vport) 
	{	if (not exists $hash{$key1})
		{	push (@port_diff,"$key1");
			$count_difference++;
		}
		else 
		{	push (@port_same,"$key1");
		}
	}
	my %hash2;
	for my $key2 (@vdata) 
	{	$hash2{$key2}++;
	}
	for my $key2 (@xlsx_port_comb) 
	{	if (not exists $hash2{$key2})
		{	push (@port_diff2,"$key2");
		}
	}	
	##checking mismatch between IP and integration ports
	my %hash3;
	for my $key3 (@xlsx_port_comb) 
	{	$hash3{$key3}++;
	}
	for my $key3 (@xlsx_port1_comb) 
	{	if (not exists $hash3{$key3})
		{	push (@port_diff3,"$key3");
			$count_difference1++;
		}
		else 
		{	push (@port_same3,"$key3");
		}
	}
	my %hash4;
	for my $key4 (@xlsx_port1_comb) 
	{	$hash4{$key4}++;
	}
	for my $key4 (@xlsx_port_comb) 
	{	if (not exists $hash4{$key4})
		{	push (@port_diff4,"$key4");
		}
	}
	if ($count_difference == 0)
	{$audit0a = 1}
	if ($count_difference > 0) 
	{$audit1a = 1}	
	if ($count_difference1 == 0) 
	{$audit2a = 1}	
	if (($count_difference1 > 0) & ($count_difference == 0))
	{$audit3a = 1}
	
	# Printing mismatch between Netlist, IP and Integration
	if (defined $audit_run)
	{
	if (($count_difference1 > 0) & ($count_difference > 0))
	{ 	print "\nRunning audit..\n\n";
		print "[ERROR-003] Mismatch in the netlist ports: @port_diff\n";
		print "[ERROR-004] Mismatch between netlists and conn file IP ports: @port_diff2\n";
		print "[ERROR-005] Mismatch in the conn file between IP and Integration ports: @port_diff3\n";
		print LOGFILE "\nRunning audit..\n\n";
		print LOGFILE "[ERROR-003] Mismatch in the netlist ports: @port_diff\n";
		print LOGFILE "[ERROR-004] Mismatch between netlists and conn file IP ports: @port_diff2\n";
		print LOGFILE "[ERROR-005] Mismatch in the conn file between IP and Integration ports: @port_diff3\n";
		print "\n<status> failed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";	
		print LOGFILE "\n<status> failed \n";
		print LOGFILE "<log> $file\n";
	}
	# Printing alignment between Netlist, IP and Integration
	if (($audit0a == 1) & ($audit2a == 1 ))
	{	print "\nRunning audit..\n\n";
		print "[INFO] No changes in netlist ports. \n";
		print "[INFO] Matched between netlist and conn file IP ports. \n";
		print "[INFO] Matched between IP and Integration ports. \n";
		print "\n<status> passed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\nRunning audit..\n\n";
		print LOGFILE "[INFO] No changes in netlist ports\n";
		print LOGFILE "[INFO] Matched between netlist and conn file IP ports. \n";
		print LOGFILE "[INFO] Matched between IP and Integration ports. \n";
		print LOGFILE "\n<status> passed \n";
		print LOGFILE "<log> $file\n";
	}
	# Printing mismatch between IP and Integration
	if (($audit0a == 1) & ($audit3a == 1 ))
	{	print "\nRunning audit..\n\n";
		print "[INFO] No changes in netlist ports. \n";
		print "[INFO] Matched between netlist and conn file IP ports. \n";
		print "[ERROR-005] Mismatch in the conn file between IP and Integration ports: @port_diff3\n";
		print "\n<status> failed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\nRunning audit..\n\n";
		print LOGFILE "[INFO] No changes in netlist ports\n";
		print LOGFILE "[INFO] Matched between netlist and connection IP ports. \n";
		print LOGFILE "[ERROR-005] Mismatch in the conn file between IP and Integration ports: @port_diff3\n";
		print LOGFILE "\n<status> failed \n";
		print LOGFILE "<log> $file\n";
	}
	# Printing mismatch between Netlist and IP
	if (($audit1a == 1 ) & ($audit2a == 1))
	{	print "\nRunning audit..\n\n";
		print LOGFILE "\nRunning audit..\n\n";
		print "[ERROR-003] Mismatch in the netlist ports: @port_diff\n";
		print "[ERROR-004] Mismatch between netlists and conn file IP ports: @port_diff2\n";
		print LOGFILE "[ERROR-003] Mismatch in the netlist ports: @port_diff\n";
		print LOGFILE "[ERROR-004] Mismatch between netlists and conn file IP ports: @port_diff2\n";
		print "\n<status> failed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";	
		print LOGFILE "\n<status> failed \n";
		print LOGFILE "<log> $file\n";
	}
	}
return;			
}
	
# -------------------------------------------------------------------------------
# audit conn file containing multiple submodule
# Description:
# 1. Module that compares the conn files port with the netlists ports 

sub audit_multi
{
	$file =shift;	
	&con_parser($file);
	`cp ip_tmp ip_tmp_$cell`;
	open (IPDATA, "ip_tmp_$cell");
	my @ipdata = (<IPDATA>);
	`cp int_tmp int_tmp_$cell`;
	open (INTDATA, "int_tmp_$cell");
	my @intdata = (<INTDATA>);
	my $block_list;
	if (defined $conn_list)
	{$block_list = "$conn_list"}
	elsif (defined $verilog_list)
	{$block_list = "$verilog_list"}
	my @list_array = split(",",$block_list);	
	my @ip_port;
	my @int_port;
	my $audit0a;
	my $audit1a;
	my $audit2a;
	my $audit3a;
	my $count_difference = 0;
	my $count_difference1 = 0;	
	foreach my $list (@list_array)
	{	foreach my $ip_line (@ipdata)
		{$ip_line =~s/P|F/I/;
		if ($ip_line =~ m/^($list)\t(.*)\t(O|I|IO|P|F)\t(.*)/i)
		{
		push (@ip_port,"$2($3)\n");
		$cell = $list;
		&verilog_parser($verilog_file);	
		`cp v_tmp v_tmp_$cell`;
		}
		}
		foreach my $int_line (@intdata)
		{$int_line =~s/P|F/I/;
		if ($int_line =~ m/^($list)\t(.*)\t(O|I|IO|P|F)\t(.*)/i)
		{
		push (@int_port,"$2($3)\n");
		}
		}
	open (V_TMP_DATA, "v_tmp_$cell");
	my @v_tmp = (<V_TMP_DATA>);
	my %hash;
	my @port_diff;
	my @port_same;	
	for my $key1 (@ip_port) 
	{	$hash{$key1}++;
	}
	for my $key1 (@v_tmp) 
	{	if (not exists $hash{$key1})
		{	push (@port_diff,"$key1");
			$count_difference++;
		}
		else 
		{	push (@port_same,"$key1");
		}
	}
	my %hash2;
	my @port_diff2;
	for my $key2 (@v_tmp) 
	{	$hash2{$key2}++;
	}
	for my $key2 (@ip_port) 
	{	if (not exists $hash2{$key2})
		{	push (@port_diff2,"$key2");
		}
	}
	my %hash3;
	my @port_diff3;
	my @port_same3;
	for my $key3 (@ip_port) 
	{	$hash{$key3}++;
	}
	for my $key3 (@int_port) 
	{	if (not exists $hash3{$key3})
		{	push (@port_diff3,"$key3");
			$count_difference1++;
		}
		else 
		{	push (@port_same3,"$key3");
		}
	}
	my %hash4;
	my @port_diff4;
	for my $key4 (@int_port) 
	{	$hash4{$key4}++;
	}
	for my $key4 (@ip_port) 
	{	if (not exists $hash4{$key4})
		{	push (@port_diff4,"$key4");
		}
	}
	
	if ($count_difference == 0)
	{$audit0a = 1}
	if ($count_difference > 0) 
	{$audit1a = 1}	
	if ($count_difference1 == 0) 
	{$audit2a = 1}	
	if (($count_difference1 > 0) & ($count_difference == 0))
	{$audit3a = 1}
	
	# Printing alignment between Netlist, IP and Integrationsss
	if (($count_difference1 > 0) & ($count_difference > 0))
	{ 	print "\nRunning audit for module $cell..\n\n";
		print "[ERROR-003] Mismatch in the netlist ports for module $cell: @port_diff\n";
		print "[ERROR-004] Mismatch between netlists and conn file IP ports for module $cell: @port_diff2\n";
		print "[ERROR-005] Mismatch in the conn file between IP and Integration ports for module $cell: @port_diff3\n";
		print LOGFILE "\nRunning audit for module $cell..\n\n";
		print LOGFILE "[ERROR-003] Mismatch in the netlist ports for module $cell: @port_diff\n";
		print LOGFILE "[ERROR-004] Mismatch between netlists and conn file IP ports for module $cell: @port_diff2\n";
		print LOGFILE "[ERROR-005] Mismatch in the conn file between IP and Integration ports for module $cell: @port_diff3\n";
	}
	# Printing alignment between Netlist, IP and Integration
	if (($audit0a == 1) & ($audit2a == 1 ))
	{	print "\nRunning audit for module $cell..\n\n";
		print "[INFO] No changes in netlist ports for module $cell. \n";
		print "[INFO] Matched between netlist and conn file IP ports for module $cell. \n";
		print "[INFO] Matched between IP and Integration ports for module $cell. \n";
		print LOGFILE "\nRunning audit for module $cell..\n\n";
		print LOGFILE "[INFO] No changes in netlist ports for module $cell\n";
		print LOGFILE "[INFO] Matched between netlist and conn file IP ports for module $cell. \n";
		print LOGFILE "[INFO] Matched between IP and Integration ports for module $cell. \n";
	}
	# Printing mismatch between IP and Integration
	if (($audit0a == 1) & ($audit3a == 1 ))
	{	print "\nRunning audit for module $cell..\n\n";
		print "[INFO] No changes in netlist ports for module $cell. \n";
		print "[INFO] Matched between netlist and conn file IP ports for module $cell. \n";
		print "[ERROR-005] Mismatch in the conn file between IP and Integration ports for module $cell: @port_diff3\n";
		print LOGFILE "\nRunning audit for module $cell..\n\n";
		print LOGFILE "[INFO] No changes in netlist ports for module $cell\n";
		print LOGFILE "[INFO] Matched between netlist and connection IP ports for module $cell. \n";
		print LOGFILE "[ERROR-005] Mismatch in the conn file between IP and Integration ports for module $cell: @port_diff3\n";
	}
	# Printing mismatch between Netlist and IP
	if (($audit1a == 1 ) & ($audit2a == 1))
	{	print "\nRunning audit for module $cell..\n\n";
		print LOGFILE "\nRunning audit for module $cell..\n\n";
		print "[ERROR-003] Mismatch in the netlist ports for module $cell: @port_diff\n";
		print "[ERROR-004] Mismatch between netlists and conn file IP ports for module $cell: @port_diff2\n";
		print LOGFILE "[ERROR-003] Mismatch in the netlist ports for module $cell: @port_diff\n";
		print LOGFILE "[ERROR-004] Mismatch between netlists and conn file IP ports for module $cell: @port_diff2\n";
	}
	#`rm v_tmp_$cell`;	
	}
	#`rm v_tmp*`;
	`rm ip_tmp*`;
	`rm int_tmp*`;
	`rm rev_tmp*`;
	
	if (($count_difference1 > 0) & ($count_difference > 0))
	{ 
		print "\n<status> failed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";	
		print LOGFILE "\n<status> failed \n";
		print LOGFILE "<log> $file\n";
	}
	# Printing alignment between Netlist, IP and Integration
	if (($audit0a == 1) & ($audit2a == 1 ))
	{	
		print "\n<status> passed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status> passed \n";
		print LOGFILE "<log> $file\n";
	}
	# Printing mismatch between IP and Integration
	if (($audit0a == 1) & ($audit3a == 1 ))
	{
		print "\n<status> failed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";
		print LOGFILE "\n<status> failed \n";
		print LOGFILE "<log> $file\n";
	}
	# Printing mismatch between Netlist and IP
	if (($audit1a == 1 ) & ($audit2a == 1))
	{	
		print "\n<status> failed \n";
		print "<log> $file\n";
		print "---------------------------\n\n\n";	
		print LOGFILE "\n<status> failed \n";
		print LOGFILE "<log> $file\n";
	}
	
		
return;
}

######################## error submodule #####################
sub error {
	my $error = shift;
	die "-----------------------------------------------------	
USAGE:
	create_connection_spreadsheet.pl
	Requried:	
		[-s]        ------------------------ Argument to create, audit and update conn file for IPs containing single block
		[-m]        ------------------------ Argument to create, audit and update conn file for IPs containing multiple blocks
		[-c <conn_list> -------------------- Argument defining input conn files of IP with multiple blocks to be used. Should be define along with -m argument
		[-v <verilog_list> ----------------- Argument defining input verilog files for IPs containing multiple blocks. Should be define along with -m argument		
	Optional:
		[-p <path>] ------------------------ Refers to the user's desired path where to run the tool
		[-pdef]     ------------------------ Argument to define power pins
		[-update]   ------------------------ Argument for updating the conn file
		[-audit]    ------------------------ Argument for auditing the conn file
		[-h|help]   ------------------------ Run this message to display help file.		
SAMPLE:
	create_connection_spreadsheet.pl -s or create_connection_spreadsheet.pl -s -pdef -audit -update 
	  or
	create_connection_spreadsheet.pl -m -c|-v ioslm_bankref_g,ioslm_SUMB_i2cr -pdef -audit 
	  or
	create_connection_spreadsheet.pl -p /ldc/projects/IP/ip_umc40lp_9M2T1H0A1U_mdkfdk_ver01/ghusaya1/workarea/glad_automation/conn
	  or
	create_connection_spreadsheet.pl -p /ldc/projects/IP/ip_umc40lp_9M2T1H0A1U_mdkfdk_ver01/ghusaya1/workarea/glad_automation/conn -update
	  or
	create_connection_spreadsheet.pl -p /ldc/projects/IP/ip_umc40lp_9M2T1H0A1U_mdkfdk_ver01/ghusaya1/workarea/glad_automation/conn -update -audit
	  or 
	create_connection_spreadsheet.pl -h|help
-----------------------------------------------------\n";
exit (1);
}
####################### parameter submodule ##################
sub parameter {
	my $param = shift;
	if ($param =~ /^--?/) {	die "\n[ERROR] Unknown parameter: $param\n" }
	else { push @opt_files, "$param" }
return;
}
##############################################################

####################### usage submodule ######################
sub usage {
print <<EOH;
--------------------------------------------------------------------------------------------------------
DESCRIPTION
create_connection_spreadsheet.pl	- A tool that parse an input Verilog file and generate a conn file template with complete list of IP ports.
		- This file constructs the following:
			(1) IP Information with port list and port type
			(2) Integration Connectivity template
			(3) Revision History template
		- The tool is also capable of updating the conn file whenever there are updates in the functional model port while retaining the initial data.

USAGE:
	create_connection_spreadsheet.pl
	
	Requried:	
		[-s]        ------------------------ Argument to create, audit and update conn file for IPs containing single block
		[-m]        ------------------------ Argument to create, audit and update conn file for IPs containing multiple blocks
		[-c <conn_list> -------------------- Argument defining input conn files of IP with multiple blocks to be used. Should be define along with -m argument
		[-v <verilog_list> ----------------- Argument defining input verilog files for IPs containing multiple blocks. Should be define along with -m argument
		
	Optional:
		[-p <path>] ------------------------ Refers to the user's desired path where to run the tool
		[-pdef]     ------------------------ Argument to define power pins
		[-update]   ------------------------ Argument for updating the conn file
		[-audit]    ------------------------ Argument for auditing the conn file
		[-h|help]   ------------------------ Run this message to display help file.

SCOPE AND LIMITATIONS
	(1) Generates a conn file template in xlsx format containing :
		- IP Information with port list and port type
		- Integration Connectivity template
		- Revision History template
	(2) Capable of updating the conn file once there are updates in the IP's functional model ports and user's argument -update was defined
		- Ports in the previous conn file no longer exists in the latest functional model will be automatically deleted
		- New ports that exists in the functional model will be automatically added in the conn file.
		- A new conn file will be generated with file name 'conn_file_<ip_name>.xlsx'.
		- The previous conn file will be considered as backup file by default renamed as 'conn_file_bak<ip_name>.xlsx'.
	(3) In case no updates made on the functional model ports, no update will be made in the conn file even if -update argument was provided
	(4) By default, the tool prompts if there is mismatch between netlist's ports and current conn file ports
	(5) Must be invoked in the 'conn' directory. 
	(6) By default, uses the current working directory but have an option to use a -p argument to define where to run the script
	(7) The output file 'conn_file_<ip_name>.xlsx' will be generated in the 'conn' directory per IP.
	(8) IP directory structure must be strictly followed.

Developer: rrita [IP Factory,LMN]
--------------------------------------------------------------------------------------------------------
EOH
exit(1);
}

__END__

