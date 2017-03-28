#!/usr/bin/perl
#
# storeid.pl with debug opt - based on storeurl.pl
# @ http://www2.fh-lausitz.de/launic/comp/misc/squid/projekt_youtube/
#
# mods by cespun and fajar @ ipfire.id
#  
 
use IO::File;
$|=1;
STDOUT->autoflush(1);
$debug=0;           ## recommended:0
$bypassallrules=0;      ## recommended:0
$sucks="";          ## unused
$sucks="sucks" if ($debug>=1);
$timenow="";
$printtimenow=1;        ## print timenow: 0|1
my $logfile = '/tmp/storeid.log';
 
open my $logfh, '>>', $logfile
    or die "Couldn't open $logfile for appending: $!\n" if $debug;
$logfh->autoflush(1) if $debug;
 
while (<>) {
$timenow=time()." " if ($printtimenow);
print $logfh "$timenow"."in : $_" if ($debug>=1);
chop;
my $myURL = $_;
@X = split(" ",$myURL);
$a = $X[0]; ## channel id
$b = $X[1]; ## url
$c = $X[2]; ## ip address
$u = $b; ## url
 
if ($bypassallrules){
 $out="$u"; ## map 1:1
 
} elsif ($u=~ m/http.*\.(fbcdn|akamaihd)\.net\/h(profile|photos).*[\d\w].*\/([\w]\d+x\d+\/.*\.[\d\w]{3}).*/) {
    $out="OK store-id=http://fbcdn.net.squid.internal/" . $2 . "/" . $3 ;
} elsif ($u=~ m/^http(.*)static(.*)(akamaihd|fbcdn).net\/rsrc.php\/(.*\/.*\/(.*).(js|css|png|gif|jpg))(\?(.*)|$)/) {
    $out="OK store-id=http://fbcdn.net.squid.internal/static/" . $5 . "." . $6 ;
} elsif ($u =~ m/^https?:\/\/attachment\.fbsbx\.com\/.*\?(id=[0-9]*).*/) {
    $out="OK store-id=http://facebook.squid.internal/" . $1;
} elsif ($u=~ m/^https?\:\/\/.*utm.gif.*/) {
    $out="OK store-id=http://google-analytics.squid.internal/__utm.gif";
} elsif ($u=~ m/^http\:\/\/.*\/speedtest\/(.*\.(jpg|txt|png|swf|gif|xml|css)).*/) {
    $out="OK store-id=http://speedtest.squid.internal/" . $1;
} elsif ($u=~ m/^https?\:\/\/.*\/(.*\..*(mp4|3gp|flv))\?.*/) {
    $out="OK store-id=http://video-file.squid.internal/" . $1;
} elsif ($u=~ m/^https?\:\/\/c2lo\.reverbnation\.com\/audio_player\/ec_stream_song\/(.*)\?.*/) {
    $out="OK store-id=http://reverbnation.squid.internal/" . $1;
} elsif ($u=~ m/^https?\:\/\/.*\.c\.android\.clients\.google\.com\/market\/GetBinary\/GetBinary\/(.*\/.*)\?.*/) {
    $out="OK store-id=http://playstore-android.squid.internal/" . $1;
   
} elsif ($_ =~ m/^https?:\/\/.*\.ytimg\.com\/(.*\.(webp|jpg|gif))/){
    $out="OK store-id=http://ytimg.squid.internal/" . $1;
} elsif ($_ =~ m/^https?:\/\/.*\.gstatic\.com\/images\?q=tbn\:(.*)/){
    $out="OK store-id=http://gstatic.squid.internal/" . $1;
} elsif ($_ =~ m/^https?:\/\/.*\.reverbnation\.com\/.*\/(ec_stream_song|download_song_direct|stream_song)\/([0-9]*).*/){
    $out="OK store-id=http://reverbnation.squid.internal/" . $1;
} elsif ($_ =~ m/^https?:\/\/([^\.]*)\.yimg\.com\/(.*)/){
    $out="OK store-id=http://yimg.squid.internal/" . $1;
} elsif ($_ =~ m/^https?:\/\/(.*?)\/speedtest\/(.*\.(jpg|txt|png|swf|gif|xml|css))\??.*$/){
    $out="OK store-id=http://speedtest.squid.internal/" . $1;
} elsif ($_ =~ m/^https?:\/\/([a-z0-9.]*)(\.doubleclick\.net|\.quantserve\.com|.exoclick\.com|interclick.\com|\.googlesyndication\.com|\.auditude\.com|.visiblemeasures\.com|yieldmanager|cpxinteractive)(.*)/){
    $out="OK store-id=http://ads.squid.internal/" . $1;
} elsif ($_ =~ m/^https?:\/\/(.*?)\/(ads)\?(.*?)/){
    $out="OK store-id=http://ads.squid.internal/" . $1;
   
#} elsif ($_ =~ m/^https?:\/\/.*gemscool\.com\/.*\/([0-9]+\/(.*))/) {
#   $out="OK store-id=http://gemscool.squid.internal/" . $1;
#} elsif ($_ =~ m/^https?:\/\/.*netmarble\.co\.id\/.*\/(Patch|ModooMarble)\/(.*)/) {
#   $out="OK store-id=http://netmarble.squid.internal/" . $1;
#} elsif ($_ =~ m/^https?:\/\/.*lytogame\.com\/.*\/([a-zA-Z]+\/(.*))/) {
#   $out="OK store-id=http://lytogame.squid.internal/" . $1;
   
} elsif ($u=~ m/^https?\:\/\/.*youtube.*ptracking.*/){
    @video_id = m/[&?]video_id\=([^\&\s]*)/;
    @cpn = m/[&?]cpn\=([^\&\s]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "@video_id";
    close FILE;
    }
    $out="ERR";
 
} elsif ($u=~ m/^https?\:\/\/.*youtube.*stream_204.*/){
    @docid = m/[&?]docid\=([^\&\s]*)/;
    @cpn = m/[&?]cpn\=([^\&\s]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "@docid";
    close FILE;
    }
    $out="ERR";
 
} elsif ($u=~ m/^https?\:\/\/.*youtube.*player_204.*/){
    @v = m/[&?]v\=([^\&\s]*)/;
    @cpn = m/[&?]cpn\=([^\&\s]*)/;
    unless (-e "/tmp/@cpn"){
    open FILE, ">/tmp/@cpn";
    print FILE "@v";
    close FILE;
    }
    $out="ERR";
 
} elsif ($u=~ m/^https?\:\/\/.*(youtube|googlevideo).*videoplayback.*/){
    @itag = m/[&?](itag\=[0-9]*)/;
    @range = m/[&?](range\=[^\&\s]*)/;
    @cpn = m/[&?]cpn\=([^\&\s]*)/;
    @mime = m/[&?](mime\=[^\&\s]*)/;
    @id = m/[&?]id\=([^\&\s]*)/;
 
    if (defined(@cpn[0])){
        if (-e "/tmp/@cpn"){
        open FILE, "/tmp/@cpn";
        @id = <FILE>;
        close FILE;}
    }
    $out="OK store-id=http://video-srv.squid.internal/id=@id@mime@range";
 
} else {
    $out="ERR";
}
    print $logfh "$timenow"."out: $a $out\n" if ($debug>=1);
    print "$a $out\n";
}
close $logfh if ($debug);
