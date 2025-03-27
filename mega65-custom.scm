(define memories
'(
	(memory zeroPage (address (#x2 . #x7f)) (type ram) (qualifier zpage)
		(section (registers #x2))
	)
	
	(memory stackPage (address (#x100 . #x1ff))
		(type ram)
	)

	(memory hzd (address (#x0400 . #x0dff)) (type any)
		(section
			heap
			zdata
		)
	)

	(memory prog (address (#x1200 . #x6fff)) (type any)
		(section
			(programStart #x1200)
			startup
			code
			data
			switch
			cdata
			data_init_table
		)
	)
))
