mustconfigure:
	@printf "\n\nNot yet configured: runnung 'make configure'.\n\n"
	@make -s configure
	@printf "\n\n"
	@make -s usage

