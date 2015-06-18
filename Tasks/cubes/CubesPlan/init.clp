(deffacts cubes_plan_init_facts
	(task (plan "Cubes plan") (action_type hd_lookat) (params 0 0) (step 1))
	(task (plan "Cubes plan") (action_type subscribe_to_shared_var) (params "recognizedSpeech") (step 2) )
	(task (plan "Cubes plan") (action_type wait_for_user_instruction) (step 3))
	(can_run_in_parallel spg_say cube_clear_arm)
	;(cubes_goal green_cube blue_cube)
	;(cubes_goal green blue red)
)

(deffacts init_facts
        (arm_info (side left))
        (arm_info (side right))
        (head_info (pan -1) (tilt -1))
        (robot_info )
        (module (name MVN-PLN) (speech_name "motion planner") (id "MVN-PLN"))
        (module (name SP-GEN) (speech_name "speech generator") (id "SP-GEN"))
        ;(module (name VISION) (speech_name "vision system") (id "OBJ-FT"))
        (module (name SP-REC) (speech_name "speech recognizer") (id "SP-REC"))
        (module (name ST-PLN) (speech_name "simple task planner") (id "ST-PLN"))
        (module (name NLP) (speech_name "natural language processing system") (id "LANG-UND"))
)

(deffacts settings
        (can_run_in_parallel la_goto ra_goto)
        (can_run_in_parallel la_goto hd_lookat)
        (can_run_in_parallel ra_goto hd_lookat)
        (can_run_in_parallel subscribe_to_shared_var subscribe_to_shared_var)
)
