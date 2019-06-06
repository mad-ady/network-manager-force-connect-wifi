#!/usr/bin/perl
use strict;
use warnings;
use Sys::Syslog qw(:standard :macros);  # standard functions & macros

openlog("$0", "pid,nofatal,perror", "local0");
syslog( "info", "Started");
sub get_wlan_status {
  my $status =  `nmcli device | grep wlan0 | grep disconnected | wc -l`;
  chomp $status;
  return $status;
}

sub get_current_connected_ap {
   my $connected_ap=`nmcli device  | grep wlan0 | cut -c '37-' | sed -r 's/\\s+\$//'`;
   chomp $connected_ap;
   return $connected_ap;
}

my @configured_ap=`nmcli connection show | grep wifi | cut -c '1-20' | sed -r 's/\\s+\$//'`;
chomp @configured_ap;
my @visible_ap=`nmcli device wifi | grep Infra | cut -c '1-29' | sed -r 's/\\s+\$//' | sed -r 's/^\\s+//'`;
chomp @visible_ap;
my %configured_ap_hash = map { $_ => 1 } @configured_ap;

syslog("info", "Visible APs: ".join(", ", @visible_ap));
syslog("info", "Configured APs: ".join(", ", @configured_ap));

if(get_wlan_status() == "1"){
	syslog("warning", "Wifi is disconnected. Trying to connect");
	foreach my $ap (@visible_ap){
		if(defined $configured_ap_hash{$ap}){
			syslog("info", "Trying to connect to known AP $ap");
			syslog("info", `nmcli connection up "$ap"`);
			if(get_wlan_status() == "1"){
				syslog("warning", "Wifi is still disconnected...");
			}
			else{
				syslog("info", "Wifi successfully connected to ".get_current_connected_ap());
				#no need to try further
				exit;
			}			
		}
	}
}
else{
	syslog("info", "We are connected to ".get_current_connected_ap().". Nothing to do");
}
