GREEN		=	\033[1;32m
YELLOW		=	\033[0;33m
NC			=	\033[0m

all: up

up:
	@echo "${YELLOW}[MAKEFILE]${NC} - vagrant up"
	@sudo vagrant up

status:
	@sudo vagrant status

server:
	@sudo vagrant ssh rdel-aguS
	
clean:
	@sudo vagrant destroy -f