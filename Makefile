# Wrapper so that `make` works from PowerShell / Windows Terminal.
# GNU make runs recipes with cmd.exe here (no sh on PATH).
# make.bat needs the Arkos Tracker song for the event track; Acid_demo_21.aks
# is the one added in the final-version commit (2020-05-26). Override: make AKS=...
AKS ?= data\music\Acid_demo_21.aks

.PHONY: all build assets music help
all: build

build:
	cmd /c .\make.bat $(AKS)

assets:
	cmd /c .\make-assets.bat

music:
	cmd /c .\make-music.bat $(AKS)

help:
	@echo make          - events + code + disc\nova-invite.ssd (runs make.bat $(AKS))
	@echo make assets   - convert images/fonts/anims into build\ (make-assets.bat)
	@echo make music    - rebuild music + events + disc from the AKS (make-music.bat)
	@echo make help     - this list
	@echo run.bat copies the disc to ..\jsbeeb-kieranhj\discs and opens runme.url
