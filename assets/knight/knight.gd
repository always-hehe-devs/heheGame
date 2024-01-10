extends Node2D

func play_idle_animation():
	%AnimatedSprite2D.play("idle")
	
func play_run_animation():
	%AnimatedSprite2D.play("run")

func play_roll_animation():
	%AnimatedSprite2D.play("roll")
