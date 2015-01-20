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

(deffacts PE-init_facts
    (PE-last_plan nil)
    (arm_info (side left))
    (arm_info (side right))
)

(deffacts PE-settings
    (can_run_in_parallel la_goto ra_goto)
)
