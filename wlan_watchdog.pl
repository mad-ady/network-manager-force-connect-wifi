#!/usr/bin/perl
use strict;
use warnings;
use Sys::Syslog qw(:standard :macros);  # standard functions & macros

my $wifi = `nmcli --fields=DEVICE device | egrep '^wl' | tail -1`;
chomp $wifi;

openlog("$0", "pid,nofatal,perror", "local0");
syslog( "info", "Started");
sub get_wlan_status {
  my $status =  `nmcli device | grep $wifi | grep disconnected | wc -l`;
  chomp $status;
  return $status;
}

sub get_current_connected_ap {
   my $connected_ap=`nmcli device  | grep $wifi | cut -c '37-' | sed -r 's/\\s+\$//'`;
   chomp $connected_ap;
   return $connected_ap;
}

my @configured_ap=`nmcli --fields=NAME connection show | tail -n +2`;
chomp @configured_ap;
s/\s+$//g for (@configured_ap);
my @visible_ap=`nmcli --fields=SSID device wifi | tail +2`;
chomp @visible_ap;
s/\s+$//g for (@visible_ap);
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
				my $new_ap = get_current_connected_ap();
				syslog("info", "Wifi successfully connected to $new_ap");

				sleep(5);
				#set the metric (prevent loops through docker/anbox)
				print `ifmetric $wifi 110`;
				if( -e "/usr/local/bin/telegram-send"){
					`/usr/local/bin/telegram-send "Wifi successfully connected to $new_ap"`;
				}
				#no need to try further
				exit;

			}
			
		}
	}

}
else{
	syslog("info", "We are connected to ".get_current_connected_ap().". Nothing to do");
}
