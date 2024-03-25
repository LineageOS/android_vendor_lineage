package prebuilt_etc_dir

import (
	"path"
	"path/filepath"
	"strings"

	"github.com/google/blueprint/proptools"

	"android/soong/android"
	"android/soong/etc"
	"android/soong/phony"
)

func init() {
	android.RegisterModuleType("prebuilt_etc_dir", prebuiltEtcDirFactory)
	android.RegisterModuleType("prebuilt_etc_dir_host", prebuiltEtcDirHostFactory)
}

type prebuiltEtcDirProperties struct {
	Name     *string
	Srcs     []string
	Src_dir  *string
	Dest_dir *string
}

func prebuiltEtcDirLoadHook(
	ctx android.LoadHookContext, factory android.ModuleFactory, c *prebuiltEtcDirProperties) {
	var srcs []string

	if c.Srcs != nil && len(c.Srcs) > 0 {
		for _, src := range c.Srcs {
			srcs = append(srcs, path.Join(ctx.ModuleDir(), *c.Src_dir, src))
		}
	} else {
		files, err := ctx.GlobWithDeps(path.Join(ctx.ModuleDir(), *c.Src_dir, "**/*"), nil)
		if err != nil {
			ctx.PropertyErrorf("src_dir", err.Error())
			return
		}
		for _, src := range files {
			if !strings.HasSuffix(src, "/") {
				srcs = append(srcs, src)
			}
		}
	}

	if len(srcs) == 0 {
		ctx.PropertyErrorf("src_dir", "No files available to install")
		return
	}

	// Scan through the found files to create a prebuilt_etc module for each of them.
	requiredModuleNames := make([]string, len(srcs))
	for i, src := range srcs {
		modulePath, _ := filepath.Rel(ctx.ModuleDir(), src)
		modulePathRel, _ := filepath.Rel(path.Join(ctx.ModuleDir(), *c.Src_dir), src)
		moduleSubDir := filepath.Dir(modulePathRel)
		moduleName := *c.Name + strings.ReplaceAll(modulePath, "/", "-")

		etcProps := struct {
			Name     *string
			Src      *string
			Sub_dir  *string
			Filename *string
		}{
			Name: proptools.StringPtr(moduleName),
			Src: proptools.StringPtr(modulePath),
			Sub_dir: proptools.StringPtr(path.Join(*c.Dest_dir, moduleSubDir)),
			Filename: proptools.StringPtr(filepath.Base(src)),
		}
		ctx.CreateModule(factory, &etcProps)

		// Add it to the required module list of the parent phony rule.
		requiredModuleNames[i] = moduleName
	}

	phonyProps := struct {
		Required []string
	}{
		Required: requiredModuleNames,
	}
	ctx.AppendProperties(&phonyProps)
}

func prebuiltEtcDirFactory() android.Module {
	p := phony.PhonyFactory()
	c := &prebuiltEtcDirProperties{}
	android.AddLoadHook(p, func(ctx android.LoadHookContext) {
		prebuiltEtcDirLoadHook(ctx, etc.PrebuiltEtcFactory, c)
	})
	p.AddProperties(c)
	return p
}

func prebuiltEtcDirHostFactory() android.Module {
	p := phony.PhonyFactory()
	c := &prebuiltEtcDirProperties{}
	android.AddLoadHook(p, func(ctx android.LoadHookContext) {
		prebuiltEtcDirLoadHook(ctx, etc.PrebuiltEtcHostFactory, c)
	})
	p.AddProperties(c)
	return p
}
