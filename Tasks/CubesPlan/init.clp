(deffacts cubes_plan_init_facts
	(task (plan "Cubes plan") (action_type hd_lookat) (params 0 0) (step 1))
	(task (plan "Cubes plan") (action_type subscribe_to_shared_var) (params "recognizedSpeech") (step 2) )
	(task (plan "Cubes plan") (action_type wait_for_user_instruction) (step 3))
	(can_run_in_parallel spg_say cube_clear_arm)
	;(cubes_goal green_cube blue_cube)
	;(cubes_goal green blue red)
)
