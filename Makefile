VERSION=$(shell jq -r .variables.version freedos.json)

help:
	@echo type make build-libvirt

build-libvirt: freedos-${VERSION}-libvirt.img

freedos-${VERSION}-libvirt.img: freedos.json
	rm -f freedos-${VERSION}-libvirt.box
	PACKER_KEY_INTERVAL=10ms CHECKPOINT_DISABLE=1 PACKER_LOG=1 PACKER_LOG_PATH=$@.log \
		packer build -only=freedos-${VERSION}-libvirt -on-error=abort freedos.json

.PHONY: buid-libvirt
