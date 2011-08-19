#!/usr/bin/perl -w
use strict;
use warnings;

use SDL;
use SDLx::App;
use SDLx::Text;

use SDL::Event;
use SDL::Events;

my $PADDLE_LENGTH = 50;
my $app = SDLx::App->new(width      => 600,
			 height     => 480,
			 fullscreen => 1,
);
my $event = SDL::Event->new();

my @background = (0,0,0,255);

my @time = localtime();
my $hour = $time[2];
my $minute = $time[1];

my $v1 = 0; my $pos1 = 5;
my $v2 = 0; my $pos2 = 200;
my $quit = 0;

my $b_xpos = 240; my $b_ypos = 300;
my $b_xvel = 1;   my $b_yvel = 1;

my $score = SDLx::Text->new(
    color   => [255,255,255],
    h_align => 'center',
    );

sub press_key {
    my $_ = SDL::Events::get_key_name( $event->key_sym );
    if ($_ eq 'a') { $PADDLE_LENGTH += 10; }
    if ($_ eq 'z') { $PADDLE_LENGTH -= 10; }
    if ($_ eq 'q') { $quit = 1; }
}

sub release_key {
    my $_ = SDL::Events::get_key_name( $event->key_sym );
    if ($_ eq 'up') { $v1 = 0; }
    if ($_ eq 'down') { $v1 = 0; }
}

sub process_events {
    my @time = localtime();
    SDL::Events::pump_events();
    while ( SDL::Events::poll_event($event) ) {
	press_key() if $event->type == SDL_KEYDOWN;
    }
    if ($b_ypos > $pos2 + ($PADDLE_LENGTH / 2)) { $v2 = 1; }
    if ($b_ypos < $pos2 + ($PADDLE_LENGTH / 2)) { $v2 = -1; }
    if ($b_ypos < $pos1 + ($PADDLE_LENGTH / 2)) { $v1 = -1; }
    if ($b_ypos > $pos1 + ($PADDLE_LENGTH / 2)) { $v1 = 1; }
    if ($hour != $time[2]) { $v2 = 0; @background = (10,10,10,255); }
    if ($minute != $time[1]) { $v1 = 0; @background = (10,10,10,255); }
    $pos1 += $v1 if ($b_xvel == -1);
    $pos2 += $v2 if ($b_xvel == 1);
}

sub ball_bounce {
    my @time = localtime();
    if ($b_xpos == 20 && $b_ypos > $pos1 && $b_ypos < $pos1 + $PADDLE_LENGTH) { $b_xvel *= -1; }
    if ($b_xpos == 580 && $b_ypos > $pos2 && $b_ypos < $pos2 + $PADDLE_LENGTH) { $b_xvel *= -1; }
    if ($b_ypos == 0 || $b_ypos == 480) { $b_yvel *= -1; }

    if ($b_xpos == 600) { $hour = $time[2]; @background = (0,0,0,255); }
    if ($b_xpos == 0) { $minute = $time[1]; @background = (0,0,0,255); }
    if ($b_xpos == 0 || $b_xpos == 600) {
	$b_xpos = 240; $b_ypos = 300;
	$b_xvel = 1;   $b_yvel = 1;
    }
    $b_xpos += $b_xvel;
    $b_ypos += $b_yvel;
}

while (!$quit) {
    process_events;
    ball_bounce;
    $app->draw_rect( [0,0,640,480], [@background] );
    $app->draw_rect( [20,$pos1,2,$PADDLE_LENGTH], [0,255,0,255] );
    $app->draw_rect( [580,$pos2,2,$PADDLE_LENGTH], [255,0,0,255] );
    $app->draw_rect( [$b_xpos,$b_ypos,5,5], [255,255,255,255] );
    
    $score->write_to(
	$app,
	$hour . ' : '  . $minute,
	);
    $app->update();
}
