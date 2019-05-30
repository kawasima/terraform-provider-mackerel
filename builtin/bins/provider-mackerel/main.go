package main

import (
	"github.com/hashicorp/terraform/plugin"
	"github.com/kawasima/terraform-provider-mackerel"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: mackerel.Provider,
	})
}
