(deffacts cubes_plan_init_facts
	(task (plan "Cubes plan") (action_type cubes_plan))
	(can_run_in_parallel spg_say cube_clear_arm)
	(cubes_goal green blue)
	;(cubes_goal green blue red)
)
