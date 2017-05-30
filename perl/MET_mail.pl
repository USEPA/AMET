#!/usr/bin/perl
#
#######################################################
#		Power List version 1.5
#
#     	Created by: Solution Scripts 
# 		Email: solutions@solutionscripts.com
#		Web: http://solutionscripts.com
#
#######################################################
#
#
# COPYRIGHT NOTICE:
#
# Copyright 1997-2000 Solution Scripts  All Rights Reserved.
#
# This program is being distributed as freeware.  It may be used and
# modified free of charge, so long as this copyright notice, the header 
# above and all the footers in the program that give us credit remain 
# intact. Please also send us an email, and let me know 
# where you are using this script. 
#
# By using this program you agree to indemnify Solution Scripts from any liability.
#
# Selling the code for this program without prior written consent is
# expressly forbidden.  Obtain permission before redistributing this
# program over the Internet or in any other medium.  In all cases
# copyright and header must remain intact.
#
######################################################
########### YOU MUST CHANGE THE FOLLOWING ##########

$name_list = "Your sites Mailing List";
	# THE NAME OF YOUR MAILING LIST

$your_email = "webmaster\@yoursite.com";
	# YOUR EMAIL ADDRESS
	# don't forget the \ before @

$your_name = "Joe Smith";
	# YOUR NAME 
	# Will show up in the from field 
	# of all emails sent
	
$name_url ="http://yoursite.com";
	#THE URL OF YOUR SITE

$name_home = "your sites name";
	#YOUR COMPANY OR SITE NAME
	
$mail_prog = "/usr/sbin/sendmail";
     	# PATH TO MAILER PROGRAM:
     	# This has to point to your sendmail program. If your server does not
     	# have sendmail, you may need to modify the open(MAIL,"|$mailprog -t");
     	# lines in all of the scripts to support whatever format your server
     	# email system requires. If you are not sure, ask your server 
     	# administrator. If you have a virtual domain with your own root 
     	# directory, look in the /usr/sbin ,  /usr/lib, /usr/bin, and similar
     	# directories, for a program named sendmail. If it does not exist, 
     	# ask your server admin what is the correct calling method. This is a
     	# server dependent problem, and we at Solution Scripts cannot help you with 
     	# this. If you have other working scripts that send email, look at 
     	# them for clues.

$remove_link = 1;
	# This will put a link at the bottom of all emails sent out, where a user can click on
	# to automatically be removed from your mailing list. Set to 1 for on, 0 for off.


###################################
## ADVANCED CONFIGURATION ##
###################################


	## COLOR OPTIONS ##
	# The following five variables allow you to customize the look of Power List
	# by changing the colors of the table backgrounds and the text throughout the 
	# Script. Simply enter the color desired, either by name or its hex number
	# ie: "white" or "#FFFFFF"
	
$table_head_bg = "DARKSLATEBLUE";
	# Background color of the small header row of the table
	
$table_head_text = "white";
	# Color of the text in the table header

$table_body_bg = "#C0C0C0";
	# Background color of the main body of the table
	
$table_body_text = "black";
	# Color of the text in the body of the table

$body_tag = qq~
	<BODY BGCOLOR="white" TEXT="black" link="white" vlink="white">
~;
	# Body tag used throughout the program. Change the body tag to however
	# you like.


$data_path = "";
	# (OPTIONAL)
	# Directory path to where you want the two data files stored.
	# EXAMPLE - $data_path = "/home/httpd/html/powerlist";
	
$address_file = "";
	# (OPTIONAL)
	# Name of file where email addresses are stored.
	# If left blank, address.txt is used.
	# EXAMPLE - $address_file = "emailsaddrs.txt";




##############################################################################
# CHANGE NO MORE

$version = "1.5";

$thisurl = $ENV{'SCRIPT_NAME'};
$mail_url = $ENV{'SERVER_NAME'};

$address_file = "address.txt" unless $address_file;
$pwd_file = "password.txt" unless $pwd_file;

$address_file = "$data_path/$address_file" if $data_path;
$pwd_file = "$data_path/$pwd_file" if $data_path;
 

read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
@pairs = split(/&/, $buffer);
foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	if ($INPUT{$name}) { $INPUT{$name} = $INPUT{$name}.",".$value; }
	else { $INPUT{$name} = $value; }
}

unless ($INPUT{'email'}) { 
	print "Content-type: text/html \n\n";
	&Top;
}

$temp=0;
$temp=$ENV{'QUERY_STRING'};
if ($temp) {
	$INPUT{'address'} = $temp;
	&remove;
}

if ($INPUT{'email'}) { &email; }
elsif ($INPUT{'action'} eq "subscribe") { &subscribe; }
elsif ($INPUT{'action'} eq "remove") { &remove; }
elsif ($INPUT{'newpass'}) { &newpass; }
elsif ($INPUT{'delete_select'}) { &delete_select; }
elsif ($INPUT{'delete_final'}) { &delete_final; }
elsif ($INPUT{'sendemail'}) { &sendemail; }
elsif ($INPUT{'address'}) { &subscribe; }
else { &admin; }
exit;

########### MAIN ADMIN SCREEN ##########
sub admin {

open (PASSWORD, "$pwd_file");
$password = <PASSWORD>;
close (PASSWORD);
chop ($password) if ($password =~ /\n$/);

if (!$password) {
	print qq~
	<table cellspacing=0 border=1 cellpadding =5 width=500>
	<TR bgcolor="$table_head_bg"><TD>
	<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Set Admin Password
	</B></FONT>
	</TD></TR>
	<TR bgcolor="$table_body_bg">
	<TD>
	<BR>
	<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
	Before you can do anything else,
	you'll need to set your administrative password.
	This will allow you to use the administrative functions,
	<HR noshade size=1 width=85%>
	Please enter your desired password below.
	(Enter it twice.)</font>
	<FORM METHOD=POST ACTION=$thisurl>
	<CENTER><INPUT TYPE=SUBMIT NAME=newpass VALUE="Set Admin Password:">
	<INPUT TYPE=PASSWORD NAME=passad SIZE=10>
	<INPUT TYPE=PASSWORD NAME=passad2 SIZE=10>
	</CENTER></FORM>
	</TD></TR></TABLE><BR>
	~;
	&Bottom;
	exit;
}
	
$numemail=0;
	
open(LIST,"$address_file");
@addresses=<LIST>;
close(LIST);
	
$numemail = push(@addresses);
	
print qq~
<form action="$thisurl" method=post>
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Add or remove an email address
</FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<BR>

<input type=text name="address" size=30><br>
<input type=radio name=action value=subscribe checked> 
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
Subscribe | Unsubscribe <input type=radio name=action value=remove><BR>
</FONT>
<br><input type="submit" value="Update">
</form></TD></TR></TABLE>
		
<BR><BR>
		
<form action="$thisurl" method=post>
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Admin Functions
</FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<BR>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
Send out an email to <B>$numemail</B> emails<br>
</FONT>
<INPUT TYPE="SUBMIT" NAME="sendemail" VALUE="Send Email">
<BR><BR>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
Delete selected addresses from database</FONT>
<BR>
<INPUT TYPE="SUBMIT" NAME="delete_select" VALUE="Delete Selected">
<BR><BR>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">Enter admin password<BR><i>Needed for both of above</I></FONT>
<BR>
<input type=password name="password" size=20>
</form></TD></TR></TABLE>
~;

&Bottom;
exit;

}

########## SET NEW PASSWORD ##########
sub newpass {
	
unless ($INPUT{'passad'} eq $INPUT{'passad2'}) {
	print qq~
	<table cellspacing=0 border=1 cellpadding =5 width=400>
	<TR bgcolor="$table_head_bg"><TD>
	<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Error!!
	</FONT>
	</TD></TR>
	<TR bgcolor="$table_body_bg">
	<TD><FONT SIZE="-1" FACE="Arial" color="$table_body_text">
	<BR>Your administrative password was 
	not set, as the two entries were different!</TD></TR></TABLE>
	~;
	&Bottom;
	exit;
}

if ($INPUT{'passad'}) {
	$newpassword = crypt($INPUT{'passad'}, aa);
}
else {
	print qq~
	<table cellspacing=0 border=1 cellpadding =5 width=400>
	<TR bgcolor="$table_head_bg"><TD>
	<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Error!!
	</B></FONT>
	</TD></TR>
	<TR bgcolor="$table_body_bg">
	<TD>
	<BR><FONT SIZE="-1" FACE="Arial" color="$table_body_text">
	You must enter a password!</FONT></TD></TR></TABLE>
	~;
	&Bottom;
	exit;
}

if (-e "$pwd_file") {
	print qq~
	<table cellspacing=0 border=1 cellpadding =5 width=400>
	<TR bgcolor="$table_head_bg"><TD>
	<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Error!!
	</B></FONT>
	</TD></TR>
	<TR bgcolor="$table_body_bg">
	<TD>
	<BR><FONT SIZE="-1" FACE="Arial" color="$table_body_text">
	Password already exists<BR><BR>
	To set a new password manually delete the 
	<BR>
	$pwd_file file </FONT>
	</TD></TR></TABLE>
	~;
	&Bottom;
	exit;
}

open (PASSWORD, ">$pwd_file") || &error(1);
print PASSWORD "$newpassword";
close (PASSWORD);

print qq~
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Password Set
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD><FONT SIZE="-1" FACE="Arial" color="$table_body_text">
<BR>Your administrative password has been set.</FONT></TD></TR></TABLE>
<BR>
~;
&admin;
exit;
}

########## SUBSCRIBE NEW EMAILS ##########
sub subscribe {

unless ($INPUT{'address'}=~/\@/)   { 
	&error_pretty("You entered an invalid email address, please go back and try again");
}

open(LIST,"$address_file");
@addresses=<LIST>;
close(LIST);

@add = grep{ /$INPUT{'address'}/i } @addresses;

if (@add) {
	&error_pretty("The address you entered, <B>$INPUT{'address'}</B> is already in our mailing list");
}


open(LIST,">>$address_file") || &error(2);
print LIST "$INPUT{'address'}\n";
close(LIST);

print qq~
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Email successfully added!!
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<BR>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
Thank you for your interest<BR><BR>The address <B>$INPUT{'address'}</B> has been added to our mailing list.
<BR><BR>
</td></TR>
<TR bgcolor="$table_head_bg">
<TD>
<FONT SIZE="-1" FACE="arial" color="$table_head_text">
Return to <a href=$name_url>$name_home</a> 
</FONT></TD></TR>

</TABLE>
~;

&Bottom;
exit;
}


########## REMOVE ADDRESSES ##########
sub remove{

unless ($INPUT{'address'}) {
	&error_pretty("You must enter an address to be removed");
}

if (-e "$address_file") {
	&lock($address_file);
	
	open(LIST, "+<$address_file");
	@addresses = <LIST>;
	seek (LIST, 0, 0);
	truncate (LIST,0);
	
	foreach $add(@addresses) {
		chomp($add);
		unless ($add =~ /^$INPUT{'address'}$/i) {
			print LIST "$add\n";
		}
		else {
			$found=1;
		}
	}	
	close(LIST);
	&unlock($address_file);
}

print qq~
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Email successfully removed
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<BR><FONT SIZE="-1" FACE="Arial" color="$table_body_text">
We are sorry to see you go<BR><BR>The address <B>$INPUT{'address'}</B> has been removed from our mailing list
<BR><BR>
</td></TR>
<TR bgcolor="$table_head_bg">
<TD>
<FONT SIZE="-1" FACE="arial" color="$table_head_text">
Return to <a href=$name_url>$name_home</a> 
</FONT></TD></TR>
</TABLE>
~;

&Bottom;
exit;
}

########## SEND EMAILS ##########
sub email {

&checkpassword;

####
$pid = fork();
print "Content-type: text/html \n\n fork failed: $!" unless defined $pid;

if ($pid) {
	#parent
	print "Content-type: text/html \n\n";
	&Top;	
	print qq~
	<table cellspacing=0 border=1 cellpadding =5 width=400>
	<TR bgcolor="$table_head_bg"><TD>
	<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Email successfully sent!!
	</B></FONT><BR><BR>
	</TD></TR>
	<TR bgcolor="$table_body_bg">
	<TD>
	<BR><FONT SIZE="-1" FACE="Arial" color="$table_body_text">
	Emails sent
	</font></td></TR></TABLE>
	~;
	&Bottom;
	exit(0);
}
else {
	#child

	close (STDOUT);
	open(LIST,"$address_file");
	@addresses=<LIST>;
	close(LIST);
	$num_email=0;
	
	foreach $line(@addresses) {
		chomp($line);

		open(MAIL, "|$mail_prog -t") || &error("Could not send out emails");
		print MAIL "To: $line \n";
		print MAIL "From: $your_name <$your_email>\n";
		print MAIL "Subject: $INPUT{'subject'} \n";
		print MAIL "$INPUT{'body'}";
		print MAIL "\n\n";
		if ($remove_link) {
			print MAIL "-------------------------------------------------------------------------\n";
			print MAIL "To be removed from this mailing list\n";
			print MAIL "click on the link below \n";
			print MAIL "http://$mail_url$thisurl?$line\n";
		}
		print MAIL "\n\n";
		close (MAIL);
		$num_email++;
	}

	open(MAIL, "|$mail_prog -t") || &error("Could not send out emails");
	print MAIL "To: $your_email \n";
	print MAIL "From: $your_name <$your_email>\n";
	print MAIL "Subject: $INPUT{'subject'} \n";
	print MAIL "$num_email were sent out with the following message \n\n";
	print MAIL"-----------------------------------------------------------------------------------------\n";
	print MAIL "$INPUT{'body'}";
	print MAIL "\n\n";
	print MAIL "\n\n";
	close (MAIL);
	exit(0);
}
	
	
}

########## DELETE SELECTED EMAILS ##########
sub delete_select {
	
&checkpassword;

open(LIST,"$address_file");
@addresses=<LIST>;
close(LIST);

@addresses = sort(@addresses);

print qq~
<FORM METHOD=POST ACTION="$thisurl">
<table cellspacing=0 border=1 cellpadding =5>
<TR bgcolor="$table_head_bg"><TD colspan=3>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Select email to delete
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
~;
	
$num_email=0;
foreach $line(@addresses) {
	chomp($line);
	if ($num_email == 3) { 
		print "</TR><TR bgcolor=\#C0C0C0 align=left>"; 
		$num_email=0;
	}
	print "<TD><FONT SIZE=\"-2\" FACE=\"Arial\" color=\"$table_body_text\">";
	print "<INPUT TYPE=\"CHECKBOX\" NAME=\"delete\" VALUE=\"$line\"> -- $line</TD>";
	$num_email++;
}

print qq~
<TR align=center bgcolor="$table_body_bg"><TD colspan=3>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
Enter your admin password<BR>
<input type=password name="password" size=20>
<BR><BR>
<INPUT TYPE="SUBMIT" NAME="delete_final" VALUE="Delete these addresses">
</TD></TR></TABLE>
</form>
~;
&Bottom;
exit;	
	
}	

########## DELETE MULTIPLE ##########
sub delete_final {
	
&checkpassword;

open(LIST,"$address_file");
@addresses=<LIST>;
close(LIST);

@deleting = split(/\,/,$INPUT{'delete'});

foreach $line(@deleting) {
	@addresses = grep{ !(/$line/i) } @addresses;
}

open(LIST,">$address_file") || &error(2);
print LIST @addresses;
close(LIST);

$INPUT{'delete'} =~ s/\,/<BR>\n/g;

print qq~
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Emails Removed
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD><FONT SIZE="-1" FACE="Arial" color="$table_body_text">The following emails have been deleted from the database<BR><BR>
<B>$INPUT{'delete'}</B><BR><BR>
</TD></TR></TABLE>
~;

&Bottom;
exit;

}

########## WRITE THE EMAIL ##########
sub sendemail {
	
&checkpassword;

print qq~
<FORM METHOD=POST ACTION=$thisurl>
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD colspan=3>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Create email to send to all users
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
Subject<BR>
<input type = text name=subject size=45>
<BR><BR>Body of Message
	<TEXTAREA NAME=body ROWS=14 COLS=50></TEXTAREA>
<BR><BR>
Admin Password: <INPUT TYPE=PASSWORD NAME=password SIZE=15><BR><BR>
<INPUT TYPE=SUBMIT NAME=email VALUE="Send Email">
</TD></TR></TABLE></FORM>
~;
&Bottom;
exit;
}

########## CHECK PASSWORD ##########
sub checkpassword {

open (PASSWORD, "$pwd_file");
$password = <PASSWORD>; 
close (PASSWORD);

if ($INPUT{'password'}) {
	$newpassword = crypt($INPUT{'password'}, aa);
	unless ($newpassword eq $password) {
		&error_pretty("Wrong Password");
	}
}
else {
	&error_pretty("You must enter a password");
}

}


sub Top {

print qq~
<HTML><HEAD><TITLE>$name_list</TITLE></HEAD>
$body_tag
<CENTER>
<table cellspacing=0 border=1 cellpadding =5>
<TR bgcolor="$table_head_bg"><TD align=center>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>
&nbsp; &nbsp; &nbsp; &nbsp; 
$name_list
&nbsp; &nbsp; &nbsp; &nbsp; 
</FONT>
</TD></TR></TABLE>
<BR><BR>
~;
}

sub Bottom {
print qq~
<BR><BR><table cellspacing=0 bgcolor="$table_head_bg" border=1 cellpadding =3>
<TR align=center><TD><FONT SIZE="-2" FACE="Arial" color="$table_head_text">
<A HREF="http://solutionscripts.com/index.shtml">Power List</A> v $version<br>Free from <A HREF="http://solutionscripts.com/index.shtml">Solution Scripts</A></TD></TR></TABLE>
</FONT><BR><BR>
</BODY></HTML>
~;
}

sub error{
$errors = $_[0] ;

if ($errors == 1) {
	$error_msg = "Unable to write to $pwd_file";
}
else {
	$error_msg = "Unable to write to $address_file";
}	
print qq~
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD colspan=3>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Fatal Error!!
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<BR>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
$error_msg -
<B>$!</B><BR><BR>
If the above error states "Permission Denied than either the dir this cgi file is in or the text file mentioned need 
to be chmoded to 777.<BR><BR>
Do not worry if you do not have the file mentioned, once the permissions are set correctly it will be created for you.
<BR><BR>
If you are having trouble with this script<BR>please post a message to the 
<A HREF="http://forum.solutionscripts.com"><B>CGI Forum</B></A><BR><BR></FONT></TD></TR></TABLE>
~;
&Bottom;
exit;
}

sub error_pretty { 
$errors = $_[0];
print qq~
<table cellspacing=0 border=1 cellpadding =5 width=400>
<TR bgcolor="$table_head_bg"><TD>
<FONT SIZE="-1" FACE="Arial" color="$table_head_text"><B>Error!!
</B></FONT>
</TD></TR>
<TR bgcolor="$table_body_bg">
<TD>
<BR>
<FONT SIZE="-1" FACE="Arial" color="$table_body_text">
$errors
<BR><BR></TD></TR>
<TR bgcolor="$table_head_bg">
<TD>
<FONT SIZE="-1" FACE="arial" color="$table_head_text">
Return to <a href=$name_url>$name_home</a>
</FONT></TD></TR>
</TABLE>
~;
&Bottom;
exit;
}

########## FILE LOCKING SUB ##########
sub lock {

my $file = $_[0];
my $etime = time + 5;

if (-e "$file.lock") {
	open (LOCK,"$file.lock");
	my $temp = <LOCK>;
	close (LOCK);
	chomp ($temp);

    if ($temp < (time - 10)) {
         unlink ("$file.lock");
	}
}

while (-e "$file.lock" && time < $etime) {
	sleep(1);
}

if (-e "$file.lock") {
	print "file lock still here $file.lock";
	exit;
} 
else {
	open (LOCKFILE, ">$file.lock");
	print LOCKFILE time;
	close (LOCKFILE);	
}
}

############
sub unlock {
my $file = shift;
unlink ("$file.lock");
}

1;

