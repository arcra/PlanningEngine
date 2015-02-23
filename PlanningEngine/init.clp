(deftemplate arm_info
	(slot side
		(type SYMBOL)
	)
	(slot position
		(type STRING)
		(default "home")
	)
	(slot grabbing
		(type LEXEME)
		(default nil)
	)
	(slot enabled
		(type SYMBOL)
		(allowed-symbols TRUE FALSE)
		(default TRUE)
	)
)

(deftemplate head_info
	(slot pan
		(type NUMBER)
	)
	(slot tilt
		(type NUMBER)
	)
)

(deffacts PE-init_facts
    (PE-last_plan nil)
;    (arm_info (side left) (enabled FALSE))
	(arm_info (side left))
    (arm_info (side right))
    (head_info (pan -1) (tilt -1))
)

(deffacts PE-settings
    (can_run_in_parallel la_goto ra_goto)
    (can_run_in_parallel la_goto hd_lookat)
    (can_run_in_parallel ra_goto hd_lookat)
    (can_run_in_parallel subscribe_to_shared_var subscribe_to_shared_var)
)
