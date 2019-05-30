VERSION=v0.1.0
ARCH=amd64
OS=linux

TEST?=$$(go list ./... | grep -v '/vendor/')
VETARGS?=-all
GOFMT_FILES?=$$(find . -name '*.go' | grep -v vendor)

TARGET_BINARY=$(CURDIR)/bin/terraform-provider-mackerel_$(VERSION)
TERRAFORM_PLUGIN_DIR=$(HOME)/.terraform.d/plugins/$(OS)_$(ARCH)

default: test

clean:
	rm -Rf $(CURDIR)/bin/*

build: $(TARGET_BINARY)

$(TARGET_BINARY): deps
	go build -o $(TARGET_BINARY) $(CURDIR)/builtin/bins/provider-mackerel/main.go

deps:
	dep ensure

test: build vet
	TF_ACC= go test $(TEST) $(TESTARGS) -timeout=30s -parallel=4

testacc: vet
	TF_ACC=1 go test $(TEST) -v $(TESTARGS) -timeout 120m

vet: fmt
	@echo "go vet $(VETARGS) ."
	@go vet $(VETARGS) ; if [ $$? -eq 1 ]; then \
		echo ""; \
		echo "Vet found suspicious constructs. Please check the reported constructs"; \
		echo "and fix them if necessary before submitting the code for review."; \
		exit 1; \
	fi

fmt:
	gofmt -w $(GOFMT_FILES)

install_plugin_locally: $(TARGET_BINARY)
	mkdir -p $(TERRAFORM_PLUGIN_DIR)
	cp $(TARGET_BINARY) $(TERRAFORM_PLUGIN_DIR)/

.PHONY: default build test vet fmt
