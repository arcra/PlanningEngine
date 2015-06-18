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

(deftemplate robot_info
	(slot location
		(type SYMBOL)
		(default custom)
	)
	(slot status
		(type SYMBOL)
		(default normal)
	)
	(slot x
		(type NUMBER)
	)
	(slot y
		(type NUMBER)
	)
	(slot angle
		(type NUMBER)
	)
)

(deftemplate item
	(slot name
		(type LEXEME)
	)
	(slot speech_name
		(type LEXEME)
	)
	(slot location
		(type LEXEME)
		(default unknown)
	)
)

(deftemplate location
	(slot name
		(type SYMBOL)
	)
	(slot speech_name
		(type LEXEME)
	)
	(slot room
		(type SYMBOL)
		(default unknown)
	)
)

(deftemplate position
	(slot name
		(type SYMBOL)
	)
	(slot x
		(type NUMBER)
	)
	(slot y
		(type NUMBER)
	)
	(slot angle
		(type NUMBER)
	)
)

(deftemplate room
	(slot name
		(type SYMBOL)
	)
	(slot speech_name
		(type LEXEME)
	)
)

(deftemplate module
	(slot name
		(type LEXEME)
	)
	(slot id
		(type STRING)
	)
	(slot status
		(type SYMBOL)
		(default connected)
	)
	(slot speech_name
		(type LEXEME)
	)
)

(deftemplate person
	(slot name
		(type LEXEME)
	)
	(slot speech_name
		(type LEXEME)
	)
	(slot location
		(type SYMBOL)
		(default unknown)
	)
	(slot room
		(type SYMBOL)
		(default unknown)
	)
)

(deffacts PE-init_facts
	(PE-last_plan nil)
)
