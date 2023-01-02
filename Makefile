include toolbox/mk/common.mk

.PHONY: print-sha256
print-sha256: ## ▶ print sha256 signatures
	echo "+ $@"
	@cd toolbox/mk; \
	for mk_file in $$(ls *.mk | grep -v remote-mk); do \
  	printf "%-29s := %s\n" MK_$$(echo $$mk_file | cut -d '.' -f1 | tr '[:lower:]' '[:upper:]' | tr '-' '_')_SHA256 $$(sha256sum $$mk_file | cut -d " " -f1); \
	done
