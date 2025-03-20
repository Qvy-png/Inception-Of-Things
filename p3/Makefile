
GREEN		=	\033[1;32m
YELLOW		=	\033[0;33m
NC			=	\033[0m

all: up

up:
	@echo "${YELLOW}[MAKEFILE]${NC} - launching scripts"
	@sudo ./scripts/install.sh && sudo ./scripts/launch.sh

clean:
	sudo k3d cluster delete rpol