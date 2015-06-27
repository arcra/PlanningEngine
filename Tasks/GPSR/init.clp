(deffacts GPSR_init_facts
	(task (plan "GPSR") (action_type subscribe_to_shared_var) (params "recognizedSpeech") (step 1) )
        (task (plan "GPSR") (action_type wait_for_user_instruction) (step 2))
)

(deffacts init_facts
        (arm_info (side left))
        (arm_info (side right))
        (head_info (pan -1) (tilt -1))
        (robot_info )
        (module (name SP-GEN) (speech_name "speech generator") (id "SP-GEN"))

        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        ; All
        (can_run_in_parallel subscribe_to_shared_var *)

        ; All but itself
        (can_run_in_parallel spg_say *)
        (cannot_run_in_parallel spg_say spg_say)

        ; All but other la taks
        (can_run_in_parallel la_goto *)
        (cannot_run_in_parallel la_goto arms_goto)
        (cannot_run_in_parallel la_goto la_goto)
        (cannot_run_in_parallel la_goto la_close)
        (cannot_run_in_parallel la_goto la_open)

        ; All but other ra taks
        (can_run_in_parallel ra_goto *)
        (cannot_run_in_parallel ra_goto arms_goto)
        (cannot_run_in_parallel ra_goto ra_goto)
        (cannot_run_in_parallel ra_goto ra_close)
        (cannot_run_in_parallel ra_goto ra_open)

        ; All but arms related and dropping related tasks
        (can_run_in_parallel monitor_grabbing *)
        (cannot_run_in_parallel monitor_grabbing drop)
        (cannot_run_in_parallel monitor_grabbing handover_object)
        (cannot_run_in_parallel monitor_grabbing arms_goto)
        (cannot_run_in_parallel monitor_grabbing la_goto)
        (cannot_run_in_parallel monitor_grabbing ra_goto)
        (cannot_run_in_parallel monitor_grabbing la_close)
        (cannot_run_in_parallel monitor_grabbing ra_close)
        (cannot_run_in_parallel monitor_grabbing la_open)
        (cannot_run_in_parallel monitor_grabbing ra_open)

        (module (name SP_REC) (speech_name "speech recognizer") (id "SP-REC"))
        (module (name ARMS) (speech_name "arms module") (id "ARMS"))
        (module (name HEAD) (speech_name "head module") (id "HEAD"))
        (module (name MVN_PLN) (speech_name "motion planner") (id "MVN-PLN"))
;        (module (name VISION) (speech_name "vision system") (id "OBJ-FNDT"))
        (module (name ST_PLN) (speech_name "simple task planner") (id "ST-PLN"))
        (module (name NLP) (speech_name "natural language processing system") (id "LANG_UND"))
)

(deffacts task_settings

        (item (name apple) (speech_name "apple") (location kitchen_table))
        (location (name kitchen_table) (speech_name "kitchen table") (room kitchen))
        (room (name kitchen) (speech_name "kitchen"))
        
        (task_priority recover_object 100)
)
