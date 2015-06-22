(deffunction spg_say
	(?symbol $?elements)
	(bind ?text "")
	(progn$ (?var $?elements)
		(bind ?text (str-cat ?text " " ?var) )
	)
	(bind ?length (str-length ?text))
	(bind ?timeout (+ (* 250 ?length) 1000) )
	(send-command "spg_say" ?symbol ?text ?timeout )
)